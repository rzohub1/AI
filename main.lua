--[[
    ⚡ DELTA EXECUTOR - FIXED SCRIPT ⚡
    Menggunakan Native Roblox UI (PASTI MUNCUL)
    Fitur: Aimbot | ESP Tembus Tembok | Wallbang | Auto-Play
    Hotkey: INSERT to toggle GUI
]]

-- ============================================
-- 1. ANTI-DETECTION & BYPASS
-- ============================================
local function BypassAntiCheat()
    local MarketplaceService = game:GetService("MarketplaceService")
    if MarketplaceService then
        MarketplaceService.PromptBulkPurchase = function() return nil end
    end
    
    local LogService = game:GetService("LogService")
    if LogService then
        LogService.MessageOut:Connect(function(message)
            local suspicious = {"executor", "delta", "exploit", "inject", "bypass", "cheat"}
            for _, word in pairs(suspicious) do
                if string.lower(message):find(word) then 
                    return 
                end
            end
        end)
    end
    
    -- Bersihkan environment
    local env = getrenv and getrenv() or getfenv and getfenv()
    if env then
        local executorNames = {"Delta", "delta", "EXECUTOR", "DeltaExecutor", "syn", "krnl", "script", "executor"}
        for _, name in pairs(executorNames) do
            pcall(function() env[name] = nil end)
        end
    end
    
    collectgarbage("collect")
end
pcall(BypassAntiCheat)

-- ============================================
-- 2. SERVICES & VARIABLES
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Pastikan LocalPlayer ada
if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Settings
local Settings = {
    AimbotEnabled = true,
    AimbotFOV = 150,
    AimbotSmoothness = 10,
    TargetLock = false,
    AimPart = "HumanoidRootPart",
    ESPEnabled = true,
    ESPBoxOutline = true,
    ESPShowName = true,
    ESPShowDistance = true,
    ESPShowHealth = true,
    ESPTracers = true,
    TeamCheck = true,
    WallCheck = true, -- ESP tembus tembok
    WallbangEnabled = true,
    AutoPlayEnabled = false,
}

-- ESP Objects
local espObjects = {}
local currentTarget = nil
local guiVisible = true

-- Fungsi warna
local function getPlayerColor(player)
    if player.Team == LocalPlayer.Team and player.Team then
        return Color3.fromRGB(0, 255, 0) -- Hijau untuk teammate
    else
        return Color3.fromRGB(255, 50, 50) -- Merah untuk musuh
    end
end

-- ============================================
-- 3. CREATE NATIVE ROBLOX GUI (PASTI MUNCUL)
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaCheatGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game:GetService("CoreGui") -- Pake CoreGui biar selalu di atas

-- Coba pake PlayerGui kalo CoreGui error
pcall(function()
    if not screenGui.Parent then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 360, 0, 500)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Shadow effect
local shadow = Instance.new("UIStroke")
shadow.Color = Color3.fromRGB(0, 150, 255)
shadow.Thickness = 1
shadow.Transparency = 0.7
shadow.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.Text = "⚡ DELTA ULTIMATE CHEAT v4.0"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 1, 0)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextSize = 20
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 35, 1, 0)
minBtn.Position = UDim2.new(1, -80, 0, 0)
minBtn.Text = "−"
minBtn.TextSize = 20
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
minBtn.BorderSizePixel = 0
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minBtn

-- Scrollable Container
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -45)
scrollFrame.Position = UDim2.new(0, 0, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- ============================================
-- 4. FUNGSI MEMBUAT UI ELEMENTS
-- ============================================
local function createSection(parent, title, order)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 40)
    section.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    section.BorderSizePixel = 0
    section.LayoutOrder = order
    section.Parent = parent
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 8)
    sectionCorner.Parent = section
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -15, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = section
    
    return section
end

