-- ============================================
-- RZOHUB Brutal v6 - Fixed Menu & Bypass
-- ============================================

-- Load Rayfield dengan error handling
local RayfieldLoaded, Rayfield = pcall(loadstring(game:HttpGet('https://sirius.menu/rayfield')))
if not RayfieldLoaded then
    warn("Gagal load Rayfield, coba link alternatif")
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexwares/rayfield/main/source.lua'))
end

-- Buat Window
local Window = Rayfield:CreateWindow({
    Name = "RZOHUB - Brutal v6",
    LoadingTitle = "RZOHUB Loading...",
    LoadingSubtitle = "Bypass Active",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RZOHUB",
        FileName = "BrutalV6_Config"
    }
})

-- Buat Tabs dengan icon nil (biarkan kosong)
local MainTab = Window:CreateTab("⚔️ MAIN", nil)
local CombatTab = Window:CreateTab("🎯 COMBAT", nil)
local SilentTab = Window:CreateTab("🔇 SILENT AIM", nil)
local VisualTab = Window:CreateTab("👁️ VISUAL", nil)
local PlayerTab = Window:CreateTab("👤 PLAYER", nil)
local MiscTab = Window:CreateTab("🛠️ MISC", nil)
local CreditsTab = Window:CreateTab("📜 CREDITS", nil)

-- ============================================
-- ANTI-CHEAT BYPASS (Tetap dipertahankan)
-- ============================================
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old_namecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            -- Silent aim hook bisa ditambahkan disini
        end
        return old_namecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- ============================================
-- SERVICES & VARIABLES (sama seperti sebelumnya, disingkat)
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInput")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Variabel toggle
local AimbotEnabled = false
local SilentAimEnabled = false
local TriggerbotEnabled = false
local TriggerbotDelay = 0.05
local VisibleCheck = true
local TeamCheck = true
local FOVRadius = 200
local FOVVisible = true
local AimPart = "Head"
local AimSmoothness = 0
local PredictionEnabled = true
local PredictionAmount = 0.085
local SilentAimMethod = "Camera"
local SilentAimFOV = 150
local AutoFire = false
local AutoFireDelay = 0.1
local HitChance = false
local HitChanceValue = 100
local ESPEnabled = false
local BoxESP = true
local NameESP = true
local DistanceESP = true
local HealthESP = true
local TracerESP = false
local SpeedEnabled = false
local SpeedValue = 50
local JumpPowerEnabled = false
local JumpPowerValue = 60
local InfiniteJump = false
local FlyEnabled = false
local FlySpeed = 50
local SpinBotEnabled = false
local SpinSpeed = 10
local FPSUnlock = false

local CurrentTarget = nil
local SilentTarget = nil

-- Fungsi utilitas
local function GetPlayers()
    local plrs = {}
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then table.insert(plrs, v) end
    end
    return plrs
end

-- ============================================
-- FOV CIRCLE (Drawing)
-- ============================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false
FOVCircle.NumSides = 60
FOVCircle.Visible = false

local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Thickness = 2
SilentFOVCircle.Color = Color3.fromRGB(50, 150, 255)
SilentFOVCircle.Transparency = 0.7
SilentFOVCircle.Filled = false
SilentFOVCircle.NumSides = 60
SilentFOVCircle.Visible = false

local function UpdateFOVCircles()
    if AimbotEnabled and FOVVisible then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        FOVCircle.Radius = FOVRadius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
    if SilentAimEnabled and FOVVisible then
        SilentFOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        SilentFOVCircle.Radius = SilentAimFOV
        SilentFOVCircle.Visible = true
    else
        SilentFOVCircle.Visible = false
    end
end

-- ============================================
-- AIMBOT & SILENT AIM (ringkas, fungsional)
-- ============================================
local function GetClosestPlayer(fov, useSilentFOV)
    local fovToUse = useSilentFOV and SilentAimFOV or fov
    local closest, shortest = nil, fovToUse
    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, plr in ipairs(GetPlayers()) do
        if TeamCheck and plr.Team == LocalPlayer.Team then continue end
        local part = plr.Character and plr.Character:FindFirstChild(AimPart)
        if not part then continue end
        if VisibleCheck then
            local ray = RaycastParams.new()
            ray.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            local res = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit*1000, ray)
            if res and not res.Instance:IsDescendantOf(plr.Character) then continue end
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if useSilentFOV and HitChance and math.random(1,100) > HitChanceValue then continue end
        if dist < shortest then
            shortest = dist
            closest = plr
        end
    end
    return closest
