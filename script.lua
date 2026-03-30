-- ╔══════════════════════════════════════════════════════════════╗
-- ║                    AMIER HUB                                            ║         
-- ║              Steal a Brainrot Edition                                   ║
-- ║              discord.gg/JaFSsHRrU                                       ║
-- ╚══════════════════════════════════════════════════════════════╝

repeat task.wait() until game:IsLoaded()

-- Auto copy discord link
pcall(function()
    if setclipboard then setclipboard("https://discord.gg/JaFSsHRrU") end
end)

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Player           = Players.LocalPlayer

if not Player.Character then Player.CharacterAdded:Wait() end
task.wait(0.5)

-- ──────────────────────────────────────────────────────────────
-- CONFIG
-- ──────────────────────────────────────────────────────────────
local Cfg = {
    StealRadius   = 23,
    StealSpeed    = 29.5,
    ProximityRad  = 23,
    AimbotRad     = 100,
    RotSpeed      = 233,
    Depth         = 5.0,
}

local T = {
    AutoSteal         = false,
    StealHighest      = false,
    StealPriority     = false,
    StealNearest      = false,
    InstantSteal      = false,
    InvisOnSteal      = false,
    FixLagback        = false,
    UnlockOnSteal     = false,
    Aimbot            = false,
    Desync            = false,
    AutoUnlockOnSteal = false,
    ShowUnlockHUD     = false,
    AutoInvisDuringSteal = false,
    AutoTPOnFailed    = false,
    AutoTPPriority    = false,
    AutoKickOnSteal   = false,
    ProximityCircle   = false,
    SpeedEnabled      = false,
}

local Connections = {}
local lastSteal   = 0
local guiVisible  = true
local adminTargets = {}
local spinBAV     = nil
local floatConn   = nil

-- ──────────────────────────────────────────────────────────────
-- HELPERS
-- ──────────────────────────────────────────────────────────────
local function getHRP()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = Player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function isMyPlot(name)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(name)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled end
    end
    return false
end
local function tw(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15), props):Play()
end
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, ds, dp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; ds = i.Position; dp = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - ds
            frame.Position = UDim2.new(dp.X.Scale, dp.X.Offset + delta.X, dp.Y.Scale, dp.Y.Offset + delta.Y)
        end
    end)
end

-- ──────────────────────────────────────────────────────────────
-- FIND PROMPT
-- ──────────────────────────────────────────────────────────────
local function findPrompt(onlyNearest, priorityList)
    local hrp = getHRP(); if not hrp then return nil end
    local plots = workspace:FindFirstChild("Plots"); if not plots then return nil end
    local ok, S = pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        return {
            Sync   = require(rs:WaitForChild("Packages"):WaitForChild("Synchronizer")),
            Shared = require(rs:WaitForChild("Shared"):WaitForChild("Animals")),
            Animals= require(rs:WaitForChild("Datas"):WaitForChild("Animals")),
        }
    end)
    local animals = {}
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlot(plot.Name) then continue end
        local pods = plot:FindFirstChild("AnimalPodiums"); if not pods then continue end
        if ok then
            pcall(function()
                local ch = S.Sync:Get(plot.Name); if not ch then return end
                local list = ch:Get("AnimalList"); if not list then return end
                for slot, data in pairs(list) do
                    if type(data) ~= "table" then continue end
                    local val = S.Shared:GetGeneration(data.Index, data.Mutation, data.Traits, nil) or 0
                    local pod = pods:FindFirstChild(tostring(slot))
                    if pod then
                        table.insert(animals, {val=val, pod=pod, plot=plot.Name, slot=tostring(slot), name=data.Index})
                    end
                end
            end)
        else
            for _, pod in ipairs(pods:GetChildren()) do
                local pos = pod:GetPivot().Position
                local dist = (pos - hrp.Position).Magnitude
                table.insert(animals, {val=0, pod=pod, dist=dist, plot=plot.Name, slot=pod.Name})
            end
        end
    end
    if #animals == 0 then return nil end
    table.sort(animals, function(a, b)
        if onlyNearest then
            local da = (a.pod:GetPivot().Position - hrp.Position).Magnitude
            local db = (b.pod:GetPivot().Position - hrp.Position).Magnitude
            return da < db
        end
        return a.val > b.val
    end)
    local target = animals[1]
    if not target then return nil end
    local pod = target.pod
    local base = pod:FindFirstChild("Base"); if not base then return nil end
    local spawn = base:FindFirstChild("Spawn"); if not spawn then return nil end
    local att = spawn:FindFirstChild("PromptAttachment"); if not att then return nil end
    for _, ch in ipairs(att:GetChildren()) do
        if ch:IsA("ProximityPrompt") then return ch, target end
    end
    return nil, target
end

-- ──────────────────────────────────────────────────────────────
-- STEAL
-- ──────────────────────────────────────────────────────────────
local function doSteal(prompt)
    if not prompt or not prompt.Parent then return end
    pcall(function() fireproximityprompt(prompt) end)
end

