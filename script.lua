-- ╔══════════════════════════════════════════════════════════════╗
-- ║                        SECRET HUB                            ║
-- ║                 Steal a Brainrot Edition                     ║
-- ║                  discord.gg/JaFSsHRrU                        ║
-- ╚══════════════════════════════════════════════════════════════╝
repeat task.wait() until game:IsLoaded()
pcall(function() if setclipboard then setclipboard("discord.gg/JaFSsHRrU") end end)
local Pl=game:GetService("Players").LocalPlayer
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
if not Pl.Character then Pl.CharacterAdded:Wait() end
task.wait(0.5)
local Cfg={StealRadius=23,Speed=55,ProxRad=23,StealSpeed=29.5}
local T={AutoSteal=false,StealHighest=false,StealPriority=false,StealNearest=false,InstantSteal=false,
    AutoUnlock=false,ShowHUD=false,AutoInvis=false,AutoTPFail=false,AutoTPPriority=false,AutoKick=false,
    InvisToggle=false,FixLagback=false,InvOnSteal=false,UnlockOnSteal=false,Aimbot=false,Desync=false,
    SpeedEnabled=false,ProxCircle=false}
local C={};local lastSteal=0;local guiVisible=true;local proxHL={}

local function getH() local c=Pl.Character;return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=Pl.Character;return c and c:FindFirstChildOfClass("Humanoid") end
local function tw(o,p,t) TS:Create(o,TweenInfo.new(t or 0.15),p):Play() end
local function corner(r,p) local e=Instance.new("UICorner",p);e.CornerRadius=UDim.new(0,r);return e end
local function drag(f,h)
    h=h or f;local d,ds,dp=false,nil,nil
    h.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true;ds=i.Position;dp=f.Position end end)
    h.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end)
    UIS.InputChanged:Connect(function(i) if d and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local dt=i.Position-ds;f.Position=UDim2.new(dp.X.Scale,dp.X.Offset+dt.X,dp.Y.Scale,dp.Y.Offset+dt.Y)end end)
end

local function isMyPlot(n)
    local plots=workspace:FindFirstChild("Plots");if not plots then return false end
    local plot=plots:FindFirstChild(n);if not plot then return false end
    local sign=plot:FindFirstChild("PlotSign")
    if sign then local yb=sign:FindFirstChild("YourBase");if yb and yb:IsA("BillboardGui") then return yb.Enabled end end
    return false
end
local function findPrompt(nearest)
    local hrp=getH();if not hrp then return nil end
    local plots=workspace:FindFirstChild("Plots");if not plots then return nil end
    local np,nd=nil,math.huge
    for _,plot in ipairs(plots:GetChildren()) do
        if isMyPlot(plot.Name) then continue end
        local pods=plot:FindFirstChild("AnimalPodiums");if not pods then continue end
        for _,pod in ipairs(pods:GetChildren()) do
            pcall(function()
                local base=pod:FindFirstChild("Base");local spawn=base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist=(spawn.Position-hrp.Position).Magnitude
                    if dist<nd and dist<=Cfg.StealRadius then
                        local att=spawn:FindFirstChild("PromptAttachment")
                        if att then for _,ch in ipairs(att:GetChildren()) do if ch:IsA("ProximityPrompt") then np=ch;nd=dist;break end end end
                    end
                end
            end)
        end
    end
    return np
end
local function startSteal()
    if C.steal then return end
    C.steal=RS.Heartbeat:Connect(function()
        if not(T.AutoSteal or T.StealHighest or T.StealNearest or T.InstantSteal) then return end
        if tick()-lastSteal<0.25 then return end
        local hum=getHum();if hum and hum.FloorMaterial==Enum.Material.Air then return end
        local p=findPrompt(T.StealNearest)
        if p and p.Parent then lastSteal=tick();pcall(function() fireproximityprompt(p) end) end
    end)
end
local function stopSteal() if C.steal then C.steal:Disconnect();C.steal=nil end end
local function startAimbot()
    if C.aim then return end
    C.aim=RS.Heartbeat:Connect(function()
        if not T.Aimbot then return end
        local hrp=getH();if not hrp then return end
        local best,bd=nil,math.huge
        for _,p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p~=Pl and p.Character then
                local eh=p.Character:FindFirstChild("HumanoidRootPart")
                local h2=p.Character:FindFirstChildOfClass("Humanoid")
                if eh and h2 and h2.Health>0 then local d=(eh.Position-hrp.Position).Magnitude;if d<bd then bd=d;best=eh end end
            end
        end
        if not best then return end
        local f=Vector3.new(best.Position.X-hrp.Position.X,0,best.Position.Z-hrp.Position.Z)
        if f.Magnitude>1 then local m=f.Unit;hrp.AssemblyLinearVelocity=Vector3.new(m.X*Cfg.Speed,hrp.AssemblyLinearVelocity.Y,m.Z*Cfg.Speed) end
    end)
end
local function stopAimbot() if C.aim then C.aim:Disconnect();C.aim=nil end end
RS.Heartbeat:Connect(function()
    if not T.SpeedEnabled then return end
    local hrp=getH();local hum=getHum();if not hrp or not hum then return end
    local md=hum.MoveDirection;if md.Magnitude<0.1 or hum.FloorMaterial==Enum.Material.Air then return end
    hrp.AssemblyLinearVelocity=Vector3.new(md.X*Cfg.StealSpeed,hrp.AssemblyLinearVelocity.Y,md.Z*Cfg.StealSpeed)
end)
local function clearProx() for _,h in pairs(proxHL) do pcall(function() h:Destroy() end) end;proxHL={} end

