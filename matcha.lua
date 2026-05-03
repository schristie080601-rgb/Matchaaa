-- ╔══════════════════════════════════════════════════════════════╗
-- ║  MATCHA EXTERNAL  —  Pixel-Accurate UI Recreation v5        ║
-- ║  Matches real screenshots exactly                           ║
-- ║  Delta/Hydrogen/Arceus/Fluxus/KRNL compatible               ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ══════════════════════════════════════════════════════════════
--  SAFE  ENV
-- ══════════════════════════════════════════════════════════════
local _GE = (function()
    if type(getgenv) == "function" then
        local ok, g = pcall(getgenv)
        if ok and type(g) == "table" then return g end
    end
    return _G
end)()
local function setG(k,v) pcall(function() _GE[k]=v end); pcall(function() _G[k]=v end) end
local function getG(k) return _GE[k] or _G[k] end

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local Plrs  = game:GetService("Players")
local RS    = game:GetService("RunService")
local UIS   = game:GetService("UserInputService")
local TS    = game:GetService("TweenService")
local Light = game:GetService("Lighting")
local WS    = game:GetService("Workspace")
local CGui  = game:GetService("CoreGui")

local LP   = Plrs.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui", 10)
local Cam  = WS.CurrentCamera
local mob  = UIS.TouchEnabled

-- ══════════════════════════════════════════════════════════════
--  GUI PARENT
-- ══════════════════════════════════════════════════════════════
local function getParent()
    if type(gethui) == "function" then local ok,h = pcall(gethui); if ok and h then return h end end
    local ok = pcall(function() local t = Instance.new("Folder"); t.Parent = CGui; t:Destroy() end)
    if ok then return CGui end
    return PGui
end
local GP = getParent()
for _,v in ipairs({CGui, PGui}) do
    pcall(function() local o = v:FindFirstChild("MatchaV5"); if o then o:Destroy() end end)
end

-- ══════════════════════════════════════════════════════════════
--  STATE  (mirrors every setting from screenshots)
-- ══════════════════════════════════════════════════════════════
local S = {
    -- COMBAT LEFT — Aimbot
    AB = {
        On=false, Team=false, Vis=false, Health=false, Sticky=false,
        Dist=500, Sens=0.40, Part="Head", AimType="Mouse",
        Rage=false, Type="Camera Teleport", Resolver=false,
        Pred=false, PredAmt=0.12,
        FOVOn=false, FOVSz=150, FOVFill=false,
        Soft=false, SoftStr=0.08,
        Keybind="RMB",
    },
    -- COMBAT RIGHT — Silent Aim
    SA = {
        On=false, Team=false, Vis=false, Health=false, Sticky=false,
        Dist=500, Part="Head", Method="Experimental",
        Pred=false, FOV=360,
        Keybind="e",
    },
    -- Trigger Bot (right side, below silent aim)
    TB = {On=false, Vis=false, Team=false, HBMul=1.00, Delay=1, Release=10},
    -- VISUALS — ESP (left panel)
    ESP = {
        On=false, Team=false, Vis=false, TeamColor=false,
        TxtGrad=true, TxtBG=false, Outline=true, Glow=false, Self=false,
        SizeType="Bounding", RDist=3000,
        -- Box
        Box=false, Fill=false, BoxType="2D",
        -- Name
        Name=false,
        -- Chams
        Chams=false, ChamsFill=true, ChamsType="Static",
        -- Tracer
        Trace=false, TraceOrigin="Bottom",
        -- Indicators
        Dist=false, Equip=false, Skel=false, Dot=false, DotGlow=false, Prof=false,
        -- Health
        HBar=false, HBased=false, HText=false, HTextPos="Above Name",
        -- Rainbow
        Rainbow=false,
    },
    -- WORLD — Camera
    WC = {FOVOn=false, FOVAmt=70},
    -- WORLD — Waypoints
    WP = {Name="", TweenGoto=false, TweenSpeed=200, Vis=false, List={}},
    -- WORLD — Lighting
    WL = {
        Ambience=false, CustomFog=false, Glow=false, FogDist=0,
        Exposure=false, ExpoVal=2.00,
        Bright=false, BrightVal=2.00,
        Time=false, TimeVal=12.00,
        Sky=false, SkyVal="Galaxy Nebula",
        Full=false, NoFog=false,
    },
    -- CHARACTER — Hitbox
    HB = {On=true, Vis=false, Team=false, Health=false, Sz=20, Type="Old"},
    -- CHARACTER — Target Hovering
    TH = {On=false, Circle=false, Method="Closest To Mouse", Radius=10, Speed=5.60},
    -- CHARACTER — Desync
    DS = {On=false, Method="Client-Sided", RemWalk=false, DisAnim=false, Tick=false, Invis=false},
    -- CHARACTER — Movement
    MV = {
        AntiFling=false, NoClip=false, InfJump=false, ClickTP=false,
        Speed=false, SpeedMeth="Velocity", SpeedAmt=1,
        Flight=false, FlightMeth="Velocity", FlightAmt=1,
        Jump=false, JumpPow=50,
        Float=false, FloatH=10,
        Timer=false, TimerMul=1.00,
    },
    -- HIDE
    Hide = {All=false, WM=false, Console=false, Spoof=false, Blur=false, Screenshot=false},
}
setG("MatchaState", S)

-- ══════════════════════════════════════════════════════════════
--  EXACT  MATCHA  COLOURS  (from screenshots)
-- ══════════════════════════════════════════════════════════════
local C = {
    -- Window background — near black, very slight purple tint
    Win    = Color3.fromRGB(14, 13, 20),
    -- Panel/tab background
    Panel  = Color3.fromRGB(18, 17, 26),
    -- Section headers / top bar
    TopBar = Color3.fromRGB(20, 19, 28),
    -- Card / row background
    Row    = Color3.fromRGB(22, 21, 32),
    -- Input / slider track
    Track  = Color3.fromRGB(12, 11, 18),
    -- Divider lines
    Div    = Color3.fromRGB(34, 32, 48),
    -- Active tab underline / accent
    Acc    = Color3.fromRGB(195, 70, 245),   -- real matcha purple
    AccL   = Color3.fromRGB(215, 100, 255),
    -- Slider/toggle active: bright magenta-pink
    Slider = Color3.fromRGB(230, 60, 150),   -- real matcha pink slider
    -- Checkbox active
    Check  = Color3.fromRGB(195, 70, 245),
    -- Sub-tab active text
    SubAcc = Color3.fromRGB(195, 70, 245),
    -- Status/utility
    Green  = Color3.fromRGB(80, 220, 120),
    Red    = Color3.fromRGB(230, 60, 60),
    Yellow = Color3.fromRGB(230, 185, 40),
    Cyan   = Color3.fromRGB(40, 190, 210),
    -- Text
    TW     = Color3.fromRGB(235, 230, 255),   -- white-ish
    TS2    = Color3.fromRGB(150, 140, 175),   -- secondary
    TD     = Color3.fromRGB(72, 68, 100),     -- dim
    White  = Color3.new(1,1,1),
    Black  = Color3.new(0,0,0),
}

-- ══════════════════════════════════════════════════════════════
--  UTIL
-- ══════════════════════════════════════════════════════════════
local function tw(o,p,t,s,d)
    pcall(function()
        TS:Create(o, TweenInfo.new(t or .18, s or Enum.EasingStyle.Quart, d or Enum.EasingDirection.Out), p):Play()
    end)
end
local function mk(cl, pr, pa)
    local ok, o = pcall(Instance.new, cl)
    if not ok then return nil end
    for k,v in pairs(pr or {}) do pcall(function() o[k]=v end) end
    if pa then pcall(function() o.Parent=pa end) end
    return o
end
local function cr(p,r)   return mk("UICorner",   {CornerRadius=UDim.new(0,r or 6)}, p) end
local function sk(p,c,t) return mk("UIStroke",   {Color=c or C.Div, Thickness=t or 1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, p) end
local function pd(p,t,r,b,l)
    return mk("UIPadding", {PaddingTop=UDim.new(0,t or 6),PaddingRight=UDim.new(0,r or 6),PaddingBottom=UDim.new(0,b or 6),PaddingLeft=UDim.new(0,l or 6)}, p)
end
local function fr(pa, sz, ps, co, tr)
    return mk("Frame", {Size=sz or UDim2.new(1,0,1,0), Position=ps or UDim2.new(0,0,0,0), BackgroundColor3=co or C.Panel, BackgroundTransparency=tr or 0, BorderSizePixel=0}, pa)
end
local function sc(pa, sz, ps, co)
    return mk("ScrollingFrame", {Size=sz or UDim2.new(1,0,1,0), Position=ps or UDim2.new(0,0,0,0), BackgroundColor3=co or C.Win, BackgroundTransparency=0, BorderSizePixel=0, ScrollBarThickness=2, ScrollBarImageColor3=C.Acc, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollingDirection=Enum.ScrollingDirection.Y}, pa)
end
local function lb(pa, tx, sz, co, fn, xa, ya)
    return mk("TextLabel", {BackgroundTransparency=1, Text=tx or "", TextSize=sz or 11, TextColor3=co or C.TW, Font=fn or Enum.Font.Gotham, TextXAlignment=xa or Enum.TextXAlignment.Left, TextYAlignment=ya or Enum.TextYAlignment.Center, Size=UDim2.new(1,0,1,0), BorderSizePixel=0}, pa)
end
local function vl(p, sp, ha)
    return mk("UIListLayout", {FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,sp or 3), SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=ha or Enum.HorizontalAlignment.Left}, p)
end
local function hl(p, sp, va)
    return mk("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,sp or 4), SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=va or Enum.VerticalAlignment.Center}, p)
end

-- ══════════════════════════════════════════════════════════════
--  SCREEN GUI + MAIN WINDOW
-- ══════════════════════════════════════════════════════════════
local SG = mk("ScreenGui", {Name="MatchaV5", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, IgnoreGuiInset=true, DisplayOrder=999}, GP)
if not SG then SG = mk("ScreenGui", {Name="MatchaV5", ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=999}); pcall(function() SG.Parent = PGui end) end

-- Real Matcha window size from screenshots: ~460×450 (narrow, two-panel)
local WW = mob and 390 or 460
local WH = mob and 520 or 520

local Win = fr(SG, UDim2.new(0,WW,0,WH), UDim2.new(0.5,-WW/2,0.5,-WH/2), C.Win)
cr(Win, 8)
sk(Win, C.Div, 1)
Win.ClipsDescendants = true

-- Entrance animation
Win.Size = UDim2.new(0, WW, 0, 0)
tw(Win, {Size=UDim2.new(0,WW,0,WH)}, .3, Enum.EasingStyle.Back)

-- Drag
do
    local dg, ds, sp = false, nil, nil
    Win.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dg=true; ds=i.Position; sp=Win.Position
        end
    end)
    Win.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            Win.Position=UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  TITLE BAR  (real Matcha: "Matcha  Interface  Pro"  + username right)
-- ══════════════════════════════════════════════════════════════
local TitleBar = fr(Win, UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), C.Win)
sk(TitleBar, C.Div, 1)

-- "Matcha" (accent colour)  "Interface" (dim)  "Pro" (accent)
local titleHL = hl(TitleBar, 6)
pd(TitleBar, 0,8,0,10)

local tM = lb(TitleBar,"Matcha",11,C.Acc,Enum.Font.GothamBold,Enum.TextXAlignment.Left)
tM.Size=UDim2.new(0,44,1,0)
local tI = lb(TitleBar,"Interface",11,C.TS2,Enum.Font.Gotham,Enum.TextXAlignment.Left)
tI.Size=UDim2.new(0,55,1,0); tI.Position=UDim2.new(0,50,0,0)
local tP = lb(TitleBar,"Pro",11,C.Acc,Enum.Font.GothamBold,Enum.TextXAlignment.Left)
tP.Size=UDim2.new(0,24,1,0); tP.Position=UDim2.new(0,110,0,0)

-- Username top-right
local userLbl = lb(TitleBar, LP.Name, 10, C.TD, Enum.Font.Gotham, Enum.TextXAlignment.Right)
userLbl.Size=UDim2.new(0,130,1,0); userLbl.Position=UDim2.new(1,-136,0,0)

