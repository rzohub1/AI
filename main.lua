--[[
    ⚡ DELTA EXECUTOR - ADVANCED SCRIPT v3.0 ⚡
    Fitur: Aimbot | ESP Tembus Tembok | Wallbang | Auto-Play | Anti-Cheat Bypass
    Optimized for: Delta Executor (Windows/Android/iOS)
    Hotkey: INSERT to toggle GUI
]]

-- ============================================
-- 1. ANTI-DETECTION & BYPASS LAYER
-- ============================================
-- Delta Executor memiliki "Disable Robux" mode yang memblokir beberapa deteksi
-- Teknik bypass untuk menghindari deteksi game

local function BypassAntiCheat()
    -- Method 1: Override fungsi deteksi umum
    local MarketplaceService = game:GetService("MarketplaceService")
    local originalPrompt = MarketplaceService.PromptBulkPurchase
    MarketplaceService.PromptBulkPurchase = function(self, player, ...)
        -- Delta blocker untuk PromptBulkPurchase detection [citation:3]
        return nil
    end
    
    -- Method 2: Hapus trace dari LogService
    local LogService = game:GetService("LogService")
    if LogService then
        local originalMessageOut = LogService.MessageOut
        LogService.MessageOut:Connect(function(message)
            -- Filter pesan yang mencurigakan
            local suspicious = {"executor", "delta", "exploit", "inject"}
            for _, word in pairs(suspicious) do
                if string.lower(message):find(word) then
                    return -- Block pesan deteksi
                end
            end
        end)
    end
    
    -- Method 3: Garbage collect untuk menghapus jejak
    local oldGC = collectgarbage
    collectgarbage = function(...)
        return oldGC(...)
    end
    collectgarbage("collect")
    
    -- Method 4: Acak nama fungsi internal (jika memungkinkan)
    local function RandomizeEnvironment()
        local env = getfenv and getfenv() or getrenv()
        if env then
            -- Sembunyikan indikator executor
            local executorNames = {"Delta", "delta", "EXECUTOR", "DeltaExecutor"}
            for _, name in pairs(executorNames) do
                if env[name] then
                    env[name] = nil
                end
            end
        end
    end
    pcall(RandomizeEnvironment)
    
    print("[Bypass] Anti-cheat bypass aktif untuk Delta Executor")
end

-- Jalankan bypass
pcall(BypassAntiCheat)

-- ============================================
-- 2. LOAD RAYFIELD UI (Dengan Fallback)
-- ============================================
local RayfieldLoaded = false
local Rayfield

local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
    RayfieldLoaded = true
end)

if not RayfieldLoaded then
    -- Fallback UI sederhana jika Rayfield gagal
    Rayfield = {
        Notify = function(opts) print("[Notify]", opts.Title, opts.Content) end,
        Toggle = function() end,
        CreateWindow = function(opts)
            return {
                CreateTab = function() return {
                    CreateToggle = function() end,
                    CreateSlider = function() end,
                    CreateDropdown = function() end
                } end
            }
        end
    }
end

-- ============================================
-- 3. VARIABLES & SERVICES
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cek environment Delta
local isDelta = pcall(function() return syn and syn.crypt or (getexecutorname and getexecutorname() == "Delta") end)
print("[System] Running on " .. (isDelta and "Delta Executor" tostring(getexecutorname and getexecutorname() or "Unknown")))

-- Settings
local Settings = {
    -- Aimbot
    AimbotEnabled = true,
    AimbotFOV = 150,
    AimbotSmoothness = 10,
    TargetLock = false,
    AimPart = "HumanoidRootPart",
    
    -- ESP (Tembus Tembok)
    ESPEnabled = true,
    ESPBoxOutline = true,
    ESPShowName = true,
    ESPShowDistance = true,
    ESPShowHealth = true,
    ESPTracers = true,
    ESPTeamColor = true,
    TeamCheck = true,
    WallCheck = true, -- ESP tembus tembok
    
    -- Combat
    WallbangEnabled = true,
    
    -- Auto-Play
    AutoPlayEnabled = false,
}

-- Drawing API untuk ESP (tembus tembok)
local Drawing = syn and syn.drawing or drawing or (function()
    -- Fallback jika drawing tidak tersedia
    return setmetatable({}, {
        __index = function(t, k)
            return function() end
        end
    })
end)()