-- ── GUI ──
local BG=Color3.fromRGB(15,15,20);local CARD=Color3.fromRGB(22,22,30);local GRN=Color3.fromRGB(0,200,100)
local WHT=Color3.fromRGB(255,255,255);local GRY=Color3.fromRGB(130,130,150);local DRK=Color3.fromRGB(10,10,16)
local RED=Color3.fromRGB(200,50,50);local BLUE=Color3.fromRGB(40,130,255)
local sg=Instance.new("ScreenGui");sg.Name="SecretHub";sg.ResetOnSpawn=false;sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;sg.Parent=Pl:FindFirstChildOfClass("PlayerGui") or Pl.PlayerGui

-- ── LEFT PANEL (Main actions like UCT) ──
local leftP=Instance.new("Frame",sg);leftP.Size=UDim2.new(0,140,0,340);leftP.Position=UDim2.new(0,5,0.35,0)
leftP.BackgroundColor3=BG;leftP.BackgroundTransparency=0.05;leftP.BorderSizePixel=0;leftP.ZIndex=10
corner(10,leftP);Instance.new("UIStroke",leftP).Color=Color3.fromRGB(35,35,50)
drag(leftP)
local lTitle=Instance.new("TextLabel",leftP);lTitle.Size=UDim2.new(1,0,0,20);lTitle.BackgroundTransparency=1
lTitle.Text="Secret Hub";lTitle.TextColor3=WHT;lTitle.Font=Enum.Font.GothamBlack;lTitle.TextSize=12;lTitle.ZIndex=11
local lSub=Instance.new("TextLabel",leftP);lSub.Size=UDim2.new(1,0,0,14);lSub.Position=UDim2.new(0,0,0,18)
lSub.BackgroundTransparency=1;lSub.Text="Actions";lSub.TextColor3=GRY;lSub.Font=Enum.Font.Gotham;lSub.TextSize=9;lSub.ZIndex=11
local lScroll=Instance.new("ScrollingFrame",leftP);lScroll.Size=UDim2.new(1,-8,1,-36);lScroll.Position=UDim2.new(0,4,0,34)
lScroll.BackgroundTransparency=1;lScroll.BorderSizePixel=0;lScroll.ScrollBarThickness=2;lScroll.ScrollBarImageColor3=GRN
lScroll.CanvasSize=UDim2.new(0,0,0,0);lScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;lScroll.ZIndex=11
local lList=Instance.new("UIListLayout",lScroll);lList.Padding=UDim.new(0,3);lList.SortOrder=Enum.SortOrder.LayoutOrder
Instance.new("UIPadding",lScroll).PaddingBottom=UDim.new(0,6)

local function mkLeftBtn(label,cb)
    local b=Instance.new("TextButton",lScroll);b.Size=UDim2.new(1,0,0,28)
    b.BackgroundColor3=CARD;b.BackgroundTransparency=0.2;b.BorderSizePixel=0
    b.Text=label;b.TextColor3=WHT;b.Font=Enum.Font.GothamBold;b.TextSize=11;b.ZIndex=12
    corner(6,b);b.MouseButton1Click:Connect(cb)
    b.MouseEnter:Connect(function() tw(b,{BackgroundTransparency=0}) end)
    b.MouseLeave:Connect(function() tw(b,{BackgroundTransparency=0.2}) end)
end
local function mkLeftHead(label)
    local l=Instance.new("TextLabel",lScroll);l.Size=UDim2.new(1,0,0,16);l.BackgroundTransparency=1
    l.Text=label;l.TextColor3=GRN;l.Font=Enum.Font.GothamBold;l.TextSize=9;l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=12
end
local proximityLbl=Instance.new("TextLabel",leftP);proximityLbl.Size=UDim2.new(1,-8,0,12);proximityLbl.Position=UDim2.new(0,4,0,22)
proximityLbl.BackgroundTransparency=1;proximityLbl.Text="Proximity: OFF";proximityLbl.TextColor3=GRY;proximityLbl.Font=Enum.Font.Gotham;proximityLbl.TextSize=8;proximityLbl.ZIndex=11

mkLeftHead("ACTIONS")
mkLeftBtn("Teleport (T)",function() local hrp=getH();if not hrp then return end;local p=findPrompt();if p and p.Parent then local pod=p.Parent.Parent.Parent;pcall(function() hrp.CFrame=CFrame.new(pod:GetPivot().Position+Vector3.new(0,5,0)) end) end end)
mkLeftBtn("Ragdoll Self (R)",function() local h=getHum();if h then h:ChangeState(Enum.HumanoidStateType.Ragdoll) end end)
mkLeftBtn("Rejoin PS",function() pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,Pl) end) end)
mkLeftBtn("Rejoin Job ID",function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId,Pl) end) end)
mkLeftBtn("Kick (Y)",function() Pl:Kick("Secret Hub") end)
mkLeftBtn("Reset (X)",function() local h=getHum();if h then h.Health=0 end end)
mkLeftHead("SETTINGS")
mkLeftBtn("⚙ Settings",function() end)

-- ── MAIN PANEL (center - UCT style with tabs) ──
local main=Instance.new("Frame",sg);main.Size=UDim2.new(0,400,0,500);main.Position=UDim2.new(0.3,0,0.5,-250)
main.BackgroundColor3=BG;main.BackgroundTransparency=0.05;main.BorderSizePixel=0;main.ClipsDescendants=true;main.ZIndex=10
corner(12,main);Instance.new("UIStroke",main).Color=Color3.fromRGB(35,35,50)

