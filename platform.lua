-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

humanoid.JumpPower = 50
humanoid.UseJumpPower = true

local platform = nil
local isPlatformActive = true
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

local currentTargetIndex = 1
local targetFlingTimer = 0
local spinAngle = 0

local originalVolumes = {}
local isMuted = false

-- OYUNCU ÖLÜMÜ BİLDİRİM SİSTEMİ (AÇ/KAPA ÖZELLİKLİ)
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
end)

local currentLang = "TR"
local translations = {
    ["TR"] = {
        title = "⚡ DÖNEN TARGET FLING ⚡",
        homeTab = "Ev 🏠", soundTab = "Ses 🎵", platformTab = "Platform 🧱", cheatsTab = "Hileler ⚡", trollTab = "Troll 🌀", langTab = "Dil 🌍", guideTab = "Kılavuz 📖",
        closeBtn = "Menüyü Kapat ❌",
        homeWelcome = "⚡ Menüye Hoş Geldin!\n\nÖlüm bildirimlerini aşağıdaki butondan açıp kapatabilirsin.",
        musicIdPh = "Müzik ID Gir", playMusic = "Müziği Oynat 🎵", stopMusic = "Müziği Kapat ⏹️", muteGame = "Oyun Sesini Sustur 🔇", unmuteGame = "Oyun Sesini Aç 🔊",
        upBtn = "+ (Yukarı) 🔼", downBtn = "- (Aşağı) 🔽", platOn = "Platform: AÇIK", platOff = "Platform: KAPALI",
        speedPh = "Hız Yaz (örn: 50)", noclipOn = "Noclip: AÇIK 👻", noclipOff = "Noclip: KAPALI", flyOn = "Uçma: AÇIK ✈️", flyOff = "Uçma: KAPALI ✈️", holdJumpOn = "Zıplama Tuşuyla Yüksel: AÇIK 🚀", holdJumpOff = "Zıplama Tuşuyla Yüksel: KAPALI 🚀",
        trollTitle = "🌀 TROLL ÖZELLİKLERİ", walkFlingOn = "Target Fling (Dönen): AÇIK 🎯", walkFlingOff = "Target Fling (Dönen): KAPALI 🎯",
        deathNotifOn = "Ölüm Bildirimi: AÇIK 🔔", deathNotifOff = "Ölüm Bildirimi: KAPALI 🔕",
        flyTitle = "✈️ UÇMA YÜKSEKLİK", upMob = "Yüksel 🔼", downMob = "Alçal 🔽",
        langTrBtn = "🇹🇷 Türkçe", langEnBtn = "🇬🇧 English",
        guideText = [[📜 KILAVUZ & BİLGİLER:

🎯 Target Fling (Dönen Mod):
Karakterini yüksek hızda döndürerek hedeflerin içine girer ve fizik motorunu tetikleyip onları uzaya uçurur!
*(Ölüm bildirimlerini Ev sekmesinden açıp kapatabilirsin!)]]
    },
    ["EN"] = {
        title = "⚡ SPINNING TARGET FLING ⚡",
        homeTab = "Home 🏠", soundTab = "Sound 🎵", platformTab = "Platform 🧱", cheatsTab = "Cheats ⚡", trollTab = "Troll 🌀", langTab = "Lang 🌍", guideTab = "Guide 📖",
        closeBtn = "Close Menu ❌",
        homeWelcome = "⚡ Welcome to the Menu!\n\nYou can toggle death notifications using the button below.",
        musicIdPh = "Enter Music ID", playMusic = "Play Music 🎵", stopMusic = "Stop Music ⏹️", muteGame = "Mute Game Audio 🔇", unmuteGame = "Unmute Game Audio 🔊",
        upBtn = "+ (Up) 🔼", downBtn = "- (Down) 🔽", platOn = "Platform: ON", platOff = "Platform: OFF",
        speedPh = "Enter Speed (e.g: 50)", noclipOn = "Noclip: ON 👻", noclipOff = "Noclip: OFF", flyOn = "Fly: ON ✈️", flyOff = "Fly: OFF ✈️", holdJumpOn = "Hold Jump: ON 🚀", holdJumpOff = "Hold Jump: OFF 🚀",
        trollTitle = "🌀 TROLL FEATURES", walkFlingOn = "Target Fling (Spinning): ON 🎯", walkFlingOff = "Target Fling (Spinning): OFF 🎯",
        deathNotifOn = "Death Notification: ON 🔔", deathNotifOff = "Death Notification: OFF 🔕",
        flyTitle = "✈️ FLY HEIGHT", upMob = "Up 🔼", downMob = "Down 🔽",
        langTrBtn = "🇹🇷 Turkish", langEnBtn = "🇬🇧 English",
        guideText = [[📜 GUIDE & INFO:

🎯 Target Fling (Spinning Mode):
Spins your character at high speed into targets, triggering the physics engine to fling them away!
*(You can toggle death notifications from the Home tab!)]]
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
    createPlatform()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CategorizedMenuGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 225, 0, 370)
frame.Position = UDim2.new(0, 20, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 9.5
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = translations["TR"].title
titleLabel.Parent = frame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(1, -30, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 16
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.Text = "-"
minimizeButton.Parent = frame
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 4)

local eyeButton = Instance.new("TextButton")
eyeButton.Size = UDim2.new(0, 50, 0, 50)
eyeButton.Position = UDim2.new(0.5, -25, 0.5, -25)
eyeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
eyeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
eyeButton.TextSize = 24
eyeButton.Font = Enum.Font.SourceSansBold
eyeButton.Text = "👁️"
eyeButton.Visible = false
eyeButton.Parent = frame
Instance.new("UICorner", eyeButton).CornerRadius = UDim.new(0, 25)

local flyControlGui = Instance.new("ScreenGui")
flyControlGui.Name = "FlyControlGUI"
flyControlGui.ResetOnSpawn = false
flyControlGui.Enabled = false
flyControlGui.Parent = player:WaitForChild("PlayerGui")

local flyFrame = Instance.new("Frame")
flyFrame.Size = UDim2.new(0, 130, 0, 68)
flyFrame.Position = UDim2.new(1, -150, 0.5, -34)
flyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
flyFrame.BorderSizePixel = 0
flyFrame.Active = true
flyFrame.Draggable = true
flyFrame.Parent = flyControlGui
Instance.new("UICorner", flyFrame).CornerRadius = UDim.new(0, 8)

local flyTitle = Instance.new("TextLabel")
flyTitle.Size = UDim2.new(1, 0, 0, 22)
flyTitle.BackgroundTransparency = 1
flyTitle.TextColor3 = Color3.fromRGB(0, 255, 128)
flyTitle.TextSize = 11
flyTitle.Font = Enum.Font.SourceSansBold
flyTitle.Text = translations["TR"].flyTitle
flyTitle.Parent = flyFrame

local function createMobBtn(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 55, 0, 32)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = text
    btn.Parent = flyFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local upMobBtn = createMobBtn(translations["TR"].upMob, UDim2.new(0, 6, 0, 28), Color3.fromRGB(40, 120, 80))
local downMobBtn = createMobBtn(translations["TR"].downMob, UDim2.new(0, 68, 0, 28), Color3.fromRGB(120, 40, 40))

upMobBtn.MouseButton1Down:Connect(function() mobUpPressed = true end)
upMobBtn.MouseButton1Up:Connect(function() mobUpPressed = false end)
upMobBtn.MouseLeave:Connect(function() mobUpPressed = false end)

downMobBtn.MouseButton1Down:Connect(function() mobDownPressed = true end)
downMobBtn.MouseButton1Up:Connect(function() mobDownPressed = false end)
downMobBtn.MouseLeave:Connect(function() mobDownPressed = false end)

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -10, 0, 30)
tabContainer.Position = UDim2.new(0, 5, 0, 38)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

local function createTabButton(text, xPos, width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(width, 0, 1, 0)
    btn.Position = UDim2.new(xPos, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 7.0
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = text
    btn.Parent = tabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

local homeTabBtn = createTabButton(translations["TR"].homeTab, 0, 0.135)
local soundTabBtn = createTabButton(translations["TR"].soundTab, 0.140, 0.135)
local platformTabBtn = createTabButton(translations["TR"].platformTab, 0.280, 0.145)
local cheatsTabBtn = createTabButton(translations["TR"].cheatsTab, 0.430, 0.140)
local trollTabBtn = createTabButton(translations["TR"].trollTab, 0.575, 0.135)
local langTabBtn = createTabButton(translations["TR"].langTab, 0.715, 0.135)
local guideTabBtn = createTabButton(translations["TR"].guideTab, 0.855, 0.140)

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -10, 1, -115)
scrollingFrame.Position = UDim2.new(0, 5, 0, 75)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.Parent = frame

local homePage = Instance.new("Frame")
homePage.Size = UDim2.new(1, 0, 0, 150)
homePage.BackgroundTransparency = 1
homePage.Visible = true
homePage.Parent = scrollingFrame

local homeWelcomeLabel = Instance.new("TextLabel")
homeWelcomeLabel.Size = UDim2.new(1, -5, 0, 50)
homeWelcomeLabel.Position = UDim2.new(0, 0, 0, 5)
homeWelcomeLabel.BackgroundTransparency = 1
homeWelcomeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
homeWelcomeLabel.TextSize = 10
homeWelcomeLabel.Font = Enum.Font.SourceSansBold
homeWelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
homeWelcomeLabel.TextYAlignment = Enum.TextYAlignment.Top
homeWelcomeLabel.TextWrapped = true
homeWelcomeLabel.Text = translations["TR"].homeWelcome
homeWelcomeLabel.Parent = homePage

local deathNotifButton = Instance.new("TextButton")
deathNotifButton.Size = UDim2.new(1, -5, 0, 38)
deathNotifButton.Position = UDim2.new(0, 0, 0, 60)
deathNotifButton.BackgroundColor3 = Color3.fromRGB(50, 140, 50)
deathNotifButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deathNotifButton.TextSize = 10
deathNotifButton.Font = Enum.Font.SourceSansBold
deathNotifButton.Text = translations["TR"].deathNotifOn
deathNotifButton.Parent = homePage
Instance.new("UICorner", deathNotifButton).CornerRadius = UDim.new(0, 6)

local soundPage = Instance.new("Frame")
soundPage.Size = UDim2.new(1, 0, 0, 190)
soundPage.BackgroundTransparency = 1
soundPage.Visible = false
soundPage.Parent = scrollingFrame

local platformPage = Instance.new("Frame")
platformPage.Size = UDim2.new(1, 0, 0, 130)
platformPage.BackgroundTransparency = 1
platformPage.Visible = false
platformPage.Parent = scrollingFrame

local cheatsPage = Instance.new("Frame")
cheatsPage.Size = UDim2.new(1, 0, 0, 170)
cheatsPage.BackgroundTransparency = 1
cheatsPage.Visible = false
cheatsPage.Parent = scrollingFrame

local trollPage = Instance.new("Frame")
trollPage.Size = UDim2.new(1, 0, 0, 70)
trollPage.BackgroundTransparency = 1
trollPage.Visible = false
trollPage.Parent = scrollingFrame

local walkFlingButton = Instance.new("TextButton")
walkFlingButton.Size = UDim2.new(1, -5, 0, 38)
walkFlingButton.Position = UDim2.new(0, 0, 0, 5)
walkFlingButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
walkFlingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
walkFlingButton.TextSize = 10
walkFlingButton.Font = Enum.Font.SourceSansBold
walkFlingButton.Text = translations["TR"].walkFlingOff
walkFlingButton.Parent = trollPage
Instance.new("UICorner", walkFlingButton).CornerRadius = UDim.new(0, 6)

local langPage = Instance.new("Frame")
langPage.Size = UDim2.new(1, 0, 1, 0)
langPage.BackgroundTransparency = 1
langPage.Visible = false
langPage.Parent = scrollingFrame

local langTrBtn = Instance.new("TextButton")
langTrBtn.Size = UDim2.new(1, -5, 0, 40)
langTrBtn.Position = UDim2.new(0, 0, 0, 10)
langTrBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
langTrBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
langTrBtn.TextSize = 13
langTrBtn.Font = Enum.Font.SourceSansBold
langTrBtn.Text = translations["TR"].langTrBtn
langTrBtn.Parent = langPage
Instance.new("UICorner", langTrBtn).CornerRadius = UDim.new(0, 6)

local langEnBtn = Instance.new("TextButton")
langEnBtn.Size = UDim2.new(1, -5, 0, 40)
langEnBtn.Position = UDim2.new(0, 0, 0, 60)
langEnBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
langEnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
langEnBtn.TextSize = 13
langEnBtn.Font = Enum.Font.SourceSansBold
langEnBtn.Text = translations["TR"].langEnBtn
langEnBtn.Parent = langPage
Instance.new("UICorner", langEnBtn).CornerRadius = UDim.new(0, 6)

local guidePage = Instance.new("Frame")
guidePage.Size = UDim2.new(1, 0, 1, 0)
guidePage.BackgroundTransparency = 1
guidePage.Visible = false
guidePage.Parent = scrollingFrame

local guideLabel = Instance.new("TextLabel")
guideLabel.Size = UDim2.new(1, -5, 1, 0)
guideLabel.Position = UDim2.new(0, 0, 0, 5)
guideLabel.BackgroundTransparency = 1
guideLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
guideLabel.TextSize = 10
guideLabel.Font = Enum.Font.SourceSans
guideLabel.TextXAlignment = Enum.TextXAlignment.Left
guideLabel.TextYAlignment = Enum.TextYAlignment.Top
guideLabel.TextWrapped = true
guideLabel.Text = translations["TR"].guideText
guideLabel.Parent = guidePage

local musicIdBox = Instance.new("TextBox")
musicIdBox.Size = UDim2.new(1, -5, 0, 32)
musicIdBox.Position = UDim2.new(0, 0, 0, 5)
musicIdBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
musicIdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
musicIdBox.PlaceholderText = translations["TR"].musicIdPh
musicIdBox.Text = ""
musicIdBox.TextSize = 12
musicIdBox.Font = Enum.Font.SourceSansBold
musicIdBox.ClearTextOnFocus = false
musicIdBox.Parent = soundPage
Instance.new("UICorner", musicIdBox).CornerRadius = UDim.new(0, 6)

local playMusicButton = Instance.new("TextButton")
playMusicButton.Size = UDim2.new(1, -5, 0, 32)
playMusicButton.Position = UDim2.new(0, 0, 0, 42)
playMusicButton.BackgroundColor3 = Color3.fromRGB(80, 50, 140)
playMusicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playMusicButton.TextSize = 12
playMusicButton.Font = Enum.Font.SourceSansBold
playMusicButton.Text = translations["TR"].playMusic
playMusicButton.Parent = soundPage
Instance.new("UICorner", playMusicButton).CornerRadius = UDim.new(0, 6)

local stopMusicButton = Instance.new("TextButton")
stopMusicButton.Size = UDim2.new(1, -5, 0, 32)
stopMusicButton.Position = UDim2.new(0, 0, 0, 79)
stopMusicButton.BackgroundColor3 = Color3.fromRGB(140, 50, 80)
stopMusicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopMusicButton.TextSize = 12
stopMusicButton.Font = Enum.Font.SourceSansBold
stopMusicButton.Text = translations["TR"].stopMusic
stopMusicButton.Parent = soundPage
Instance.new("UICorner", stopMusicButton).CornerRadius = UDim.new(0, 6)

local muteGameMusicButton = Instance.new("TextButton")
muteGameMusicButton.Size = UDim2.new(1, -5, 0, 32)
muteGameMusicButton.Position = UDim2.new(0, 0, 0, 116)
muteGameMusicButton.BackgroundColor3 = Color3.fromRGB(120, 80, 40)
muteGameMusicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
muteGameMusicButton.TextSize = 11
muteGameMusicButton.Font = Enum.Font.SourceSansBold
muteGameMusicButton.Text = translations["TR"].muteGame
muteGameMusicButton.Parent = soundPage
Instance.new("UICorner", muteGameMusicButton).CornerRadius = UDim.new(0, 6)

local unmuteGameMusicButton = Instance.new("TextButton")
unmuteGameMusicButton.Size = UDim2.new(1, -5, 0, 32)
unmuteGameMusicButton.Position = UDim2.new(0, 0, 0, 153)
unmuteGameMusicButton.BackgroundColor3 = Color3.fromRGB(40, 120, 80)
unmuteGameMusicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
unmuteGameMusicButton.TextSize = 11
unmuteGameMusicButton.Font = Enum.Font.SourceSansBold
unmuteGameMusicButton.Text = translations["TR"].unmuteGame
unmuteGameMusicButton.Parent = soundPage
Instance.new("UICorner", unmuteGameMusicButton).CornerRadius = UDim.new(0, 6)

local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(1, -5, 0, 35)
upButton.Position = UDim2.new(0, 0, 0, 5)
upButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.TextSize = 13
upButton.Font = Enum.Font.SourceSansBold
upButton.Text = translations["TR"].upBtn
upButton.Parent = platformPage
Instance.new("UICorner", upButton).CornerRadius = UDim.new(0, 6)

local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(1, -5, 0, 35)
downButton.Position = UDim2.new(0, 0, 0, 45)
downButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.TextSize = 13
downButton.Font = Enum.Font.SourceSansBold
downButton.Text = translations["TR"].downBtn
downButton.Parent = platformPage
Instance.new("UICorner", downButton).CornerRadius = UDim.new(0, 6)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -5, 0, 35)
toggleButton.Position = UDim2.new(0, 0, 0, 85)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 140, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 13
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Text = translations["TR"].platOn
toggleButton.Parent = platformPage
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 6)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -5, 0, 35)
speedBox.Position = UDim2.new(0, 0, 0, 5)
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.PlaceholderText = translations["TR"].speedPh
speedBox.Text = ""
speedBox.TextSize = 13
speedBox.Font = Enum.Font.SourceSansBold
speedBox.ClearTextOnFocus = false
speedBox.Parent = cheatsPage
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(1, -5, 0, 35)
noclipButton.Position = UDim2.new(0, 0, 0, 45)
noclipButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
noclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipButton.TextSize = 13
noclipButton.Font = Enum.Font.SourceSansBold
noclipButton.Text = translations["TR"].noclipOff
noclipButton.Parent = cheatsPage
Instance.new("UICorner", noclipButton).CornerRadius = UDim.new(0, 6)