local function startAutoSteal()
    if Connections.steal then return end
    Connections.steal = RunService.Heartbeat:Connect(function()
        if not (T.AutoSteal or T.StealHighest or T.StealNearest or T.InstantSteal) then return end
        if tick() - lastSteal < 0.25 then return end
        local hum = getHum()
        if hum and hum.FloorMaterial == Enum.Material.Air then return end
        if T.InvisOnSteal or T.AutoInvisDuringSteal then
            local char = Player.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then pcall(function() p.LocalTransparencyModifier = 1 end) end
                end
            end
        end
        local prompt = findPrompt(T.StealNearest)
        if prompt then
            lastSteal = tick()
            doSteal(prompt)
        end
    end)
end
local function stopAutoSteal()
    if Connections.steal then Connections.steal:Disconnect(); Connections.steal = nil end
end

-- ──────────────────────────────────────────────────────────────
-- SPEED
-- ──────────────────────────────────────────────────────────────
local function startSpeed()
    if Connections.speed then return end
    Connections.speed = RunService.Heartbeat:Connect(function()
        if not T.SpeedEnabled then return end
        local hrp = getHRP(); local hum = getHum()
        if not hrp or not hum then return end
        local md = hum.MoveDirection
        if md.Magnitude > 0.1 and hum.FloorMaterial ~= Enum.Material.Air then
            hrp.AssemblyLinearVelocity = Vector3.new(md.X * Cfg.StealSpeed, hrp.AssemblyLinearVelocity.Y, md.Z * Cfg.StealSpeed)
        end
    end)
end

-- ──────────────────────────────────────────────────────────────
-- AIMBOT
-- ──────────────────────────────────────────────────────────────
local function startAimbot()
    if Connections.aim then return end
    Connections.aim = RunService.Heartbeat:Connect(function()
        if not T.Aimbot then return end
        local hrp = getHRP(); local hum = getHum()
        if not hrp or not hum then return end
        local best, bd = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local eh = p.Character:FindFirstChild("HumanoidRootPart")
                local h2 = p.Character:FindFirstChildOfClass("Humanoid")
                if eh and h2 and h2.Health > 0 then
                    local d = (eh.Position - hrp.Position).Magnitude
                    if d < bd and d <= Cfg.AimbotRad then bd = d; best = eh end
                end
            end
        end
        if not best then return end
        local flat = Vector3.new(best.Position.X - hrp.Position.X, 0, best.Position.Z - hrp.Position.Z)
        if flat.Magnitude > 1 then
            local m = flat.Unit
            hrp.AssemblyLinearVelocity = Vector3.new(m.X * 55, hrp.AssemblyLinearVelocity.Y, m.Z * 55)
        end
    end)
end
local function stopAimbot()
    if Connections.aim then Connections.aim:Disconnect(); Connections.aim = nil end
end

-- ──────────────────────────────────────────────────────────────
-- DESYNC
-- ──────────────────────────────────────────────────────────────
local function enableDesync()
    local flags = {
        MaxTimestepMultiplierAcceleration = 2147483647,
        GameNetDontSendRedundantNumTimes = 1,
        PhysicsSenderMaxBandwidthBps = 20000,
        ServerMaxBandwith = 52,
        WorldStepMax = 30,
    }
    for k, v in pairs(flags) do pcall(function() setfflag(tostring(k), tostring(v)) end) end
end

-- ──────────────────────────────────────────────────────────────
-- PROXIMITY CIRCLE + ADMIN PANEL
-- ──────────────────────────────────────────────────────────────
local adminPanelGui = nil
local proximityHighlights = {}

local function clearProximityHighlights()
    for _, h in pairs(proximityHighlights) do
        pcall(function() h:Destroy() end)
    end
    proximityHighlights = {}
end

local function applyAdminActions(target, action)
    local char = target.Character
    if not char then return end
    if action == "ragdoll" then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Ragdoll) end
    elseif action == "jump" then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, 80, 0) end
    elseif action == "ban" then
        -- Kick simulation (server-side ban not possible from client)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for i = 1, 10 do
                hrp.AssemblyLinearVelocity = Vector3.new(math.random(-50,50), 100, math.random(-50,50))
                task.wait(0.05)
            end
        end
    end
end

