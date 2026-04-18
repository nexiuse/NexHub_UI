local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local NexHubUI = {}

local Theme = {
    Color = Color3.fromRGB(0, 208, 255),
    Bg = Color3.fromRGB(20, 25, 30),
    Sidebar = Color3.fromRGB(15, 20, 25),
    Element = Color3.fromRGB(25, 30, 35),
    Hover = Color3.fromRGB(35, 40, 45),
    Stroke = Color3.fromRGB(45, 50, 55),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(120, 130, 140)
}

function NexHubUI:Window(cfg)
    local sg = Instance.new("ScreenGui")
    sg.Name = "VelarisClone"
    sg.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui
    
    local Main = Instance.new("Frame", sg)
    Main.Size = cfg.Size or UDim2.fromOffset(680, 450)
    Main.Position = UDim2.new(0.5, -Main.Size.X.Offset/2, 0.5, -Main.Size.Y.Offset/2)
    Main.BackgroundColor3 = Theme.Bg
    Main.BackgroundTransparency = 0.15
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
    local strk = Instance.new("UIStroke", Main)
    strk.Color = Color3.fromRGB(255,255,255)
    strk.Transparency = 0.8
    strk.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Topbar = Instance.new("Frame", Main)
    Topbar.Size = UDim2.new(1, 0, 0, 38)
    Topbar.BackgroundTransparency = 1
    
    local dragging, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local del = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + del.X, startPos.Y.Scale, startPos.Y.Offset + del.Y)
        end
    end)
    
    local TTitle = Instance.new("TextLabel", Topbar)
    TTitle.Size = UDim2.new(0, 200, 1, 0)
    TTitle.Position = UDim2.new(0, 30, 0, 0)
    TTitle.BackgroundTransparency = 1
    TTitle.Text = cfg.Title or "By Nexa"
    TTitle.Font = Enum.Font.GothamBold
    TTitle.TextSize = 13
    TTitle.TextColor3 = Theme.Color
    TTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", Topbar)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.TextColor3 = Theme.TextDark
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 170, 1, -45)
    Sidebar.Position = UDim2.new(0, 5, 0, 40)
    Sidebar.BackgroundTransparency = 1
    
    local search = Instance.new("TextBox", Sidebar)
    search.Size = UDim2.new(1, -10, 0, 26)
    search.Position = UDim2.new(0, 5, 0, 0)
    search.BackgroundColor3 = Theme.Element
    search.Text = ""
    search.PlaceholderText = "Search..."
    search.Font = Enum.Font.Gotham
    search.TextSize = 11
    search.TextColor3 = Theme.Text
    Instance.new("UICorner", search).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", search).Color = Theme.Stroke
    
    local TabScroll = Instance.new("ScrollingFrame", Sidebar)
    TabScroll.Size = UDim2.new(1, 0, 1, -75)
    TabScroll.Position = UDim2.new(0, 0, 0, 32)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    local tl = Instance.new("UIListLayout", TabScroll)
    tl.SortOrder = Enum.SortOrder.LayoutOrder
    tl.Padding = UDim.new(0, 4)
    tl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabScroll.CanvasSize = UDim2.new(0,0,0,tl.AbsoluteContentSize.Y) end)
    
    local ContentFrame = Instance.new("Frame", Main)
    ContentFrame.Size = UDim2.new(1, -185, 1, -45)
    ContentFrame.Position = UDim2.new(0, 180, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    
    local cTitle = Instance.new("TextLabel", ContentFrame)
    cTitle.Size = UDim2.new(1, 0, 0, 20)
    cTitle.BackgroundTransparency = 1
    cTitle.Text = "Content"
    cTitle.Font = Enum.Font.GothamBold
    cTitle.TextSize = 12
    cTitle.TextColor3 = Theme.Color
    
    local PageContainer = Instance.new("Frame", ContentFrame)
    PageContainer.Size = UDim2.new(1, 0, 1, -25)
    PageContainer.Position = UDim2.new(0, 0, 0, 25)
    PageContainer.BackgroundTransparency = 1
    
    local WindowObj = { Tabs = {} }
    
    function WindowObj:AddTab(tcfg)
        local tbtn = Instance.new("TextButton", TabScroll)
        tbtn.Size = UDim2.new(1, -10, 0, 26)
        tbtn.Position = UDim2.new(0, 5, 0, 0)
        tbtn.BackgroundColor3 = Theme.Sidebar
        tbtn.BackgroundTransparency = 1
        tbtn.Text = "  " .. (tcfg.Name or "Tab")
        tbtn.Font = Enum.Font.GothamMedium
        tbtn.TextSize = 12
        tbtn.TextColor3 = Theme.TextDark
        tbtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", tbtn).CornerRadius = UDim.new(0, 4)
        local selInd = Instance.new("Frame", tbtn)
        selInd.Size = UDim2.new(0, 2, 0, 14)
        selInd.Position = UDim2.new(0, 2, 0.5, -7)
        selInd.BackgroundColor3 = Theme.Color
        selInd.BorderSizePixel = 0
        selInd.BackgroundTransparency = 1
        Instance.new("UICorner", selInd).CornerRadius = UDim.new(1, 0)
        
        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Size = UDim2.new(1, -10, 1, -10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 1
        Page.ScrollBarImageColor3 = Theme.Stroke
        Page.Visible = false
        local pl = Instance.new("UIListLayout", Page)
        pl.SortOrder = Enum.SortOrder.LayoutOrder
        pl.Padding = UDim.new(0, 6)
        pl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0,pl.AbsoluteContentSize.Y+15) end)
        
        local tobj = { Btn = tbtn, Page = Page, Ind = selInd }
        table.insert(WindowObj.Tabs, tobj)
        
        tbtn.MouseButton1Click:Connect(function()
            for _,t in ipairs(WindowObj.Tabs) do
                t.Page.Visible = false
                t.Btn.TextColor3 = Theme.TextDark
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                TweenService:Create(t.Ind, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            end
            Page.Visible = true
            tbtn.TextColor3 = Theme.Text
            TweenService:Create(tbtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(selInd, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            cTitle.Text = tcfg.Name or "Content"
        end)
        
        if #WindowObj.Tabs == 1 then
            Page.Visible = true
            tbtn.TextColor3 = Theme.Text
            tbtn.BackgroundTransparency = 0
            selInd.BackgroundTransparency = 0
            cTitle.Text = tcfg.Name or "Content"
        end
        
        function tobj:AddSection(scfg)
            local sTitle = scfg.Title or "Section"
            local sFrame = Instance.new("Frame", Page)
            sFrame.Size = UDim2.new(1, 0, 0, 30)
            sFrame.BackgroundColor3 = Theme.Element
            sFrame.BackgroundTransparency = 0.3
            Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 6)
            local str = Instance.new("UIStroke", sFrame)
            str.Color = Theme.Stroke
            
            local slbl = Instance.new("TextLabel", sFrame)
            slbl.Size = UDim2.new(1, -20, 0, 24)
            slbl.Position = UDim2.new(0, 10, 0, 4)
            slbl.BackgroundTransparency = 1
            slbl.Text = sTitle
            slbl.Font = Enum.Font.GothamBold
            slbl.TextSize = 13
            slbl.TextColor3 = Theme.Text
            slbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local sCont = Instance.new("Frame", sFrame)
            sCont.Size = UDim2.new(1, 0, 1, -30)
            sCont.Position = UDim2.new(0, 0, 0, 30)
            sCont.BackgroundTransparency = 1
            local cl = Instance.new("UIListLayout", sCont)
            cl.SortOrder = Enum.SortOrder.LayoutOrder
            cl.Padding = UDim.new(0, 1)
            
            cl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sFrame.Size = UDim2.new(1, 0, 0, cl.AbsoluteContentSize.Y + 35)
            end)
            
            local Sec = {}
            function Sec:AddToggle(icfg)
                local val = icfg.Default or false
                local tf = Instance.new("TextButton", sCont)
                tf.Size = UDim2.new(1, 0, 0, 28)
                tf.BackgroundTransparency = 1
                tf.Text = ""
                
                local tl = Instance.new("TextLabel", tf)
                tl.Size = UDim2.new(1, -50, 1, 0)
                tl.Position = UDim2.new(0, 15, 0, 0)
                tl.BackgroundTransparency = 1
                tl.Text = icfg.Title or icfg.Flag or "Toggle"
                tl.Font = Enum.Font.GothamMedium
                tl.TextSize = 11
                tl.TextColor3 = Theme.TextDark
                tl.TextXAlignment = Enum.TextXAlignment.Left
                
                local bg = Instance.new("Frame", tf)
                bg.Size = UDim2.new(0, 26, 0, 12)
                bg.Position = UDim2.new(1, -35, 0.5, -6)
                bg.BackgroundColor3 = val and Theme.Color or Theme.Stroke
                Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
                local cr = Instance.new("Frame", bg)
                cr.Size = UDim2.new(0, 10, 0, 10)
                cr.Position = UDim2.new(0, val and 14 or 2, 0.5, -5)
                cr.BackgroundColor3 = Color3.fromRGB(240,240,240)
                Instance.new("UICorner", cr).CornerRadius = UDim.new(1, 0)
                
                tf.MouseButton1Click:Connect(function()
                    val = not val
                    TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = val and Theme.Color or Theme.Stroke}):Play()
                    TweenService:Create(cr, TweenInfo.new(0.2), {Position = UDim2.new(0, val and 14 or 2, 0.5, -5)}):Play()
                    if icfg.Callback then task.spawn(function() pcall(icfg.Callback, val) end) end
                end)
            end
            
            function Sec:AddSlider(icfg)
                local val = icfg.Default or icfg.Min or 0
                local min, max = icfg.Min or 0, icfg.Max or 100
                local sf = Instance.new("Frame", sCont)
                sf.Size = UDim2.new(1, 0, 0, 36)
                sf.BackgroundTransparency = 1
                
                local sl = Instance.new("TextLabel", sf)
                sl.Size = UDim2.new(1, -50, 0, 18)
                sl.Position = UDim2.new(0, 15, 0, 0)
                sl.BackgroundTransparency = 1
                sl.Text = icfg.Title or "Slider"
                sl.Font = Enum.Font.GothamMedium
                sl.TextSize = 11
                sl.TextColor3 = Theme.TextDark
                sl.TextXAlignment = Enum.TextXAlignment.Left
                
                local vl = Instance.new("TextLabel", sf)
                vl.Size = UDim2.new(0, 30, 0, 18)
                vl.Position = UDim2.new(1, -40, 0, 0)
                vl.BackgroundTransparency = 1
                vl.Text = tostring(val)
                vl.Font = Enum.Font.GothamBold
                vl.TextSize = 10
                vl.TextColor3 = Theme.Color
                vl.TextXAlignment = Enum.TextXAlignment.Right
                
                local tk = Instance.new("TextButton", sf)
                tk.Size = UDim2.new(1, -30, 0, 3)
                tk.Position = UDim2.new(0, 15, 1, -10)
                tk.BackgroundColor3 = Theme.Stroke
                tk.Text = ""
                Instance.new("UICorner", tk).CornerRadius = UDim.new(1, 0)
                
                local fl = Instance.new("Frame", tk)
                fl.Size = UDim2.new(math.clamp((val-min)/(max-min), 0, 1), 0, 1, 0)
                fl.BackgroundColor3 = Theme.Color
                Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
                
                local drag = false
                local function upd(i)
                    local px = math.clamp((i.Position.X - tk.AbsolutePosition.X) / tk.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + ((max - min) * px))
                    vl.Text = tostring(val)
                    fl.Size = UDim2.new(px, 0, 1, 0)
                    if icfg.Callback then pcall(icfg.Callback, val) end
                end
                tk.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; upd(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
                UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end end)
            end
            
            function Sec:AddButton(icfg)
                local b = Instance.new("TextButton", sCont)
                b.Size = UDim2.new(1, -20, 0, 26)
                b.Position = UDim2.new(0, 10, 0, 0)
                b.BackgroundColor3 = Theme.Hover
                b.Text = icfg.Title or "Button"
                b.Font = Enum.Font.GothamMedium
                b.TextSize = 11
                b.TextColor3 = Theme.Text
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
                Instance.new("UIStroke", b).Color = Theme.Stroke
                local pw = Instance.new("Frame", sCont); pw.Size = UDim2.new(1,0,0,4); pw.BackgroundTransparency = 1
                b.MouseButton1Click:Connect(function() if icfg.Callback then pcall(icfg.Callback) end end)
            end
            
            function Sec:AddDropdown(icfg)
                local val = icfg.Default
                local d = Instance.new("TextButton", sCont)
                d.Size = UDim2.new(1, -20, 0, 26)
                d.Position = UDim2.new(0, 10, 0, 0)
                d.BackgroundColor3 = Theme.Hover
                d.Text = "  " .. (icfg.Title or "Drop") .. " - " .. tostring(val or "...")
                d.Font = Enum.Font.GothamMedium
                d.TextSize = 11
                d.TextColor3 = Theme.TextDark
                d.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", d).CornerRadius = UDim.new(0, 4)
                Instance.new("UIStroke", d).Color = Theme.Stroke
                local pw = Instance.new("Frame", sCont); pw.Size = UDim2.new(1,0,0,4); pw.BackgroundTransparency = 1
                d.MouseButton1Click:Connect(function() if icfg.Callback then pcall(icfg.Callback, val) end end)
                return { Refresh = function(opts) end, Set = function(v) end }
            end

            -- Aliases for Velaris Adapter
            function Sec:AddTabbox(cfg) return Sec end
            function Sec:AddParagraph(cfg) return Sec end
            function Sec:AddColorpicker(cfg) return {Set = function() end} end
            function Sec:AddColorPicker(cfg) return {Set = function() end} end
            function Sec:AddKeybind(cfg) return {Set = function() end} end
            
            return Sec
        end
        return tobj
    end
    
    function WindowObj:ToggleUI() sg.Enabled = not sg.Enabled end
    function WindowObj:Notify(...) end
    function WindowObj:Dialog(...) end
    return WindowObj
end
return NexHubUI
