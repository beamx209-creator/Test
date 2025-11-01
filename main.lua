--[[-------------------------------------------------------
Main.lua - Example Script with GUI Toggle and Commands
---------------------------------------------------------]]

-- Global Settings
getgenv().ScriptSettings = {
    MainAccount = "lawakaitun5BD5",
    Configs = {
        Prefix = ".",
        Mask = "ninja",
        Gun = "ak47",
        Melee = "stop",
        FPSCap = 0,
        CameraOnMain = true,
    },
}

-- Command Table
getgenv().ScriptCommands = {
    ["Fix Script"] = "fix",
    ["Reset Stand"] = "reset",
    ["Ascend"] = "summon",
    ["Descend"] = "vanish",
    ["Kill Player"] = "kill",
    ["Teleport Player"] = "tp",
    ["Auto Heal"] = "aheal",
    ["Auto Armor"] = "aarmor",
    -- เพิ่มคำสั่งอื่น ๆ ได้ตามต้องการ
}

-- GUI Setup
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyScriptGUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Visible = true
mainFrame.Parent = screenGui

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Toggle GUI"
toggleButton.Parent = mainFrame

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 50)
title.Text = "Script Commands"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = mainFrame

-- Buttons for Commands
local yPos = 90
for name, cmd in pairs(getgenv().ScriptCommands) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = mainFrame

    btn.MouseButton1Click:Connect(function()
        print("Executing command:", getgenv().ScriptSettings.Configs.Prefix..cmd)
        -- ตัวอย่างการเรียก command (คุณสามารถแทนด้วย RemoteEvent ของเกมได้)
        -- game.ReplicatedStorage.Remotes.Command:FireServer(getgenv().ScriptSettings.Configs.Prefix..cmd)
    end)
    yPos = yPos + 30
end