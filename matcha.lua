-- [[ SHADOW HUB V6 | MATCHA UNIVERSAL ]] --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/73n6/MatchaLib/main/Library.lua"))()

local Window = Library:CreateWindow({
    Name = "Shadow Hub v6 | Matcha Interface Pro",
    Footer = "Universal Build | matcha.pink",
    Color = Color3.fromRGB(232, 121, 249)
})

-- ══════════ COMBAT ══════════
local CombatTab = Window:CreateTab("Combat")
local AB = CombatTab:CreateSection("Aimbot")
AB:CreateToggle("Enabled", false, function(v) _G.Aimbot = v end)
AB:CreateSlider("Range", 0, 1000, 500, function(v) _G.AimbotDist = v end)
AB:CreateDropdown("Target", {"Head", "Torso", "HumanoidRootPart"}, function(v) _G.TargetPart = v end)

-- ══════════ CHARACTER ══════════
local CharTab = Window:CreateTab("Character")
local Hitbox = CharTab:CreateSection("Hitbox Extender (Riggerbot)")
Hitbox:CreateSlider("Size", 2, 100, 20, function(v)
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Size = Vector3.new(v, v, v)
            player.Character.HumanoidRootPart.Transparency = 0.7
            player.Character.HumanoidRootPart.CanCollide = false
        end
    end
end)

local Movement = CharTab:CreateSection("Movement")
Movement:CreateSlider("Speed", 16, 250, 16, function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end)
Movement:CreateToggle("Noclip", false, function(v)
    _G.Noclip = v
    game:GetService("RunService").Stepped:Connect(function()
        if _G.Noclip and game.Players.LocalPlayer.Character then
            for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end)

-- ══════════ VISUALS ══════════
local VisualsTab = Window:CreateTab("Visuals")
VisualsTab:CreateSection("ESP"):CreateToggle("Enabled", false, function(v) _G.ESP = v end)

Library:Notify("Shadow Hub Loaded Successfully", 3)
