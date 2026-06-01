-- LocalScript → StarterPlayer > StarterPlayerScripts
-- Works best with Delta Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- Settings
local aimbotEnabled = false
local silentAimEnabled = false
local triggerbotEnabled = false
local targetLockEnabled = false
local autoPlayEnabled = false
local antiAimEnabled = false
local teamCheckEnabled = true

local fov = 120
local smoothness = 0.25
local antiAimMode = "Spin" -- Spin, Jitter, Random

local currentTarget = nil
local drawings = {}

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 580)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -290)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "Private Test Menu - Delta"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Toggle Creator
local function createToggle(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 42)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextScaled = true
    btn.Parent = mainFrame
    Instance.new("UICorner", btn)
    return btn
end

local aimbotBtn = createToggle("Aimbot", 60)
local silentBtn = createToggle("Silent Aim", 110)
local triggerBtn = createToggle("Triggerbot", 160)
local lockBtn = createToggle("Target Lock", 210)
local teamBtn = createToggle("Team Check", 260)
local autoBtn = createToggle("Auto Play", 310)
local antiAimBtn = createToggle("Anti-Aim", 360)

-- Anti-Aim Mode Buttons
local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(0.9, 0, 0, 50)
modeFrame.Position = UDim2.new(0.05, 0, 0, 410)
modeFrame.BackgroundTransparency = 1
modeFrame.Parent = mainFrame

local spinBtn = Instance.new("TextButton")
spinBtn.Size = UDim2.new(0.3, 0, 1, 0)
spinBtn.Position = UDim2.new(0, 0, 0, 0)
spinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
spinBtn.Text = "Spin"
spinBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
spinBtn.Font = Enum.Font.Gotham
spinBtn.TextScaled = true
spinBtn.Parent = modeFrame
Instance.new("UICorner", spinBtn)

local jitterBtn = Instance.new("TextButton")
jitterBtn.Size = UDim2.new(0.3, 0, 1, 0)
jitterBtn.Position = UDim2.new(0.35, 0, 0, 0)
jitterBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
jitterBtn.Text = "Jitter"
jitterBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
jitterBtn.Font = Enum.Font.Gotham
jitterBtn.TextScaled = true
jitterBtn.Parent = modeFrame
Instance.new("UICorner", jitterBtn)

local randomBtn = Instance.new("TextButton")
randomBtn.Size = UDim2.new(0.3, 0, 1, 0)
randomBtn.Position = UDim2.new(0.7, 0, 0, 0)
randomBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
randomBtn.Text = "Random"
randomBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
randomBtn.Font = Enum.Font.Gotham
randomBtn.TextScaled = true
randomBtn.Parent = modeFrame
Instance.new("UICorner", randomBtn)

-- Sliders (FOV & Smoothness)
local function createSlider(name, yPos, min, max, def)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 65)
    frame.Position = UDim2.new(0.05, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = mainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,22)
    label.Text = name .. ": " .. def
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200,200,200)
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,0,0,10)
    bar.Position = UDim2.new(0,0,0,40)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,45)
    bar.Parent = frame
    Instance.new("UICorner", bar)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    fill.Parent = bar
    Instance.new("UICorner", fill)

    return {label=label, fill=fill, value=def}
end

local fovSlider = createSlider("FOV", 470, 30, 400, fov)
local smoothSlider = createSlider("Smoothness", 540, 0.05, 1, smoothness)

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn)

-- Keybind
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Button Functions
aimbotBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
    aimbotBtn.TextColor3 = aimbotEnabled and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,80,80)
end)

silentBtn.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    silentBtn.Text = "Silent Aim: " .. (silentAimEnabled and "ON" or "OFF")
end)

triggerBtn.MouseButton1Click:Connect(function()
    triggerbotEnabled = not triggerbotEnabled
    triggerBtn.Text = "Triggerbot: " .. (triggerbotEnabled and "ON" or "OFF")
end)

lockBtn.MouseButton1Click:Connect(function()
    targetLockEnabled = not targetLockEnabled
    lockBtn.Text = "Target Lock: " .. (targetLockEnabled and "ON" or "OFF")
end)

teamBtn.MouseButton1Click:Connect(function()
    teamCheckEnabled = not teamCheckEnabled
    teamBtn.Text = "Team Check: " .. (teamCheckEnabled and "ON" or "OFF")
end)

autoBtn.MouseButton1Click:Connect(function()
    autoPlayEnabled = not autoPlayEnabled
    autoBtn.Text = "Auto Play: " .. (autoPlayEnabled and "ON" or "OFF")
end)

