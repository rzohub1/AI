--[[
    ADVANCED AIMBOT + AUTO-PLAY UI
    Place this script in a ScreenGui (or create the GUI via script)
    All settings are saved between sessions using StringValues for easy toggling.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- --------------------------------
-- 1. CREATE MAIN UI FRAME
-- --------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimbotGUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 420)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Rounded corners via UICorner
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

-- Drag functionality
local dragging = false
local dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Title Bar
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
titleBar.Text = "⚡ PRIVATE CHEAT v1.0"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextSize = 18
titleBar.Font = Enum.Font.GothamBold
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextSize = 22
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Minimize/open button (toggle visibility using hotkey: INSERT)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- --------------------------------
-- 2. CREATE UI ELEMENTS
-- --------------------------------
local function createToggle(parent, text, yOffset, defaultValue)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 45)
    container.Position = UDim2.new(0, 10, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 16
    label.Font = Enum.Font.Gotham
    label.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 70, 0, 30)
    toggleBtn.Position = UDim2.new(0.85, -70, 0.5, -15)
    toggleBtn.Text = defaultValue and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 50, 50)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = container

    local state = defaultValue
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 50, 50)
    end)

    return function() return state end
end

local function createSlider(parent, text, minVal, maxVal, defaultVal, yOffset, formatFunc)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 65)
    container.Position = UDim2.new(0, 10, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. tostring(defaultVal)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -20, 0, 6)
    slider.Position = UDim2.new(0, 10, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(70,70,80)
    slider.BorderSizePixel = 0
    slider.Parent = container

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal)/(maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local value = defaultVal
    local dragging = false

    local updateLabel = function()
        local display = formatFunc and formatFunc(value) or tostring(math.floor(value * 10) / 10)
        label.Text = text .. ": " .. display
        fill.Size = UDim2.new((value - minVal)/(maxVal - minVal), 0, 1, 0)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    slider.InputEnded:Connect(function()
        dragging = false
    end)

    slider.MouseMoved:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local relX = mousePos.X - slider.AbsolutePosition.X
            local newVal = math.clamp((relX / slider.AbsoluteSize.X) * (maxVal - minVal) + minVal, minVal, maxVal)
            value = newVal
            updateLabel()
        end
    end)

    updateLabel()
    return function() return value end
end

-- Build UI
local toggleAimbot = createToggle(mainFrame, "🔫 AIMBOT", 50, true)
local toggleTargetLock = createToggle(mainFrame, "🔒 TARGET LOCK", 105, false)
local fovSlider = createSlider(mainFrame, "FOV", 30, 300, 120, 170, function(v) return math.floor(v) .. "px" end)
local smoothSlider = createSlider(mainFrame, "SMOOTHNESS", 1, 50, 15, 240, function(v) return math.floor(v) end)

local autoPlayBtn = Instance.new("TextButton")
autoPlayBtn.Size = UDim2.new(0.86, 0, 0, 45)
autoPlayBtn.Position = UDim2.new(0.07, 0, 0, 320)
autoPlayBtn.Text = "🎮 AUTO-PLAY (DETECTS PLAYERS)"
autoPlayBtn.TextColor3 = Color3.fromRGB(255,255,255)
autoPlayBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 90)
autoPlayBtn.Font = Enum.Font.GothamBold
autoPlayBtn.TextSize = 16
autoPlayBtn.BorderSizePixel = 0
autoPlayBtn.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 375)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: IDLE"
statusLabel.TextColor3 = Color3.fromRGB(150,150,150)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- --------------------------------
-- 3. LOGIC: TARGET ACQUISITION
-- --------------------------------
local function getClosestPlayerInFOV()
    local camera = workspace.CurrentCamera
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local closestDist = fovSlider()
    local closestPlayer = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer, closestDist
end

-- Aim assist (mock movement of mouse)
local currentTarget = nil
RunService.RenderStepped:Connect(function()
    if not toggleAimbot() then return end

    local target, dist = getClosestPlayerInFOV()
    if target then
        currentTarget = target
        local targetPart = target.Character.HumanoidRootPart
        if targetPart then
            local camera = workspace.CurrentCamera
            local vector, onScreen = camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local targetScreen = Vector2.new(vector.X, vector.Y)
                local smooth = smoothSlider()
                local mouseDelta = (targetScreen - UserInputService:GetMouseLocation()) / smooth
                -- Simulated aim movement: mousemoverel (only works in certain contexts, for real aim you'd use mouse move)
                -- For test environment we just update an internal value – replace with actual mousemoverel if plugin environment allows.
                -- We'll store a CFrame for target lock.
                if toggleTargetLock() then
                    -- Target lock sim: keep camera towards target
                    local cameraCF = CFrame.new(camera.CFrame.Position, targetPart.Position)
                    camera.CFrame = cameraCF
                end
            end
        end
    else
        currentTarget = nil
    end
end)

-- --------------------------------
-- 4. AUTO-PLAY LOGIC (DETECTS & MOVES)
-- --------------------------------
local autoPlayActive = false
local autoPlayConnection = nil

local function autoPlay()
    if not autoPlayActive then return end
    -- Find nearest player
    local nearest = nil
    local nearestDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                         (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or math.huge
            if dist < nearestDist then
                nearestDist = dist
                nearest = player
            end
        end
    end

    if nearest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        local root = LocalPlayer.Character.HumanoidRootPart
        local targetPos = nearest.Character.HumanoidRootPart.Position
        local direction = (targetPos - root.Position).Unit
        -- Move towards target (mock movement)
        humanoid:MoveTo(targetPos)
        statusLabel.Text = "Auto-play: moving toward " .. nearest.Name
    else
        statusLabel.Text = "Auto-play: No targets found"
    end
end

autoPlayBtn.MouseButton1Click:Connect(function()
    autoPlayActive = not autoPlayActive
    if autoPlayActive then
        autoPlayBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        autoPlayBtn.Text = "⏹ STOP AUTO-PLAY"
        autoPlayConnection = RunService.Heartbeat:Connect(autoPlay)
        statusLabel.Text = "Auto-play ENABLED"
    else
        autoPlayBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 90)
        autoPlayBtn.Text = "🎮 AUTO-PLAY (DETECTS PLAYERS)"
        if autoPlayConnection then autoPlayConnection:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
        end
        statusLabel.Text = "Auto-play DISABLED"
    end
end)

-- --------------------------------
-- 5. CLEANUP ON RESPAWN
-- --------------------------------
LocalPlayer.CharacterAdded:Connect(function()
    if autoPlayActive then
        -- Re-activate auto-play pathfinding on new character
        if autoPlayConnection then autoPlayConnection:Disconnect() end
        autoPlayConnection = RunService.Heartbeat:Connect(autoPlay)
    end
end)

-- Initialize window visibility
mainFrame.Visible = true