local mTitleBar=Instance.new("Frame",main);mTitleBar.Size=UDim2.new(1,0,0,44);mTitleBar.BackgroundColor3=DRK;mTitleBar.BorderSizePixel=0;mTitleBar.ZIndex=11
Instance.new("TextLabel",mTitleBar):ClearAllChildren()
local mTitle=Instance.new("TextLabel",mTitleBar);mTitle.Size=UDim2.new(1,-80,0,24);mTitle.Position=UDim2.new(0,12,0,4)
mTitle.BackgroundTransparency=1;mTitle.Text="SECRET HUB";mTitle.TextColor3=WHT;mTitle.Font=Enum.Font.GothamBlack;mTitle.TextSize=15;mTitle.TextXAlignment=Enum.TextXAlignment.Left;mTitle.ZIndex=12
local mSub=Instance.new("TextLabel",mTitleBar);mSub.Size=UDim2.new(1,-80,0,14);mSub.Position=UDim2.new(0,12,0,26)
mSub.BackgroundTransparency=1;mSub.Text="discord.gg/JaFSsHRrU";mSub.TextColor3=GRY;mSub.Font=Enum.Font.Gotham;mSub.TextSize=9;mSub.TextXAlignment=Enum.TextXAlignment.Left;mSub.ZIndex=12
local minBtn=Instance.new("TextButton",mTitleBar);minBtn.Size=UDim2.new(0,26,0,26);minBtn.Position=UDim2.new(1,-58,0.5,-13)
minBtn.BackgroundColor3=Color3.fromRGB(50,50,70);minBtn.BorderSizePixel=0;minBtn.Text="−";minBtn.TextColor3=WHT;minBtn.Font=Enum.Font.GothamBold;minBtn.TextSize=16;minBtn.ZIndex=12;corner(100,minBtn)
local xBtn=Instance.new("TextButton",mTitleBar);xBtn.Size=UDim2.new(0,26,0,26);xBtn.Position=UDim2.new(1,-28,0.5,-13)
xBtn.BackgroundColor3=RED;xBtn.BorderSizePixel=0;xBtn.Text="✕";xBtn.TextColor3=WHT;xBtn.Font=Enum.Font.GothamBold;xBtn.TextSize=11;xBtn.ZIndex=12;corner(100,xBtn)
xBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
drag(main,mTitleBar)

-- SIDEBAR
local sidebar=Instance.new("Frame",main);sidebar.Size=UDim2.new(0,70,1,-44);sidebar.Position=UDim2.new(0,0,0,44)
sidebar.BackgroundColor3=DRK;sidebar.BorderSizePixel=0;sidebar.ZIndex=11
local TABS={"Main","Steals","Priority","ESP","Misc","Config","Keybinds","Info"};local tabBtns={};local curTab="Main"
local tabList=Instance.new("UIListLayout",sidebar);tabList.Padding=UDim.new(0,1);tabList.SortOrder=Enum.SortOrder.LayoutOrder
for i,name in ipairs(TABS) do
    local b=Instance.new("TextButton",sidebar);b.Size=UDim2.new(1,0,0,34);b.LayoutOrder=i
    b.BackgroundColor3=name==curTab and Color3.fromRGB(28,28,42) or DRK;b.BackgroundTransparency=0;b.BorderSizePixel=0
    b.Text=name;b.TextColor3=name==curTab and WHT or GRY;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.ZIndex=12
    tabBtns[name]=b
end

-- CONTENT
local ca=Instance.new("Frame",main);ca.Size=UDim2.new(1,-70,1,-44);ca.Position=UDim2.new(0,70,0,44)
ca.BackgroundTransparency=1;ca.ZIndex=11
local panels={}
for _,name in ipairs(TABS) do
    local p=Instance.new("ScrollingFrame",ca);p.Size=UDim2.new(1,0,1,0);p.BackgroundTransparency=1;p.BorderSizePixel=0
    p.ScrollBarThickness=3;p.ScrollBarImageColor3=GRN;p.CanvasSize=UDim2.new(0,0,0,0);p.AutomaticCanvasSize=Enum.AutomaticSize.Y
    p.ZIndex=12;p.Visible=name=="Main"
    local l=Instance.new("UIListLayout",p);l.Padding=UDim.new(0,4);l.SortOrder=Enum.SortOrder.LayoutOrder
    local pad=Instance.new("UIPadding",p);pad.PaddingTop=UDim.new(0,8);pad.PaddingLeft=UDim.new(0,8);pad.PaddingRight=UDim.new(0,8);pad.PaddingBottom=UDim.new(0,8)
    panels[name]=p
end
local function switchTab(name) curTab=name;for n,p in pairs(panels)do p.Visible=(n==name)end;for n,b in pairs(tabBtns)do b.TextColor3=(n==name)and WHT or GRY;b.BackgroundColor3=(n==name)and Color3.fromRGB(28,28,42)or DRK end end
for name,btn in pairs(tabBtns) do btn.MouseButton1Click:Connect(function() switchTab(name) end) end

local function mkSection(panel,label)
    local l=Instance.new("TextLabel",panel);l.Size=UDim2.new(1,0,0,18);l.BackgroundTransparency=1
    l.Text="│ "..label;l.TextColor3=GRN;l.Font=Enum.Font.GothamBold;l.TextSize=10;l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=13
