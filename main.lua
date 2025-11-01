-- main.lua
-- GUI + Aimlock + Speed แบบแท็บครบระบบ

-- ==============================
-- SETTINGS
-- ==============================
local settings = {
    -- AIMLOCK
    aimlockEnabled = false,
    aimTargetPart = "Head", -- Head / Body

    -- SPEED
    speedEnabled = false,
    walkSpeed = 16,
    runSpeed = 32,
}

-- ==============================
-- LOAD PLAYER
-- ==============================
local player = game.Players.LocalPlayer

-- ==============================
-- GUI
-- ==============================
local GuiLib = {}
function GuiLib:Create(settings)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MyScriptGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- Main Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 250)
    frame.Position = UDim2.new(0, 50, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    -- Tab Buttons
    local tabs = {"Aimlock", "Speed"} -- เพิ่ม Tab ได้ในอนาคต
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

    -- ==============================
    -- Aimlock Tab
    -- ==============================
    local aimFrame = Instance.new("Frame")
    aimFrame.Size = UDim2.new(0, 280, 0, 180)
    aimFrame.Position = UDim2.new(0, 10, 0, 50)
    aimFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    aimFrame.Visible = true
    aimFrame.Parent = frame
    tabFrames["Aimlock"] = aimFrame

    -- Aimlock Toggle
    local aimToggle = Instance.new("TextButton")
    aimToggle.Size = UDim2.new(0, 250, 0, 30)
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
    targetBtn.Size = UDim2.new(0, 250, 0, 30)
    targetBtn.Position = UDim2.new(0, 15, 0, 50)
    targetBtn.Text = "Target: Head"
    targetBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    targetBtn.TextColor3 = Color3.fromRGB(255,255,255)
    targetBtn.Parent = aimFrame
    targetBtn.MouseButton1Click:Connect(function()
        settings.aimTargetPart = settings.aimTargetPart == "Head" and "Body" or "Head"
        targetBtn.Text = "Target: " .. settings.aimTargetPart
    end)

    -- ==============================
    -- Speed Tab
    -- ==============================
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(0, 280, 0, 180)
    speedFrame.Position = UDim2.new(0, 10, 0, 50)
    speedFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    speedFrame.Visible = false
    speedFrame.Parent = frame
    tabFrames["Speed"] = speedFrame

    -- Speed Toggle
    local speedToggle = Instance.new("TextButton")
    speedToggle.Size = UDim2.new(0, 250, 0, 30)
    speedToggle.Position = UDim2.new(0, 15, 0, 10)
    speedToggle.Text = "Speed: OFF"
    speedToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
    speedToggle.TextColor3 = Color3.fromRGB(255,255,255)
    speedToggle.Parent = speedFrame
    speedToggle.MouseButton1Click:Connect(function()
        settings.speedEnabled = not settings.speedEnabled
        speedToggle.Text = "Speed: " .. (settings.speedEnabled and "ON" or "OFF")
    end)

    -- WalkSpeed Input
    local walkInput = Instance.new("TextBox")
    walkInput.Size = UDim2.new(0, 250, 0, 30)
    walkInput.Position = UDim2.new(0, 15, 0, 50)
    walkInput.Text = tostring(settings.walkSpeed)
    walkInput.BackgroundColor3 = Color3.fromRGB(60,60,60)
    walkInput.TextColor3 = Color3.fromRGB(255,255,255)
    walkInput.PlaceholderText = "Walk Speed"
    walkInput.Parent = speedFrame
    walkInput.FocusLost:Connect(function()
        local val = tonumber(walkInput.Text)
        if val then settings.walkSpeed = val end
        walkInput.Text = tostring(settings.walkSpeed)
    end)

    -- RunSpeed Input
    local runInput = Instance.new("TextBox")
    runInput.Size = UDim2.new(0, 250, 0, 30)
    runInput.Position = UDim2.new(0, 15, 0, 90)
    runInput.Text = tostring(settings.runSpeed)
    runInput.BackgroundColor3 = Color3.fromRGB(60,60,60)
    runInput.TextColor3 = Color3.fromRGB(255,255,255)
    runInput.PlaceholderText = "Run Speed"
    runInput.Parent = speedFrame
    runInput.FocusLost:Connect(function()
        local val = tonumber(runInput.Text)
        if val then settings.runSpeed = val end
        runInput.Text = tostring(settings.runSpeed)
    end)
end

-- ==============================
-- AIMLOCK FUNCTIONS
-- ==============================
local Aimlock = {}

function Aimlock:GetClosestTarget()
    local closest = nil
    local minDist = math.huge
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char and char:FindFirstChild(settings.aimTargetPart) then
                local dist = (char[settings.aimTargetPart].Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = char[settings.aimTargetPart]
                end
            end
        end
    end
    return closest
end

function Aimlock:Update()
    if settings.aimlockEnabled then
        local target = self:GetClosestTarget()
        if target then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
        end
    end
end

-- ==============================
-- SPEED FUNCTIONS
-- ==============================
local Speed = {}

function Speed:Update()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        if settings.speedEnabled then
            humanoid.WalkSpeed = settings.runSpeed
        else
            humanoid.WalkSpeed = settings.walkSpeed
        end
    end
end

-- ==============================
-- RUN GUI + MAIN LOOP
-- ==============================
GuiLib:Create(settings)

game:GetService("RunService").RenderStepped:Connect(function()
    Aimlock:Update()
    Speed:Update()
end)