local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local NexHubUI = {}

local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Topbar = Color3.fromRGB(24, 24, 28),
    Accent = Color3.fromRGB(155, 89, 182), -- Purple
    Text = Color3.fromRGB(230, 230, 230),
    TextDark = Color3.fromRGB(140, 140, 140),
    Element = Color3.fromRGB(28, 28, 34),
    ElementHover = Color3.fromRGB(35, 35, 42),
    Outline = Color3.fromRGB(40, 40, 48),
}

function NexHubUI:AddTheme(cfg)
    if cfg.Accent then Theme.Accent = cfg.Accent end
    if cfg.WindowBackground then Theme.Background = cfg.WindowBackground end
end

local function MakeDraggable(topbar, frame)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function NexHubUI:MakeNotify(cfg)
    local title = cfg.Title or "Notification"
    local content = cfg.Content or ""
    local duration = cfg.Duration or 3
    local fullText = content ~= "" and (title .. " | " .. content) or title

    local ui = CoreGui:FindFirstChild("NexHubNotifContainer")
    if not ui then
        ui = Instance.new("ScreenGui")
        ui.Name = "NexHubNotifContainer"
        ui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui
    end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 32)
    notif.Position = UDim2.new(1, 10, 1, -50 - (#ui:GetChildren() * 40))
    notif.BackgroundColor3 = Theme.Background
    notif.Parent = ui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 4)
    
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = Theme.Outline
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local accent = Instance.new("Frame", notif)
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = Theme.Accent
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 3)

    local lbl = Instance.new("TextLabel", notif)
    lbl.Size = UDim2.new(1, -15, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = fullText
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextColor3 = Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -300, 1, notif.Position.Y.Offset)}):Play()
    
    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 10, 1, notif.Position.Y.Offset)}):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

