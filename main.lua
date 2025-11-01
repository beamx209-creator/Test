-- main.lua (Juju-like GUI, Aimlock, Speed, Commands)
-- วางเป็น LocalScript ใน StarterPlayerScripts หรือรันผ่าน loadstring จาก raw URL

-- ==========================
-- SETTINGS / COMMAND TABLE
-- ==========================
getgenv().ScriptSettings = getgenv().ScriptSettings or {
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

getgenv().ScriptCommands = getgenv().ScriptCommands or {
    ["Fix Script"] = "fix",
    ["Reset Stand"] = "reset",
    ["Ascend"] = "summon",
    ["Descend"] = "vanish",
    ["Kill Player"] = "kill",
    ["Teleport Player"] = "tp",
    ["Auto Heal"] = "aheal",
    ["Auto Armor"] = "aarmor",
}

-- ==========================
-- BASE REFERENCES
-- ==========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================
-- STATE
-- ==========================
local settings = {
    aimlockEnabled = false,
    aimTargetPart = "Head",
    aimSmooth = false,
    aimFOV = 120, -- not used visually, only as placeholder
    speedEnabled = false,
    walkSpeed = 16,
    runSpeed = 32,
}

-- ==========================
-- UTILS
-- ==========================
local function make(instanceType, props)
    local inst = Instance.new(instanceType)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

-- ==========================
-- GUI (Juju-like)
-- ==========================
local ScreenGui = make("ScreenGui", {Name = "JujuScriptGUI", ResetOnSpawn = false, Parent = playerGui})

-- Main Window
local Main = make("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 420, 0, 320),
    Position = UDim2.new(0.5, -210, 0.5, -160),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    Parent = ScreenGui,
})

-- UI Corner & Stroke
make("UICorner", {CornerRadius = UDim.new(0,8), Parent = Main})
make("UIStroke", {Color = Color3.fromRGB(60,60,70), Thickness = 1, Parent = Main})

-- Top bar
local TopBar = make("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1,0,0,34),
    BackgroundColor3 = Color3.fromRGB(16,16,16),
    Parent = Main,
})
make("UICorner", {CornerRadius = UDim.new(0,8), Parent = TopBar})

local Title = make("TextLabel", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0,12,0,0),
    BackgroundTransparency = 1,
    Text = "JujuScript",
    TextColor3 = Color3.fromRGB(220,220,220),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})

-- Toggle hotkey hint
local HotkeyLabel = make("TextLabel", {
    Size = UDim2.new(0, 80, 1, 0),
    Position = UDim2.new(1,-90,0,0),
    BackgroundTransparency = 1,
    Text = "[RCTRL]",
    TextColor3 = Color3.fromRGB(160,160,160),
    Font = Enum.Font.Gotham,
    TextSize = 12,
    Parent = TopBar,
})

-- Close / Minimize
local MinBtn = make("TextButton", {
    Size = UDim2.new(0, 28, 0, 24),
    Position = UDim2.new(1, -52, 0, 5),
    Text = "—",
    BackgroundColor3 = Color3.fromRGB(30,30,30),
    TextColor3 = Color3.fromRGB(200,200,200),
    Font = Enum.Font.Gotham,
    TextSize = 18,
    Parent = TopBar,
})
local CloseBtn = make("TextButton", {
    Size = UDim2.new(0, 28, 0, 24),
    Position = UDim2.new(1, -24, 0, 5),
    Text = "✕",
    BackgroundColor3 = Color3.fromRGB(30,30,30),
    TextColor3 = Color3.fromRGB(200,200,200),
    Font = Enum.Font.Gotham,
    TextSize = 16,
    Parent = TopBar,
})

-- Left tab list
local Left = make("Frame", {
    Size = UDim2.new(0, 120, 1, -34),
    Position = UDim2.new(0, 0, 0, 34),
    BackgroundColor3 = Color3.fromRGB(18,18,18),
    Parent = Main,
})
make("UICorner", {CornerRadius = UDim.new(0,6), Parent = Left})

local Tabs = {"Aimlock", "Movement", "Commands"}
local TabButtons = {}
local ContentFrames = {}