-- Close X (small, top right corner)
local XBtn = mk("TextButton", {Size=UDim2.new(0,20,0,20), Position=UDim2.new(1,-22,0.5,-10), BackgroundColor3=C.Red, BackgroundTransparency=0.4, Text="✕", TextColor3=C.White, TextSize=9, Font=Enum.Font.GothamBold, BorderSizePixel=0}, TitleBar)
cr(XBtn, 4)
XBtn.MouseButton1Click:Connect(function()
    tw(Win, {Size=UDim2.new(0,WW,0,0), BackgroundTransparency=1}, .2)
    task.delay(.25, function() Win.Visible=false end)
end)

-- ══════════════════════════════════════════════════════════════
--  MAIN  TAB  BAR  (Combat | Visuals | World | Character | Options | Configs | NPC | Teams)
--  Real Matcha: horizontal tabs, underline indicator, 11px Gotham
-- ══════════════════════════════════════════════════════════════
local TabBar = fr(Win, UDim2.new(1,0,0,26), UDim2.new(0,0,0,28), C.Win)
sk(TabBar, C.Div, 1)
hl(TabBar, 0)

local mainTabs = {"Combat","Visuals","World","Character","Options","Configs","NPC","Teams"}
local tabBtns  = {}
local tabPages = {}
local activeMT = nil

local function switchMainTab(name)
    for _,p in pairs(tabPages) do p.Visible = false end
    for n, tb in pairs(tabBtns) do
        local a = n==name
        tw(tb.lbl, {TextColor3 = a and C.TW or C.TD}, .15)
        tb.bar.Visible = a
    end
    if tabPages[name] then tabPages[name].Visible = true end
    activeMT = name
end

for _, tn in ipairs(mainTabs) do
    local btn = mk("TextButton", {
        Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1, Text="", BorderSizePixel=0,
    }, TabBar)
    pd(btn, 0,8,0,8)

    local lbl2 = lb(btn, tn, 11, C.TD, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    lbl2.Size = UDim2.new(1,0,1,-2)

    -- Bottom underline bar
    local bar = fr(btn, UDim2.new(1,0,0,2), UDim2.new(0,0,1,-2), C.Acc)
    bar.Visible = false

    tabBtns[tn] = {btn=btn, lbl=lbl2, bar=bar}

    -- Create page
    local page = fr(nil, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.Win, 0)
    page.Visible = false; page.Name = tn; page.ClipsDescendants = true
    tabPages[tn] = page

    btn.MouseButton1Click:Connect(function() switchMainTab(tn) end)
    btn.MouseEnter:Connect(function() if activeMT~=tn then tw(lbl2,{TextColor3=C.TS2},.1) end end)
    btn.MouseLeave:Connect(function() if activeMT~=tn then tw(lbl2,{TextColor3=C.TD},.1) end end)
end

-- Content host
local ContentHost = fr(Win, UDim2.new(1,0,1,-54), UDim2.new(0,0,0,54), C.Win)
ContentHost.ClipsDescendants = true
for _,p in pairs(tabPages) do p.Parent = ContentHost end

-- ══════════════════════════════════════════════════════════════
--  SUB-TAB  SYSTEM  (appears below main tab bar like real Matcha)
-- ══════════════════════════════════════════════════════════════
-- Each main tab can have a sub-tab bar that sits at the very top of its page
local function makeSubTabBar(parent, defs)
    -- Sub-tab bar: 24px high, sits at top of content area
    local stBar = fr(parent, UDim2.new(1,0,0,24), UDim2.new(0,0,0,0), C.Win)
    sk(stBar, C.Div, 1)
    hl(stBar, 0)

    local stPages = {}
    local stBtns  = {}
    local activeST2 = nil

    local contentArea = sc(parent, UDim2.new(1,0,1,-24), UDim2.new(0,0,0,24), C.Win)

    local function switchST(id)
        for _,sp in pairs(stPages) do sp.Visible = false end
        for sid, sb in pairs(stBtns) do
            local a = sid==id
            tw(sb.lbl, {TextColor3=a and C.AccL or C.TD}, .12)
            sb.bar.Visible = a
        end
        if stPages[id] then stPages[id].Visible = true end
        activeST2 = id
    end

    for _, sd in ipairs(defs) do
        local btn = mk("TextButton", {
            Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
            BackgroundTransparency=1, Text="", BorderSizePixel=0,
        }, stBar)
        pd(btn, 0,8,0,8)

        local lbl2 = lb(btn, sd.lbl, 10, C.TD, Enum.Font.Gotham, Enum.TextXAlignment.Center)
        lbl2.Size = UDim2.new(1,0,1,-2)

        local bar = fr(btn, UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), C.Acc)
        bar.Visible = false

        -- Key badge (like "rmb", "e", "q" shown in screenshots)
        if sd.badge then
            local bdg = mk("TextButton", {
                Size=UDim2.new(0,22,0,14), Position=UDim2.new(1,2,0.5,-7),
                BackgroundColor3=C.Track, BackgroundTransparency=0,
                Text=sd.badge, TextColor3=C.TD, TextSize=8,
                Font=Enum.Font.Gotham, BorderSizePixel=0,
            }, btn)
            cr(bdg, 3)
        end

        local pg = sc(contentArea, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.Win)
        pg.Visible = false; pg.Name = sd.id
        pd(pg, 8,8,8,8); vl(pg, 4)

        stBtns[sd.id]  = {btn=btn, lbl=lbl2, bar=bar}
        stPages[sd.id] = pg

        btn.MouseButton1Click:Connect(function() switchST(sd.id) end)
    end

    -- Auto-select first
    if #defs > 0 then task.defer(function() switchST(defs[1].id) end) end

    return stPages, switchST
end

-- ══════════════════════════════════════════════════════════════
--  UI  WIDGETS  (real Matcha style from screenshots)
-- ══════════════════════════════════════════════════════════════

-- Real Matcha checkbox: small square, ~12×12, tight to text
local function Checkbox(parent, text, default, cb, order, keybind)
    local row = fr(parent, UDim2.new(1,0,0,22), UDim2.new(0,0,0,0), Color3.new(), 1)
    row.LayoutOrder = order or 0

    -- Checkbox square
    local box = fr(row, UDim2.new(0,12,0,12), UDim2.new(0,0,0.5,-6), default and C.Acc or C.Track)
    cr(box, 2)
    sk(box, default and C.Acc or C.Div, 1)
    local tick = lb(box, "✓", 8, C.White, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    tick.Visible = default or false

    local txt = lb(row, text, 11, C.TW, Enum.Font.Gotham)
    txt.Size  = UDim2.new(1,-18,1,0); txt.Position=UDim2.new(0,16,0,0)

    -- Keybind badge (like "rmb", "q", "e", "z", "control", "y")
    if keybind then
        local kbdg = mk("TextButton", {
            Size=UDim2.new(0,0,0,14), AutomaticSize=Enum.AutomaticSize.X,
            Position=UDim2.new(1,-2,0.5,-7), AnchorPoint=Vector2.new(1,0.5),
            BackgroundColor3=C.Track, Text=" "..keybind.." ",
            TextColor3=C.TD, TextSize=8, Font=Enum.Font.Gotham, BorderSizePixel=0,
        }, row)
        cr(kbdg, 3); txt.Size=UDim2.new(1,-60,1,0)
    end

    local state = default or false
    local function set(v, silent)
        state = v
        tw(box, {BackgroundColor3 = v and C.Acc or C.Track}, .15)
        sk(box, v and C.Acc or C.Div, 1)
        tick.Visible = v
        if not silent and cb then pcall(cb, v) end
    end
    row.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            set(not state)
        end
    end)
    return row, set
end

-- Real Matcha slider: very thin pink/magenta track, small dot
local function Slider(parent, text, mn, mx, def, cb, order, decimals)
    local dec = decimals or 0
    local row = fr(parent, UDim2.new(1,0,0,36), UDim2.new(0,0,0,0), Color3.new(), 1)
    row.LayoutOrder = order or 0

    -- Label left
    local tl2 = lb(row, text, 11, C.TS2, Enum.Font.Gotham)
    tl2.Size=UDim2.new(0.55,0,0,14); tl2.Position=UDim2.new(0,0,0,0)

    -- Value right
    local fmt = decimals and ("%.2f") or ("%d")
    local vlbl = lb(row, string.format(fmt, def), 11, C.TW, Enum.Font.Gotham, Enum.TextXAlignment.Right)
    vlbl.Size=UDim2.new(0.42,0,0,14); vlbl.Position=UDim2.new(0.56,0,0,0)

    -- Track
    local track = fr(row, UDim2.new(1,0,0,2), UDim2.new(0,0,0,22), C.Track)
    cr(track, 1)

    local pct = math.clamp((def-mn)/(mx-mn), 0, 1)

    -- Fill with pink gradient (real Matcha)
    local fill = fr(track, UDim2.new(pct,0,1,0), UDim2.new(0,0,0,0), C.Slider)
    cr(fill, 1)
    mk("UIGradient", {
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.Acc),
            ColorSequenceKeypoint.new(1, C.Slider),
        }), Rotation=90
    }, fill)

    -- Knob: small filled circle
    local knob = fr(track, UDim2.new(0,8,0,8), UDim2.new(pct,-4,0.5,-4), C.Slider)
    cr(knob, 4)

    local drag = false
    local function upd(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v
        if decimals then
            v = tonumber(string.format("%.2f", mn + rel*(mx-mn)))
        else
            v = math.floor(mn + rel*(mx-mn))
        end
        vlbl.Text = decimals and string.format("%.2f",v) or tostring(v)
        fill.Size = UDim2.new(rel,0,1,0)
        knob.Position = UDim2.new(rel,-4,0.5,-4)
        if cb then pcall(cb, v) end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; upd(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            upd(i.Position.X)
        end
    end)
    return row
end

-- Real Matcha dropdown: dark pill, white caret, full-width
local function Dropdown(parent, opts, def, cb, order)
    local row = fr(parent, UDim2.new(1,0,0,22), UDim2.new(0,0,0,0), C.Track)
    row.LayoutOrder = order or 0
    cr(row, 4); sk(row, C.Div, 1)

    local selL = lb(row, def or opts[1], 10, C.TW, Enum.Font.Gotham)
    selL.Size=UDim2.new(1,-18,1,0); selL.Position=UDim2.new(0,6,0,0)
    local ar = lb(row, "▾", 10, C.TD, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
    ar.Size=UDim2.new(0,14,1,0); ar.Position=UDim2.new(1,-16,0,0)

    local dh = #opts * 22 + 6
    local dl = fr(SG, UDim2.new(0,0,0,0), UDim2.new(0,0,0,0), C.Row)
    dl.Visible=false; dl.ZIndex=9998; cr(dl,5); sk(dl,C.Acc,1.5); pd(dl,3,3,3,3); vl(dl,2)

    for _,opt in ipairs(opts) do
        local ob = mk("TextButton", {Size=UDim2.new(1,0,0,20), BackgroundColor3=C.Row, BackgroundTransparency=1, Text="  "..opt, TextColor3=C.TS2, TextSize=10, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, BorderSizePixel=0, ZIndex=9999}, dl)
        cr(ob, 3)
        ob.MouseEnter:Connect(function() tw(ob,{BackgroundTransparency=0.6,TextColor3=C.TW},.1) end)
        ob.MouseLeave:Connect(function() tw(ob,{BackgroundTransparency=1,TextColor3=C.TS2},.1) end)
        ob.MouseButton1Click:Connect(function()
            selL.Text=opt; if cb then pcall(cb,opt) end
            tw(dl,{Size=UDim2.new(0,row.AbsoluteSize.X,0,0)},.12)
            task.delay(.14,function() dl.Visible=false end)
        end)
    end

    local open = false
    row.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            open=not open
            if open then
                local ap=row.AbsolutePosition
                local aw=row.AbsoluteSize.X
                dl.Position=UDim2.new(0,ap.X,0,ap.Y+row.AbsoluteSize.Y+3)
                dl.Size=UDim2.new(0,aw,0,0); dl.Visible=true
                tw(dl,{Size=UDim2.new(0,aw,0,dh)},.18)
            else
                tw(dl,{Size=UDim2.new(0,row.AbsoluteSize.X,0,0)},.12)
                task.delay(.14,function() dl.Visible=false end)
            end
        end
    end)
    return row
end

-- Label (small section header inside panel, like "Hit Part", "Aim Type", etc.)
local function FieldLabel(parent, text, order)
    local h = fr(parent, UDim2.new(1,0,0,16), UDim2.new(0,0,0,0), Color3.new(), 1)
    h.LayoutOrder = order or 0
    local l = lb(h, text, 10, C.TS2, Enum.Font.Gotham)
    l.Size = UDim2.new(1,0,1,0)
    return h
end

-- Misc section header (like "Misc" in real matcha)
local function SectionLabel(parent, text, order)
    local h = fr(parent, UDim2.new(1,0,0,18), UDim2.new(0,0,0,0), Color3.new(), 1)
    h.LayoutOrder = order or 0
    local l = lb(h, text, 10, C.TS2, Enum.Font.Gotham)
    l.Size = UDim2.new(1,0,1,0)
    -- thin underline
    local line = fr(h, UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), C.Div)
    return h
