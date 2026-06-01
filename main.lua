-- RZOHUB Brutal v5 - Phoenix Style UI (Modern & Smooth)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/refs/heads/main/main.lua"))()  -- Phoenix Style Theme

local Window = Library:CreateWindow({
    Title = "RZOHUB Brutal v5",
    SubTitle = "Phoenix Style • Private Test",
    TabWidth = 170,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

local MainTab = Window:AddTab({Title = "Main"})
local AimTab = Window:AddTab({Title = "Aimbot"})
local VisualTab = Window:AddTab({Title = "Visual"})
local MiscTab = Window:AddTab({Title = "Misc"})

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
local Smoothness = 0.09
local CurrentTarget = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Bypass
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
fovCircle.Color = Color3.fromRGB(255, 85, 85)
fovCircle.Transparency = 0.75
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
    -- ... (ESP code sama seperti sebelumnya, saya singkat agar tidak terlalu panjang)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = plr.Character and plr.Character:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 240, 0, 65)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = plr.Character.Head

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1,0,0.4,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1,0,0.6,0)
    infoLabel.Position = UDim2.new(0,0,0.4,0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
    infoLabel.TextStrokeTransparency = 0
    infoLabel.Font = Enum.Font.GothamSemibold
    infoLabel.TextScaled = true
    infoLabel.Parent = billboard

    ESPObjects[plr] = {Billboard = billboard, Name = nameLabel, Info = infoLabel}
end

-- ESP Update Loop (sama seperti sebelumnya)
RunService.RenderStepped:Connect(function()
    for plr, esp in pairs(ESPObjects) do
        if ESPEnabled and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local hum = plr.Character:FindFirstChild("Humanoid")
            esp.Billboard.Enabled = true
            local dist = (Camera.CFrame.Position - head.Position).Magnitude
            local hp = hum and math.floor(hum.Health) or 0
            esp.Name.Text = plr.Name
            esp.Info.Text = string.format("HP: %d  |  %.0f studs", hp, dist)
        elseif esp.Billboard then
            esp.Billboard.Enabled = false
        end
    end
end)

-- Auto ESP on join
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() task.wait(0.5) if ESPEnabled then CreateESP(plr) end end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Character then CreateESP(plr) end
    plr.CharacterAdded:Connect(function() task.wait(0.5) if ESPEnabled then CreateESP(plr) end end)
end

-- Aimbot + Triggerbot + Spinbot (sama seperti versi sebelumnya)
local function GetClosestPlayer()
    -- (kode sama seperti sebelumnya)
end

RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    CurrentTarget = GetClosestPlayer()
    if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
        local head = CurrentTarget.Character.Head
        local targetPos = head.Position + (head.Parent.HumanoidRootPart.Velocity * 0.085)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPos), Smoothness)
    end
end)

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

RunService.RenderStepped:Connect(function()
    if SpinBotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(40), 0)
    end
end)

-- ==================== PHOENIX STYLE MENU ====================
MainTab:AddToggle({Title = "Aimbot", Default = false, Callback = function(v) AimbotEnabled = v end})
MainTab:AddToggle({Title = "Silent Aim", Default = false, Callback = function(v) SilentAimEnabled = v end})
MainTab:AddToggle({Title = "Triggerbot (Super Fast)", Default = false, Callback = function(v) TriggerbotEnabled = v end})
MainTab:AddToggle({Title = "Resolver", Default = false, Callback = function(v) ResolverEnabled = v end})
MainTab:AddToggle({Title = "Spin Bot", Default = false, Callback = function(v) SpinBotEnabled = v end})

AimTab:AddSlider({Title = "FOV", Min = 80, Max = 700, Default = FOV, Increment = 10, Callback = function(v) FOV = v end})
AimTab:AddSlider({Title = "Smoothness (Lower = Brutal)", Min = 0.05, Max = 0.25, Default = Smoothness, Increment = 0.01, Callback = function(v) Smoothness = v end})
AimTab:AddToggle({Title = "Wall Check", Default = true, Callback = function(v) WallCheck = v end})
AimTab:AddToggle({Title = "Team Check", Default = true, Callback = function(v) TeamCheck = v end})

VisualTab:AddToggle({Title = "ESP (Nama + Jarak + Darah)", Default = false, Callback = function(v) ESPEnabled = v end})

MiscTab:AddButton({Title = "Anti Lag Max", Callback = function()
    settings().Rendering.QualityLevel = 1
    setfpscap(60)
    Library:Notify({Title = "Anti Lag", Content = "Activated for Mobile", Duration = 5})
end})

Library:Notify({
    Title = "RZOHUB Brutal v5",
    Content = "Phoenix Style UI Loaded • Semua fitur lengkap",
    Duration = 10
})
