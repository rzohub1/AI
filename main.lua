-- ============================================
-- RZOHUB Brutal v6 - Full Recode + Bypass
-- Rayfield UI Framework
-- WITH ANTI-CHEAT BYPASS (USE AT YOUR OWN RISK)
-- ============================================

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ============================================
-- ANTI-CHEAT BYPASS
-- ============================================
local success, err = pcall(function()
    -- Bypass metatable protection
    local mt = getrawmetatable(game)
    local old_namecall = mt.__namecall
    local old_index = mt.__index
    local old_newindex = mt.__newindex
    
    setreadonly(mt, false)
    
    -- Bypass namecall (FireServer, InvokeServer, etc)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Silent aim hook untuk projectiles
        if method == "FireServer" or method == "InvokeServer" then
            local selfStr = tostring(self)
            if selfStr:lower():find("bullet") or 
               selfStr:lower():find("projectile") or 
               selfStr:lower():find("shoot") or 
               selfStr:lower():find("fire") or
               selfStr:lower():find("weapon") then
                -- Redirect untuk silent aim
            end
        end
        
        return old_namecall(self, unpack(args))
    end)
    
    -- Bypass checkers
    mt.__index = newcclosure(function(self, key)
        if key == "Health" and self:IsA("Humanoid") then
            return old_index(self, key)
        end
        if key == "WalkSpeed" or key == "JumpPower" then
            return old_index(self, key)
        end
        return old_index(self, key)
    end)
    
    -- Bypass write restrictions
    mt.__newindex = newcclosure(function(self, key, value)
        local success, err = pcall(function()
            old_newindex(self, key, value)
        end)
        if not success then
            rawset(self, key, value)
        end
    end)
    
    setreadonly(mt, true)
    
    -- Disable remote event logs (optional)
    if game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui") then
        game:GetService("CoreGui").RobloxPromptGui.Enabled = false
    end
    
    -- Bypass admin scripts
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("LocalScript") and (v.Name:lower():find("anticheat") or v.Name:lower():find("anti-cheat")) then
            v:Disable()
        end
    end
end)

-- ============================================
-- UI WINDOW & TABS
-- ============================================
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

-- Create Tabs
local MainTab = Window:CreateTab("⚔️ MAIN", nil)
local CombatTab = Window:CreateTab("🎯 COMBAT", nil)
local SilentTab = Window:CreateTab("🔇 SILENT AIM", nil)
local VisualTab = Window:CreateTab("👁️ VISUAL", nil)
local PlayerTab = Window:CreateTab("👤 PLAYER", nil)
local MiscTab = Window:CreateTab("🛠️ MISC", nil)
local CreditsTab = Window:CreateTab("📜 CREDITS", nil)

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInput = game:GetService("VirtualInput")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- VARIABLES
-- ============================================
-- Combat
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

-- Silent Aim specific
local SilentAimMethod = "Camera" -- Camera, Mouse, Remote
local SilentAimFOV = 150
local AutoFire = false
local AutoFireDelay = 0.1
local HitChance = 100
local HitChanceValue = 100

-- Visual
local ESPEnabled = false
local BoxESP = true
local NameESP = true
local DistanceESP = true
local HealthESP = true
local TracerESP = false
local ChamsEnabled = false
local ChamsColor = Color3.fromRGB(255, 0, 0)

-- Player
local SpeedEnabled = false
local SpeedValue = 50
local JumpPowerEnabled = false
local JumpPowerValue = 60
local InfiniteJump = false
local NoClipEnabled = false
local FlyEnabled = false
local FlySpeed = 50

-- Misc
local SpinBotEnabled = false
local SpinSpeed = 10
local FPSUnlock = false

-- Target
local CurrentTarget = nil
local CurrentAimPosition = nil
local SilentTarget = nil

-- ESP Storage
local ESPList = {}

-- Remote storage untuk silent aim
local WeaponRemote = nil
local CurrentWeapon = nil

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function IsAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function GetPlayers()
    local plrs = {}
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            table.insert(plrs, v)
        end
    end
    return plrs
end

-- Get current weapon
local function GetCurrentWeapon()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local tool = character:FindFirstChildWhichIsA("Tool")
    if tool then
        return tool
    end
    
    local backpack = LocalPlayer.Backpack
    local equipped = backpack:FindFirstChildWhichIsA("Tool")
    if equipped then
        return equipped
    end
    
    return nil
end