local function createToggle(parent, text, defaultValue, yOffset, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 40)
    container.Position = UDim2.new(0, 10, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.Parent = container
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 70, 0, 30)
    toggleBtn.Position = UDim2.new(1, -75, 0.5, -15)
    toggleBtn.Text = defaultValue and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 50, 50)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.Parent = container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    local state = defaultValue
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 50, 50)
        if callback then callback(state) end
    end)
    
    return function() return state end
end

local function createSlider(parent, text, minVal, maxVal, defaultVal, yOffset, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 65)
    container.Position = UDim2.new(0, 10, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. tostring(defaultVal)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 6)
    sliderFrame.Position = UDim2.new(0, 0, 0, 30)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal)/(maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local value = defaultVal
    local dragging = false
    
    local updateLabel = function()
        label.Text = text .. ": " .. math.floor(value)
        fill.Size = UDim2.new((value - minVal)/(maxVal - minVal), 0, 1, 0)
        if callback then callback(value) end
    end
    
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local mousePos = UserInputService:GetMouseLocation()
            local relX = math.clamp(mousePos.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
            value = minVal + (relX / sliderFrame.AbsoluteSize.X) * (maxVal - minVal)
            value = math.floor(value)
            updateLabel()
        end
    end)
    
    sliderFrame.InputEnded:Connect(function()
        dragging = false
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local relX = math.clamp(mousePos.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
            value = minVal + (relX / sliderFrame.AbsoluteSize.X) * (maxVal - minVal)
            value = math.floor(value)
            updateLabel()
        end
    end)
    
    updateLabel()
    return function() return value end
end

-- ============================================
-- 5. BUILD UI
-- ============================================
local yOffset = 0
local function addElement(element, height)
    element.LayoutOrder = yOffset
    element.Parent = scrollFrame
    yOffset = yOffset + 1
end

-- Section Aimbot
local aimbotSection = createSection(scrollFrame, "🎯 AIMBOT", yOffset)
yOffset = yOffset + 1

local aimbotToggle = createToggle(scrollFrame, "Aimbot", Settings.AimbotEnabled, 0, function(val)
    Settings.AimbotEnabled = val
end)
aimbotToggle.LayoutOrder = yOffset
aimbotToggle.Parent = scrollFrame
yOffset = yOffset + 1

local fovSlider = createSlider(scrollFrame, "FOV Radius", 30, 350, Settings.AimbotFOV, 0, function(val)
    Settings.AimbotFOV = val
end)
fovSlider.LayoutOrder = yOffset
fovSlider.Parent = scrollFrame
yOffset = yOffset + 1

local smoothSlider = createSlider(scrollFrame, "Smoothness", 1, 50, Settings.AimbotSmoothness, 0, function(val)
    Settings.AimbotSmoothness = val
end)
smoothSlider.LayoutOrder = yOffset
smoothSlider.Parent = scrollFrame
yOffset = yOffset + 1

local targetLockToggle = createToggle(scrollFrame, "Target Lock", Settings.TargetLock, 0, function(val)
    Settings.TargetLock = val
end)
targetLockToggle.LayoutOrder = yOffset
targetLockToggle.Parent = scrollFrame
yOffset = yOffset + 1

-- Section ESP
local espSection = createSection(scrollFrame, "👁️ ESP (TEMBUS TEMBOK)", yOffset)
yOffset = yOffset + 1

local espToggle = createToggle(scrollFrame, "Master ESP", Settings.ESPEnabled, 0, function(val)
    Settings.ESPEnabled = val
end)
espToggle.LayoutOrder = yOffset
espToggle.Parent = scrollFrame
yOffset = yOffset + 1

local boxToggle = createToggle(scrollFrame, "Box Outline", Settings.ESPBoxOutline, 0, function(val)
    Settings.ESPBoxOutline = val
end)
boxToggle.LayoutOrder = yOffset
boxToggle.Parent = scrollFrame
yOffset = yOffset + 1

local nameToggle = createToggle(scrollFrame, "Show Name", Settings.ESPShowName, 0, function(val)
    Settings.ESPShowName = val
end)
nameToggle.LayoutOrder = yOffset
nameToggle.Parent = scrollFrame
yOffset = yOffset + 1

local distToggle = createToggle(scrollFrame, "Show Distance", Settings.ESPShowDistance, 0, function(val)
    Settings.ESPShowDistance = val
end)
distToggle.LayoutOrder = yOffset
distToggle.Parent = scrollFrame
yOffset = yOffset + 1

local healthToggle = createToggle(scrollFrame, "Show Health Bar", Settings.ESPShowHealth, 0, function(val)
    Settings.ESPShowHealth = val
end)
healthToggle.LayoutOrder = yOffset
healthToggle.Parent = scrollFrame
yOffset = yOffset + 1

local tracerToggle = createToggle(scrollFrame, "Tracers", Settings.ESPTracers, 0, function(val)
    Settings.ESPTracers = val
end)
tracerToggle.LayoutOrder = yOffset
tracerToggle.Parent = scrollFrame
yOffset = yOffset + 1

local teamCheckToggle = createToggle(scrollFrame, "Team Check (Ignore Team)", Settings.TeamCheck, 0, function(val)
    Settings.TeamCheck = val
end)
teamCheckToggle.LayoutOrder = yOffset
teamCheckToggle.Parent = scrollFrame
yOffset = yOffset + 1

local wallCheckToggle = createToggle(scrollFrame, "X-Ray (Tembus Tembok)", Settings.WallCheck, 0, function(val)
    Settings.WallCheck = val
end)
wallCheckToggle.LayoutOrder = yOffset
wallCheckToggle.Parent = scrollFrame
yOffset = yOffset + 1

-- Section Combat
local combatSection = createSection(scrollFrame, "💥 COMBAT", yOffset)
yOffset = yOffset + 1

local wallbangToggle = createToggle(scrollFrame, "Wallbang (Tembus Tembok)", Settings.WallbangEnabled, 0, function(val)
    Settings.WallbangEnabled = val
end)
wallbangToggle.LayoutOrder = yOffset
wallbangToggle.Parent = scrollFrame
yOffset = yOffset + 1

-- Section Auto-Play
local autoSection = createSection(scrollFrame, "🤖 AUTO-PLAY", yOffset)
yOffset = yOffset + 1

local autoPlayConnection = nil

local function autoPlayLogic()
    if not Settings.AutoPlayEnabled then return end
    
    local nearestPlayer = nil
    local nearestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team and player.Team then
                -- skip
            else
                local root = player.Character.HumanoidRootPart
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestPlayer = player
                    end
                end
            end
        end
    end
    
    if nearestPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        local targetPos = nearestPlayer.Character.HumanoidRootPart.Position
        humanoid:MoveTo(targetPos)
    end
end

local autoPlayToggle = createToggle(scrollFrame, "Auto-Play (Chase Enemies)", Settings.AutoPlayEnabled, 0, function(val)
    Settings.AutoPlayEnabled = val
    if val then
        if autoPlayConnection then autoPlayConnection:Disconnect() end
        autoPlayConnection = RunService.Heartbeat:Connect(autoPlayLogic)
    else
        if autoPlayConnection then autoPlayConnection:Disconnect() end
    end
end)
autoPlayToggle.LayoutOrder = yOffset
autoPlayToggle.Parent = scrollFrame
yOffset = yOffset + 1

-- Update canvas size
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset * 50 + 100)

-- ============================================
-- 6. DRAG FUNCTIONALITY
-- ============================================
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
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

-- ============================================
-- 7. BUTTON FUNCTIONS
-- ============================================
closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
    guiVisible = false
end)

minBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
    guiVisible = screenGui.Enabled
end)

-- Toggle dengan Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        screenGui.Enabled = not screenGui.Enabled
        guiVisible = screenGui.Enabled
    end
end)

-- ============================================
-- 8. ESP SYSTEM (Drawing API)
-- ============================================
-- Cek Drawing API availability
local hasDrawing = pcall(function() return Drawing.new("Square") end)

if hasDrawing then
    local function createESPObject(player)
        if espObjects[player] then return end
        
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1.5
        box.Filled = false
        box.Color = getPlayerColor(player)
        box.Transparency = 0.7
        
        local nameText = Drawing.new("Text")
        nameText.Visible = false
        nameText.Size = 14
        nameText.Center = true
        nameText.Outline = true
        nameText.Color = Color3.fromRGB(255, 255, 255)
        
        local distText = Drawing.new("Text")
        distText.Visible = false
        distText.Size = 11
        distText.Center = true
        distText.Outline = true
        distText.Color = Color3.fromRGB(200, 200, 200)
        
        local healthBar = Drawing.new("Line")
        healthBar.Visible = false
        healthBar.Thickness = 3
        
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 1.5
        tracer.Transparency = 0.7
        
        espObjects[player] = {
            Box = box,
            Name = nameText,
            Distance = distText,
            HealthBar = healthBar,
            Tracer = tracer,
        }
    end
    
    local function updateESP()
        if not Settings.ESPEnabled then return end
        
        for player, objects in pairs(espObjects) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
               player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                
                local rootPart = player.Character.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local screenPos = Vector2.new(vector.X, vector.Y)
                local isOnScreen = onScreen
                
                -- Wall Check (X-Ray)
                if not Settings.WallCheck then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                    local ray = workspace:Raycast(Camera.CFrame.Position, (rootPart.Position - Camera.CFrame.Position).Unit * 1000, raycastParams)
                    if ray and ray.Instance then
                        isOnScreen = false
                    end
                end
                
                if isOnScreen and vector.Z > 0 then
                    local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                    local boxSize = 140 / distance * 5
                    local boxHeight = boxSize * 1.8
                    local boxWidth = boxSize
                    local boxPos = Vector2.new(screenPos.X - boxWidth/2, screenPos.Y - boxHeight/2)
                    
                    if Settings.ESPBoxOutline then
                        objects.Box.Visible = true
                        objects.Box.Size = Vector2.new(boxWidth, boxHeight)
                        objects.Box.Position = boxPos
                        objects.Box.Color = getPlayerColor(player)
                    else
                        objects.Box.Visible = false
                    end
                    
                    if Settings.ESPShowName then
                        objects.Name.Visible = true
                        objects.Name.Text = player.Name
                        objects.Name.Position = Vector2.new(screenPos.X, screenPos.Y - boxHeight/2 - 15)
                    else
                        objects.Name.Visible = false
                    end
                    
                    if Settings.ESPShowDistance then
                        objects.Distance.Visible = true
                        objects.Distance.Text = math.floor(distance) .. "m"
                        objects.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + boxHeight/2 + 5)
                    else
                        objects.Distance.Visible = false
                    end
                    
                    if Settings.ESPShowHealth then
                        local health = player.Character.Humanoid.Health
                        local maxHealth = player.Character.Humanoid.MaxHealth
                        local healthPercent = math.clamp(health / maxHealth, 0, 1)
                        local healthBarHeight = boxHeight * healthPercent
                        
                        objects.HealthBar.Visible = true
                        objects.HealthBar.From = Vector2.new(boxPos.X - 5, boxPos.Y + boxHeight - healthBarHeight)
                        objects.HealthBar.To = Vector2.new(boxPos.X - 5, boxPos.Y + boxHeight)
                        objects.HealthBar.Color = Color3.fromRGB(0, 255 * (1 - healthPercent), 255 * healthPercent)
                    else
                        objects.HealthBar.Visible = false
                    end
                    
                    if Settings.ESPTracers then
                        objects.Tracer.Visible = true
                        objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        objects.Tracer.To = screenPos
                        objects.Tracer.Color = getPlayerColor(player)
                    else
                        objects.Tracer.Visible = false
                    end
                else
                    objects.Box.Visible = false
                    objects.Name.Visible = false
                    objects.Distance.Visible = false
                    objects.HealthBar.Visible = false
                    objects.Tracer.Visible = false
                end
            else
                if objects then
                    objects.Box.Visible = false
                    objects.Name.Visible = false
                    objects.Distance.Visible = false
                    objects.HealthBar.Visible = false
                    objects.Tracer.Visible = false
                end
            end
        end
    end
    
    local function clearESP()
        for player, objects in pairs(espObjects) do
            pcall(function()
                if objects.Box then objects.Box:Remove() end
                if objects.Name then objects.Name:Remove() end
                if objects.Distance then objects.Distance:Remove() end
                if objects.HealthBar then objects.HealthBar:Remove() end
                if objects.Tracer then objects.Tracer:Remove() end
            end)
        end
        espObjects = {}
    end
    
    local function setupESP()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESPObject(player)
            end
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then createESPObject(player) end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if espObjects[player] then
            pcall(function()
                if espObjects[player].Box then espObjects[player].Box:Remove() end
                if espObjects[player].Name then espObjects[player].Name:Remove() end
                if espObjects[player].Distance then espObjects[player].Distance:Remove() end
                if espObjects[player].HealthBar then espObjects[player].HealthBar:Remove() end
                if espObjects[player].Tracer then espObjects[player].Tracer:Remove() end
            end)
            espObjects[player] = nil
        end
    end)
    
    setupESP()
    
    RunService.RenderStepped:Connect(function()
        updateESP()
    end)
