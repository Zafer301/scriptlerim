local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local platform = Instance.new("Part")
platform.Size = Vector3.new(50, 1, 50)
platform.Anchored = true
platform.CanCollide = true
platform.Transparency = 0.5
platform.Parent = workspace

local baseHeight = humanoidRootPart.Position.Y - 3

game:GetService("RunService").RenderStepped:Connect(function()
    if humanoidRootPart and platform then
        -- X ve Z'de karakteri takip eder, Y'yi (yüksekliği) sabiter
        platform.CFrame = CFrame.new(humanoidRootPart.Position.X, baseHeight, humanoidRootPart.Position.Z)
    end
end)