end
local function mkToggle(panel,label,tKey,onFn,offFn)
    local row=Instance.new("Frame",panel);row.Size=UDim2.new(1,0,0,38);row.BackgroundColor3=CARD;row.BackgroundTransparency=0.25;row.BorderSizePixel=0;row.ZIndex=13;corner(6,row)
    local lbl=Instance.new("TextLabel",row);lbl.Size=UDim2.new(1,-60,1,0);lbl.Position=UDim2.new(0,12,0,0);lbl.BackgroundTransparency=1
    lbl.Text=label;lbl.TextColor3=WHT;lbl.Font=Enum.Font.GothamBold;lbl.TextSize=13;lbl.TextXAlignment=Enum.TextXAlignment.Left;lbl.ZIndex=14
    local tb=Instance.new("Frame",row);tb.Size=UDim2.new(0,44,0,22);tb.Position=UDim2.new(1,-52,0.5,-11);tb.BackgroundColor3=Color3.fromRGB(40,40,60);tb.BorderSizePixel=0;tb.ZIndex=13;corner(100,tb)
    local knob=Instance.new("Frame",tb);knob.Size=UDim2.new(0,18,0,18);knob.Position=UDim2.new(0,2,0.5,-9);knob.BackgroundColor3=WHT;knob.BorderSizePixel=0;knob.ZIndex=14;corner(100,knob)
    local clk=Instance.new("TextButton",row);clk.Size=UDim2.new(1,0,1,0);clk.BackgroundTransparency=1;clk.Text="";clk.ZIndex=15
    local isOn=T[tKey] or false
    if isOn then tw(tb,{BackgroundColor3=GRN});tw(knob,{Position=UDim2.new(1,-20,0.5,-9)}) end
    local function sv(s) isOn=s;T[tKey]=isOn;tw(tb,{BackgroundColor3=isOn and GRN or Color3.fromRGB(40,40,60)});tw(knob,{Position=isOn and UDim2.new(1,-20,0.5,-9)or UDim2.new(0,2,0.5,-9)});if isOn and onFn then onFn()end;if not isOn and offFn then offFn()end end
    clk.MouseButton1Click:Connect(function() sv(not isOn) end)
end
local function mkBtn2(panel,label,color,cb)
    local b=Instance.new("TextButton",panel);b.Size=UDim2.new(1,0,0,36);b.BackgroundColor3=color or BLUE;b.BorderSizePixel=0
    b.Text=label;b.TextColor3=WHT;b.Font=Enum.Font.GothamBlack;b.TextSize=13;b.ZIndex=13;corner(8,b);b.MouseButton1Click:Connect(cb)
end

-- MAIN TAB
mkSection(panels["Main"],"ACTIONS")
mkBtn2(panels["Main"],"Teleport (T)",BLUE,function() local hrp=getH();if hrp then local p=findPrompt();if p then pcall(function() hrp.CFrame=CFrame.new(p.Parent.Parent.Parent:GetPivot().Position+Vector3.new(0,5,0)) end) end end end)
mkBtn2(panels["Main"],"Ragdoll Self (R)",Color3.fromRGB(60,60,80),function() local h=getHum();if h then h:ChangeState(Enum.HumanoidStateType.Ragdoll) end end)
mkBtn2(panels["Main"],"Rejoin PS",Color3.fromRGB(45,45,70),function() pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,Pl) end) end)
mkBtn2(panels["Main"],"Rejoin Job ID",Color3.fromRGB(45,45,70),function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId,Pl) end) end)
mkBtn2(panels["Main"],"Kick (Y)",RED,function() Pl:Kick("Secret Hub") end)
mkBtn2(panels["Main"],"Reset (X)",Color3.fromRGB(100,40,40),function() local h=getHum();if h then h.Health=0 end end)

-- STEALS TAB
mkSection(panels["Steals"],"AUTO UNLOCK")
mkToggle(panels["Steals"],"Auto Unlock on Steal","AutoUnlock",nil,nil)
mkToggle(panels["Steals"],"Show Unlock Buttons HUD","ShowHUD",nil,nil)
mkSection(panels["Steals"],"AUTOMATION")
mkToggle(panels["Steals"],"Auto Invis During Steal","AutoInvis",nil,nil)
mkToggle(panels["Steals"],"Auto TP on Failed Steal","AutoTPFail",nil,nil)
mkToggle(panels["Steals"],"Auto TP Priority Mode","AutoTPPriority",nil,nil)
mkToggle(panels["Steals"],"Auto-Kick on Steal","AutoKick",nil,nil)

-- MISC TAB
mkSection(panels["Misc"],"MISC")
mkToggle(panels["Misc"],"Fix Lagback","FixLagback",function() pcall(function() setfflag("MaxAcceptableUpdateDelay","1") end) end,nil)
mkToggle(panels["Misc"],"Desync","Desync",function() pcall(function() setfflag("PhysicsSenderMaxBandwidthBps","20000") end) end,nil)
mkToggle(panels["Misc"],"Aimbot","Aimbot",startAimbot,stopAimbot)
mkToggle(panels["Misc"],"Speed [E]","SpeedEnabled",nil,nil)
mkToggle(panels["Misc"],"Proximity Circle","ProxCircle",nil,nil)

-- INFO TAB
local infoLbl=Instance.new("TextLabel",panels["Info"]);infoLbl.Size=UDim2.new(1,0,0,100);infoLbl.BackgroundTransparency=1
infoLbl.Text="Secret Hub
discord.gg/JaFSsHRrU

Discord link auto-copied!";infoLbl.TextColor3=WHT;infoLbl.Font=Enum.Font.GothamBold;infoLbl.TextSize=13;infoLbl.TextXAlignment=Enum.TextXAlignment.Center;infoLbl.TextWrapped=true;infoLbl.ZIndex=13

