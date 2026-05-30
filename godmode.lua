-- Zafer301 God Mode Scripti
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

humanoid.MaxHealth = 999999
humanoid.Health = 999999

humanoid.HealthChanged:Connect(function()
    humanoid.Health = 999999
end)

print("God Mode Aktif edildi, Zafer301!")