-- Find weapon remote
local function FindWeaponRemote(weapon)
    if not weapon then return nil end
    
    for _, v in pairs(weapon:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            if v.Name:lower():find("shoot") or 
               v.Name:lower():find("fire") or 
               v.Name:lower():find("attack") or
               v.Name:lower():find("bullet") then
                return v
            end
        end
    end
    
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            if v.Name:lower():find("shoot") or 
               v.Name:lower():find("fire") or 
               v.Name:lower():find("attack") then
                return v
            end
        end
    end
    
    return nil
end

-- ============================================
-- FOV CIRCLE
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
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = FOVRadius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
    
    if SilentAimEnabled and FOVVisible then
        SilentFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        SilentFOVCircle.Radius = SilentAimFOV
        SilentFOVCircle.Visible = true
    else
        SilentFOVCircle.Visible = false
    end
end

-- ============================================
-- AIMBOT CORE
-- ============================================
local function GetClosestPlayerToCursor(useSilentFOV)
    local fovToUse = useSilentFOV and SilentAimFOV or FOVRadius
    local closestPlayer = nil
    local shortestDistance = fovToUse
    local mousePosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(GetPlayers()) do
        if not player.Character then continue end
        
        -- Team check
        if TeamCheck and player.Team == LocalPlayer.Team then
            continue
        end
        
        local targetPart = player.Character:FindFirstChild(AimPart)
        if not targetPart then continue end
        
        -- Visible check
        if VisibleCheck then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            local rayResult = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000, raycastParams)
            if rayResult and not rayResult.Instance:IsDescendantOf(player.Character) then
                continue
            end
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePosition).Magnitude
        
        -- Hit chance check
        if useSilentFOV and HitChance then
            local random = math.random(1, 100)
            if random > HitChanceValue then
                goto continue
            end
        end
        
        if distance < shortestDistance then
            shortestDistance = distance
            closestPlayer = player
        end
        
        ::continue::
    end
    
    return closestPlayer
end

local function GetPredictedPosition(target)
    if not PredictionEnabled then return target.Position end
    
    local hrp = target.Parent:FindFirstChild("HumanoidRootPart")
    if hrp then
        return target.Position + (hrp.Velocity * PredictionAmount)
    end
    return target.Position
end

-- Aimbot Update
RunService.RenderStepped:Connect(function()
    UpdateFOVCircles()
    
    if not AimbotEnabled then
        CurrentTarget = nil
        return
    end
    
    CurrentTarget = GetClosestPlayerToCursor(false)
    
    if CurrentTarget and CurrentTarget.Character then
        local aimPart = CurrentTarget.Character:FindFirstChild(AimPart)
        if aimPart then
            local targetPosition = GetPredictedPosition(aimPart)
            CurrentAimPosition = targetPosition
            
            if AimSmoothness == 0 then
                -- Instant aim
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPosition)
            else
                -- Smoothed aim
                local currentCF = Camera.CFrame
                local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPosition)
                Camera.CFrame = currentCF:Lerp(targetCF, 1 / AimSmoothness)
            end
        end
    end
end)

-- ============================================
-- SILENT AIM (DENGAN BYPASS)
-- ============================================
local function GetSilentTarget()
    return GetClosestPlayerToCursor(true)
end

-- Method 1: Camera-based silent aim (most compatible)
local function SilentAimCamera()
    if not SilentAimEnabled then return end
    
    SilentTarget = GetSilentTarget()
    
    if SilentTarget and SilentTarget.Character then
        local aimPart = SilentTarget.Character:FindFirstChild(AimPart)
        if aimPart then
            local targetPos = GetPredictedPosition(aimPart)
            
            -- Temporarily change camera CFrame
            local originalCF = Camera.CFrame
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            
            -- Auto fire jika enabled
            if AutoFire then
                task.wait(AutoFireDelay)
                VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, true, false, false)
                task.wait(0.05)
                VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, false, false, false)
            end
            
            -- Kembalikan camera setelah frame (optional)
            -- Camera.CFrame = originalCF
        end
    end
end

-- Method 2: Mouse-based silent aim
local function SilentAimMouse()
    if not SilentAimEnabled then return end
    
    SilentTarget = GetSilentTarget()
    
    if SilentTarget and SilentTarget.Character then
        local aimPart = SilentTarget.Character:FindFirstChild(AimPart)
        if aimPart then
            local targetPos = GetPredictedPosition(aimPart)
            local screenPos = Camera:WorldToViewportPoint(targetPos)
            
            -- Move mouse to target position
            mousemoverel(screenPos.X - Camera.ViewportSize.X/2, screenPos.Y - Camera.ViewportSize.Y/2)
            
            -- Auto fire
            if AutoFire then
                task.wait(AutoFireDelay)
                VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, true, false, false)
                task.wait(0.05)
                VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, false, false, false)
            end
        end
    end