local function updateAdminPanel(nearbyPlayers, panelFrame, listFrame)
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, p in ipairs(nearbyPlayers) do
        local row = Instance.new("Frame", listFrame)
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        row.BackgroundTransparency = 0.3
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.Size = UDim2.new(0.35, 0, 1, 0)
        nameLbl.Position = UDim2.new(0, 8, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = "@" .. p.Name
        nameLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 11
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left

        local function mkAdminBtn(label, xp, action)
            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(0, 28, 0, 28)
            btn.Position = UDim2.new(0, xp, 0.5, -14)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            btn.BorderSizePixel = 0
            btn.Text = label
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 10
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(function()
                applyAdminActions(p, action)
            end)
        end

        mkAdminBtn("R",  130, "ragdoll")
        mkAdminBtn("RO", 162, "jump")
        mkAdminBtn("J",  194, "jump")
        mkAdminBtn("B",  226, "ban")
    end

    local layout = listFrame:FindFirstChildOfClass("UIListLayout")
    if layout then
        listFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
end

local function startProximityCircle(adminFrame, listFrame)
    if Connections.prox then return end
    Connections.prox = RunService.Heartbeat:Connect(function()
        if not T.ProximityCircle then return end
        local hrp = getHRP(); if not hrp then return end
        clearProximityHighlights()
        local nearby = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local eh = p.Character:FindFirstChild("HumanoidRootPart")
                if eh then
                    local dist = (eh.Position - hrp.Position).Magnitude
                    if dist <= Cfg.ProximityRad then
                        table.insert(nearby, p)
                        -- Highlight
                        local hl = Instance.new("SelectionBox")
                        hl.Adornee = p.Character
                        hl.Color3 = Color3.fromRGB(0, 200, 255)
                        hl.LineThickness = 0.05
                        hl.SurfaceTransparency = 0.8
                        hl.SurfaceColor3 = Color3.fromRGB(0, 100, 200)
                        hl.Parent = Player.PlayerGui
                        table.insert(proximityHighlights, hl)
                    end
                end
            end
        end
        if #nearby > 0 then
            adminFrame.Visible = true
            updateAdminPanel(nearby, adminFrame, listFrame)
        else
            adminFrame.Visible = false
        end
    end)
end
local function stopProximityCircle()
    if Connections.prox then Connections.prox:Disconnect(); Connections.prox = nil end
    clearProximityHighlights()
end

-- ──────────────────────────────────────────────────────────────
-- GUI
-- ──────────────────────────────────────────────────────────────
local sg = Instance.new("ScreenGui")
sg.Name = "AmierHub"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = Player:FindFirstChildOfClass("PlayerGui") or Player.PlayerGui

local BG   = Color3.fromRGB(15, 15, 22)
local CARD = Color3.fromRGB(22, 22, 32)
local GRN  = Color3.fromRGB(0, 200, 100)
local WHT  = Color3.fromRGB(255, 255, 255)
local GRY  = Color3.fromRGB(120, 120, 140)
local DRK  = Color3.fromRGB(10, 10, 18)
local RED  = Color3.fromRGB(200, 50, 50)
local BLUE = Color3.fromRGB(30, 120, 255)

-- ── MAIN PANEL ──
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 320, 0, 580)
main.Position = UDim2.new(0.35, 0, 0.5, -290)
main.BackgroundColor3 = BG
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.ZIndex = 10
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", main).Color = Color3.fromRGB(40, 40, 60)

-- Title bar
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = DRK
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 11

local titleLbl = Instance.new("TextLabel", titleBar)
titleLbl.Size = UDim2.new(1, -80, 1, 0)
titleLbl.Position = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Amier Hub"
titleLbl.TextColor3 = WHT
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 16
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 12

local discordLbl = Instance.new("TextLabel", titleBar)
discordLbl.Size = UDim2.new(1, -80, 0, 14)
discordLbl.Position = UDim2.new(0, 12, 0, 26)
discordLbl.BackgroundTransparency = 1
discordLbl.Text = "discord.gg/JaFSsHRrU"
discordLbl.TextColor3 = GRY
discordLbl.Font = Enum.Font.Gotham
discordLbl.TextSize = 10
discordLbl.TextXAlignment = Enum.TextXAlignment.Left
discordLbl.ZIndex = 12

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -64, 0.5, -14)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
minBtn.BorderSizePixel = 0
minBtn.Text = "−"
minBtn.TextColor3 = WHT
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.ZIndex = 12
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

local closeBtn2 = Instance.new("TextButton", titleBar)
closeBtn2.Size = UDim2.new(0, 28, 0, 28)
closeBtn2.Position = UDim2.new(1, -32, 0.5, -14)
closeBtn2.BackgroundColor3 = RED
closeBtn2.BorderSizePixel = 0
closeBtn2.Text = "✕"
closeBtn2.TextColor3 = WHT
closeBtn2.Font = Enum.Font.GothamBold
closeBtn2.TextSize = 13
closeBtn2.ZIndex = 12
Instance.new("UICorner", closeBtn2).CornerRadius = UDim.new(1, 0)
closeBtn2.MouseButton1Click:Connect(function() sg:Destroy() end)

makeDraggable(main, titleBar)

-- SIDEBAR TABS
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 70, 1, -45)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = DRK
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 11

local TABS = {"Main", "Steals", "Priority", "ESP", "Misc", "Config", "Keybinds", "Info"}
local tabBtns = {}
local currentTab = "Main"

local tabList = Instance.new("UIListLayout", sidebar)
tabList.Padding = UDim.new(0, 2)
tabList.SortOrder = Enum.SortOrder.LayoutOrder

for i, name in ipairs(TABS) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = name == currentTab and Color3.fromRGB(30, 30, 50) or Color3.fromRGB(15, 15, 22)
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = name == currentTab and WHT or GRY
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.ZIndex = 12
    btn.LayoutOrder = i
    tabBtns[name] = btn
end

-- CONTENT AREA
local contentArea = Instance.new("Frame", main)
contentArea.Size = UDim2.new(1, -70, 1, -45)
contentArea.Position = UDim2.new(0, 70, 0, 45)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 11

local function mkScroll()
    local p = Instance.new("ScrollingFrame", contentArea)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = GRN
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.ZIndex = 12
    p.Visible = false
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", p)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    return p
end