local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(1, -5, 0, 35)
flyButton.Position = UDim2.new(0, 0, 0, 85)
flyButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextSize = 13
flyButton.Font = Enum.Font.SourceSansBold
flyButton.Text = translations["TR"].flyOff
flyButton.Parent = cheatsPage
Instance.new("UICorner", flyButton).CornerRadius = UDim.new(0, 6)

local holdJumpButton = Instance.new("TextButton")
holdJumpButton.Size = UDim2.new(1, -5, 0, 35)
holdJumpButton.Position = UDim2.new(0, 0, 0, 125)
holdJumpButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
holdJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
holdJumpButton.TextSize = 11
holdJumpButton.Font = Enum.Font.SourceSansBold
holdJumpButton.Text = translations["TR"].holdJumpOff
holdJumpButton.Parent = cheatsPage
Instance.new("UICorner", holdJumpButton).CornerRadius = UDim.new(0, 6)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(1, -45, 0, 30)
closeButton.Position = UDim2.new(0, 5, 1, -35)
closeButton.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 12
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Text = translations["TR"].closeBtn
closeButton.Parent = frame
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)

local resizeButton = Instance.new("TextButton")
resizeButton.Size = UDim2.new(0, 32, 0, 30)
resizeButton.Position = UDim2.new(1, -37, 1, -35)
resizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
resizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resizeButton.TextSize = 13
resizeButton.Font = Enum.Font.SourceSansBold
resizeButton.Text = "↔️"
resizeButton.Parent = frame
Instance.new("UICorner", resizeButton).CornerRadius = UDim.new(0, 6)

