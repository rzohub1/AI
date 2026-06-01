-- RZOHUB Brutal v6 - Rayfield UI (No Smoothness)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "RZOHUB - Brutal v6",
    LoadingTitle = "Loading Rayfield...",
    LoadingSubtitle = "Private Test Environment",
    ConfigurationSaving = { Enabled = true, FolderName = "RZOHUB", FileName = "BrutalV6" }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local AimTab = Window:CreateTab("Aimbot", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Variables
local AimbotEnabled = false
local SilentAimEnabled = false
local TriggerbotEnabled = false
local ResolverEnabled = false
local SpinBotEnabled = false
local ESPEnabled = false
local WallCheck = true
local TeamCheck = true
local FOV = 240
local CurrentTarget = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Extreme Bypass
local mt = getrawmetatable(game)
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if SilentAimEnabled and (method == "FireServer" or method == "InvokeServer") then
        if self.Name:lower():find("bullet") or self.Name:lower():find("hit") or self.Name:lower():find("shoot") then
            if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
                local vel = CurrentTarget.Character.HumanoidRootPart.Velocity
                args[1] = CurrentTarget.Character.Head.Position + vel * 0.085
            end
        end
    end
    return mt.__namecall(self, unpack(args))
end)
setreadonly(mt, true)

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Transparency = 0.8
fovCircle.Filled = false

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Radius = FOV
    fovCircle.Visible = AimbotEnabled
end)

-- Advanced ESP (Nama + Jarak + Darah)
local ESPObjects = {}

local function CreateESP(plr)
    if plr == LocalPlayer or ESPObjects[plr] then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = plr.Character and plr.Character:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 220, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = plr.Character and plr.Character:FindFirstChild("Head")

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

RunService.RenderStepped:Connect(function()
    for plr, esp in pairs(ESPObjects) do
        if ESPEnabled and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local hum = plr.Character:FindFirstChild("Humanoid")
            esp.Billboard.Enabled = true
            local dist = (Camera.CFrame.Position - head.Position).Magnitude
            local hp = hum and math.floor(hum.Health) or 0
            esp.Name.Text = plr.Name
            esp.Info.Text = string.format("HP: %d | %.0f studs", hp, dist)
        elseif esp.Billboard then
            esp.Billboard.Enabled = false
        end
    end
end)

-- Auto ESP
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESPEnabled then CreateESP(plr) end
    end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Character then CreateESP(plr) end
    plr.CharacterAdded:Connect(function() task.wait(0.5); if ESPEnabled then CreateESP(plr) end end)
end

-- Get Closest Player
local function GetClosestPlayer()
    local closest, dist = nil, FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            if TeamCheck and plr.Team == LocalPlayer.Team then continue end
            local head = plr.Character.Head
            local screen, onScreen = Camera:WorldToViewportPoint(head.Position)
            local distance = (Vector2.new(screen.X, screen.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude

            if onScreen and distance < dist then
                if WallCheck then
                    local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 1500)
                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                    if hit and hit:IsDescendantOf(plr.Character) then
                        dist = distance
                        closest = plr
                    end
                else
                    dist = distance
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- Aimbot Loop (Tanpa Smoothness = Langsung Brutal)
RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    CurrentTarget = GetClosestPlayer()
    if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
        local head = CurrentTarget.Character.Head
        local targetPos = head.Position + (head.Parent.HumanoidRootPart.Velocity * 0.085)
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    end
end)

-- Fast Triggerbot
RunService.Heartbeat:Connect(function()
    if not TriggerbotEnabled or not CurrentTarget then return end
    local char = CurrentTarget.Character
    if char and char:FindFirstChild("Head") then
        local ray = Ray.new(Camera.CFrame.Position, (char.Head.Position - Camera.CFrame.Position).Unit * 1200)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
        if hit and hit:IsDescendantOf(char) then
            mouse1click()
            task.wait(0.03)
        end
    end
end)

-- Spin Bot
RunService.RenderStepped:Connect(function()
    if SpinBotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(40), 0)
    end
end)

-- ==================== RAYFIELD MENU ====================
MainTab:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(v) AimbotEnabled = v end})
MainTab:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) SilentAimEnabled = v end})
MainTab:CreateToggle({Name = "Triggerbot (Fast)", CurrentValue = false, Callback = function(v) TriggerbotEnabled = v end})
MainTab:CreateToggle({Name = "Resolver", CurrentValue = false, Callback = function(v) ResolverEnabled = v end})
MainTab:CreateToggle({Name = "Spin Bot", CurrentValue = false, Callback = function(v) SpinBotEnabled = v end})

AimTab:CreateSlider({Name = "FOV", Range = {80, 700}, Increment = 10, CurrentValue = FOV, Callback = function(v) FOV = v end})
AimTab:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(v) WallCheck = v end})
AimTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) TeamCheck = v end})

VisualTab:CreateToggle({Name = "ESP (Nama + Jarak + Darah)", CurrentValue = false, Callback = function(v) ESPEnabled = v end})

MiscTab:CreateButton({Name = "Anti Lag Max", Callback = function()
    settings().Rendering.QualityLevel = 1
    setfpscap(60)
    Rayfield:Notify({Title = "Anti Lag", Content = "Activated!", Duration = 5})
end})

Rayfield:Notify({
    Title = "Brutal v6 Loaded",
    Content = "Rayfield UI • Smoothness dihapus (Aimbot lebih brutal)",
    Duration = 10
})
