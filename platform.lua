-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer

-- 🔔 EKRANDA 5 SANİYE BOYUNCA BÜYÜK BOYUTTA BELİRGİN BİLDİRİM FONKSİYONU
local function showCustomNotification(titleText, descText)
    task.spawn(function()
        local pg = player:FindFirstChild("PlayerGui")
        if not pg then return end
        
        local oldNotif = pg:FindFirstChild("TemporaryScriptNotification")
        if oldNotif then oldNotif:Destroy() end
        
        local notifGui = Instance.new("ScreenGui")
        notifGui.Name = "TemporaryScriptNotification"
        notifGui.ResetOnSpawn = false
        notifGui.Parent = pg
        
        local notifFrame = Instance.new("Frame")
        notifFrame.Size = UDim2.new(0, 380, 0, 95)
        notifFrame.Position = UDim2.new(0.5, -190, 0, -120)
        notifFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        notifFrame.BorderSizePixel = 0
        notifFrame.Parent = notifGui
        
        Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 12)
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(80, 70, 220)
        stroke.Thickness = 2.5
        stroke.Parent = notifFrame
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 30)
        title.Position = UDim2.new(0, 10, 0, 12)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(120, 200, 255)
        title.TextSize = 17
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Text = titleText
        title.Parent = notifFrame
        
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -20, 0, 40)
        desc.Position = UDim2.new(0, 10, 0, 42)
        desc.BackgroundTransparency = 1
        desc.TextColor3 = Color3.fromRGB(240, 240, 255)
        desc.TextSize = 14
        desc.Font = Enum.Font.GothamMedium
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.TextWrapped = true
        desc.Text = descText
        desc.Parent = notifFrame
        
        local info = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local slideIn = TweenService:Create(notifFrame, info, {Position = UDim2.new(0.5, -190, 0, 25)})
        slideIn:Play()
        
        task.wait(5)
        
        local slideOut = TweenService:Create(notifFrame, info, {Position = UDim2.new(0.5, -190, 0, -120)})
        slideOut:Play()
        slideOut.Completed:Wait()
        
        notifGui:Destroy()
    end)
end

-- 🔒 ÜST ÜSTE GUI AÇILMAMA KİLİDİ (GLOBAL KONTROL)
if player:FindFirstChild("PlayerGui") then
    local existingGui = player.PlayerGui:FindFirstChild("ModernCategorizedMenu")
    if existingGui then
        warn("⚠️ Menü zaten açık! Üst üste açılması engellendi ipucu - basıca göz tuşu çıkar. O göz tuşuna 2 kez tıklarsan geri açılır.")
        showCustomNotification("⚠️ Uyarı / Warning", "Menü zaten açık! Üst üste açılması engellendi. ipucu - basıca göz tuşu çıkar. O göz tuşuna 2 kez tıklarsan geri açılır.")
        return
    end
end

local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

humanoid.JumpPower = 50
humanoid.UseJumpPower = true

local platform = nil
local isPlatformActive = false
local lockedHeight = humanoidRootPart.Position.Y - 3

local noclipActive = false
local noclipConnection = nil
local savedWalkSpeed = 16
local isSpawningLocked = false
local isMinimized = false

local flyActive = false
local flyConnection = nil
local flySpeed = 50
local bg, bv
local mobUpPressed = false
local mobDownPressed = false

local holdJumpActive = false
local isHoldingJump = false

local walkFlingActive = false
local walkFlingConnection = nil

local powerfulTrampolineActive = false
local trampolinePart = nil
local trampolineConnection = nil

local isSitTrollActive = false

local focusedTargetPlayer = nil
local targetFocusActive = false

local espEnabled = false
local espBoxEnabled = true
local espNameEnabled = true
local espDistanceEnabled = true
local espTracersEnabled = false
local espObjects = {}

local xrayEnabled = false
local xrayTransparency = 0.5
local originalPartsData = {}

local originalVolumes = {}
local isMuted = false

local deathNotificationEnabled = true
local deathConnections = {}

local function showDeathNotification(message)
    if not deathNotificationEnabled then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🎯 Target Fling",
            Text = message,
            Duration = 3,
        })
    end)
end

