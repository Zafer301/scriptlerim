local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. ADIM: 3500 HIZINDA SPIN (FLING) KURULUMU
-- ==========================================
local function SpiniAktifEt()
    task.spawn(function()
        while true do
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:WaitForChild("HumanoidRootPart", 5)
            
            if rootPart then
                -- Eğer eski bir spin objesi varsa temizle
                for _, child in ipairs(rootPart:GetChildren()) do
                    if child.Name == "TrollSpini" then
                        child:Destroy()
                    end
                end
                
                -- Karakteri fırlatacak olan fizik gücünü oluştur
                local bodyVelocity = Instance.new("BodyAngularVelocity")
                bodyVelocity.Name = "TrollSpini"
                bodyVelocity.MaxTorque = Vector3.new(0, math.huge, 0) -- Sadece kendi etrafında dönmesi için
                bodyVelocity.AngularVelocity = Vector3.new(0, 3500, 0) -- İstediğin 3500 Spin hızı!
                bodyVelocity.Parent = rootPart
            end
            LocalPlayer.CharacterAdded:Wait() -- Ölürsen yeni karakter gelene kadar bekle
        end
    end)
end

-- Spini hemen başlatıyoruz
SpiniAktifEt()

-- ==========================================
-- 2. ADIM: YAVAŞ IŞINLANMA VE TROL DÖNGÜSÜ
-- ==========================================
local GecisSuresi = 1.0 -- Oyuncuya süzülme süresi (1 saniye)
local BeklemeSuresi = 0.5 -- Yanında bekleme/fırlatma süresi (Yarım saniye)

-- Pürüzsüz hareket fonksiyonu
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

-- Tüm oyuncuları sırayla trolleyen ana döngü
while true do
    local oyuncular = Players:GetPlayers()
    local hedefBulundu = false
    
    for _, player in ipairs(oyuncular) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hedefRoot = player.Character.HumanoidRootPart
            local hedefCFrame = hedefRoot.CFrame * CFrame.new(0, 0, 3) 
            
            PruzsuzIsinlan(hedefCFrame)
            hedefBulundu = true
            
            task.wait(BeklemeSuresi) -- 0.5 saniye boyunca 3500 spinle adama çarpıp fırlat!
        end
    end
    
    if not hedefBulundu then
        task.wait(2)
    end
    
    task.wait(1)
end