function NexHubUI:Window(cfg)
    local WindowSize = cfg.Size or UDim2.fromOffset(550, 380)
    
    local SG = Instance.new("ScreenGui")
    SG.Name = "VelarisUI_Clone_" .. tostring(math.random(100,999))
    SG.ResetOnSpawn = false
    SG.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui

    local Main = Instance.new("Frame")
    Main.Size = WindowSize
    Main.Position = UDim2.new(0.5, -WindowSize.X.Offset/2, 0.5, -WindowSize.Y.Offset/2)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.Parent = SG
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", Main)
    stroke.Color = Theme.Outline

    local Topbar = Instance.new("Frame", Main)
    Topbar.Size = UDim2.new(1, 0, 0, 30)
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.BorderSizePixel = 0
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 6)
    local tpFix = Instance.new("Frame", Topbar)
    tpFix.Size = UDim2.new(1, 0, 0, 6)
    tpFix.Position = UDim2.new(0, 0, 1, -6)
    tpFix.BackgroundColor3 = Theme.Topbar
    tpFix.BorderSizePixel = 0
    
    local lbl = Instance.new("TextLabel", Topbar)
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = cfg.Title or "NexHub UI"
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    MakeDraggable(Topbar, Main)

    -- KEY SYSTEM HANDLING
    if cfg.KeySystem then
        local kf = Instance.new("Frame", Main)
        kf.Size = UDim2.new(1, 0, 1, -30)
        kf.Position = UDim2.new(0, 0, 0, 30)
        kf.BackgroundTransparency = 1
        
        local klbl = Instance.new("TextLabel", kf)
        klbl.Size = UDim2.new(1, 0, 0, 20)
        klbl.Position = UDim2.new(0, 0, 0.5, -40)
        klbl.BackgroundTransparency = 1
        klbl.Text = cfg.KeySystem.Title or "Authentication"
        klbl.Font = Enum.Font.GothamBold
        klbl.TextSize = 16
        klbl.TextColor3 = Theme.Text
        
        local box = Instance.new("TextBox", kf)
        box.Size = UDim2.new(0, 220, 0, 28)
        box.Position = UDim2.new(0.5, -110, 0.5, -10)
        box.BackgroundColor3 = Theme.Element
        box.Text = ""
        box.PlaceholderText = cfg.KeySystem.Placeholder or "Enter Key..."
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.TextColor3 = Theme.Text
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        local bs = Instance.new("UIStroke", box)
        bs.Color = Theme.Outline
        
        local btn = Instance.new("TextButton", kf)
        btn.Size = UDim2.new(0, 120, 0, 28)
        btn.Position = UDim2.new(0.5, -60, 0.5, 30)
        btn.BackgroundColor3 = Theme.Accent
        btn.Text = "Verify"
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            btn.Text = "..."
            local ok = false
            if type(cfg.KeySystem.Callback) == "function" then
                ok = cfg.KeySystem.Callback(box.Text)
            end
            if not ok then
                btn.Text = "Invalid"
                task.wait(1)
                btn.Text = "Verify"
            end
        end)
        
        return { GUI = SG, Destroy = function() SG:Destroy() end }
    end

    -- HORIZONTAL TABS
    local TabContainer = Instance.new("ScrollingFrame", Main)
    TabContainer.Size = UDim2.new(1, -20, 0, 28)
    TabContainer.Position = UDim2.new(0, 10, 0, 35)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local tLayout = Instance.new("UIListLayout", TabContainer)
    tLayout.FillDirection = Enum.FillDirection.Horizontal
    tLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tLayout.Padding = UDim.new(0, 6)
    
    tLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, tLayout.AbsoluteContentSize.X, 0, 0)
    end)

    local sep = Instance.new("Frame", Main)
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Position = UDim2.new(0, 0, 0, 68)
    sep.BackgroundColor3 = Theme.Outline
    sep.BorderSizePixel = 0

    local ContentContainer = Instance.new("Frame", Main)
    ContentContainer.Size = UDim2.new(1, -16, 1, -75)
    ContentContainer.Position = UDim2.new(0, 8, 0, 72)
    ContentContainer.BackgroundTransparency = 1

    local WindowObj = { Tabs = {} }
    
    function WindowObj:AddTab(tCfg)
        local tName = tCfg.Name or tCfg.Title or "Tab"
        
        local tBtn = Instance.new("TextButton", TabContainer)
        tBtn.Size = UDim2.new(0, 0, 1, 0)
        tBtn.AutomaticSize = Enum.AutomaticSize.X
        tBtn.BackgroundTransparency = 1
        tBtn.Text = "  " .. tName .. "  "
        tBtn.Font = Enum.Font.GothamMedium
        tBtn.TextSize = 12
        tBtn.TextColor3 = Theme.TextDark
        
        local und = Instance.new("Frame", tBtn)
        und.Size = UDim2.new(0, 0, 0, 2)
        und.Position = UDim2.new(0.5, 0, 1, -2)
        und.AnchorPoint = Vector2.new(0.5, 0)
        und.BackgroundColor3 = Theme.Accent
        und.BorderSizePixel = 0

        local Page = Instance.new("ScrollingFrame", ContentContainer)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Visible = false
        
        local pLayout = Instance.new("UIListLayout", Page)
        pLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pLayout.Padding = UDim.new(0, 8)
        local pad = Instance.new("UIPadding", Page)
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingRight = UDim.new(0, 8)
        pad.PaddingLeft = UDim.new(0, 2)
        pad.PaddingBottom = UDim.new(0, 8)
        
        pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 16)
        end)

        local tObj = { Button = tBtn, Page = Page, Und = und }
        table.insert(WindowObj.Tabs, tObj)

        tBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(WindowObj.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.2), {TextColor3 = Theme.TextDark}):Play()
                TweenService:Create(t.Und, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 2)}):Play()
            end
            Page.Visible = true
            TweenService:Create(tBtn, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
            TweenService:Create(und, TweenInfo.new(0.2), {Size = UDim2.new(1, -4, 0, 2)}):Play()
        end)

        if #WindowObj.Tabs == 1 then
            Page.Visible = true
            tBtn.TextColor3 = Theme.Text
            und.Size = UDim2.new(1, -4, 0, 2)
        end

        function tObj:AddSection(sCfg)
            local sTitle = sCfg.Title or "Group"
            
            local sFrame = Instance.new("Frame", Page)
            sFrame.Size = UDim2.new(1, 0, 0, 20)
            sFrame.BackgroundColor3 = Theme.Element
            Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 4)
            local sStr = Instance.new("UIStroke", sFrame)
            sStr.Color = Theme.Outline
            
            local sLbl = Instance.new("TextLabel", sFrame)
            sLbl.Size = UDim2.new(1, -16, 0, 22)
            sLbl.Position = UDim2.new(0, 8, 0, 0)
            sLbl.BackgroundTransparency = 1
            sLbl.Text = sTitle
            sLbl.Font = Enum.Font.GothamMedium
            sLbl.TextSize = 11
            sLbl.TextColor3 = Theme.TextDark
            sLbl.TextXAlignment = Enum.TextXAlignment.Left

            local cont = Instance.new("Frame", sFrame)
            cont.Size = UDim2.new(1, 0, 1, -22)
            cont.Position = UDim2.new(0, 0, 0, 22)
            cont.BackgroundTransparency = 1
            
            local cLayout = Instance.new("UIListLayout", cont)
            cLayout.SortOrder = Enum.SortOrder.LayoutOrder
            cLayout.Padding = UDim.new(0, 4)
            local cPad = Instance.new("UIPadding", cont)
            cPad.PaddingTop = UDim.new(0, 0)
            cPad.PaddingBottom = UDim.new(0, 6)
            cPad.PaddingLeft = UDim.new(0, 6)
            cPad.PaddingRight = UDim.new(0, 6)
            
            cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sFrame.Size = UDim2.new(1, 0, 0, cLayout.AbsoluteContentSize.Y + 28)
            end)

            local Sec = {}
            
            -- TOGGLE
            function Sec:AddToggle(iCfg)
                local val = iCfg.Default or false
                local tf = Instance.new("TextButton", cont)
                tf.Size = UDim2.new(1, 0, 0, 24)
                tf.BackgroundTransparency = 1
                tf.Text = ""
                
                local tl = Instance.new("TextLabel", tf)
                tl.Size = UDim2.new(1, -40, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = iCfg.Title or iCfg.Flag or "Toggle"
                tl.Font = Enum.Font.Gotham
                tl.TextSize = 12
                tl.TextColor3 = Theme.Text
                tl.TextXAlignment = Enum.TextXAlignment.Left
                
                local bg = Instance.new("Frame", tf)
                bg.Size = UDim2.new(0, 28, 0, 14)
                bg.Position = UDim2.new(1, -28, 0.5, -7)
                bg.BackgroundColor3 = val and Theme.Accent or Theme.Background
                Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
                local bs = Instance.new("UIStroke", bg)
                bs.Color = Theme.Outline
                
                local cr = Instance.new("Frame", bg)
                cr.Size = UDim2.new(0, 10, 0, 10)
                cr.Position = UDim2.new(0, val and 16 or 2, 0.5, -5)
                cr.BackgroundColor3 = Color3.fromRGB(240,240,240)
                Instance.new("UICorner", cr).CornerRadius = UDim.new(1, 0)
                
                local function trig(v)
                    val = v
                    TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = val and Theme.Accent or Theme.Background}):Play()
                    TweenService:Create(cr, TweenInfo.new(0.2), {Position = UDim2.new(0, val and 16 or 2, 0.5, -5)}):Play()
                    if iCfg.Callback then task.spawn(function() pcall(iCfg.Callback, val) end) end
                end
                
                tf.MouseButton1Click:Connect(function() trig(not val) end)
                
                local r = { Value = val }
                function r:Set(v) trig(v) end
                return r
            end
            
            -- SLIDER
            function Sec:AddSlider(iCfg)
                local val = iCfg.Default or iCfg.Min or 0
                local min, max = iCfg.Min or 0, iCfg.Max or 100
                
                local sf = Instance.new("Frame", cont)
                sf.Size = UDim2.new(1, 0, 0, 36)
                sf.BackgroundTransparency = 1
                
                local sl = Instance.new("TextLabel", sf)
                sl.Size = UDim2.new(1, -40, 0, 18)
                sl.BackgroundTransparency = 1
                sl.Text = iCfg.Title or "Slider"
                sl.Font = Enum.Font.Gotham
                sl.TextSize = 12
                sl.TextColor3 = Theme.Text
                sl.TextXAlignment = Enum.TextXAlignment.Left
                
                local vl = Instance.new("TextLabel", sf)
                vl.Size = UDim2.new(0, 40, 0, 18)
                vl.Position = UDim2.new(1, -40, 0, 0)
                vl.BackgroundTransparency = 1
                vl.Text = tostring(val)
                vl.Font = Enum.Font.GothamBold
                vl.TextSize = 11
                vl.TextColor3 = Theme.Accent
                vl.TextXAlignment = Enum.TextXAlignment.Right
                
                local tk = Instance.new("TextButton", sf)
                tk.Size = UDim2.new(1, 0, 0, 4)
                tk.Position = UDim2.new(0, 0, 1, -8)
                tk.BackgroundColor3 = Theme.Background
                tk.Text = ""
                Instance.new("UICorner", tk).CornerRadius = UDim.new(1, 0)
                Instance.new("UIStroke", tk).Color = Theme.Outline
                
                local fl = Instance.new("Frame", tk)
                fl.Size = UDim2.new(math.clamp((val-min)/(max-min), 0, 1), 0, 1, 0)
                fl.BackgroundColor3 = Theme.Accent
                fl.BorderSizePixel = 0
                Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
                
                local drag = false
                local function upd(inp)
                    local px = math.clamp((inp.Position.X - tk.AbsolutePosition.X) / tk.AbsoluteSize.X, 0, 1)
                    local cl = math.floor(min + ((max - min) * px))
                    val = cl
                    vl.Text = tostring(val)
                    TweenService:Create(fl, TweenInfo.new(0.1), {Size = UDim2.new(px, 0, 1, 0)}):Play()
                    if iCfg.Callback then task.spawn(function() pcall(iCfg.Callback, val) end) end
                end
                
                tk.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; upd(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
                UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end end)
                
                local r = { Value = val }
                function r:Set(v)
                    val = math.clamp(v, min, max)
                    vl.Text = tostring(val)
                    TweenService:Create(fl, TweenInfo.new(0.1), {Size = UDim2.new((val-min)/(max-min), 0, 1, 0)}):Play()
                    if iCfg.Callback then task.spawn(function() pcall(iCfg.Callback, val) end) end
                end
                return r
            end
            
            -- BUTTON
            function Sec:AddButton(iCfg)
                local b = Instance.new("TextButton", cont)
                b.Size = UDim2.new(1, 0, 0, 24)
                b.BackgroundColor3 = Theme.Background
                b.Text = iCfg.Title or "Button"
                b.Font = Enum.Font.GothamMedium
                b.TextSize = 12
                b.TextColor3 = Theme.Text
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
                Instance.new("UIStroke", b).Color = Theme.Outline
                
                b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play() end)
                b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background}):Play() end)
                b.MouseButton1Click:Connect(function() if iCfg.Callback then task.spawn(function() pcall(iCfg.Callback) end) end end)
                return b
            end

            function Sec:AddDropdown(iCfg)
                local val = iCfg.Default
                local d = Instance.new("TextButton", cont)
                d.Size = UDim2.new(1, 0, 0, 26)
                d.BackgroundColor3 = Theme.Background
                d.Text = ""
                d.ClipsDescendants = true
                Instance.new("UICorner", d).CornerRadius = UDim.new(0, 4)
                Instance.new("UIStroke", d).Color = Theme.Outline
                
                local dl = Instance.new("TextLabel", d)
                dl.Size = UDim2.new(1, -20, 0, 26)
                dl.Position = UDim2.new(0, 6, 0, 0)
                dl.BackgroundTransparency = 1
                dl.Text = (iCfg.Title or "Drop") .. " : " .. tostring(val or "None")
                dl.Font = Enum.Font.Gotham
                dl.TextSize = 12
                dl.TextColor3 = Theme.Text
                dl.TextXAlignment = Enum.TextXAlignment.Left

                local drop = false
                local sf = Instance.new("ScrollingFrame", d)
                sf.Size = UDim2.new(1, 0, 1, -26)
                sf.Position = UDim2.new(0, 0, 0, 26)
                sf.BackgroundTransparency = 1
                sf.ScrollBarThickness = 2
                
                local sl = Instance.new("UIListLayout", sf)
                sl.SortOrder = Enum.SortOrder.LayoutOrder
                
                d.MouseButton1Click:Connect(function()
                    drop = not drop
                    local h = drop and math.min(26 + (sl.AbsoluteContentSize.Y), 120) or 26
                    TweenService:Create(d, TweenInfo.new(0.2), {Size = UDim2.new(1,0,0,h)}):Play()
                end)
                
                local function pop(lst)
                    for _,c in pairs(sf:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                    for _,o in pairs(lst) do
                        local btn = Instance.new("TextButton", sf)
                        btn.Size = UDim2.new(1, 0, 0, 22)
                        btn.BackgroundColor3 = Theme.Background
                        btn.Text = "  " .. tostring(o)
                        btn.Font = Enum.Font.Gotham
                        btn.TextSize = 11
                        btn.TextColor3 = Theme.TextDark
                        btn.TextXAlignment = Enum.TextXAlignment.Left
                        btn.MouseButton1Click:Connect(function()
                            val = o
                            dl.Text = (iCfg.Title or "Drop") .. " : " .. tostring(val)
                            drop = false
                            TweenService:Create(d, TweenInfo.new(0.2), {Size = UDim2.new(1,0,0,26)}):Play()
                            if iCfg.Callback then task.spawn(function() pcall(iCfg.Callback, val) end) end
                        end)
                    end
                    sf.CanvasSize = UDim2.new(0,0,0,sl.AbsoluteContentSize.Y)
                end
                pop(iCfg.Options or {})
                
                local r = { Value = val }
                function r:Set(v) val = v; dl.Text = (iCfg.Title or "Drop") .. " : " .. tostring(v) end
                function r:Refresh(l) pop(l) end
                return r
            end

            function Sec:AddParagraph(iCfg)
                local f = Instance.new("Frame", cont)
                f.Size = UDim2.new(1, 0, 0, 16)
                f.BackgroundTransparency = 1
                local l = Instance.new("TextLabel", f)
                l.Size = UDim2.new(1, 0, 1, 0)
                l.BackgroundTransparency = 1
                l.Text = (iCfg.Title and (iCfg.Title.."\n") or "") .. (iCfg.Content or "")
                l.Font = Enum.Font.Gotham
                l.TextSize = 11
                l.TextColor3 = Theme.TextDark
                l.TextXAlignment = Enum.TextXAlignment.Left
                l.TextWrapped = true
                f.Size = UDim2.new(1, 0, 0, l.TextBounds.Y + 4)
                return {}
            end

            function Sec:AddTabbox(iCfg)
                local lbl = Instance.new("TextLabel", cont)
                lbl.Size = UDim2.new(1, 0, 0, 14)
                lbl.BackgroundTransparency = 1
                lbl.Text = "— " .. (iCfg.Title or "Group") .. " —"
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 10
                lbl.TextColor3 = Theme.Accent
                return Sec
            end
            
            function Sec:AddColorPicker(...) return { Set = function() end } end
            function Sec:AddColorpicker(...) return { Set = function() end } end
            function Sec:AddKeybind(...) return { Set = function() end } end

            return Sec
        end
        return tObj
    end

    function WindowObj:Notify(cfg) NexHubUI:MakeNotify(cfg) end
    function WindowObj:ToggleUI() SG.Enabled = not SG.Enabled end
    function WindowObj:Destroy() SG:Destroy() end

    return WindowObj
end

return NexHubUI
