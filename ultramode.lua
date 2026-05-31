local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Karakter güncelleyici fonksiyon
local function setupCharacter(char)
    local hum = char:WaitForChild("Humanoid")
    
    -- Komutları dinle
    player.Chatted:Connect(function(message)
        local args = string.split(message, " ")
        local command = string.lower(args[1])

        if command == "!god" then
            hum.MaxHealth = 999999
            hum.Health = 999999
            hum.HealthChanged:Connect(function()
                hum.Health = 999999
            end)
            
        elseif command == "!hiz" then
            hum.WalkSpeed = tonumber(args[2]) or 50
            
        elseif command == "!zipla" then
            hum.JumpPower = tonumber(args[2]) or 100
        end
    end)
end

-- İlk karakteri yakala
if player.Character then
    setupCharacter(player.Character)
end

-- Karakter her öldüğünde/yeniden doğduğunda tekrar ayarla
player.CharacterAdded:Connect(setupCharacter)
