local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local scriptCalisiyor = true
local noclipBaglantisi = nil

-- ==========================================
-- 1. ADIM: NOCLIP (DUVARLARDAN GEÇME) SİSTEMİ
-- ==========================================
local function NoclipAktifEt()
    -- Eğer önceden açık bir noclip varsa önce onu kapat
    if noclipBaglantisi then
        noclipBaglantisi:Disconnect()
    end
    
    -- Her fizik adımında karakterin parçalarının çarpışmasını kapatır
    noclipBaglantisi = RunService.Stepped:Connect(function()
        if scriptCalisiyor and LocalPlayer.Character then
            for _, parca in ipairs(LocalPlayer.Character:GetDescendants()) do
                if parca:IsA("BasePart") and parca.CanCollide == true then
                    parca.CanCollide = false
                end
            end
        end
    end)
end

-- Noclip'i hemen başlat
NoclipAktifEt()

-- ==========================================
-- 2. ADIM: EKRANDA "OYUNCU YOK" YAZDIRAN MOBİL SİSTEM
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
-- 3. ADIM: 3500 SPEED SPIN (FLING) DÖNGÜSÜ
-- ==========================================
local function SpiniAktifEt()
    task.spawn(function()
        while scriptCalisiyor do
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:WaitForChild("HumanoidRootPart", 5)
            
            if rootPart and scriptCalisiyor then
                for _, child in ipairs(rootPart:GetChildren()) do
                    if child.Name == "TrollSpini" then
                        child:Destroy()
                    end
                end
                
                local bodyVelocity = Instance.new("BodyAngularVelocity")
                bodyVelocity.Name = "TrollSpini"
                bodyVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                bodyVelocity.AngularVelocity = Vector3.new(0, 3500, 0) -- 3500 Spin Hızı!
                bodyVelocity.Parent = rootPart
            end
            task.wait(0.5)
        end
    end)
end

-- Spin hilesini başlat
SpiniAktifEt()

-- ==========================================
-- 4. ADIM: OTOMATİK IŞINLANMA VE SİSTEMİ KAPATMA DÖNGÜSÜ
-- ==========================================
local GecisSuresi = 1.0
local BeklemeSuresi = 0.5

local function PruzsuzIsinlan(hedefCFrame)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = character.HumanoidRootPart
    
    local mesafe = (rootPart.Position - hedefCFrame.Position).Magnitude
    local dynamicTime = math.max(GecisSuresi, mesafe / 200) 
    
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
    
    -- SUNUCUDA BAŞKA OYUNCU YOKSA ÇALIŞACAK KISIM
    if aktifOyuncuSayisi == 0 then
        -- 1. Ekrana kırmızı, kocaman "OYUNCU YOK" yazar
        local duyuruGui = EkranaYaziYaz("OYUNCU YOK")
        
        -- 2. Bu yazı ekranda tam 2 saniye kalır, sonra kaybolur
        task.wait(2)
        if duyuruGui then duyuruGui:Destroy() end
        
        -- 3. Yazı gittikten 1 saniye sonra her şeyi durdur
        task.wait(1)
        scriptCalisiyor = false 
        
        -- Noclip'i kapat ve çarpışmaları normale döndür
        if noclipBaglantisi then
            noclipBaglantisi:Disconnect()
            noclipBaglantisi = nil
        end
        
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local spin = rootPart:FindFirstChild("TrollSpini")
                if spin then spin:Destroy() end
            end
            -- Karakter parçalarının çarpışmasını tekrar aç (Normal fizik)
            for _, parca in ipairs(character:GetDescendants()) do
                if parca:IsA("BasePart") then
                    parca.CanCollide = true
                end
            end
        end
        break 
    end
    
    -- Sunucuda oyuncular varsa sırayla trolleme döngüsü başlar
    for _, player in ipairs(oyuncular) do
        if not scriptCalisiyor then break end
        
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hedefRoot = player.Character.HumanoidRootPart
            local hedefCFrame = hedefRoot.CFrame * CFrame.new(0, 0, 3)
            
            PruzsuzIsinlan(hedefCFrame)
            task.wait(BeklemeSuresi) 
        end
    end
    
    task.wait(1)
end
