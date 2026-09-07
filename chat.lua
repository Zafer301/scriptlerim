-- Ekran butonunu ve arkadaki tüm işlemleri tamamen sonlandıran script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Yazdırmak istediğin metni buraya yaz
local gonderilecekMesaj = "Buraya chate gitmesini istedigin yaziyi yaz"

-- GUI Oluşturma
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChatAparati"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 140, 0, 90)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

local textButton = Instance.new("TextButton")
textButton.Size = UDim2.new(0, 140, 0, 50)
textButton.Position = UDim2.new(0, 0, 0, 0)
textButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
textButton.TextSize = 16
textButton.Text = "Mesajı Gönder"
textButton.Parent = mainFrame

local uiCorner1 = Instance.new("UICorner")
uiCorner1.CornerRadius = UDim.new(0, 8)
uiCorner1.Parent = textButton

-- Kapatma / Yok Etme Butonu
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 140, 0, 30)
closeButton.Position = UDim2.new(0, 0, 0, 60)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Text = "Tamamen Yok Et"
closeButton.Parent = mainFrame

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, 8)
uiCorner2.Parent = closeButton

-- Mesaj gönderme bağlantısı
local clickConnection
clickConnection = textButton.MouseButton1Click:Connect(function()
    pcall(function()
        local textChatService = game:GetService("TextChatService")
        if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channels = textChatService:WaitForChild("TextChannels", 2)
            if channels then
                local generalChannel = channels:FindFirstChild("RBXGeneral")
                if generalChannel then
                    generalChannel:SendAsync(gonderilecekMesaj)
                    return
                end
            end
        end
        
        local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents", true)
        if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
            chatRemote.SayMessageRequest:FireServer(gonderilecekMesaj, "All")
        end
    end)
end)

-- Butona basıldığında arayüzü siler ve arka plandaki tüm döngü/bağlantıları tamamen yok eder
closeButton.MouseButton1Click:Connect(function()
    if clickConnection then
        clickConnection:Disconnect() -- Tıklama olayını bellekten siler
    end
    screenGui:Destroy() -- Ekrandaki her şeyi ve arayüzü tamamen yok eder
end)