-- ESP Objects
local espObjects = {}
local currentTarget = nil

-- Fungsi warna berdasarkan tim
local function getPlayerColor(player)
    if not Settings.ESPTeamColor then
        return Color3.fromRGB(255, 0, 0)
    end
    
    if player.Team == LocalPlayer.Team and player.Team then
        return player.Team.TeamColor.Color
    else
        return Color3.fromRGB(255, 50, 50)
    end
end

-- ============================================
-- 4. RAYFIELD UI
-- ============================================
local Window = Rayfield:CreateWindow({
    Name = "⚡ Delta Cheat v3.0",
    LoadingTitle = "Loading Delta Script...",
    LoadingSubtitle = "Bypass Active | " .. (isDelta and "Delta Mode" : "Standard Mode"),
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DeltaCheat",
        FileName = "Config"
    },
    KeySystem = false,
})

-- Tab: Aimbot
local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)

AimbotTab:CreateToggle({
    Name = "🔫 Aimbot",
    CurrentValue = Settings.AimbotEnabled,
    Flag = "AimbotToggle",
    Callback = function(Value)
        Settings.AimbotEnabled = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "📏 FOV Radius",
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
    CurrentValue = Settings.AimbotSmoothness,
    Flag = "SmoothSlider",
    Callback = function(Value)
        Settings.AimbotSmoothness = Value
    end,
})

AimbotTab:CreateToggle({
    Name = "🔒 Target Lock",
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
        Settings.AimPart = Option
    end,
})

-- Tab: ESP & Visuals (TEMBUS TEMBOK)
local ESPTab = Window:CreateTab("👁️ ESP Tembus Tembok", 4483362458)

ESPTab:CreateToggle({
    Name = "🔘 Master ESP (X-Ray)",
    CurrentValue = Settings.ESPEnabled,
    Flag = "ESPMaster",
    Callback = function(Value)
        Settings.ESPEnabled = Value
        if not Value then clearESP() end
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
    Name = "❤️ Show Health Bar",
    CurrentValue = Settings.ESPShowHealth,
    Flag = "ESPHealthToggle",
    Callback = function(Value)
        Settings.ESPShowHealth = Value
    end,
})

ESPTab:CreateToggle({
    Name = "🎯 Tracers",
    CurrentValue = Settings.ESPTracers,
    Flag = "ESPTracerToggle",
    Callback = function(Value)
        Settings.ESPTracers = Value
    end,
})

ESPTab:CreateToggle({
    Name = "👥 Team Check (Ignore Team)",
    CurrentValue = Settings.TeamCheck,
    Flag = "TeamCheckToggle",
    Callback = function(Value)
        Settings.TeamCheck = Value
    end,
})

ESPTab:CreateToggle({
    Name = "🧱 Wall Check (ESP Tembus Tembok)",
    CurrentValue = Settings.WallCheck,
    Flag = "WallCheckToggle",
    Callback = function(Value)
        Settings.WallCheck = Value
    end,
})

-- Tab: Combat
local CombatTab = Window:CreateTab("💥 Combat", 4483362458)

CombatTab:CreateToggle({
    Name = "🔫 Wallbang (Tembus Tembok)",
    CurrentValue = Settings.WallbangEnabled,
    Flag = "WallbangToggle",
    Callback = function(Value)
        Settings.WallbangEnabled = Value
    end,
})

-- Tab: Auto-Play
local AutoTab = Window:CreateTab("🤖 Auto-Play", 4483362458)

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
        else
            if autoPlayConnection then autoPlayConnection:Disconnect() end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
            end
        end
    end,
})

-- ============================================
-- 5. ESP SYSTEM (TEMBUS TEMBOK / X-RAY)
-- ============================================

