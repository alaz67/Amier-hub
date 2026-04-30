 task.spawn(function()
    _G.BloodHub = {}
    local C = _G.BloodHub

    -- Services
    C.Players = game:GetService("Players")
    C.RunService = game:GetService("RunService")
    C.UserInputService = game:GetService("UserInputService")
    C.TweenService = game:GetService("TweenService")
    C.SoundService = game:GetService("SoundService")
    C.Lighting = game:GetService("Lighting")
    C.ReplicatedStorage = game:GetService("ReplicatedStorage")
    C.HttpService = game:GetService("HttpService")
    C.Player = C.Players.LocalPlayer

    C.isMobile = C.UserInputService.TouchEnabled and not C.UserInputService.KeyboardEnabled
    C.s = C.isMobile and 0.65 or 1
    C.dragLocked = false
    C.CurrentBgEffect = "Stars"
    C.bgEffects = {"Stars", "Matrix", "Grid", "Pulse", "Circles", "None"}
    C.CurrentBgEffectIndex = 1

    function C.waitForCharacter()
        local char = C.Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
            return char
        end
        return C.Player.CharacterAdded:Wait()
    end
    task.spawn(function() C.waitForCharacter() end)

    function C.MakeDraggable(frame)
        local dragging, dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        frame.InputBegan:Connect(function(input)
            if C.dragLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        frame.InputChanged:Connect(function(input)
            if C.dragLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        C.UserInputService.InputChanged:Connect(function(input)
            if C.dragLocked then return end
            if input == dragInput and dragging then update(input) end
        end)
    end

    -- Config
    C.ConfigFileName = "Blood_Hub_Config_V1.json"
    C.Enabled = {
        SpeedBoost = false, AntiRagdoll = false, SpinBot = false,
        SpeedWhileStealing = false, AutoSteal = false, Unwalk = false,
        Optimizer = false, Galaxy = false, SpamBat = false, BatAimbot = false,
        GalaxySkyBright = false, AutoWalkEnabled = false, AutoRightEnabled = false,
        AutoPlayLeftEnabled = false, AutoPlayRightEnabled = false, InfJump = false,
        ESP = false, Hover = false, Stats = false, SpeedMeter = false, TPDown = false
    }
    C.Values = {
        BoostSpeed = 30, SpinSpeed = 30, StealingSpeedValue = 29,
        STEAL_RADIUS = 20, STEAL_DURATION = 1.3,
        AutoLeftSpeed = 59.5, AutoRightSpeed = 59.5,
        AutoWalkReturnSpeed = 30, AutoPlayReturnSpeed = 30,
        AutoWalkWaitTime = 1.0, AutoPlayWaitTime = 1.0,
        AutoPlayExitDist = 6.0, DEFAULT_GRAVITY = 196.2,
        GalaxyGravityPercent = 70, HOP_POWER = 35, HOP_COOLDOWN = 0.08,
        FOV = 105.8, HoverHeight = 6
    }

    C.KEYBINDS = {
        SPEED = Enum.KeyCode.V, SPIN = Enum.KeyCode.N, GALAXY = Enum.KeyCode.M,
        BATAIMBOT = Enum.KeyCode.X, NUKE = Enum.KeyCode.Q,
        AUTOLEFT = Enum.KeyCode.Z, AUTORIGHT = Enum.KeyCode.C,
        AUTOPLAYLEFT = Enum.KeyCode.F10, AUTOPLAYRIGHT = Enum.KeyCode.F11,
        ANTIRAGDOLL = Enum.KeyCode.F1, SPEEDSTEAL = Enum.KeyCode.F2,
        AUTOSTEAL = Enum.KeyCode.F3, UNWALK = Enum.KeyCode.F4,
        OPTIMIZER = Enum.KeyCode.F5, SPAMBAT = Enum.KeyCode.F6,
        GALAXY_SKY = Enum.KeyCode.F7, INFJUMP = Enum.KeyCode.F8,
        ESP = Enum.KeyCode.P, HOVER = Enum.KeyCode.G,
        STATS = Enum.KeyCode.F9, SPEEDMETER = Enum.KeyCode.J,
        TPDOWN = Enum.KeyCode.H,
        MOBILE_HOVER = Enum.KeyCode.LeftShift, MOBILE_BAT = Enum.KeyCode.B,
        MOBILE_PLAYL = Enum.KeyCode.LeftAlt, MOBILE_PLAYR = Enum.KeyCode.RightAlt,
        MOBILE_TPDOWN = Enum.KeyCode.T, MOBILE_DROP = Enum.KeyCode.D
    }
    C.GAMEPAD_BINDS = {
        MOBILE_HOVER = Enum.KeyCode.ButtonX, MOBILE_BAT = Enum.KeyCode.ButtonY,
        MOBILE_PLAYL = Enum.KeyCode.ButtonL1, MOBILE_PLAYR = Enum.KeyCode.ButtonR1,
        MOBILE_TPDOWN = Enum.KeyCode.ButtonL2, MOBILE_DROP = Enum.KeyCode.ButtonR2
    }

    C.CurrentThemeIndex = 1
    C.isRainbow = false

    pcall(function()
        if readfile and isfile and isfile(C.ConfigFileName) then
            local data = C.HttpService:JSONDecode(readfile(C.ConfigFileName))
            if data then
                for k, v in pairs(data) do
                    if C.Enabled[k] ~= nil then C.Enabled[k] = v end
                end
                for k, v in pairs(data) do
                    if C.Values[k] ~= nil then C.Values[k] = v end
                end
                for key, codeName in pairs(data) do
                    if key:match("^KEY_") then
                        local kbind = key:gsub("KEY_", "")
                        if C.KEYBINDS[kbind] then
                            C.KEYBINDS[kbind] = Enum.KeyCode[codeName]
                        end
                    end
                    if key:match("^GAMEPAD_") then
                        local kbind = key:gsub("GAMEPAD_", "")
                        if C.GAMEPAD_BINDS[kbind] then
                            C.GAMEPAD_BINDS[kbind] = Enum.KeyCode[codeName]
                        end
                    end
                end
                if data.CurrentThemeIndex then C.CurrentThemeIndex = data.CurrentThemeIndex end
                if data.isRainbow ~= nil then C.isRainbow = data.isRainbow end
                if data.CurrentBgEffectIndex then C.CurrentBgEffectIndex = data.CurrentBgEffectIndex end
            end
        end
    end)

    function C.SaveConfig()
        local data = {}
        for k, v in pairs(C.Enabled) do data[k] = v end
        for k, v in pairs(C.Values) do data[k] = v end
        for k, v in pairs(C.KEYBINDS) do data["KEY_"..k] = v.Name end
        for k, v in pairs(C.GAMEPAD_BINDS) do data["GAMEPAD_"..k] = v.Name end
        data.CurrentThemeIndex = C.CurrentThemeIndex
        data.isRainbow = C.isRainbow
        data.CurrentBgEffectIndex = C.CurrentBgEffectIndex
        local success = false
        if writefile then
            pcall(function()
                writefile(C.ConfigFileName, C.HttpService:JSONEncode(data))
                success = true
            end)
        end
        return success
    end

    -- Internal tables
    C.Connections = {}
    C.StealData = {}
    C.SavedAnimations = {}
    C.EspConnections = {}
    C.WfConns = {}
    C.WfActive = false
    C.OriginalTransparency = {}
    C.XrayEnabled = false
    C.GalaxyPlanets = {}
    C.MobileShortcutButtons = {}
    C.VisualSetters = {}
    C.SliderSetters = {}
    C.KeyButtons = {}
    C.WaitingForKeybind = nil
    C.GuiVisible = true
    C.ThemeUpdateFuncs = {}
    C.SpinBAV = nil
    C.AimbotConnection = nil
    C.LockedTarget = nil
    C.AimbotHighlight = nil
    C.GalaxyVectorForce = nil
    C.GalaxyAttachment = nil
    C.GalaxyEnabled = false
    C.HopsEnabled = false
    C.LastHopTime = 0
    C.SpaceHeld = false
    C.OriginalJumpPower = 50
    C.AutoWalkPhase = 1
    C.AutoRightPhase = 1
    C.AutoPlayLeftPhase = 1
    C.AutoPlayRightPhase = 1
    C.AutoWalkEnabled = false
    C.AutoRightEnabled = false
    C.AutoPlayLeftEnabled = false
    C.AutoPlayRightEnabled = false
    C.AutoWalkConnection = nil
    C.AutoRightConnection = nil
    C.AutoPlayLeftConnection = nil
    C.AutoPlayRightConnection = nil
    C.AutoPlayLeftWait = false
    C.AutoPlayLeftWaitStart = 0
    C.AutoPlayRightWait = false
    C.AutoPlayRightWaitStart = 0
    C.OriginalSkybox = nil
    C.GalaxySkyBright = nil
    C.GalaxySkyBrightConn = nil
    C.GalaxyBloom = nil
    C.GalaxyCC = nil
    C.FovConnection = nil
    C.SpeedMeterConnection = nil
    C.SpeedMeterGui = nil
    C.AutoStealGui = nil
    C.BarFill = nil
    C.RadiusValueLabel = nil
    C.DurationValueLabel = nil
    C.IsStealing = false
    C.StealProgress = 0
    C.LastBatSwing = 0
    C.BatSwingCooldown = 0.12
    C.SlapList = {
        {1,"Bat"},{2,"Slap"},{3,"Iron Slap"},{4,"Gold Slap"},
        {5,"Diamond Slap"},{6,"Emerald Slap"},{7,"Ruby Slap"},
        {8,"Dark Matter Slap"},{9,"Flame Slap"},{10,"Nuclear Slap"},
        {11,"Galaxy Slap"},{12,"Glitched Slap"}
    }
    C.ADMIN_KEY = "78a772b6-9e1c-4827-ab8b-04a07838f298"
    C.REMOTE_EVENT_ID = "352aad58-c786-4998-886b-3e4fa390721e"
    C.BALLOON_REMOTE = C.ReplicatedStorage:FindFirstChild(C.REMOTE_EVENT_ID, true)
    C.HoverTargetY = 0
    C.AIMBOT_SPEED = 60
    C.MELEE_OFFSET = 3
    C.MAX_DISTANCE = math.huge

    -- Colors
    C.Themes = {
        ["Royal Purple"] = { P = Color3.fromRGB(255,0,50), L = Color3.fromRGB(255,80,100), D = Color3.fromRGB(180,0,30) },
        ["Crimson Red"] = { P = Color3.fromRGB(220, 20, 60), L = Color3.fromRGB(255, 60, 90), D = Color3.fromRGB(150, 15, 40) },
        ["Cyberpunk Yellow"] = { P = Color3.fromRGB(255, 215, 0), L = Color3.fromRGB(255, 235, 100), D = Color3.fromRGB(180, 150, 0) },
        ["Neon Green"] = { P = Color3.fromRGB(50, 255, 50), L = Color3.fromRGB(100, 255, 100), D = Color3.fromRGB(20, 180, 20) }
    }
    C.ThemeNames = {"Royal Purple", "Crimson Red", "Cyberpunk Yellow", "Neon Green", "Rainbow Mode"}
    C.Color = {
        bg = Color3.fromRGB(12,12,15),
        sidebar = Color3.fromRGB(18,18,22),
        primary = C.Themes["Crimson Red"].P,
        primaryLight = C.Themes["Crimson Red"].L,
        primaryDark = C.Themes["Crimson Red"].D,
        text = Color3.fromRGB(245,245,245),
        textMuted = Color3.fromRGB(130,130,140),
        elementBg = Color3.fromRGB(24,24,28),
        border = Color3.fromRGB(40,40,48),
        success = Color3.fromRGB(40,200,100)
    }

    function C.UpdateThemeColors(p, l, d)
        C.Color.primary = p
        C.Color.primaryLight = l
        C.Color.primaryDark = d
        for _, func in ipairs(C.ThemeUpdateFuncs) do
            func(p, l, d)
        end
    end

    C.RunService.RenderStepped:Connect(function()
        if C.isRainbow then
            local hue = tick() % 5 / 5
            local rgb = Color3.fromHSV(hue, 1, 1)
            local light = Color3.fromHSV(hue, 0.6, 1)
            local dark = Color3.fromHSV(hue, 1, 0.5)
            C.UpdateThemeColors(rgb, light, dark)
        end
    end)

    -- ====================== UI Functions ======================
    C.createAutoStealUI = function()
        if C.AutoStealGui then return end
        local gui = Instance.new("ScreenGui")
        gui.Name = "BloodHubAutoSteal"
        gui.ResetOnSpawn = false
        gui.Parent = C.Player:WaitForChild("PlayerGui")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 30)
        frame.Position = UDim2.new(0.5, -100, 0.8, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        frame.Parent = gui
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        
        C.BarFill = Instance.new("Frame")
        C.BarFill.Size = UDim2.new(0, 0, 1, 0)
        C.BarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 50)
        C.BarFill.BorderSizePixel = 0
        C.BarFill.Parent = frame
        Instance.new("UICorner", C.BarFill).CornerRadius = UDim.new(0, 8)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "Stealing..."
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Parent = frame
        
        C.AutoStealGui = gui
    end
    
    C.removeAutoStealUI = function()
        if C.AutoStealGui then
            C.AutoStealGui:Destroy()
            C.AutoStealGui = nil
            C.BarFill = nil
        end
    end
    
    C.updateStealUIDisplay = function()
        if C.AutoStealGui and C.BarFill then
            C.BarFill.Size = UDim2.new(C.StealProgress, 0, 1, 0)
        end
    end

    -- ====================== FEATURE FUNCTIONS ======================
    function C.INSTANT_NUKE(target)
        if not C.BALLOON_REMOTE or not target then return end
        for _, p in ipairs({"balloon","ragdoll","jumpscare","morph","tiny","rocket","inverse","jail"}) do
            C.BALLOON_REMOTE:FireServer(C.ADMIN_KEY, target, p)
        end
    end

    function C.getNearestPlayer()
        local c = C.Player.Character
        if not c then return nil end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return nil end
        local pos = h.Position
        local nearest, dist = nil, math.huge
        for _, p in ipairs(C.Players:GetPlayers()) do
            if p ~= C.Player and p.Character then
                local oh = p.Character:FindFirstChild("HumanoidRootPart")
                if oh then
                    local d = (pos - oh.Position).Magnitude
                    if d < dist then
                        dist = d
                        nearest = p
                    end
                end
            end
        end
        return nearest
    end

    function C.findBat()
        local c = C.Player.Character
        if not c then return nil end
        local bp = C.Player:FindFirstChildOfClass("Backpack")
        for _, ch in ipairs(c:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
        if bp then
            for _, ch in ipairs(bp:GetChildren()) do
                if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
            end
        end
        for _, i in ipairs(C.SlapList) do
            local t = c:FindFirstChild(i[2]) or (bp and bp:FindFirstChild(i[2]))
            if t then return t end
        end
        return nil
    end

    function C.startSpamBat()
        if C.Connections.spamBat then return end
        C.Connections.spamBat = C.RunService.Heartbeat:Connect(function()
            if not C.Enabled.SpamBat then return end
            local c = C.Player.Character
            if not c then return end
            local bat = C.findBat()
            if not bat then return end
            if bat.Parent ~= c then bat.Parent = c end
            local now = tick()
            if now - C.LastBatSwing < C.BatSwingCooldown then return end
            C.LastBatSwing = now
            pcall(function() bat:Activate() end)
        end)
    end
    
    function C.stopSpamBat()
        if C.Connections.spamBat then C.Connections.spamBat:Disconnect() C.Connections.spamBat = nil end
    end

    function C.startSpinBot()
        local c = C.Player.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if C.SpinBAV then C.SpinBAV:Destroy() end
        for _, v in pairs(hrp:GetChildren()) do if v.Name == "SpinBAV" then v:Destroy() end end
        C.SpinBAV = Instance.new("BodyAngularVelocity")
        C.SpinBAV.Name = "SpinBAV"
        C.SpinBAV.MaxTorque = Vector3.new(0, math.huge, 0)
        C.SpinBAV.AngularVelocity = Vector3.new(0, C.Values.SpinSpeed, 0)
        C.SpinBAV.Parent = hrp
    end
    
    function C.stopSpinBot()
        if C.SpinBAV then C.SpinBAV:Destroy() C.SpinBAV = nil end
        local c = C.Player.Character
        if c then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in pairs(hrp:GetChildren()) do if v.Name == "SpinBAV" then v:Destroy() end end
            end
        end
    end

    C.RunService.Heartbeat:Connect(function()
        if C.Enabled.SpinBot and C.SpinBAV then
            if C.Player:GetAttribute("Stealing") then
                C.SpinBAV.AngularVelocity = Vector3.new(0,0,0)
            else
                C.SpinBAV.AngularVelocity = Vector3.new(0, C.Values.SpinSpeed, 0)
            end
        end
    end)

    function C.toggleSpeedMeter(state)
        if C.SpeedMeterConnection then C.SpeedMeterConnection:Disconnect() C.SpeedMeterConnection = nil end
        if C.SpeedMeterGui then C.SpeedMeterGui:Destroy() C.SpeedMeterGui = nil end
        if not state then return end
        local char = C.Player.Character
        if not char then return end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not head then return end
        C.SpeedMeterGui = Instance.new("BillboardGui")
        C.SpeedMeterGui.Name = "BloodHubSpeedMeter"
        C.SpeedMeterGui.Adornee = head
        C.SpeedMeterGui.Size = UDim2.new(0,150,0,40)
        C.SpeedMeterGui.StudsOffset = Vector3.new(0,3.5,0)
        C.SpeedMeterGui.AlwaysOnTop = true
        local textLabel = Instance.new("TextLabel", C.SpeedMeterGui)
        textLabel.Name = "SpeedText"
        textLabel.Size = UDim2.new(1,0,1,0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "Speed: 0"
        textLabel.TextColor3 = Color3.fromRGB(255,255,255)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 16 * C.s
        local successHl, _ = pcall(function() C.SpeedMeterGui.Parent = game:GetService("CoreGui") end)
        if not successHl then C.SpeedMeterGui.Parent = C.Player:WaitForChild("PlayerGui") end
        C.SpeedMeterConnection = C.RunService.Heartbeat:Connect(function()
            if not C.Player.Character or not C.Player.Character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = C.Player.Character.HumanoidRootPart
            if C.SpeedMeterGui and C.SpeedMeterGui:FindFirstChild("SpeedText") then
                local hv = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
                local speed = math.round(hv.Magnitude)
                C.SpeedMeterGui.SpeedText.Text = "Speed: " .. tostring(speed)
            end
        end)
    end

    C.AimbotHighlight = Instance.new("Highlight")
    C.AimbotHighlight.Name = "AimbotTargetESP"
    C.AimbotHighlight.FillColor = Color3.fromRGB(255,0,0)
    C.AimbotHighlight.OutlineColor = Color3.fromRGB(255,255,255)
    C.AimbotHighlight.FillTransparency = 0.5
    C.AimbotHighlight.OutlineTransparency = 0
    local successHl, _ = pcall(function() C.AimbotHighlight.Parent = game:GetService("CoreGui") end)
    if not successHl then C.AimbotHighlight.Parent = C.Player:WaitForChild("PlayerGui") end

    function C.isTargetValid(targetChar)
        if not targetChar then return false end
        local hum = targetChar:FindFirstChildOfClass("Humanoid")
        local hrp = targetChar:FindFirstChild("HumanoidRootPart")
        local ff = targetChar:FindFirstChildOfClass("ForceField")
        return hum and hrp and hum.Health > 0 and not ff
    end

    function C.getBestTarget(myHRP)
        if C.LockedTarget and C.isTargetValid(C.LockedTarget) then
            return C.LockedTarget:FindFirstChild("HumanoidRootPart"), C.LockedTarget
        end
        local shortestDistance = C.MAX_DISTANCE
        local newTargetChar, newTargetHRP = nil, nil
        for _, targetPlayer in ipairs(C.Players:GetPlayers()) do
            if targetPlayer ~= C.Player and C.isTargetValid(targetPlayer.Character) then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local distance = (targetHRP.Position - myHRP.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    newTargetHRP = targetHRP
                    newTargetChar = targetPlayer.Character
                end
            end
        end
        C.LockedTarget = newTargetChar
        return newTargetHRP, newTargetChar
    end

    function C.startBatAimbot()
        if C.AimbotConnection then return end
        local c = C.Player.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        hum.AutoRotate = false
        local attachment = h:FindFirstChild("AimbotAttachment") or Instance.new("Attachment", h)
        attachment.Name = "AimbotAttachment"
        local align = h:FindFirstChild("AimbotAlign") or Instance.new("AlignOrientation", h)
        align.Name = "AimbotAlign"
        align.Mode = Enum.OrientationAlignmentMode.OneAttachment
        align.Attachment0 = attachment
        align.MaxTorque = math.huge
        align.Responsiveness = 200
        C.AimbotConnection = C.RunService.Heartbeat:Connect(function(dt)
            if not C.Enabled.BatAimbot then return end
            if not C.Player.Character or not C.Player.Character:FindFirstChild("HumanoidRootPart") then return end
            local currentHRP = C.Player.Character.HumanoidRootPart
            local currentHum = C.Player.Character:FindFirstChildOfClass("Humanoid")
            local bat = C.findBat()
            if bat and bat.Parent ~= C.Player.Character then currentHum:EquipTool(bat) end
            local targetHRP, targetChar = C.getBestTarget(currentHRP)
            if targetHRP and targetChar then
                C.AimbotHighlight.Adornee = targetChar
                local targetVelocity = targetHRP.AssemblyLinearVelocity
                local speed = targetVelocity.Magnitude
                local dynamicPredictTime = math.clamp(speed / 150, 0.05, 0.2)
                local predictedPos = targetHRP.Position + (targetVelocity * dynamicPredictTime)
                local dirToTarget = (predictedPos - currentHRP.Position)
                local distance3D = dirToTarget.Magnitude
                local targetStandPos = predictedPos
                if distance3D > 0 then targetStandPos = predictedPos - (dirToTarget.Unit * C.MELEE_OFFSET) end
                align.CFrame = CFrame.lookAt(currentHRP.Position, predictedPos)
                local moveDir = (targetStandPos - currentHRP.Position)
                local distToStandPos = moveDir.Magnitude
                if distToStandPos > 1 then
                    currentHRP.AssemblyLinearVelocity = moveDir.Unit * C.AIMBOT_SPEED
                else
                    currentHRP.AssemblyLinearVelocity = targetVelocity
                end
            else
                C.LockedTarget = nil
                currentHRP.AssemblyLinearVelocity = Vector3.new(0,0,0)
                C.AimbotHighlight.Adornee = nil
            end
        end)
    end
    
    function C.stopBatAimbot()
        if C.AimbotConnection then C.AimbotConnection:Disconnect() C.AimbotConnection = nil end
        local c = C.Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            local att = h:FindFirstChild("AimbotAttachment")
            if att then att:Destroy() end
            local align = h:FindFirstChild("AimbotAlign")
            if align then align:Destroy() end
            h.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
        if hum then hum.AutoRotate = true end
        C.LockedTarget = nil
        C.AimbotHighlight.Adornee = nil
    end

    function C.captureJumpPower()
        local c = C.Player.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum and hum.JumpPower > 0 then C.OriginalJumpPower = hum.JumpPower end
        end
    end
    task.spawn(function() C.captureJumpPower() end)
    C.Player.CharacterAdded:Connect(function() task.wait(1); C.captureJumpPower() end)

    function C.setupGalaxyForce()
        pcall(function()
            local c = C.Player.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if not h then return end
            if C.GalaxyVectorForce then C.GalaxyVectorForce:Destroy() end
            if C.GalaxyAttachment then C.GalaxyAttachment:Destroy() end
            C.GalaxyAttachment = Instance.new("Attachment", h)
            C.GalaxyVectorForce = Instance.new("VectorForce", h)
            C.GalaxyVectorForce.Attachment0 = C.GalaxyAttachment
            C.GalaxyVectorForce.ApplyAtCenterOfMass = true
            C.GalaxyVectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
            C.GalaxyVectorForce.Force = Vector3.new(0,0,0)
        end)
    end

    function C.updateGalaxyForce()
        if not C.GalaxyEnabled or not C.GalaxyVectorForce then return end
        local c = C.Player.Character
        if not c then return end
        local mass = 0
        for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then mass = mass + p:GetMass() end end
        local tg = C.Values.DEFAULT_GRAVITY * (C.Values.GalaxyGravityPercent / 100)
        C.GalaxyVectorForce.Force = Vector3.new(0, mass * (C.Values.DEFAULT_GRAVITY - tg) * 0.95, 0)
    end

    function C.adjustGalaxyJump()
        pcall(function()
            local c = C.Player.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if not C.GalaxyEnabled then hum.JumpPower = C.OriginalJumpPower return end
            local ratio = math.sqrt((C.Values.DEFAULT_GRAVITY * (C.Values.GalaxyGravityPercent / 100)) / C.Values.DEFAULT_GRAVITY)
            hum.JumpPower = C.OriginalJumpPower * ratio
        end)
    end

    function C.doMiniHop()
        if not C.HopsEnabled then return end
        pcall(function()
            local c = C.Player.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not h or not hum then return end
            if tick() - C.LastHopTime < C.Values.HOP_COOLDOWN then return end
            C.LastHopTime = tick()
            if hum.FloorMaterial == Enum.Material.Air then
                h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, C.Values.HOP_POWER, h.AssemblyLinearVelocity.Z)
            end
        end)
    end

    function C.startGalaxy() C.GalaxyEnabled = true; C.HopsEnabled = true; C.setupGalaxyForce(); C.adjustGalaxyJump() end
    function C.stopGalaxy()
        C.GalaxyEnabled = false; C.HopsEnabled = false
        if C.GalaxyVectorForce then C.GalaxyVectorForce:Destroy() C.GalaxyVectorForce = nil end
        if C.GalaxyAttachment then C.GalaxyAttachment:Destroy() C.GalaxyAttachment = nil end
        C.adjustGalaxyJump()
    end

    C.RunService.Heartbeat:Connect(function()
        if C.HopsEnabled and C.SpaceHeld then C.doMiniHop() end
        if C.GalaxyEnabled then C.updateGalaxyForce() end
    end)

    function C.getMovementDirection()
        local c = C.Player.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        return hum and hum.MoveDirection or Vector3.zero
    end

    function C.startSpeedBoost()
        if C.Connections.speed then return end
        C.Connections.speed = C.RunService.Heartbeat:Connect(function()
            if not C.Enabled.SpeedBoost then return end
            pcall(function()
                local c = C.Player.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if not h then return end
                local md = C.getMovementDirection()
                if md.Magnitude > 0.1 then
                    h.AssemblyLinearVelocity = Vector3.new(md.X * C.Values.BoostSpeed, h.AssemblyLinearVelocity.Y, md.Z * C.Values.BoostSpeed)
                end
            end)
        end)
    end
    
    function C.stopSpeedBoost() if C.Connections.speed then C.Connections.speed:Disconnect() C.Connections.speed = nil end end

    function C.ToggleHover(state)
        local char = C.Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if state and hrp then
            C.HoverTargetY = hrp.Position.Y + C.Values.HoverHeight
        else
            if hrp then hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -10, hrp.AssemblyLinearVelocity.Z) end
        end
    end

    C.RunService.Heartbeat:Connect(function()
        if C.Enabled.Hover then            local char = C.Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local myY = hrp.Position.Y
                local error = C.HoverTargetY - myY
                local currentY = math.clamp(error * 10, -50, 50)
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, currentY, hrp.AssemblyLinearVelocity.Z)
            end
        end
    end)

    -- Auto walk coordinates
    C.POSITION_1 = Vector3.new(-476.48, -6.28, 92.73)
    C.POSITION_2 = Vector3.new(-483.12, -4.95, 94.80)
    C.POSITION_R1 = Vector3.new(-476.16, -6.52, 25.62)
    C.POSITION_R2 = Vector3.new(-483.04, -5.09, 23.14)
    C.dirL = (Vector3.new(C.POSITION_1.X,0,C.POSITION_1.Z) - Vector3.new(C.POSITION_2.X,0,C.POSITION_2.Z)).Unit
    C.dirR = (Vector3.new(C.POSITION_R1.X,0,C.POSITION_R1.Z) - Vector3.new(C.POSITION_R2.X,0,C.POSITION_R2.Z)).Unit
    function C.GET_POS_1_OUT() return C.POSITION_1 + (C.dirL * C.Values.AutoPlayExitDist) end
    function C.GET_POS_R1_OUT() return C.POSITION_R1 + (C.dirR * C.Values.AutoPlayExitDist) end

    function C.faceCam(angleY)
        local c = C.Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local camera = workspace.CurrentCamera
        if camera then
            if angleY == 0 then
                camera.CFrame = CFrame.new(h.Position.X, h.Position.Y + 5, h.Position.Z - 12) * CFrame.Angles(math.rad(-15),0,0)
            else
                camera.CFrame = CFrame.new(h.Position.X, h.Position.Y + 2, h.Position.Z + 12) * CFrame.Angles(0, math.rad(180), 0)
            end
        end
    end

    function C.startAutoPlayLeft()
        if C.AutoPlayLeftConnection then C.AutoPlayLeftConnection:Disconnect() end
        C.AutoPlayLeftPhase = 1
        C.AutoPlayLeftWait = false
        C.AutoPlayLeftWaitStart = 0
        local c = C.Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then
            local walkOri = h:FindFirstChild("AutoWalkOri")
            if not walkOri then
                local walkAtt = Instance.new("Attachment", h)
                walkAtt.Name = "AutoWalkAtt"
                walkOri = Instance.new("AlignOrientation", h)
                walkOri.Name = "AutoWalkOri"
                walkOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
                walkOri.Attachment0 = walkAtt
                walkOri.MaxTorque = math.huge
                walkOri.Responsiveness = 200
            end
        end
        local seq = {C.GET_POS_1_OUT, C.POSITION_1, C.POSITION_2, C.POSITION_1, C.GET_POS_1_OUT, C.GET_POS_R1_OUT, C.POSITION_R1, C.POSITION_R2}
        C.AutoPlayLeftConnection = C.RunService.Heartbeat:Connect(function()
            if not C.AutoPlayLeftEnabled then return end
            local char = C.Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local wo = hrp:FindFirstChild("AutoWalkOri")
            if C.AutoPlayLeftWait then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                if tick() - C.AutoPlayLeftWaitStart >= C.Values.AutoPlayWaitTime then
                    C.AutoPlayLeftWait = false
                    C.AutoPlayLeftPhase = C.AutoPlayLeftPhase + 1
                end
                return
            end
            if C.AutoPlayLeftPhase <= #seq then
                local targetPos = seq[C.AutoPlayLeftPhase]
                if type(targetPos) == "function" then targetPos = targetPos() end
                local dist = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Magnitude
                if dist < 1 then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                    if C.AutoPlayLeftPhase == 3 then
                        C.AutoPlayLeftWait = true
                        C.AutoPlayLeftWaitStart = tick()
                    else
                        C.AutoPlayLeftPhase = C.AutoPlayLeftPhase + 1
                    end
                else
                    local flatDir = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)) end
                    local spd = (C.AutoPlayLeftPhase >= 4) and C.Values.AutoPlayReturnSpeed or C.Values.AutoLeftSpeed
                    hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * spd, hrp.AssemblyLinearVelocity.Y, moveDir.Z * spd)
                end
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                C.AutoPlayLeftEnabled = false; C.Enabled.AutoPlayLeftEnabled = false
                if C.VisualSetters.AutoPlayLeftEnabled then C.VisualSetters.AutoPlayLeftEnabled(false) end
                if C.AutoPlayLeftConnection then C.AutoPlayLeftConnection:Disconnect() C.AutoPlayLeftConnection = nil end
                local wa = hrp:FindFirstChild("AutoWalkAtt")
                if wo then wo:Destroy() end
                if wa then wa:Destroy() end
                C.faceCam(0)
            end
        end)
    end
    
    function C.stopAutoPlayLeft()
        if C.AutoPlayLeftConnection then C.AutoPlayLeftConnection:Disconnect() C.AutoPlayLeftConnection = nil end
        local h = C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart")
        if h then
            h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            local wo = h:FindFirstChild("AutoWalkOri")
            local wa = h:FindFirstChild("AutoWalkAtt")
            if wo then wo:Destroy() end
            if wa then wa:Destroy() end
        end
    end

    function C.startAutoPlayRight()
        if C.AutoPlayRightConnection then C.AutoPlayRightConnection:Disconnect() end
        C.AutoPlayRightPhase = 1
        C.AutoPlayRightWait = false
        C.AutoPlayRightWaitStart = 0
        local c = C.Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then
            local walkOri = h:FindFirstChild("AutoWalkOri")
            if not walkOri then
                local walkAtt = Instance.new("Attachment", h)
                walkAtt.Name = "AutoWalkAtt"
                walkOri = Instance.new("AlignOrientation", h)
                walkOri.Name = "AutoWalkOri"
                walkOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
                walkOri.Attachment0 = walkAtt
                walkOri.MaxTorque = math.huge
                walkOri.Responsiveness = 200
            end
        end
        local seq = {C.GET_POS_R1_OUT, C.POSITION_R1, C.POSITION_R2, C.POSITION_R1, C.GET_POS_R1_OUT, C.GET_POS_1_OUT, C.POSITION_1, C.POSITION_2}
        C.AutoPlayRightConnection = C.RunService.Heartbeat:Connect(function()
            if not C.AutoPlayRightEnabled then return end
            local char = C.Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local wo = hrp:FindFirstChild("AutoWalkOri")
            if C.AutoPlayRightWait then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                if tick() - C.AutoPlayRightWaitStart >= C.Values.AutoPlayWaitTime then
                    C.AutoPlayRightWait = false
                    C.AutoPlayRightPhase = C.AutoPlayRightPhase + 1
                end
                return
            end
            if C.AutoPlayRightPhase <= #seq then
                local targetPos = seq[C.AutoPlayRightPhase]
                if type(targetPos) == "function" then targetPos = targetPos() end
                local dist = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Magnitude
                if dist < 1 then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                    if C.AutoPlayRightPhase == 3 then
                        C.AutoPlayRightWait = true
                        C.AutoPlayRightWaitStart = tick()
                    else
                        C.AutoPlayRightPhase = C.AutoPlayRightPhase + 1
                    end
                else
                    local flatDir = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)) end
                    local spd = (C.AutoPlayRightPhase >= 4) and C.Values.AutoPlayReturnSpeed or C.Values.AutoRightSpeed
                    hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * spd, hrp.AssemblyLinearVelocity.Y, moveDir.Z * spd)
                end
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                C.AutoPlayRightEnabled = false; C.Enabled.AutoPlayRightEnabled = false
                if C.VisualSetters.AutoPlayRightEnabled then C.VisualSetters.AutoPlayRightEnabled(false) end
                if C.AutoPlayRightConnection then C.AutoPlayRightConnection:Disconnect() C.AutoPlayRightConnection = nil end
                local wa = hrp:FindFirstChild("AutoWalkAtt")
                if wo then wo:Destroy() end
                if wa then wa:Destroy() end
                C.faceCam(math.rad(180))
            end
        end)
    end
    
    function C.stopAutoPlayRight()
        if C.AutoPlayRightConnection then C.AutoPlayRightConnection:Disconnect() C.AutoPlayRightConnection = nil end
        local h = C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart")
        if h then
            h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            local wo = h:FindFirstChild("AutoWalkOri")
            local wa = h:FindFirstChild("AutoWalkAtt")
            if wo then wo:Destroy() end
            if wa then wa:Destroy() end
        end
    end

    function C.startAutoWalk()
        if C.AutoWalkConnection then C.AutoWalkConnection:Disconnect() end
        C.AutoWalkPhase = 1
        local waitStartTime = 0
        local c = C.Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then
            local walkOri = h:FindFirstChild("AutoWalkOri")
            if not walkOri then
                local walkAtt = Instance.new("Attachment", h)
                walkAtt.Name = "AutoWalkAtt"
                walkOri = Instance.new("AlignOrientation", h)
                walkOri.Name = "AutoWalkOri"
                walkOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
                walkOri.Attachment0 = walkAtt
                walkOri.MaxTorque = math.huge
                walkOri.Responsiveness = 200
            end
        end
        C.AutoWalkConnection = C.RunService.Heartbeat:Connect(function()
            if not C.AutoWalkEnabled then return end
            local c = C.Player.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if not h then return end
            local wo = h:FindFirstChild("AutoWalkOri")
            local pos1 = C.POSITION_1
            local pos2 = C.POSITION_2
            if C.AutoWalkPhase == 1 then
                local dist = (Vector3.new(pos1.X, h.Position.Y, pos1.Z) - h.Position).Magnitude
                if dist < 1 then
                    C.AutoWalkPhase = 2
                else
                    local flatDir = Vector3.new(pos1.X - h.Position.X, 0, pos1.Z - h.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos1.X, h.Position.Y, pos1.Z)) end
                    h.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.Values.AutoLeftSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * C.Values.AutoLeftSpeed)
                end
            elseif C.AutoWalkPhase == 2 then
                local dist = (Vector3.new(pos2.X, h.Position.Y, pos2.Z) - h.Position).Magnitude
                if dist < 1 then
                    C.AutoWalkPhase = 3
                    waitStartTime = tick()
                    h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
                else
                    local flatDir = Vector3.new(pos2.X - h.Position.X, 0, pos2.Z - h.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos2.X, h.Position.Y, pos2.Z)) end
                    h.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.Values.AutoLeftSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * C.Values.AutoLeftSpeed)
                end
            elseif C.AutoWalkPhase == 3 then
                h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
                if tick() - waitStartTime >= C.Values.AutoWalkWaitTime then
                    C.AutoWalkPhase = 4
                end
            elseif C.AutoWalkPhase == 4 then
                local dist = (Vector3.new(pos1.X, h.Position.Y, pos1.Z) - h.Position).Magnitude
                if dist < 1 then
                    C.AutoWalkPhase = 5
                else
                    local flatDir = Vector3.new(pos1.X - h.Position.X, 0, pos1.Z - h.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos1.X, h.Position.Y, pos1.Z)) end
                    h.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.Values.AutoWalkReturnSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * C.Values.AutoWalkReturnSpeed)
                end
            elseif C.AutoWalkPhase == 5 then
                h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
                C.AutoWalkEnabled = false; C.Enabled.AutoWalkEnabled = false
                if C.VisualSetters.AutoWalkEnabled then C.VisualSetters.AutoWalkEnabled(false) end
                if C.AutoWalkConnection then C.AutoWalkConnection:Disconnect() C.AutoWalkConnection = nil end
                local wa = h:FindFirstChild("AutoWalkAtt")
                if wo then wo:Destroy() end
                if wa then wa:Destroy() end
                C.faceCam(0)
            end
        end)
    end
    
    function C.stopAutoWalk()
        if C.AutoWalkConnection then C.AutoWalkConnection:Disconnect() C.AutoWalkConnection = nil end
        local h = C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart")
        if h then
            h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            local wo = h:FindFirstChild("AutoWalkOri")
            local wa = h:FindFirstChild("AutoWalkAtt")
            if wo then wo:Destroy() end
            if wa then wa:Destroy() end
        end
    end

    function C.startAutoRight()
        if C.AutoRightConnection then C.AutoRightConnection:Disconnect() end
        C.AutoRightPhase = 1
        local waitStartTime = 0
        local c = C.Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then
            local walkOri = h:FindFirstChild("AutoWalkOri")
            if not walkOri then
                local walkAtt = Instance.new("Attachment", h)
                walkAtt.Name = "AutoWalkAtt"
                walkOri = Instance.new("AlignOrientation", h)
                walkOri.Name = "AutoWalkOri"
                walkOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
                walkOri.Attachment0 = walkAtt
                walkOri.MaxTorque = math.huge
                walkOri.Responsiveness = 200
            end
        end
        C.AutoRightConnection = C.RunService.Heartbeat:Connect(function()
            if not C.AutoRightEnabled then return end
            local c = C.Player.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if not h then return end
            local wo = h:FindFirstChild("AutoWalkOri")
            local pos1 = C.POSITION_R1
            local pos2 = C.POSITION_R2
            if C.AutoRightPhase == 1 then
                local dist = (Vector3.new(pos1.X, h.Position.Y, pos1.Z) - h.Position).Magnitude
                if dist < 1 then
                    C.AutoRightPhase = 2
                else
                    local flatDir = Vector3.new(pos1.X - h.Position.X, 0, pos1.Z - h.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos1.X, h.Position.Y, pos1.Z)) end
                    h.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.Values.AutoRightSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * C.Values.AutoRightSpeed)
                end
            elseif C.AutoRightPhase == 2 then
                local dist = (Vector3.new(pos2.X, h.Position.Y, pos2.Z) - h.Position).Magnitude
                if dist < 1 then
                    C.AutoRightPhase = 3
                    waitStartTime = tick()
                    h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
                else
                    local flatDir = Vector3.new(pos2.X - h.Position.X, 0, pos2.Z - h.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos2.X, h.Position.Y, pos2.Z)) end
                    h.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.Values.AutoRightSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * C.Values.AutoRightSpeed)
                end
            elseif C.AutoRightPhase == 3 then
                h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
                if tick() - waitStartTime >= C.Values.AutoWalkWaitTime then
                    C.AutoRightPhase = 4
                end
            elseif C.AutoRightPhase == 4 then
                local dist = (Vector3.new(pos1.X, h.Position.Y, pos1.Z) - h.Position).Magnitude
                if dist < 1 then
                    C.AutoRightPhase = 5
                else
                    local flatDir = Vector3.new(pos1.X - h.Position.X, 0, pos1.Z - h.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos1.X, h.Position.Y, pos1.Z)) end
                    h.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.Values.AutoWalkReturnSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * C.Values.AutoWalkReturnSpeed)
                end
            elseif C.AutoRightPhase == 5 then
                h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
                C.AutoRightEnabled = false; C.Enabled.AutoRightEnabled = false
                if C.VisualSetters.AutoRightEnabled then C.VisualSetters.AutoRightEnabled(false) end
                if C.AutoRightConnection then C.AutoRightConnection:Disconnect() C.AutoRightConnection = nil end
                local wa = h:FindFirstChild("AutoWalkAtt")
                if wo then wo:Destroy() end
                if wa then wa:Destroy() end
                C.faceCam(math.rad(180))
            end
        end)
    end
    
    function C.stopAutoRight()
        if C.AutoRightConnection then C.AutoRightConnection:Disconnect() C.AutoRightConnection = nil end
        local h = C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart")
        if h then
            h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            local wo = h:FindFirstChild("AutoWalkOri")
            local wa = h:FindFirstChild("AutoWalkAtt")
            if wo then wo:Destroy() end
            if wa then wa:Destroy() end
        end
    end

    function C.startAntiRagdoll()
        if C.Connections.antiRagdoll then return end
        C.Connections.antiRagdoll = C.RunService.Heartbeat:Connect(function()
            if not C.Enabled.AntiRagdoll then return end
            local char = C.Player.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local hs = hum:GetState()
                if hs == Enum.HumanoidStateType.Physics or hs == Enum.HumanoidStateType.Ragdoll or hs == Enum.HumanoidStateType.FallingDown then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    workspace.CurrentCamera.CameraSubject = hum
                    pcall(function()
                        if C.Player.Character then
                            local PlayerModule = C.Player.PlayerScripts:FindFirstChild("PlayerModule")
                            if PlayerModule then
                                local Controls = require(PlayerModule:FindFirstChild("ControlModule"))
                                Controls:Enable()
                            end
                        end
                    end)
                    if root then root.AssemblyLinearVelocity = Vector3.new(0,0,0); root.AssemblyAngularVelocity = Vector3.new(0,0,0) end
                end
            end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") and obj.Enabled == false then obj.Enabled = true end
            end
        end)
    end
    
    function C.stopAntiRagdoll() if C.Connections.antiRagdoll then C.Connections.antiRagdoll:Disconnect() C.Connections.antiRagdoll = nil end end

    function C.startSpeedWhileStealing()
        if C.Connections.speedWhileStealing then return end
        C.Connections.speedWhileStealing = C.RunService.Heartbeat:Connect(function()
            if not C.Enabled.SpeedWhileStealing or not C.Player:GetAttribute("Stealing") then return end
            local h = C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart")
            if not h then return end
            local md = C.getMovementDirection()
            if md.Magnitude > 0.1 then
                h.AssemblyLinearVelocity = Vector3.new(md.X * C.Values.StealingSpeedValue, h.AssemblyLinearVelocity.Y, md.Z * C.Values.StealingSpeedValue)
            end
        end)
    end
    
    function C.stopSpeedWhileStealing() if C.Connections.speedWhileStealing then C.Connections.speedWhileStealing:Disconnect() end end

    C.RadiusVisualizer = Instance.new("Part")
    C.RadiusVisualizer.Name = "BloodHubRadiusVisualizer"
    C.RadiusVisualizer.Shape = Enum.PartType.Cylinder
    C.RadiusVisualizer.CanCollide = false
    C.RadiusVisualizer.Anchored = true
    C.RadiusVisualizer.CastShadow = false
    C.RadiusVisualizer.Material = Enum.Material.ForceField
    C.RadiusVisualizer.Color = Color3.fromRGB(255,0,50)
    C.RadiusVisualizer.Transparency = 0.5

    C.RunService.Heartbeat:Connect(function()
        if C.Enabled.AutoSteal and C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart") then
            if C.RadiusVisualizer.Parent ~= workspace then C.RadiusVisualizer.Parent = workspace end
            C.RadiusVisualizer.Size = Vector3.new(0.05, C.Values.STEAL_RADIUS * 2, C.Values.STEAL_RADIUS * 2)
            C.RadiusVisualizer.CFrame = C.Player.Character.HumanoidRootPart.CFrame * CFrame.new(0,-2.8,0) * CFrame.Angles(0,0,math.rad(90))
        else
            if C.RadiusVisualizer.Parent then C.RadiusVisualizer.Parent = nil end
        end
    end)

    function C.isMyPlotByName(pn)
        local plots = workspace:FindFirstChild("Plots")
        local sign = plots and plots:FindFirstChild(pn) and plots[pn]:FindFirstChild("PlotSign")
        return sign and sign:FindFirstChild("YourBase") and sign.YourBase:IsA("BillboardGui") and sign.YourBase.Enabled
    end

    function C.findNearestPrompt()
        local h = C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart")
        local plots = workspace:FindFirstChild("Plots")
        if not h or not plots then return nil end
        local np, nd, nn = nil, math.huge, nil
        for _, plot in ipairs(plots:GetChildren()) do
            if C.isMyPlotByName(plot.Name) then continue end
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then continue end
            for _, pod in ipairs(podiums:GetChildren()) do
                pcall(function()
                    local spawn = pod:FindFirstChild("Base") and pod.Base:FindFirstChild("Spawn")
                    if spawn then
                        local dist = (spawn.Position - h.Position).Magnitude
                        if dist < nd and dist <= C.Values.STEAL_RADIUS then
                            local att = spawn:FindFirstChild("PromptAttachment")
                            if att then
                                for _, ch in ipairs(att:GetChildren()) do
                                    if ch:IsA("ProximityPrompt") then np, nd, nn = ch, dist, pod.Name break end
                                end
                            end
                        end
                    end
                end)
            end
        end
        return np, nd, nn
    end

    function C.executeSteal(prompt, name)
        if C.IsStealing then return end
        if not C.StealData[prompt] then
            C.StealData[prompt] = {hold = {}, trigger = {}, ready = true}
            pcall(function()
                if getconnections then
                    for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if c.Function then table.insert(C.StealData[prompt].hold, c.Function) end end
                    for _, c in ipairs(getconnections(prompt.Triggered)) do if c.Function then table.insert(C.StealData[prompt].trigger, c.Function) end end
                end
            end)
        end
        local data = C.StealData[prompt]
        if not data.ready then return end
        data.ready = false; C.IsStealing = true
        task.spawn(function()
            for _, f in ipairs(data.hold) do task.spawn(f) end
            local startTime = tick()
            local duration = C.Values.STEAL_DURATION
            if duration > 0 then
                while tick() - startTime < duration do
                    if not C.IsStealing then break end
                    C.StealProgress = math.clamp((tick() - startTime) / duration, 0, 1)
                    C.updateStealUIDisplay()
                    task.wait()
                end
            end
            C.StealProgress = 1
            C.updateStealUIDisplay()
            for _, f in ipairs(data.trigger) do task.spawn(f) end
            task.wait(0.2)
            C.StealProgress = 0
            C.updateStealUIDisplay()
            data.ready = true; C.IsStealing = false
        end)
    end

    function C.startAutoSteal()
        if C.Connections.autoSteal then return end
        C.createAutoStealUI()
        C.Connections.autoSteal = C.RunService.Heartbeat:Connect(function()
            if not C.Enabled.AutoSteal or C.IsStealing then return end
            local p, _, n = C.findNearestPrompt()
            if p then C.executeSteal(p, n) end
        end)
    end
    
    function C.stopAutoSteal()
        if C.Connections.autoSteal then C.Connections.autoSteal:Disconnect() C.Connections.autoSteal = nil end
        C.IsStealing = false
        C.removeAutoStealUI()
    end

    function C.startUnwalk()
        local c = C.Player.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
        local anim = c and c:FindFirstChild("Animate")
        if anim then C.SavedAnimations.Animate = anim:Clone(); anim:Destroy() end
    end
    
    function C.stopUnwalk()
        local c = C.Player.Character
        if c and C.SavedAnimations.Animate then C.SavedAnimations.Animate:Clone().Parent = c; C.SavedAnimations.Animate = nil end
    end

    function C.enableOptimizer()
        if getgenv and getgenv().OPTIMIZER_ACTIVE then return end
        if getgenv then getgenv().OPTIMIZER_ACTIVE = true end
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            C.Lighting.GlobalShadows = false
            C.Lighting.Brightness = 3
            C.Lighting.FogEnd = 9e9
        end)
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj:Destroy()
                    elseif obj:IsA("BasePart") then obj.CastShadow = false; obj.Material = Enum.Material.Plastic end
                end)
            end
        end)
        C.XrayEnabled = true
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Anchored and (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
                    C.OriginalTransparency[obj] = obj.LocalTransparencyModifier
                    obj.LocalTransparencyModifier = 0.85
                end
            end
        end)
    end
    
    function C.disableOptimizer()
        if getgenv then getgenv().OPTIMIZER_ACTIVE = false end
        if C.XrayEnabled then
            for part, value in pairs(C.OriginalTransparency) do if part then part.LocalTransparencyModifier = value end end
            C.OriginalTransparency = {}
            C.XrayEnabled = false
        end
    end

    function C.enableGalaxySkyBright()
        if C.GalaxySkyBright then return end
        C.OriginalSkybox = C.Lighting:FindFirstChildOfClass("Sky")
        if C.OriginalSkybox then C.OriginalSkybox.Parent = nil end
        C.GalaxySkyBright = Instance.new("Sky", C.Lighting)
        C.GalaxySkyBright.SkyboxBk = "rbxassetid://1534951537"
        C.GalaxySkyBright.SkyboxDn = "rbxassetid://1534951537"
        C.GalaxySkyBright.SkyboxFt = "rbxassetid://1534951537"
        C.GalaxySkyBright.SkyboxLf = "rbxassetid://1534951537"
        C.GalaxySkyBright.SkyboxRt = "rbxassetid://1534951537"
        C.GalaxySkyBright.SkyboxUp = "rbxassetid://1534951537"
        C.GalaxySkyBright.StarCount = 10000
        C.GalaxySkyBright.CelestialBodiesShown = false
        C.GalaxyBloom = Instance.new("BloomEffect", C.Lighting)
        C.GalaxyBloom.Intensity = 1.5
        C.GalaxyBloom.Size = 40
        C.GalaxyBloom.Threshold = 0.8
        C.GalaxyCC = Instance.new("ColorCorrectionEffect", C.Lighting)
        C.GalaxyCC.Saturation = 1
        C.GalaxyCC.Contrast = 1
        C.GalaxyCC.TintColor = Color3.fromRGB(255,60,60)
        C.Lighting.Ambient = Color3.fromRGB(120,0,10)
        C.Lighting.Brightness = 3
        C.Lighting.ClockTime = 0
        C.GalaxySkyBrightConn = C.RunService.Heartbeat:Connect(function()
            if not C.Enabled.GalaxySkyBright then return end
            local t = tick() * 0.5
            C.Lighting.Ambient = Color3.fromRGB(120 + math.sin(t)*60, 50 + math.sin(t*0.8)*40, 180 + math.sin(t*1.2)*50)
            if C.GalaxyBloom then C.GalaxyBloom.Intensity = 1.2 + math.sin(t*2)*0.4 end
        end)
    end
    
    function C.disableGalaxySkyBright()
        if C.GalaxySkyBrightConn then C.GalaxySkyBrightConn:Disconnect(); C.GalaxySkyBrightConn = nil end
        if C.GalaxySkyBright then C.GalaxySkyBright:Destroy(); C.GalaxySkyBright = nil end
        if C.OriginalSkybox then C.OriginalSkybox.Parent = C.Lighting end
        if C.GalaxyBloom then C.GalaxyBloom:Destroy(); C.GalaxyBloom = nil end
        if C.GalaxyCC then C.GalaxyCC:Destroy(); C.GalaxyCC = nil end
        C.Lighting.Ambient = Color3.fromRGB(127,127,127)
        C.Lighting.Brightness = 2
        C.Lighting.ClockTime = 14
    end

    function C.updateFOV()
        local cam = workspace.CurrentCamera
        if cam and cam.FieldOfView ~= C.Values.FOV then
            cam.FieldOfView = C.Values.FOV
        end
    end
    
    function C.hookFOV()
        if C.FovConnection then C.FovConnection:Disconnect() end
        local cam = workspace.CurrentCamera
        if cam then
            C.FovConnection = cam:GetPropertyChangedSignal("FieldOfView"):Connect(C.updateFOV)
            C.updateFOV()
        end
    end
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(C.hookFOV)
    C.hookFOV()

    C.UserInputService.JumpRequest:Connect(function()
        if C.Enabled.InfJump then
            local c = C.Player.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
            end
        end
    end)

    function C.createESP(plr)
        if plr == C.Player or not plr.Character then return end
        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp or char:FindFirstChild("BloodHubHitbox") then return end
        local h = Instance.new("BoxHandleAdornment", char)
        h.Name = "BloodHubHitbox"
        h.Adornee = hrp
        h.Size = Vector3.new(4,6,2)
        h.Color3 = Color3.fromRGB(255,0,50)
        h.Transparency = 0.6
        h.ZIndex = 10
        h.AlwaysOnTop = true
        local b = Instance.new("BillboardGui", char)
        b.Name = "BloodHubName"
        b.Adornee = char:FindFirstChild("Head") or hrp
        b.Size = UDim2.new(0,200,0,50)
        b.StudsOffset = Vector3.new(0,3,0)
        b.AlwaysOnTop = true
        local l = Instance.new("TextLabel", b)
        l.Size = UDim2.new(1,0,1,0)
        l.BackgroundTransparency = 1
        l.Text = plr.DisplayName
        l.TextColor3 = Color3.fromRGB(255,0,50)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 14
    end
    
    function C.toggleESP(state)
        if not state then
            for _, p in ipairs(C.Players:GetPlayers()) do
                if p.Character then
                    local hb = p.Character:FindFirstChild("BloodHubHitbox")
                    local nm = p.Character:FindFirstChild("BloodHubName")
                    if hb then hb:Destroy() end
                    if nm then nm:Destroy() end
                end
            end
            for _, c in ipairs(C.EspConnections) do c:Disconnect() end
            C.EspConnections = {}
        else
            for _, p in ipairs(C.Players:GetPlayers()) do
                C.createESP(p)
                table.insert(C.EspConnections, p.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    if C.Enabled.ESP then C.createESP(p) end
                end))
            end
            table.insert(C.EspConnections, C.Players.PlayerAdded:Connect(function(p)
                table.insert(C.EspConnections, p.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    if C.Enabled.ESP then C.createESP(p) end
                end))
            end))
        end
    end

    function C.startWalkFling()
        if C.WfActive then return end
        C.WfActive = true
        local stepConn = C.RunService.Stepped:Connect(function()
            if not C.WfActive then return end
            for _, p in ipairs(C.Players:GetPlayers()) do
                if p ~= C.Player and p.Character then
                    for _, part in ipairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
        table.insert(C.WfConns, stepConn)
        local co = coroutine.create(function()
            while C.WfActive do
                C.RunService.Heartbeat:Wait()
                local char = C.Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                local vel = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0,10000,0)
                C.RunService.RenderStepped:Wait()
                if root and root.Parent then root.AssemblyLinearVelocity = vel end
                C.RunService.Stepped:Wait()
                if root and root.Parent then root.AssemblyLinearVelocity = vel + Vector3.new(0,0.1,0) end
            end
        end)
        coroutine.resume(co)
        table.insert(C.WfConns, co)
    end
    
    function C.stopWalkFling()
        C.WfActive = false
        for _, c in ipairs(C.WfConns) do
            if typeof(c) == "RBXScriptConnection" then c:Disconnect()
            elseif typeof(c) == "thread" then pcall(task.cancel, c) end
        end
        C.WfConns = {}
        for _, p in ipairs(C.Players:GetPlayers()) do
            if p ~= C.Player and p.Character then
                for _, part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end

    function C.doTPDown()
        local char = C.Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.new(0,-20,0)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
    
    function C.startTPDown()
        if not C.Enabled.TPDown then return end
        C.doTPDown()
        task.delay(0.2, function()
            if C.Enabled.TPDown then
                C.Enabled.TPDown = false
                if C.VisualSetters.TPDown then C.VisualSetters.TPDown(false, true) end
            end
        end)
    end

    -- Mutual exclusivity
    C.movementToggles = {
        AutoWalkEnabled = { name = "Auto Walk Left", type = "auto" },
        AutoRightEnabled = { name = "Auto Walk Right", type = "auto" },
        AutoPlayLeftEnabled = { name = "Auto Play Left", type = "play" },
        AutoPlayRightEnabled = { name = "Auto Play Right", type = "play" }
    }
    
    function C.enforceMutualExclusivity(activatedKey, newState)
        if not newState then return end
        if activatedKey == "Hover" then
            local leftOn = C.Enabled.AutoPlayLeftEnabled
            local rightOn = C.Enabled.AutoPlayRightEnabled
            if leftOn and rightOn then
                if rightOn then
                    if C.VisualSetters.AutoPlayRightEnabled then C.VisualSetters.AutoPlayRightEnabled(false) end
                    C.Enabled.AutoPlayRightEnabled = false
                    C.AutoPlayRightEnabled = false
                elseif leftOn then
                    if C.VisualSetters.AutoPlayLeftEnabled then C.VisualSetters.AutoPlayLeftEnabled(false) end
                    C.Enabled.AutoPlayLeftEnabled = false
                    C.AutoPlayLeftEnabled = false
                end
            end
            return
        end
        if C.movementToggles[activatedKey] then
            local currentHover = C.Enabled.Hover
            if currentHover then
                if activatedKey == "AutoPlayLeftEnabled" or activatedKey == "AutoPlayRightEnabled" then
                    if activatedKey == "AutoPlayLeftEnabled" and C.Enabled.AutoPlayRightEnabled then
                        if C.VisualSetters.AutoPlayRightEnabled then C.VisualSetters.AutoPlayRightEnabled(false) end
                        C.Enabled.AutoPlayRightEnabled = false
                        C.AutoPlayRightEnabled = false
                    elseif activatedKey == "AutoPlayRightEnabled" and C.Enabled.AutoPlayLeftEnabled then
                        if C.VisualSetters.AutoPlayLeftEnabled then C.VisualSetters.AutoPlayLeftEnabled(false) end
                        C.Enabled.AutoPlayLeftEnabled = false
                        C.AutoPlayLeftEnabled = false
                    end
                    if C.Enabled.AutoWalkEnabled then
                        if C.VisualSetters.AutoWalkEnabled then C.VisualSetters.AutoWalkEnabled(false) end
                        C.Enabled.AutoWalkEnabled = false
                        C.AutoWalkEnabled = false
                    end
                    if C.Enabled.AutoRightEnabled then
                        if C.VisualSetters.AutoRightEnabled then C.VisualSetters.AutoRightEnabled(false) end
                        C.Enabled.AutoRightEnabled = false
                        C.AutoRightEnabled = false
                    end
                else
                    if C.VisualSetters[activatedKey] then C.VisualSetters[activatedKey](false) end
                    C.Enabled[activatedKey] = false
                    if activatedKey == "AutoWalkEnabled" then C.AutoWalkEnabled = false end
                    if activatedKey == "AutoRightEnabled" then C.AutoRightEnabled = false end
                    return
                end
            else
                for key, _ in pairs(C.movementToggles) do
                    if key ~= activatedKey and C.Enabled[key] then
                        if C.VisualSetters[key] then C.VisualSetters[key](false) end
                        C.Enabled[key] = false
                        if key == "AutoWalkEnabled" then C.AutoWalkEnabled = false end
                        if key == "AutoRightEnabled" then C.AutoRightEnabled = false end
                        if key == "AutoPlayLeftEnabled" then C.AutoPlayLeftEnabled = false end
                        if key == "AutoPlayRightEnabled" then C.AutoPlayRightEnabled = false end
                    end
                end
            end
        end
    end

    -- Sound helper
    function C.playSound(id, vol)
        pcall(function()
            local sound = Instance.new("Sound", C.SoundService)
            sound.SoundId = id
            sound.Volume = vol or 0.3
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 1)
        end)
    end

    function C.attachRipple(btn, targetFrame)
        targetFrame = targetFrame or btn
        targetFrame.ClipsDescendants = true
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                task.spawn(function()
                    local ripple = Instance.new("Frame", targetFrame)
                    ripple.BackgroundColor3 = Color3.fromRGB(255,255,255)
                    ripple.AnchorPoint = Vector2.new(0.5,0.5)
                    ripple.Size = UDim2.new(0,0,0,0)
                    local x = input.Position.X - targetFrame.AbsolutePosition.X
                    local y = input.Position.Y - targetFrame.AbsolutePosition.Y
                    ripple.Position = UDim2.new(0,x,0,y)
                    ripple.ZIndex = targetFrame.ZIndex + 1
                    ripple.BackgroundTransparency = 0.6
                    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1,0)
                    local maxSize = math.max(targetFrame.AbsoluteSize.X, targetFrame.AbsoluteSize.Y) * 2
                    local t = C.TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0,maxSize,0,maxSize),
                        BackgroundTransparency = 1
                    })
                    t:Play()
                    task.wait(0.4)
                    ripple:Destroy()
                end)
            end
        end)
    end

    -- Initialize features based on saved config
    if C.Enabled.SpinBot then C.startSpinBot() end
    if C.Enabled.AntiRagdoll then C.startAntiRagdoll() end
    if C.Enabled.SpeedBoost then C.startSpeedBoost() end
    if C.Enabled.SpeedWhileStealing then C.startSpeedWhileStealing() end
    if C.Enabled.AutoSteal then C.startAutoSteal() end
    if C.Enabled.BatAimbot then C.startBatAimbot() end
    if C.Enabled.Galaxy then C.startGalaxy() end
    if C.Enabled.GalaxySkyBright then C.enableGalaxySkyBright() end
    if C.Enabled.Optimizer then C.enableOptimizer() end
    if C.Enabled.ESP then C.toggleESP(true) end
    if C.Enabled.Unwalk then C.startUnwalk() end
    
    print("Blood Hub - Full Fixed Version Loaded Successfully!")
end)