local function updateLanguage(langCode)
    currentLang = langCode
    local t = translations[currentLang]
    
    titleLabel.Text = t.title
    homeTabBtn.Text = t.homeTab
    soundTabBtn.Text = t.soundTab
    platformTabBtn.Text = t.platformTab
    cheatsTabBtn.Text = t.cheatsTab
    trollTabBtn.Text = t.trollTab
    langTabBtn.Text = t.langTab
    guideTabBtn.Text = t.guideTab
    closeButton.Text = t.closeBtn
    
    homeWelcomeLabel.Text = t.homeWelcome
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
    deathNotifButton.Text = deathNotificationEnabled and t.deathNotifOn or t.deathNotifOff
    
    flyTitle.Text = t.flyTitle
    upMobBtn.Text = t.upMob
    downMobBtn.Text = t.downMob
    
    langTrBtn.Text = t.langTrBtn
    langEnBtn.Text = t.langEnBtn
    guideLabel.Text = t.guideText
end

langTrBtn.MouseButton1Click:Connect(function() updateLanguage("TR") end)
langEnBtn.MouseButton1Click:Connect(function() updateLanguage("EN") end)

local function switchTab(activeTab)
    homePage.Visible = (activeTab == "home")
    soundPage.Visible = (activeTab == "sound")
    platformPage.Visible = (activeTab == "platform")
    cheatsPage.Visible = (activeTab == "cheats")
    trollPage.Visible = (activeTab == "troll")
    langPage.Visible = (activeTab == "lang")
    guidePage.Visible = (activeTab == "guide")
    
    homeTabBtn.BackgroundColor3 = (activeTab == "home") and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(40, 40, 40)
    soundTabBtn.BackgroundColor3 = (activeTab == "sound") and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(40, 40, 40)
    platformTabBtn.BackgroundColor3 = (activeTab == "platform") and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(40, 40, 40)
    cheatsTabBtn.BackgroundColor3 = (activeTab == "cheats") and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(40, 40, 40)
    trollTabBtn.BackgroundColor3 = (activeTab == "troll") and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(40, 40, 40)
    langTabBtn.BackgroundColor3 = (activeTab == "lang") and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(40, 40, 40)
    guideTabBtn.BackgroundColor3 = (activeTab == "guide") and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(40, 40, 40)
    
    if activeTab == "home" then scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 150)
    elseif activeTab == "sound" then scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 190)
    elseif activeTab == "platform" then scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 130)
    elseif activeTab == "cheats" then scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 170)
    elseif activeTab == "troll" then scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 70)
    elseif activeTab == "lang" then scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 110)
    elseif activeTab == "guide" then scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
    end
