-- Rayfield Aimbot + ESP (Mobile Optimized for Delta Executor)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Simple Aimbot + ESP",
    LoadingTitle = "Loading UI...",
    LoadingSubtitle = "Private Test",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SimpleHub",
        FileName = "Config"
    },
    Discord = {
        Enabled = false
    }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local AimTab = Window:CreateTab("Aimbot", 4483362458)
local EspTab = Window:CreateTab("ESP", 4483362458)

-- Variables
local AimbotEnabled = false
local ESPEnabled = false
local WallCheck = true
local TargetLock = false
local FOV = 150
local Smoothness = 0.5
local CurrentTarget = nil

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Simple Aimbot Function
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                
                if onScreen and distance < shortestDistance then
                    -- Wall Check
                    if WallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (player.Character.Head.Position - Camera.CFrame.Position).Unit * 500)
                        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                        if hit and hit:IsDescendantOf(player.Character) then
                            shortestDistance = distance
                            closest = player
                        end
                    else
                        shortestDistance = distance
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    
    CurrentTarget = GetClosestPlayer()
    
    if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
        local targetPos = CurrentTarget.Character.Head.Position
        local direction = (targetPos - Camera.CFrame.Position).Unit
        
        local smoothCFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPos), Smoothness)
        Camera.CFrame = smoothCFrame
    end
end)

-- === MAIN TAB ===
MainTab:CreateToggle({
    Name = "Aimbot Toggle",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        AimbotEnabled = Value
    end,
})

MainTab:CreateToggle({
    Name = "ESP Toggle",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        ESPEnabled = Value
        -- ESP logic di bawah
    end,
})

-- === AIMBOT TAB ===
AimTab:CreateSlider({
    Name = "FOV",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = FOV,
    Flag = "FOVSlider",
    Callback = function(Value)
        FOV = Value
    end,
})

AimTab:CreateSlider({
    Name = "Smoothness",
    Range = {0.1, 1},
    Increment = 0.05,
    CurrentValue = Smoothness,
    Flag = "SmoothSlider",
    Callback = function(Value)
        Smoothness = Value
    end,
})

AimTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Flag = "WallCheck",
    Callback = function(Value)
        WallCheck = Value
    end,
})

AimTab:CreateToggle({
    Name = "Target Lock (Hold)",
    CurrentValue = false,
    Flag = "TargetLock",
    Callback = function(Value)
        TargetLock = Value
    end,
})

-- === ESP TAB ===
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "SimpleESP"
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.1  -- tembus pandang (outline)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillColor = Color3.fromRGB(0, 255, 255)
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    
    -- Destroy saat mati
    player.CharacterAdded:Connect(function(char)
        highlight.Adornee = char
    end)
end

EspTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    CreateESP(player)
                end
                player.CharacterAdded:Connect(function() 
                    if ESPEnabled then CreateESP(player) end
                end)
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("SimpleESP") then
                    player.Character.SimpleESP:Destroy()
                end
            end
        end
    end,
})

EspTab:CreateParagraph({
    Title = "Note",
    Content = "Outline tembus pandang sudah diatur (Transparency 0.1)"
})

Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Selamat testing di private server!",
    Duration = 6,
    Image = 4483362458
})
