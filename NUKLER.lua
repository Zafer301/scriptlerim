local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local scriptCalisiyor = true
local noclipBaglantisi = nil
local lagParcalari = {} -- Üretilen lag parçalarını hafızada tutuyoruz

-- ==========================================
-- SCRIPT SIFIRLAMA VE DURDURMA FONKSİYONU
-- ==========================================
local function ScriptiDurdur()
    if not scriptCalisiyor then return end
    scriptCalisiyor = false
    
    -- Noclip bağlantısını kopar
    if noclipBaglantisi then
        noclipBaglantisi:Disconnect()
        noclipBaglantisi = nil
    end
    
    -- Üretilen tüm lag parçalarını temizle (Oyunu anında rahatlatır)
    for _, parca in ipairs(lagParcalari) do
        if parca and parca.Parent then
            parca:Destroy()
        end
    end
    lagParcalari = {}
    
    -- Karakteri temizle
    local character = LocalPlayer.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local spin = rootPart:FindFirstChild("TrollSpini")
            local sabitleyici = rootPart:FindFirstChild("TrollSabitleyici")
            local yon = rootPart:FindFirstChild("TrollYön")
            if spin then spin:Destroy() end
            if sabitleyici then sabitleyici:Destroy() end
            if yon then yon:Destroy() end
        end
        for _, parca in ipairs(character:GetDescendants()) do
            if parca:IsA("BasePart") then
                parca.CanCollide = true
            end
        end
    end
    
    -- Ekrandaki arayüzleri temizle
    if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("TrollDuyuruKutusu") then
        LocalPlayer.PlayerGui.TrollDuyuruKutusu:Destroy()
    end
    if LocalPlayer.PlayerGui:FindFirstChild("TrollKontrolPaneli") then
        LocalPlayer.PlayerGui.TrollKontrolPaneli:Destroy()
    end
end

-- Klavyeden "X" tuşuna basınca durdur
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.X then
        ScriptiDurdur()
    end
end)

-- ==========================================
-- EKRANA DURDURMA BUTONU EKLEME
-- ==========================================
local function DurdurmaButonuOlustur()
    if LocalPlayer.PlayerGui:FindFirstChild("TrollKontrolPaneli") then
        LocalPlayer.PlayerGui.TrollKontrolPaneli:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "TrollKontrolPaneli"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local buton = Instance.new("TextButton")
    buton.Size = UDim2.new(0, 120, 0, 50)
    buton.Position = UDim2.new(0.5, -60, 0.1, 0)
    buton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    buton.BorderSizePixel = 2
    buton.Text = "KAPAT (X)"
    buton.TextColor3 = Color3.fromRGB(255, 255, 255)
    buton.Font = Enum.Font.SourceSansBold
    buton.TextSize = 20
    buton.Parent = gui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = buton

    buton.MouseButton1Click:Connect(function()
        ScriptiDurdur()
    end)
end
DurdurmaButonuOlustur()

-- ==========================================
-- 1. ADIM: GELİŞMİŞ VE GÜVENLİ NOCLIP
-- ==========================================
local function NoclipAktifEt()
    if noclipBaglantisi then noclipBaglantisi:Disconnect() end
    noclipBaglantisi = RunService.Stepped:Connect(function()
        if scriptCalisiyor and LocalPlayer.Character then
            for _, parca in ipairs(LocalPlayer.Character:GetDescendants()) do
                if parca:IsA("BasePart") then
                    parca.CanCollide = false
                end
            end
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CanCollide = true
            end
        end
    end)
end
NoclipAktifEt()