for i, name in ipairs(Tabs) do
    local btn = make("TextButton", {
        Size = UDim2.new(1, -10, 0, 38),
        Position = UDim2.new(0, 5, 0, 8 + (i-1)*44),
        Text = name,
        BackgroundColor3 = Color3.fromRGB(28,28,28),
        TextColor3 = Color3.fromRGB(210,210,210),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = Left,
    })
    make("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})
    TabButtons[name] = btn

    local content = make("Frame", {
        Size = UDim2.new(1, -130, 1, -44),
        Position = UDim2.new(0, 130, 0, 44),
        BackgroundColor3 = Color3.fromRGB(14,14,14),
        Visible = (i==1),
        Parent = Main,
    })
    make("UICorner", {CornerRadius = UDim.new(0,6), Parent = content})
    ContentFrames[name] = content

    btn.MouseButton1Click:Connect(function()
        for k,v in pairs(ContentFrames) do v.Visible = false end
        content.Visible = true
        -- visual selection
        for k,b in pairs(TabButtons) do b.BackgroundColor3 = Color3.fromRGB(28,28,28) end
        btn.BackgroundColor3 = Color3.fromRGB(45,45,55)
    end)
end

-- make first tab highlighted
TabButtons["Aimlock"].BackgroundColor3 = Color3.fromRGB(45,45,55)

-- ==========================
-- Populate Aimlock Tab
-- ==========================
local aimFrame = ContentFrames["Aimlock"]

local aimToggle = make("TextButton", {
    Size = UDim2.new(0, 170, 0, 36),
    Position = UDim2.new(0, 12, 0, 12),
    Text = "Aimlock: OFF",
    BackgroundColor3 = Color3.fromRGB(40,40,40),
    TextColor3 = Color3.fromRGB(230,230,230),
    Font = Enum.Font.Gotham,
    TextSize = 14,
    Parent = aimFrame,
})
make("UICorner", {CornerRadius = UDim.new(0,6), Parent = aimToggle})

aimToggle.MouseButton1Click:Connect(function()
    settings.aimlockEnabled = not settings.aimlockEnabled
    aimToggle.Text = "Aimlock: " .. (settings.aimlockEnabled and "ON" or "OFF")
end)

local targetBtn = make("TextButton", {
    Size = UDim2.new(0, 120, 0, 28),
    Position = UDim2.new(0, 12, 0, 58),
    Text = "Target: Head",
    BackgroundColor3 = Color3.fromRGB(35,35,35),
    TextColor3 = Color3.fromRGB(210,210,210),
    Font = Enum.Font.Gotham,
    TextSize = 13,
    Parent = aimFrame,
})
make("UICorner", {CornerRadius = UDim.new(0,6), Parent = targetBtn})
targetBtn.MouseButton1Click:Connect(function()
    settings.aimTargetPart = (settings.aimTargetPart == "Head") and "HumanoidRootPart" or "Head"
    targetBtn.Text = "Target: " .. (settings.aimTargetPart == "Head" and "Head" or "Body")
end)

local smoothToggle = make("TextButton", {
    Size = UDim2.new(0, 120, 0, 28),
    Position = UDim2.new(0, 150, 0, 58),
    Text = "Smooth: OFF",
    BackgroundColor3 = Color3.fromRGB(35,35,35),
    TextColor3 = Color3.fromRGB(210,210,210),
    Font = Enum.Font.Gotham,
    TextSize = 13,
    Parent = aimFrame,
})
make("UICorner", {CornerRadius = UDim.new(0,6), Parent = smoothToggle})
smoothToggle.MouseButton1Click:Connect(function()
    settings.aimSmooth = not settings.aimSmooth
    smoothToggle.Text = "Smooth: " .. (settings.aimSmooth and "ON" or "OFF")
end)

-- ==========================
-- Populate Movement Tab
-- ==========================
local moveFrame = ContentFrames["Movement"]

local speedToggle = make("TextButton", {
    Size = UDim2.new(0, 140, 0, 36),
    Position = UDim2.new(0, 12, 0, 12),
    Text = "Speed: OFF",
    BackgroundColor3 = Color3.fromRGB(40,40,40),
    TextColor3 = Color3.fromRGB(230,230,230),
    Font = Enum.Font.Gotham,
    TextSize = 14,
    Parent = moveFrame,
})
make("UICorner", {CornerRadius = UDim.new(0,6), Parent = speedToggle})

speedToggle.MouseButton1Click:Connect(function()
    settings.speedEnabled = not settings.speedEnabled
    speedToggle.Text = "Speed: " .. (settings.speedEnabled and "ON" or "OFF")
end)

-- WalkSpeed input
local walkBox = make("TextBox", {
    Size = UDim2.new(0, 140, 0, 28),
    Position = UDim2.new(0, 12, 0, 60),
    Text = tostring(settings.walkSpeed),
    PlaceholderText = "WalkSpeed",
    BackgroundColor3 = Color3.fromRGB(35,35,35),
    TextColor3 = Color3.fromRGB(230,230,230),
    Font = Enum.Font.Gotham,
    TextSize = 14,
    Parent = moveFrame,
})
make("UICorner", {CornerRadius = UDim.new(0,6), Parent = walkBox})
walkBox.FocusLost:Connect(function(enter)
    local v = tonumber(walkBox.Text)
    if v then settings.walkSpeed = clamp(v, 8, 200) end
    walkBox.Text = tostring(settings.walkSpeed)
end)

local runBox = make("TextBox", {
    Size = UDim2.new(0, 140, 0, 28),
    Position = UDim2.new(0, 160, 0, 60),
    Text = tostring(settings.runSpeed),
    PlaceholderText = "RunSpeed",
    BackgroundColor3 = Color3.fromRGB(35,35,35),
    TextColor3 = Color3.fromRGB(230,230,230),
    Font = Enum.Font.Gotham,
    TextSize = 14,
    Parent = moveFrame,
})
make("UICorner", {CornerRadius = UDim.new(0,6), Parent = runBox})
runBox.FocusLost:Connect(function()
    local v = tonumber(runBox.Text)
    if v then settings.runSpeed = clamp(v, 16, 500) end
    runBox.Text = tostring(settings.runSpeed)
end)

-- ==========================
-- Populate Commands Tab
-- ==========================
local cmdFrame = ContentFrames["Commands"]
local y = 12
for name, cmd in pairs(getgenv().ScriptCommands) do
    local b = make("TextButton", {
        Size = UDim2.new(0, 260, 0, 28),
        Position = UDim2.new(0, 12, 0, y),
        Text = name,
        BackgroundColor3 = Color3.fromRGB(36,36,36),
        TextColor3 = Color3.fromRGB(230,230,230),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Parent = cmdFrame,
    })
    make("UICorner", {CornerRadius = UDim.new(0,6), Parent = b})
    b.MouseButton1Click:Connect(function()
        local full = (getgenv().ScriptSettings.Configs.Prefix or ".") .. cmd
        print("[JujuScript] Executing:", full)
        -- ตัวอย่าง: แทนที่ print ด้วย RemoteEvent call ของเกมได้เลย
        -- game.ReplicatedStorage.Remotes.Command:FireServer(full)
    end)
    y = y + 36
end

-- ==========================
-- Draggable
-- ==========================
local dragging = false
local dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInput.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Minimize / Close
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in pairs(Main:GetChildren()) do
        if child ~= TopBar then
            child.Visible = not minimized
        end
    end
    MinBtn.Text = minimized and "+" or "—"
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui.Enabled = false end)

