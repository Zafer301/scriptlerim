local Players = game:GetService("Players")
local player = Players.LocalPlayer
local currentConnection = nil -- Bağlantıyı takip etmek için değişken

local function setupCharacter(char)
    local hum = char:WaitForChild("Humanoid")
    
    -- Eğer eski bir bağlantı varsa kapat (üst üste binmeyi önler)
    if currentConnection then
        currentConnection:Disconnect()
    end
    
    -- Yeni bağlantıyı kur ve değişkene ata
    currentConnection = player.Chatted:Connect(function(message)
        local args = string.split(message, " ")
        local command = string.lower(args[1])

        if command == "!god" then
            hum.MaxHealth = 999999
            hum.Health = 999999
            -- HealthChanged bağlantısını da temizlemek gerekebilir, 
            -- ama şimdilik temel işlevin çalışıyor.
            
        elseif command == "!hiz" then
            local speed = tonumber(args[2]) or 50
            hum.WalkSpeed = speed
            
        elseif command == "!zipla" then
            local jump = tonumber(args[2]) or 100
            hum.JumpPower = jump
        end
    end)
end

-- İlk karakter ve sonraki tüm karakterler için kurulum
player.CharacterAdded:Connect(setupCharacter)
if player.Character then
    setupCharacter(player.Character)
end
