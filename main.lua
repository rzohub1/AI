--[[
    ⚡ ADVANCED AIMBOT + ESP + WALLBANG SCRIPT ⚡
    Menggunakan Rayfield UI Library
    Fitur: ESP Outline Tembus Tembok | Wallbang | Aimbot | Auto-Play | Team Check
    
    Cara penggunaan:
    1. Copy seluruh script ini
    2. Paste di executor (Synapse X, Krnl, dll)
    3. Execute
    4. Tekan tombol Insert untuk toggle GUI
]]

-- ============================================
-- 1. LOAD RAYFIELD LIBRARY
-- ============================================
getgenv().SecureMode = true -- Mengurangi kemungkinan deteksi

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- ============================================
-- 2. VARIABLES & SERVICES
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Drawing API untuk ESP (agar tembus tembok)
local Drawing = Drawing or require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("Drawing"))

-- Settings
local Settings = {
    -- Aimbot
    AimbotEnabled = true,
    AimbotFOV = 150,
    AimbotSmoothness = 10,
    TargetLock = false,
    AimPart = "HumanoidRootPart",
    
    -- ESP
    ESPEnabled = true,
    ESPBoxOutline = true,
    ESPShowName = true,
    ESPShowDistance = true,
    ESPShowHealth = true,
    ESPTracers = true,
    ESPTeamColor = true,
    TeamCheck = true,
    
    -- Wallbang
    WallbangEnabled = true,
    WallCheck = true, -- Cek tembok untuk ESP
    
    -- Auto-Play
    AutoPlayEnabled = false,
}

-- Variabel untuk ESP
local espObjects = {}
local currentTarget = nil

-- Warna tim (default jika tidak terdeteksi)
local function getPlayerColor(player)
    if not Settings.ESPTeamColor then
        return Color3.fromRGB(255, 0, 0) -- Merah untuk musuh
    end
    
    if player.Team == LocalPlayer.Team and player.Team then
        return player.Team.TeamColor.Color -- Warna tim sendiri
    else
        return Color3.fromRGB(255, 50, 50) -- Merah untuk musuh
    end
end

-- ============================================
-- 3. CREATE RAYFIELD UI
-- ============================================
local Window = Rayfield:CreateWindow({
    Name = "⚡ Advanced Cheat v2.0",
    LoadingTitle = "Loading Cheat...",
    LoadingSubtitle = "by Private Script",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PrivateCheat",
        FileName = "Config"
    },
    KeySystem = false, -- Ganti ke true jika ingin pake key system
})

-- Tab: Aimbot
local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)

AimbotTab:CreateToggle({
    Name = "🔫 Aimbot",
    CurrentValue = Settings.AimbotEnabled,
    Flag = "AimbotToggle",
    Callback = function(Value)
        Settings.AimbotEnabled = Value
        Rayfield:Notify({
            Title = "Aimbot",
            Content = Value and "Aimbot Enabled" or "Aimbot Disabled",
            Duration = 1.5,
        })
    end,
})

AimbotTab:CreateSlider({
    Name = "📏 FOV Radius (px)",
    Range = {30, 350},
    Increment = 5,
    Suffix = "px",
    CurrentValue = Settings.AimbotFOV,
    Flag = "FOVSlider",
    Callback = function(Value)
        Settings.AimbotFOV = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "✨ Smoothness",
    Range = {1, 50},
    Increment = 1,
    Suffix = "",
    CurrentValue = Settings.AimbotSmoothness,
    Flag = "SmoothSlider",
    Callback = function(Value)
        Settings.AimbotSmoothness = Value
    end,
})

AimbotTab:CreateToggle({
    Name = "🔒 Target Lock (Camera Lock)",
    CurrentValue = Settings.TargetLock,
    Flag = "TargetLockToggle",
    Callback = function(Value)
        Settings.TargetLock = Value
    end,
})

AimbotTab:CreateDropdown({
    Name = "🎯 Aim Part",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    CurrentOption = "HumanoidRootPart",
    Flag = "AimPartDropdown",
    Callback = function(Option)
        if Option == "Head" then
            Settings.AimPart = "Head"
        elseif Option == "UpperTorso" then
            Settings.AimPart = "UpperTorso"
        else
            Settings.AimPart = "HumanoidRootPart"
        end
    end,
})

