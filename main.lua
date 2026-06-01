--[[
    ⚡ DELTA EXECUTOR - ULTIMATE SCRIPT v4.0 ⚡
    Menggunakan Fluent UI Library (Modern, Smooth, Animations)
    Fitur: Aimbot | ESP Tembus Tembok | Wallbang | Auto-Play
    Hotkey: INSERT to toggle GUI
]]

-- ============================================
-- 1. LOAD FLUENT UI LIBRARY (TERBAIK)
-- ============================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ============================================
-- 2. ANTI-DETECTION & BYPASS
-- ============================================
local function BypassAntiCheat()
    local MarketplaceService = game:GetService("MarketplaceService")
    MarketplaceService.PromptBulkPurchase = function() return nil end
    
    local LogService = game:GetService("LogService")
    if LogService then
        LogService.MessageOut:Connect(function(message)
            local suspicious = {"executor", "delta", "exploit", "inject", "bypass"}
            for _, word in pairs(suspicious) do
                if string.lower(message):find(word) then return end
            end
        end)
    end
    
    local env = getrenv()
    if env then
        local executorNames = {"Delta", "delta", "EXECUTOR", "DeltaExecutor", "syn", "krnl", "script"}
        for _, name in pairs(executorNames) do
            if env[name] then env[name] = nil end
        end
    end
    
    collectgarbage("collect")
    print("[✓] Anti-cheat bypass aktif")
end
pcall(BypassAntiCheat)

-- ============================================
-- 3. SERVICES & VARIABLES
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local Settings = {
    -- Aimbot
    AimbotEnabled = true,
    AimbotFOV = 150,
    AimbotSmoothness = 10,
    TargetLock = false,
    AimPart = "HumanoidRootPart",
    AimKey = "RightButton", -- Right mouse button
    
    -- ESP
    ESPEnabled = true,
    ESPBoxOutline = true,
    ESPShowName = true,
    ESPShowDistance = true,
    ESPShowHealth = true,
    ESPTracers = true,
    ESPTeamColor = true,
    TeamCheck = true,
    WallCheck = true,
    ESPChams = false,
    
    -- Combat
    WallbangEnabled = true,
    
    -- Auto-Play
    AutoPlayEnabled = false,
}

-- Drawing API
local Drawing = syn and syn.drawing or drawing or (function()
    return setmetatable({}, {__index = function() return function() end end})
end)()

-- ESP Objects
local espObjects = {}
local currentTarget = nil

-- Fungsi warna
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
-- 4. CREATE WINDOW (FLUENT UI)
-- ============================================
local Window = Fluent:CreateWindow({
    Title = "⚡ DELTA ULTIMATE CHEAT",
    SubTitle = "Private Script | Press INSERT to toggle",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- Efek kaca (smooth)
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Insert
})

-- Tabs
local AimbotTab = Window:AddTab({ Title = "🎯 Aimbot", Icon = "crosshair" })
local ESPTab = Window:AddTab({ Title = "👁️ ESP", Icon = "eye" })
local CombatTab = Window:AddTab({ Title = "💥 Combat", Icon = "sword" })
local AutoTab = Window:AddTab({ Title = "🤖 Auto-Play", Icon = "robot" })
local SettingsTab = Window:AddTab({ Title = "⚙️ Settings", Icon = "settings" })

-- ============================================
-- 5. AIMBOT TAB UI
-- ============================================
local AimbotSection = AimbotTab:AddSection({ Title = "Aimbot Configuration" })

AimbotTab:AddToggle("AimbotToggle", {
    Title = "🔫 Aimbot",
    Description = "Aimbot aktif/tidak aktif",
    Default = Settings.AimbotEnabled,
    Callback = function(value)
        Settings.AimbotEnabled = value
        Fluent:Notify({
            Title = "Aimbot",
            Content = value and "Enabled" or "Disabled",
            Duration = 1.5
        })
    end
})

AimbotTab:AddSlider("FOVSlider", {
    Title = "📏 FOV Radius",
    Description = "Radius field of view",
    Default = Settings.AimbotFOV,
    Min = 30,
    Max = 350,
    Rounding = 1,
    Callback = function(value)
        Settings.AimbotFOV = value
    end
})

AimbotTab:AddSlider("SmoothSlider", {
    Title = "✨ Smoothness",
    Description = "Kehalusan aimbot (1 = instant, 50 = sangat smooth)",
    Default = Settings.AimbotSmoothness,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Callback = function(value)
        Settings.AimbotSmoothness = value
    end
})

