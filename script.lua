-- ╔══════════════════════════════════════════════════════════════╗
-- ║                        SECRET HUB                            ║
-- ║                 Steal a Brainrot Edition                     ║
-- ║                  discord.gg/JaFSsHRrU                        ║
-- ╚══════════════════════════════════════════════════════════════╝
repeat task.wait() until game:IsLoaded()
pcall(function() if setclipboard then setclipboard("discord.gg/JaFSsHRrU") end end)
local Players=game:GetService("Players");local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService");local TS=game:GetService("TweenService")
local Pl=Players.LocalPlayer
if not Pl.Character then Pl.CharacterAdded:Wait() end;task.wait(0.5)
local Cfg={StealRadius=23,Speed=55,ProxRad=23}
local T={AutoSteal=false,Aimbot=false,Speed=false,ProxCircle=false,InstantSteal=false}
local C={};local lastSteal=0;local guiVisible=true;local proxHighlights={}
local function getH()local c=Pl.Character;return c and c:FindFirstChild("HumanoidRootPart")end
local function getHum()local c=Pl.Character;return c and c:FindFirstChildOfClass("Humanoid")end
local function tw(o,p,t)TS:Create(o,TweenInfo.new(t or 0.15),p):Play()end
local function drag(frame,handle)
    handle=handle or frame;local d,ds,dp=false,nil,nil
    handle.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true;ds=i.Position;dp=frame.Position end end)
    handle.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end)
    UIS.InputChanged:Connect(function(i)if d and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local dt=i.Position-ds;frame.Position=UDim2.new(dp.X.Scale,dp.X.Offset+dt.X,dp.Y.Scale,dp.Y.Offset+dt.Y)end end)
end
local function isMyPlot(n)
    local plots=workspace:FindFirstChild("Plots");if not plots then return false end
    local plot=plots:FindFirstChild(n);if not plot then return false end
    local sign=plot:FindFirstChild("PlotSign")
    if sign then local yb=sign:FindFirstChild("YourBase");if yb and yb:IsA("BillboardGui")then return yb.Enabled end end
    return false
end
local function findPrompt()
    local hrp=getH();if not hrp then return nil end
    local plots=workspace:FindFirstChild("Plots");if not plots then return nil end
    local np,nd=nil,math.huge
    for _,plot in ipairs(plots:GetChildren())do
        if isMyPlot(plot.Name)then continue end
        local pods=plot:FindFirstChild("AnimalPodiums");if not pods then continue end
        for _,pod in ipairs(pods:GetChildren())do
            pcall(function()
                local base=pod:FindFirstChild("Base");local spawn=base and base:FindFirstChild("Spawn")
                if spawn then local dist=(spawn.Position-hrp.Position).Magnitude
                    if dist<nd and dist<=Cfg.StealRadius then
                        local att=spawn:FindFirstChild("PromptAttachment")
                        if att then for _,ch in ipairs(att:GetChildren())do if ch:IsA("ProximityPrompt")then np=ch;nd=dist;break end end end
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
        if not(T.AutoSteal or T.InstantSteal)then return end
        if tick()-lastSteal<0.25 then return end
        local hum=getHum();if hum and hum.FloorMaterial==Enum.Material.Air then return end
        local p=findPrompt();if p and p.Parent then lastSteal=tick();pcall(function()fireproximityprompt(p)end)end
    end)
end
local function stopSteal()if C.steal then C.steal:Disconnect();C.steal=nil end end
local function startAimbot()
    if C.aim then return end
    C.aim=RS.Heartbeat:Connect(function()
        if not T.Aimbot then return end
        local hrp=getH();if not hrp then return end
        local best,bd=nil,math.huge
        for _,p in ipairs(Players:GetPlayers())do
            if p~=Pl and p.Character then
                local eh=p.Character:FindFirstChild("HumanoidRootPart")
                local h2=p.Character:FindFirstChildOfClass("Humanoid")
                if eh and h2 and h2.Health>0 then local d=(eh.Position-hrp.Position).Magnitude;if d<bd then bd=d;best=eh end end
            end
        end
        if not best then return end
        local f=Vector3.new(best.Position.X-hrp.Position.X,0,best.Position.Z-hrp.Position.Z)
        if f.Magnitude>1 then local m=f.Unit;hrp.AssemblyLinearVelocity=Vector3.new(m.X*Cfg.Speed,hrp.AssemblyLinearVelocity.Y,m.Z*Cfg.Speed)end
    end)