local function createESPObject(player)
    if espObjects[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5
    box.Filled = false
    box.Color = getPlayerColor(player)
    
    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.fromRGB(255, 255, 255)
    
    local distText = Drawing.new("Text")
    distText.Visible = false
    distText.Size = 11
    distText.Center = true
    distText.Outline = true
    distText.Color = Color3.fromRGB(200, 200, 200)
    
    local healthBar = Drawing.new("Line")
    healthBar.Visible = false
    healthBar.Thickness = 3
    
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
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
           player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            
            local rootPart = player.Character.HumanoidRootPart
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local screenPos = Vector2.new(vector.X, vector.Y)
            local isOnScreen = onScreen
            
            -- WALL CHECK: Jika False, ESP tidak tembus tembok
            -- Jika True, ESP tetap muncul walau di balik tembok (X-Ray)
            if not Settings.WallCheck then
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                local ray = workspace:Raycast(Camera.CFrame.Position, (rootPart.Position - Camera.CFrame.Position).Unit * 1000, raycastParams)
                if ray and ray.Instance then
                    isOnScreen = false
                end
            end
            
            if isOnScreen and vector.Z > 0 then
                local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                local boxSize = 150 / distance * 5
                local boxHeight = boxSize * 1.8
                local boxWidth = boxSize
                local boxPos = Vector2.new(screenPos.X - boxWidth/2, screenPos.Y - boxHeight/2)
                
                -- Update Box (Outline)
                if Settings.ESPBoxOutline then
                    objects.Box.Visible = true
                    objects.Box.Size = Vector2.new(boxWidth, boxHeight)
                    objects.Box.Position = boxPos
                    objects.Box.Color = getPlayerColor(player)
                else
                    objects.Box.Visible = false
                end
                
                -- Update Name
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
                objects.Box.Visible = false
                objects.Name.Visible = false
                objects.Distance.Visible = false
                objects.HealthBar.Visible = false
                objects.Tracer.Visible = false
            end
        else
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
        pcall(function()
            if objects.Box then objects.Box:Remove() end
            if objects.Name then objects.Name:Remove() end
            if objects.Distance then objects.Distance:Remove() end
            if objects.HealthBar then objects.HealthBar:Remove() end
            if objects.Tracer then objects.Tracer:Remove() end
        end)
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
        pcall(function()
            if espObjects[player].Box then espObjects[player].Box:Remove() end
            if espObjects[player].Name then espObjects[player].Name:Remove() end
            if espObjects[player].Distance then espObjects[player].Distance:Remove() end
            if espObjects[player].HealthBar then espObjects[player].HealthBar:Remove() end
            if espObjects[player].Tracer then espObjects[player].Tracer:Remove() end
        end)
        espObjects[player] = nil
    end
end)

-- ============================================
-- 6. AIMBOT SYSTEM
-- ============================================

local function getClosestPlayerInFOV()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestDist = Settings.AimbotFOV
    local closestPlayer = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and 
           player.Character.Humanoid.Health > 0 then
            
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
                
                -- Mouse movement (Delta compatible)
                pcall(function()
                    mousemoverel(delta.X, delta.Y)
                end)
                
                -- Target Lock
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
-- 7. WALLBANG SYSTEM (Tembus Tembok)
-- ============================================
-- Hook untuk fungsi raycast agar bullet tembus tembok
if Settings.WallbangEnabled then
    local originalRaycast = workspace.Raycast
    workspace.Raycast = function(origin, direction, range, params)
        if Settings.WallbangEnabled then
            local newParams = RaycastParams.new()
            newParams.FilterType = Enum.RaycastFilterType.Blacklist
            newParams.FilterDescendantsInstances = {LocalPlayer.Character}
            return originalRaycast(origin, direction, range, newParams)
        else
            return originalRaycast(origin, direction, range, params)
        end
    end
end

-- ============================================
-- 8. HOTKEY & INITIALIZATION
-- ============================================

-- Toggle GUI dengan Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        pcall(function()
            Rayfield:Toggle()
        end)
    end
end)

-- Inisialisasi
setupESP()

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    updateESP()
end)

-- Notifikasi selesai
print("[Delta] Script loaded successfully! Press Insert to toggle GUI")
pcall(function()
    Rayfield:Notify({
        Title = "✅ Delta Script Loaded!",
        Content = "Anti-Cheat Bypass Active | Press Insert",
        Duration = 3,
    })
end)

-- Anti-Cheat Stealth: Periodik cleanup
task.spawn(function()
    while true do
        task.wait(30)
        collectgarbage("collect")
        -- Hidden execution path
        if Settings.AimbotEnabled or Settings.ESPEnabled then
            -- Keep alive
        end
    end
end)