end

-- Method 3: Remote-based silent aim (advanced bypass)
local function SilentAimRemote()
    if not SilentAimEnabled then return end
    
    local weapon = GetCurrentWeapon()
    if not weapon then return end
    
    local remote = FindWeaponRemote(weapon)
    if not remote then return end
    
    SilentTarget = GetSilentTarget()
    
    if SilentTarget and SilentTarget.Character then
        local aimPart = SilentTarget.Character:FindFirstChild(AimPart)
        if aimPart then
            local targetPos = GetPredictedPosition(aimPart)
            
            -- Hook ke remote event
            local oldFire = remote.FireServer
            remote.FireServer = function(self, ...)
                local args = {...}
                -- Modify args untuk silent aim
                if #args >= 1 then
                    if type(args[1]) == "Vector3" then
                        args[1] = targetPos
                    elseif type(args[1]) == "CFrame" then
                        args[1] = CFrame.lookAt(args[1].Position, targetPos)
                    end
                end
                return oldFire(self, unpack(args))
            end
            
            -- Trigger fire
            if AutoFire then
                VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, true, false, false)
                task.wait(0.05)
                VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, false, false, false)
            end
            
            -- Restore
            remote.FireServer = oldFire
        end
    end
end

-- Silent aim selection
local function OnSilentAimUpdate()
    if not SilentAimEnabled then return end
    
    if SilentAimMethod == "Camera" then
        SilentAimCamera()
    elseif SilentAimMethod == "Mouse" then
        SilentAimMouse()
    elseif SilentAimMethod == "Remote" then
        SilentAimRemote()
    end
end

-- Silent aim loop
RunService.Heartbeat:Connect(OnSilentAimUpdate)

-- ============================================
-- TRIGGERBOT
-- ============================================
local TriggerbotConnection = nil

local function StartTriggerbot()
    if TriggerbotConnection then
        TriggerbotConnection:Disconnect()
        TriggerbotConnection = nil
    end
    
    if not TriggerbotEnabled then return end
    
    TriggerbotConnection = RunService.Heartbeat:Connect(function()
        local targetToUse = SilentAimEnabled and SilentTarget or CurrentTarget
        
        if not targetToUse or not targetToUse.Character then return end
        
        local aimPart = targetToUse.Character:FindFirstChild(AimPart)
        if not aimPart then return end
        
        -- Check if aiming at target
        local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then return end
        
        local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        
        if distance <= 50 then -- Within crosshair radius
            -- Simulate shoot
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, true, false, false)
            task.wait(TriggerbotDelay)
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, false, false, false)
        end
    end)
end

-- ============================================
-- ESP SYSTEM (Drawing)
-- ============================================
local function CreateESPForPlayer(player)
    if ESPList[player] then return end
    
    local espData = {}
    
    -- Box ESP
    local boxOutline = Drawing.new("Square")
    boxOutline.Thickness = 2
    boxOutline.Color = Color3.fromRGB(0, 0, 0)
    boxOutline.Filled = false
    boxOutline.Visible = false
    
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Filled = false
    box.Visible = false
    
    -- Name text
    local nameText = Drawing.new("Text")
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Font = Drawing.Fonts.UI
    nameText.Visible = false
    
    -- Distance text
    local distText = Drawing.new("Text")
    distText.Size = 12
    distText.Center = true
    distText.Outline = true
    distText.Font = Drawing.Fonts.UI
    distText.Visible = false
    
    -- Health bar
    local healthBar = Drawing.new("Square")
    healthBar.Thickness = 0
    healthBar.Filled = true
    healthBar.Visible = false
    
    -- Tracer
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Visible = false
    
    espData = {
        BoxOutline = boxOutline,
        Box = box,
        Name = nameText,
        Distance = distText,
        HealthBar = healthBar,
        Tracer = tracer,
        Player = player
    }
    
    ESPList[player] = espData
end

