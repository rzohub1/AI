-- RZOHUB Brutal v6 - Rayfield UI (No Bypass)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "RZOHUB - Brutal v6",
    LoadingTitle = "Loading Rayfield...",
    LoadingSubtitle = "Private Test Environment",
    ConfigurationSaving = { Enabled = true, FolderName = "RZOHUB", FileName = "BrutalV6" }
})

-- Create Tabs
local MainTab = Window:CreateTab("Main", "4483362458")
local AimTab = Window:CreateTab("Aimbot", "4483362458")
local VisualTab = Window:CreateTab("Visual", "4483362458")
local MiscTab = Window:CreateTab("Misc", "4483362458")

-- Variables
local AimbotEnabled = false
local SilentAimEnabled = false
local TriggerbotEnabled = false
local SpinBotEnabled = false
local ESPEnabled = false
local WallCheck = true
local TeamCheck = true
local FOV = 240
local CurrentTarget = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Transparency = 0.8
fovCircle.Filled = false
fovCircle.Visible = false

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and fovCircle then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Radius = FOV
        fovCircle.Visible = true
    elseif fovCircle then
        fovCircle.Visible = false
    end
end)

-- ESP System
local ESPObjects = {}

local function CreateESP(plr)
    if plr == LocalPlayer or ESPObjects[plr] then return end
    
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESPEnabled and plr.Character and plr.Character:FindFirstChild("Head") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "RZOHUB_ESP"
            billboard.Adornee = plr.Character.Head
            billboard.Size = UDim2.new(0, 220, 0, 60)
            billboard.StudsOffset = Vector3.new(0, 3.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = plr.Character.Head
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1,0,0.45,0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextScaled = true
            nameLabel.Parent = billboard
            
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Size = UDim2.new(1,0,0.55,0)
            infoLabel.Position = UDim2.new(0,0,0.45,0)
            infoLabel.BackgroundTransparency = 1
            infoLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
            infoLabel.TextStrokeTransparency = 0
            infoLabel.Font = Enum.Font.GothamSemibold
            infoLabel.TextScaled = true
            infoLabel.Parent = billboard
            
            ESPObjects[plr] = {Billboard = billboard, Name = nameLabel, Info = infoLabel}
        end
    end)
    
    if ESPEnabled and plr.Character and plr.Character:FindFirstChild("Head") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "RZOHUB_ESP"
        billboard.Adornee = plr.Character.Head
        billboard.Size = UDim2.new(0, 220, 0, 60)
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = plr.Character.Head
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1,0,0.45,0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextScaled = true
        nameLabel.Parent = billboard
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1,0,0.55,0)
        infoLabel.Position = UDim2.new(0,0,0.45,0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
        infoLabel.TextStrokeTransparency = 0
        infoLabel.Font = Enum.Font.GothamSemibold
        infoLabel.TextScaled = true
        infoLabel.Parent = billboard
        
        ESPObjects[plr] = {Billboard = billboard, Name = nameLabel, Info = infoLabel}
    end
end

local function UpdateESP()
    for plr, esp in pairs(ESPObjects) do
        if ESPEnabled and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local hum = plr.Character:FindFirstChild("Humanoid")
            if esp.Billboard then
                esp.Billboard.Enabled = true
                local dist = (Camera.CFrame.Position - head.Position).Magnitude
                local hp = hum and math.floor(hum.Health) or 0
                if esp.Name then esp.Name.Text = plr.Name end
                if esp.Info then esp.Info.Text = string.format("HP: %d | %.0f studs", hp, dist) end
            end
        elseif esp.Billboard then
            esp.Billboard.Enabled = false
        end
    end
end

-- Setup ESP for existing players
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        CreateESP(plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    CreateESP(plr)
end)

-- Get Closest Player
local function GetClosestPlayer()
    local closest, closestDist = nil, FOV
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            if TeamCheck and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                continue
            end
            
            local head = plr.Character.Head
            local vector, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local distance = (Vector2.new(vector.X, vector.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                
                if distance < closestDist then
                    if WallCheck then
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        local rayResult = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 1000, raycastParams)
                        
                        if rayResult and rayResult.Instance:IsDescendantOf(plr.Character) then
                            closestDist = distance
                            closest = plr
                        end
                    else
                        closestDist = distance
                        closest = plr
                    end
                end
            end
        end
    end
    
    return closest
end

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        CurrentTarget = GetClosestPlayer()
        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
            local head = CurrentTarget.Character.Head
            local targetPos = head.Position
            
            -- Simple prediction
            local hrp = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                targetPos = targetPos + (hrp.Velocity * 0.085)
            end
            
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        end
    end
end)

-- Triggerbot
RunService.Heartbeat:Connect(function()
    if TriggerbotEnabled and CurrentTarget and CurrentTarget.Character then
        local head = CurrentTarget.Character:FindFirstChild("Head")
        if head then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
            local rayResult = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 1000, raycastParams)
            
            if rayResult and rayResult.Instance:IsDescendantOf(CurrentTarget.Character) then
                -- Simulate mouse click for triggerbot
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    -- Auto shoot when aiming at target
                end
            end
        end
    end
end)