local panels = {}
for _, name in ipairs(TABS) do
    panels[name] = mkScroll()
end
panels["Main"].Visible = true

local function switchTab(name)
    currentTab = name
    for n, p in pairs(panels) do p.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        b.TextColor3 = (n == name) and WHT or GRY
        b.BackgroundColor3 = (n == name) and Color3.fromRGB(30, 30, 50) or Color3.fromRGB(15, 15, 22)
    end
end

for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- ── TOGGLE ROW ──
local function mkToggleRow(panel, label, tKey, onFn, offFn)
    local row = Instance.new("Frame", panel)
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = CARD
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.ZIndex = 13
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = WHT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 14

    local defOn = T[tKey] or false
    local tb = Instance.new("Frame", row)
    tb.Size = UDim2.new(0, 44, 0, 22)
    tb.Position = UDim2.new(1, -52, 0.5, -11)
    tb.BackgroundColor3 = defOn and GRN or Color3.fromRGB(40, 40, 60)
    tb.BorderSizePixel = 0
    tb.ZIndex = 13
    Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", tb)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = defOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = WHT
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local clk = Instance.new("TextButton", row)
    clk.Size = UDim2.new(1, 0, 1, 0)
    clk.BackgroundTransparency = 1
    clk.Text = ""
    clk.ZIndex = 15

    local isOn = defOn
    local function sv(state)
        isOn = state; T[tKey] = isOn
        tw(tb, {BackgroundColor3 = isOn and GRN or Color3.fromRGB(40, 40, 60)})
        tw(knob, {Position = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)})
        if isOn and onFn then onFn() end
        if not isOn and offFn then offFn() end
    end
    clk.MouseButton1Click:Connect(function() sv(not isOn) end)
    return row
end

-- ── SECTION HEADER ──
local function mkHeader(panel, label)
    local lbl = Instance.new("TextLabel", panel)
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = "│ " .. label
    lbl.TextColor3 = GRN
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
end

-- ── ACTION BUTTON ──
local function mkActionBtn(panel, label, color, cb)
    local btn = Instance.new("TextButton", panel)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = color or BLUE
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = WHT
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.ZIndex = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(cb)
    btn.MouseEnter:Connect(function() tw(btn, {BackgroundTransparency = 0.2}) end)
    btn.MouseLeave:Connect(function() tw(btn, {BackgroundTransparency = 0}) end)
end

-- ── POPULATE MAIN TAB ──
mkHeader(panels["Main"], "ACTIONS")
mkActionBtn(panels["Main"], "Teleport (T)", BLUE, function()
    local _, animal = findPrompt(false)
    if animal and animal.pod then
        local hrp = getHRP()
        if hrp then hrp.CFrame = CFrame.new(animal.pod:GetPivot().Position + Vector3.new(0,5,0)) end
    end
end)
mkActionBtn(panels["Main"], "Ragdoll Self (R)", Color3.fromRGB(80,80,80), function()
    local hum = getHum()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Ragdoll) end
end)
mkActionBtn(panels["Main"], "Rejoin PS", Color3.fromRGB(50,50,80), function()
    local ts = game:GetService("TeleportService")
    pcall(function() ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end)
end)
mkActionBtn(panels["Main"], "Rejoin Job ID", Color3.fromRGB(50,50,80), function()
    local ts = game:GetService("TeleportService")
    pcall(function() ts:Teleport(game.PlaceId, Player) end)
end)
mkActionBtn(panels["Main"], "Kick (Y)", RED, function()
    Player:Kick("Kicked by Amier Hub")
end)
mkActionBtn(panels["Main"], "Reset (X)", Color3.fromRGB(100,50,50), function()
    local hum = getHum()
    if hum then hum.Health = 0 end
end)

-- ── POPULATE STEALS TAB ──
mkHeader(panels["Steals"], "AUTO UNLOCK")
mkToggleRow(panels["Steals"], "Auto Unlock on Steal",  "AutoUnlockOnSteal", nil, nil)
mkToggleRow(panels["Steals"], "Show Unlock Buttons HUD","ShowUnlockHUD", nil, nil)
mkHeader(panels["Steals"], "AUTOMATION")
mkToggleRow(panels["Steals"], "Auto Invis During Steal", "AutoInvisDuringSteal", nil, nil)
mkToggleRow(panels["Steals"], "Auto TP on Failed Steal", "AutoTPOnFailed", nil, nil)
mkToggleRow(panels["Steals"], "Auto TP Priority Mode",   "AutoTPPriority", nil, nil)
mkToggleRow(panels["Steals"], "Auto-Kick on Steal",      "AutoKickOnSteal", nil, nil)

-- ── POPULATE MISC TAB ──
mkHeader(panels["Misc"], "MISC")
mkToggleRow(panels["Misc"], "Fix Lagback",   "FixLagback", function()
    local flags = {MaxAcceptableUpdateDelay=1, WorldStepMax=30}
    for k,v in pairs(flags) do pcall(function() setfflag(tostring(k),tostring(v)) end) end
end, nil)
mkToggleRow(panels["Misc"], "Desync",        "Desync", enableDesync, nil)
mkToggleRow(panels["Misc"], "Aimbot",        "Aimbot", startAimbot, stopAimbot)
mkToggleRow(panels["Misc"], "Speed [E]",     "SpeedEnabled", startSpeed, nil)
mkToggleRow(panels["Misc"], "Proximity Circle", "ProximityCircle", nil, nil)

