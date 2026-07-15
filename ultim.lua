local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local scriptCalisiyor = true

-- ==========================================
-- 1. ADIM: EKRANDA "OYUNCU YOK" YAZDIRAN MOBİL UYUMLU SİSTEM
-- ==========================================
local function EkranaYaziYaz(gosterilecekMetin)
    -- Eski bir duyuru ekranı varsa önce onu temizle
    if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("TrollDuyuruKutusu") then
        LocalPlayer.PlayerGui.TrollDuyuruKutusu:Destroy()
    end

    local ekranArayuzu = Instance.new("ScreenGui")
    ekranArayuzu.Name = "TrollDuyuruKutusu"
    ekranArayuzu.ResetOnSpawn = false
    ekranArayuzu.DisplayOrder = 999999 -- Ekrandaki her şeyin en üstünde durmasını sağlar
    ekranArayuzu.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local yaziAlani = Instance.new("TextLabel")
    yaziAlani.Size = UDim2.new(0.8, 0, 0.2, 0) -- Ekranın genişliğinin %80'ini kaplar
    yaziAlani.Position = UDim2.new(0.5, 0, 0.5, 0) -- Tam ekran ortası
    yaziAlani.AnchorPoint = Vector2.new(0.5, 0.5) -- Kusursuz merkezleme hizalaması
    yaziAlani.BackgroundTransparency = 1 -- Arka planı gizler, sadece kırmızı harfler görünür
    yaziAlani.Text = gosterilecekMetin -- Ekranda "OYUNCU YOK" yazmasını sağlayan asıl kısım
    yaziAlani.TextColor3 = Color3.fromRGB(255, 0, 0) -- Kıpkırmızı renk
    yaziAlani.Font = Enum.Font.SourceSansBold
    yaziAlani.TextScaled = true -- Telefon ekranının boyutuna göre yazıyı otomatik en büyük hale getirir
    yaziAlani.TextStrokeTransparency = 0 -- Harflerin etrafına siyah çerçeve çizer (rahat okunsun diye)
    yaziAlani.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    yaziAlani.Parent = ekranArayuzu

    return ekranArayuzu
end

-- ==========================================
-- 2. ADIM: 3500 SPEED SPIN (FLING) DÖNGÜSÜ
-- ==========================================
local function SpiniAktifEt()
    task.spawn(function()
        while scriptCalisiyor do
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:WaitForChild("HumanoidRootPart", 5)
            
            if rootPart and scriptCalisiyor then
                -- Eski spini temizle
                for _, child in ipairs(rootPart:GetChildren()) do
                    if child.Name == "TrollSpini" then
                        child:Destroy()
                    end
                end
                
                -- Karakteri döndürecek fiziksel gücü uygula
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
-- 3. ADIM: OTOMATİK IŞINLANMA VE SİSTEMİ KAPATMA DÖNGÜSÜ
-- ==========================================
local GecisSuresi = 1.0 -- Oyuncuya gitme süresi (1 saniye)
local BeklemeSuresi = 0.5 -- Yanında bekleme/fırlatma süresi (Yarım saniye)

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
    
    -- Sunucudaki diğer oyuncuları kontrol et
    for _, player in ipairs(oyuncular) do
        if player ~= LocalPlayer then
            aktifOyuncuSayisi = aktifOyuncuSayisi + 1
        end
    end
    
    -- EĞER SUNUCUDA BAŞKA OYUNCU YOKSA ÇALIŞACAK KISIM
    if aktifOyuncuSayisi == 0 then
        -- 1. Ekrana kırmızı, kocaman "OYUNCU YOK" yazdırır
        local duyuruGui = EkranaYaziYaz("OYUNCU YOK")
        
        -- 2. Bu yazı ekranda tam 2 saniye kalır, sonra kaybolur
        task.wait(2)
        if duyuruGui then duyuruGui:Destroy() end
        
        -- 3. Yazı gittikten 1 saniye sonra scripti ve dönmeyi tamamen durdurur
        task.wait(1)
        scriptCalisiyor = false 
        
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local spin = rootPart:FindFirstChild("TrollSpini")
                if spin then spin:Destroy() end -- Spin gücünü yok eder, dönmeyi durdurur
            end
        end
        break -- Döngüyü kırıp scripti sonlandırır
    end
    
    -- Sunucuda oyuncular varsa sırayla trolleme döngüsü başlar
    for _, player in ipairs(oyuncular) do
        if not scriptCalisiyor then break end
        
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hedefRoot = player.Character.HumanoidRootPart
            local hedefCFrame = hedefRoot.CFrame * CFrame.new(0, 0, 3) -- Oyuncunun hemen arkası
            
            PruzsuzIsinlan(hedefCFrame)
            task.wait(BeklemeSuresi) -- 0.5 saniye boyunca spinle adama çarpar
        end
    end
    
    task.wait(1)
end
