-- Mobile Aimbot + ESP Script - Delta Executor Compatible
-- Fixed version - tested for mobile

-- Load Rayfield dengan benar
local RayfieldLoaded, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
end)

if not RayfieldLoaded then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = "Failed to load Rayfield! Check connection.",
        Duration = 5
    })
    return
end

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Mobile Aimbot + ESP",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "By Script",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MobileAimScript",
        FileName = "Settings"
    },
    KeySystem = false
})

-- Tabs
local MainTab = Window:CreateTab("Aimbot", 4483362458)
local EspTab = Window:CreateTab("ESP", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Settings
local AimbotEnabled = false
local TargetLock = false
local FOV = 200
local Smoothness = 5
local WallCheck = true
local ESPEnabled = false
local OutlineESP = false

local currentTarget = nil

-- Mobile touch aim simulation (replaces mousemoverel for mobile)
local function MoveAim(deltaX, deltaY)
    -- For mobile, we use viewport center as reference
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local newPosition = center + Vector2.new(deltaX, deltaY)
    
    -- Simulate mouse movement for aimbot on mobile
    -- Some executors support this, otherwise just visual
    pcall(function()
        mousemoveabs(newPosition.X, newPosition.Y)
    end)
end

-- Get closest player to crosshair
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if not center then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local part = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDist then
                        if WallCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                            local hit, position = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                            if hit and hit:IsDescendantOf(player.Character) then
                                closest = player
                                shortestDist = dist
                            elseif not hit then
                                closest = player
                                shortestDist = dist
                            end
                        else
                            closest = player
                            shortestDist = dist
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Aimbot main loop (mobile friendly)
local function AimbotLoop()
    if not AimbotEnabled then return end
    
    if TargetLock and currentTarget then
        if currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = currentTarget.Character.HumanoidRootPart
            local targetScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if targetScreen.Z > 0 then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local delta = Vector2.new(targetScreen.X, targetScreen.Y) - center
                if delta.Magnitude > 5 then
                    local smoothDelta = delta / Smoothness
                    MoveAim(smoothDelta.X, smoothDelta.Y)
                end
            else
                currentTarget = nil
            end
        else
            currentTarget = nil
        end
    elseif not TargetLock then
        currentTarget = GetClosestPlayer()
    end
end

-- ESP Creation (Outline tembus pandang)
local espConnections = {}

local function CreateESP(player)
    if not ESPEnabled or player == LocalPlayer then return end
    
    local function addESP(char)
        if not char or char:FindFirstChildWhichIsA("Highlight") then return end
        
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255, 50, 50)
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.3
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Makes outline visible through walls
        highlight.Adornee = char
        highlight.Parent = char
        
        -- Name tag
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Name"
        billboard.Size = UDim2.new(0, 120, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard
        
        if OutlineESP then
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        else
            highlight.OutlineTransparency = 1
        end
    end
    
    if player.Character then
        addESP(player.Character)
    end
    
    local conn
    conn = player.CharacterAdded:Connect(addESP)
    table.insert(espConnections, {player = player, connection = conn})
end

local function RemoveESP(player)
    if player.Character then
        for _, child in ipairs(player.Character:GetChildren()) do
            if child:IsA("Highlight") or child.Name == "ESP_Name" then
                child:Destroy()
            end
        end
    end
    
    for i, data in ipairs(espConnections) do
        if data.player == player then
            data.connection:Disconnect()
            table.remove(espConnections, i)
            break
        end
    end
end

local function RefreshAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            RemoveESP(player)
            if ESPEnabled then
                CreateESP(player)
            end
        end
    end
end

-- Player connections
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPEnabled then
            CreateESP(player)
        end
    end)
    if ESPEnabled then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- UI Elements
MainTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(value)
        AimbotEnabled = value
        if not value then currentTarget = nil end
    end
})

MainTab:CreateToggle({
    Name = "Target Lock",
    CurrentValue = false,
    Flag = "TargetLock",
    Callback = function(value)
        TargetLock = value
        if not value then currentTarget = nil end
    end
})

MainTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 200,
    Flag = "FOVSlider",
    Callback = function(value)
        FOV = value
    end
})

MainTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 15},
    Increment = 1,
    Suffix = "",
    CurrentValue = 5,
    Flag = "SmoothSlider",
    Callback = function(value)
        Smoothness = value
    end
})

MainTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Flag = "WallCheck",
    Callback = function(value)
        WallCheck = value
    end
})

EspTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(value)
        ESPEnabled = value
        RefreshAllESP()
    end
})

EspTab:CreateToggle({
    Name = "Outline Tembus Pandang",
    CurrentValue = false,
    Flag = "OutlineESP",
    Callback = function(value)
        OutlineESP = value
        RefreshAllESP()
    end
})

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        for _, data in ipairs(espConnections) do
            data.connection:Disconnect()
        end
        Rayfield:Destroy()
    end
})

-- Main loop
RunService.RenderStepped:Connect(AimbotLoop)

-- Success notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Loaded Successfully",
    Text = "Mobile Aimbot + ESP Ready! Use the UI to toggle features.",
    Duration = 4
})

-- Show UI instructions for mobile
task.wait(1)
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Mobile Users",
    Text = "Tap the Rayfield button on screen to show/hide UI",
    Duration = 5
})