-- ==========================================
-- 2. ADIM: DEVASA SPIN GÜCÜ (95.000)
-- ==========================================
local function SpiniAktifEt()
    task.spawn(function()
        while scriptCalisiyor do
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:WaitForChild("HumanoidRootPart", 5)
            
            if rootPart and scriptCalisiyor then
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                
                for _, child in ipairs(rootPart:GetChildren()) do
                    if child.Name == "TrollSpini" or child.Name == "TrollSabitleyici" or child.Name == "TrollYön" then 
                        child:Destroy() 
                    end
                end
                
                local sabitleyici = Instance.new("BodyVelocity")
                sabitleyici.Name = "TrollSabitleyici"
                sabitleyici.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                sabitleyici.Velocity = Vector3.new(0, 0, 0)
                sabitleyici.Parent = rootPart
                
                local yon = Instance.new("BodyGyro")
                yon.Name = "TrollYön"
                yon.MaxTorque = Vector3.new(math.huge, 0, math.huge)
                yon.CFrame = rootPart.CFrame
                yon.Parent = rootPart
                
                local bodyVelocity = Instance.new("BodyAngularVelocity")
                bodyVelocity.Name = "TrollSpini"
                bodyVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                bodyVelocity.AngularVelocity = Vector3.new(0, 95000, 0) 
                bodyVelocity.Parent = rootPart
            end
            task.wait(0.1)
        end
    end)
end
SpiniAktifEt()

-- ==========================================
-- 3. ADIM: FİZİKSEL LAG PARÇALARI ÜRETİCİSİ
-- ==========================================
local function LagBulutuOlustur(pozisyon)
    if not scriptCalisiyor then return end
    
    -- Tek seferde 5 adet aşırı ağır fiziksel parça fırlatır
    for i = 1, 5 do
        local parca = Instance.new("Part")
        parca.Size = Vector3.new(4, 4, 4)
        parca.Position = pozisyon + Vector3.new(math.random(-2, 2), 2, math.random(-2, 2))
        parca.CastShadow = false
        parca.Material = Enum.Material.ForceField -- Ekran kartını en çok yoran materyal!
        parca.Color = Color3.fromRGB(255, 0, 0)
        parca.Transparency = 0.7 -- Şeffaf nesnelerin üst üste binmesi render lagı yaratır
        
        -- Ağır fiziksel hesaplama için ayarlar
        parca.CanCollide = true
        parca.Velocity = Vector3.new(math.random(-100, 100), 100, math.random(-100, 100))
        
        -- Yerçekimsiz yapıyoruz ki haritadan düşüp yok olmasınlar, etrafta uçuşup lag yapsınlar
        local force = Instance.new("BodyForce")
        force.Force = Vector3.new(0, parca:GetMass() * workspace.Gravity, 0)
        force.Parent = parca
        
        parca.Parent = workspace
        table.insert(lagParcalari, parca)
        
        -- Performansın tamamen çökmemesi için eski parçaları yavaşça temizle (Maksimum 150 parça)
        if #lagParcalari > 150 then
            local eskiParca = table.remove(lagParcalari, 1)
            if eskiParca and eskiParca.Parent then
                eskiParca:Destroy()
            end
        end
    end
end

-- ==========================================
-- 4. ADIM: HEM ARKADAN FLING HEM DE LAG DÖNGÜSÜ
-- ==========================================
while scriptCalisiyor do
    local oyuncular = Players:GetPlayers()
    local aktifOyuncuSayisi = 0
    
    for _, player in ipairs(oyuncular) do
        if player ~= LocalPlayer then
            aktifOyuncuSayisi = aktifOyuncuSayisi + 1
        end
    end
    
    if aktifOyuncuSayisi == 0 then
        ScriptiDurdur()
        break 
    end
    
    for _, player in ipairs(oyuncular) do
        if not scriptCalisiyor then break end
        
        local character = LocalPlayer.Character
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and character and character:FindFirstChild("HumanoidRootPart") then
            
            local kurbanRoot = player.Character.HumanoidRootPart
            local bizimRoot = character.HumanoidRootPart
            
            -- Arkasına ışınlanıyoruz
            local arkasindakiKonum = kurbanRoot.CFrame * CFrame.new(0, 0, 1.8) 
            bizimRoot.CFrame = arkasindakiKonum
            
            -- Işınlandığımız yerde anında lag bulutunu tetikliyoruz
            LagBulutuOlustur(bizimRoot.Position)
            
            task.wait(0.12) 
        end
    end
    
    task.wait(0.1)
end

