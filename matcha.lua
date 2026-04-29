-- [[ MATCHA INTERFACE PRO - UNIVERSAL ]] --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/73n6/MatchaLib/main/Library.lua"))()

local Window = Library:CreateWindow({
    Name = "Shadow Hub v6 | Matcha Interface Pro",
    Footer = "Universal Rage Build | matcha.pink",
    Color = Color3.fromRGB(232, 121, 249)
})

-- 1. LOAD JSK BACKEND
-- This pulls the core logic from your repository
loadstring(game:HttpGet("https://raw.githubusercontent.com/schristie080601-rgb/Matchaaa/refs/heads/main/matcha.lua"))()

-- 2. COMBAT PANEL
local CombatTab = Window:CreateTab("Combat")
local CombatLeft = CombatTab:CreateSection("Aimbot")
local CombatRight = CombatTab:CreateSection("Silent Aim & Trigger")

-- Left Side Components
CombatLeft:CreateToggle("Enabled", false, function(v) _G.AimbotEnabled = v end)
CombatLeft:CreateToggle("Team Check", false, function(v) _G.TeamCheck = v end)
CombatLeft:CreateSlider("Distance", 0, 1000, 500, function(v) _G.AimbotDist = v end)
CombatLeft:CreateSlider("Sensitivity", 0, 100, 40, function(v) _G.AimbotSens = v/100 end)
CombatLeft:CreateDropdown("Hit Part", {"Head", "Torso", "Left Arm", "Right Arm"}, function(v) _G.HitPart = v end)

-- Right Side Components
CombatRight:CreateToggle("Silent Aim Enabled", false, function(v) _G.SilentAim = v end)
CombatRight:CreateDropdown("Method", {"Experimental", "Standard", "Legacy"}, function(v) _G.SAMethod = v end)

local Triggerbot = CombatRight:CreateSection("Trigger Bot")
Triggerbot:CreateToggle("Enabled", false, function(v) _G.TBEnabled = v end)
Triggerbot:CreateSlider("Hitbox Mul", 1, 3, 1, function(v) _G.TBHitboxMul = v end)

-- 3. VISUALS PANEL
local VisualsTab = Window:CreateTab("Visuals")
local VisualsLeft = VisualsTab:CreateSection("ESP Main")
local VisualsRight = VisualsTab:CreateSection("Indicators")

VisualsLeft:CreateToggle("Enabled", false, function(v) _G.ESPEnabled = v end)
VisualsLeft:CreateSlider("Render Distance", 0, 5000, 3000, function(v) _G.ESPDist = v end)
VisualsLeft:CreateToggle("Box", false, function(v) _G.ESPBox = v end)

VisualsRight:CreateToggle("Skeleton", false, function(v) _G.ESPSkeleton = v end)
VisualsRight:CreateToggle("Health Bar", false, function(v) _G.ESPHealth = v end)

-- 4. CHARACTER PANEL (Universal Logic)
local CharTab = Window:CreateTab("Character")
local HitboxSection = CharTab:CreateSection("Hitbox Extender (Riggerbot)")
local MoveSection = CharTab:CreateSection("Movement")

HitboxSection:CreateToggle("Enabled", true, function(v) _G.HitboxEnabled = v end)
HitboxSection:CreateSlider("Hitbox Size", 1, 100, 20, function(v) 
    _G.HitboxSize = v
    -- Applied Riggerbot Logic Loop
    if _G.HitboxEnabled then
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Size = Vector3.new(v, v, v)
                player.Character.HumanoidRootPart.Transparency = 0.7
                player.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
end)

MoveSection:CreateSlider("WalkSpeed", 16, 200, 16, function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)
MoveSection:CreateToggle("No-Clip", false, function(v)
    _G.Noclip = v
    game:GetService("RunService").Stepped:Connect(function()
        if _G.Noclip and game.Players.LocalPlayer.Character then
            for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end)

-- 5. WORLD PANEL
local WorldTab = Window:CreateTab("World")
local Lighting = WorldTab:CreateSection("Lighting")

Lighting:CreateSlider("Clock Time", 0, 24, 12, function(v)
    game:GetService("Lighting").ClockTime = v
end)

Library:Notify("Shadow Hub v6 Universal Active", 4)
