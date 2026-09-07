-- Ekranın köşesinde açılan, kendi yazı yazma kutusu olan chat aparatı
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- GUI Oluşturma
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChatAparati"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 110)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCornerMain = Instance.new("UICorner")
uiCornerMain.CornerRadius = UDim.new(0, 8)
uiCornerMain.Parent = mainFrame

-- Yazı Yazma Kutusu (TextBox)
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0, 180, 0, 35)
textBox.Position = UDim2.new(0, 10, 0, 10)
textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderText = "Gönderilecek yazıyı yaz..."
textBox.Text = ""
textBox.TextSize = 14
textBox.ClearTextOnFocus = false
textBox.Parent = mainFrame

local uiCornerBox = Instance.new("UICorner")
uiCornerBox.CornerRadius = UDim.new(0, 6)
uiCornerBox.Parent = textBox

-- Mesaj Gönderme Butonu
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(0, 85, 0, 30)
sendButton.Position = UDim2.new(0, 10, 0, 55)
sendButton.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sendButton.TextSize = 14
sendButton.Text = "Gönder"
sendButton.Parent = mainFrame

local uiCornerSend = Instance.new("UICorner")
uiCornerSend.CornerRadius = UDim.new(0, 6)
uiCornerSend.Parent = sendButton

-- Tamamen Yok Etme Butonu
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 85, 0, 30)
closeButton.Position = UDim2.new(0, 105, 0, 55)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Text = "Kapat"
closeButton.Parent = mainFrame

local uiCornerClose = Instance.new("UICorner")
uiCornerClose.CornerRadius = UDim.new(0, 6)
uiCornerClose.Parent = closeButton

-- Gönderme bağlantısı
local clickConnection
clickConnection = sendButton.MouseButton1Click:Connect(function()
    local metin = textBox.Text
    if metin ~= "" then
        pcall(function()
            local textChatService = game:GetService("TextChatService")
            if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local channels = textChatService:WaitForChild("TextChannels", 2)
                if channels then
                    local generalChannel = channels:FindFirstChild("RBXGeneral")
                    if generalChannel then
                        generalChannel:SendAsync(metin)
                        return
                    end
                end
            end
            
            local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents", true)
            if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
                chatRemote.SayMessageRequest:FireServer(metin, "All")
            end
        end)
    end
end)

-- Yok etme bağlantısı
closeButton.MouseButton1Click:Connect(function()
    if clickConnection then
        clickConnection:Disconnect()
    end
    screenGui:Destroy()
end)
