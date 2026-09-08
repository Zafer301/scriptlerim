local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Platformu oluştur
local platform = Instance.new("Part")
platform.Size = Vector3.new(50, 1, 50)
platform.Anchored = true
platform.CanCollide = true
platform.Transparency = 0.5
platform.Parent = workspace

local heightOffset = -3

-- GUI Oluşturma
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlatformControlGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 140, 0, 180)
frame.Position = UDim2.new(0, 20, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = frame

-- (+) Butonu (Yukarı)
local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0, 120, 0, 40)
upButton.Position = UDim2.new(0, 10, 0, 10)
upButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.TextSize = 20
upButton.Font = Enum.Font.SourceSansBold
upButton.Text = "+ (Yukarı)"
upButton.Parent = frame
Instance.new("UICorner", upButton).CornerRadius = UDim.new(0, 6)

-- (-) Butonu (Aşağı)
local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0, 120, 0, 40)
downButton.Position = UDim2.new(0, 10, 0, 60)
downButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.TextSize = 20
downButton.Font = Enum.Font.SourceSansBold
downButton.Text = "- (Aşağı)"
downButton.Parent = frame
Instance.new("UICorner", downButton).CornerRadius = UDim.new(0, 6)

-- Kapat Butonu (X)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 120, 0, 40)
closeButton.Position = UDim2.new(0, 10, 0, 110)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Text = "Kapat"
closeButton.Parent = frame
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)

-- Buton İşlevleri
upButton.MouseButton1Click:Connect(function()
    heightOffset = heightOffset + 1
end)

downButton.MouseButton1Click:Connect(function()
    heightOffset = heightOffset - 1
end)

local isRunning = true
closeButton.MouseButton1Click:Connect(function()
    isRunning = false
    platform:Destroy()
    screenGui:Destroy()
end)

-- Takip Döngüsü
game:GetService("RunService").RenderStepped:Connect(function()
    if not isRunning then return end
    
    if humanoidRootPart and platform then
        local targetPosition = humanoidRootPart.Position + Vector3.new(0, heightOffset, 0)
        platform.CFrame = CFrame.new(targetPosition.X, targetPosition.Y, targetPosition.Z)
    end
end)
