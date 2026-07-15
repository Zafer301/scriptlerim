local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local scriptCalisiyor = true
local noclipBaglantisi = nil

-- Yapay Spin Açısı
local yapayDonisAcisi = 0

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
                -- Sadece ana gövdenin çarpışmasını açık tutuyoruz ki temas gerçekleşsin!
                root.CanCollide = true
            end
        end
    end)
end
NoclipAktifEt()

-- ==========================================
-- 2. ADIM: GÜVENLİ VE GÜÇLÜ SPIN (9500 GÜÇ)
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
                bodyVelocity.AngularVelocity = Vector3.new(0, 9500, 0) 
                bodyVelocity.Parent = rootPart
            end
            task.wait(0.1)
        end
    end)
end
SpiniAktifEt()

-- ==========================================
-- 3. ADIM: EKRANDA "OYUNCU YOK" DUYURUSU
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
-- 4. ADIM: SÜRTÜNMELİ IŞINLANMA FONKSİYONU
-- ==========================================
local function TemasliIsinlan(hedefPozisyon)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    yapayDonisAcisi = (yapayDonisAcisi + 90) % 360
    
    -- Fiziksel temas (sürtünme) yaratmak için pozisyona milimetrik yapay bir titreşim/sapma ekliyoruz.
    -- Bu sayede karakter doğrudan tam ortada hayalet gibi durmaz, sürekli adama çarpıyormuş gibi yapar.
    local sapmaX = (math.random(-10, 10) / 100)
    local sapmaZ = (math.random(-10, 10) / 100)
    local yeniPozisyon = hedefPozisyon + Vector3.new(sapmaX, 0.1, sapmaZ)
    
    local yeniCFrame = CFrame.new(yeniPozisyon) * CFrame.Angles(0, math.rad(yapayDonisAcisi), 0)
    character.HumanoidRootPart.CFrame = yeniCFrame
end

-- ==========================================
-- 5. ADIM: MIKNATISLI TAKİP VE ANA KONTROL DÖNGÜSÜ
-- ==========================================
local BeklemeSuresi = 1.5 -- Takip ve fırlatma süresi 1.5 saniye

while scriptCalisiyor do
    local oyuncular = Players:GetPlayers()
    local aktifOyuncuSayisi = 0
    
    for _, player in ipairs(oyuncular) do
        if player ~= LocalPlayer then
            aktifOyuncuSayisi = aktifOyuncuSayisi + 1
        end
    end
    
    -- OYUNCU YOKSA SCRIPT KENDİNİ KAPATIR
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
        break 
    end
    
    -- SIRAYLA OYUNCULARIN TAM İÇİNE IŞINLAN VE YAPAY TEMASLA FIRLAT
    for _, player in ipairs(oyuncular) do
        if not scriptCalisiyor then break end
        
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local baslangicZamani = os.clock()
            
            while os.clock() - baslangicZamani < BeklemeSuresi do
                if not scriptCalisiyor then break end
                
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hedefPozisyon = player.Character.HumanoidRootPart.Position
                    TemasliIsinlan(hedefPozisyon)
                else
                    break 
                end
                
                RunService.Heartbeat:Wait()
            end
        end
    end
    
    task.wait(0.1)
end