local function monitorPlayer(p)
    if p == player then return end
    local function onCharacterAdded(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            deathConnections[p] = hum.Died:Connect(function()
                showDeathNotification(p.Name .. " öldü!")
            end)
        end
    end
    
    if p.Character then
        onCharacterAdded(p.Character)
    end
    p.CharacterAdded:Connect(onCharacterAdded)
end

for _, p in ipairs(Players:GetPlayers()) do
    monitorPlayer(p)
end

Players.PlayerAdded:Connect(monitorPlayer)

Players.PlayerRemoving:Connect(function(p)
    if deathConnections[p] then
        deathConnections[p]:Disconnect()
        deathConnections[p] = nil
    end
    if focusedTargetPlayer == p then
        focusedTargetPlayer = nil
        targetFocusActive = false
    end
end)

local currentLang = "TR"
local translations = {
    ["TR"] = {
        title = "⚡ MODERN TARGET FLING ⚡",
        homeTab = "Ev", visualsTab = "Visuals", soundTab = "Ses", platformTab = "Platform", cheatsTab = "Hileler", trollTab = "Troll", boredomTab = "Can Sıkıntısı", langTab = "Dil", guideTab = "Kılavuz",
        closeBtn = "Menüyü Kapat",
        homeWelcome = "⚡ Modern Arayüze Hoş Geldin!\n\nEv sekmesi altından ölüm bildirimlerini yönetebilirsin. Üstteki Visuals düğmesinden ESP ve X-Ray ayarlarını açabilirsin.",
        deathSectionTitle = "🎯 ÖLÜM AYARLARI",
        visualsSectionTitle = "👁️ BÖLÜM 1: ESP AYARLARI",
        xraySectionTitle = "🧱 BÖLÜM 2: X-RAY (DUVAR GÖRÜŞÜ) AYARLARI",
        musicIdPh = "Müzik ID Gir", playMusic = "Müziği Oynat", stopMusic = "Müziği Kapat", muteGame = "Oyun Sesini Sustur", unmuteGame = "Oyun Sesini Aç",
        upBtn = "+ (Yukarı)", downBtn = "- (Aşağı)", platOn = "Platform: AÇIK", platOff = "Platform: KAPALI",
        speedPh = "Hız Yaz (örn: 50)", noclipOn = "Noclip: AÇIK", noclipOff = "Noclip: KAPALI", flyOn = "Uçma: AÇIK", flyOff = "Uçma: KAPALI", holdJumpOn = "Zıplama Tuşuyla Yüksel: AÇIK", holdJumpOff = "Zıplama Tuşuyla Yüksel: KAPALI",
        trollTitle = "🌀 TROLL ÖZELLİKLERİ", walkFlingOn = "Target Fling (Dönen): AÇIK", walkFlingOff = "Target Fling (Dönen): KAPALI",
        sitTrollOn = "Yere Oturtma Troll: AÇIK", sitTrollOff = "Yere Oturtma Troll: KAPALI",
        deathNotifOn = "Ölüm Bildirimi: AÇIK", deathNotifOff = "Ölüm Bildirimi: KAPALI",
        boredomTitle = "🎲 CAN SIKINTISI BÖLÜMÜ", trampolineOn = "Güçlü Trambolin: AÇIK", trampolineOff = "Güçlü Trambolin: KAPALI",
        flyTitle = "✈️ UÇMA YÜKSEKLİK", upMob = "Yüksel", downMob = "Alçal",
        langTrBtn = "🇹🇷 Türkçe", langEnBtn = "🇬🇧 English",
        espMainOn = "ESP Sistemi: AÇIK", espMainOff = "ESP Sistemi: KAPALI",
        espBoxOn = "ESP Kutu: AÇIK", espBoxOff = "ESP Kutu: KAPALI",
        espNameOn = "ESP İsim: AÇIK", espNameOff = "ESP İsim: KAPALI",
        espDistOn = "ESP Mesafe: AÇIK", espDistOff = "ESP Mesafe: KAPALI",
        espTracerOn = "ESP Çizgi (Tracer): AÇIK", espTracerOff = "ESP Çizgi (Tracer): KAPALI",
        xrayMainOn = "X-Ray Duvar Görüşü: AÇIK", xrayMainOff = "X-Ray Duvar Görüşü: KAPALI",
        xraySliderPh = "Şeffaflık Gir (örn: 0.5)",
        targetFocusSectionTitle = "🎯 HEDEF ODAKLANMA (TARGET FOCUS)",
        targetDropdownPh = "Hedef Oyuncu Seç...",
        targetFocusBtnOn = "Hedefe Odaklanma: AÇIK",
        targetFocusBtnOff = "Hedefe Odaklanma: KAPALI",
        guideText = [[📜 KILAVUZ & BİLGİLER:

🎯 Target Fling (Dönen Mod):
Karakterini hedefledikten sonra yüksek hızda döndürerek fizik motorunu tetikler ve uzaya uçurur!
🎯 Hedefe Odaklanma (Target Focus):
Troll sekmesinden seçtiğin spesifik bir oyuncunun tam üstüne kilitlenerek onu taklit eder/rahatsız edersin!
🎲 Güçlü Trambolin:
Önünde beliren tramboline değerek gökyüzüne uçabilirsin!
👁️ Visuals / ESP & X-Ray Sistemi:
Visuals sekmesinden ESP özelliklerini ve 2. Bölümden X-Ray duvar şeffaflığını aktif edebilirsin.]]
    },
    ["EN"] = {
        title = "⚡ MODERN TARGET FLING ⚡",
        homeTab = "Home", visualsTab = "Visuals", soundTab = "Sound", platformTab = "Platform", cheatsTab = "Cheats", trollTab = "Troll", boredomTab = "Boredom", langTab = "Lang", guideTab = "Guide",
        closeBtn = "Close Menu",
        homeWelcome = "⚡ Welcome to the Modern UI!\n\nYou can manage death notifications from the Home tab, and ESP/X-Ray settings from the Visuals button above.",
        deathSectionTitle = "🎯 DEATH SETTINGS",
        visualsSectionTitle = "👁️ SECTION 1: ESP SETTINGS",
        xraySectionTitle = "🧱 SECTION 2: X-RAY (WALL VIEW) SETTINGS",
        musicIdPh = "Enter Music ID", playMusic = "Play Music", stopMusic = "Stop Music", muteGame = "Mute Game Audio", unmuteGame = "Unmute Game Audio",
        upBtn = "+ (Up)", downBtn = "- (Down)", platOn = "Platform: ON", platOff = "Platform: OFF",
        speedPh = "Enter Speed (e.g: 50)", noclipOn = "Noclip: ON", noclipOff = "Noclip: OFF", flyOn = "Fly: ON", flyOff = "Fly: OFF", holdJumpOn = "Hold Jump: ON", holdJumpOff = "Hold Jump: OFF",
        trollTitle = "🌀 TROLL FEATURES", walkFlingOn = "Target Fling (Spinning): ON", walkFlingOff = "Target Fling (Spinning): OFF",
        sitTrollOn = "Sit Troll: ON", sitTrollOff = "Sit Troll: OFF",
        deathNotifOn = "Death Notification: ON", deathNotifOff = "Death Notification: OFF",
        boredomTitle = "🎲 BOREDOM SECTION", trampolineOn = "Powerful Trampoline: ON", trampolineOff = "Powerful Trampoline: OFF",
        flyTitle = "✈️ FLY HEIGHT", upMob = "Up", downMob = "Down",
        langTrBtn = "🇹🇷 Turkish", langEnBtn = "🇬🇧 English",
        espMainOn = "ESP System: ON", espMainOff = "ESP System: OFF",
        espBoxOn = "ESP Box: ON", espBoxOff = "ESP Box: OFF",
        espNameOn = "ESP Name: ON", espNameOff = "ESP Name: OFF",
        espDistOn = "ESP Distance: ON", espDistOff = "ESP Distance: OFF",
        espTracerOn = "ESP Tracer: ON", espTracerOff = "ESP Tracer: OFF",
        xrayMainOn = "X-Ray Wall View: ON", xrayMainOff = "X-Ray Wall View: OFF",
        xraySliderPh = "Enter Transparency (e.g: 0.5)",
        targetFocusSectionTitle = "🎯 TARGET FOCUS",
        targetDropdownPh = "Select Target Player...",
        targetFocusBtnOn = "Target Focus: ON",
        targetFocusBtnOff = "Target Focus: OFF",
        guideText = [[📜 GUIDE & INFO:

🎯 Target Fling (Spinning Mode):
Spins your character at high speed into targets, triggering the physics engine to fling them away!
🎯 Target Focus:
Locks onto and follows a specific player chosen from the Troll tab to annoy or trail them!
🎲 Powerful Trampoline:
Step on the trampoline spawned in front of you to fly into the sky!
👁️ Visuals / ESP & X-Ray System:
You can toggle ESP features and X-Ray wall transparency from Section 2 of the Visuals tab.]]
    }
}

local backgroundMusic = Instance.new("Sound")
backgroundMusic.Name = "CustomBackgroundMusic"
backgroundMusic.Looped = true
backgroundMusic.Parent = SoundService

local function createPlatform()
    if platform then platform:Destroy() end
    platform = Instance.new("Part")
    platform.Size = Vector3.new(15, 1, 15)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.5
    platform.Parent = workspace
end

if humanoidRootPart then
    lockedHeight = humanoidRootPart.Position.Y - 3
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernCategorizedMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 480, 0, 320)
frame.Position = UDim2.new(0.5, -240, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local dropShadow = Instance.new("UIStroke")
dropShadow.Color = Color3.fromRGB(80, 70, 220)
dropShadow.Transparency = 0.5
dropShadow.Thickness = 2
dropShadow.Parent = frame

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 45)
topBar.BackgroundTransparency = 1
topBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -210, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = translations["TR"].title
titleLabel.Parent = topBar

local topVisualsButton = Instance.new("TextButton")
topVisualsButton.Size = UDim2.new(0, 75, 0, 30)
topVisualsButton.Position = UDim2.new(1, -195, 0, 8)
topVisualsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
topVisualsButton.TextColor3 = Color3.fromRGB(120, 200, 255)
topVisualsButton.TextSize = 12
topVisualsButton.Font = Enum.Font.GothamBold
topVisualsButton.Text = "Visuals"
topVisualsButton.ZIndex = 3
topVisualsButton.Visible = true
topVisualsButton.Parent = topBar
Instance.new("UICorner", topVisualsButton).CornerRadius = UDim.new(0, 8)

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 32, 0, 32)
minimizeButton.Position = UDim2.new(1, -112, 0, 7)
minimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
minimizeButton.TextColor3 = Color3.fromRGB(200, 200, 220)
minimizeButton.TextSize = 14
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Text = "-"
minimizeButton.ZIndex = 3
minimizeButton.Parent = topBar
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 8)

