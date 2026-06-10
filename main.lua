--[[
    🎯 Nexus FPS | Mobile & PC Supporting Roblox GUI
    Powered by Rayfield Library
--]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🎯 Nexus FPS | Roblox Menu",
   LoadingTitle = "Nexus Hub",
   LoadingSubtitle = "by Antigravity",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "NexusFPS",
      FileName = "Config"
   },
   KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Configuration Variables
local AimbotSettings = {
    Enabled = false,
    TargetPart = "Head",
    Smoothness = 0.1,
    FOVEnabled = true,
    Radius = 100,
    TeamCheck = false
}

local SilentAim = {
    Enabled = false,
    TargetPart = "Head",
    Radius = 120,
    FOVEnabled = true,
    TeamCheck = false
}

local HitboxSettings = {
    Enabled = false,
    TargetPart = "Head",
    Size = 10,
    Transparency = 0.7,
    TeamCheck = false
}

local ESP = {
    Enabled = false,
    Names = false,
    TeamCheck = false,
    Color = Color3.fromRGB(255, 0, 0)
}

local Movement = {
    WalkSpeed = 16,
    JumpPower = 50,
    WSLoop = false,
    JPLoop = false
}

-- Drawing FOV Circles
local AimbotFOVCircle = Drawing.new("Circle")
AimbotFOVCircle.Color = Color3.fromRGB(255, 255, 255)
AimbotFOVCircle.Thickness = 1.5
AimbotFOVCircle.NumSides = 64
AimbotFOVCircle.Radius = AimbotSettings.Radius
AimbotFOVCircle.Filled = false
AimbotFOVCircle.Visible = false

local SilentAimFOVCircle = Drawing.new("Circle")
SilentAimFOVCircle.Color = Color3.fromRGB(255, 0, 0)
SilentAimFOVCircle.Thickness = 1.5
SilentAimFOVCircle.NumSides = 64
SilentAimFOVCircle.Radius = SilentAim.Radius
SilentAimFOVCircle.Filled = false
SilentAimFOVCircle.Visible = false

-- Update FOV Circles (Centered on Screen)
RunService.RenderStepped:Connect(function()
    local screenCenter = Camera.ViewportSize / 2
    
    -- Aimbot FOV
    AimbotFOVCircle.Position = screenCenter
    AimbotFOVCircle.Radius = AimbotSettings.Radius
    AimbotFOVCircle.Visible = AimbotSettings.Enabled and AimbotSettings.FOVEnabled
    
    -- Silent Aim FOV
    SilentAimFOVCircle.Position = screenCenter
    SilentAimFOVCircle.Radius = SilentAim.Radius
    SilentAimFOVCircle.Visible = SilentAim.Enabled and SilentAim.FOVEnabled
end)

-- Helper: Get Closest Player to Screen Center
local function getClosestPlayerToCenter(targetPart, radius, teamCheck)
    local target = nil
    local maxDistance = radius
    local screenCenter = Camera.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(targetPart) and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            if teamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local screenPoint, onScreen = Camera:WorldToViewportPoint(player.Character[targetPart].Position)
            if onScreen then
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                if distance < maxDistance then
                    target = player
                    maxDistance = distance
                end
            end
        end
    end
    return target
end

-- Aimbot Lerp Loop
RunService.RenderStepped:Connect(function()
    if AimbotSettings.Enabled then
        local target = getClosestPlayerToCenter(AimbotSettings.TargetPart, AimbotSettings.Radius, AimbotSettings.TeamCheck)
        if target and target.Character and target.Character:FindFirstChild(AimbotSettings.TargetPart) then
            local targetPos = target.Character[AimbotSettings.TargetPart].Position
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSettings.Smoothness)
        end
    end
end)

-- Silent Aim: Hook Metamethod (Supports major executors)
local IndexHook
pcall(function()
    IndexHook = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and SilentAim.Enabled and tostring(self) == "Mouse" then
            if key == "Hit" or key == "Target" then
                local target = getClosestPlayerToCenter(SilentAim.TargetPart, SilentAim.Radius, SilentAim.TeamCheck)
                if target and target.Character and target.Character:FindFirstChild(SilentAim.TargetPart) then
                    local part = target.Character[SilentAim.TargetPart]
                    if key == "Hit" then
                        return part.CFrame
                    elseif key == "Target" then
                        return part
                    end
                end
            end
        end
        return IndexHook(self, key)
    end)
end)

