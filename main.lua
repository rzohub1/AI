-- Rayfield Mobile Aimbot + ESP Script (Delta Executor compatible)
-- For private test environment only

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({
    Name = "Mobile Aimbot + ESP",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "By Script",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MobileAimScript",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvite",
        RememberJoins = true
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Aimbot", 4483362458)
local EspTab = Window:CreateTab("ESP", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local AimbotEnabled = false
local TargetLock = false
local FOV = 200
local Smoothness = 5
local WallCheck = true
local ESPEnabled = false
local OutlineESP = false

local currentTarget = nil
local lastTarget = nil

-- Helper: Get closest player to crosshair
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
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
    return closest
end

-- Aimbot loop (mobile: simulates mouse move)
local function Aimbot()
    if not AimbotEnabled then return end
    if TargetLock and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local targetPart = currentTarget.Character.HumanoidRootPart
        local targetScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if targetScreen.Z > 0 then
            local delta = Vector2.new(targetScreen.X, targetScreen.Y) - Vector2.new(Mouse.X, Mouse.Y)
            if delta.Magnitude > 1 then
                local smoothDelta = delta / Smoothness
                mousemoverel(smoothDelta.X, smoothDelta.Y)
            end
        else
            currentTarget = nil
        end
    elseif not TargetLock then
        currentTarget = GetClosestPlayer()
        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = currentTarget.Character.HumanoidRootPart
            local targetScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if targetScreen.Z > 0 then
                local delta = Vector2.new(targetScreen.X, targetScreen.Y) - Vector2.new(Mouse.X, Mouse.Y)
                if delta.Magnitude > 1 then
                    local smoothDelta = delta / Smoothness
                    mousemoverel(smoothDelta.X, smoothDelta.Y)
                end
            end
        end
    end
end

-- ESP: Box + Outline tembus pandang
local function CreateESP(player)
    if not ESPEnabled then return end
    if player == LocalPlayer then return end
    
    local function addESP(char)
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        -- Bounding box
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0 -- Outline tembus pandang (visible through walls)
        highlight.Adornee = char
        highlight.Parent = char
        
        -- Optional: Name tag
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Parent = billboard
        
        if OutlineESP then
            highlight.OutlineTransparency = 0
        else
            highlight.OutlineTransparency = 1
        end
    end
    
    if player.Character then
        addESP(player.Character)
    end
    player.CharacterAdded:Connect(addESP)
end

-- Clean ESP on removal
local function RemoveESP(player)
    if player.Character and player.Character:FindFirstChildWhichIsA("Highlight") then
        player.Character:FindFirstChildWhichIsA("Highlight"):Destroy()
    end
    if player.Character and player.Character:FindFirstChildWhichIsA("BillboardGui") then
        player.Character:FindFirstChildWhichIsA("BillboardGui"):Destroy()
    end
end

-- Apply ESP to all players
local function RefreshESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            RemoveESP(player)
            if ESPEnabled then
                CreateESP(player)
            end
        end
    end
end

-- Auto setup for new players
Players.PlayerAdded:Connect(function(player)
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
    Name = "Target Lock (Hold on closest)",
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
    Increment = 5,
    Suffix = "px",
    CurrentValue = 200,
    Flag = "FOVSlider",
    Callback = function(value)
        FOV = value
    end
})

MainTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 20},
    Increment = 1,
    Suffix = "",
    CurrentValue = 5,
    Flag = "SmoothSlider",
    Callback = function(value)
        Smoothness = value
    end
})

MainTab:CreateToggle({
    Name = "Wall Check (ignore behind walls)",
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
        RefreshESP()
    end
})

EspTab:CreateToggle({
    Name = "Outline Tembus Pandang (See through walls)",
    CurrentValue = false,
    Flag = "OutlineESP",
    Callback = function(value)
        OutlineESP = value
        RefreshESP()
    end
})

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Closed",
            Text = "UI Destroyed",
            Duration = 2
        })
    end
})

-- Aimbot loop
RunService.RenderStepped:Connect(Aimbot)

-- Mobile notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Loaded",
    Text = "Mobile Aimbot + ESP Ready | Delta Executor",
    Duration = 3
})
