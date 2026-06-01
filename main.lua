-- RZOHUB Brutal Private Test - Delta Executor
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "RZOHUB - Brutal v2",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Delta Executor Mobile",
    ConfigurationSaving = { Enabled = true, FolderName = "RZOHUB", FileName = "BrutalV2" }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local AimTab = Window:CreateTab("Aimbot", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Variables
local AimbotEnabled = false
local SilentAimEnabled = false
local TriggerbotEnabled = false
local ResolverEnabled = false
local SpinBotEnabled = false
local WallCheck = true
local TeamCheck = true
local FOV = 240
local Smoothness = 0.09   -- Sangat lengket
local CurrentTarget = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== EXTREME BYPASS ====================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if SilentAimEnabled and (method == "FireServer" or method == "InvokeServer") then
        if self.Name:lower():find("bullet") or self.Name:lower():find("hit") or self.Name:lower():find("shoot") then
            if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
                local vel = CurrentTarget.Character.HumanoidRootPart.Velocity
                args[1] = CurrentTarget.Character.Head.Position + vel * 0.085  -- Strong Prediction
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Transparency = 0.75
fovCircle.Filled = false

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Radius = FOV
    fovCircle.Visible = AimbotEnabled
end)

-- Resolver Function
local function GetResolvedPosition(head)
    if not ResolverEnabled then 
        return head.Position 
    end
    local vel = head.Parent.HumanoidRootPart.Velocity
    return head.Position + vel * 0.1 + Vector3.new(0, 0.5, 0)  -- Basic Resolver
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

-- Aimbot Loop (Brutal + Resolver)
RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    CurrentTarget = GetClosestPlayer()

    if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
        local head = CurrentTarget.Character.Head
        local targetPos = GetResolvedPosition(head) + (head.Parent.HumanoidRootPart.Velocity * 0.08)
        
        local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Smoothness)
    end
end)

-- Fast Triggerbot (Auto Shoot Cepat)
RunService.Heartbeat:Connect(function()
    if not TriggerbotEnabled or not CurrentTarget then return end
    local char = CurrentTarget.Character
    if char and char:FindFirstChild("Head") then
        local ray = Ray.new(Camera.CFrame.Position, (char.Head.Position - Camera.CFrame.Position).Unit * 1200)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
        
        if hit and hit:IsDescendantOf(char) then
            mouse1click()
            task.wait(0.035) -- Lebih cepat (sebelumnya 0.08)
        end
    end
end)

-- Spin Bot
RunService.RenderStepped:Connect(function()
    if not SpinBotEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(35), 0)  -- Spin Speed
end)

-- ==================== UI ====================
MainTab:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(v) AimbotEnabled = v end})
MainTab:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) SilentAimEnabled = v end})
MainTab:CreateToggle({Name = "Triggerbot (Fast)", CurrentValue = false, Callback = function(v) TriggerbotEnabled = v end})
MainTab:CreateToggle({Name = "Resolver", CurrentValue = false, Callback = function(v) ResolverEnabled = v end})
MainTab:CreateToggle({Name = "Spin Bot", CurrentValue = false, Callback = function(v) SpinBotEnabled = v end})

AimTab:CreateSlider({Name = "FOV", Range = {80, 650}, Increment = 10, CurrentValue = FOV, Callback = function(v) FOV = v end})
AimTab:CreateSlider({Name = "Smoothness (Lower = Brutal)", Range = {0.05, 0.25}, Increment = 0.01, CurrentValue = Smoothness, Callback = function(v) Smoothness = v end})

AimTab:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(v) WallCheck = v end})
AimTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) TeamCheck = v end})

MiscTab:CreateButton({Name = "Anti Lag (Max)", Callback = function()
    settings().Rendering.QualityLevel = 1
    setfpscap(60)
    Rayfield:Notify({Title = "Anti Lag", Content = "Activated!", Duration = 4})
end})

Rayfield:Notify({
    Title = "Brutal v2 Loaded",
    Content = "Resolver + Fast Triggerbot + Spin Bot sudah aktif",
    Duration = 10
})