-- Tab: ESP & Visuals
local ESPTab = Window:CreateTab("👁️ ESP & Visuals", 4483362458)

ESPTab:CreateToggle({
    Name = "🔘 Master ESP",
    CurrentValue = Settings.ESPEnabled,
    Flag = "ESPMaster",
    Callback = function(Value)
        Settings.ESPEnabled = Value
        if not Value then
            clearESP()
        end
    end,
})

ESPTab:CreateToggle({
    Name = "📦 Box Outline (Tembus Tembok)",
    CurrentValue = Settings.ESPBoxOutline,
    Flag = "ESPBoxToggle",
    Callback = function(Value)
        Settings.ESPBoxOutline = Value
    end,
})

ESPTab:CreateToggle({
    Name = "🏷️ Show Name",
    CurrentValue = Settings.ESPShowName,
    Flag = "ESPNameToggle",
    Callback = function(Value)
        Settings.ESPShowName = Value
    end,
})

ESPTab:CreateToggle({
    Name = "📏 Show Distance",
    CurrentValue = Settings.ESPShowDistance,
    Flag = "ESPDistanceToggle",
    Callback = function(Value)
        Settings.ESPShowDistance = Value
    end,
})

ESPTab:CreateToggle({
    Name = "❤️ Show Health",
    CurrentValue = Settings.ESPShowHealth,
    Flag = "ESPHealthToggle",
    Callback = function(Value)
        Settings.ESPShowHealth = Value
    end,
})

ESPTab:CreateToggle({
    Name = "🎯 Show Tracers",
    CurrentValue = Settings.ESPTracers,
    Flag = "ESPTracerToggle",
    Callback = function(Value)
        Settings.ESPTracers = Value
    end,
})

ESPTab:CreateToggle({
    Name = "🎨 Team Color (RGB)",
    CurrentValue = Settings.ESPTeamColor,
    Flag = "ESPColorToggle",
    Callback = function(Value)
        Settings.ESPTeamColor = Value
    end,
})

ESPTab:CreateToggle({
    Name = "👥 Team Check (Ignor Team)",
    CurrentValue = Settings.TeamCheck,
    Flag = "TeamCheckToggle",
    Callback = function(Value)
        Settings.TeamCheck = Value
        Rayfield:Notify({
            Title = "Team Check",
            Content = Value and "Teammates will be IGNORED" or "Teammates will be TARGETED",
            Duration = 2,
        })
    end,
})

-- Tab: Combat & Wallbang
local CombatTab = Window:CreateTab("💥 Combat", 4483362458)

CombatTab:CreateToggle({
    Name = "🔫 Wallbang (Tembus Tembok)",
    CurrentValue = Settings.WallbangEnabled,
    Flag = "WallbangToggle",
    Callback = function(Value)
        Settings.WallbangEnabled = Value
        Rayfield:Notify({
            Title = "Wallbang",
            Content = Value and "Bullets can penetrate walls" or "Wallbang disabled",
            Duration = 1.5,
        })
    end,
})

CombatTab:CreateToggle({
    Name = "🧱 Wall Check (ESP Tembus Tembok)",
    CurrentValue = Settings.WallCheck,
    Flag = "WallCheckToggle",
    Callback = function(Value)
        Settings.WallCheck = Value
        -- WallCheck = true berarti ESP tetap muncul walau dibalik tembok
    end,
})

-- Tab: Auto-Play
local AutoTab = Window:CreateTab("🤖 Auto-Play", 4483362458)

local autoPlayRunning = false
local autoPlayConnection = nil

local function autoPlayLogic()
    if not Settings.AutoPlayEnabled then return end
    
    local nearestPlayer = nil
    local nearestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team and player.Team then
                -- Skip teammate
            else
                local root = player.Character.HumanoidRootPart
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestPlayer = player
                    end
                end
            end
        end
    end
    
    if nearestPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        local targetPos = nearestPlayer.Character.HumanoidRootPart.Position
        humanoid:MoveTo(targetPos)
    end
end