-- ── POPULATE ESP TAB ──
mkHeader(panels["ESP"], "ESP")
mkToggleRow(panels["ESP"], "Proximity Circle (Admin)", "ProximityCircle", nil, nil)

-- ── INFO TAB ──
local infoLbl = Instance.new("TextLabel", panels["Info"])
infoLbl.Size = UDim2.new(1, 0, 0, 200)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "Amier Hub
discord.gg/JaFSsHRrU

Discord link wurde
automatisch kopiert!"
infoLbl.TextColor3 = WHT
infoLbl.Font = Enum.Font.GothamBold
infoLbl.TextSize = 14
infoLbl.TextXAlignment = Enum.TextXAlignment.Center
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.TextWrapped = true
infoLbl.ZIndex = 13

-- ── FPS/PING BAR ──
local fpsBar = Instance.new("Frame", sg)
fpsBar.Size = UDim2.new(0, 320, 0, 36)
fpsBar.Position = UDim2.new(0.35, 0, 1, -46)
fpsBar.BackgroundColor3 = DRK
fpsBar.BackgroundTransparency = 0.1
fpsBar.BorderSizePixel = 0
fpsBar.ZIndex = 10
Instance.new("UICorner", fpsBar).CornerRadius = UDim.new(0, 8)
makeDraggable(fpsBar)

local uBtn = Instance.new("TextLabel", fpsBar)
uBtn.Size = UDim2.new(0, 20, 1, 0)
uBtn.BackgroundTransparency = 1
uBtn.Text = "U"
uBtn.TextColor3 = GRN
uBtn.Font = Enum.Font.GothamBlack
uBtn.TextSize = 13
uBtn.ZIndex = 11

local hubLbl = Instance.new("TextLabel", fpsBar)
hubLbl.Size = UDim2.new(0, 80, 1, 0)
hubLbl.Position = UDim2.new(0, 22, 0, 0)
hubLbl.BackgroundTransparency = 1
hubLbl.Text = "AMIER HUB"
hubLbl.TextColor3 = WHT
hubLbl.Font = Enum.Font.GothamBlack
hubLbl.TextSize = 11
hubLbl.ZIndex = 11

local discLbl2 = Instance.new("TextLabel", fpsBar)
discLbl2.Size = UDim2.new(0, 120, 1, 0)
discLbl2.Position = UDim2.new(0, 105, 0, 0)
discLbl2.BackgroundTransparency = 1
discLbl2.Text = "discord.gg/JaFSsHRrU"
discLbl2.TextColor3 = GRY
discLbl2.Font = Enum.Font.Gotham
discLbl2.TextSize = 10
discLbl2.ZIndex = 11

local fpsLbl = Instance.new("TextLabel", fpsBar)
fpsLbl.Size = UDim2.new(0, 80, 1, 0)
fpsLbl.Position = UDim2.new(1, -85, 0, 0)
fpsLbl.BackgroundTransparency = 1
fpsLbl.TextColor3 = GRN
fpsLbl.Font = Enum.Font.GothamBold
fpsLbl.TextSize = 11
fpsLbl.ZIndex = 11

local frames, lastT = 0, tick()
RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastT >= 1 then
        local fps = frames; frames = 0; lastT = tick()
        local ok, ping = pcall(function()
            return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        fpsLbl.Text = "FPS: " .. fps .. "  PING: " .. (ok and ping or "?") .. "ms"
    end
end)

-- ── INVIS STEAL PANEL (right side) ──
local invisPanel = Instance.new("Frame", sg)
invisPanel.Size = UDim2.new(0, 180, 0, 340)
invisPanel.Position = UDim2.new(0.72, 0, 0.5, -170)
invisPanel.BackgroundColor3 = BG
invisPanel.BackgroundTransparency = 0.05
invisPanel.BorderSizePixel = 0
invisPanel.ZIndex = 10
Instance.new("UICorner", invisPanel).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", invisPanel).Color = Color3.fromRGB(40, 40, 60)
makeDraggable(invisPanel)

local invTitleBar = Instance.new("Frame", invisPanel)
invTitleBar.Size = UDim2.new(1, 0, 0, 36)
invTitleBar.BackgroundColor3 = DRK
invTitleBar.BorderSizePixel = 0
invTitleBar.ZIndex = 11
Instance.new("UICorner", invTitleBar).CornerRadius = UDim.new(0, 12)
local invFill = Instance.new("Frame", invTitleBar)
invFill.Size = UDim2.new(1, 0, 0.5, 0); invFill.Position = UDim2.new(0, 0, 0.5, 0)
invFill.BackgroundColor3 = DRK; invFill.BorderSizePixel = 0; invFill.ZIndex = 11