-- Toggle key (RightControl)
UserInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- ==========================
-- AIMLOCK CORE
-- ==========================
local function getClosestTarget(partName)
    local closest = nil
    local minDist = math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character.Parent and plr.Character:FindFirstChild(partName) then
            local part = plr.Character[partName]
            local camPos = workspace.CurrentCamera.CFrame.Position
            local dist = (part.Position - camPos).Magnitude
            if dist < minDist then
                minDist = dist
                closest = part
            end
        end
    end
    return closest
end

local lastCFrame = workspace.CurrentCamera.CFrame
RunService.RenderStepped:Connect(function(dt)
    -- Aimlock
    if settings.aimlockEnabled then
        local targetPartName = settings.aimTargetPart == "Head" and "Head" or "HumanoidRootPart"
        local target = getClosestTarget(targetPartName)
        if target and workspace.CurrentCamera then
            local camPos = workspace.CurrentCamera.CFrame.Position
            local newCF = CFrame.new(camPos, target.Position)
            if settings.aimSmooth then
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(newCF, clamp(dt * 12, 0, 1))
            else
                workspace.CurrentCamera.CFrame = newCF
            end
        end
    end

    -- Speed
    if settings.speedEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        hum.WalkSpeed = settings.runSpeed
    elseif player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = settings.walkSpeed
    end
end)

-- ==========================
-- INIT: ensure GUI visible and settings synced
-- ==========================
-- sync GUI texts
aimToggle.Text = "Aimlock: " .. (settings.aimlockEnabled and "ON" or "OFF")
speedToggle.Text = "Speed: " .. (settings.speedEnabled and "ON" or "OFF")
targetBtn.Text = "Target: " .. (settings.aimTargetPart == "Head" and "Head" or "Body")
smoothToggle.Text = "Smooth: " .. (settings.aimSmooth and "ON" or "OFF")

print("[JujuScript] Loaded. Toggle GUI with RightControl.")