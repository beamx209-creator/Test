-- gui.lua
-- Module สำหรับสร้าง GUI เมนู

local GuiLib = {}

-- ต้องส่ง settings เข้ามาเพื่อเชื่อมกับฟีเจอร์อื่น
function GuiLib:Create(settings)
    local player = game.Players.LocalPlayer

    -- สร้าง ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MyScriptGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- Main Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 120)
    frame.Position = UDim2.new(0, 50, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    -- Aimlock Toggle Button
    local aimToggle = Instance.new("TextButton")
    aimToggle.Size = UDim2.new(0, 180, 0, 30)
    aimToggle.Position = UDim2.new(0, 10, 0, 10)
    aimToggle.Text = "Aimlock: OFF"
    aimToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    aimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimToggle.Parent = frame
    aimToggle.MouseButton1Click:Connect(function()
        settings.aimlockEnabled = not settings.aimlockEnabled
        aimToggle.Text = "Aimlock: " .. (settings.aimlockEnabled and "ON" or "OFF")
    end)

    -- Target Part Toggle Button (Head/Body)
    local targetButton = Instance.new("TextButton")
    targetButton.Size = UDim2.new(0, 180, 0, 30)
    targetButton.Position = UDim2.new(0, 10, 0, 50)
    targetButton.Text = "Target: Head"
    targetButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    targetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetButton.Parent = frame
    targetButton.MouseButton1Click:Connect(function()
        settings.aimTargetPart = settings.aimTargetPart == "Head" and "Body" or "Head"
        targetButton.Text = "Target: " .. settings.aimTargetPart
    end)

    -- Close GUI Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 180, 0, 30)
    closeButton.Position = UDim2.new(0, 10, 0, 90)
    closeButton.Text = "Close GUI"
    closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Parent = frame
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

return GuiLib