local invTitle = Instance.new("TextLabel", invTitleBar)
invTitle.Size = UDim2.new(1, 0, 1, 0); invTitle.BackgroundTransparency = 1
invTitle.Text = "Invis steal"; invTitle.TextColor3 = WHT
invTitle.Font = Enum.Font.GothamBlack; invTitle.TextSize = 13; invTitle.ZIndex = 12
makeDraggable(invisPanel, invTitleBar)

local invScroll = Instance.new("ScrollingFrame", invisPanel)
invScroll.Size = UDim2.new(1, -10, 1, -40)
invScroll.Position = UDim2.new(0, 5, 0, 38)
invScroll.BackgroundTransparency = 1; invScroll.BorderSizePixel = 0
invScroll.ScrollBarThickness = 2; invScroll.ScrollBarImageColor3 = GRN
invScroll.CanvasSize = UDim2.new(0, 0, 0, 0); invScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
invScroll.ZIndex = 11
local invList = Instance.new("UIListLayout", invScroll)
invList.Padding = UDim.new(0, 4); invList.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", invScroll).PaddingTop = UDim.new(0, 4)

local function mkInvRow(label, tKey, defaultVal, onFn, offFn)
    local row = Instance.new("Frame", invScroll)
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = CARD
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.ZIndex = 12
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6, 0, 1, 0); lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = GRY; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 13

    local valBtn = Instance.new("TextButton", row)
    valBtn.Size = UDim2.new(0, 48, 0, 22)
    valBtn.Position = UDim2.new(1, -52, 0.5, -11)
    local isOn = defaultVal or false
    if tKey then isOn = T[tKey] or false end
    valBtn.BackgroundColor3 = isOn and GRN or Color3.fromRGB(150, 50, 50)
    valBtn.BorderSizePixel = 0
    valBtn.Text = isOn and "ON" or "OFF"
    valBtn.TextColor3 = WHT; valBtn.Font = Enum.Font.GothamBold; valBtn.TextSize = 11; valBtn.ZIndex = 13
    Instance.new("UICorner", valBtn).CornerRadius = UDim.new(0, 6)

    valBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if tKey then T[tKey] = isOn end
        valBtn.Text = isOn and "ON" or "OFF"
        tw(valBtn, {BackgroundColor3 = isOn and GRN or Color3.fromRGB(150, 50, 50)})
        if isOn and onFn then onFn() end
        if not isOn and offFn then offFn() end
    end)
end

local function mkInvLabel(label)
    local lbl = Instance.new("TextLabel", invScroll)
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = GRY
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 12
end

mkInvLabel("Toggle")
mkInvRow("Toggle", nil, false, nil, nil)
mkInvRow("Fix lagback", "FixLagback", false, nil, nil)
mkInvRow("Inv on steal", "InvisOnSteal", false, nil, nil)
mkInvRow("Unlock on steal", "UnlockOnSteal", false, nil, nil)
mkInvRow("Aimbot", "Aimbot", false, startAimbot, stopAimbot)
mkInvRow("Desync", "Desync", false, enableDesync, nil)
mkInvLabel("Rot: " .. Cfg.RotSpeed)
mkInvLabel("Depth: " .. Cfg.Depth)

-- ── STEAL TARGET PANEL ──
local stealPanel = Instance.new("Frame", sg)
stealPanel.Size = UDim2.new(0, 180, 0, 200)
stealPanel.Position = UDim2.new(0.72, 0, 0.05, 0)
stealPanel.BackgroundColor3 = BG
stealPanel.BackgroundTransparency = 0.05
stealPanel.BorderSizePixel = 0
stealPanel.ZIndex = 10
Instance.new("UICorner", stealPanel).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", stealPanel).Color = Color3.fromRGB(40, 40, 60)
makeDraggable(stealPanel)

local stTitle = Instance.new("TextLabel", stealPanel)
stTitle.Size = UDim2.new(1, 0, 0, 30)
stTitle.BackgroundTransparency = 1
stTitle.Text = "Steal target"
stTitle.TextColor3 = WHT
stTitle.Font = Enum.Font.GothamBlack
stTitle.TextSize = 13
stTitle.ZIndex = 11

local stScroll = Instance.new("ScrollingFrame", stealPanel)
stScroll.Size = UDim2.new(1, -10, 1, -34)
stScroll.Position = UDim2.new(0, 5, 0, 32)
stScroll.BackgroundTransparency = 1; stScroll.BorderSizePixel = 0
stScroll.ScrollBarThickness = 2; stScroll.ScrollBarImageColor3 = GRN
stScroll.CanvasSize = UDim2.new(0, 0, 0, 0); stScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
stScroll.ZIndex = 11
local stList = Instance.new("UIListLayout", stScroll)
stList.Padding = UDim.new(0, 3); stList.SortOrder = Enum.SortOrder.LayoutOrder

for i = 1, 5 do
    local row = Instance.new("Frame", stScroll)
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundColor3 = CARD
    row.BackgroundTransparency = 0.4
    row.BorderSizePixel = 0
    row.ZIndex = 12
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -10, 1, 0); lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = "#" .. i .. "  —"
    lbl.TextColor3 = GRY; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 13
end