-- ── STEAL TARGET PANEL (top right) ──
local stPanel=Instance.new("Frame",sg);stPanel.Size=UDim2.new(0,170,0,180);stPanel.Position=UDim2.new(0.75,0,0.02,0)
stPanel.BackgroundColor3=BG;stPanel.BackgroundTransparency=0.05;stPanel.BorderSizePixel=0;stPanel.ZIndex=10
corner(10,stPanel);Instance.new("UIStroke",stPanel).Color=Color3.fromRGB(35,35,50)
drag(stPanel)
Instance.new("TextLabel",stPanel):ClearAllChildren()
local stTitle=Instance.new("TextLabel",stPanel);stTitle.Size=UDim2.new(1,0,0,24);stTitle.BackgroundTransparency=1
stTitle.Text="Steal target";stTitle.TextColor3=WHT;stTitle.Font=Enum.Font.GothamBlack;stTitle.TextSize=12;stTitle.ZIndex=11
local stScroll=Instance.new("ScrollingFrame",stPanel);stScroll.Size=UDim2.new(1,-8,1,-26);stScroll.Position=UDim2.new(0,4,0,24)
stScroll.BackgroundTransparency=1;stScroll.BorderSizePixel=0;stScroll.ScrollBarThickness=2;stScroll.ScrollBarImageColor3=GRN
stScroll.CanvasSize=UDim2.new(0,0,0,0);stScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;stScroll.ZIndex=11
Instance.new("UIListLayout",stScroll).Padding=UDim.new(0,2)
local stLabels={}
for i=1,5 do
    local row=Instance.new("Frame",stScroll);row.Size=UDim2.new(1,0,0,26);row.BackgroundColor3=CARD;row.BackgroundTransparency=0.4;row.BorderSizePixel=0;row.ZIndex=12;corner(5,row)
    local lbl=Instance.new("TextLabel",row);lbl.Size=UDim2.new(1,-8,1,0);lbl.Position=UDim2.new(0,6,0,0);lbl.BackgroundTransparency=1
    lbl.Text="#"..i.."  —";lbl.TextColor3=GRY;lbl.Font=Enum.Font.Gotham;lbl.TextSize=10;lbl.TextXAlignment=Enum.TextXAlignment.Left;lbl.ZIndex=13
    table.insert(stLabels,lbl)
end

-- ── QUICK STEAL PANEL (right) ──
local qPanel=Instance.new("Frame",sg);qPanel.Size=UDim2.new(0,170,0,220);qPanel.Position=UDim2.new(0.75,0,0.34,0)
qPanel.BackgroundColor3=BG;qPanel.BackgroundTransparency=0.05;qPanel.BorderSizePixel=0;qPanel.ZIndex=10
corner(10,qPanel);Instance.new("UIStroke",qPanel).Color=Color3.fromRGB(35,35,50)
drag(qPanel)
local qTitle=Instance.new("TextLabel",qPanel);qTitle.Size=UDim2.new(1,0,0,24);qTitle.BackgroundTransparency=1
qTitle.Text="Secret Hub";qTitle.TextColor3=BLUE;qTitle.Font=Enum.Font.GothamBlack;qTitle.TextSize=12;qTitle.ZIndex=11
local qScroll=Instance.new("ScrollingFrame",qPanel);qScroll.Size=UDim2.new(1,-8,1,-26);qScroll.Position=UDim2.new(0,4,0,24)
qScroll.BackgroundTransparency=1;qScroll.BorderSizePixel=0;qScroll.ScrollBarThickness=2;qScroll.ScrollBarImageColor3=GRN
qScroll.CanvasSize=UDim2.new(0,0,0,0);qScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;qScroll.ZIndex=11
Instance.new("UIListLayout",qScroll).Padding=UDim.new(0,3)
Instance.new("UIPadding",qScroll).PaddingTop=UDim.new(0,4)
local function mkQRow(label,tKey,onFn,offFn)
    local row=Instance.new("Frame",qScroll);row.Size=UDim2.new(1,0,0,32);row.BackgroundColor3=CARD;row.BackgroundTransparency=0.3;row.BorderSizePixel=0;row.ZIndex=12;corner(6,row)
    local lbl=Instance.new("TextLabel",row);lbl.Size=UDim2.new(0.65,0,1,0);lbl.Position=UDim2.new(0,8,0,0);lbl.BackgroundTransparency=1
    lbl.Text=label;lbl.TextColor3=WHT;lbl.Font=Enum.Font.GothamBold;lbl.TextSize=11;lbl.TextXAlignment=Enum.TextXAlignment.Left;lbl.ZIndex=13
    local tb=Instance.new("Frame",row);tb.Size=UDim2.new(0,40,0,18);tb.Position=UDim2.new(1,-44,0.5,-9);tb.BackgroundColor3=Color3.fromRGB(40,40,60);tb.BorderSizePixel=0;tb.ZIndex=12;corner(100,tb)
    local knob=Instance.new("Frame",tb);knob.Size=UDim2.new(0,14,0,14);knob.Position=UDim2.new(0,2,0.5,-7);knob.BackgroundColor3=WHT;knob.BorderSizePixel=0;knob.ZIndex=13;corner(100,knob)
    local clk=Instance.new("TextButton",row);clk.Size=UDim2.new(1,0,1,0);clk.BackgroundTransparency=1;clk.Text="";clk.ZIndex=14
    local isOn=false
    clk.MouseButton1Click:Connect(function()
        isOn=not isOn;T[tKey]=isOn
        tw(tb,{BackgroundColor3=isOn and GRN or Color3.fromRGB(40,40,60)})
        tw(knob,{Position=isOn and UDim2.new(1,-16,0.5,-7)or UDim2.new(0,2,0.5,-7)})
        if isOn and onFn then onFn()end;if not isOn and offFn then offFn()end
    end)