end

homeTabBtn.MouseButton1Click:Connect(function() switchTab("home") end)
soundTabBtn.MouseButton1Click:Connect(function() switchTab("sound") end)
platformTabBtn.MouseButton1Click:Connect(function() switchTab("platform") end)
cheatsTabBtn.MouseButton1Click:Connect(function() switchTab("cheats") end)
trollTabBtn.MouseButton1Click:Connect(function() switchTab("troll") end)
langTabBtn.MouseButton1Click:Connect(function() switchTab("lang") end)
guideTabBtn.MouseButton1Click:Connect(function() switchTab("guide") end)

switchTab("home")

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

local function disablePlatform()
    if isPlatformActive then
        isPlatformActive = false
        local t = translations[currentLang]
        toggleButton.Text = t.platOff
        toggleButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
        if platform then platform:Destroy(); platform = nil end
    end
end

walkFlingButton.MouseButton1Click:Connect(function()
    if isSpawningLocked then return end
    local t = translations[currentLang]
    
    walkFlingActive = not walkFlingActive
    if walkFlingActive then
        disablePlatform()
        walkFlingButton.Text = t.walkFlingOn
        walkFlingButton.BackgroundColor3 = Color3.fromRGB(50, 140, 50)
        
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
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
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
        walkFlingButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
        if walkFlingConnection then walkFlingConnection:Disconnect(); walkFlingConnection = nil end
        
        if character and not noclipActive then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)