-- Auto-update steal target
RunService.Heartbeat:Connect(function()
    if tick() % 2 < 0.05 then
        local _, animal = pcall(findPrompt, false)
        if type(animal) == "table" and animal.name then
            local first = stScroll:GetChildren()
            for _, ch in ipairs(first) do
                if ch:IsA("Frame") then
                    local lbl = ch:FindFirstChildOfClass("TextLabel")
                    if lbl then lbl.Text = "#1  " .. tostring(animal.name) end
                    break
                end
            end
        end
    end
end)

-- ── STEAL SPEED PANEL ──
local speedPanel = Instance.new("Frame", sg)
speedPanel.Size = UDim2.new(0, 180, 0, 90)
speedPanel.Position = UDim2.new(0.72, 0, 0.88, 0)
speedPanel.BackgroundColor3 = BG
speedPanel.BackgroundTransparency = 0.05
speedPanel.BorderSizePixel = 0
speedPanel.ZIndex = 10
Instance.new("UICorner", speedPanel).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", speedPanel).Color = Color3.fromRGB(40, 40, 60)
makeDraggable(speedPanel)

local spTitle = Instance.new("TextLabel", speedPanel)
spTitle.Size = UDim2.new(1, 0, 0, 28)
spTitle.BackgroundTransparency = 1; spTitle.Text = "STEAL SPEED"
spTitle.TextColor3 = GRY; spTitle.Font = Enum.Font.GothamBold; spTitle.TextSize = 11; spTitle.ZIndex = 11

local spValLbl = Instance.new("TextLabel", speedPanel)
spValLbl.Size = UDim2.new(1, 0, 0, 28)
spValLbl.Position = UDim2.new(0, 0, 0, 24)
spValLbl.BackgroundTransparency = 1; spValLbl.Text = tostring(Cfg.StealSpeed)
spValLbl.TextColor3 = WHT; spValLbl.Font = Enum.Font.GothamBlack; spValLbl.TextSize = 20; spValLbl.ZIndex = 11

local spStatusLbl = Instance.new("TextLabel", speedPanel)
spStatusLbl.Size = UDim2.new(1, 0, 0, 18)
spStatusLbl.Position = UDim2.new(0, 0, 0, 52)
spStatusLbl.BackgroundTransparency = 1; spStatusLbl.Text = "DISABLED"
spStatusLbl.TextColor3 = RED; spStatusLbl.Font = Enum.Font.GothamBold; spStatusLbl.TextSize = 12; spStatusLbl.ZIndex = 11

local spBtn = Instance.new("TextButton", speedPanel)
spBtn.Size = UDim2.new(1, -16, 0, 24)
spBtn.Position = UDim2.new(0, 8, 0, 60)
spBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
spBtn.BorderSizePixel = 0; spBtn.Text = "Type value, Enter"
spBtn.TextColor3 = GRY; spBtn.Font = Enum.Font.Gotham; spBtn.TextSize = 10; spBtn.ZIndex = 11
Instance.new("UICorner", spBtn).CornerRadius = UDim.new(0, 6)
spBtn.MouseButton1Click:Connect(function()
    T.SpeedEnabled = not T.SpeedEnabled
    spStatusLbl.Text = T.SpeedEnabled and "ENABLED" or "DISABLED"
    spStatusLbl.TextColor3 = T.SpeedEnabled and GRN or RED
    if T.SpeedEnabled then startSpeed() end
end)