end
local function stopAimbot()if C.aim then C.aim:Disconnect();C.aim=nil end end
local function startSpeed()
    if C.spd then return end
    C.spd=RS.Heartbeat:Connect(function()
        if not T.Speed then return end
        local hrp=getH();local hum=getHum();if not hrp or not hum then return end
        local md=hum.MoveDirection;if md.Magnitude<0.1 or hum.FloorMaterial==Enum.Material.Air then return end
        hrp.AssemblyLinearVelocity=Vector3.new(md.X*Cfg.Speed,hrp.AssemblyLinearVelocity.Y,md.Z*Cfg.Speed)
    end)
end
local function clearProx()for _,h in pairs(proxHighlights)do pcall(function()h:Destroy()end)end;proxHighlights={}end
local adminFrame=nil
local function startProx(aFrame,aList)
    if C.prox then return end
    C.prox=RS.Heartbeat:Connect(function()
        if not T.ProxCircle then return end
        local hrp=getH();if not hrp then return end
        clearProx()
        local nearby={}
        for _,p in ipairs(Players:GetPlayers())do
            if p~=Pl and p.Character then
                local eh=p.Character:FindFirstChild("HumanoidRootPart")
                if eh and(eh.Position-hrp.Position).Magnitude<=Cfg.ProxRad then
                    table.insert(nearby,p)
                    local hl=Instance.new("SelectionBox");hl.Adornee=p.Character
                    hl.Color3=Color3.fromRGB(0,200,255);hl.LineThickness=0.05
                    hl.SurfaceTransparency=0.8;hl.SurfaceColor3=Color3.fromRGB(0,100,200)
                    hl.Parent=Pl.PlayerGui;table.insert(proxHighlights,hl)
                end
            end
        end
        if aFrame then aFrame.Visible=#nearby>0 end
        if aList and #nearby>0 then
            for _,ch in ipairs(aList:GetChildren())do if ch:IsA("Frame")then ch:Destroy()end end
            for _,p in ipairs(nearby)do
                local row=Instance.new("Frame",aList);row.Size=UDim2.new(1,0,0,40);row.BackgroundColor3=Color3.fromRGB(22,22,32);row.BorderSizePixel=0
                Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
                local nl=Instance.new("TextLabel",row);nl.Size=UDim2.new(0.45,0,1,0);nl.Position=UDim2.new(0,6,0,0);nl.BackgroundTransparency=1
                nl.Text="@"..p.Name;nl.TextColor3=Color3.fromRGB(200,200,200);nl.Font=Enum.Font.GothamBold;nl.TextSize=10;nl.TextXAlignment=Enum.TextXAlignment.Left
                local function mkABtn(lbl,xp,fn)
                    local b=Instance.new("TextButton",row);b.Size=UDim2.new(0,26,0,26);b.Position=UDim2.new(0,xp,0.5,-13)
                    b.BackgroundColor3=Color3.fromRGB(40,40,60);b.BorderSizePixel=0;b.Text=lbl;b.TextColor3=Color3.fromRGB(200,200,200);b.Font=Enum.Font.GothamBold;b.TextSize=9
                    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5);b.MouseButton1Click:Connect(fn)
                end
                mkABtn("R",120,function()local c=p.Character;if c then local h=c:FindFirstChildOfClass("Humanoid");if h then h:ChangeState(Enum.HumanoidStateType.Ragdoll)end end end)
                mkABtn("J",150,function()local c=p.Character;if c then local h=c:FindFirstChild("HumanoidRootPart");if h then h.AssemblyLinearVelocity=Vector3.new(0,80,0)end end end)
                mkABtn("B",180,function()local c=p.Character;if c then local h=c:FindFirstChild("HumanoidRootPart");if h then for i=1,5 do h.AssemblyLinearVelocity=Vector3.new(math.random(-50,50),100,math.random(-50,50));task.wait(0.05)end end end end)
            end
            aList.CanvasSize=UDim2.new(0,0,0,#nearby*44)
        end
    end)