end

-- Action button (full width)
local function ActionBtn(parent, text, col, cb, order)
    local b = mk("TextButton", {
        Size=UDim2.new(1,0,0,24), BackgroundColor3=col or C.Track,
        BackgroundTransparency=0.6, Text=text, TextColor3=col or C.TW,
        TextSize=10, Font=Enum.Font.Gotham, BorderSizePixel=0,
        LayoutOrder=order or 0,
    }, parent)
    cr(b, 4); sk(b, col or C.Div, 1)
    b.MouseEnter:Connect(function() tw(b,{BackgroundTransparency=0.25},.1) end)
    b.MouseLeave:Connect(function() tw(b,{BackgroundTransparency=0.6},.1) end)
    b.MouseButton1Click:Connect(function()
        tw(b,{BackgroundTransparency=0.05},.08)
        task.delay(.15,function() tw(b,{BackgroundTransparency=0.6},.1) end)
        if cb then pcall(cb) end
    end)
    return b
end

-- ══════════════════════════════════════════════════════════════
--  TWO-PANEL LAYOUT HELPER (real Matcha Combat layout)
--  Left panel ~48% | Right panel ~48% | gap 4%
-- ══════════════════════════════════════════════════════════════
local function TwoPanel(parent)
    local wrap = fr(parent, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Color3.new(), 1)
    local leftSC  = sc(wrap, UDim2.new(0.49,0,1,0), UDim2.new(0,0,0,0), C.Win)
    local rightSC = sc(wrap, UDim2.new(0.49,0,1,0), UDim2.new(0.51,0,0,0), C.Win)
    pd(leftSC, 6,4,6,6); vl(leftSC, 4)
    pd(rightSC, 6,6,6,4); vl(rightSC, 4)
    -- Divider
    local divLine = fr(wrap, UDim2.new(0,1,1,0), UDim2.new(0.50,0,0,0), C.Div)
    return leftSC, rightSC
end

-- ══════════════════════════════════════════════════════════════
--  NOTIFICATIONS
-- ══════════════════════════════════════════════════════════════
local NotifFrame = fr(SG, UDim2.new(0,240,1,0), UDim2.new(1,-248,0,10), Color3.new(), 1)
NotifFrame.ZIndex = 9999; vl(NotifFrame, 5)

local function notif(title, msg, ntype, dur)
    ntype = ntype or "info"; dur = dur or 3.5
    local cols = {info=C.Acc, success=C.Green, warn=C.Yellow, error=C.Red}
    local nc = cols[ntype] or C.Acc
    local nf = fr(NotifFrame, UDim2.new(1,0,0,46), UDim2.new(0,0,0,0), C.Panel)
    nf.ZIndex=9999; cr(nf,5); sk(nf,nc,1)
    local st = fr(nf, UDim2.new(0,2,0.6,0), UDim2.new(0,0,0.2,0), nc); cr(st,1)
    local tl3 = lb(nf, title, 11, C.TW, Enum.Font.GothamBold); tl3.Size=UDim2.new(1,-8,0,14); tl3.Position=UDim2.new(0,8,0,5); tl3.ZIndex=10000
    local ml  = lb(nf, msg, 9, C.TS2, Enum.Font.Gotham); ml.Size=UDim2.new(1,-8,0,22); ml.Position=UDim2.new(0,8,0,20); ml.TextWrapped=true; ml.ZIndex=10000
    local pb = fr(nf, UDim2.new(1,-4,0,2), UDim2.new(0,2,1,-4), nc); cr(pb,1); pb.BackgroundTransparency=0.5
    local pf = fr(pb, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), nc); cr(pf,1)
    nf.Position=UDim2.new(1,10,0,0); tw(nf,{Position=UDim2.new(0,0,0,0)},.22)
    tw(pf, {Size=UDim2.new(0,0,1,0)}, dur, Enum.EasingStyle.Linear)
    task.delay(dur, function() tw(nf,{Position=UDim2.new(1,10,0,0)},.2); task.delay(.25,function() pcall(function() nf:Destroy() end) end) end)
end

-- ══════════════════════════════════════════════════════════════
--  ██████████  COMBAT  TAB  ██████████
--  Left panel: Aimbot + sub-tabs (Aimbot|Prediction|Smoothness|FOV)
--  Right panel: Silent Aim + sub-tabs + Trigger Bot
--  Exactly matching screenshots
-- ══════════════════════════════════════════════════════════════
local combatPage = tabPages["Combat"]

-- Two-panel layout exactly like screenshots
local L, R = TwoPanel(combatPage)

-- ── LEFT PANEL ─ Aimbot sub-tabs ─────────────────────────────
-- Sub-tab bar on left
local lSubBar = fr(L, UDim2.new(1,0,0,20), UDim2.new(0,0,0,0), C.Win)
lSubBar.LayoutOrder=0; hl(lSubBar,0)

local lSubDefs = {
    {id="aimbot",    lbl="Aimbot"},
    {id="prediction",lbl="Prediction"},
    {id="smooth",    lbl="Smoothness"},
    {id="fov",       lbl="FOV"},
}
local lSubPages = {}
local lActiveSub = nil

local lSubHolder = sc(L, UDim2.new(1,0,1,-20), UDim2.new(0,0,0,20), C.Win)
pd(lSubHolder, 4,2,4,2); vl(lSubHolder,4)

local function switchLSub(id)
    for _,sp in pairs(lSubPages) do sp.Visible=false end
    for sid,sb in pairs(lSubPages) do
        local btn = lSubBar:FindFirstChild("btn_"..sid)
        if btn then
            local a = sid==id
            local bl3 = btn:FindFirstChildOfClass("TextLabel")
            if bl3 then tw(bl3,{TextColor3=a and C.AccL or C.TD},.12) end
            local bbar = btn:FindFirstChild("bar")
            if bbar then bbar.Visible=a end
        end
    end
    if lSubPages[id] then lSubPages[id].Visible=true end
    lActiveSub=id
end

for _, sd in ipairs(lSubDefs) do
    local btn = mk("TextButton", {
        Name="btn_"..sd.id, Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1, Text="", BorderSizePixel=0,
    }, lSubBar)
    pd(btn,0,6,0,6)
    local bl3 = lb(btn, sd.lbl, 9, C.TD, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    bl3.Size=UDim2.new(1,0,1,-2)
    local bbar2 = fr(btn, UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), C.Acc); bbar2.Visible=false; bbar2.Name="bar"

    local pg = sc(lSubHolder, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.Win)
    pg.Visible=false; pd(pg,2,2,2,2); vl(pg,3)
    lSubPages[sd.id]=pg

    btn.MouseButton1Click:Connect(function() switchLSub(sd.id) end)
end

-- Aimbot page content
local pgAB = lSubPages["aimbot"]
Checkbox(pgAB, "Enabled",      false, function(v) S.AB.On=v end,    0, "rmb")
Checkbox(pgAB, "Team Check",   false, function(v) S.AB.Team=v end,   1)
Checkbox(pgAB, "Visible Check",false, function(v) S.AB.Vis=v end,    2)
Checkbox(pgAB, "Health Check", false, function(v) S.AB.Health=v end, 3)
Checkbox(pgAB, "Sticky Aim",   false, function(v) S.AB.Sticky=v end, 4)
Slider(pgAB, "Distance",   50, 2000, 500,  function(v) S.AB.Dist=v end,    5)
Slider(pgAB, "Sensitivity",1,  100,  40,   function(v) S.AB.Sens=v/100 end,6)
FieldLabel(pgAB, "Hit Part", 7)
Dropdown(pgAB, {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}, "Head", function(v) S.AB.Part=v end, 8)
FieldLabel(pgAB, "Aim Type", 9)
Dropdown(pgAB, {"Mouse","Gyroscope","Camera"}, "Mouse", function(v) S.AB.AimType=v end, 10)
Checkbox(pgAB, "Rage Method",  false, function(v) S.AB.Rage=v end,   11)
FieldLabel(pgAB, "Type", 12)
Dropdown(pgAB, {"Camera Teleport","Legit","Body"}, "Camera Teleport", function(v) S.AB.Type=v end, 13)

SectionLabel(pgAB, "Misc", 14)
Checkbox(pgAB, "Resolver", false, function(v) S.AB.Resolver=v end, 15)
-- Soft Aim (new addition)
Checkbox(pgAB, "Soft Aim",  false, function(v) S.AB.Soft=v end, 16)
Slider(pgAB, "Soft Strength", 1, 100, 8, function(v) S.AB.SoftStr=v/100 end, 17)

-- Prediction page
local pgPred = lSubPages["prediction"]
Checkbox(pgPred, "Prediction", false, function(v) S.AB.Pred=v end, 0)
Slider(pgPred, "Prediction Amount", 1, 50, 12, function(v) S.AB.PredAmt=v/100 end, 1)

-- Smoothness page
local pgSmooth = lSubPages["smooth"]
Slider(pgSmooth, "Smooth Amount", 1, 100, 35, function(v) S.AB.Sens=v/100 end, 0)

-- FOV page
local pgFOV = lSubPages["fov"]
Checkbox(pgFOV, "FOV Enabled", false, function(v) S.AB.FOVOn=v end, 0)
Checkbox(pgFOV, "FOV Filled",  false, function(v) S.AB.FOVFill=v end, 1)
Slider(pgFOV, "FOV Size", 10, 600, 150, function(v) S.AB.FOVSz=v end, 2)

task.defer(function() switchLSub("aimbot") end)

-- ── RIGHT PANEL ─ Silent Aim + Trigger Bot ────────────────────
local rSubBar = fr(R, UDim2.new(1,0,0,20), UDim2.new(0,0,0,0), C.Win)
rSubBar.LayoutOrder=0; hl(rSubBar,0)

local rSubDefs = {
    {id="silentaim", lbl="Silent Aim"},
    {id="pred",      lbl="Prediction"},
    {id="fov2",      lbl="FOV"},
}
local rSubPages = {}
local rActiveSub = nil

local rSubHolder = sc(R, UDim2.new(1,0,1,-20), UDim2.new(0,0,0,20), C.Win)
pd(rSubHolder,4,2,4,2); vl(rSubHolder,4)

local function switchRSub(id)
    for _,sp in pairs(rSubPages) do sp.Visible=false end
    for sid,_ in pairs(rSubPages) do
        local btn=rSubBar:FindFirstChild("rbtn_"..sid)
        if btn then
            local a=sid==id
            local bl4=btn:FindFirstChildOfClass("TextLabel")
            if bl4 then tw(bl4,{TextColor3=a and C.AccL or C.TD},.12) end
            local bbar3=btn:FindFirstChild("bar")
            if bbar3 then bbar3.Visible=a end
        end
    end
    if rSubPages[id] then rSubPages[id].Visible=true end
    rActiveSub=id
end

for _,sd in ipairs(rSubDefs) do
    local btn=mk("TextButton",{
        Name="rbtn_"..sd.id, Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1, Text="", BorderSizePixel=0,
    },rSubBar)
    pd(btn,0,6,0,6)
    local bl4=lb(btn,sd.lbl,9,C.TD,Enum.Font.Gotham,Enum.TextXAlignment.Center)
    bl4.Size=UDim2.new(1,0,1,-2)
    local bbar3=fr(btn,UDim2.new(1,0,0,1),UDim2.new(0,0,1,-1),C.Acc); bbar3.Visible=false; bbar3.Name="bar"
    local pg=sc(rSubHolder,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.Win)
    pg.Visible=false; pd(pg,2,2,2,2); vl(pg,3)
    rSubPages[sd.id]=pg
    btn.MouseButton1Click:Connect(function() switchRSub(sd.id) end)