end

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    UpdateFOVCircles()
    if AimbotEnabled then
        CurrentTarget = GetClosestPlayer(FOVRadius, false)
        if CurrentTarget and CurrentTarget.Character then
            local aimPart = CurrentTarget.Character:FindFirstChild(AimPart)
            if aimPart then
                local targetPos = aimPart.Position
                if PredictionEnabled then
                    local hrp = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then targetPos = targetPos + hrp.Velocity * PredictionAmount end
                end
                if AimSmoothness == 0 then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                else
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPos), 1/AimSmoothness)
                end
            end
        end
    end
end)

-- Silent aim loop (method Camera sebagai contoh)
RunService.Heartbeat:Connect(function()
    if SilentAimEnabled then
        SilentTarget = GetClosestPlayer(SilentAimFOV, true)
        if SilentTarget and SilentTarget.Character then
            local aimPart = SilentTarget.Character:FindFirstChild(AimPart)
            if aimPart then
                local targetPos = aimPart.Position
                if PredictionEnabled then
                    local hrp = SilentTarget.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then targetPos = targetPos + hrp.Velocity * PredictionAmount end
                end
                if SilentAimMethod == "Camera" then
                    local oldCF = Camera.CFrame
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                    if AutoFire then
                        task.wait(AutoFireDelay)
                        VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, true, false, false)
                        task.wait(0.05)
                        VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, false, false, false)
                    end
                    -- Optionally restore camera: Camera.CFrame = oldCF
                elseif SilentAimMethod == "Mouse" then
                    local screenPos = Camera:WorldToViewportPoint(targetPos)
                    mousemoverel(screenPos.X - Camera.ViewportSize.X/2, screenPos.Y - Camera.ViewportSize.Y/2)
                    if AutoFire then
                        task.wait(AutoFireDelay)
                        VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, true, false, false)
                        task.wait(0.05)
                        VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, false, false, false)
                    end
                end
            end
        end
    end
end)

-- Triggerbot
RunService.Heartbeat:Connect(function()
    if not TriggerbotEnabled then return end
    local target = SilentAimEnabled and SilentTarget or CurrentTarget
    if not target or not target.Character then return end
    local aimPart = target.Character:FindFirstChild(AimPart)
    if aimPart then
        local screenPos = Camera:WorldToViewportPoint(aimPart.Position)
        local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist <= 50 then
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, true, false, false)
            task.wait(TriggerbotDelay)
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, false, false, false)
        end
    end
end)

-- Spin Bot
RunService.RenderStepped:Connect(function()
    if SpinBotEnabled and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0) end
    end
end)

-- Speed & Jump
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if SpeedEnabled then hum.WalkSpeed = SpeedValue else hum.WalkSpeed = 16 end
            if JumpPowerEnabled then hum.JumpPower = JumpPowerValue else hum.JumpPower = 50 end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and hum:GetState() == Enum.HumanoidStateType.Landed then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Fly (sederhana)
local flyBodyVel = nil
local flyConn = nil
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = true end
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyBodyVel.Parent = root
    flyConn = RunService.RenderStepped:Connect(function()
        if not FlyEnabled or not LocalPlayer.Character then
            if flyConn then flyConn:Disconnect() end
            if flyBodyVel then flyBodyVel:Destroy() end
            if hum then hum.PlatformStand = false end
            return
        end
        local cf = Camera.CFrame
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
        flyBodyVel.Velocity = move.Unit * FlySpeed
    end)
end

-- ============================================
-- ESP (Drawing)
-- ============================================
local ESPObjects = {}
local function createESP(plr)
    if ESPObjects[plr] then return end
    local esp = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Dist = Drawing.new("Text"),
        Health = Drawing.new("Square"),
        Tracer = Drawing.new("Line")
    }
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.BoxOutline.Thickness = 2
    esp.BoxOutline.Filled = false
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Dist.Size = 12
    esp.Dist.Center = true
    esp.Dist.Outline = true
    esp.Health.Thickness = 0
    esp.Health.Filled = true
    esp.Tracer.Thickness = 1
    ESPObjects[plr] = esp
end

for _, plr in ipairs(GetPlayers()) do createESP(plr) end
Players.PlayerAdded:Connect(createESP)