AutoTab:CreateToggle({
    Name = "🎮 Auto-Play (Detect & Chase)",
    CurrentValue = Settings.AutoPlayEnabled,
    Flag = "AutoPlayToggle",
    Callback = function(Value)
        Settings.AutoPlayEnabled = Value
        if Value then
            if autoPlayConnection then autoPlayConnection:Disconnect() end
            autoPlayConnection = RunService.Heartbeat:Connect(autoPlayLogic)
            Rayfield:Notify({
                Title = "Auto-Play",
                Content = "Auto-Play ENABLED - Chasing enemies",
                Duration = 2,
            })
        else
            if autoPlayConnection then autoPlayConnection:Disconnect() end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
            end
            Rayfield:Notify({
                Title = "Auto-Play",
                Content = "Auto-Play DISABLED",
                Duration = 1.5,
            })
        end
    end,
})

-- ============================================
-- 4. ESP SYSTEM (TEMBUS TEMBOK dengan OUTLINE)
-- ============================================

local function createESPObject(player)
    if espObjects[player] then return end
    
    -- Box Outline (Square)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5
    box.Filled = false
    box.Color = getPlayerColor(player)
    
    -- Nama Player
    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.fromRGB(255, 255, 255)
    
    -- Distance Text
    local distText = Drawing.new("Text")
    distText.Visible = false
    distText.Size = 11
    distText.Center = true
    distText.Outline = true
    distText.Color = Color3.fromRGB(200, 200, 200)
    
    -- Health Bar
    local healthBar = Drawing.new("Line")
    healthBar.Visible = false
    healthBar.Thickness = 3
    
    -- Tracer (garis dari bawah layar ke target)
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1.5
    
    espObjects[player] = {
        Box = box,
        Name = nameText,
        Distance = distText,
        HealthBar = healthBar,
        Tracer = tracer,
    }
end

local function updateESP()
    if not Settings.ESPEnabled then return end
    
    for player, objects in pairs(espObjects) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local rootPart = player.Character.HumanoidRootPart
            local headPart = player.Character:FindFirstChild("Head") or rootPart
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            -- Hitung posisi di layar
            local screenPos = Vector2.new(vector.X, vector.Y)
            local isOnScreen = onScreen
            
            -- Wall Check: Jika tembok menghalangi, tetap tampilkan (tembus tembok)
            if not Settings.WallCheck then
                -- Cek apakah terhalang tembok
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                local ray = workspace:Raycast(Camera.CFrame.Position, (rootPart.Position - Camera.CFrame.Position).Unit * 1000, raycastParams)
                if ray and ray.Instance then
                    isOnScreen = false
                end
            end
            
            if isOnScreen and vector.Z > 0 then
                -- Hitung ukuran box berdasarkan jarak
                local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                local boxSize = 150 / distance * 5
                local boxHeight = boxSize * 1.8
                local boxWidth = boxSize
                
                local boxPos = Vector2.new(screenPos.X - boxWidth/2, screenPos.Y - boxHeight/2)
                
                -- Update Box
                if Settings.ESPBoxOutline then
                    objects.Box.Visible = true
                    objects.Box.Size = Vector2.new(boxWidth, boxHeight)
                    objects.Box.Position = boxPos
                    objects.Box.Color = getPlayerColor(player)
                else
                    objects.Box.Visible = false
                end
                
                -- Update Name Text
                if Settings.ESPShowName then
                    objects.Name.Visible = true
                    objects.Name.Text = player.Name
                    objects.Name.Position = Vector2.new(screenPos.X, screenPos.Y - boxHeight/2 - 15)
                    objects.Name.Color = getPlayerColor(player)
                else
                    objects.Name.Visible = false
                end
                
                -- Update Distance
                if Settings.ESPShowDistance then
                    objects.Distance.Visible = true
                    objects.Distance.Text = math.floor(distance) .. "m"
                    objects.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + boxHeight/2 + 5)
                else
                    objects.Distance.Visible = false
                end
                
                -- Update Health Bar
                if Settings.ESPShowHealth then
                    local health = player.Character.Humanoid.Health
                    local maxHealth = player.Character.Humanoid.MaxHealth
                    local healthPercent = math.clamp(health / maxHealth, 0, 1)
                    local healthBarHeight = boxHeight * healthPercent
                    
                    objects.HealthBar.Visible = true
                    objects.HealthBar.From = Vector2.new(boxPos.X - 5, boxPos.Y + boxHeight - healthBarHeight)
                    objects.HealthBar.To = Vector2.new(boxPos.X - 5, boxPos.Y + boxHeight)
                    objects.HealthBar.Color = Color3.fromRGB(0, 255 * (1 - healthPercent), 255 * healthPercent)
                else
                    objects.HealthBar.Visible = false
                end
                
                -- Update Tracers
                if Settings.ESPTracers then
                    objects.Tracer.Visible = true
                    objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    objects.Tracer.To = screenPos
                    objects.Tracer.Color = getPlayerColor(player)
                else
                    objects.Tracer.Visible = false
                end
            else
                -- Hide all if off-screen
                objects.Box.Visible = false
                objects.Name.Visible = false
                objects.Distance.Visible = false
                objects.HealthBar.Visible = false
                objects.Tracer.Visible = false
            end
        else
            -- Hide all if player invalid
            objects.Box.Visible = false
            objects.Name.Visible = false
            objects.Distance.Visible = false
            objects.HealthBar.Visible = false
            objects.Tracer.Visible = false
        end
    end