end

-- Silent Aim content
local pgSA2 = rSubPages["silentaim"]
Checkbox(pgSA2, "Enabled",      false, function(v) S.SA.On=v end,     0, "e")
Checkbox(pgSA2, "Team Check",   false, function(v) S.SA.Team=v end,    1)
Checkbox(pgSA2, "Visible Check",false, function(v) S.SA.Vis=v end,     2)
Checkbox(pgSA2, "Health Check", false, function(v) S.SA.Health=v end,  3)
Checkbox(pgSA2, "Sticky Aim",   false, function(v) S.SA.Sticky=v end,  4)
Slider(pgSA2, "Distance", 50, 2000, 500, function(v) S.SA.Dist=v end,  5)
FieldLabel(pgSA2, "Hit Part", 6)
Dropdown(pgSA2, {"Head","Torso","Left Arm","Right Arm"}, "Head", function(v) S.SA.Part=v end, 7)
FieldLabel(pgSA2, "Methods", 8)
Dropdown(pgSA2, {"Experimental","Standard","Legacy"}, "Experimental", function(v) S.SA.Method=v end, 9)

-- Trigger Bot section (inside silent aim panel, below Methods - matching screenshot)
SectionLabel(pgSA2, "Trigger Bot", 10)
Checkbox(pgSA2, "Enabled",      false, function(v) S.TB.On=v end,     11, "q")
Checkbox(pgSA2, "Visible Check",false, function(v) S.TB.Vis=v end,    12)
Checkbox(pgSA2, "Team Check",   false, function(v) S.TB.Team=v end,   13)
Slider(pgSA2, "Hitbox Mul", 1, 10, 1,   function(v) S.TB.HBMul=v end, 14, true)
Slider(pgSA2, "Delay (ms)", 0, 500, 1,  function(v) S.TB.Delay=v end, 15)
Slider(pgSA2, "Release (ms)", 0, 200, 10,function(v) S.TB.Release=v end,16)

task.defer(function() switchRSub("silentaim") end)

-- ══════════════════════════════════════════════════════════════
--  ██████████  VISUALS  TAB  ██████████
--  Left: ESP sub-tabs | Right: Indicators/OOF Arrow/Radar
--  + ESP Preview panel (right side, shows "Loading avatar...")
-- ══════════════════════════════════════════════════════════════
local visualsPage = tabPages["Visuals"]

-- Real Matcha visuals: left ~55% ESP, right ~44% Indicators+Preview
local VL = sc(visualsPage, UDim2.new(0.55,-2,1,0), UDim2.new(0,0,0,0), C.Win)
local VR = sc(visualsPage, UDim2.new(0.45,-2,1,0), UDim2.new(0.55,2,0,0), C.Win)
local vDiv = fr(visualsPage, UDim2.new(0,1,1,0), UDim2.new(0.55,0,0,0), C.Div)
pd(VL,6,4,6,6); vl(VL,3)
pd(VR,6,6,6,4); vl(VR,3)

-- Left: ESP sub-tabs
local vLSubBar = fr(VL, UDim2.new(1,0,0,20), UDim2.new(0,0,0,0), C.Win)
vLSubBar.LayoutOrder=0; hl(vLSubBar,0)

local vLSubDefs = {{id="esp2",lbl="ESP"},{id="cross",lbl="Crosshair"},{id="misc2",lbl="Misc"},{id="flags",lbl="Flags"}}
local vLSPages={}
local vLSubHolder=sc(VL,UDim2.new(1,0,1,-20),UDim2.new(0,0,0,20),C.Win)
pd(vLSubHolder,4,2,4,2); vl(vLSubHolder,3)

local function switchVLSub(id)
    for _,sp in pairs(vLSPages) do sp.Visible=false end
    for sid,_ in pairs(vLSPages) do
        local btn=vLSubBar:FindFirstChild("vb_"..sid)
        if btn then
            local a=sid==id
            local bl5=btn:FindFirstChildOfClass("TextLabel")
            if bl5 then tw(bl5,{TextColor3=a and C.AccL or C.TD},.12) end
            local bb=btn:FindFirstChild("bar"); if bb then bb.Visible=a end
        end
    end
    if vLSPages[id] then vLSPages[id].Visible=true end
end

for _,sd in ipairs(vLSubDefs) do
    local btn=mk("TextButton",{Name="vb_"..sd.id,Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text="",BorderSizePixel=0},vLSubBar)
    pd(btn,0,6,0,6)
    local bl5=lb(btn,sd.lbl,9,C.TD,Enum.Font.Gotham,Enum.TextXAlignment.Center); bl5.Size=UDim2.new(1,0,1,-2)
    local bb=fr(btn,UDim2.new(1,0,0,1),UDim2.new(0,0,1,-1),C.Acc); bb.Visible=false; bb.Name="bar"
    local pg=sc(vLSubHolder,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.Win)
    pg.Visible=false; pd(pg,2,2,2,2); vl(pg,3); vLSPages[sd.id]=pg
    btn.MouseButton1Click:Connect(function() switchVLSub(sd.id) end)
end

-- ESP page (exactly matching screenshot checkboxes)
local pgESP2 = vLSPages["esp2"]

-- Colour buttons row (like the blue/red squares in screenshot)
local colorRow = fr(pgESP2, UDim2.new(1,0,0,20), UDim2.new(0,0,0,0), Color3.new(), 1)
colorRow.LayoutOrder=0
local colorBtn1=fr(colorRow,UDim2.new(0,14,0,14),UDim2.new(0,0,0.5,-7),Color3.fromRGB(66,133,244)); cr(colorBtn1,3)
local colorBtn2=fr(colorRow,UDim2.new(0,14,0,14),UDim2.new(0,18,0.5,-7),Color3.fromRGB(220,50,50)); cr(colorBtn2,3)
local colorLbl=lb(colorRow,"none",9,C.TD,Enum.Font.Gotham,Enum.TextXAlignment.Right)
colorLbl.Size=UDim2.new(0,30,1,0); colorLbl.Position=UDim2.new(1,-32,0,0)

Checkbox(pgESP2,"Enabled",      false,function(v) S.ESP.On=v end,    1)
Checkbox(pgESP2,"Team Check",   false,function(v) S.ESP.Team=v end,  2)
Checkbox(pgESP2,"Visible Check",false,function(v) S.ESP.Vis=v end,   3)
Checkbox(pgESP2,"Team Based Color",false,function(v) S.ESP.TeamColor=v end,4)
Checkbox(pgESP2,"Text Gradient",true, function(v) S.ESP.TxtGrad=v end,5)
Checkbox(pgESP2,"Text Background",false,function(v) S.ESP.TxtBG=v end,6)
Checkbox(pgESP2,"Outline",      true, function(v) S.ESP.Outline=v end,7)
Checkbox(pgESP2,"Glow",         false,function(v) S.ESP.Glow=v end,  8)
Checkbox(pgESP2,"Self ESP",     false,function(v) S.ESP.Self=v end,  9)
FieldLabel(pgESP2,"Sizing Type",10)
Dropdown(pgESP2,{"Bounding","Dynamic","Static"},"Bounding",function(v) S.ESP.SizeType=v end,11)
Slider(pgESP2,"Render Distance",100,8000,3000,function(v) S.ESP.RDist=v end,12)

-- Box section
SectionLabel(pgESP2,"Box",13)
Checkbox(pgESP2,"Enabled",false,function(v) S.ESP.Box=v end,14)
Checkbox(pgESP2,"Fill Box",false,function(v) S.ESP.Fill=v end,15)
FieldLabel(pgESP2,"Box Type",16)
Dropdown(pgESP2,{"2D","3D","Corner"},"2D",function(v) S.ESP.BoxType=v end,17)

-- Name section
SectionLabel(pgESP2,"Name",18)
Checkbox(pgESP2,"Enabled",false,function(v) S.ESP.Name=v end,19)

-- Chams section
SectionLabel(pgESP2,"Chams",20)
Checkbox(pgESP2,"Enabled",false,function(v) S.ESP.Chams=v end,21)
Checkbox(pgESP2,"Filled", true, function(v) S.ESP.ChamsFill=v end,22)
FieldLabel(pgESP2,"Rendering Type",23)
Dropdown(pgESP2,{"Static","Dynamic","Wireframe"},"Static",function(v) S.ESP.ChamsType=v end,24)

-- Tracer section
SectionLabel(pgESP2,"Tracer",25)
Checkbox(pgESP2,"Enabled",false,function(v) S.ESP.Trace=v end,26)
FieldLabel(pgESP2,"Origin",27)
Dropdown(pgESP2,{"Top","Bottom","Middle"},"Bottom",function(v) S.ESP.TraceOrigin=v end,28)

-- Crosshair page
local pgCross = vLSPages["cross"]
local CX={On=false,Style="Cross",Size=10,Gap=4,Thick=1}
Checkbox(pgCross,"Enabled",false,function(v) CX.On=v end,0)
FieldLabel(pgCross,"Style",1)
Dropdown(pgCross,{"Cross","Dot","Circle","T-Shape"},"Cross",function(v) CX.Style=v end,2)
Slider(pgCross,"Size",2,30,10,function(v) CX.Size=v end,3)
Slider(pgCross,"Gap",0,20,4,function(v) CX.Gap=v end,4)
Slider(pgCross,"Thickness",1,5,1,function(v) CX.Thick=v end,5)

-- Misc visuals page
local pgVMisc = vLSPages["misc2"]
Checkbox(pgVMisc,"Fullbright",false,function(v) S.WL.Full=v end,0)
Checkbox(pgVMisc,"No Fog",false,function(v) S.WL.NoFog=v end,1)
Checkbox(pgVMisc,"Rainbow ESP",false,function(v) S.ESP.Rainbow=v end,2)

task.defer(function() switchVLSub("esp2") end)

-- Right panel: sub-tabs  Indicators | OOF Arrow | Radar
local vRSubBar=fr(VR,UDim2.new(1,0,0,20),UDim2.new(0,0,0,0),C.Win)
vRSubBar.LayoutOrder=0; hl(vRSubBar,0)

local vRSubDefs={{id="indicators",lbl="Indicators"},{id="oof",lbl="OOF Arrow"},{id="radar",lbl="Radar"}}
local vRSPages={}
local vRSubHolder=sc(VR,UDim2.new(1,0,1,-20),UDim2.new(0,0,0,20),C.Win)
pd(vRSubHolder,4,2,4,2); vl(vRSubHolder,3)

local function switchVRSub(id)
    for _,sp in pairs(vRSPages) do sp.Visible=false end
    for sid,_ in pairs(vRSPages) do
        local btn=vRSubBar:FindFirstChild("vrb_"..sid)
        if btn then
            local a=sid==id
            local bl6=btn:FindFirstChildOfClass("TextLabel")
            if bl6 then tw(bl6,{TextColor3=a and C.AccL or C.TD},.12) end
            local bb=btn:FindFirstChild("bar"); if bb then bb.Visible=a end
        end
    end
    if vRSPages[id] then vRSPages[id].Visible=true end
end

for _,sd in ipairs(vRSubDefs) do
    local btn=mk("TextButton",{Name="vrb_"..sd.id,Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text="",BorderSizePixel=0},vRSubBar)
    pd(btn,0,6,0,6)
    local bl6=lb(btn,sd.lbl,9,C.TD,Enum.Font.Gotham,Enum.TextXAlignment.Center); bl6.Size=UDim2.new(1,0,1,-2)
    local bb=fr(btn,UDim2.new(1,0,0,1),UDim2.new(0,0,1,-1),C.Acc); bb.Visible=false; bb.Name="bar"
    local pg=sc(vRSubHolder,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.Win)
    pg.Visible=false; pd(pg,2,2,2,2); vl(pg,3); vRSPages[sd.id]=pg
    btn.MouseButton1Click:Connect(function() switchVRSub(sd.id) end)
end

-- Indicators page (right side, matching screenshot colour squares)
local pgInd = vRSPages["indicators"]

