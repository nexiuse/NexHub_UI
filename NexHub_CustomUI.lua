local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local NexHubUI = {}

-- Config / Theme
local Theme = {
    Background = Color3.fromRGB(20, 20, 24),
    Topbar = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(138, 43, 226), -- Muted Purple
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    Element = Color3.fromRGB(30, 30, 35),
    ElementHover = Color3.fromRGB(40, 40, 45),
    Outline = Color3.fromRGB(45, 45, 50),
}

function NexHubUI:AddTheme(cfg)
    -- Allows overriding accent if needed, but we keep our purple default
    if cfg.Accent then
        -- We won't strictly enforce if they pass something, but we can store it.
    end
end

-- ==========================================
-- Utility: Draggable
-- ==========================================
local function MakeDraggable(topbar, frame)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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
            TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

-- ==========================================
-- System: Notifications
-- ==========================================
local NotificationContainer
function NexHubUI:MakeNotify(cfg)
    local title = cfg.Title or "Notification"
    local content = cfg.Content or ""
    local duration = cfg.Duration or 3

    if not NotificationContainer then
        local targetParent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui
        local ui = Instance.new("ScreenGui")
        ui.Name = "NexHubNotifications"
        ui.Parent = targetParent

        NotificationContainer = Instance.new("Frame")
        NotificationContainer.Name = "Container"
        NotificationContainer.BackgroundTransparency = 1
        NotificationContainer.Size = UDim2.new(0, 300, 1, -20)
        NotificationContainer.Position = UDim2.new(1, -320, 0, 20)
        NotificationContainer.Parent = ui

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Padding = UDim.new(0, 10)
        layout.Parent = NotificationContainer
    end

    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(1, 0, 0, 60)
    Notif.BackgroundColor3 = Theme.Background
    Notif.BorderSizePixel = 0
    Notif.Parent = NotificationContainer

    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", Notif)
    stroke.Color = Theme.Outline
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local AccentBar = Instance.new("Frame")
    AccentBar.Size = UDim2.new(0, 4, 1, -12)
    AccentBar.Position = UDim2.new(0, 6, 0, 6)
    AccentBar.BackgroundColor3 = Theme.Accent
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = Notif
    Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(1, 0)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -30, 0, 20)
    TitleLbl.Position = UDim2.new(0, 20, 0, 8)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 14
    TitleLbl.TextColor3 = Theme.Text
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = Notif

    local DescLbl = Instance.new("TextLabel")
    DescLbl.Size = UDim2.new(1, -30, 0, 20)
    DescLbl.Position = UDim2.new(0, 20, 0, 28)
    DescLbl.BackgroundTransparency = 1
    DescLbl.Text = content
    DescLbl.Font = Enum.Font.Gotham
    DescLbl.TextSize = 12
    DescLbl.TextColor3 = Theme.TextDark
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    DescLbl.TextWrapped = true
    DescLbl.Parent = Notif

    -- Anim
    Notif.Position = UDim2.new(1, 50, 0, 0)
    Notif.BackgroundTransparency = 1
    TitleLbl.TextTransparency = 1
    DescLbl.TextTransparency = 1
    AccentBar.BackgroundTransparency = 1
    stroke.Transparency = 1

    TweenService:Create(Notif, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}):Play()
    TweenService:Create(TitleLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(DescLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(AccentBar, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()

    task.spawn(function()
        task.wait(duration)
        TweenService:Create(Notif, TweenInfo.new(0.3), {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}):Play()
        TweenService:Create(TitleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(DescLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(AccentBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        task.wait(0.3)
        Notif:Destroy()
    end)
end

-- ==========================================
-- Window Builder
-- ==========================================
function NexHubUI:Window(cfg)
    local WindowTitle = cfg.Title or "NexHub UI"
    local WindowSize = cfg.Size or UDim2.fromOffset(640, 480)
    local KeySystemData = cfg.KeySystem

    local targetParent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexHub_UI_" .. tostring(math.random(100, 999))
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = targetParent

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = WindowSize
    Main.Position = UDim2.new(0.5, -WindowSize.X.Offset/2, 0.5, -WindowSize.Y.Offset/2)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local border = Instance.new("UIStroke", Main)
    border.Color = Theme.Outline
    border.Thickness = 1.2
    
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Position = UDim2.new(0, 0, 1, 0)
    sep.BackgroundColor3 = Theme.Outline
    sep.BorderSizePixel = 0
    sep.Parent = Topbar

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -20, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = WindowTitle
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 14
    TitleText.TextColor3 = Theme.Accent
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = Topbar

    MakeDraggable(Topbar, Main)

    local WindowObj = {
        GUI = ScreenGui,
        Tabs = {},
        ActiveTab = nil,
        ContentContainer = nil,
        TabContainer = nil
    }

    function WindowObj:Destroy()
        ScreenGui:Destroy()
    end

    -- ==========================================
    -- Key System Handling
    -- ==========================================
    if KeySystemData then
        local KeyFrame = Instance.new("Frame")
        KeyFrame.Size = UDim2.new(1, 0, 1, -40)
        KeyFrame.Position = UDim2.new(0, 0, 0, 40)
        KeyFrame.BackgroundTransparency = 1
        KeyFrame.Parent = Main

        local TitleKS = Instance.new("TextLabel")
        TitleKS.Size = UDim2.new(1, 0, 0, 30)
        TitleKS.Position = UDim2.new(0, 0, 0, 20)
        TitleKS.Text = KeySystemData.Title or "Authentication"
        TitleKS.Font = Enum.Font.GothamBold
        TitleKS.TextSize = 18
        TitleKS.TextColor3 = Theme.Text
        TitleKS.BackgroundTransparency = 1
        TitleKS.Parent = KeyFrame

        local InputKS = Instance.new("TextBox")
        InputKS.Size = UDim2.new(0, 250, 0, 35)
        InputKS.Position = UDim2.new(0.5, -125, 0.5, -30)
        InputKS.BackgroundColor3 = Theme.Element
        InputKS.PlaceholderText = KeySystemData.Placeholder or "Enter Key..."
        InputKS.Text = ""
        InputKS.TextColor3 = Theme.Text
        InputKS.Font = Enum.Font.Gotham
        InputKS.TextSize = 14
        InputKS.Parent = KeyFrame
        Instance.new("UICorner", InputKS).CornerRadius = UDim.new(0, 6)
        local istroke = Instance.new("UIStroke", InputKS)
        istroke.Color = Theme.Outline
        istroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local SubmitBtn = Instance.new("TextButton")
        SubmitBtn.Size = UDim2.new(0, 150, 0, 35)
        SubmitBtn.Position = UDim2.new(0.5, -75, 0.5, 20)
        SubmitBtn.BackgroundColor3 = Theme.Accent
        SubmitBtn.Text = "Verify"
        SubmitBtn.Font = Enum.Font.GothamBold
        SubmitBtn.TextSize = 14
        SubmitBtn.TextColor3 = Color3.fromRGB(255,255,255)
        SubmitBtn.Parent = KeyFrame
        Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)

        SubmitBtn.MouseButton1Click:Connect(function()
            SubmitBtn.Text = "Checking..."
            local isValid = false
            if type(KeySystemData.Callback) == "function" then
                isValid = KeySystemData.Callback(InputKS.Text)
            end
            if not isValid then
                SubmitBtn.Text = "Invalid Key!"
                task.wait(1)
                SubmitBtn.Text = "Verify"
            end
        end)
        
        -- If it's just a loader window, we return it to let loader handle destruction
        return WindowObj
    end

    -- ==========================================
    -- Main Window Setup (Tabs & Content)
    -- ==========================================
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 140, 1, -40)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Main
    WindowObj.TabContainer = TabContainer

    local tabLayout = Instance.new("UIListLayout", TabContainer)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)

    local tabPad = Instance.new("UIPadding", TabContainer)
    tabPad.PaddingTop = UDim.new(0, 10)
    tabPad.PaddingLeft = UDim.new(0, 10)
    tabPad.PaddingRight = UDim.new(0, 10)

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -145, 1, -45)
    ContentContainer.Position = UDim2.new(0, 145, 0, 45)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = Main
    WindowObj.ContentContainer = ContentContainer

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 1, 1, -40)
    line.Position = UDim2.new(0, 140, 0, 40)
    line.BackgroundColor3 = Theme.Outline
    line.BorderSizePixel = 0
    line.Parent = Main

    -- ==========================================
    -- API: AddTab
    -- ==========================================
    function WindowObj:AddTab(cfg)
        local tName = cfg.Title or cfg.Name or "Tab"
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.BackgroundColor3 = Theme.Background
        TabBtn.Text = "  " .. tName
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 13
        TabBtn.TextColor3 = Theme.TextDark
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabContainer

        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Visible = false
        Page.Parent = ContentContainer

        -- Layout for page (Left and Right columns if needed, or simple list)
        -- We'll do a simple list but wrap it nicely
        local pageLayout = Instance.new("UIListLayout", Page)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 10)
        
        local pPad = Instance.new("UIPadding", Page)
        pPad.PaddingTop = UDim.new(0, 5)
        pPad.PaddingLeft = UDim.new(0, 5)
        pPad.PaddingRight = UDim.new(0, 5)
        pPad.PaddingBottom = UDim.new(0, 20)

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
        end)

        local TabObj = {
            Button = TabBtn,
            Page = Page
        }

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(WindowObj.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background, TextColor3 = Theme.TextDark}):Play()
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element, TextColor3 = Theme.Accent}):Play()
        end)

        table.insert(WindowObj.Tabs, TabObj)
        if #WindowObj.Tabs == 1 then
            Page.Visible = true
            TabBtn.BackgroundColor3 = Theme.Element
            TabBtn.TextColor3 = Theme.Accent
        end

        -- ==========================================
        -- API: AddSection inside Tab
        -- ==========================================
        function TabObj:AddSection(sCfg)
            local sTitle = sCfg.Title or "Section"
            
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, 0, 0, 0) -- auto height
            SecFrame.BackgroundColor3 = Theme.Background
            SecFrame.Parent = Page
            
            Instance.new("UICorner", SecFrame).CornerRadius = UDim.new(0, 6)
            local sstroke = Instance.new("UIStroke", SecFrame)
            sstroke.Color = Theme.Outline
            sstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local sLbl = Instance.new("TextLabel")
            sLbl.Size = UDim2.new(1, -20, 0, 25)
            sLbl.Position = UDim2.new(0, 10, 0, 5)
            sLbl.BackgroundTransparency = 1
            sLbl.Text = sTitle
            sLbl.Font = Enum.Font.GothamBold
            sLbl.TextSize = 13
            sLbl.TextColor3 = Theme.Text
            sLbl.TextXAlignment = Enum.TextXAlignment.Left
            sLbl.Parent = SecFrame

            local sLayout = Instance.new("UIListLayout", SecFrame)
            sLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sLayout.Padding = UDim.new(0, 5)
            
            local sPad = Instance.new("UIPadding", SecFrame)
            sPad.PaddingTop = UDim.new(0, 30)
            sPad.PaddingLeft = UDim.new(0, 10)
            sPad.PaddingRight = UDim.new(0, 10)
            sPad.PaddingBottom = UDim.new(0, 10)

            sLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SecFrame.Size = UDim2.new(1, 0, 0, sLayout.AbsoluteContentSize.Y + 40)
            end)

            local SecObj = {}

            -- ==========================================
            -- API: AddToggle
            -- ==========================================
            function SecObj:AddToggle(opts)
                local tTitle = opts.Title or opts.Flag or "Toggle"
                local def = opts.Default or false
                local cb = opts.Callback or function() end
                local Toggle = { Value = def }

                local tFrame = Instance.new("TextButton")
                tFrame.Size = UDim2.new(1, 0, 0, 35)
                tFrame.BackgroundColor3 = Theme.Element
                tFrame.Text = ""
                tFrame.AutoButtonColor = false
                tFrame.Parent = SecFrame
                Instance.new("UICorner", tFrame).CornerRadius = UDim.new(0, 4)

                local tLbl = Instance.new("TextLabel")
                tLbl.Size = UDim2.new(1, -40, 1, 0)
                tLbl.Position = UDim2.new(0, 10, 0, 0)
                tLbl.BackgroundTransparency = 1
                tLbl.Text = tTitle
                tLbl.Font = Enum.Font.Gotham
                tLbl.TextSize = 13
                tLbl.TextColor3 = Theme.Text
                tLbl.TextXAlignment = Enum.TextXAlignment.Left
                tLbl.Parent = tFrame

                local Box = Instance.new("Frame")
                Box.Size = UDim2.new(0, 20, 0, 20)
                Box.Position = UDim2.new(1, -30, 0.5, -10)
                Box.BackgroundColor3 = def and Theme.Accent or Theme.Background
                Box.Parent = tFrame
                Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
                local bstroke = Instance.new("UIStroke", Box)
                bstroke.Color = Theme.Outline

                local function trigger(val)
                    Toggle.Value = val
                    TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = val and Theme.Accent or Theme.Background}):Play()
                    task.spawn(function() pcall(cb, val) end)
                end

                tFrame.MouseButton1Click:Connect(function()
                    trigger(not Toggle.Value)
                end)

                function Toggle:Set(v)
                    trigger(v)
                end

                return Toggle
            end

            -- ==========================================
            -- API: AddButton
            -- ==========================================
            function SecObj:AddButton(opts)
                local bTitle = opts.Title or "Button"
                local cb = opts.Callback or function() end

                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 35)
                btn.BackgroundColor3 = Theme.Element
                btn.Text = bTitle
                btn.Font = Enum.Font.GothamSemibold
                btn.TextSize = 13
                btn.TextColor3 = Theme.Text
                btn.AutoButtonColor = false
                btn.Parent = SecFrame
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                local bstr = Instance.new("UIStroke", btn)
                bstr.Color = Theme.Outline

                btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play() end)
                btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play() end)
                btn.MouseButton1Click:Connect(function()
                    local circle = Instance.new("Frame")
                    circle.Size = UDim2.new(0,0,0,0)
                    circle.Position = UDim2.new(0.5,0,0.5,0)
                    circle.AnchorPoint = Vector2.new(0.5,0.5)
                    circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
                    circle.BackgroundTransparency = 0.8
                    circle.Parent = btn
                    Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)
                    TweenService:Create(circle, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 4, 0), BackgroundTransparency = 1}):Play()
                    task.spawn(function() pcall(cb) end)
                    task.delay(0.4, function() circle:Destroy() end)
                end)
                return btn
            end

            -- ==========================================
            -- API: AddSlider
            -- ==========================================
            function SecObj:AddSlider(opts)
                local sTitle = opts.Title or "Slider"
                local min = opts.Min or 0
                local max = opts.Max or 100
                local def = opts.Default or min
                local cb = opts.Callback or function() end
                local Slider = { Value = def }

                local sFrame = Instance.new("Frame")
                sFrame.Size = UDim2.new(1, 0, 0, 50)
                sFrame.BackgroundColor3 = Theme.Element
                sFrame.Parent = SecFrame
                Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 4)

                local sLbl = Instance.new("TextLabel")
                sLbl.Size = UDim2.new(1, -50, 0, 20)
                sLbl.Position = UDim2.new(0, 10, 0, 5)
                sLbl.BackgroundTransparency = 1
                sLbl.Text = sTitle
                sLbl.Font = Enum.Font.Gotham
                sLbl.TextSize = 13
                sLbl.TextColor3 = Theme.Text
                sLbl.TextXAlignment = Enum.TextXAlignment.Left
                sLbl.Parent = sFrame

                local vLbl = Instance.new("TextLabel")
                vLbl.Size = UDim2.new(0, 40, 0, 20)
                vLbl.Position = UDim2.new(1, -50, 0, 5)
                vLbl.BackgroundTransparency = 1
                vLbl.Text = tostring(def)
                vLbl.Font = Enum.Font.GothamBold
                vLbl.TextSize = 13
                vLbl.TextColor3 = Theme.Accent
                vLbl.TextXAlignment = Enum.TextXAlignment.Right
                vLbl.Parent = sFrame

                local track = Instance.new("TextButton")
                track.Size = UDim2.new(1, -20, 0, 6)
                track.Position = UDim2.new(0, 10, 0, 35)
                track.BackgroundColor3 = Theme.Background
                track.Text = ""
                track.AutoButtonColor = false
                track.Parent = sFrame
                Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(math.clamp((def - min) / (max - min), 0, 1), 0, 1, 0)
                fill.BackgroundColor3 = Theme.Accent
                fill.BorderSizePixel = 0
                fill.Parent = track
                Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

                local dragging = false
                local function update(input)
                    local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + ((max - min) * percent))
                    Slider.Value = val
                    vLbl.Text = tostring(val)
                    TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                    task.spawn(function() pcall(cb, val) end)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        update(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        update(input)
                    end
                end)

                function Slider:Set(v)
                    v = math.clamp(v, min, max)
                    Slider.Value = v
                    vLbl.Text = tostring(v)
                    TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new((v - min)/(max - min), 0, 1, 0)}):Play()
                    task.spawn(function() pcall(cb, v) end)
                end

                return Slider
            end

            -- ==========================================
            -- API: AddDropdown
            -- ==========================================
            function SecObj:AddDropdown(opts)
                local dTitle = opts.Title or "Dropdown"
                local List = opts.Options or {}
                local cb = opts.Callback or function() end
                local Dropdown = { Value = opts.Default }
                
                local dFrame = Instance.new("TextButton")
                dFrame.Size = UDim2.new(1, 0, 0, 35) -- collapsed
                dFrame.BackgroundColor3 = Theme.Element
                dFrame.Text = ""
                dFrame.AutoButtonColor = false
                dFrame.ClipsDescendants = true
                dFrame.Parent = SecFrame
                Instance.new("UICorner", dFrame).CornerRadius = UDim.new(0, 4)

                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, -40, 0, 35)
                Lbl.Position = UDim2.new(0, 10, 0, 0)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = dTitle .. " : " .. (opts.Default and tostring(opts.Default) or "None")
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 13
                Lbl.TextColor3 = Theme.Text
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = dFrame

                local Icon = Instance.new("TextLabel")
                Icon.Size = UDim2.new(0, 20, 0, 35)
                Icon.Position = UDim2.new(1, -30, 0, 0)
                Icon.BackgroundTransparency = 1
                Icon.Text = "+"
                Icon.Font = Enum.Font.GothamBold
                Icon.TextSize = 16
                Icon.TextColor3 = Theme.TextDark
                Icon.Parent = dFrame

                local dScroll = Instance.new("ScrollingFrame")
                dScroll.Size = UDim2.new(1, -10, 0, 100)
                dScroll.Position = UDim2.new(0, 5, 0, 40)
                dScroll.BackgroundTransparency = 1
                dScroll.ScrollBarThickness = 2
                dScroll.ScrollBarImageColor3 = Theme.Accent
                dScroll.Parent = dFrame

                local dsLayout = Instance.new("UIListLayout", dScroll)
                dsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                dsLayout.Padding = UDim.new(0, 2)

                local isOpen = false
                local function toggleDrop()
                    isOpen = not isOpen
                    Icon.Text = isOpen and "-" or "+"
                    local targetH = isOpen and math.min(35 + (dsLayout.AbsoluteContentSize.Y) + 10, 150) or 35
                    TweenService:Create(dFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetH)}):Play()
                end
                dFrame.MouseButton1Click:Connect(toggleDrop)

                local function populate(options)
                    for _, child in ipairs(dScroll:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, -10, 0, 25)
                        btn.BackgroundColor3 = Theme.Background
                        btn.Text = tostring(opt)
                        btn.Font = Enum.Font.Gotham
                        btn.TextSize = 12
                        btn.TextColor3 = Theme.Text
                        btn.Parent = dScroll
                        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

                        btn.MouseButton1Click:Connect(function()
                            Dropdown.Value = opt
                            Lbl.Text = dTitle .. " : " .. tostring(opt)
                            task.spawn(function() pcall(cb, opt) end)
                            toggleDrop()
                        end)
                    end
                    dScroll.CanvasSize = UDim2.new(0, 0, 0, dsLayout.AbsoluteContentSize.Y)
                end
                populate(List)

                function Dropdown:Set(val)
                    Dropdown.Value = val
                    Lbl.Text = dTitle .. " : " .. tostring(val)
                    task.spawn(function() pcall(cb, val) end)
                end
                function Dropdown:Refresh(newList)
                    populate(newList)
                end

                return Dropdown
            end

            -- ==========================================
            -- API: AddParagraph / Label
            -- ==========================================
            function SecObj:AddParagraph(opts)
                local pTitle = opts.Title or ""
                local text = opts.Content or ""

                local pFrame = Instance.new("Frame")
                pFrame.Size = UDim2.new(1, 0, 0, 20) -- auto height
                pFrame.BackgroundTransparency = 1
                pFrame.Parent = SecFrame

                local pLbl = Instance.new("TextLabel")
                pLbl.Size = UDim2.new(1, -20, 1, 0)
                pLbl.Position = UDim2.new(0, 10, 0, 0)
                pLbl.BackgroundTransparency = 1
                pLbl.Text = (pTitle ~= "" and (pTitle .. "\n") or "") .. text
                pLbl.Font = Enum.Font.Gotham
                pLbl.TextSize = 12
                pLbl.TextColor3 = Theme.TextDark
                pLbl.TextXAlignment = Enum.TextXAlignment.Left
                pLbl.TextYAlignment = Enum.TextYAlignment.Top
                pLbl.TextWrapped = true
                pLbl.Parent = pFrame
                
                -- Adjust height
                local h = pLbl.TextBounds.Y
                pFrame.Size = UDim2.new(1, 0, 0, h + 10)
                
                return {}
            end

            -- ==========================================
            -- API: AddTabbox (Simulated Grouping)
            -- ==========================================
            function SecObj:AddTabbox(opts)
                local tTitle = opts.Title or "Group"
                
                local sepFrame = Instance.new("Frame")
                sepFrame.Size = UDim2.new(1, 0, 0, 20)
                sepFrame.BackgroundTransparency = 1
                sepFrame.Parent = SecFrame
                
                local sepLbl = Instance.new("TextLabel")
                sepLbl.Size = UDim2.new(1, -10, 1, 0)
                sepLbl.Position = UDim2.new(0, 5, 0, 5)
                sepLbl.BackgroundTransparency = 1
                sepLbl.Text = "— " .. tTitle .. " —"
                sepLbl.Font = Enum.Font.GothamBold
                sepLbl.TextSize = 12
                sepLbl.TextColor3 = Theme.Accent
                sepLbl.TextXAlignment = Enum.TextXAlignment.Center
                sepLbl.Parent = sepFrame

                return SecObj
            end
            
            -- ==========================================
            -- API: AddColorpicker / AddKeybind (Dummies to prevent nil calls)
            -- ==========================================
            function SecObj:AddColorPicker(...) return { Set = function() end } end
            function SecObj:AddColorpicker(...) return { Set = function() end } end
            function SecObj:AddKeybind(...) return { Set = function() end } end

            return SecObj
        end
        
        return TabObj
    end

    -- Fix for some script's adapter format
    function WindowObj:ToggleUI()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
    
    function WindowObj:Notify(cfg)
        NexHubUI:MakeNotify(cfg)
    end

    return WindowObj
end

return NexHubUI