end
mkQRow("Auto steal","AutoSteal",startSteal,stopSteal)
mkQRow("Steal highest","StealHighest",startSteal,stopSteal)
mkQRow("Steal priority","StealPriority",startSteal,stopSteal)
mkQRow("Steal nearest","StealNearest",startSteal,stopSteal)
mkQRow("Instant steal","InstantSteal",startSteal,stopSteal)

-- ── INVIS STEAL PANEL (right bottom) ──
local invPanel=Instance.new("Frame",sg);invPanel.Size=UDim2.new(0,170,0,260);invPanel.Position=UDim2.new(0.75,0,0.58,0)
invPanel.BackgroundColor3=BG;invPanel.BackgroundTransparency=0.05;invPanel.BorderSizePixel=0;invPanel.ZIndex=10
corner(10,invPanel);Instance.new("UIStroke",invPanel).Color=Color3.fromRGB(35,35,50)
drag(invPanel)
local invTitle=Instance.new("TextLabel",invPanel);invTitle.Size=UDim2.new(1,0,0,24);invTitle.BackgroundTransparency=1
invTitle.Text="Invis steal";invTitle.TextColor3=WHT;invTitle.Font=Enum.Font.GothamBlack;invTitle.TextSize=12;invTitle.ZIndex=11
local invScroll=Instance.new("ScrollingFrame",invPanel);invScroll.Size=UDim2.new(1,-8,1,-26);invScroll.Position=UDim2.new(0,4,0,24)
invScroll.BackgroundTransparency=1;invScroll.BorderSizePixel=0;invScroll.ScrollBarThickness=2;invScroll.ScrollBarImageColor3=GRN
invScroll.CanvasSize=UDim2.new(0,0,0,0);invScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;invScroll.ZIndex=11
Instance.new("UIListLayout",invScroll).Padding=UDim.new(0,3)
Instance.new("UIPadding",invScroll).PaddingTop=UDim.new(0,4)
local function mkInvRow(label,tKey,onFn,offFn)
    local row=Instance.new("Frame",invScroll);row.Size=UDim2.new(1,0,0,30);row.BackgroundColor3=CARD;row.BackgroundTransparency=0.3;row.BorderSizePixel=0;row.ZIndex=12;corner(6,row)
    local lbl=Instance.new("TextLabel",row);lbl.Size=UDim2.new(0.6,0,1,0);lbl.Position=UDim2.new(0,8,0,0);lbl.BackgroundTransparency=1
    lbl.Text=label;lbl.TextColor3=GRY;lbl.Font=Enum.Font.GothamBold;lbl.TextSize=10;lbl.TextXAlignment=Enum.TextXAlignment.Left;lbl.ZIndex=13
    local valBtn=Instance.new("TextButton",row);valBtn.Size=UDim2.new(0,44,0,20);valBtn.Position=UDim2.new(1,-48,0.5,-10)
    local isOn=tKey and T[tKey] or false
    valBtn.BackgroundColor3=isOn and GRN or Color3.fromRGB(140,40,40);valBtn.BorderSizePixel=0
    valBtn.Text=isOn and"ON"or"OFF";valBtn.TextColor3=WHT;valBtn.Font=Enum.Font.GothamBold;valBtn.TextSize=10;valBtn.ZIndex=13;corner(5,valBtn)
    valBtn.MouseButton1Click:Connect(function()
        isOn=not isOn;if tKey then T[tKey]=isOn end
        valBtn.Text=isOn and"ON"or"OFF";tw(valBtn,{BackgroundColor3=isOn and GRN or Color3.fromRGB(140,40,40)})
        if isOn and onFn then onFn()end;if not isOn and offFn then offFn()end
    end)
end
mkInvRow("Toggle","InvisToggle",nil,nil)
mkInvRow("Fix lagback","FixLagback",nil,nil)
mkInvRow("Inv on steal","InvOnSteal",nil,nil)
mkInvRow("Unlock on steal","UnlockOnSteal",nil,nil)
mkInvRow("Aimbot","Aimbot",startAimbot,stopAimbot)
mkInvRow("Desync","Desync",nil,nil)
local rotLbl=Instance.new("TextLabel",invScroll);rotLbl.Size=UDim2.new(1,0,0,14);rotLbl.BackgroundTransparency=1;rotLbl.Text="Rot: "..Cfg.StealRadius;rotLbl.TextColor3=GRY;rotLbl.Font=Enum.Font.Gotham;rotLbl.TextSize=9;rotLbl.TextXAlignment=Enum.TextXAlignment.Left;rotLbl.ZIndex=12
local depthLbl=Instance.new("TextLabel",invScroll);depthLbl.Size=UDim2.new(1,0,0,14);depthLbl.BackgroundTransparency=1;depthLbl.Text="Depth: 5.0";depthLbl.TextColor3=GRY;depthLbl.Font=Enum.Font.Gotham;depthLbl.TextSize=9;depthLbl.TextXAlignment=Enum.TextXAlignment.Left;depthLbl.ZIndex=12