-- Colour squares next to each (like screenshot)
local function IndRow(parent, text, default, cb, order)
    local row=fr(parent,UDim2.new(1,0,0,20),UDim2.new(0,0,0,0),Color3.new(),1)
    row.LayoutOrder=order or 0
    local box=fr(row,UDim2.new(0,11,0,11),UDim2.new(0,0,0.5,-5.5),default and C.Acc or C.Track)
    cr(box,2); sk(box,default and C.Acc or C.Div,1)
    local tick=lb(box,"✓",7,C.White,Enum.Font.GothamBold,Enum.TextXAlignment.Center); tick.Visible=default or false
    local txt=lb(row,text,10,C.TW,Enum.Font.Gotham); txt.Size=UDim2.new(1,-16,1,0); txt.Position=UDim2.new(0,14,0,0)
    -- White colour swatch button on right
    local sw=fr(row,UDim2.new(0,12,0,12),UDim2.new(1,-14,0.5,-6),C.White); cr(sw,2)
    local state=default or false
    local function set(v,s) state=v tw(box,{BackgroundColor3=v and C.Acc or C.Track},.15) sk(box,v and C.Acc or C.Div,1) tick.Visible=v if not s and cb then pcall(cb,v) end end
    row.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then set(not state) end end)
    return row,set
end

IndRow(pgInd,"Distance",  false, function(v) S.ESP.Dist=v end,   0)
IndRow(pgInd,"Equipped Item",false, function(v) S.ESP.Equip=v end,  1)
IndRow(pgInd,"Skeleton",  false, function(v) S.ESP.Skel=v end,   2)
IndRow(pgInd,"Head Dot",  false, function(v) S.ESP.Dot=v end,    3)
IndRow(pgInd,"Head Dot Glow",false,function(v) S.ESP.DotGlow=v end,4)
IndRow(pgInd,"Profile Picture",false,function(v) S.ESP.Prof=v end, 5)

-- Health section
SectionLabel(pgInd,"Health",6)
local hgRow=fr(pgInd,UDim2.new(1,0,0,20),UDim2.new(0,0,0,0),Color3.new(),1)
hgRow.LayoutOrder=7
local hgChk=fr(hgRow,UDim2.new(0,11,0,11),UDim2.new(0,0,0.5,-5.5),C.Track); cr(hgChk,2); sk(hgChk,C.Div,1)
local hgTick=lb(hgChk,"✓",7,C.White,Enum.Font.GothamBold,Enum.TextXAlignment.Center); hgTick.Visible=false
local hgTxt=lb(hgRow,"Health Bar",10,C.TW,Enum.Font.Gotham); hgTxt.Size=UDim2.new(1,-16,1,0); hgTxt.Position=UDim2.new(0,14,0,0)
-- Green swatch (like screenshot)
local hgSwatch=fr(hgRow,UDim2.new(0,12,0,12),UDim2.new(1,-14,0.5,-6),C.Green); cr(hgSwatch,2)
hgRow.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then S.ESP.HBar=not S.ESP.HBar; hgTick.Visible=S.ESP.HBar; tw(hgChk,{BackgroundColor3=S.ESP.HBar and C.Acc or C.Track},.15) end end)

Checkbox(pgInd,"Health Based",false,function(v) S.ESP.HBased=v end,8)
Checkbox(pgInd,"Health Text", false,function(v) S.ESP.HText=v end, 9)
FieldLabel(pgInd,"Text Pos",10)
Dropdown(pgInd,{"Above Name","Below Name","Left","Right"},"Above Name",function(v) S.ESP.HTextPos=v end,11)

-- Account mirror in Indicators
SectionLabel(pgInd,"Account Mirror",12)
local mirrorFrame=fr(pgInd,UDim2.new(1,0,0,70),UDim2.new(0,0,0,0),C.Panel)
mirrorFrame.LayoutOrder=13; cr(mirrorFrame,5); sk(mirrorFrame,C.Div,1)
local mirrorInner=fr(mirrorFrame,UDim2.new(1,-4,1,-4),UDim2.new(0,2,0,2),Color3.new(),1)

-- Avatar image
local avImg=mk("ImageLabel",{
    Size=UDim2.new(0,52,0,52),Position=UDim2.new(0,4,0.5,-26),
    BackgroundColor3=C.Track,BackgroundTransparency=0,
    Image="rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150",BorderSizePixel=0,
},mirrorInner); cr(avImg,4)

-- Info
local avInfo=fr(mirrorInner,UDim2.new(1,-64,1,0),UDim2.new(0,60,0,0),Color3.new(),1)
vl(avInfo,2)
local function avRow(k,v2)
    local r=fr(avInfo,UDim2.new(1,0,0,14),UDim2.new(0,0,0,0),Color3.new(),1)
    local kl=lb(r,k,8,C.TD,Enum.Font.Gotham); kl.Size=UDim2.new(0.4,0,1,0)
    local vl3=lb(r,v2,8,C.AccL,Enum.Font.GothamBold); vl3.Size=UDim2.new(0.58,0,1,0); vl3.Position=UDim2.new(0.4,0,0,0)
    return vl3
end
local avName=avRow("User:",LP.Name)
local avID=avRow("ID:",tostring(LP.UserId))
local avHP=avRow("HP:","--")
local avPos=avRow("Pos:","--")

RS.Heartbeat:Connect(function()
    pcall(function()
        local ch=LP.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid"); local root=ch and ch:FindFirstChild("HumanoidRootPart")
        if hum then avHP.Text=math.floor(hum.Health).."/"..math.floor(hum.MaxHealth) end
        if root then local p=root.Position; avPos.Text=string.format("%d,%d,%d",p.X,p.Y,p.Z) end
    end)
end)

-- "Loading avatar..." preview panel (right side of Visuals, like screenshot)
local previewPanel=fr(pgInd,UDim2.new(1,0,0,80),UDim2.new(0,0,0,0),C.Panel)
previewPanel.LayoutOrder=14; cr(previewPanel,5); sk(previewPanel,C.Div,1)

-- Preview tabs: ESP | Preview | 3D
local prevTabBar=fr(previewPanel,UDim2.new(1,0,0,18),UDim2.new(0,0,0,0),C.Win)
hl(prevTabBar,0); pd(prevTabBar,0,4,0,4)
for _,ptn in ipairs({"ESP","Preview","3D"}) do
    local ptb=lb(prevTabBar,ptn,9,C.TD,Enum.Font.Gotham,Enum.TextXAlignment.Center)
    ptb.Size=UDim2.new(0,26,1,0)
end

-- Avatar preview
local prevImg=mk("ImageLabel",{
    Size=UDim2.new(0,50,0,55),Position=UDim2.new(0.5,-25,0,18),
    BackgroundColor3=C.Track,BackgroundTransparency=0,
    Image="rbxthumb://type=Avatar&id="..LP.UserId.."&w=150&h=150",BorderSizePixel=0,
},previewPanel); cr(prevImg,3)
local prevLbl=lb(previewPanel,"Loading avatar...",9,C.TD,Enum.Font.Gotham,Enum.TextXAlignment.Center)
prevLbl.Size=UDim2.new(1,0,0,12); prevLbl.Position=UDim2.new(0,0,1,-13)

task.defer(function() switchVRSub("indicators") end)

-- ══════════════════════════════════════════════════════════════
--  WORLD TAB
-- ══════════════════════════════════════════════════════════════
local worldPage = tabPages["World"]
local WL2, WR2 = TwoPanel(worldPage)

-- Left: Camera | Freecam
local wLSubBar=fr(WL2,UDim2.new(1,0,0,20),UDim2.new(0,0,0,0),C.Win); wLSubBar.LayoutOrder=0; hl(wLSubBar,0)
local wLP={}
local wLHolder=sc(WL2,UDim2.new(1,0,1,-20),UDim2.new(0,0,0,20),C.Win); pd(wLHolder,4,2,4,2); vl(wLHolder,3)

local function switchWL(id)
    for _,sp in pairs(wLP) do sp.Visible=false end
    for sid,_ in pairs(wLP) do
        local btn=wLSubBar:FindFirstChild("wlb_"..sid)
        if btn then local a=sid==id local bl7=btn:FindFirstChildOfClass("TextLabel") if bl7 then tw(bl7,{TextColor3=a and C.AccL or C.TD},.12) end local bb=btn:FindFirstChild("bar") if bb then bb.Visible=a end end
    end
    if wLP[id] then wLP[id].Visible=true end
end

for _,sd in ipairs({{id="camera",lbl="Camera"},{id="freecam",lbl="Freecam"}}) do
    local btn=mk("TextButton",{Name="wlb_"..sd.id,Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text="",BorderSizePixel=0},wLSubBar)
    pd(btn,0,8,0,8)
    local bl7=lb(btn,sd.lbl,9,C.TD,Enum.Font.Gotham,Enum.TextXAlignment.Center); bl7.Size=UDim2.new(1,0,1,-2)
    local bb=fr(btn,UDim2.new(1,0,0,1),UDim2.new(0,0,1,-1),C.Acc); bb.Visible=false; bb.Name="bar"
    local pg=sc(wLHolder,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.Win); pg.Visible=false; pd(pg,2,2,2,2); vl(pg,3); wLP[sd.id]=pg
    btn.MouseButton1Click:Connect(function() switchWL(sd.id) end)
end

-- Camera page
local pgCam2=wLP["camera"]
Checkbox(pgCam2,"Camera Field Of View",false,function(v) S.WC.FOVOn=v end,0)
Slider(pgCam2,"Amount",30,120,70,function(v) S.WC.FOVAmt=v end,1)
SectionLabel(pgCam2,"Waypoint",2)

local wpNameBox=mk("TextBox",{
    Size=UDim2.new(1,0,0,20),BackgroundColor3=C.Track,BackgroundTransparency=0,
    Text="",PlaceholderText="Name...",PlaceholderColor3=C.TD,
    TextColor3=C.TW,TextSize=10,Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,
    LayoutOrder=3,
},pgCam2); cr(wpNameBox,3); sk(wpNameBox,C.Div,1); pd(wpNameBox,0,0,0,6)

-- No Saved Waypoints label
local noWPLbl=lb(pgCam2,"No Saved Waypoints",10,Color3.fromRGB(195,70,245),Enum.Font.Gotham)
noWPLbl.Size=UDim2.new(1,0,0,16); noWPLbl.LayoutOrder=4

ActionBtn(pgCam2,"Create",C.Acc,function()
    local name=wpNameBox.Text:gsub("%s+","")
    if name=="" then name="WP"..tostring(#S.WP.List+1) end
    local ch=LP.Character; local root=ch and ch:FindFirstChild("HumanoidRootPart")
    if root then table.insert(S.WP.List,{name=name,cf=root.CFrame}) notif("Waypoint","Saved: "..name,"success") wpNameBox.Text="" end
end,5)
ActionBtn(pgCam2,"Remove Waypoint",C.Red,function()
    local name=wpNameBox.Text:gsub("%s+","")
    for i,wp in ipairs(S.WP.List) do if wp.name==name then table.remove(S.WP.List,i) notif("Waypoint","Removed: "..name,"info") return end end
end,6)
ActionBtn(pgCam2,"Goto",C.Acc,function()
    local name=wpNameBox.Text:gsub("%s+","")
    local ch=LP.Character; local root=ch and ch:FindFirstChild("HumanoidRootPart")
    if root then for _,wp in ipairs(S.WP.List) do if wp.name==name then root.CFrame=wp.cf notif("Goto","Teleported!","success") return end end end
end,7)

Checkbox(pgCam2,"Tween goto",false,function(v) S.WP.TweenGoto=v end,8)
Slider(pgCam2,"Tween speed",1,2000,200,function(v) S.WP.TweenSpeed=v end,9)
Checkbox(pgCam2,"Visualize waypoint",false,function(v) S.WP.Vis=v end,10)
task.defer(function() switchWL("camera") end)

-- Right: World Lighting
local pgWLit=sc(WR2,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.Win)
pd(pgWLit,6,4,6,4); vl(pgWLit,3)

lb(pgWLit,"World Lighting",10,C.TS2,Enum.Font.GothamBold).LayoutOrder=0

-- White colour swatches (like screenshot)
local function LitRow(parent, text, default, cb, order)
    local row=fr(parent,UDim2.new(1,0,0,20),UDim2.new(0,0,0,0),Color3.new(),1)
    row.LayoutOrder=order or 0
    local box=fr(row,UDim2.new(0,11,0,11),UDim2.new(0,0,0.5,-5.5),default and C.Acc or C.Track); cr(box,2); sk(box,default and C.Acc or C.Div,1)
    local tick=lb(box,"✓",7,C.White,Enum.Font.GothamBold,Enum.TextXAlignment.Center); tick.Visible=default or false
    local txt=lb(row,text,10,C.TW,Enum.Font.Gotham); txt.Size=UDim2.new(1,-28,1,0); txt.Position=UDim2.new(0,14,0,0)
    local sw=fr(row,UDim2.new(0,12,0,12),UDim2.new(1,-14,0.5,-6),C.White); cr(sw,2)
    local state=default or false
    local function set(v,s) state=v tw(box,{BackgroundColor3=v and C.Acc or C.Track},.15) sk(box,v and C.Acc or C.Div,1) tick.Visible=v if not s and cb then pcall(cb,v) end end
    row.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then set(not state) end end)
    return row,set
