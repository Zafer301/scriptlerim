local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local scriptCalisiyor = true
local noclipBaglantisi = nil

-- ==========================================
-- 1. ADIM: OYUNCULARA ÇARPAN SEÇİCİ NOCLIP
-- ==========================================
local function NoclipAktifEt()
    if noclipBaglantisi then noclipBaglantisi:Disconnect() end
    
    noclipBaglantisi = RunService.Stepped:Connect(function()
        local karakter = LocalPlayer.Character
        if scriptCalisiyor and karakter then
            -- Kendi karakter parçalarımızın haritayla çarpışmasını kapatıyoruz
            for _, parca in ipairs(karakter:GetDescendants()) do
                if parca:IsA("BasePart") then
                    -- ÖNEMLİ: Oyuncuların çarpışmasını açık tutmak için CanCollide'ı sadece harita elemanlarına karşı kapatıyoruz
                    parca.CanCollide = false
                end
            end
            
            -- Diğer oyuncuların karakterleriyle çarpışabilmemiz için HumanoidRootPart'ı aktif tutuyoruz
            local root = karakter:FindFirstChild("HumanoidRootPart")
            if root then
                root.CanCollide = true
            end
        end
    end)
end
NoclipAktifEt()

-- ==========================================
-- 2. ADIM: EKRANDA "OYUNCU YOK" DUYURUSU
-- ==========================================
local function EkranaYaziYaz(gosterilecekMetin)
    if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("TrollDuyuruKutusu") then
        LocalPlayer.PlayerGui.TrollDuyuruKutusu:Destroy()
    end

    local ekranArayuzu = Instance.new("ScreenGui")
    ekranArayuzu.Name = "TrollDuyuruKutusu"
    ekranArayuzu.ResetOnSpawn = false
    ekranArayuzu.DisplayOrder = 999999
    ekranArayuzu.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local yaziAlani = Instance.new("TextLabel")
    yaziAlani.Size = UDim2.new(0.8, 0, 0.2, 0)
    yaziAlani.Position = UDim2.new(0.5, 0, 0.5, 0)
    yaziAlani.AnchorPoint = Vector2.new(0.5, 0.5)
    yaziAlani.BackgroundTransparency = 1
    yaziAlani.Text = gosterilecekMetin
    yaziAlani.TextColor3 = Color3.fromRGB(255, 0, 0)
    yaziAlani.Font = Enum.Font.SourceSansBold
    yaziAlani.TextScaled = true
    yaziAlani.TextStrokeTransparency = 0
    yaziAlani.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    yaziAlani.Parent = ekranArayuzu

    return ekranArayuzu
end

-- ==========================================
-- 3. ADIM: GÜVENLİ VE GÜÇLÜ SPIN (BUG ENGELLEYİCİ)
-- ==========================================
local function SpiniAktifEt()
    task.spawn(function()
        while scriptCalisiyor do
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:WaitForChild("HumanoidRootPart", 5)
            
            if rootPart and scriptCalisiyor then
                -- Karakterin kendi kendine saçma sapan fırlamasını engelleyen sabitleyici fizik
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                
                for _, child in ipairs(rootPart:GetChildren()) do
                    if child.Name == "TrollSpini" or child.Name == "TrollSabitleyici" then 
                        child:Destroy() 
                    end
                end
                
                -- Sabitleyici (Karakterin buglanıp başka yere uçmasını önler)
                local sabitleyici = Instance.new("BodyVelocity")
                sabitleyici.Name = "TrollSabitleyici"
                sabitleyici.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                sabitleyici.Velocity = Vector3.new(0, 0, 0)
                sabitleyici.Parent = rootPart
                
                -- 15.000 Gücünde Spin
                local bodyVelocity = Instance.new("BodyAngularVelocity")
                bodyVelocity.Name = "TrollSpini"
                bodyVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                bodyVelocity.AngularVelocity = Vector3.new(0, 15000, 0) 
                bodyVelocity.Parent = rootPart
            end
            task.wait(0.2)
        end
    end)
end
SpiniAktifEt()

-- ==========================================
-- 4. ADIM: IŞINLANMA VE TROL DÖNGÜSÜ
-- ==========================================
local GecisSuresi = 1.0 -- Oyuncuya gitme süresi
local BeklemeSuresi = 0.5 -- Oyuncuyu fırlatması için bekleme süresi

local function PruzsuzIsinlan(hedefCFrame)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = character.HumanoidRootPart
    
    local mesafe = (rootPart.Position - hedefCFrame.Position).Magnitude
    local dynamicTime = math.max(GecisSuresi, mesafe / 50) -- Saniyede 50 birim kontrollü hız
    
    local tweenInfo = TweenInfo.new(dynamicTime, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = hedefCFrame})
    
    tween:Play()
    tween.Completed:Wait()
end

while scriptCalisiyor do
    local oyuncular = Players:GetPlayers()
    local aktifOyuncuSayisi = 0
    
    for _, player in ipairs(oyuncular) do
        if player ~= LocalPlayer then
            aktifOyuncuSayisi = aktifOyuncuSayisi + 1
        end
    end
    
    -- OYUNCU YOKSA KAPANMA
    if aktifOyuncuSayisi == 0 then
        local duyuruGui = EkranaYaziYaz("OYUNCU YOK")
        task.wait(2)
        if duyuruGui then duyuruGui:Destroy() end
        
        task.wait(1)
        scriptCalisiyor = false 
        
        if noclipBaglantisi then
            noclipBaglantisi:Disconnect()
            noclipBaglantisi = nil
        end
        
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local spin = rootPart:FindFirstChild("TrollSpini")
                local sabitleyici = rootPart:FindFirstChild("TrollSabitleyici")
                if spin then spin:Destroy() end
                if sabitleyici then sabitleyici:Destroy() end
            end
            for _, parca in ipairs(character:GetDescendants()) do
                if parca:IsA("BasePart") then
                    parca.CanCollide = true
                end
            end
        end
        break 
    end
    
    -- SIRAYLA OYUNCULARIN ARKASINA GİT VE FIRLAT
    for _, player in ipairs(oyuncular) do
        if not scriptCalisiyor then break end
        
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hedefRoot = player.Character.HumanoidRootPart
            
            -- Oyuncunun tam arkasına kilitlen
            local hedefCFrame = hedefRoot.CFrame * CFrame.new(0, 0, 3)
            
            PruzsuzIsinlan(hedefCFrame)
            task.wait(BeklemeSuresi) -- Yarım saniye çarpıp fırlatmasını bekle
        end
    end
    
    task.wait(0.5)
end