deathNotifButton.MouseButton1Click:Connect(function()
    local t = translations[currentLang]
    deathNotificationEnabled = not deathNotificationEnabled
    if deathNotificationEnabled then
        deathNotifButton.Text = t.deathNotifOn
        deathNotifButton.BackgroundColor3 = Color3.fromRGB(50, 140, 50)
    else
        deathNotifButton.Text = t.deathNotifOff
        deathNotifButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
    end
end)

flyButton.MouseButton1Click:Connect(function()
    if isSpawningLocked then return end
    local t = translations[currentLang]
    
    flyActive = not flyActive
    if flyActive then
        disablePlatform()
        flyButton.Text = t.flyOn
        flyButton.BackgroundColor3 = Color3.fromRGB(50, 140, 50)
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
        flyButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
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
    if flyActive then flyButton.MouseButton1Click:Fire() end
    
    holdJumpActive = not holdJumpActive
    if holdJumpActive then
        disablePlatform()
        holdJumpButton.Text = t.holdJumpOn
        holdJumpButton.BackgroundColor3 = Color3.fromRGB(50, 140, 50)
    else
        holdJumpButton.Text = t.holdJumpOff
        holdJumpButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
        isHoldingJump = false
    end
end)

noclipButton.MouseButton1Click:Connect(function()
    if isSpawningLocked then return end
    local t = translations[currentLang]
    
    noclipActive = not noclipActive
    if noclipActive then
        disablePlatform()
        noclipButton.Text = t.noclipOn
        noclipButton.BackgroundColor3 = Color3.fromRGB(50, 140, 50)
        noclipConnection = RunService.Stepped:Connect(function()
            if not character or not humanoidRootPart or isPlatformActive then return end
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    else
        noclipButton.Text = t.noclipOff
        noclipButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    if isSpawningLocked then return end
    local t = translations[currentLang]
    
    isPlatformActive = not isPlatformActive
    if isPlatformActive then
        toggleButton.Text = t.platOn
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 140, 50)
        
        if walkFlingActive then walkFlingButton.MouseButton1Click:Fire() end
        if flyActive then flyButton.MouseButton1Click:Fire() end
        if holdJumpActive then holdJumpButton.MouseButton1Click:Fire() end
        if noclipActive then noclipButton.MouseButton1Click:Fire() end

        if humanoidRootPart then lockedHeight = humanoidRootPart.Position.Y - 3 end
        createPlatform()
    else
        toggleButton.Text = t.platOff
        toggleButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
        if platform then platform:Destroy(); platform = nil end
    end
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
            humanoidRootPart.Velocity = Vector3.new(humanoidRootPart.Velocity.X, 40, humanoidRootPart.Velocity.Z)
        end
    end
end)