local closeTopButton = Instance.new("TextButton")
closeTopButton.Size = UDim2.new(0, 32, 0, 32)
closeTopButton.Position = UDim2.new(1, -75, 0, 7)
closeTopButton.BackgroundColor3 = Color3.fromRGB(220, 50, 70)
closeTopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeTopButton.TextSize = 12
closeTopButton.Font = Enum.Font.GothamBold
closeTopButton.Text = "✕"
closeTopButton.ZIndex = 3
closeTopButton.Parent = topBar
Instance.new("UICorner", closeTopButton).CornerRadius = UDim.new(0, 8)

local eyeControlGui = Instance.new("ScreenGui")
eyeControlGui.Name = "ModernEyeControl"
eyeControlGui.ResetOnSpawn = false
eyeControlGui.Enabled = false
eyeControlGui.Parent = player:WaitForChild("PlayerGui")

local eyeButton = Instance.new("TextButton")
eyeButton.Size = UDim2.new(0, 50, 0, 50)
eyeButton.Position = UDim2.new(0.05, 0, 0.4, 0)
eyeButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
eyeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
eyeButton.TextSize = 24
eyeButton.Font = Enum.Font.GothamBold
eyeButton.Text = "👁"
eyeButton.Active = true
eyeButton.Draggable = true
eyeButton.ZIndex = 9999
eyeButton.Parent = eyeControlGui
Instance.new("UICorner", eyeButton).CornerRadius = UDim.new(1, 0)

local eyeStroke = Instance.new("UIStroke")
eyeStroke.Color = Color3.fromRGB(80, 70, 220)
eyeStroke.Thickness = 2
eyeStroke.Parent = eyeButton

local resizeButton = Instance.new("TextButton")
resizeButton.Size = UDim2.new(0, 26, 0, 26)
resizeButton.Position = UDim2.new(1, -30, 1, -30)
resizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
resizeButton.TextColor3 = Color3.fromRGB(200, 200, 220)
resizeButton.TextSize = 11
resizeButton.Font = Enum.Font.GothamBold
resizeButton.Text = "↔️"
resizeButton.ZIndex = 5
resizeButton.Parent = frame
Instance.new("UICorner", resizeButton).CornerRadius = UDim.new(0, 6)

local resizeStroke = Instance.new("UIStroke")
resizeStroke.Color = Color3.fromRGB(80, 70, 220)
resizeStroke.Transparency = 0.4
resizeStroke.Thickness = 1
resizeStroke.Parent = resizeButton

local isResizing = false
local resizeStartPos = Vector2.new(0, 0)
local startFrameSize = UDim2.new(0, 480, 0, 320)

resizeButton.MouseButton1Down:Connect(function()
    if isMinimized then return end
    isResizing = true
    resizeStartPos = UserInputService:GetMouseLocation()
    startFrameSize = frame.AbsoluteSize
    resizeStroke.Color = Color3.fromRGB(120, 110, 255)
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = false
        resizeStroke.Color = Color3.fromRGB(80, 70, 220)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local currentMousePos = UserInputService:GetMouseLocation()
        local delta = currentMousePos - resizeStartPos
        local newWidth = math.clamp(startFrameSize.X + delta.X, 360, 850)
        local newHeight = math.clamp(startFrameSize.Y + delta.Y, 240, 650)
        frame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

local flyControlGui = Instance.new("ScreenGui")
flyControlGui.Name = "ModernFlyControl"
flyControlGui.ResetOnSpawn = false
flyControlGui.Enabled = false
flyControlGui.Parent = player:WaitForChild("PlayerGui")

local flyFrame = Instance.new("Frame")
flyFrame.Size = UDim2.new(0, 140, 0, 75)
flyFrame.Position = UDim2.new(1, -160, 0.5, -37)
flyFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
flyFrame.BorderSizePixel = 0
flyFrame.Active = true
flyFrame.Draggable = true
flyFrame.Parent = flyControlGui
Instance.new("UICorner", flyFrame).CornerRadius = UDim.new(0, 10)
local flyStroke = Instance.new("UIStroke")
flyStroke.Color = Color3.fromRGB(80, 70, 220)
flyStroke.Thickness = 1.5
flyStroke.Parent = flyFrame

local flyTitle = Instance.new("TextLabel")
flyTitle.Size = UDim2.new(1, 0, 0, 25)
flyTitle.BackgroundTransparency = 1
flyTitle.TextColor3 = Color3.fromRGB(100, 220, 150)
flyTitle.TextSize = 11
flyTitle.Font = Enum.Font.GothamBold
flyTitle.Text = translations["TR"].flyTitle
flyTitle.Parent = flyFrame

local function createMobBtn(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.Parent = flyFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local upMobBtn = createMobBtn(translations["TR"].upMob, UDim2.new(0, 6, 0, 32), Color3.fromRGB(40, 140, 90))
local downMobBtn = createMobBtn(translations["TR"].downMob, UDim2.new(0, 74, 0, 32), Color3.fromRGB(160, 50, 60))

upMobBtn.MouseButton1Down:Connect(function() mobUpPressed = true end)
upMobBtn.MouseButton1Up:Connect(function() mobUpPressed = false end)
upMobBtn.MouseLeave:Connect(function() mobUpPressed = false end)

downMobBtn.MouseButton1Down:Connect(function() mobDownPressed = true end)
downMobBtn.MouseButton1Up:Connect(function() mobDownPressed = false end)
downMobBtn.MouseLeave:Connect(function() mobDownPressed = false end)

local sidebar = Instance.new("ScrollingFrame")
sidebar.Size = UDim2.new(0, 120, 1, -55)
sidebar.Position = UDim2.new(0, 10, 0, 45)
sidebar.BackgroundTransparency = 1
sidebar.BorderSizePixel = 0
sidebar.CanvasSize = UDim2.new(0, 0, 0, 360)
sidebar.ScrollBarThickness = 2
sidebar.Parent = frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = sidebar

local function createTabButton(text, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.LayoutOrder = order
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local homeTabBtn = createTabButton(translations["TR"].homeTab, 1)
local soundTabBtn = createTabButton(translations["TR"].soundTab, 2)
local platformTabBtn = createTabButton(translations["TR"].platformTab, 3)
local cheatsTabBtn = createTabButton(translations["TR"].cheatsTab, 4)
local trollTabBtn = createTabButton(translations["TR"].trollTab, 5)
local boredomTabBtn = createTabButton(translations["TR"].boredomTab, 6)
local langTabBtn = createTabButton(translations["TR"].langTab, 7)
local guideTabBtn = createTabButton(translations["TR"].guideTab, 8)

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -145, 1, -55)
contentContainer.Position = UDim2.new(0, 135, 0, 45)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = frame

local function createPage()
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 4
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.Parent = contentContainer
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = p
    return p
end

local homePage = createPage()
local visualsPage = createPage()
local soundPage = createPage()
local platformPage = createPage()
local cheatsPage = createPage()
local trollPage = createPage()
local boredomPage = createPage()
local langPage = createPage()
local guidePage = createPage()

local function createStyledLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 50)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextWrapped = true
    lbl.Text = text
    lbl.Parent = parent
    return lbl
end

local function createStyledHeader(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 30)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(120, 200, 255)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = parent
    return lbl
end

local function createStyledButton(parent, text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 55)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local function createStyledBox(parent, phText)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -10, 0, 38)
    box.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = phText
    box.Text = ""
    box.TextSize = 12
    box.Font = Enum.Font.GothamMedium
    box.ClearTextOnFocus = false
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
    return box