-- ── STEAL SPEED (bottom right) ──
local ssPanel=Instance.new("Frame",sg);ssPanel.Size=UDim2.new(0,170,0,80);ssPanel.Position=UDim2.new(0.75,0,0.9,0)
ssPanel.BackgroundColor3=BG;ssPanel.BackgroundTransparency=0.05;ssPanel.BorderSizePixel=0;ssPanel.ZIndex=10
corner(10,ssPanel);Instance.new("UIStroke",ssPanel).Color=Color3.fromRGB(35,35,50)
drag(ssPanel)
local ssTitle=Instance.new("TextLabel",ssPanel);ssTitle.Size=UDim2.new(1,0,0,18);ssTitle.BackgroundTransparency=1;ssTitle.Text="STEAL SPEED";ssTitle.TextColor3=GRY;ssTitle.Font=Enum.Font.GothamBold;ssTitle.TextSize=9;ssTitle.ZIndex=11
local ssVal=Instance.new("TextLabel",ssPanel);ssVal.Size=UDim2.new(1,0,0,24);ssVal.Position=UDim2.new(0,0,0,16);ssVal.BackgroundTransparency=1;ssVal.Text=tostring(Cfg.StealSpeed);ssVal.TextColor3=WHT;ssVal.Font=Enum.Font.GothamBlack;ssVal.TextSize=18;ssVal.ZIndex=11
local ssStatus=Instance.new("TextLabel",ssPanel);ssStatus.Size=UDim2.new(1,0,0,14);ssStatus.Position=UDim2.new(0,0,0,40);ssStatus.BackgroundTransparency=1;ssStatus.Text="DISABLED";ssStatus.TextColor3=RED;ssStatus.Font=Enum.Font.GothamBold;ssStatus.TextSize=10;ssStatus.ZIndex=11
local ssBtn=Instance.new("TextButton",ssPanel);ssBtn.Size=UDim2.new(1,-16,0,18);ssBtn.Position=UDim2.new(0,8,0,56);ssBtn.BackgroundColor3=Color3.fromRGB(30,30,45);ssBtn.BorderSizePixel=0;ssBtn.Text="Type value, Enter";ssBtn.TextColor3=GRY;ssBtn.Font=Enum.Font.Gotham;ssBtn.TextSize=9;ssBtn.ZIndex=11;corner(5,ssBtn)
ssBtn.MouseButton1Click:Connect(function()
    T.SpeedEnabled=not T.SpeedEnabled;ssStatus.Text=T.SpeedEnabled and"ENABLED"or"DISABLED";ssStatus.TextColor3=T.SpeedEnabled and GRN or RED
end)

-- ── ADMIN PANEL ──
local adminF=Instance.new("Frame",sg);adminF.Size=UDim2.new(0,250,0,280);adminF.Position=UDim2.new(0,5,0.15,0)
adminF.BackgroundColor3=BG;adminF.BackgroundTransparency=0.05;adminF.BorderSizePixel=0;adminF.ZIndex=10;adminF.Visible=false
corner(10,adminF);Instance.new("UIStroke",adminF).Color=Color3.fromRGB(35,35,50)
drag(adminF)
local adminTitle=Instance.new("TextLabel",adminF);adminTitle.Size=UDim2.new(1,-30,0,30);adminTitle.BackgroundTransparency=1;adminTitle.Text="Admin Panel";adminTitle.TextColor3=WHT;adminTitle.Font=Enum.Font.GothamBlack;adminTitle.TextSize=13;adminTitle.ZIndex=11
local adminList=Instance.new("ScrollingFrame",adminF);adminList.Size=UDim2.new(1,-10,1,-34);adminList.Position=UDim2.new(0,5,0,32)
adminList.BackgroundTransparency=1;adminList.BorderSizePixel=0;adminList.ScrollBarThickness=2;adminList.ScrollBarImageColor3=GRN
adminList.CanvasSize=UDim2.new(0,0,0,0);adminList.ZIndex=11
local adminListLayout=Instance.new("UIListLayout",adminList);adminListLayout.Padding=UDim.new(0,4);adminListLayout.SortOrder=Enum.SortOrder.LayoutOrder

