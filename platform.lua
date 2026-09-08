local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local platform = Instance.new("Part")
platform.Size = Vector3.new(50, 1, 50)
platform.Anchored = true
platform.CanCollide = true
platform.Transparency = 0.5
platform.Parent = workspace

game:GetService("RunService").RenderStepped:Connect(function()
    if humanoidRootPart and platform then
        local targetPosition = humanoidRootPart.Position - Vector3.new(0, 3, 0)
        platform.CFrame = CFrame.new(targetPosition)
    end
end)