end

LitRow(pgWLit,"Ambience",false,function(v) S.WL.Ambience=v end,1)
LitRow(pgWLit,"Custom Fog",false,function(v) S.WL.CustomFog=v end,2)
Checkbox(pgWLit,"Glow",false,function(v) S.WL.Glow=v end,3)
Slider(pgWLit,"Distance",0,1000,0,function(v) S.WL.FogDist=v end,4)

Checkbox(pgWLit,"Custom Exposure",false,function(v) S.WL.Exposure=v end,5)
Slider(pgWLit,"Exposure Compensation",0,5,2,function(v) S.WL.ExpoVal=v end,6,true)
Checkbox(pgWLit,"Custom Brightness",false,function(v) S.WL.Bright=v end,7)
Slider(pgWLit,"Brightness",0,5,2,function(v) S.WL.BrightVal=v end,8,true)
Checkbox(pgWLit,"Custom Time",false,function(v) S.WL.Time=v end,9)
Slider(pgWLit,"Clock Time",0,24,12,function(v) S.WL.TimeVal=v end,10,true)
Checkbox(pgWLit,"Custom Sky",false,function(v) S.WL.Sky=v end,11)
FieldLabel(pgWLit,"Sky",12)
Dropdown(pgWLit,{"Galaxy Nebula","Default","Bluesky","Night","Sunset"},"Galaxy Nebula",function(v) S.WL.SkyVal=v end,13)

-- ══════════════════════════════════════════════════════════════
--  CHARACTER TAB  (matches screenshot exactly)
--  Left: Hitbox Extender + Target Hovering + Desync
--  Right: Movement + Flight + Jump + Float + Timer
-- ══════════════════════════════════════════════════════════════
local charPage = tabPages["Character"]
local CL, CR2 = TwoPanel(charPage)

-- Left side: no sub-tabs, just sections
local clSC=sc(CL,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.Win); pd(clSC,6,4,6,6); vl(clSC,4)

SectionLabel(clSC,"Hitbox Extender",0)
Checkbox(clSC,"Enabled",      true, function(v) S.HB.On=v end,     1)
Checkbox(clSC,"Visualize Hitbox",false,function(v) S.HB.Vis=v end,  2)
Checkbox(clSC,"Team Check",   false,function(v) S.HB.Team=v end,   3)
Checkbox(clSC,"Health Check", false,function(v) S.HB.Health=v end, 4)
Slider(clSC,"Hitbox Size",1,100,20,function(v) S.HB.Sz=v end,5)
FieldLabel(clSC,"Type",6)
Dropdown(clSC,{"Old","New","Hybrid"},"Old",function(v) S.HB.Type=v end,7)

SectionLabel(clSC,"Target Hovering",8)
Checkbox(clSC,"Enabled",     false,function(v) S.TH.On=v end,    9)
Checkbox(clSC,"Display Circle",false,function(v) S.TH.Circle=v end,10)
FieldLabel(clSC,"Target Method",11)
Dropdown(clSC,{"Closest To Mouse","Closest To Center","Random"},"Closest To Mouse",function(v) S.TH.Method=v end,12)
Slider(clSC,"Radius",0,50,10,function(v) S.TH.Radius=v end,13,true)
Slider(clSC,"Speed",0,50,5.60,function(v) S.TH.Speed=v end,14,true)

SectionLabel(clSC,"Desync",15)
Checkbox(clSC,"Enabled",         false,function(v) S.DS.On=v end,      16,"xbutton1")
FieldLabel(clSC,"Method",17)
Dropdown(clSC,{"Client-Sided","Server-Sided","Hybrid"},"Client-Sided",function(v) S.DS.Method=v end,18)
Checkbox(clSC,"Remove Walk Animation",false,function(v) S.DS.RemWalk=v end,19)
Checkbox(clSC,"Disable Animation",    false,function(v) S.DS.DisAnim=v end,20)
Checkbox(clSC,"Use Tick",             false,function(v) S.DS.Tick=v end,   21)
Checkbox(clSC,"Invisible",            false,function(v) S.DS.Invis=v end,  22)

-- Right side: Movement
local crSC=sc(CR2,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.Win); pd(crSC,6,6,6,4); vl(crSC,4)

SectionLabel(crSC,"Movement",0)
Checkbox(crSC,"Anti-Fling", false,function(v) S.MV.AntiFling=v end,1)
Checkbox(crSC,"No-Clip",    false,function(v) S.MV.NoClip=v end,   2,"z")
Checkbox(crSC,"Inf Jump",   false,function(v) S.MV.InfJump=v end,  3)
Checkbox(crSC,"Click TP",   false,function(v) S.MV.ClickTP=v end,  4,"control")
Checkbox(crSC,"Speed",      false,function(v) S.MV.Speed=v end,    5,"v")
FieldLabel(crSC,"Speed Method",6)
Dropdown(crSC,{"Velocity","BodyVelocity","Fly"},"Velocity",function(v) S.MV.SpeedMeth=v end,7)
Slider(crSC,"Speed Amount",1,200,1,function(v) S.MV.SpeedAmt=v end,8)

-- Flight
Checkbox(crSC,"Flight",false,function(v) S.MV.Flight=v end,9,"f")
FieldLabel(crSC,"Flight Method",10)
Dropdown(crSC,{"Velocity","BodyVelocity","Noclip"},"Velocity",function(v) S.MV.FlightMeth=v end,11)
Slider(crSC,"Flight Amount",1,200,1,function(v) S.MV.FlightAmt=v end,12)

-- Jump
Checkbox(crSC,"Jump",false,function(v) S.MV.Jump=v end,13)
Slider(crSC,"Jump Power",1,500,50,function(v) S.MV.JumpPow=v end,14)

-- Float
Checkbox(crSC,"Float",false,function(v) S.MV.Float=v end,15)
Slider(crSC,"Height",0,200,10,function(v) S.MV.FloatH=v end,16)

-- Timer Manipulation
SectionLabel(crSC,"Timer Manipulation",17)
Checkbox(crSC,"Enabled",false,function(v) S.MV.Timer=v end,18,"y")
Slider(crSC,"Multiply",1,500,100,function(v) S.MV.TimerMul=v/100 end,19,true)

-- ══════════════════════════════════════════════════════════════
--  OPTIONS TAB  (Script Hub + Settings)
-- ══════════════════════════════════════════════════════════════
local optPage = tabPages["Options"]
local optSC = sc(optPage, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.Win)
pd(optSC,8,8,8,8); vl(optSC,6)

SectionLabel(optSC,"Script Hub",0)

local hubs={
    {name="Owl Hub",   col=C.Yellow, url="https://raw.githubusercontent.com/ItzzSEV/OG-Owl-Hub/master/Owl%20Hub"},
    {name="Hoho Hub",  col=C.Cyan,   url="https://raw.githubusercontent.com/acsu123/HOHO_H/main/Loading_UI"},
    {name="Infinite Yield",col=C.Green,url="https://raw.githubusercontent.com/EdgeIY/infinite-yield/master/source"},
    {name="Dark Hub",  col=C.Slider, url="https://raw.githubusercontent.com/RandomAdamYT/DarkHub/master/init"},
    {name="Sirius",    col=C.Acc,    url="https://raw.githubusercontent.com/Stefanuk12/Sirius/main/Hub"},
}

for i,hub in ipairs(hubs) do
    local hRow=fr(optSC,UDim2.new(1,0,0,28),UDim2.new(0,0,0,0),C.Panel)
    hRow.LayoutOrder=i; cr(hRow,5); sk(hRow,C.Div,1)

    local hName=lb(hRow,hub.name,11,C.TW,Enum.Font.GothamBold)
    hName.Size=UDim2.new(0.45,0,1,0); hName.Position=UDim2.new(0,8,0,0)

    local loadBtn=mk("TextButton",{
        Size=UDim2.new(0,56,0,20),Position=UDim2.new(1,-120,0.5,-10),
        BackgroundColor3=hub.col,BackgroundTransparency=0.75,
        Text="▶ Load",TextColor3=hub.col,TextSize=9,Font=Enum.Font.GothamBold,BorderSizePixel=0,
    },hRow); cr(loadBtn,4); sk(loadBtn,hub.col,1)

    local copyBtn=mk("TextButton",{
        Size=UDim2.new(0,52,0,20),Position=UDim2.new(1,-60,0.5,-10),
        BackgroundColor3=C.Track,BackgroundTransparency=0,
        Text="Copy",TextColor3=C.TS2,TextSize=9,Font=Enum.Font.Gotham,BorderSizePixel=0,
    },hRow); cr(copyBtn,4); sk(copyBtn,C.Div,1)

    loadBtn.MouseButton1Click:Connect(function()
        if hub.url~="" then
            local ok2,err=pcall(function() loadstring(game:HttpGet(hub.url,true))() end)
            notif(hub.name, ok2 and "Loaded!" or "Failed: "..(err or "?"), ok2 and "success" or "error")
        end
    end)
    copyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(hub.url) end)
        notif("Copied",hub.name,"info")
    end)

    hRow.MouseEnter:Connect(function() tw(hRow,{BackgroundColor3=C.Row},.1) end)
    hRow.MouseLeave:Connect(function() tw(hRow,{BackgroundColor3=C.Panel},.1) end)
end

