local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Karakterin zıplamasını engelle (Sıkışmayı önlemek için)
humanoid.JumpPower = 0
humanoid.UseJumpPower = true

-- Karakter sıfırlandığında zıplamayı kapalı tutmaya devam et
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

-- Başlangıç yüksekliğini sabitle (Karakterin altı)
local lockedHeight = humanoidRootPart.Position.Y - 3

-- GUI Oluşturma
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlatformControlGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 140, 0, 230)
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
upButton.Size = UDim2.new(0, 120, 0, 35)
upButton.Position = UDim2.new(0, 10, 0, 10)
upButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.TextSize = 18
upButton.Font = Enum.Font.SourceSansBold
upButton.Text = "+ (Yukarı)"
upButton.Parent = frame
Instance.new("UICorner", upButton).CornerRadius = UDim.new(0, 6)

-- (-) Butonu (Aşağı)
local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0, 120, 0, 35)
downButton.Position = UDim2.new(0, 10, 0, 55)
downButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.TextSize = 18
downButton.Font = Enum.Font.SourceSansBold
downButton.Text = "- (Aşağı)"
downButton.Parent = frame
Instance.new("UICorner", downButton).CornerRadius = UDim.new(0, 6)

-- Hız Girdi Kutusu (TextBox)
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 120, 0, 35)
speedBox.Position = UDim2.new(0, 10, 0, 100)
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.PlaceholderText = "Hız Yaz (örn: 50)"
speedBox.Text = ""
speedBox.TextSize = 14
speedBox.Font = Enum.Font.SourceSansBold
speedBox.ClearTextOnFocus = false
speedBox.Parent = frame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

-- Kapat Butonu (X)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 120, 0, 35)
closeButton.Position = UDim2.new(0, 10, 0, 145)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Text = "Kapat"
closeButton.Parent = frame
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)

-- TextBox Hız Değiştirme Mantığı
speedBox.FocusLost:Connect(function(enterPressed)
    local newSpeed = tonumber(speedBox.Text)
    if newSpeed and humanoid then
        humanoid.WalkSpeed = newSpeed
    end
end)

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
    if humanoid then 
        humanoid.JumpPower = 50 
        humanoid.WalkSpeed = 16 
    end
    platform:Destroy()
    screenGui:Destroy()
end)

-- Karakterin platforma yapışmasını ve takip etmesini sağlayan ana döngü
game:GetService("RunService").RenderStepped:Connect(function(dt)
    if not isRunning then return end
    
    -- Butona basılı tutulduğunda yüksekliği dinamik değiştir
    if movingUp then
        lockedHeight = lockedHeight + (25 * dt)
    elseif movingDown then
        lockedHeight = lockedHeight - (25 * dt)
    end
    
    if humanoidRootPart and platform then
        -- X ve Z'de seni takip eder, Y'de seninle birlikte kilitli yükseklikte kalır (Yapışma hissi)
        platform.CFrame = CFrame.new(humanoidRootPart.Position.X, lockedHeight, humanoidRootPart.Position.Z)
    end
end)
