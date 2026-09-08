local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Karakterin zıplamasını engelle (Sıkışmayı önlemek için)
humanoid.JumpPower = 0
humanoid.UseJumpPower = true

-- Karakter sıfırlandığında (ölüp dirildiğinde) zıplamayı kapalı tutmaya devam et
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    humanoid.JumpPower = 0
    humanoid.UseJumpPower = true
end)

-- Platformu oluştur
local platform = Instance.new("Part")
platform.Size = Vector3.new(50, 1, 50)
platform.Anchored = true
platform.CanCollide = true
platform.Transparency = 0.5
platform.Parent = workspace

-- Başlangıç yüksekliğini karakterin doğduğu yere sabitle (Aşağı düşme sorununu çözer)
local lockedHeight = humanoidRootPart.Position.Y - 3

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

-- Basılı tutma durumları
local movingUp = false
local movingDown = false

upButton.MouseButton1Down:Connect(function() movingUp = true end)
upButton.MouseButton1Up:Connect(function() movingUp = false end)
upButton.MouseLeave:Connect(function() movingUp = false end)

downButton.MouseButton1Down:Connect(function() movingDown = true end)
downButton.MouseButton1Up:Connect(function() movingDown = false end)
downButton.MouseLeave:Connect(function() movingDown = false end)

local isRunning = true
closeButton.MouseButton1Click:Connect(function()
    isRunning = false
    if humanoid then humanoid.JumpPower = 50 end -- Kapatınca zıplamayı normale döndür
    platform:Destroy()
    screenGui:Destroy()
end)

-- Takip ve Sabitleme Döngüsü
game:GetService("RunService").RenderStepped:Connect(function(dt)
    if not isRunning then return end
    
    -- Butona basılı tutulduğunda yüksekliği değiştir
    if movingUp then
        lockedHeight = lockedHeight + (25 * dt)
    elseif movingDown then
        lockedHeight = lockedHeight - (25 * dt)
    end
    
    if humanoidRootPart and platform then
        -- X ve Z ekseninde karakteri takip eder, Y eksenini (yüksekliği) tamamen sabit tutar
        platform.CFrame = CFrame.new(humanoidRootPart.Position.X, lockedHeight, humanoidRootPart.Position.Z)
    end
end)