end
local function stopProx()if C.prox then C.prox:Disconnect();C.prox=nil end;clearProx()end
-- GUI
local sg=Instance.new("ScreenGui");sg.Name="SecretHub";sg.ResetOnSpawn=false;sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;sg.Parent=Pl:FindFirstChildOfClass("PlayerGui")or Pl.PlayerGui
local BG=Color3.fromRGB(15,15,22);local CARD=Color3.fromRGB(22,22,32);local GRN=Color3.fromRGB(0,200,100)
local WHT=Color3.fromRGB(255,255,255);local GRY=Color3.fromRGB(120,120,140);local DRK=Color3.fromRGB(10,10,18)
local RED=Color3.fromRGB(200,50,50);local BLUE=Color3.fromRGB(30,120,255)
local function el(cls,props,par)local e=Instance.new(cls);for k,v in pairs(props)do e[k]=v end;if par then e.Parent=par end;return e end
local function corner(r,p)return el("UICorner",{CornerRadius=UDim.new(0,r)},p)end
-- MAIN
local main=el("Frame",{Size=UDim2.new(0,300,0,520),Position=UDim2.new(0.35,0,0.5,-260),BackgroundColor3=BG,BackgroundTransparency=0.05,BorderSizePixel=0,ClipsDescendants=true,ZIndex=10},sg);corner(12,main)
el("UIStroke",{Color=Color3.fromRGB(40,40,60)},main)
local tBar=el("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=DRK,BorderSizePixel=0,ZIndex=11},main)
el("TextLabel",{Size=UDim2.new(1,-70,0,24),Position=UDim2.new(0,12,0,4),BackgroundTransparency=1,Text="Secret Hub",TextColor3=WHT,Font=Enum.Font.GothamBlack,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12},tBar)
el("TextLabel",{Size=UDim2.new(1,-70,0,14),Position=UDim2.new(0,12,0,26),BackgroundTransparency=1,Text="discord.gg/JaFSsHRrU",TextColor3=GRY,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12},tBar)
local minBtn=el("TextButton",{Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,-60,0.5,-13),BackgroundColor3=Color3.fromRGB(50,50,70),BorderSizePixel=0,Text="−",TextColor3=WHT,Font=Enum.Font.GothamBold,TextSize=16,ZIndex=12},tBar);corner(100,minBtn)
local xBtn=el("TextButton",{Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,-30,0.5,-13),BackgroundColor3=RED,BorderSizePixel=0,Text="✕",TextColor3=WHT,Font=Enum.Font.GothamBold,TextSize=11,ZIndex=12},tBar);corner(100,xBtn)
xBtn.MouseButton1Click:Connect(function()sg:Destroy()end)
drag(main,tBar)
-- SIDEBAR
local sidebar=el("Frame",{Size=UDim2.new(0,65,1,-44),Position=UDim2.new(0,0,0,44),BackgroundColor3=DRK,BorderSizePixel=0,ZIndex=11},main)
local TABS={"Main","Steals","Misc"};local tabBtns={};local curTab="Main"
el("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},sidebar)
for i,name in ipairs(TABS)do
    local b=el("TextButton",{Size=UDim2.new(1,0,0,36),BackgroundColor3=name==curTab and Color3.fromRGB(30,30,50)or DRK,BorderSizePixel=0,Text=name,TextColor3=name==curTab and WHT or GRY,Font=Enum.Font.GothamBold,TextSize=10,ZIndex=12,LayoutOrder=i},sidebar)
    tabBtns[name]=b
end
-- CONTENT
local ca=el("Frame",{Size=UDim2.new(1,-65,1,-44),Position=UDim2.new(0,65,0,44),BackgroundTransparency=1,ZIndex=11},main)
local panels={}
for _,name in ipairs(TABS)do
    local p=el("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=GRN,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=12,Visible=name=="Main"},ca)
    local l=el("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},p)
    el("UIPadding",{PaddingTop=UDim.new(0,6),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,6)},p)
    panels[name]=p
end
local function switchTab(name)curTab=name;for n,p in pairs(panels)do p.Visible=(n==name)end;for n,b in pairs(tabBtns)do b.TextColor3=(n==name)and WHT or GRY;b.BackgroundColor3=(n==name)and Color3.fromRGB(30,30,50)or DRK end end
for name,btn in pairs(tabBtns)do btn.MouseButton1Click:Connect(function()switchTab(name)end)end
local function mkToggle(panel,label,tKey,onFn,offFn)
    local row=el("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=CARD,BackgroundTransparency=0.3,BorderSizePixel=0,ZIndex=13},panel);corner(6,row)
    el("TextLabel",{Size=UDim2.new(1,-58,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=label,TextColor3=WHT,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=14},row)
    local tb=el("Frame",{Size=UDim2.new(0,42,0,20),Position=UDim2.new(1,-48,0.5,-10),BackgroundColor3=Color3.fromRGB(40,40,60),BorderSizePixel=0,ZIndex=13},row);corner(100,tb)
    local knob=el("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,2,0.5,-8),BackgroundColor3=WHT,BorderSizePixel=0,ZIndex=14},tb);corner(100,knob)
    local clk=el("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=15},row)
    local isOn=false
    clk.MouseButton1Click:Connect(function()
        isOn=not isOn;T[tKey]=isOn
        tw(tb,{BackgroundColor3=isOn and GRN or Color3.fromRGB(40,40,60)})
        tw(knob,{Position=isOn and UDim2.new(1,-18,0.5,-8)or UDim2.new(0,2,0.5,-8)})
        if isOn and onFn then onFn()end;if not isOn and offFn then offFn()end
    end)
end
local function mkBtn(panel,label,color,cb)
    local b=el("TextButton",{Size=UDim2.new(1,0,0,38),BackgroundColor3=color or BLUE,BorderSizePixel=0,Text=label,TextColor3=WHT,Font=Enum.Font.GothamBlack,TextSize=13,ZIndex=13},panel);corner(8,b);b.MouseButton1Click:Connect(cb)
end
local function mkHead(panel,label)
    el("TextLabel",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text="│ "..label,TextColor3=GRN,Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13},panel)
end
-- MAIN TAB
mkHead(panels["Main"],"ACTIONS")
mkBtn(panels["Main"],"Teleport (T)",BLUE,function()local hrp=getH();if hrp then local p=findPrompt();if p and p.Parent then hrp.CFrame=CFrame.new(p.Parent.Parent.Parent:GetPivot().Position+Vector3.new(0,5,0))end end end)
mkBtn(panels["Main"],"Ragdoll Self (R)",Color3.fromRGB(70,70,90),function()local h=getHum();if h then h:ChangeState(Enum.HumanoidStateType.Ragdoll)end end)
mkBtn(panels["Main"],"Rejoin",Color3.fromRGB(50,50,80),function()local ts=game:GetService("TeleportService");pcall(function()ts:TeleportToPlaceInstance(game.PlaceId,game.JobId,Pl)end)end)
mkBtn(panels["Main"],"Reset (X)",RED,function()local h=getHum();if h then h.Health=0 end end)
mkHead(panels["Main"],"ADMIN")
mkToggle(panels["Main"],"Proximity Circle","ProxCircle",function()T.ProxCircle=true;startProx(adminFrame,adminFrame and adminFrame:FindFirstChild("List"))end,function()T.ProxCircle=false;stopProx()end)
-- STEALS TAB
mkHead(panels["Steals"],"STEAL")
mkToggle(panels["Steals"],"Auto Steal","AutoSteal",startSteal,stopSteal)
mkToggle(panels["Steals"],"Instant Steal","InstantSteal",startSteal,stopSteal)
mkToggle(panels["Steals"],"Aimbot","Aimbot",startAimbot,stopAimbot)
mkHead(panels["Steals"],"OPTIONS")
mkToggle(panels["Steals"],"Auto Invis on Steal","AutoInvis",nil,nil)
mkToggle(panels["Steals"],"Auto TP on Fail","AutoTP",nil,nil)
mkToggle(panels["Steals"],"Auto Kick on Steal","AutoKick",nil,nil)
-- MISC TAB
mkHead(panels["Misc"],"MISC")
mkToggle(panels["Misc"],"Speed [E]","Speed",startSpeed,nil)
mkBtn(panels["Misc"],"Copy Discord",GRN,function()pcall(function()if setclipboard then setclipboard("discord.gg/JaFSsHRrU")end end)end)
-- ADMIN PANEL
adminFrame=el("Frame",{Size=UDim2.new(0,240,0,260),Position=UDim2.new(0,10,0.15,0),BackgroundColor3=BG,BackgroundTransparency=0.05,BorderSizePixel=0,ZIndex=10,Visible=false},sg);corner(12,adminFrame)
el("UIStroke",{Color=Color3.fromRGB(40,40,60)},adminFrame)
el("TextLabel",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Text="Admin Panel",TextColor3=WHT,Font=Enum.Font.GothamBlack,TextSize=13,ZIndex=11},adminFrame)
local aList=el("ScrollingFrame",{Name="List",Size=UDim2.new(1,-10,1,-34),Position=UDim2.new(0,5,0,32),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=GRN,CanvasSize=UDim2.new(0,0,0,0),ZIndex=11},adminFrame)
el("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},aList)
drag(adminFrame)
startProx(adminFrame,aList)
-- FPS BAR
local fpsBar=el("Frame",{Size=UDim2.new(0,300,0,32),Position=UDim2.new(0.35,0,1,-42),BackgroundColor3=DRK,BackgroundTransparency=0.1,BorderSizePixel=0,ZIndex=10},sg);corner(8,fpsBar);drag(fpsBar)
el("TextLabel",{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text="SECRET HUB",TextColor3=WHT,Font=Enum.Font.GothamBlack,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11},fpsBar)
local fpsLbl=el("TextLabel",{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,0,0,0),BackgroundTransparency=1,TextColor3=GRN,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=11},fpsBar)
local fpsLbl2=el("TextLabel",{Size=UDim2.new(1,-10,0,12),Position=UDim2.new(0,10,1,-14),BackgroundTransparency=1,Text="discord.gg/JaFSsHRrU",TextColor3=GRY,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11},fpsBar)
local fr,lt=0,tick()
RS.RenderStepped:Connect(function()fr=fr+1;if tick()-lt>=1 then local fps=fr;fr=0;lt=tick();local ok,ping=pcall(function()return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())end);fpsLbl.Text="FPS:"..fps.." PING:"..(ok and ping or"?").."ms" end end)
-- TOGGLE
minBtn.MouseButton1Click:Connect(function()guiVisible=not guiVisible;main.Visible=guiVisible end)
-- INPUT
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end;local k=inp.KeyCode
    if k==Enum.KeyCode.U then guiVisible=not guiVisible;main.Visible=guiVisible end
    if k==Enum.KeyCode.T then local hrp=getH();if hrp then local p=findPrompt();if p then hrp.CFrame=CFrame.new(p.Parent.Parent.Parent:GetPivot().Position+Vector3.new(0,5,0))end end end
    if k==Enum.KeyCode.R then local h=getHum();if h then h:ChangeState(Enum.HumanoidStateType.Ragdoll)end end
    if k==Enum.KeyCode.X then local h=getHum();if h then h.Health=0 end end
    if k==Enum.KeyCode.E then T.Speed=not T.Speed;if T.Speed then startSpeed()end end
end)
Pl.CharacterAdded:Connect(function()task.wait(1);if T.AutoSteal or T.InstantSteal then stopSteal();task.wait(0.1);startSteal()end;if T.Aimbot then stopAimbot();task.wait(0.1);startAimbot()end end)
print("[SECRET HUB] Loaded! discord.gg/JaFSsHRrU")