-- ── ADMIN PANEL (appears when proximity triggered) ──
local adminFrame = Instance.new("Frame", sg)
adminFrame.Size = UDim2.new(0, 260, 0, 280)
adminFrame.Position = UDim2.new(0, 10, 0.15, 0)
adminFrame.BackgroundColor3 = BG
adminFrame.BackgroundTransparency = 0.05
adminFrame.BorderSizePixel = 0
adminFrame.ZIndex = 10
adminFrame.Visible = false
Instance.new("UICorner", adminFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", adminFrame).Color = Color3.fromRGB(40, 40, 60)
makeDraggable(adminFrame)

local adminTitle = Instance.new("TextLabel", adminFrame)
adminTitle.Size = UDim2.new(1, 0, 0, 32)
adminTitle.BackgroundTransparency = 1; adminTitle.Text = "Admin Panel"
adminTitle.TextColor3 = WHT; adminTitle.Font = Enum.Font.GothamBlack; adminTitle.TextSize = 14; adminTitle.ZIndex = 11

local adminListFrame = Instance.new("ScrollingFrame", adminFrame)
adminListFrame.Size = UDim2.new(1, -10, 1, -36)
adminListFrame.Position = UDim2.new(0, 5, 0, 34)
adminListFrame.BackgroundTransparency = 1; adminListFrame.BorderSizePixel = 0
adminListFrame.ScrollBarThickness = 2; adminListFrame.ScrollBarImageColor3 = GRN
adminListFrame.CanvasSize = UDim2.new(0, 0, 0, 0); adminListFrame.ZIndex = 11
local adminListLayout = Instance.new("UIListLayout", adminListFrame)
adminListLayout.Padding = UDim.new(0, 4); adminListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ── STEAL QUICK PANEL ──
local quickPanel = Instance.new("Frame", sg)
quickPanel.Size = UDim2.new(0, 180, 0, 220)
quickPanel.Position = UDim2.new(0.72, 185, 0.5, -110)
quickPanel.BackgroundColor3 = BG
quickPanel.BackgroundTransparency = 0.05
quickPanel.BorderSizePixel = 0
quickPanel.ZIndex = 10
Instance.new("UICorner", quickPanel).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", quickPanel).Color = Color3.fromRGB(40, 40, 60)
makeDraggable(quickPanel)

local qTitle = Instance.new("TextLabel", quickPanel)
qTitle.Size = UDim2.new(1, 0, 0, 30)
qTitle.BackgroundTransparency = 1; qTitle.Text = "Amier Hub"
qTitle.TextColor3 = BLUE; qTitle.Font = Enum.Font.GothamBlack; qTitle.TextSize = 14; qTitle.ZIndex = 11

local qScroll = Instance.new("ScrollingFrame", quickPanel)
qScroll.Size = UDim2.new(1, -10, 1, -34); qScroll.Position = UDim2.new(0, 5, 0, 32)
qScroll.BackgroundTransparency = 1; qScroll.BorderSizePixel = 0
qScroll.ScrollBarThickness = 2; qScroll.ScrollBarImageColor3 = GRN
qScroll.CanvasSize = UDim2.new(0, 0, 0, 0); qScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
qScroll.ZIndex = 11
local qList = Instance.new("UIListLayout", qScroll)
qList.Padding = UDim.new(0, 4); qList.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", qScroll).PaddingTop = UDim.new(0, 4)

local function mkQToggle(label, tKey, onFn, offFn)
    local row = Instance.new("Frame", qScroll)
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = CARD; row.BackgroundTransparency = 0.3; row.BorderSizePixel = 0; row.ZIndex = 12
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.65, 0, 1, 0); lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = WHT; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 13
    local tb = Instance.new("Frame", row)
    tb.Size = UDim2.new(0, 40, 0, 18); tb.Position = UDim2.new(1, -44, 0.5, -9)
    tb.BackgroundColor3 = Color3.fromRGB(40,40,60); tb.BorderSizePixel = 0; tb.ZIndex = 12
    Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", tb)
    knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = WHT; knob.BorderSizePixel = 0; knob.ZIndex = 13
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local clk = Instance.new("TextButton", row)
    clk.Size = UDim2.new(1, 0, 1, 0); clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 14
    local isOn = false
    clk.MouseButton1Click:Connect(function()
        isOn = not isOn; T[tKey] = isOn
        tw(tb, {BackgroundColor3 = isOn and GRN or Color3.fromRGB(40,40,60)})
        tw(knob, {Position = isOn and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)})
        if isOn and onFn then onFn() end
        if not isOn and offFn then offFn() end
    end)
end

mkQToggle("Auto steal",      "AutoSteal",    startAutoSteal, stopAutoSteal)
mkQToggle("Steal highest",   "StealHighest", startAutoSteal, stopAutoSteal)
mkQToggle("Steal priority",  "StealPriority",startAutoSteal, stopAutoSteal)
mkQToggle("Steal nearest",   "StealNearest", startAutoSteal, stopAutoSteal)
mkQToggle("Instant steal",   "InstantSteal", startAutoSteal, stopAutoSteal)

-- ── PROXIMITY CIRCLE SETUP ──
startProximityCircle(adminFrame, adminListFrame)

RunService.Heartbeat:Connect(function()
    if T.ProximityCircle then
        if not Connections.prox then
            startProximityCircle(adminFrame, adminListFrame)
        end
    else
        if Connections.prox then stopProximityCircle() end
    end
end)

-- ── TOGGLE ──
minBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    main.Visible = guiVisible
end)

-- ── INPUT ──
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    local k = inp.KeyCode
    if k == Enum.KeyCode.U then guiVisible = not guiVisible; main.Visible = guiVisible end
    if k == Enum.KeyCode.T then
        local _, animal = findPrompt(false)
        if animal and animal.pod then
            local hrp = getHRP()
            if hrp then hrp.CFrame = CFrame.new(animal.pod:GetPivot().Position + Vector3.new(0,5,0)) end
        end
    end
    if k == Enum.KeyCode.R then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Ragdoll) end
    end
    if k == Enum.KeyCode.Y then Player:Kick("Kicked by Amier Hub") end
    if k == Enum.KeyCode.X then
        local hum = getHum(); if hum then hum.Health = 0 end
    end
    if k == Enum.KeyCode.E then
        T.SpeedEnabled = not T.SpeedEnabled
        spStatusLbl.Text = T.SpeedEnabled and "ENABLED" or "DISABLED"
        spStatusLbl.TextColor3 = T.SpeedEnabled and GRN or RED
        if T.SpeedEnabled then startSpeed() end
    end
end)

-- ── RESPAWN ──
Player.CharacterAdded:Connect(function()
    task.wait(1)
    if T.AutoSteal or T.StealHighest or T.StealNearest or T.InstantSteal then
        stopAutoSteal(); task.wait(0.1); startAutoSteal()
    end
    if T.Aimbot then stopAimbot(); task.wait(0.1); startAimbot() end
end)

print("[AMIER HUB] Loaded! discord.gg/JaFSsHRrU | U=Toggle")