antiAimBtn.MouseButton1Click:Connect(function()
    antiAimEnabled = not antiAimEnabled
    antiAimBtn.Text = "Anti-Aim: " .. (antiAimEnabled and "ON" or "OFF")
    antiAimBtn.TextColor3 = antiAimEnabled and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(255,80,80)
end)

-- Mode Selection
spinBtn.MouseButton1Click:Connect(function() antiAimMode = "Spin" end)
jitterBtn.MouseButton1Click:Connect(function() antiAimMode = "Jitter" end)
randomBtn.MouseButton1Click:Connect(function() antiAimMode = "Random" end)

closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

-- ESP (same as before)
local function createESP(plr)
    if plr == player then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = Color3.fromRGB(255, 50, 50)
    box.Transparency = 1

    local name = Drawing.new("Text")
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255,255,255)

    drawings[plr] = {box = box, name = name}
end

for _, plr in pairs(Players:GetPlayers()) do createESP(plr) end
Players.PlayerAdded:Connect(createESP)

-- Get Closest Player (same logic)
local function getClosestPlayer()
    local closest, dist = nil, fov
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
            if teamCheckEnabled and plr.Team == player.Team then continue end
            local head = plr.Character.Head
            local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if mouseDist < dist then
                    dist = mouseDist
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- Anti-Aim Logic
local antiAimConnection
antiAimConnection = RunService.RenderStepped:Connect(function()
    if not antiAimEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local root = player.Character.HumanoidRootPart
    local currentCFrame = root.CFrame

    if antiAimMode == "Spin" then
        root.CFrame = currentCFrame * CFrame.Angles(0, math.rad(25), 0) -- Spin speed
    elseif antiAimMode == "Jitter" then
        local jitter = math.random(-35, 35)
        root.CFrame = currentCFrame * CFrame.Angles(0, math.rad(jitter), 0)
    elseif antiAimMode == "Random" then
        if math.random(1, 8) == 1 then
            root.CFrame = currentCFrame * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
        end
    end
end)

-- Main Aimbot Loop
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end

    local target = targetLockEnabled and currentTarget or getClosestPlayer()

    if target and target.Character and target.Character:FindFirstChild("Head") then
        currentTarget = target
        local headPos = camera:WorldToScreenPoint(target.Character.Head.Position)

        if silentAimEnabled then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Character.Head.Position)
        else
            local current = Vector2.new(mouse.X, mouse.Y)
            local targetVec = Vector2.new(headPos.X, headPos.Y)
            local newPos = current:Lerp(targetVec, smoothness)
            mousemoverel(newPos.X - current.X, newPos.Y - current.Y)
        end
    end
end)

-- Triggerbot + Auto Play + ESP (same as previous version)
RunService.Heartbeat:Connect(function()
    if triggerbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character then
            local dist = (target.Character.Head.Position - camera.CFrame.Position).Magnitude
            if dist < 180 then
                mouse1click()
                task.wait(0.07)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if autoPlayEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        local root = player.Character.HumanoidRootPart
        local closest = getClosestPlayer()

        if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = closest.Character.HumanoidRootPart
            local dir = (targetRoot.Position - root.Position).Unit
            root.CFrame = CFrame.lookAt(root.Position, targetRoot.Position)
            humanoid:Move(dir, false)

            if (targetRoot.Position - root.Position).Magnitude < 12 then
                mouse1click()
            end
        end
    end
end)

-- ESP Loop
RunService.RenderStepped:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        local esp = drawings[plr]
        if esp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head")
            local humanoid = plr.Character:FindFirstChild("Humanoid")

            local pos, onScreen = camera:WorldToViewportPoint(root.Position)
            if onScreen and head then
                local top = camera:WorldToViewportPoint(head.Position + Vector3.new(0,2.5,0))
                local bottom = camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                local height = bottom.Y - top.Y
                local width = height * 0.6

                esp.box.Size = Vector2.new(width, height)
                esp.box.Position = Vector2.new(top.X - width/2, top.Y)
                esp.box.Visible = true

                esp.name.Text = plr.Name .. " [" .. (humanoid and math.floor(humanoid.Health) or 0) .. "]"
                esp.name.Position = Vector2.new(top.X, top.Y - 20)
                esp.name.Visible = true
            else
                esp.box.Visible = false
                esp.name.Visible = false
            end
        elseif esp then
            esp.box.Visible = false
            esp.name.Visible = false
        end
    end
end)

print("✅ Full Menu Loaded (Delta) | Press Right Shift")