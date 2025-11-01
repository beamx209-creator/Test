-- main.lua
-- Script ต้นแบบ Lua สำหรับเกม HITBOX

-- Modules
local GuiLib = {} -- โค้ด GUI ตรงนี้สามารถต่อยอดได้
local Aimlock = {}
local Speed = {}

----------------------------
-- SETTINGS
----------------------------
local settings = {
    aimlockEnabled = false,
    aimTargetPart = "Head", -- Head หรือ Body
    speedEnabled = false,
    walkSpeed = 16,
    runSpeed = 32,
}

----------------------------
-- AIMLOCK MODULE
----------------------------
function Aimlock:GetClosestTarget()
    -- โค้ดนี้เป็นตัวอย่าง สามารถปรับใช้กับ Hitbox ของเกมคุณ
    local closest = nil
    local minDist = math.huge
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local char = player.Character
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
            -- เล็งไปที่ target
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
        end
    end
end

----------------------------
-- SPEED MODULE
----------------------------
function Speed:Update()
    if settings.speedEnabled then
        local plr = game.Players.LocalPlayer
        if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.WalkSpeed = settings.runSpeed
        end
    else
        local plr = game.Players.LocalPlayer
        if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.WalkSpeed = settings.walkSpeed
        end
    end
end

----------------------------
-- GUI MODULE
----------------------------
function GuiLib:Create()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MyScriptGUI"
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 150)
    Frame.Position = UDim2.new(0, 50, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.Parent = ScreenGui

    -- Aimlock Toggle
    local AimToggle = Instance.new("TextButton")
    AimToggle.Size = UDim2.new(0, 180, 0, 30)
    AimToggle.Position = UDim2.new(0, 10, 0, 10)
    AimToggle.Text = "Aimlock: OFF"
    AimToggle.Parent = Frame
    AimToggle.MouseButton1Click:Connect(function()
        settings.aimlockEnabled = not settings.aimlockEnabled
        AimToggle.Text = "Aimlock: " .. (settings.aimlockEnabled and "ON" or "OFF")
    end)

    -- Target Part Dropdown (Head / Body)
    local TargetButton = Instance.new("TextButton")
    TargetButton.Size = UDim2.new(0, 180, 0, 30)
    TargetButton.Position = UDim2.new(0, 10, 0, 50)
    TargetButton.Text = "Target: Head"
    TargetButton.Parent = Frame
    TargetButton.MouseButton1Click:Connect(function()
        settings.aimTargetPart = settings.aimTargetPart == "Head" and "Body" or "Head"
        TargetButton.Text = "Target: " .. settings.aimTargetPart
    end)

    -- Speed Toggle
    local SpeedToggle = Instance.new("TextButton")
    SpeedToggle.Size = UDim2.new(0, 180, 0, 30)
    SpeedToggle.Position = UDim2.new(0, 10, 0, 90)
    SpeedToggle.Text = "Speed: OFF"
    SpeedToggle.Parent = Frame
    SpeedToggle.MouseButton1Click:Connect(function()
        settings.speedEnabled = not settings.speedEnabled
        SpeedToggle.Text = "Speed: " .. (settings.speedEnabled and "ON" or "OFF")
    end)
end

----------------------------
-- MAIN LOOP
----------------------------
GuiLib:Create()

game:GetService("RunService").RenderStepped:Connect(function()
    Aimlock:Update()
    Speed:Update()
end)