local isResizing = false
local resizeStartPos = Vector2.new(0, 0)
local startSize = UDim2.new(0, 0, 0, 0)

resizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = true
        resizeStartPos = input.Position
        startSize = frame.Size
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStartPos
        local newWidth = math.clamp(startSize.X.Offset + delta.X, 190, 350)
        local newHeight = math.clamp(startSize.Y.Offset + delta.Y, 220, 600)
        frame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = false
    end
end)

minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = true
    frame.Size = UDim2.new(0, 60, 0, 60)
    titleLabel.Visible = false
    tabContainer.Visible = false
    scrollingFrame.Visible = false
    closeButton.Visible = false
    resizeButton.Visible = false
    minimizeButton.Visible = false
    eyeButton.Visible = true
end)

eyeButton.MouseButton1Click:Connect(function()
    isMinimized = false
    frame.Size = UDim2.new(0, 225, 0, 370)
    titleLabel.Visible = true
    tabContainer.Visible = true
    scrollingFrame.Visible = true
    closeButton.Visible = true
    resizeButton.Visible = true
    minimizeButton.Visible = true
    eyeButton.Visible = false
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
    if isSpawningLocked or isPlatformActive then return end
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

closeButton.MouseButton1Click:Connect(function()
    isRunning = false
    if noclipConnection then noclipConnection:Disconnect() end
    if flyConnection then flyConnection:Disconnect() end
    if walkFlingConnection then walkFlingConnection:Disconnect() end
    for _, conn in pairs(deathConnections) do
        if conn then conn:Disconnect() end
    end
    flyActive = false
    holdJumpActive = false
    walkFlingActive = false
    isHoldingJump = false
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
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
    if not isPlatformActive then return end
    if humanoid and humanoid.WalkSpeed ~= savedWalkSpeed then humanoid.WalkSpeed = savedWalkSpeed end
    if humanoidRootPart and platform then
        local currentX = humanoidRootPart.Position.X
        local currentZ = humanoidRootPart.Position.Z
        local charY = humanoidRootPart.Position.Y
        local platPos = platform.Position
        if Vector2.new(platPos.X - currentX, platPos.Z - currentZ).Magnitude > 30 then
            lockedHeight = charY - 3
        end
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {character, platform}
        if movingUp then
            if noclipActive then
                lockedHeight = lockedHeight + (25 * dt)
            else
                local headPos = humanoidRootPart.Position + Vector3.new(0, 2.5, 0)
                if not workspace:Raycast(headPos, Vector3.new(0, 0.8, 0), raycastParams) then
                    lockedHeight = lockedHeight + (25 * dt)
                end
            end
        elseif movingDown then
            local groundRay = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -50, 0), raycastParams)
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
    end
    if platform then
        platform.CFrame = CFrame.new(humanoidRootPart.Position.X, lockedHeight, humanoidRootPart.Position.Z)
    end
end)