SectionLabel(optSC,"Interface",#hubs+1)
Slider(optSC,"UI Opacity",10,100,100,function(v) Win.BackgroundTransparency=1-(v/100) end,#hubs+2)

-- ══════════════════════════════════════════════════════════════
--  HIDE TAB
-- ══════════════════════════════════════════════════════════════
local hidePage2 = tabPages["Configs"]  -- Use Configs slot for Hide
local hideSC = sc(hidePage2, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.Win)
pd(hideSC,8,8,8,8); vl(hideSC,5)

SectionLabel(hideSC,"Hide Delta UI",0)
Checkbox(hideSC,"Hide All Delta UI",false,function(v)
    if v then
        local cnt=0
        local function scan(p) pcall(function() for _,ch in ipairs(p:GetChildren()) do local n=ch.Name:lower() if n:find("delta") or n:find("watermark") or n:find("executor") then pcall(function() if ch:IsA("ScreenGui") or ch:IsA("GuiBase") then ch.Enabled=false; cnt=cnt+1 end end) end scan(ch) end end) end
        pcall(function() scan(CGui) end); pcall(function() scan(PGui) end)
        notif("Hidden",cnt.." Delta objects","success")
    end
end,1)
Checkbox(hideSC,"Hide Watermark",false,function(v)
    if v then
        local function sw(p) pcall(function() for _,ch in ipairs(p:GetChildren()) do if ch.Name:lower():find("watermark") then pcall(function() ch.Enabled=false end) end sw(ch) end end) end
        pcall(function() sw(CGui) end); pcall(function() sw(PGui) end)
        notif("Watermark","Hidden","success")
    end
end,2)
Checkbox(hideSC,"Spoof Globals",false,function(v)
    if v then
        local gl={"Delta","delta","DELTA_LOADED","DeltaEnv","SYNAPSE_RUNNING","syn","KRNL_LOADED","fluxus","Fluxus"}
        for _,k in ipairs(gl) do pcall(function() _GE[k]=nil end); pcall(function() _G[k]=nil end) end
        notif("Spoofed","Globals cleared","success")
    end
end,3)
Checkbox(hideSC,"Anti-Screenshot",false,function(v) S.Hide.Screenshot=v end,4)
ActionBtn(hideSC,"Force Hide All",C.Red,function()
    local cnt=0
    local function scan(p) pcall(function() for _,ch in ipairs(p:GetChildren()) do local n=ch.Name:lower() if n:find("delta") or n:find("watermark") then pcall(function() if ch:IsA("ScreenGui") then ch.Enabled=false;cnt=cnt+1 end end) end scan(ch) end end) end
    pcall(function() scan(CGui) end); pcall(function() scan(PGui) end)
    notif("Hidden",cnt.." objects","success")
end,5)
ActionBtn(hideSC,"Restore All",C.Green,function()
    pcall(function() for _,ch in ipairs(CGui:GetChildren()) do if ch:IsA("ScreenGui") and ch.Name~="MatchaV5" then pcall(function() ch.Enabled=true end) end end end)
    pcall(function() for _,ch in ipairs(PGui:GetChildren()) do if ch:IsA("ScreenGui") and ch.Name~="MatchaV5" then pcall(function() ch.Enabled=true end) end end end)
    notif("Restored","Done","info")
end,6)

-- ══════════════════════════════════════════════════════════════
--  MOBILE FLOATING BUTTONS  (right side strip)
-- ══════════════════════════════════════════════════════════════
if mob then
    local mobF = fr(SG, UDim2.new(0,50,1,0), UDim2.new(1,-56,0,0), Color3.new(), 1)
    mobF.ZIndex=100; vl(mobF,5,Enum.HorizontalAlignment.Center)

    local mbs={
        {t="ESP",  c=C.Acc,    f=function() S.ESP.On=not S.ESP.On; notif("ESP",S.ESP.On and "ON" or "OFF",S.ESP.On and "success" or "info") end},
        {t="AIM",  c=C.Slider, f=function() S.AB.On=not S.AB.On; notif("Aimbot",S.AB.On and "ON" or "OFF",S.AB.On and "success" or "info") end},
        {t="SOFT", c=C.Cyan,   f=function() S.AB.Soft=not S.AB.Soft; notif("Soft",S.AB.Soft and "ON" or "OFF",S.AB.Soft and "success" or "info") end},
        {t="SA",   c=C.Green,  f=function() S.SA.On=not S.SA.On; notif("Silent",S.SA.On and "ON" or "OFF",S.SA.On and "success" or "info") end},
        {t="NC",   c=C.Yellow, f=function() S.MV.NoClip=not S.MV.NoClip; notif("NoClip",S.MV.NoClip and "ON" or "OFF",S.MV.NoClip and "success" or "info") end},
        {t="FLY",  c=C.AccL,   f=function() S.MV.Flight=not S.MV.Flight; notif("Flight",S.MV.Flight and "ON" or "OFF",S.MV.Flight and "success" or "info") end},
        {t="MNU",  c=C.Acc,    f=function() Win.Visible=not Win.Visible; if Win.Visible then Win.Size=UDim2.new(0,WW,0,0) tw(Win,{Size=UDim2.new(0,WW,0,WH)},.25,Enum.EasingStyle.Back) end end},
        {t="HUB",  c=C.Slider, f=function() switchMainTab("Options") end},
    }

    for i,mb in ipairs(mbs) do
        local b=mk("TextButton",{
            Size=UDim2.new(0,42,0,42),BackgroundColor3=mb.c,BackgroundTransparency=0.68,
            Text=mb.t,TextColor3=mb.c,TextSize=9,Font=Enum.Font.GothamBold,
            BorderSizePixel=0,LayoutOrder=i,ZIndex=101,
        },mobF); cr(b,9); sk(b,mb.c,1.5)
        b.MouseButton1Click:Connect(function()
            tw(b,{BackgroundTransparency=0.15},.08)
            task.delay(.2,function() tw(b,{BackgroundTransparency=0.68},.15) end)
            if mb.f then pcall(mb.f) end
        end)
    end
end

-- ══════════════════════════════════════════════════════════════
--  ESP DRAWING  (working)
-- ══════════════════════════════════════════════════════════════
local ESPObj={}
local boneDefs={
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
}
local function nd(t,pr)
    local ok,o=pcall(Drawing.new,t)
    if not ok then return {Visible=false,Remove=function()end} end
    for k,v in pairs(pr or {}) do pcall(function() o[k]=v end) end
    return o
end
local function w2v(p) local s,z=Cam:WorldToViewportPoint(p); return Vector2.new(s.X,s.Y),z,z>0 end

local function buildESP(pl)
    if ESPObj[pl] then for _,o in pairs(ESPObj[pl]) do if type(o)~="table" then pcall(function() o:Remove() end) end end end
    local ac=Color3.fromRGB(195,70,245)
    local t={
        Box=nd("Square",{Visible=false,Color=ac,Thickness=1,Filled=false}),
        BoxF=nd("Square",{Visible=false,Color=ac,Thickness=0,Filled=true,Transparency=0.8}),
        Name=nd("Text",{Visible=false,Color=Color3.new(1,1,1),Size=13,Center=true,Outline=true,OutlineColor=Color3.new(0,0,0)}),
        Dist=nd("Text",{Visible=false,Color=Color3.fromRGB(200,200,200),Size=11,Center=true,Outline=true,OutlineColor=Color3.new(0,0,0)}),
        HpBG=nd("Square",{Visible=false,Color=Color3.fromRGB(30,30,30),Filled=true,Thickness=0}),
        HpBar=nd("Square",{Visible=false,Color=Color3.fromRGB(80,220,120),Filled=true,Thickness=0}),
        Trace=nd("Line",{Visible=false,Color=ac,Thickness=1}),
        Dot=nd("Circle",{Visible=false,Color=ac,Thickness=1,Filled=false,NumSides=30,Radius=4}),
        DotG=nd("Circle",{Visible=false,Color=ac,Thickness=3,Filled=false,NumSides=30,Radius=7,Transparency=0.45}),
        Snap=nd("Line",{Visible=false,Color=Color3.fromRGB(255,240,0),Thickness=1}),
        SK={},
        C1=nd("Line",{Visible=false,Thickness=2,Color=ac}),C2=nd("Line",{Visible=false,Thickness=2,Color=ac}),
        C3=nd("Line",{Visible=false,Thickness=2,Color=ac}),C4=nd("Line",{Visible=false,Thickness=2,Color=ac}),
        C5=nd("Line",{Visible=false,Thickness=2,Color=ac}),C6=nd("Line",{Visible=false,Thickness=2,Color=ac}),
        C7=nd("Line",{Visible=false,Thickness=2,Color=ac}),C8=nd("Line",{Visible=false,Thickness=2,Color=ac}),
    }
    for i=1,#boneDefs do t.SK[i]=nd("Line",{Visible=false,Color=ac,Thickness=1}) end
    ESPObj[pl]=t
end

local rHue=0
RS.RenderStepped:Connect(function()
    rHue=(rHue+0.003)%1
    local rC=Color3.fromHSV(rHue,1,1)

    for _,p in ipairs(Plrs:GetPlayers()) do
        if p==LP and not S.ESP.Self then continue end
        if S.ESP.Team and p.Team==LP.Team and p~=LP then continue end
        local ch=p.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid")
        if not ch or not hum or hum.Health<=0 then
            if ESPObj[p] then for k,o in pairs(ESPObj[p]) do if type(o)~="table" then pcall(function() o.Visible=false end) end end for _,sk2 in ipairs(ESPObj[p].SK or {}) do pcall(function() sk2.Visible=false end) end end
            continue
        end
        if not ESPObj[p] then buildESP(p) end
        local o=ESPObj[p]

        if not S.ESP.On then
            for k,v in pairs(o) do if type(v)~="table" then pcall(function() v.Visible=false end) end end
            for _,sk2 in ipairs(o.SK or {}) do pcall(function() sk2.Visible=false end) end
            continue
        end

        local ec=S.ESP.Rainbow and rC or Color3.fromRGB(195,70,245)
        if S.ESP.TeamColor then ec=(p.Team==LP.Team) and Color3.fromRGB(80,220,80) or Color3.fromRGB(220,80,80) end

        local head=ch:FindFirstChild("Head"); local root=ch:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local hpos=head and head.Position or root.Position+Vector3.new(0,2.5,0)
        local fpos=root.Position-Vector3.new(0,hum.HipHeight+1,0)
        local d3=(root.Position-Cam.CFrame.Position).Magnitude
        if d3>S.ESP.RDist then
            for k,v in pairs(o) do if type(v)~="table" then pcall(function() v.Visible=false end) end end
            for _,sk2 in ipairs(o.SK) do pcall(function() sk2.Visible=false end) end
            continue
        end
        local hs,_,hon=w2v(hpos); local fs,_,fon=w2v(fpos)
        if not hon and not fon then
            for k,v in pairs(o) do if type(v)~="table" then pcall(function() v.Visible=false end) end end
            for _,sk2 in ipairs(o.SK) do pcall(function() sk2.Visible=false end) end
            continue
        end
        local h2=math.abs(hs.Y-fs.Y); local w2=h2*0.55; local bx=hs.X-w2/2; local by=hs.Y

        -- Box
        o.Box.Visible=S.ESP.Box; o.BoxF.Visible=S.ESP.Box and S.ESP.Fill
        if S.ESP.Box then o.Box.Size=Vector2.new(w2,h2); o.Box.Position=Vector2.new(bx,by); o.Box.Color=ec o.BoxF.Size=Vector2.new(w2,h2); o.BoxF.Position=Vector2.new(bx,by); o.BoxF.Color=ec end

        -- Corner box
        if S.ESP.BoxType=="Corner" or (S.ESP.Box and S.ESP.BoxType=="Corner") then
            local cl2=w2*0.22
            local cnrs={{o.C1,Vector2.new(bx,by),Vector2.new(bx+cl2,by)},{o.C2,Vector2.new(bx,by),Vector2.new(bx,by+cl2)},{o.C3,Vector2.new(bx+w2,by),Vector2.new(bx+w2-cl2,by)},{o.C4,Vector2.new(bx+w2,by),Vector2.new(bx+w2,by+cl2)},{o.C5,Vector2.new(bx,by+h2),Vector2.new(bx+cl2,by+h2)},{o.C6,Vector2.new(bx,by+h2),Vector2.new(bx,by+h2-cl2)},{o.C7,Vector2.new(bx+w2,by+h2),Vector2.new(bx+w2-cl2,by+h2)},{o.C8,Vector2.new(bx+w2,by+h2),Vector2.new(bx+w2,by+h2-cl2)}}
            for _,cd in ipairs(cnrs) do cd[1].Visible=true; cd[1].From=cd[2]; cd[1].To=cd[3]; cd[1].Color=ec end
        else for _,k in ipairs({"C1","C2","C3","C4","C5","C6","C7","C8"}) do o[k].Visible=false end end

        o.Name.Visible=S.ESP.Name; if S.ESP.Name then o.Name.Text=p.Name; o.Name.Position=hs-Vector2.new(0,14); o.Name.Color=ec end
        o.Dist.Visible=S.ESP.Dist; if S.ESP.Dist then o.Dist.Text="["..math.floor(d3).."]"; o.Dist.Position=Vector2.new(hs.X,by+h2+2); o.Dist.Color=Color3.fromRGB(180,180,180) end

        -- Health
        local hp=math.clamp(hum.Health/hum.MaxHealth,0,1)
        o.HpBG.Visible=S.ESP.HBar; o.HpBar.Visible=S.ESP.HBar
        if S.ESP.HBar then
            local bX=bx-6; o.HpBG.Size=Vector2.new(3,h2); o.HpBG.Position=Vector2.new(bX,by)
            o.HpBar.Size=Vector2.new(3,h2*hp); o.HpBar.Position=Vector2.new(bX,by+h2*(1-hp))
            o.HpBar.Color=S.ESP.HBased and Color3.fromRGB(math.floor(255*(1-hp)),math.floor(255*hp),0) or Color3.fromRGB(80,220,120)
        end
        o.Trace.Visible=S.ESP.Trace; if S.ESP.Trace then o.Trace.From=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y); o.Trace.To=fs; o.Trace.Color=ec end
        o.Snap.Visible=S.ESP.Snap and false; -- snap line
        o.Dot.Visible=S.ESP.Dot; o.DotG.Visible=S.ESP.Dot and S.ESP.DotGlow
        if S.ESP.Dot then o.Dot.Position=hs; o.Dot.Color=ec; o.DotG.Position=hs; o.DotG.Color=ec end

        -- Skeleton
        if S.ESP.Skel then
            for i,bn in ipairs(boneDefs) do
                local p1=ch:FindFirstChild(bn[1]); local p2=ch:FindFirstChild(bn[2]); local sk3=o.SK[i]
                if p1 and p2 and sk3 then local s1,_,on1=w2v(p1.Position); local s2,_,on2=w2v(p2.Position) sk3.Visible=on1 or on2; sk3.From=s1; sk3.To=s2; sk3.Color=ec else if sk3 then sk3.Visible=false end end
            end
        else for _,sk3 in ipairs(o.SK) do pcall(function() sk3.Visible=false end) end end
    end
end)

Plrs.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(1); buildESP(p) end) end)
Plrs.PlayerRemoving:Connect(function(p) if ESPObj[p] then for _,o in pairs(ESPObj[p]) do if type(o)~="table" then pcall(function() o:Remove() end) end end; ESPObj[p]=nil end end)
for _,p in ipairs(Plrs:GetPlayers()) do if p.Character then buildESP(p) end; p.CharacterAdded:Connect(function() task.wait(1); buildESP(p) end) end