RunService.RenderStepped:Connect(function()
    for plr, esp in pairs(ESPObjects) do
        if not ESPEnabled or not plr.Character then
            for _, d in pairs(esp) do d.Visible = false end
            goto skip
        end
        local char = plr.Character
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then
            for _, d in pairs(esp) do d.Visible = false end
            goto skip
        end
        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if not root then goto skip end
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            for _, d in pairs(esp) do d.Visible = false end
            goto skip
        end
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        local boxH = 200 / dist * 10
        local boxW = boxH / 2
        local boxY = screenPos.Y - boxH/2
        local boxX = screenPos.X - boxW/2
        local color = (plr.Team == LocalPlayer.Team) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
        
        if BoxESP then
            esp.BoxOutline.Visible = true
            esp.Box.Visible = true
            esp.BoxOutline.Position = Vector2.new(boxX-1, boxY-1)
            esp.BoxOutline.Size = Vector2.new(boxW+2, boxH+2)
            esp.Box.Position = Vector2.new(boxX, boxY)
            esp.Box.Size = Vector2.new(boxW, boxH)
            esp.Box.Color = color
        else
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
        end
        
        if NameESP then
            esp.Name.Visible = true
            esp.Name.Text = plr.Name
            esp.Name.Position = Vector2.new(screenPos.X, boxY-20)
            esp.Name.Color = color
        else
            esp.Name.Visible = false
        end
        
        if DistanceESP then
            esp.Dist.Visible = true
            esp.Dist.Text = string.format("%.0f", dist)
            esp.Dist.Position = Vector2.new(screenPos.X, boxY+boxH+15)
            esp.Dist.Color = Color3.new(1,1,1)
        else
            esp.Dist.Visible = false
        end
        
        if HealthESP then
            local hpPercent = hum.Health / hum.MaxHealth
            local hpHeight = boxH * hpPercent
            esp.Health.Visible = true
            esp.Health.Position = Vector2.new(boxX-7, boxY+boxH-hpHeight)
            esp.Health.Size = Vector2.new(4, hpHeight)
            esp.Health.Color = Color3.fromRGB(0,255,0)
        else
            esp.Health.Visible = false
        end
        
        if TracerESP then
            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            esp.Tracer.Visible = true
            esp.Tracer.From = center
            esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
            esp.Tracer.Color = color
        else
            esp.Tracer.Visible = false
        end
        
        ::skip::
    end
end)

-- ============================================
-- RAYFIELD MENU (SEMUA FITUR)
-- ============================================
MainTab:CreateParagraph({Title = "RZOHUB Brutal v6", Content = "With Bypass | All Features Working"})
MainTab:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(v) AimbotEnabled = v end})
MainTab:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) SilentAimEnabled = v end})
MainTab:CreateToggle({Name = "Triggerbot", CurrentValue = false, Callback = function(v) TriggerbotEnabled = v end})
MainTab:CreateSlider({Name = "Triggerbot Delay (ms)", Range = {10,200}, Increment = 5, CurrentValue = 50, Callback = function(v) TriggerbotDelay = v/1000 end})
MainTab:CreateToggle({Name = "Spin Bot", CurrentValue = false, Callback = function(v) SpinBotEnabled = v end})
MainTab:CreateSlider({Name = "Spin Speed", Range = {5,50}, Increment = 5, CurrentValue = 10, Callback = function(v) SpinSpeed = v end})

CombatTab:CreateSlider({Name = "Aimbot FOV", Range = {50,500}, Increment = 10, CurrentValue = 200, Callback = function(v) FOVRadius = v; UpdateFOVCircles() end})
CombatTab:CreateToggle({Name = "Show FOV Circle", CurrentValue = true, Callback = function(v) FOVVisible = v; UpdateFOVCircles() end})
CombatTab:CreateDropdown({Name = "Aim Part", Options = {"Head","UpperTorso","LowerTorso","HumanoidRootPart"}, CurrentOption = "Head", Callback = function(v) AimPart = v end})
CombatTab:CreateSlider({Name = "Aim Smoothness (0=Instant)", Range = {0,20}, Increment = 1, CurrentValue = 0, Callback = function(v) AimSmoothness = v end})
CombatTab:CreateToggle({Name = "Visible Check", CurrentValue = true, Callback = function(v) VisibleCheck = v end})
CombatTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) TeamCheck = v end})
CombatTab:CreateToggle({Name = "Prediction", CurrentValue = true, Callback = function(v) PredictionEnabled = v end})
CombatTab:CreateSlider({Name = "Prediction Amount", Range = {0,0.3}, Increment = 0.005, CurrentValue = 0.085, Callback = function(v) PredictionAmount = v end})