end

local homeWelcomeLabel = createStyledLabel(homePage, translations["TR"].homeWelcome)
local deathHeaderLabel = createStyledHeader(homePage, translations["TR"].deathSectionTitle)
local deathNotifButton = createStyledButton(homePage, translations["TR"].deathNotifOn, Color3.fromRGB(40, 140, 90))

local visualsHeaderLabel = createStyledHeader(visualsPage, translations["TR"].visualsSectionTitle)
local espMainButton = createStyledButton(visualsPage, translations["TR"].espMainOff, Color3.fromRGB(160, 60, 70))
local espBoxButton = createStyledButton(visualsPage, translations["TR"].espBoxOn, Color3.fromRGB(40, 140, 90))
local espNameButton = createStyledButton(visualsPage, translations["TR"].espNameOn, Color3.fromRGB(40, 140, 90))
local espDistButton = createStyledButton(visualsPage, translations["TR"].espDistOn, Color3.fromRGB(40, 140, 90))
local espTracerButton = createStyledButton(visualsPage, translations["TR"].espTracerOff, Color3.fromRGB(160, 60, 70))

local xrayHeaderLabel = createStyledHeader(visualsPage, translations["TR"].xraySectionTitle)
local xrayMainButton = createStyledButton(visualsPage, translations["TR"].xrayMainOff, Color3.fromRGB(160, 60, 70))
local xrayTransparencyBox = createStyledBox(visualsPage, translations["TR"].xraySliderPh)

local musicIdBox = createStyledBox(soundPage, translations["TR"].musicIdPh)
local playMusicButton = createStyledButton(soundPage, translations["TR"].playMusic, Color3.fromRGB(90, 60, 160))
local stopMusicButton = createStyledButton(soundPage, translations["TR"].stopMusic, Color3.fromRGB(160, 60, 90))
local muteGameMusicButton = createStyledButton(soundPage, translations["TR"].muteGame, Color3.fromRGB(140, 90, 40))
local unmuteGameMusicButton = createStyledButton(soundPage, translations["TR"].unmuteGame, Color3.fromRGB(40, 140, 90))

local upButton = createStyledButton(platformPage, translations["TR"].upBtn, Color3.fromRGB(45, 45, 60))
local downButton = createStyledButton(platformPage, translations["TR"].downBtn, Color3.fromRGB(45, 45, 60))
local toggleButton = createStyledButton(platformPage, translations["TR"].platOff, Color3.fromRGB(160, 60, 70))

local speedBox = createStyledBox(cheatsPage, translations["TR"].speedPh)
local noclipButton = createStyledButton(cheatsPage, translations["TR"].noclipOff, Color3.fromRGB(160, 60, 70))
local flyButton = createStyledButton(cheatsPage, translations["TR"].flyOff, Color3.fromRGB(160, 60, 70))
local holdJumpButton = createStyledButton(cheatsPage, translations["TR"].holdJumpOff, Color3.fromRGB(160, 60, 70))

local walkFlingButton = createStyledButton(trollPage, translations["TR"].walkFlingOff, Color3.fromRGB(160, 60, 70))
local sitTrollButton = createStyledButton(trollPage, translations["TR"].sitTrollOff, Color3.fromRGB(160, 60, 70))

local targetFocusHeader = createStyledHeader(trollPage, translations["TR"].targetFocusSectionTitle)
local targetFocusBox = createStyledBox(trollPage, translations["TR"].targetDropdownPh)
local targetFocusButton = createStyledButton(trollPage, translations["TR"].targetFocusBtnOff, Color3.fromRGB(160, 60, 70))

local powerfulTrampolineButton = createStyledButton(boredomPage, translations["TR"].trampolineOff, Color3.fromRGB(160, 60, 70))

local langTrBtn = createStyledButton(langPage, translations["TR"].langTrBtn, Color3.fromRGB(35, 35, 48))
local langEnBtn = createStyledButton(langPage, translations["TR"].langEnBtn, Color3.fromRGB(35, 35, 48))

local guideLabel = createStyledLabel(guidePage, translations["TR"].guideText)
guideLabel.Size = UDim2.new(1, -10, 0, 220)

local function updateLanguage(langCode)
    currentLang = langCode
    local t = translations[currentLang]
    
    titleLabel.Text = t.title
    homeTabBtn.Text = t.homeTab
    soundTabBtn.Text = t.soundTab
    platformTabBtn.Text = t.platformTab
    cheatsTabBtn.Text = t.cheatsTab
    trollTabBtn.Text = t.trollTab
    boredomTabBtn.Text = t.boredomTab
    langTabBtn.Text = t.langTab
    guideTabBtn.Text = t.guideTab
    
    homeWelcomeLabel.Text = t.homeWelcome
    deathHeaderLabel.Text = t.deathSectionTitle
    visualsHeaderLabel.Text = t.visualsSectionTitle
    xrayHeaderLabel.Text = t.xraySectionTitle
    
    musicIdBox.PlaceholderText = t.musicIdPh
    playMusicButton.Text = t.playMusic
    stopMusicButton.Text = t.stopMusic
    muteGameMusicButton.Text = t.muteGame
    unmuteGameMusicButton.Text = t.unmuteGame
    
    upButton.Text = t.upBtn
    downButton.Text = t.downBtn
    toggleButton.Text = isPlatformActive and t.platOn or t.platOff
    
    speedBox.PlaceholderText = t.speedPh
    noclipButton.Text = noclipActive and t.noclipOn or t.noclipOff
    flyButton.Text = flyActive and t.flyOn or t.flyOff
    holdJumpButton.Text = holdJumpActive and t.holdJumpOn or t.holdJumpOff
    walkFlingButton.Text = walkFlingActive and t.walkFlingOn or t.walkFlingOff
    sitTrollButton.Text = isSitTrollActive and t.sitTrollOn or t.sitTrollOff
    deathNotifButton.Text = deathNotificationEnabled and t.deathNotifOn or t.deathNotifOff
    powerfulTrampolineButton.Text = powerfulTrampolineActive and t.trampolineOn or t.trampolineOff
    
    espMainButton.Text = espEnabled and t.espMainOn or t.espMainOff
    espBoxButton.Text = espBoxEnabled and t.espBoxOn or t.espBoxOff
    espNameButton.Text = espNameEnabled and t.espNameOn or t.espNameOff
    espDistButton.Text = espDistanceEnabled and t.espDistOn or t.espDistOff
    espTracerButton.Text = espTracersEnabled and t.espTracerOn or t.espTracerOff
    
    xrayMainButton.Text = xrayEnabled and t.xrayMainOn or t.xrayMainOff
    xrayTransparencyBox.PlaceholderText = t.xraySliderPh
    
    targetFocusHeader.Text = t.targetFocusSectionTitle
    targetFocusBox.PlaceholderText = t.targetDropdownPh
    targetFocusButton.Text = targetFocusActive and t.targetFocusBtnOn or t.targetFocusBtnOff
    
    flyTitle.Text = t.flyTitle
    upMobBtn.Text = t.upMob
    downMobBtn.Text = t.downMob
    
    langTrBtn.Text = t.langTrBtn
    langEnBtn.Text = t.langEnBtn
    guideLabel.Text = t.guideText