local function UpdateESP()
    if not ESPEnabled then
        for _, esp in pairs(ESPList) do
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBar.Visible = false
            esp.Tracer.Visible = false
        end
        return
    end
    
    for _, esp in pairs(ESPList) do
        local player = esp.Player
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        
        if not character or not humanoid or humanoid.Health <= 0 then
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBar.Visible = false
            esp.Tracer.Visible = false
            goto continue
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
        if not rootPart then goto continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        
        if not onScreen then
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBar.Visible = false
            esp.Tracer.Visible = false
            goto continue
        end
        
        -- Calculate box size based on distance
        local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
        local boxHeight = 200 / distance * 10
        local boxWidth = boxHeight / 2
        local boxY = screenPos.Y - boxHeight / 2
        local boxX = screenPos.X - boxWidth / 2
        
        -- Team color
        local espColor = player.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        if BoxESP then
            esp.BoxOutline.Visible = true
            esp.Box.Visible = true
            esp.BoxOutline.Position = Vector2.new(boxX - 1, boxY - 1)
            esp.BoxOutline.Size = Vector2.new(boxWidth + 2, boxHeight + 2)
            esp.Box.Position = Vector2.new(boxX, boxY)
            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
            esp.Box.Color = espColor
        else
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
        end
        
        if NameESP then
            esp.Name.Visible = true
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(screenPos.X, boxY - 20)
            esp.Name.Color = espColor
        else
            esp.Name.Visible = false
        end
        
        if DistanceESP then
            esp.Distance.Visible = true
            esp.Distance.Text = string.format("%.0f studs", distance)
            esp.Distance.Position = Vector2.new(screenPos.X, boxY + boxHeight + 15)
            esp.Distance.Color = Color3.fromRGB(255, 255, 255)
        else
            esp.Distance.Visible = false
        end
        
        if HealthESP and humanoid then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local healthHeight = boxHeight * healthPercent
            esp.HealthBar.Visible = true
            esp.HealthBar.Position = Vector2.new(boxX - 7, boxY + boxHeight - healthHeight)
            esp.HealthBar.Size = Vector2.new(4, healthHeight)
            esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
        else
            esp.HealthBar.Visible = false
        end
        
        if TracerESP then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.Visible = true
            esp.Tracer.From = Vector2.new(screenCenter.X, screenCenter.Y)
            esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
            esp.Tracer.Color = espColor
        else
            esp.Tracer.Visible = false
        end
        
        ::continue::
    end
end

-- Create ESP for existing players
for _, player in ipairs(GetPlayers()) do
    CreateESPForPlayer(player)
end

-- ESP update loop
RunService.RenderStepped:Connect(UpdateESP)

-- New player connection
Players.PlayerAdded:Connect(function(player)
    CreateESPForPlayer(player)
end)

-- ============================================
-- PLAYER MOVEMENT
-- ============================================
local function UpdateMovement()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if SpeedEnabled then
        humanoid.WalkSpeed = SpeedValue
    else
        humanoid.WalkSpeed = 16
    end
    
    if JumpPowerEnabled then
        humanoid.JumpPower = JumpPowerValue
    else
        humanoid.JumpPower = 50
    end
end

-- Speed/ Jump update
RunService.Heartbeat:Connect(UpdateMovement)

-- Infinite Jump
local function OnJumpRequest()
    if InfiniteJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Landed then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

UserInputService.JumpRequest:Connect(OnJumpRequest)

-- Fly
local FlyConnection = nil
local FlyBodyVelocity = nil

local function StartFly()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
    
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    FlyBodyVelocity.Parent = rootPart
    
    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled or not LocalPlayer.Character then
            if FlyConnection then FlyConnection:Disconnect() end
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
            if humanoid then humanoid.PlatformStand = false end
            return
        end
        
        local cameraCF = Camera.CFrame
        local moveDirection = Vector3.zero
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + cameraCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - cameraCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + cameraCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - cameraCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
        
        moveDirection = moveDirection.Unit
        FlyBodyVelocity.Velocity = moveDirection * FlySpeed
    end)
end

-- ============================================
-- SPIN BOT
-- ============================================
RunService.RenderStepped:Connect(function()
    if SpinBotEnabled and LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
        end
    end
end)

-- ============================================
-- FPS UNLOCK
-- ============================================
local function SetFPS(value)
    setfpscap(value)
end

-- ============================================
-- RAYFIELD MENU - MAIN TAB
-- ============================================
MainTab:CreateParagraph({
    Title = "RZOHUB Brutal v6",
    Content = "With Anti-Cheat Bypass\nUSE AT YOUR OWN RISK!"
})

MainTab:CreateLabel("📊 Combat")

MainTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(value)
        AimbotEnabled = value
        if not value then CurrentTarget = nil end
    end
})

MainTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Callback = function(value)
        SilentAimEnabled = value
    end
})

MainTab:CreateToggle({
    Name = "Triggerbot",
    CurrentValue = false,
    Callback = function(value)
        TriggerbotEnabled = value
        StartTriggerbot()
    end
})