-- Hitbox Expander System
local originalHitboxes = {}

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(HitboxSettings.TargetPart)
            if targetPart and targetPart:IsA("BasePart") then
                -- Check team
                local isTeammate = HitboxSettings.TeamCheck and player.Team == LocalPlayer.Team
                
                if HitboxSettings.Enabled and not isTeammate then
                    -- Save original size
                    if not originalHitboxes[player] then
                        originalHitboxes[player] = {
                            Size = targetPart.Size,
                            Transparency = targetPart.Transparency,
                            CanCollide = targetPart.CanCollide
                        }
                    end
                    -- Expand
                    targetPart.Size = Vector3.new(HitboxSettings.Size, HitboxSettings.Size, HitboxSettings.Size)
                    targetPart.Transparency = HitboxSettings.Transparency
                    targetPart.CanCollide = false
                else
                    -- Restore
                    if originalHitboxes[player] then
                        targetPart.Size = originalHitboxes[player].Size
                        targetPart.Transparency = originalHitboxes[player].Transparency
                        targetPart.CanCollide = originalHitboxes[player].CanCollide
                        originalHitboxes[player] = nil
                    end
                end
            end
        end
    end
end)

-- ESP System (Highlights & Name Tags)
local highlights = {}
local nameTags = {}

local function addESP(player)
    if player == LocalPlayer then return end

    local function setupHighlight(char)
        if not char then return end
        
        -- Clean existing
        if highlights[player] then highlights[player]:Destroy(); highlights[player] = nil end
        if nameTags[player] then nameTags[player]:Destroy(); nameTags[player] = nil end

        if ESP.Enabled then
            if ESP.TeamCheck and player.Team == LocalPlayer.Team then return end
            
            -- Highlight Box
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Adornee = char
            highlight.FillColor = ESP.Color
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = char
            highlights[player] = highlight

            -- Name Tag
            if ESP.Names then
                local head = char:WaitForChild("Head", 5)
                if head then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ESP_NameTag"
                    billboard.Adornee = head
                    billboard.Size = UDim2.new(0, 150, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                    billboard.AlwaysOnTop = true

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = player.Name
                    textLabel.TextColor3 = ESP.Color
                    textLabel.TextSize = 14
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    textLabel.Parent = billboard

                    billboard.Parent = head
                    nameTags[player] = billboard
                end
            end
        end
    end

    player.CharacterAdded:Connect(setupHighlight)
    if player.Character then
        setupHighlight(player.Character)
    end
end

local function removeESP(player)
    if highlights[player] then highlights[player]:Destroy(); highlights[player] = nil end
    if nameTags[player] then nameTags[player]:Destroy(); nameTags[player] = nil end
    originalHitboxes[player] = nil
end

Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        removeESP(player)
        if ESP.Enabled then
            addESP(player)
        end
    end
end

-- Movement Loop (Walkspeed & Jump Power)
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Movement.WSLoop then
            humanoid.WalkSpeed = Movement.WalkSpeed
        end
        if Movement.JPLoop then
            humanoid.JumpPower = Movement.JumpPower
            humanoid.UseJumpPower = true
        end
    end
end)

-- TAB 1: Combat (Aimbot & Silent Aim)
local CombatTab = Window:CreateTab("🎯 Combat", nil)

CombatTab:CreateSection("Aimbot Settings")

CombatTab:CreateToggle({
   Name = "Enable Camera Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
      AimbotSettings.Enabled = Value
   end,
})

