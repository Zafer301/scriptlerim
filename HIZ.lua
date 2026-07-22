-- Delta ve diğer executorlar için hız hilesi ve arayüz kodu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Ana ScreenGui oluşturma
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaSpeedGui"
ScreenGui.Parent = game:CoreGui
ScreenGui.ResetOnSpawn = false

-- Ana Çerçeve (Ekranın köşesinde)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 150)
MainFrame.Position = UDim2.new(1, -230, 0, 20) -- Sağ üst köşe
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Köşeleri yuvarlatma
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Başlık / Tamamen Kapa Butonu
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(1, -10, 0, 35)
CloseButton.Position = UDim2.new(0, 5, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "TAMAMEN KAPA"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Hız Göstergesi Etiketi
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0, 25)
StatusLabel.Position = UDim2.new(0, 5, 0, 45)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Hız: 16 (Normal)"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Parent = MainFrame

-- Kaydırma Çubuğu Arka Planı (Slider Track)
local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(1, -20, 0, 10)
SliderBar.Position = UDim2.new(0, 10, 0, 95)
SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = MainFrame

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = SliderBar

-- Kaydırma Düğmesi (Slider Button)
local SliderButton = Instance.new("TextButton")
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.Position = UDim2.new(0, 0, 0.5, -10)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.Text = ""
SliderButton.Parent = SliderBar

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = SliderButton

-- Mantık ve Fonksiyonlar
local minSpeed = 16
local maxSpeed = 150
local currentSpeed = 16
local dragging = false

-- Slider sürükleme olayı
SliderButton.MouseButton1Down:Connect(function()
    dragging = true
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        local barPos = SliderBar.AbsolutePosition
        local barSize = SliderBar.AbsoluteSize
        
        local relativeX = math.clamp(mousePos.X - barPos.X, 0, barSize.X)
        local percentage = relativeX / barSize.X
        
        SliderButton.Position = UDim2.new(percentage, -10, 0.5, -10)
        
        currentSpeed = math.floor(minSpeed + (maxSpeed - minSpeed) * percentage)
        StatusLabel.Text = "Hız: " .. currentSpeed
    end
end)

-- Hızı sürekli uygulama döngüsü
local connection
connection = RunService.RenderStepped:Connect(function()
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = currentSpeed
        end
    end)
end)

-- Tamamen Kapa Butonu İşlevi
CloseButton.MouseButton1Click:Connect(function()
    if connection then
        connection:Disconnect()
    end
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16 -- Normale döndür
        end
    end)
    ScreenGui:Destroy()
end)
