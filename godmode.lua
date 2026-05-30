-- Zafer301 Geliştirilmiş God Mode
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Kalkan ekle (Roblox'un kendi kalkanı, çoğu oyunda çalışır)
local forceField = Instance.new("ForceField")
forceField.Parent = character

-- Canı sabitleme
local humanoid = character:WaitForChild("Humanoid")
humanoid.MaxHealth = 999999
humanoid.Health = 999999

humanoid.HealthChanged:Connect(function()
    humanoid.Health = 999999
end)

print("God Mode ve ForceField Aktif, Zafer301!")