-- PROXIMITY LOOP
C.prox=RS.Heartbeat:Connect(function()
    if not T.ProxCircle then adminF.Visible=false;clearProx();return end
    local hrp=getH();if not hrp then return end
    clearProx();local nearby={}
    for _,p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p~=Pl and p.Character then
            local eh=p.Character:FindFirstChild("HumanoidRootPart")
            if eh and(eh.Position-hrp.Position).Magnitude<=Cfg.ProxRad then
                table.insert(nearby,p)
                local hl=Instance.new("SelectionBox");hl.Adornee=p.Character;hl.Color3=Color3.fromRGB(0,200,255)
                hl.LineThickness=0.05;hl.SurfaceTransparency=0.8;hl.SurfaceColor3=Color3.fromRGB(0,100,200)
                hl.Parent=Pl.PlayerGui;table.insert(proxHL,hl)
            end
        end
    end
    proximityLbl.Text="Proximity: "..(T.ProxCircle and"ON"or"OFF").." | "..#nearby.." nearby"
    adminF.Visible=#nearby>0
    for _,ch in ipairs(adminList:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    for _,p in ipairs(nearby) do
        local row=Instance.new("Frame",adminList);row.Size=UDim2.new(1,0,0,42);row.BackgroundColor3=CARD;row.BackgroundTransparency=0.3;row.BorderSizePixel=0;corner(6,row)
        local nl=Instance.new("TextLabel",row);nl.Size=UDim2.new(0.5,0,1,0);nl.Position=UDim2.new(0,8,0,0);nl.BackgroundTransparency=1
        nl.Text="@"..p.Name;nl.TextColor3=WHT;nl.Font=Enum.Font.GothamBold;nl.TextSize=11;nl.TextXAlignment=Enum.TextXAlignment.Left
        local function mkAB(lbl,xp,fn)
            local b=Instance.new("TextButton",row);b.Size=UDim2.new(0,28,0,28);b.Position=UDim2.new(0,xp,0.5,-14)
            b.BackgroundColor3=Color3.fromRGB(40,40,60);b.BorderSizePixel=0;b.Text=lbl;b.TextColor3=WHT;b.Font=Enum.Font.GothamBold;b.TextSize=9;corner(6,b)
            b.MouseButton1Click:Connect(fn)
        end
        mkAB("R",120,function() local c=p.Character;if c then local h=c:FindFirstChildOfClass("Humanoid");if h then h:ChangeState(Enum.HumanoidStateType.Ragdoll)end end end)
        mkAB("RO",150,function() local c=p.Character;if c then local h=c:FindFirstChild("HumanoidRootPart");if h then h.AssemblyLinearVelocity=Vector3.new(0,80,0)end end end)
        mkAB("J",182,function() local c=p.Character;if c then local h=c:FindFirstChild("HumanoidRootPart");if h then h.AssemblyLinearVelocity=Vector3.new(0,80,0)end end end)
        mkAB("B",212,function() local c=p.Character;if c then local h=c:FindFirstChild("HumanoidRootPart");if h then for i=1,5 do h.AssemblyLinearVelocity=Vector3.new(math.random(-50,50),100,math.random(-50,50));task.wait(0.05)end end end end)
    end
    adminList.CanvasSize=UDim2.new(0,0,0,#nearby*46)
end)

-- ── FPS BAR ──
local fpsBar=Instance.new("Frame",sg);fpsBar.Size=UDim2.new(0,400,0,34);fpsBar.Position=UDim2.new(0.3,0,1,-44)
fpsBar.BackgroundColor3=DRK;fpsBar.BackgroundTransparency=0.1;fpsBar.BorderSizePixel=0;fpsBar.ZIndex=10;corner(8,fpsBar);drag(fpsBar)
local uLbl=Instance.new("TextLabel",fpsBar);uLbl.Size=UDim2.new(0,20,1,0);uLbl.BackgroundTransparency=1;uLbl.Text="U";uLbl.TextColor3=GRN;uLbl.Font=Enum.Font.GothamBlack;uLbl.TextSize=12;uLbl.ZIndex=11
local hubLbl=Instance.new("TextLabel",fpsBar);hubLbl.Size=UDim2.new(0,90,1,0);hubLbl.Position=UDim2.new(0,22,0,0);hubLbl.BackgroundTransparency=1;hubLbl.Text="SECRET HUB";hubLbl.TextColor3=WHT;hubLbl.Font=Enum.Font.GothamBlack;hubLbl.TextSize=11;hubLbl.ZIndex=11
local dLbl=Instance.new("TextLabel",fpsBar);dLbl.Size=UDim2.new(0,130,1,0);dLbl.Position=UDim2.new(0,115,0,0);dLbl.BackgroundTransparency=1;dLbl.Text="discord.gg/JaFSsHRrU";dLbl.TextColor3=GRY;dLbl.Font=Enum.Font.Gotham;dLbl.TextSize=9;dLbl.ZIndex=11
local fpsLbl=Instance.new("TextLabel",fpsBar);fpsLbl.Size=UDim2.new(0,140,1,0);fpsLbl.Position=UDim2.new(1,-145,0,0);fpsLbl.BackgroundTransparency=1;fpsLbl.TextColor3=GRN;fpsLbl.Font=Enum.Font.GothamBold;fpsLbl.TextSize=11;fpsLbl.ZIndex=11
local fr,lt=0,tick()
RS.RenderStepped:Connect(function()
    fr=fr+1;if tick()-lt>=1 then local fps=fr;fr=0;lt=tick()
        local ok,ping=pcall(function() return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        fpsLbl.Text="FPS: "..fps.."  PING: "..(ok and ping or"?").."ms"
    end
end)

-- ── TOGGLE ──
minBtn.MouseButton1Click:Connect(function() guiVisible=not guiVisible;main.Visible=guiVisible end)
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end;local k=inp.KeyCode
    if k==Enum.KeyCode.U then guiVisible=not guiVisible;main.Visible=guiVisible end
    if k==Enum.KeyCode.T then local hrp=getH();if hrp then local p=findPrompt();if p then pcall(function() hrp.CFrame=CFrame.new(p.Parent.Parent.Parent:GetPivot().Position+Vector3.new(0,5,0)) end) end end end
    if k==Enum.KeyCode.R then local h=getHum();if h then h:ChangeState(Enum.HumanoidStateType.Ragdoll) end end
    if k==Enum.KeyCode.X then local h=getHum();if h then h.Health=0 end end
    if k==Enum.KeyCode.Y then Pl:Kick("Secret Hub") end
    if k==Enum.KeyCode.E then T.SpeedEnabled=not T.SpeedEnabled;ssStatus.Text=T.SpeedEnabled and"ENABLED"or"DISABLED";ssStatus.TextColor3=T.SpeedEnabled and GRN or RED end
end)
Pl.CharacterAdded:Connect(function() task.wait(1);if T.AutoSteal or T.InstantSteal then stopSteal();task.wait(0.1);startSteal()end;if T.Aimbot then stopAimbot();task.wait(0.1);startAimbot()end end)
print("[SECRET HUB] Loaded! discord.gg/JaFSsHRrU | U=Toggle")