-- ══════════════════════════════════════════════════════════════
--  FOV CIRCLE
-- ══════════════════════════════════════════════════════════════
local fovDraw=nd("Circle",{Visible=false,Color=Color3.fromRGB(195,70,245),Thickness=1,Filled=false,NumSides=64})
RS.RenderStepped:Connect(function()
    fovDraw.Visible=S.AB.FOVOn
    if S.AB.FOVOn then fovDraw.Position=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2); fovDraw.Radius=S.AB.FOVSz end
end)

-- ══════════════════════════════════════════════════════════════
--  CROSSHAIR
-- ══════════════════════════════════════════════════════════════
local crDraws={}
RS.RenderStepped:Connect(function()
    for _,l in pairs(crDraws) do pcall(function() l.Visible=false end) end
    if not CX.On then return end
    crDraws={}
    local cx,cy=Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2
    local s,g,th=CX.Size,CX.Gap,CX.Thick
    local function ln(x1,y1,x2,y2) local l=nd("Line",{From=Vector2.new(x1,y1),To=Vector2.new(x2,y2),Color=Color3.fromRGB(195,70,245),Thickness=th,Visible=true}); table.insert(crDraws,l) end
    if CX.Style=="Cross" then ln(cx-s-g,cy,cx-g,cy); ln(cx+g,cy,cx+s+g,cy); ln(cx,cy-s-g,cx,cy-g); ln(cx,cy+g,cx,cy+s+g)
    elseif CX.Style=="Dot" then local d=nd("Circle",{Position=Vector2.new(cx,cy),Radius=th+1,Color=Color3.fromRGB(195,70,245),Filled=true,NumSides=30,Visible=true}); table.insert(crDraws,d)
    elseif CX.Style=="Circle" then local c2=nd("Circle",{Position=Vector2.new(cx,cy),Radius=s,Color=Color3.fromRGB(195,70,245),Filled=false,NumSides=60,Thickness=th,Visible=true}); table.insert(crDraws,c2)
    elseif CX.Style=="T-Shape" then ln(cx-s-g,cy,cx-g,cy); ln(cx+g,cy,cx+s+g,cy); ln(cx,cy+g,cx,cy+s+g) end
end)

-- ══════════════════════════════════════════════════════════════
--  AIMBOT + SOFT AIM + SILENT AIM  (working logic)
-- ══════════════════════════════════════════════════════════════
local function getPart(ch,pname)
    local m={Head="Head",Torso="UpperTorso",["Left Arm"]="LeftUpperArm",["Right Arm"]="RightUpperArm"}
    return ch:FindFirstChild(m[pname] or pname) or ch:FindFirstChild("HumanoidRootPart")
end

local function getTarget(cfg)
    local best,bestD=nil,math.huge
    local center=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
    for _,p in ipairs(Plrs:GetPlayers()) do
        if p==LP then continue end
        if cfg.Team and p.Team==LP.Team then continue end
        local ch=p.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid")
        if not ch or not hum or hum.Health<=0 then continue end
        local pt=getPart(ch,cfg.Part or "Head"); if not pt then continue end
        local pos=pt.Position
        if cfg.Pred then pos=pos+(pt.Velocity*(cfg.PredAmt or 0.12)) end
        local d3=(pos-Cam.CFrame.Position).Magnitude
        if d3>(cfg.Dist or 500) then continue end
        if cfg.Vis then
            local ray=Ray.new(Cam.CFrame.Position,(pos-Cam.CFrame.Position).Unit*d3)
            local hit=WS:FindPartOnRayWithIgnoreList(ray,{LP.Character,Cam})
            if hit and not hit:IsDescendantOf(ch) then continue end
        end
        local sp,_,on=w2v(pos); if not on then continue end
        local fov=cfg.FOVSz or math.huge
        local d2=(sp-center).Magnitude
        if d2>fov then continue end
        if d2<bestD then bestD=d2; best={part=pt,pos=pos,player=p} end
    end
    return best
end

local aimbotHeld=false
UIS.InputBegan:Connect(function(i,g) if g then return end if i.UserInputType==Enum.UserInputType.MouseButton2 then aimbotHeld=true end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton2 then aimbotHeld=false end end)

local silentTgt=nil

RS.RenderStepped:Connect(function()
    -- Silent aim target
    if S.SA.On then
        local t=getTarget({Team=S.SA.Team,Vis=S.SA.Vis,Dist=S.SA.Dist,Part=S.SA.Part,Pred=S.SA.Pred,PredAmt=0.12,FOVSz=S.SA.FOV})
        silentTgt=t
    else silentTgt=nil end

    -- Regular aimbot (RMB)
    if S.AB.On and aimbotHeld then
        local t=getTarget({Team=S.AB.Team,Vis=S.AB.Vis,Dist=S.AB.Dist,Part=S.AB.Part,Pred=S.AB.Pred,PredAmt=S.AB.PredAmt,FOVSz=S.AB.FOVSz})
        if t then
            if S.AB.Type=="Camera Teleport" then
                local dir=(t.pos-Cam.CFrame.Position).Unit
                Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,Cam.CFrame.Position+dir),S.AB.Sens)
            elseif S.AB.Type=="Legit" then
                local sp,_,on=w2v(t.pos)
                if on then local cx,cy=Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2 local dx=(sp.X-cx)*S.AB.Sens*0.07; local dy=(sp.Y-cy)*S.AB.Sens*0.07; pcall(function() mousemoverel(dx,dy) end) end
            end
        end
    end

    -- Soft aim (no keybind, gentle constant pull)
    if S.AB.Soft then
        local t=getTarget({Team=S.AB.Team,Vis=false,Dist=S.AB.Dist,Part=S.AB.Part,Pred=false,FOVSz=S.AB.FOVSz})
        if t then
            local dir=(t.pos-Cam.CFrame.Position).Unit
            Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,Cam.CFrame.Position+dir),S.AB.SoftStr)
        end
    end
end)

-- Silent aim hook
pcall(function()
    if not getrawmetatable then return end
    local mt=getrawmetatable(game); local oldI=mt.__index
    setreadonly(mt,false)
    mt.__index=newcclosure(function(self,key)
        if S.SA.On and silentTgt and key=="Hit" then
            if typeof(self)=="RaycastResult" then return CFrame.new(silentTgt.pos) end
        end
        return oldI(self,key)
    end)
    setreadonly(mt,true)
end)

-- ══════════════════════════════════════════════════════════════
--  TRIGGER BOT
-- ══════════════════════════════════════════════════════════════
RS.Heartbeat:Connect(function()
    if not S.TB.On then return end
    pcall(function()
        local ur=Cam:ScreenPointToRay(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
        local hit=WS:FindPartOnRayWithIgnoreList(Ray.new(ur.Origin,ur.Direction*(S.AB.Dist or 500)),{LP.Character})
        if hit then
            local tp=Plrs:GetPlayerFromCharacter(hit.Parent)
            if tp and tp~=LP then
                if S.TB.Team and tp.Team==LP.Team then return end
                task.wait(S.TB.Delay/1000)
                pcall(function() mouse1click() end)
            end
        end
    end)
end)

-- ══════════════════════════════════════════════════════════════
--  MOVEMENT LOOPS
-- ══════════════════════════════════════════════════════════════
RS.Stepped:Connect(function()
    if not S.MV.NoClip then return end
    pcall(function() local c=LP.Character; if not c then return end for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end)
end)
UIS.JumpRequest:Connect(function()
    if not S.MV.InfJump then return end
    pcall(function() local c=LP.Character; local h=c and c:FindFirstChildOfClass("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
end)
RS.Heartbeat:Connect(function()
    if not S.MV.Speed then return end
    pcall(function() local c=LP.Character; local r=c and c:FindFirstChild("HumanoidRootPart"); if not r then return end local v=r.AssemblyLinearVelocity; r.AssemblyLinearVelocity=Vector3.new(v.X*S.MV.SpeedAmt,v.Y,v.Z*S.MV.SpeedAmt) end)
end)

local fBV2=nil
RS.Heartbeat:Connect(function()
    pcall(function()
        local c=LP.Character; local r=c and c:FindFirstChild("HumanoidRootPart")
        if not S.MV.Flight then if fBV2 then fBV2:Destroy(); fBV2=nil end; return end
        if not r then return end
        if not fBV2 or not fBV2.Parent then fBV2=Instance.new("BodyVelocity"); fBV2.MaxForce=Vector3.new(1e5,1e5,1e5); fBV2.Parent=r end
        local d=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-Vector3.new(0,1,0) end
        fBV2.Velocity=d.Magnitude>0 and d.Unit*(S.MV.FlightAmt*50) or Vector3.zero
    end)
end)

-- ══════════════════════════════════════════════════════════════
--  HITBOX EXTENDER
-- ══════════════════════════════════════════════════════════════
RS.Heartbeat:Connect(function()
    if not S.HB.On then return end
    pcall(function()
        for _,p in ipairs(Plrs:GetPlayers()) do
            if p==LP then continue end
            if S.HB.Team and p.Team==LP.Team then continue end
            local ch=p.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid")
            if not ch or not hum or hum.Health<=0 then continue end
            for _,pt in ipairs(ch:GetDescendants()) do if pt:IsA("BasePart") then pcall(function() pt.Size=Vector3.new(S.HB.Sz,S.HB.Sz,S.HB.Sz) end) end end
        end
    end)
end)

-- ══════════════════════════════════════════════════════════════
--  LIGHTING LOOP
-- ══════════════════════════════════════════════════════════════
RS.Heartbeat:Connect(function()
    pcall(function()
        if S.WL.Full then Light.Brightness=2; Light.GlobalShadows=false; Light.Ambient=Color3.fromRGB(255,255,255); Light.OutdoorAmbient=Color3.fromRGB(255,255,255) end
        if S.WL.NoFog then Light.FogEnd=1e6; Light.FogStart=1e6 end
        if S.WL.Bright then Light.Brightness=S.WL.BrightVal end
        if S.WL.Time   then Light.ClockTime=S.WL.TimeVal end
        if S.WL.Exposure then Light.ExposureCompensation=S.WL.ExpoVal end
    end)
end)
RS.RenderStepped:Connect(function()
    pcall(function() if S.WC.FOVOn then Cam.FieldOfView=S.WC.FOVAmt end end)
end)

-- ══════════════════════════════════════════════════════════════
--  KEYBIND + INIT
-- ══════════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode==Enum.KeyCode.RightShift then
        Win.Visible=not Win.Visible
        if Win.Visible then Win.Size=UDim2.new(0,WW,0,0); tw(Win,{Size=UDim2.new(0,WW,0,WH)},.28,Enum.EasingStyle.Back) end
    end
end)

-- Start on Combat tab
switchMainTab("Combat")

task.delay(0.5, function() notif("Matcha External","v5 loaded  ·  RightShift to toggle","success",4) end)
task.delay(1.8, function() notif(isMob and "Mobile" or "PC",isMob and "Side buttons active" or "RMB = aim hold","info",3) end)

setG("MatchaHub", SG)
print("[MatchaV5] Ready | "..GP.Name.." | Mobile="..tostring(mob))
