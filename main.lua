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

-- Variables & Settings
local AimbotSettings = {
    Enabled = false,
    TargetPart = "Head",
    Smoothness = 0.1,
    FOVEnabled = true,
    Radius = 100,
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

-- FOV Circle setup for PC/Mobile
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = AimbotSettings.Radius
FOVCircle.Filled = false
FOVCircle.Visible = AimbotSettings.FOVEnabled

-- Update FOV Circle Position
RunService.RenderStepped:Connect(function()
    local mouseLoc = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouseLoc.X, mouseLoc.Y)
    FOVCircle.Radius = AimbotSettings.Radius
    FOVCircle.Visible = AimbotSettings.Enabled and AimbotSettings.FOVEnabled
end)

-- Helper: Get Closest Player inside FOV
local function getClosestPlayer()
    local target = nil
    local maxDistance = AimbotSettings.Radius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimbotSettings.TargetPart) and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local screenPoint, onScreen = Camera:WorldToViewportPoint(player.Character[AimbotSettings.TargetPart].Position)
            if onScreen then
                local mouseLoc = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mouseLoc.X, mouseLoc.Y)).Magnitude
                if distance < maxDistance then
                    target = player
                    maxDistance = distance
                end
            end
        end
    end
    return target
end

-- Aimbot Thread Loop
RunService.RenderStepped:Connect(function()
    if AimbotSettings.Enabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(AimbotSettings.TargetPart) then
            local targetPos = target.Character[AimbotSettings.TargetPart].Position
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSettings.Smoothness)
        end
    end
end)

-- ESP System using Highlight (Native Roblox & Mobile Optimized)
local highlights = {}

local function addESP(player)
    if player == LocalPlayer then return end

    local function setupHighlight(char)
        if not char then return end
        
        -- Remove existing highlight if any
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end

        if ESP.Enabled then
            if ESP.TeamCheck and player.Team == LocalPlayer.Team then return end
            
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Adornee = char
            highlight.FillColor = ESP.Color
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = char
            
            highlights[player] = highlight
        end
    end

    player.CharacterAdded:Connect(setupHighlight)
    if player.Character then
        setupHighlight(player.Character)
    end
end

local function removeESP(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end

-- Monitor player joins/leaves for ESP
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

-- Movement Loop (Keep Speed & Jump Power Applied)
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

-- TAB 1: Combat (Aimbot)
local CombatTab = Window:CreateTab("🎯 Combat", nil)

CombatTab:CreateSection("Aimbot Settings")

CombatTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
      AimbotSettings.Enabled = Value
   end,
})

CombatTab:CreateDropdown({
   Name = "Target Part",
   Options = {"Head", "Torso"},
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

CombatTab:CreateSection("FOV Settings")

CombatTab:CreateToggle({
   Name = "Show FOV Circle",
   CurrentValue = true,
   Flag = "FOVToggle",
   Callback = function(Value)
      AimbotSettings.FOVEnabled = Value
   end,
})

CombatTab:CreateSlider({
   Name = "FOV Radius",
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
   Name = "Team Check",
   CurrentValue = false,
   Flag = "TeamCheckToggle",
   Callback = function(Value)
      AimbotSettings.TeamCheck = Value
   end,
})

-- TAB 2: Visuals (ESP)
local VisualsTab = Window:CreateTab("👁️ Visuals", nil)

VisualsTab:CreateSection("ESP Settings")

VisualsTab:CreateToggle({
   Name = "Enable Player Highlight ESP",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      ESP.Enabled = Value
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
    Name = "ESP Highlight Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Value)
        ESP.Color = Value
        updateESP()
    end
})

-- TAB 3: Movement
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
   Title = "Nexus FPS Loaded!",
   Content = "Script berhasil dimuat. Nikmati permainan!",
   Duration = 5,
   Image = 4483362458,
})