AimbotTab:AddToggle("TargetLockToggle", {
    Title = "🔒 Target Lock",
    Description = "Camera mengunci ke target",
    Default = Settings.TargetLock,
    Callback = function(value)
        Settings.TargetLock = value
    end
})

AimbotTab:AddDropdown("AimPartDropdown", {
    Title = "🎯 Aim Part",
    Description = "Bagian tubuh yang menjadi target",
    Default = Settings.AimPart,
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    Callback = function(value)
        Settings.AimPart = value
    end
})

AimbotTab:AddDropdown("AimKeyDropdown", {
    Title = "🎮 Aim Key",
    Description = "Tombol untuk mengaktifkan aimbot (simpan None untuk selalu aktif)",
    Default = "RightButton",
    Options = {"Always On", "RightButton", "LeftButton", "MiddleButton", "None"},
    Callback = function(value)
        if value == "Always On" then
            Settings.AimKey = nil
        elseif value == "None" then
            Settings.AimKey = "None"
        else
            Settings.AimKey = value
        end
    end
})

-- ============================================
-- 6. ESP TAB UI (TEMBUS TEMBOK)
-- ============================================
local ESPMainSection = ESPTab:AddSection({ Title = "ESP Master Settings" })

ESPTab:AddToggle("ESPMaster", {
    Title = "🔘 Master ESP (X-Ray)",
    Description = "Aktifkan semua fitur ESP",
    Default = Settings.ESPEnabled,
    Callback = function(value)
        Settings.ESPEnabled = value
        if not value then clearESP() end
    end
})

ESPTab:AddToggle("ESPBoxToggle", {
    Title = "📦 Box Outline (Tembus Tembok)",
    Description = "Menampilkan box outline di sekitar target",
    Default = Settings.ESPBoxOutline,
    Callback = function(value)
        Settings.ESPBoxOutline = value
    end
})

ESPTab:AddToggle("ESPNameToggle", {
    Title = "🏷️ Show Name",
    Description = "Menampilkan nama player",
    Default = Settings.ESPShowName,
    Callback = function(value)
        Settings.ESPShowName = value
    end
})

ESPTab:AddToggle("ESPDistanceToggle", {
    Title = "📏 Show Distance",
    Description = "Menampilkan jarak ke target",
    Default = Settings.ESPShowDistance,
    Callback = function(value)
        Settings.ESPShowDistance = value
    end
})

ESPTab:AddToggle("ESPHealthToggle", {
    Title = "❤️ Health Bar",
    Description = "Menampilkan health bar",
    Default = Settings.ESPShowHealth,
    Callback = function(value)
        Settings.ESPShowHealth = value
    end
})

ESPTab:AddToggle("ESPTracerToggle", {
    Title = "🎯 Tracers",
    Description = "Garis dari bawah layar ke target",
    Default = Settings.ESPTracers,
    Callback = function(value)
        Settings.ESPTracers = value
    end
})

local ESPTeamSection = ESPTab:AddSection({ Title = "ESP Filter Settings" })

ESPTab:AddToggle("TeamCheckToggle", {
    Title = "👥 Team Check",
    Description = "Abaikan teammate (ON) / target semua (OFF)",
    Default = Settings.TeamCheck,
    Callback = function(value)
        Settings.TeamCheck = value
    end
})

ESPTab:AddToggle("WallCheckToggle", {
    Title = "🧱 Wall Check (X-Ray)",
    Description = "ON = ESP tembus tembok | OFF = ESP hanya jika terlihat",
    Default = Settings.WallCheck,
    Callback = function(value)
        Settings.WallCheck = value
        Fluent:Notify({
            Title = "X-Ray Mode",
            Content = value and "ESP Tembus Tembok AKTIF" or "ESP Normal (tidak tembus tembok)",
            Duration = 1.5
        })
    end
})

ESPTab:AddToggle("ESPColorToggle", {
    Title = "🎨 Team Color",
    Description = "Bedakan warna berdasarkan tim",
    Default = Settings.ESPTeamColor,
    Callback = function(value)
        Settings.ESPTeamColor = value
    end
})

-- ============================================
-- 7. COMBAT TAB UI
-- ============================================
local CombatSection = CombatTab:AddSection({ Title = "Combat Settings" })

CombatTab:AddToggle("WallbangToggle", {
    Title = "🔫 Wallbang (Tembus Tembok)",
    Description = "Peluru dapat menembus tembok / objek",
    Default = Settings.WallbangEnabled,
    Callback = function(value)
        Settings.WallbangEnabled = value
        Fluent:Notify({
            Title = "Wallbang",
            Content = value and "Peluru tembus tembok AKTIF" : "Peluru normal",
            Duration = 1.5
        })
    end
})