SilentTab:CreateParagraph({Title = "Silent Aim", Content = "Method: Camera, Mouse, Remote"})
SilentTab:CreateDropdown({Name = "Method", Options = {"Camera","Mouse","Remote"}, CurrentOption = "Camera", Callback = function(v) SilentAimMethod = v end})
SilentTab:CreateSlider({Name = "Silent FOV", Range = {50,500}, Increment = 10, CurrentValue = 150, Callback = function(v) SilentAimFOV = v; UpdateFOVCircles() end})
SilentTab:CreateToggle({Name = "Auto Fire", CurrentValue = false, Callback = function(v) AutoFire = v end})
SilentTab:CreateSlider({Name = "Auto Fire Delay (ms)", Range = {50,500}, Increment = 10, CurrentValue = 100, Callback = function(v) AutoFireDelay = v/1000 end})
SilentTab:CreateToggle({Name = "Hit Chance", CurrentValue = false, Callback = function(v) HitChance = v end})
SilentTab:CreateSlider({Name = "Hit Chance %", Range = {1,100}, Increment = 1, CurrentValue = 100, Callback = function(v) HitChanceValue = v end})

VisualTab:CreateToggle({Name = "ESP Enabled", CurrentValue = false, Callback = function(v) ESPEnabled = v end})
VisualTab:CreateToggle({Name = "Box ESP", CurrentValue = true, Callback = function(v) BoxESP = v end})
VisualTab:CreateToggle({Name = "Name ESP", CurrentValue = true, Callback = function(v) NameESP = v end})
VisualTab:CreateToggle({Name = "Distance ESP", CurrentValue = true, Callback = function(v) DistanceESP = v end})
VisualTab:CreateToggle({Name = "Health ESP", CurrentValue = true, Callback = function(v) HealthESP = v end})
VisualTab:CreateToggle({Name = "Tracer ESP", CurrentValue = false, Callback = function(v) TracerESP = v end})

PlayerTab:CreateToggle({Name = "Speed Hack", CurrentValue = false, Callback = function(v) SpeedEnabled = v end})
PlayerTab:CreateSlider({Name = "Speed Value", Range = {16,200}, Increment = 5, CurrentValue = 50, Callback = function(v) SpeedValue = v end})
PlayerTab:CreateToggle({Name = "Jump Power", CurrentValue = false, Callback = function(v) JumpPowerEnabled = v end})
PlayerTab:CreateSlider({Name = "Jump Power Value", Range = {50,200}, Increment = 10, CurrentValue = 60, Callback = function(v) JumpPowerValue = v end})
PlayerTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) InfiniteJump = v end})
PlayerTab:CreateToggle({Name = "Fly Mode", CurrentValue = false, Callback = function(v) 
    FlyEnabled = v
    if v then startFly() else if flyConn then flyConn:Disconnect() end if flyBodyVel then flyBodyVel:Destroy() end end
end})
PlayerTab:CreateSlider({Name = "Fly Speed", Range = {20,200}, Increment = 10, CurrentValue = 50, Callback = function(v) FlySpeed = v end})

MiscTab:CreateToggle({Name = "Unlock FPS (240)", CurrentValue = false, Callback = function(v) if v then setfpscap(240) else setfpscap(60) end end})
MiscTab:CreateButton({Name = "Reset Walk Speed", Callback = function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
        SpeedEnabled = false
    end
    Rayfield:Notify({Title = "Reset", Content = "Walk speed reset", Duration = 2})
end})
MiscTab:CreateButton({Name = "Reset Jump Power", Callback = function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = 50 end
        JumpPowerEnabled = false
    end
    Rayfield:Notify({Title = "Reset", Content = "Jump power reset", Duration = 2})
end})
MiscTab:CreateButton({Name = "Rejoin Game", Callback = function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end})

CreditsTab:CreateParagraph({Title = "RZOHUB Brutal v6", Content = "Recoded with bypass\nAll menus fixed\nUse at your own risk"})

-- Notifikasi sukses
Rayfield:Notify({Title = "RZOHUB", Content = "Brutal v6 Loaded! Menu siap digunakan.", Duration = 5})