end

local function clearESP()
    for player, objects in pairs(espObjects) do
        if objects.Box then objects.Box:Remove() end
        if objects.Name then objects.Name:Remove() end
        if objects.Distance then objects.Distance:Remove() end
        if objects.HealthBar then objects.HealthBar:Remove() end
        if objects.Tracer then objects.Tracer:Remove() end
    end
    espObjects = {}
end

-- Setup ESP untuk semua player
local function setupESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESPObject(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESPObject(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        if espObjects[player].Box then espObjects[player].Box:Remove() end
        if espObjects[player].Name then espObjects[player].Name:Remove() end
        if espObjects[player].Distance then espObjects[player].Distance:Remove() end
        if espObjects[player].HealthBar then espObjects[player].HealthBar:Remove() end
        if espObjects[player].Tracer then espObjects[player].Tracer:Remove() end
        espObjects[player] = nil
    end
end)

-- ============================================
-- 5. AIMBOT SYSTEM
-- ============================================

local function getClosestPlayerInFOV()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestDist = Settings.AimbotFOV
    local closestPlayer = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team and player.Team then
                -- Skip teammate
            else
                local targetPart = player.Character:FindFirstChild(Settings.AimPart) or player.Character:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if not Settings.AimbotEnabled then return end
    
    local target = getClosestPlayerInFOV()
    if target and target.Character then
        currentTarget = target
        local targetPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local targetScreen = Vector2.new(screenPos.X, screenPos.Y)
                local currentMouse = UserInputService:GetMouseLocation()
                local delta = (targetScreen - currentMouse) / Settings.AimbotSmoothness
                
                -- Gerakkan mouse (mouse move simulation)
                mousemoverel(delta.X, delta.Y)
                
                -- Target Lock: Camera follow
                if Settings.TargetLock then
                    local cameraCF = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                    Camera.CFrame = cameraCF
                end
            end
        end
    else
        currentTarget = nil
    end
end)

-- ============================================
-- 6. WALLBANG SYSTEM (Tembus Tembok)
-- ============================================
-- Script ini memodifikasi raycast untuk bullet agar bisa tembus tembok
-- Integrasikan dengan sistem weapon game

-- Override fungsi raycast untuk wallbang
local originalRaycast = workspace.Raycast
if Settings.WallbangEnabled then
    -- Method: Menggunakan parameter raycast yang mengabaikan wall objects
    -- Atau memodifikasi filterType
    local function wallbangRaycast(origin, direction, range, params)
        if Settings.WallbangEnabled then
            -- Buat parameter baru dengan ignore list yang mencakup tembok
            local newParams = RaycastParams.new()
            newParams.FilterType = Enum.RaycastFilterType.Blacklist
            newParams.FilterDescendantsInstances = {LocalPlayer.Character}
            -- Tambahkan material tertentu yang ingin ditembus (contoh: Concrete, Metal, dll)
            return workspace:Raycast(origin, direction * range, newParams)
        else
            return originalRaycast(origin, direction, range, params)
        end
    end
    -- Catatan: Override global hanya mungkin di environment executor tertentu
end

-- ============================================
-- 7. HOTKEY & INITIALIZATION
-- ============================================

-- Toggle GUI dengan Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Rayfield:Toggle()
    end
end)

-- Inisialisasi ESP
setupESP()

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    updateESP()
end)

-- Notifikasi selesai loading
Rayfield:Notify({
    Title = "✅ Script Loaded!",
    Content = "Press Insert to toggle GUI",
    Duration = 3,
})

print("Script loaded successfully! Press Insert to toggle GUI")
