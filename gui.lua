local GuiLib = {}

function GuiLib:Create(settings)
    local player = game.Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MyScriptGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 200)
    frame.Position = UDim2.new(0, 50, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.Parent = screenGui

    -- Tab Buttons
    local tabs = {"Aimlock"}
    local tabFrames = {}
    local selectedTab = "Aimlock"

    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 30)
        btn.Position = UDim2.new(0, 10 + (i-1)*110, 0, 10)
        btn.Text = tabName
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Parent = frame

        btn.MouseButton1Click:Connect(function()
            selectedTab = tabName
            for name, f in pairs(tabFrames) do
                f.Visible = (name == selectedTab)
            end
        end)
    end

    -- Aimlock Tab Frame
    local aimFrame = Instance.new("Frame")
    aimFrame.Size = UDim2.new(0, 230, 0, 120)
    aimFrame.Position = UDim2.new(0, 10, 0, 50)
    aimFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    aimFrame.Visible = true
    aimFrame.Parent = frame
    tabFrames["Aimlock"] = aimFrame

    -- Aimlock Toggle
    local aimToggle = Instance.new("TextButton")
    aimToggle.Size = UDim2.new(0, 200, 0, 30)
    aimToggle.Position = UDim2.new(0, 15, 0, 10)
    aimToggle.Text = "Aimlock: OFF"
    aimToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
    aimToggle.TextColor3 = Color3.fromRGB(255,255,255)
    aimToggle.Parent = aimFrame
    aimToggle.MouseButton1Click:Connect(function()
        settings.aimlockEnabled = not settings.aimlockEnabled
        aimToggle.Text = "Aimlock: " .. (settings.aimlockEnabled and "ON" or "OFF")
    end)

    -- Target Part Toggle
    local targetBtn = Instance.new("TextButton")
    targetBtn.Size = UDim2.new(0, 200, 0, 30)
    targetBtn.Position = UDim2.new(0, 15, 0, 50)
    targetBtn.Text = "Target: Head"
    targetBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    targetBtn.TextColor3 = Color3.fromRGB(255,255,255)
    targetBtn.Parent = aimFrame
    targetBtn.MouseButton1Click:Connect(function()
        settings.aimTargetPart = settings.aimTargetPart == "Head" and "Body" or "Head"
        targetBtn.Text = "Target: " .. settings.aimTargetPart
    end)
end

return GuiLib