end

-- ============================================
-- 9. AIMBOT SYSTEM
-- ============================================
local function getClosestPlayerInFOV()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestDist = Settings.AimbotFOV
    local closestPlayer = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and 
           player.Character.Humanoid.Health > 0 then
            
            if Settings.TeamCheck and player.Team == LocalPlayer.Team and player.Team then
                -- skip teammate
            else
                local targetPart = player.Character:FindFirstChild(Settings.AimPart) or player.Character:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
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
    end
    return closestPlayer
end

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if not Settings.AimbotEnabled then return end
    
    local target = getClosestPlayerInFOV()
    if target and target.Character then
        currentTarget = target
        local targetPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local targetScreen = Vector2.new(screenPos.X, screenPos.Y)
                local currentMouse = UserInputService:GetMouseLocation()
                local delta = (targetScreen - currentMouse) / Settings.AimbotSmoothness
                
                pcall(function()
                    mousemoverel(delta.X, delta.Y)
                end)
                
                if Settings.TargetLock then
                    local cameraCF = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                    Camera.CFrame = cameraCF
                end
            end
        end
    end
end)

-- ============================================
-- 10. WALLBANG SYSTEM
-- ============================================
if Settings.WallbangEnabled then
    local originalRaycast = workspace.Raycast
    workspace.Raycast = function(origin, direction, range, params)
        if Settings.WallbangEnabled then
            local newParams = RaycastParams.new()
            newParams.FilterType = Enum.RaycastFilterType.Blacklist
            newParams.FilterDescendantsInstances = {LocalPlayer.Character}
            return originalRaycast(origin, direction, range, newParams)
        else
            return originalRaycast(origin, direction, range, params)
        end
    end
end

-- ============================================
-- 11. NOTIFICATION
-- ============================================
local notification = Instance.new("TextLabel")
notification.Size = UDim2.new(0, 300, 0, 40)
notification.Position = UDim2.new(0.5, -150, 1, -60)
notification.Text = "✅ DELTA ULTIMATE SCRIPT LOADED! Press INSERT to toggle"
notification.TextColor3 = Color3.fromRGB(255, 255, 255)
notification.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
notification.BackgroundTransparency = 0.2
notification.TextSize = 14
notification.Font = Enum.Font.GothamBold
notification.BorderSizePixel = 0
notification.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 8)
notifCorner.Parent = notification

-- Fade out notification
task.wait(3)
TweenService:Create(notification, TweenInfo.new(1, Enum.EasingStyle.Linear), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
task.wait(1)
notification:Destroy()

print("[✓] Script loaded! Press Insert to toggle GUI")