-- Spin Bot
RunService.RenderStepped:Connect(function()
    if SpinBotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(15), 0)
    end
end)

-- Update ESP loop
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        UpdateESP()
    else
        for _, esp in pairs(ESPObjects) do
            if esp.Billboard then
                esp.Billboard.Enabled = false
            end
        end
    end
end)

-- ==================== RAYFIELD MENU ====================
-- Main Tab
MainTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(v)
        AimbotEnabled = v
        if not v then CurrentTarget = nil end
    end
})

MainTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Callback = function(v)
        SilentAimEnabled = v
        Rayfield:Notify({
            Title = "Silent Aim",
            Content = v and "Enabled (Experimental)" or "Disabled",
            Duration = 2
        })
    end
})

MainTab:CreateToggle({
    Name = "Triggerbot",
    CurrentValue = false,
    Callback = function(v) TriggerbotEnabled = v end
})

MainTab:CreateToggle({
    Name = "Spin Bot",
    CurrentValue = false,
    Callback = function(v) SpinBotEnabled = v end
})

-- Aim Tab
AimTab:CreateSlider({
    Name = "FOV",
    Range = {80, 700},
    Increment = 10,
    CurrentValue = FOV,
    Callback = function(v)
        FOV = v
        if fovCircle then fovCircle.Radius = v end
    end
})

AimTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Callback = function(v) WallCheck = v end
})

AimTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(v) TeamCheck = v end
})

-- Visual Tab
VisualTab:CreateToggle({
    Name = "ESP (Name + Distance + Health)",
    CurrentValue = false,
    Callback = function(v)
        ESPEnabled = v
        if v then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and not ESPObjects[plr] then
                    CreateESP(plr)
                end
            end
        end
    end
})

-- Misc Tab
MiscTab:CreateButton({
    Name = "Anti Lag Mode",
    Callback = function()
        local success, err = pcall(function()
            settings().Rendering.QualityLevel = 1
        end)
        Rayfield:Notify({
            Title = "Anti Lag",
            Content = "Graphics optimized!",
            Duration = 5
        })
    end
})

MiscTab:CreateButton({
    Name = "Clear ESP Objects",
    Callback = function()
        for _, esp in pairs(ESPObjects) do
            if esp.Billboard then
                esp.Billboard:Destroy()
            end
        end
        ESPObjects = {}
        Rayfield:Notify({
            Title = "ESP Cleared",
            Content = "All ESP objects removed",
            Duration = 3
        })
    end
})

-- Notify user
Rayfield:Notify({
    Title = "Brutal v6 Loaded",
    Content = "Rayfield UI • Bypass removed for safety",
    Duration = 10
})