MainTab:CreateSlider({
    Name = "Triggerbot Delay (ms)",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(value)
        TriggerbotDelay = value / 1000
    end
})

MainTab:CreateToggle({
    Name = "Spin Bot",
    CurrentValue = false,
    Callback = function(value)
        SpinBotEnabled = value
    end
})

MainTab:CreateSlider({
    Name = "Spin Speed",
    Range = {5, 50},
    Increment = 5,
    CurrentValue = 10,
    Callback = function(value)
        SpinSpeed = value
    end
})

-- ============================================
-- COMBAT TAB
-- ============================================
CombatTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 200,
    Callback = function(value)
        FOVRadius = value
        UpdateFOVCircles()
    end
})

CombatTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = true,
    Callback = function(value)
        FOVVisible = value
        UpdateFOVCircles()
    end
})

CombatTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    CurrentOption = "Head",
    Callback = function(option)
        AimPart = option
    end
})

CombatTab:CreateSlider({
    Name = "Aim Smoothness (0 = Instant)",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 0,
    Callback = function(value)
        AimSmoothness = value
    end
})

CombatTab:CreateToggle({
    Name = "Visible Check",
    CurrentValue = true,
    Callback = function(value)
        VisibleCheck = value
    end
})

CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(value)
        TeamCheck = value
    end
})

CombatTab:CreateToggle({
    Name = "Prediction",
    CurrentValue = true,
    Callback = function(value)
        PredictionEnabled = value
    end
})

CombatTab:CreateSlider({
    Name = "Prediction Amount",
    Range = {0, 0.3},
    Increment = 0.005,
    CurrentValue = 0.085,
    Callback = function(value)
        PredictionAmount = value
    end
})

-- ============================================
-- SILENT AIM TAB
-- ============================================
SilentTab:CreateParagraph({
    Title = "Silent Aim Settings",
    Content = "Advanced silent aim dengan bypass\nPilih method yang compatible dengan game"
})

SilentTab:CreateDropdown({
    Name = "Silent Aim Method",
    Options = {"Camera", "Mouse", "Remote"},
    CurrentOption = "Camera",
    Callback = function(option)
        SilentAimMethod = option
    end
})

SilentTab:CreateSlider({
    Name = "Silent FOV",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 150,
    Callback = function(value)
        SilentAimFOV = value
        UpdateFOVCircles()
    end
})

SilentTab:CreateToggle({
    Name = "Auto Fire",
    CurrentValue = false,
    Callback = function(value)
        AutoFire = value
    end
})

SilentTab:CreateSlider({
    Name = "Auto Fire Delay (ms)",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(value)
        AutoFireDelay = value / 1000
    end
})

SilentTab:CreateToggle({
    Name = "Hit Chance",
    CurrentValue = false,
    Callback = function(value)
        HitChance = value
    end
})

SilentTab:CreateSlider({
    Name = "Hit Chance %",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(value)
        HitChanceValue = value
    end
})

-- ============================================
-- VISUAL TAB
-- ============================================
VisualTab:CreateToggle({
    Name = "ESP Enabled",
    CurrentValue = false,
    Callback = function(value)
        ESPEnabled = value
    end
})

VisualTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = true,
    Callback = function(value)
        BoxESP = value
    end
})

VisualTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = true,
    Callback = function(value)
        NameESP = value
    end
})

VisualTab:CreateToggle({
    Name = "Distance ESP",
    CurrentValue = true,
    Callback = function(value)
        DistanceESP = value
    end
})

VisualTab:CreateToggle({
    Name = "Health ESP",
    CurrentValue = true,
    Callback = function(value)
        HealthESP = value
    end
})

VisualTab:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = false,
    Callback = function(value)
        TracerESP = value
    end
})

VisualTab:CreateDivider()

VisualTab:CreateToggle({
    Name = "Chams (Highlight)",
    CurrentValue = false,
    Callback = function(value)
        ChamsEnabled = value
    end
})

VisualTab:CreateColorPicker({
    Name = "Chams Color",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        ChamsColor = color
    end
})

-- ============================================
-- PLAYER TAB
-- ============================================
PlayerTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Callback = function(value)
        SpeedEnabled = value
    end
})

PlayerTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 200},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(value)
        SpeedValue = value
    end
})

PlayerTab:CreateToggle({
    Name = "Jump Power",
    CurrentValue = false,
    Callback = function(value)
        JumpPowerEnabled = value
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Power Value",
    Range = {50, 200},
    Increment = 10,
    CurrentValue = 60,
    Callback = function(value)
        JumpPowerValue = value
    end
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