end

langTrBtn.MouseButton1Click:Connect(function() updateLanguage("TR") end)
langEnBtn.MouseButton1Click:Connect(function() updateLanguage("EN") end)

local pages = {
    home = homePage,
    visuals = visualsPage,
    sound = soundPage,
    platform = platformPage,
    cheats = cheatsPage,
    troll = trollPage,
    boredom = boredomPage,
    lang = langPage,
    guide = guidePage
}

local buttons = {
    home = homeTabBtn,
    sound = soundTabBtn,
    platform = platformTabBtn,
    cheats = cheatsTabBtn,
    troll = trollTabBtn,
    boredom = boredomTabBtn,
    lang = langTabBtn,
    guide = guideTabBtn
}

local function switchTab(activeTabKey)
    for key, page in pairs(pages) do
        page.Visible = (key == activeTabKey)
    end
    for key, btn in pairs(buttons) do
        if key == activeTabKey then
            btn.BackgroundColor3 = Color3.fromRGB(80, 70, 220)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
            btn.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
    end
    
    topVisualsButton.Visible = (activeTabKey == "home")

    if activeTabKey == "visuals" then
        topVisualsButton.BackgroundColor3 = Color3.fromRGB(80, 70, 220)
        topVisualsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        topVisualsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        topVisualsButton.TextColor3 = Color3.fromRGB(120, 200, 255)
    end
end

homeTabBtn.MouseButton1Click:Connect(function() switchTab("home") end)
topVisualsButton.MouseButton1Click:Connect(function() switchTab("visuals") end)
soundTabBtn.MouseButton1Click:Connect(function() switchTab("sound") end)
platformTabBtn.MouseButton1Click:Connect(function() switchTab("platform") end)
cheatsTabBtn.MouseButton1Click:Connect(function() switchTab("cheats") end)
trollTabBtn.MouseButton1Click:Connect(function() switchTab("troll") end)
boredomTabBtn.MouseButton1Click:Connect(function() switchTab("boredom") end)
langTabBtn.MouseButton1Click:Connect(function() switchTab("lang") end)
guideTabBtn.MouseButton1Click:Connect(function() switchTab("guide") end)

switchTab("home")

local function applyXray()
    originalPartsData = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(player.Character) and obj ~= platform and obj ~= trampolinePart then
            originalPartsData[obj] = obj.Transparency
            obj.Transparency = xrayTransparency
        end
    end
end

local function removeXray()
    for obj, originalTrans in pairs(originalPartsData) do
        if obj and obj.Parent then
            obj.Transparency = originalTrans
        end
    end
    originalPartsData = {}
end

xrayMainButton.MouseButton1Click:Connect(function()
    xrayEnabled = not xrayEnabled
    local t = translations[currentLang]
    if xrayEnabled then
        xrayMainButton.Text = t.xrayMainOn
        xrayMainButton.BackgroundColor3 = Color3.fromRGB(40, 140, 90)
        applyXray()
    else
        xrayMainButton.Text = t.xrayMainOff
        xrayMainButton.BackgroundColor3 = Color3.fromRGB(160, 60, 70)
        removeXray()
    end
end)

xrayTransparencyBox.FocusLost:Connect(function()
    local text = xrayTransparencyBox.Text
    local val = tonumber(text)
    if val then
        xrayTransparency = math.clamp(val, 0, 1)
        if xrayEnabled then
            applyXray()
        end
    else
        xrayTransparencyBox.Text = ""
    end
end)

local function removeEspForPlayer(p)
    if espObjects[p] then
        if espObjects[p].Highlight then espObjects[p].Highlight:Destroy() end
        if espObjects[p].Billboard then espObjects[p].Billboard:Destroy() end
        if espObjects[p].TracerLine then espObjects[p].TracerLine:Remove() end
        espObjects[p] = nil
    end
end

local function setupEspForPlayer(p)
    if p == player then return end
    
    local function createVisuals()
        removeEspForPlayer(p)
        if not espEnabled then return end
        
        local char = p.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(80, 70, 220)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.Enabled = espBoxEnabled
        highlight.Parent = char
        
        local bill = Instance.new("BillboardGui")
        bill.Name = "ESPBillboard"
        bill.Adornee = root
        bill.Size = UDim2.new(0, 200, 0, 50)
        bill.StudsOffset = Vector3.new(0, 3, 0)
        bill.AlwaysOnTop = true
        bill.Parent = root
        
        local textLbl = Instance.new("TextLabel")
        textLbl.Size = UDim2.new(1, 0, 1, 0)
        textLbl.BackgroundTransparency = 1
        textLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLbl.TextSize = 13
        textLbl.Font = Enum.Font.GothamBold
        textLbl.TextStrokeTransparency = 0.5
        textLbl.Parent = bill
        
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Color = Color3.fromRGB(80, 70, 220)
        tracer.Thickness = 1.5
        tracer.Transparency = 0.7
        
        espObjects[p] = {Highlight = highlight, Billboard = bill, Text = textLbl, TracerLine = tracer}
    end
    
    p.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        createVisuals()
    end)
    
    if p.Character then
        createVisuals()
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    setupEspForPlayer(p)
end

Players.PlayerAdded:Connect(setupEspForPlayer)
Players.PlayerRemoving:Connect(removeEspForPlayer)

RunService.RenderStepped:Connect(function()
    for p, data in pairs(espObjects) do
        if p and p.Character and espEnabled then
            local char = p.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if root and hum then
                if data.Highlight then
                    data.Highlight.Enabled = espBoxEnabled
                end
                
                local txt = ""
                if espNameEnabled then txt = p.Name end
                if espDistanceEnabled and humanoidRootPart then
                    local dist = math.floor((root.Position - humanoidRootPart.Position).Magnitude)
                    txt = txt .. " [" .. dist .. "m]"
                end
                if data.Text then
                    data.Text.Text = txt
                    data.Text.Visible = (espNameEnabled or espDistanceEnabled)
                end
                
                if data.TracerLine then
                    if espTracersEnabled then
                        local vector, onScreen = Camera:WorldToViewportPoint(root.Position)
                        if onScreen then
                            data.TracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            data.TracerLine.To = Vector2.new(vector.X, vector.Y)
                            data.TracerLine.Visible = true
                        else
                            data.TracerLine.Visible = false
                        end
                    else
                        data.TracerLine.Visible = false
                    end
                end
            else
                if data.TracerLine then data.TracerLine.Visible = false end
            end
        else
            if data and data.TracerLine then data.TracerLine.Visible = false end
        end
    end
end)

espMainButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    local t = translations[currentLang]
    if espEnabled then
        espMainButton.Text = t.espMainOn
        espMainButton.BackgroundColor3 = Color3.fromRGB(40, 140, 90)
        for _, p in ipairs(Players:GetPlayers()) do
            setupEspForPlayer(p)
        end
    else
        espMainButton.Text = t.espMainOff
        espMainButton.BackgroundColor3 = Color3.fromRGB(160, 60, 70)
        for p, _ in pairs(espObjects) do
            removeEspForPlayer(p)
        end
    end
end)

espBoxButton.MouseButton1Click:Connect(function()
    espBoxEnabled = not espBoxEnabled
    local t = translations[currentLang]
    espBoxButton.Text = espBoxEnabled and t.espBoxOn or t.espBoxOff
    espBoxButton.BackgroundColor3 = espBoxEnabled and Color3.fromRGB(40, 140, 90) or Color3.fromRGB(160, 60, 70)
end)

espNameButton.MouseButton1Click:Connect(function()
    espNameEnabled = not espNameEnabled
    local t = translations[currentLang]
    espNameButton.Text = espNameEnabled and t.espNameOn or t.espNameOff
    espNameButton.BackgroundColor3 = espNameEnabled and Color3.fromRGB(40, 140, 90) or Color3.fromRGB(160, 60, 70)
end)

espDistButton.MouseButton1Click:Connect(function()
    espDistanceEnabled = not espDistanceEnabled
    local t = translations[currentLang]
    espDistButton.Text = espDistanceEnabled and t.espDistOn or t.espDistOff
    espDistButton.BackgroundColor3 = espDistanceEnabled and Color3.fromRGB(40, 140, 90) or Color3.fromRGB(160, 60, 70)
end)

espTracerButton.MouseButton1Click:Connect(function()
    espTracersEnabled = not espTracersEnabled
    local t = translations[currentLang]
    espTracerButton.Text = espTracersEnabled and t.espTracerOn or t.espTracerOff
    espTracerButton.BackgroundColor3 = espTracersEnabled and Color3.fromRGB(40, 140, 90) or Color3.fromRGB(160, 60, 70)
end)

playMusicButton.MouseButton1Click:Connect(function()
    local text = musicIdBox.Text
    local soundIdNum = tonumber(text)
    if soundIdNum then
        backgroundMusic.SoundId = "rbxassetid://" .. tostring(soundIdNum)
        backgroundMusic:Play()
    end
end)

stopMusicButton.MouseButton1Click:Connect(function()
    backgroundMusic:Stop()
end)

muteGameMusicButton.MouseButton1Click:Connect(function()
    originalVolumes = {}
    isMuted = true
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("Sound") and obj ~= backgroundMusic then
            originalVolumes[obj] = (obj.Volume > 0) and obj.Volume or 0.5
            obj.Volume = 0
        end
    end
end)

unmuteGameMusicButton.MouseButton1Click:Connect(function()
    if isMuted then
        for obj, savedVol in pairs(originalVolumes) do
            if obj and obj.Parent then obj.Volume = savedVol end
        end
        isMuted = false
    end
end)

local function setPlatformState(state)
    isPlatformActive = state
    local t = translations[currentLang]
    if isPlatformActive then
        toggleButton.Text = t.platOn
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 140, 90)
        if humanoidRootPart then lockedHeight = humanoidRootPart.Position.Y - 3 end
        createPlatform()
    else
        toggleButton.Text = t.platOff
        toggleButton.BackgroundColor3 = Color3.fromRGB(160, 60, 70)
        if platform then platform:Destroy(); platform = nil end
    end
end