CombatTab:CreateDropdown({
   Name = "Aimbot Target Part",
   Options = {"Head", "Torso", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Flag = "TargetPartDropdown",
   Callback = function(Option)
      AimbotSettings.TargetPart = Option[1]
   end,
})

CombatTab:CreateSlider({
   Name = "Aimbot Smoothness",
   Range = {0.01, 1},
   Increment = 0.05,
   Suffix = "smoothness",
   CurrentValue = 0.1,
   Flag = "SmoothnessSlider",
   Callback = function(Value)
      AimbotSettings.Smoothness = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Aimbot FOV Circle",
   CurrentValue = true,
   Flag = "FOVToggle",
   Callback = function(Value)
      AimbotSettings.FOVEnabled = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Aimbot FOV Radius",
   Range = {10, 500},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 100,
   Flag = "RadiusSlider",
   Callback = function(Value)
      AimbotSettings.Radius = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Aimbot Team Check",
   CurrentValue = false,
   Flag = "TeamCheckToggle",
   Callback = function(Value)
      AimbotSettings.TeamCheck = Value
   end,
})

CombatTab:CreateSection("Silent Aim Settings")

CombatTab:CreateToggle({
   Name = "Enable Silent Aim",
   CurrentValue = false,
   Flag = "SilentAimToggle",
   Callback = function(Value)
      SilentAim.Enabled = Value
   end,
})

CombatTab:CreateDropdown({
   Name = "Silent Target Part",
   Options = {"Head", "Torso", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Flag = "SilentPartDropdown",
   Callback = function(Option)
      SilentAim.TargetPart = Option[1]
   end,
})

CombatTab:CreateToggle({
   Name = "Silent Aim FOV Circle",
   CurrentValue = true,
   Flag = "SilentFOVToggle",
   Callback = function(Value)
      SilentAim.FOVEnabled = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Silent Aim FOV Radius",
   Range = {10, 500},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 120,
   Flag = "SilentRadiusSlider",
   Callback = function(Value)
      SilentAim.Radius = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Silent Aim Team Check",
   CurrentValue = false,
   Flag = "SilentTeamCheckToggle",
   Callback = function(Value)
      SilentAim.TeamCheck = Value
   end,
})

-- TAB 2: Hitbox Expander
local HitboxTab = Window:CreateTab("📦 Hitbox", nil)

HitboxTab:CreateSection("Hitbox Expander")

HitboxTab:CreateToggle({
   Name = "Enable Hitbox Expander",
   CurrentValue = false,
   Flag = "HitboxToggle",
   Callback = function(Value)
      HitboxSettings.Enabled = Value
   end,
})

HitboxTab:CreateDropdown({
   Name = "Hitbox Target Part",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Flag = "HitboxPartDropdown",
   Callback = function(Option)
      HitboxSettings.TargetPart = Option[1]
   end,
})

HitboxTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {2, 50},
   Increment = 1,
   Suffix = "studs",
   CurrentValue = 10,
   Flag = "HitboxSizeSlider",
   Callback = function(Value)
      HitboxSettings.Size = Value
   end,
})

HitboxTab:CreateSlider({
   Name = "Hitbox Transparency",
   Range = {0, 1},
   Increment = 0.1,
   Suffix = "transparency",
   CurrentValue = 0.7,
   Flag = "HitboxTransSlider",
   Callback = function(Value)
      HitboxSettings.Transparency = Value
   end,
})

HitboxTab:CreateToggle({
   Name = "Hitbox Team Check",
   CurrentValue = false,
   Flag = "HitboxTeamToggle",
   Callback = function(Value)
      HitboxSettings.TeamCheck = Value
   end,
})

-- TAB 3: Visuals (ESP)
local VisualsTab = Window:CreateTab("👁️ Visuals", nil)

VisualsTab:CreateSection("ESP Settings")

VisualsTab:CreateToggle({
   Name = "Enable ESP Highlights",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      ESP.Enabled = Value
      updateESP()
   end,
})

VisualsTab:CreateToggle({
   Name = "Enable ESP Names",
   CurrentValue = false,
   Flag = "ESPNamesToggle",
   Callback = function(Value)
      ESP.Names = Value
      updateESP()
   end,
})

VisualsTab:CreateToggle({
   Name = "ESP Team Check",
   CurrentValue = false,
   Flag = "ESPTeamToggle",
   Callback = function(Value)
      ESP.TeamCheck = Value
      updateESP()
   end,
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Value)
        ESP.Color = Value
        updateESP()
    end
})

-- TAB 4: Movement
local MovementTab = Window:CreateTab("⚡ Movement", nil)

MovementTab:CreateSection("Speed & Jump")

MovementTab:CreateToggle({
   Name = "Enable Custom Walkspeed",
   CurrentValue = false,
   Flag = "WSLoopToggle",
   Callback = function(Value)
      Movement.WSLoop = Value
      if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
         LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
      end
   end,
})

MovementTab:CreateSlider({
   Name = "Walkspeed Speed",
   Range = {16, 250},
   Increment = 5,
   Suffix = "speed",
   CurrentValue = 16,
   Flag = "WSSlider",
   Callback = function(Value)
      Movement.WalkSpeed = Value
   end,
})

MovementTab:CreateToggle({
   Name = "Enable Custom Jump Power",
   CurrentValue = false,
   Flag = "JPLoopToggle",
   Callback = function(Value)
      Movement.JPLoop = Value
      if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
         LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50
      end
   end,
})

MovementTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 500},
   Increment = 10,
   Suffix = "power",
   CurrentValue = 50,
   Flag = "JPSlider",
   Callback = function(Value)
      Movement.JumpPower = Value
   end,
})

-- Notification Load Completed
Rayfield:Notify({
   Title = "Nexus FPS V2 Loaded!",
   Content = "Fitur Hitbox, Silent Aim, dan ESP Nama telah diaktifkan!",
   Duration = 5,
   Image = 4483362458,
})
