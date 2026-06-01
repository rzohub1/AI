-- ================================
-- MOBILE AIMBOT + ESP SCRIPT
-- Untuk Delta Executor (Mobile/HP)
-- Langsung pakai, tanpa perlu update
-- ================================

-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Buat Window UI
local Window = Rayfield:CreateWindow({
    Name = "Mobile Aimbot + ESP",
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "Private Test Environment",
    ShowText = "MENU",  -- Tombol untuk show/hide UI di mobile
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MobileAimScript",
        FileName = "Settings"
    },
    KeySystem = false
})

-- Tab-tab
local MainTab = Window:CreateTab("Aimbot", nil)
local EspTab = Window:CreateTab("ESP", nil)
local SettingsTab = Window:CreateTab("Settings", nil)

-- ================================
-- VARIABLES
-- ================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Settings
local AimbotEnabled = false
local TargetLock = false
local FOV = 200
local Smoothness = 5
local WallCheck = true
local ESPEnabled = false
local OutlineESP = false

local currentTarget = nil

-- ================================
-- AIMBOT CORE (Mobile Compatible)
-- ================================

-- Dapatkan pemain terdekat dari crosshair
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local part = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDist then
                        if WallCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                            local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                            if hit and hit:IsDescendantOf(player.Character) then
                                closest = player
                                shortestDist = dist
                            elseif not hit then
                                closest = player
                                shortestDist = dist
                            end
                        else
                            closest = player
                            shortestDist = dist
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Fungsi aim untuk mobile (menggunakan mousemoverel jika support)
local function MoveAim(deltaX, deltaY)
    pcall(function()
        mousemoverel(deltaX, deltaY)
    end)
end

-- Loop Aimbot
local function AimbotLoop()
    if not AimbotEnabled then return end
    
    if TargetLock and currentTarget then
        if currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = currentTarget.Character.HumanoidRootPart
            local targetScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if targetScreen.Z > 0 then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local delta = Vector2.new(targetScreen.X, targetScreen.Y) - center
                if delta.Magnitude > 5 then
                    local smoothDelta = delta / Smoothness
                    MoveAim(smoothDelta.X, smoothDelta.Y)
                end
            else
                currentTarget = nil
            end
        else
            currentTarget = nil
        end
    elseif not TargetLock then
        currentTarget = GetClosestPlayer()
    end
end

-- ================================
-- ESP CORE (Outline Tembus Pandang)
-- ================================

local espHighlights = {}

local function CreateESP(player)
    if not ESPEnabled or player == LocalPlayer then return end
    
    local function addESP(char)
        if not char or char:FindFirstChildWhichIsA("Highlight") then return end
        
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255, 50, 50)
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.3
        -- INI YANG MEMBUAT OUTLINE TEMBUS PANDANG
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = char
        highlight.Parent = char
        
        -- Name tag
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Name"
        billboard.Size = UDim2.new(0, 120, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard
        
        if OutlineESP then
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        else
            highlight.OutlineTransparency = 1
        end
        
        espHighlights[player] = highlight
    end
    
    if player.Character then
        addESP(player.Character)
    end
    
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        addESP(char)
    end)
end

local function RemoveESP(player)
    if espHighlights[player] then
        espHighlights[player]:Destroy()
        espHighlights[player] = nil
    end
    if player.Character then
        for _, child in ipairs(player.Character:GetChildren()) do
            if child:IsA("Highlight") or child.Name == "ESP_Name" then
                child:Destroy()
            end
        end
    end
end

local function RefreshAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            RemoveESP(player)
            if ESPEnabled then
                CreateESP(player)
            end
        end
    end
end

-- ================================
-- PLAYER EVENT HANDLERS
-- ================================
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPEnabled then
            task.wait(0.5)
            CreateESP(player)
        end
    end)
    if ESPEnabled then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- ================================
-- UI ELEMENTS
-- ================================

-- Aimbot Tab
MainTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(value)
        AimbotEnabled = value
        if not value then currentTarget = nil end
    end
})

MainTab:CreateToggle({
    Name = "Target Lock",
    CurrentValue = false,
    Flag = "TargetLock",
    Callback = function(value)
        TargetLock = value
        if not value then currentTarget = nil end
    end
})

MainTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 200,
    Flag = "FOVSlider",
    Callback = function(value)
        FOV = value
    end
})

MainTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 15},
    Increment = 1,
    Suffix = "",
    CurrentValue = 5,
    Flag = "SmoothSlider",
    Callback = function(value)
        Smoothness = value
    end
})

MainTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Flag = "WallCheck",
    Callback = function(value)
        WallCheck = value
    end
})

-- ESP Tab
EspTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(value)
        ESPEnabled = value
        RefreshAllESP()
    end
})

EspTab:CreateToggle({
    Name = "Outline Tembus Pandang",
    CurrentValue = false,
    Flag = "OutlineESP",
    Callback = function(value)
        OutlineESP = value
        RefreshAllESP()
    end
})

-- Settings Tab
SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
    end
})

-- ================================
-- START LOOP
-- ================================
RunService.RenderStepped:Connect(AimbotLoop)

-- Notifikasi sukses
task.wait(1)
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✅ Script Loaded!",
    Text = "Mobile Aimbot + ESP siap digunakan. Tap tombol 'MENU' di layar untuk buka UI.",
    Duration = 5
})