local function setNoclipState(state)
    noclipActive = state
    local t = translations[currentLang]
    if noclipActive then
        noclipButton.Text = t.noclipOn
        noclipButton.BackgroundColor3 = Color3.fromRGB(40, 140, 90)
        noclipConnection = RunService.Stepped:Connect(function()
            if not character or not humanoidRootPart or isPlatformActive then return end
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    else
        noclipButton.Text = t.noclipOff
        noclipButton.BackgroundColor3 = Color3.fromRGB(160, 60, 70)
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        if character and not walkFlingActive and not targetFocusActive then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

local function setTrampolineState(state)
    powerfulTrampolineActive = state
    local t = translations[currentLang]
    if powerfulTrampolineActive then
        powerfulTrampolineButton.Text = t.trampolineOn
        powerfulTrampolineButton.BackgroundColor3 = Color3.fromRGB(40, 140, 90)
        
        if humanoidRootPart then
            trampolinePart = Instance.new("Part")
            trampolinePart.Size = Vector3.new(6, 1, 6)
            trampolinePart.Anchored = true
            trampolinePart.CanCollide = true
            trampolinePart.Material = Enum.Material.Neon
            trampolinePart.Color = Color3.fromRGB(20, 20, 20)
            
            local lookVector = humanoidRootPart.CFrame.LookVector
            local spawnPos = humanoidRootPart.Position + (lookVector * 5) - Vector3.new(0, 2.5, 0)
            trampolinePart.Position = spawnPos
            trampolinePart.Parent = workspace
            
            trampolineConnection = trampolinePart.Touched:Connect(function(hit)
                local hitChar = hit.Parent
                local hitHum = hitChar:FindFirstChildOfClass("Humanoid")
                local hitRoot = hitChar:FindFirstChild("HumanoidRootPart")
                if hitHum and hitRoot then
                    hitRoot.AssemblyLinearVelocity = Vector3.new(0, 350, 0)
                end
            end)
        end
    else
        powerfulTrampolineButton.Text = t.trampolineOff
        powerfulTrampolineButton.BackgroundColor3 = Color3.fromRGB(160, 60, 70)
        if trampolineConnection then trampolineConnection:Disconnect(); trampolineConnection = nil end
        if trampolinePart then trampolinePart:Destroy(); trampolinePart = nil end
    end
end

powerfulTrampolineButton.MouseButton1Click:Connect(function()
    if isSpawningLocked then return end
    local targetState = not powerfulTrampolineActive
    if targetState then
        if isPlatformActive then setPlatformState(false) end
        if noclipActive then setNoclipState(false) end
    end
    setTrampolineState(targetState)
end)

noclipButton.MouseButton1Click:Connect(function()
    if isSpawningLocked then return end
    local targetState = not noclipActive
    if targetState then
        if powerfulTrampolineActive then setTrampolineState(false) end
        if isPlatformActive then setPlatformState(false) end
    end
    setNoclipState(targetState)
end)

toggleButton.MouseButton1Click:Connect(function()
    if isSpawningLocked then return end
    local targetState = not isPlatformActive
    if targetState then
        if powerfulTrampolineActive then setTrampolineState(false) end
        if isSitTrollActive then
            isSitTrollActive = false
            sitTrollButton.Text = translations[currentLang].sitTrollOff
            sitTrollButton.BackgroundColor3 = Color3.fromRGB(160, 60, 70)
        end
        if walkFlingActive then walkFlingButton.MouseButton1Click:Fire() end
        if targetFocusActive then targetFocusButton.MouseButton1Click:Fire() end
        if flyActive then flyButton.MouseButton1Click:Fire() end
        if holdJumpActive then holdJumpButton.MouseButton1Click:Fire() end
        if noclipActive then setNoclipState(false) end
    end
    setPlatformState(targetState)
end)

walkFlingButton.MouseButton1Click:Connect(function()
    if isSpawningLocked then return end
    local t = translations[currentLang]
    
    walkFlingActive = not walkFlingActive
    if walkFlingActive then
        if targetFocusActive then targetFocusButton.MouseButton1Click:Fire() end
        setPlatformState(false)
        setTrampolineState(false)
        walkFlingButton.Text = t.walkFlingOn
        walkFlingButton.BackgroundColor3 = Color3.fromRGB(40, 140, 90)
        
        currentTargetIndex = 1
        targetFlingTimer = tick()
        spinAngle = 0
        
        walkFlingConnection = RunService.RenderStepped:Connect(function()
            if not character or not humanoidRootPart or not walkFlingActive then return end
            
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            
            spinAngle = spinAngle + 150
            
            local playersList = {}
            local otherPlayerSet = Players:GetPlayers()
            for _, otherPlayer in ipairs(otherPlayerSet) do
                if otherPlayer ~= player and otherPlayer.Character then
                    local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if otherRoot then
                        table.insert(playersList, otherRoot)
                    end
                end
            end
            
            if #playersList > 0 then
                if currentTargetIndex > #playersList then
                    currentTargetIndex = 1
                end
                
                local targetRoot = playersList[currentTargetIndex]
                if targetRoot and targetRoot.Parent then
                    humanoidRootPart.CFrame = targetRoot.CFrame * CFrame.Angles(0, math.rad(spinAngle), 0) * CFrame.new(0, 0.2, 0)
                    humanoidRootPart.AssemblyLinearVelocity = Vector3.new(math.random(-400, 400), 5000, math.random(-400, 400))
                    
                    if tick() - targetFlingTimer > 0.4 then
                        currentTargetIndex = currentTargetIndex + 1
                        targetFlingTimer = tick()
                    end
                else
                    currentTargetIndex = currentTargetIndex + 1
                end
            end
        end)
    else
        walkFlingButton.Text = t.walkFlingOff
        walkFlingButton.BackgroundColor3 = Color3.fromRGB(160, 60, 70)
        if walkFlingConnection then walkFlingConnection:Disconnect(); walkFlingConnection = nil end
        
        if character and not noclipActive then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)

local targetFocusConnection = nil

targetFocusBox.FocusLost:Connect(function()
    local text = targetFocusBox.Text:lower()
    if text == "" then
        focusedTargetPlayer = nil
        showCustomNotification("🎯 Hedef", "Hedef temizlendi!")
        return
    end
    
    local found = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and (p.Name:lower():sub(1, #text) == text or p.DisplayName:lower():sub(1, #text) == text) then
            found = p
            break
        end
    end
    
    if found then
        focusedTargetPlayer = found
        targetFocusBox.Text = found.Name
        showCustomNotification("🎯 Hedef Seçildi", "Odaklanılan Oyuncu: " .. found.Name)
    else
        showCustomNotification("⚠️ Uyarı", "Böyle bir oyuncu bulunamadı!")
        focusedTargetPlayer = nil
    end
end)

targetFocusButton.MouseButton1Click:Connect(function()
    if isSpawningLocked then return end
    local t = translations[currentLang]
    
    targetFocusActive = not targetFocusActive
    if targetFocusActive then
        if not focusedTargetPlayer then
            showCustomNotification("⚠️ Uyarı", "Önce bir hedef oyuncu adı yazıp Enter'a basın!")
            targetFocusActive = false
            return
        end
        
        if walkFlingActive then walkFlingButton.MouseButton1Click:Fire() end
        setPlatformState(false)
        setTrampolineState(false)
        
        targetFocusButton.Text = t.targetFocusBtnOn
        targetFocusButton.BackgroundColor3 = Color3.fromRGB(40, 140, 90)
        
        targetFocusConnection = RunService.RenderStepped:Connect(function()
            if not character or not humanoidRootPart or not targetFocusActive then return end
            if not focusedTargetPlayer or not focusedTargetPlayer.Character then return end
            
            local targetRoot = focusedTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                humanoidRootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
                humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        targetFocusButton.Text = t.targetFocusBtnOff
        targetFocusButton.BackgroundColor3 = Color3.fromRGB(160, 60, 70)
        if targetFocusConnection then targetFocusConnection:Disconnect(); targetFocusConnection = nil end
        
        if character and not noclipActive then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)

local function sitPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Sit = true end
end

local function setupCharacterTouch(char)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not root then return end
    root.Touched:Connect(function(hit)
        if not isSitTrollActive then return end
        local hitChar = hit.Parent
        local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
        if hitPlayer and hitPlayer ~= player then sitPlayer(hitPlayer) end
    end)
end

if character then setupCharacterTouch(character) end
player.CharacterAdded:Connect(setupCharacterTouch)

sitTrollButton.MouseButton1Click:Connect(function()
    if isSpawningLocked then return end
    local t = translations[currentLang]
    if not isSitTrollActive then
        setPlatformState(false)
        setTrampolineState(false)
    end
    isSitTrollActive = not isSitTrollActive
    sitTrollButton.Text = isSitTrollActive and t.sitTrollOn or t.sitTrollOff
    sitTrollButton.BackgroundColor3 = isSitTrollActive and Color3.fromRGB(40, 140, 90) or Color3.fromRGB(160, 60, 70)
end)

deathNotifButton.MouseButton1Click:Connect(function()
    local t = translations[currentLang]
    deathNotificationEnabled = not deathNotificationEnabled
    deathNotifButton.Text = deathNotificationEnabled and t.deathNotifOn or t.deathNotifOff
    deathNotifButton.BackgroundColor3 = deathNotificationEnabled and Color3.fromRGB(40, 140, 90) or Color3.fromRGB(160, 60, 70)
end)

flyButton.MouseButton1Click:Connect(function()
    if isSpawningLocked then return end
    local t = translations[currentLang]
    if not flyActive then
        setPlatformState(false)
        setTrampolineState(false)
    end
    flyActive = not flyActive
    if flyActive then
        flyButton.Text = t.flyOn
        flyButton.BackgroundColor3 = Color3.fromRGB(40, 140, 90)
        flyControlGui.Enabled = true
        bg = Instance.new("BodyGyro")
        bg.P = 9e4
        bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
        bg.CFrame = humanoidRootPart.CFrame
        bg.Parent = humanoidRootPart
        
        bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
        bv.Parent = humanoidRootPart
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not character or not humanoidRootPart or isPlatformActive or not flyActive then return end
            humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
            local cam = workspace.CurrentCamera
            local moveDir = humanoid.MoveDirection
            local finalVelocity = Vector3.new(0, 0, 0)
            if moveDir.Magnitude > 0 then finalVelocity = moveDir * flySpeed end
            if mobUpPressed then finalVelocity = finalVelocity + Vector3.new(0, flySpeed, 0) end
            if mobDownPressed then finalVelocity = finalVelocity - Vector3.new(0, flySpeed, 0) end
            bv.Velocity = finalVelocity
            bg.CFrame = cam.CFrame
        end)
    else
        flyButton.Text = t.flyOff
        flyButton.BackgroundColor3 = Color3.fromRGB(160, 60, 70)
        flyControlGui.Enabled = false
        mobUpPressed = false
        mobDownPressed = false
        if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
        if bg then bg:Destroy(); bg = nil end
        if bv then bv:Destroy(); bv = nil end
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end)

holdJumpButton.MouseButton1Click:Connect(function()
    if isSpawningLocked then return end
    local t = translations[currentLang]
    if not holdJumpActive then
        setPlatformState(false)
        setTrampolineState(false)
    end
    holdJumpActive = not holdJumpActive
    holdJumpButton.Text = holdJumpActive and t.holdJumpOn or t.holdJumpOff
    holdJumpButton.BackgroundColor3 = holdJumpActive and Color3.fromRGB(40, 140, 90) or Color3.fromRGB(160, 60, 70)
end)

local function setupJumpButtonHook()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    task.spawn(function()
        task.wait(2.5)
        local touchGui = playerGui:FindFirstChild("TouchGui")
        if touchGui then
            local touchControlFrame = touchGui:FindFirstChild("TouchControlFrame")
            if touchControlFrame then
                local jumpButtonObj = touchControlFrame:FindFirstChild("JumpButton")
                if jumpButtonObj and jumpButtonObj:IsA("ImageButton") then
                    jumpButtonObj.MouseButton1Down:Connect(function() if holdJumpActive then isHoldingJump = true end end)
                    jumpButtonObj.MouseButton1Up:Connect(function() if holdJumpActive then isHoldingJump = false end end)
                    jumpButtonObj.MouseLeave:Connect(function() if holdJumpActive then isHoldingJump = false end end)
                end
            end
        end
    end)
end
setupJumpButtonHook()

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Jump then
        if holdJumpActive then isHoldingJump = true end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Jump then
        isHoldingJump = false
    end
end)

RunService.RenderStepped:Connect(function()
    if holdJumpActive and humanoidRootPart and not isPlatformActive then
        if isHoldingJump or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            humanoidRootPart.AssemblyLinearVelocity = Vector3.new(humanoidRootPart.AssemblyLinearVelocity.X, 40, humanoidRootPart.AssemblyLinearVelocity.Z)
        end
    end
end)

-- 👁️ GÖZ BUTONU (ÇİFT TIKLAMA MANTIĞI EKLENDİ) & MINIMIZE
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = true
    frame.Visible = false
    eyeControlGui.Enabled = true
end)

local lastClickTime = 0
eyeButton.MouseButton1Click:Connect(function()
    local currentTime = tick()
    if currentTime - lastClickTime <= 0.4 then -- 0.4 saniye içinde 2 kez tıklanırsa açılır
        isMinimized = false
        frame.Visible = true
        eyeControlGui.Enabled = false
        lastClickTime = 0
    else
        lastClickTime = currentTime
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    isSpawningLocked = true
    humanoid.WalkSpeed = savedWalkSpeed
    humanoid.JumpPower = 50
    humanoid.UseJumpPower = true
    if isPlatformActive then
        lockedHeight = humanoidRootPart.Position.Y - 3
        createPlatform()
    end
    setupJumpButtonHook()
    task.spawn(function()
        task.wait(2.0)
        isSpawningLocked = false
    end)
end)

speedBox.FocusLost:Connect(function()
    if isSpawningLocked then return end
    local text = speedBox.Text
    if text == "" or tonumber(text) == nil then
        savedWalkSpeed = 16
        flySpeed = 16
        speedBox.Text = ""
    else
        local newSpeed = tonumber(text)
        savedWalkSpeed = newSpeed
        flySpeed = newSpeed
    end
    if humanoid then humanoid.WalkSpeed = savedWalkSpeed end
end)

local movingUp = false
local movingDown = false

upButton.MouseButton1Down:Connect(function() if isPlatformActive and not isSpawningLocked then movingUp = true end end)
upButton.MouseButton1Up:Connect(function() movingUp = false end)
upButton.MouseLeave:Connect(function() movingUp = false end)

downButton.MouseButton1Down:Connect(function() if isPlatformActive and not isSpawningLocked then movingDown = true end end)
downButton.MouseButton1Up:Connect(function() movingDown = false end)
downButton.MouseLeave:Connect(function() movingDown = false end)

local isRunning = true

closeTopButton.MouseButton1Click:Connect(function()
    isRunning = false
    if noclipConnection then noclipConnection:Disconnect() end
    if flyConnection then flyConnection:Disconnect() end
    if walkFlingConnection then walkFlingConnection:Disconnect() end
    if targetFocusConnection then targetFocusConnection:Disconnect() end
    if trampolineConnection then trampolineConnection:Disconnect() end
    for _, conn in pairs(deathConnections) do if conn then conn:Disconnect() end end
    for p, _ in pairs(espObjects) do removeEspForPlayer(p) end
    removeXray()
    flyActive = false
    holdJumpActive = false
    walkFlingActive = false
    targetFocusActive = false
    isSitTrollActive = false
    powerfulTrampolineActive = false
    espEnabled = false
    xrayEnabled = false
    isHoldingJump = false
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
    if trampolinePart then trampolinePart:Destroy() end
    backgroundMusic:Stop()
    backgroundMusic:Destroy()
    if isMuted then
        for obj, savedVol in pairs(originalVolumes) do
            if obj and obj.Parent then obj.Volume = savedVol end
        end
    end
    if humanoid then 
        humanoid.JumpPower = 50 
        humanoid.WalkSpeed = 16 
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    if platform then platform:Destroy() end
    flyControlGui:Destroy()
    eyeControlGui:Destroy()
    screenGui:Destroy()
end)

RunService.RenderStepped:Connect(function(dt)
    if not isRunning then return end
    if isSpawningLocked then
        if humanoidRootPart and platform then
            lockedHeight = humanoidRootPart.Position.Y - 3
            platform.CFrame = CFrame.new(humanoidRootPart.Position.X, lockedHeight, humanoidRootPart.Position.Z)
        end
        return
    end
    
    if humanoid and humanoid.WalkSpeed ~= savedWalkSpeed then 
        humanoid.WalkSpeed = savedWalkSpeed 
    end

    if not isPlatformActive then return end
    
    if humanoidRootPart and platform then
        local currentPos = humanoidRootPart.Position
        local charY = currentPos.Y
        local platPos = platform.Position
        
        if (Vector3.new(platPos.X, 0, platPos.Z) - Vector3.new(currentPos.X, 0, currentPos.Z)).Magnitude >= 30 then
            lockedHeight = charY - 3
            local lookVector = humanoidRootPart.CFrame.LookVector
            local newPlatformPos = currentPos + (lookVector * 5) - Vector3.new(0, 3, 0)
            platform.CFrame = CFrame.new(newPlatformPos.X, lockedHeight, newPlatformPos.Z)
            return
        end
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {character, platform}
        if movingUp then
            if noclipActive then
                lockedHeight = lockedHeight + (25 * dt)
            else
                local headPos = currentPos + Vector3.new(0, 2.5, 0)
                if not workspace:Raycast(headPos, Vector3.new(0, 0.8, 0), raycastParams) then
                    lockedHeight = lockedHeight + (25 * dt)
                end
            end
        elseif movingDown then
            local groundRay = workspace:Raycast(currentPos, Vector3.new(0, -50, 0), raycastParams)
            if groundRay then
                local groundLimit = charY - 6
                if lockedHeight > groundLimit then
                    lockedHeight = lockedHeight - (25 * dt)
                    if lockedHeight < groundLimit then lockedHeight = groundLimit end
                end
            else
                lockedHeight = lockedHeight - (25 * dt)
            end
        end
        
        platform.CFrame = CFrame.new(currentPos.X, lockedHeight, currentPos.Z)
    end
end)