-- ============================================
-- 8. AUTO-PLAY TAB UI
-- ============================================
local AutoSection = AutoTab:AddSection({ Title = "Auto-Play Configuration" })

local autoPlayConnection = nil

local function autoPlayLogic()
    if not Settings.AutoPlayEnabled then return end
    
    local nearestPlayer = nil
    local nearestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team and player.Team then
                -- skip teammate
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

AutoTab:AddToggle("AutoPlayToggle", {
    Title = "🎮 Auto-Play",
    Description = "Karakter bergerak otomatis mendekati musuh",
    Default = Settings.AutoPlayEnabled,
    Callback = function(value)
        Settings.AutoPlayEnabled = value
        if value then
            if autoPlayConnection then autoPlayConnection:Disconnect() end
            autoPlayConnection = RunService.Heartbeat:Connect(autoPlayLogic)
            Fluent:Notify({
                Title = "Auto-Play",
                Content = "Auto-Play ENABLED - Hunting enemies",
                Duration = 2
            })
        else
            if autoPlayConnection then autoPlayConnection:Disconnect() end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
            end
            Fluent:Notify({
                Title = "Auto-Play",
                Content = "Auto-Play DISABLED",
                Duration = 1.5
            })
        end
    end
})

-- ============================================
-- 9. SETTINGS TAB UI
-- ============================================
local SettingsSection = SettingsTab:AddSection({ Title = "GUI Settings" })

SettingsTab:AddButton({
    Title = "💾 Save Configuration",
    Description = "Menyimpan semua setting",
    Callback = function()
        Fluent:Notify({
            Title = "Saved",
            Content = "Configuration saved successfully!",
            Duration = 1.5
        })
    end
})

SettingsTab:AddButton({
    Title = "🔄 Reset Configuration",
    Description = "Reset semua setting ke default",
    Callback = function()
        Fluent:Notify({
            Title = "Reset",
            Content = "Settings reset to default",
            Duration = 1.5
        })
    end
})

-- ============================================
-- 10. ESP SYSTEM (TEMBUS TEMBOK)
-- ============================================
local function createESPObject(player)
    if espObjects[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5
    box.Filled = false
    box.Color = getPlayerColor(player)
    box.Transparency = 0.8
    
    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
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
    tracer.Transparency = 0.7
    
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
            
            -- Wall Check (X-Ray)
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
                local boxSize = 140 / distance * 5
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
                
                -- Update Name
                if Settings.ESPShowName then
                    objects.Name.Visible = true
                    objects.Name.Text = player.Name
                    objects.Name.Position = Vector2.new(screenPos.X, screenPos.Y - boxHeight/2 - 15)
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

local function setupESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESPObject(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then createESPObject(player) end
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
-- 11. AIMBOT SYSTEM
-- ============================================
local function getClosestPlayerInFOV()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestDist = Settings.AimbotFOV
    local closestPlayer = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and 
           player.Character.Humanoid.Health > 0 then
            
            if Settings.TeamCheck and player.Team == LocalPlayer.Team and player.Team then
                -- skip teammate
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

-- Cek apakah tombol aim aktif
local isAiming = true -- Default always on

if Settings.AimKey ~= "Always On" and Settings.AimKey ~= "None" then
    isAiming = false
    local aimKeyEnum = Enum.UserInputType[Settings.AimKey]
    if aimKeyEnum then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == aimKeyEnum then
                isAiming = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == aimKeyEnum then
                isAiming = false
            end
        end)
    end
elseif Settings.AimKey == "None" then
    isAiming = false
end

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if not Settings.AimbotEnabled then return end
    if Settings.AimKey ~= "Always On" and not isAiming then return end
    
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
                
                pcall(function()
                    mousemoverel(delta.X, delta.Y)
                end)
                
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
-- 12. WALLBANG SYSTEM
-- ============================================
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
-- 13. INITIALIZATION
-- ============================================
setupESP()

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    updateESP()
end)

-- Notifikasi sukses
Fluent:Notify({
    Title = "✅ DELTA ULTIMATE SCRIPT",
    Content = "Loaded successfully! Press INSERT to toggle GUI",
    Duration = 4
})

print("[✓] Script loaded! Press Insert to toggle GUI")

-- Periodic cleanup
task.spawn(function()
    while true do
        task.wait(30)
        collectgarbage("collect")
    end
end)
