local Horizon = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

Horizon.Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(100, 120, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(50, 50, 55),
    },
    Ocean = {
        Background = Color3.fromRGB(15, 25, 35),
        Secondary = Color3.fromRGB(25, 35, 50),
        Accent = Color3.fromRGB(50, 150, 200),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(150, 180, 200),
        Border = Color3.fromRGB(40, 60, 80),
    },
    Crimson = {
        Background = Color3.fromRGB(25, 15, 15),
        Secondary = Color3.fromRGB(35, 20, 20),
        Accent = Color3.fromRGB(200, 50, 80),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 150, 150),
        Border = Color3.fromRGB(60, 30, 40),
    },
    Forest = {
        Background = Color3.fromRGB(15, 25, 15),
        Secondary = Color3.fromRGB(20, 35, 20),
        Accent = Color3.fromRGB(80, 200, 100),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(150, 200, 150),
        Border = Color3.fromRGB(40, 60, 40),
    },
    Purple = {
        Background = Color3.fromRGB(20, 15, 30),
        Secondary = Color3.fromRGB(30, 20, 45),
        Accent = Color3.fromRGB(150, 100, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 150, 220),
        Border = Color3.fromRGB(50, 40, 70),
    },
    Midnight = {
        Background = Color3.fromRGB(10, 10, 15),
        Secondary = Color3.fromRGB(15, 15, 25),
        Accent = Color3.fromRGB(80, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(160, 160, 180),
        Border = Color3.fromRGB(30, 30, 40),
    },
    Sunset = {
        Background = Color3.fromRGB(30, 20, 15),
        Secondary = Color3.fromRGB(40, 25, 20),
        Accent = Color3.fromRGB(255, 140, 60),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(220, 180, 150),
        Border = Color3.fromRGB(60, 40, 30),
    },
    Aqua = {
        Background = Color3.fromRGB(10, 25, 25),
        Secondary = Color3.fromRGB(15, 35, 35),
        Accent = Color3.fromRGB(50, 200, 200),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(150, 200, 200),
        Border = Color3.fromRGB(30, 50, 50),
    },
    Rose = {
        Background = Color3.fromRGB(25, 15, 20),
        Secondary = Color3.fromRGB(35, 20, 30),
        Accent = Color3.fromRGB(255, 100, 150),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(220, 170, 190),
        Border = Color3.fromRGB(50, 30, 40),
    },
}

function Horizon:RegisterTheme(name, colors)
    if type(name) ~= "string" then
        warn("Horizon: Theme name must be a string")
        return false
    end
    
    if type(colors) ~= "table" then
        warn("Horizon: Theme colors must be a table")
        return false
    end
    
    local requiredKeys = {"Background", "Secondary", "Accent", "Text", "SubText", "Border"}
    for _, key in pairs(requiredKeys) do
        if not colors[key] then
            warn("Horizon: Theme missing required color: " .. key)
            return false
        end
    end
    
    Horizon.Themes[name] = colors
    return true
end

function Horizon:GetThemes()
    local themeList = {}
    for name, _ in pairs(Horizon.Themes) do
        table.insert(themeList, name)
    end
    table.sort(themeList)
    return themeList
end

local CurrentTheme = Horizon.Themes.Dark
local CurrentThemeName = "Dark"

local function MakeDraggable(frame, dragArea)
    local dragging = false
    local dragInput, mousePos, framePos

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

local function MakeResizable(frame)
    local resizing = false
    local resizeInput, startPos, startSize

    local ResizeHandle = Instance.new("Frame")
    ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
    ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
    ResizeHandle.BackgroundColor3 = CurrentTheme.Accent
    ResizeHandle.BackgroundTransparency = 0.7
    ResizeHandle.BorderSizePixel = 0
    ResizeHandle.ZIndex = 10
    ResizeHandle.Parent = frame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = ResizeHandle

    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startPos = input.Position
            startSize = frame.Size
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startPos
            local newSize = UDim2.new(
                startSize.X.Scale,
                math.max(400, startSize.X.Offset + delta.X),
                startSize.Y.Scale,
                math.max(300, startSize.Y.Offset + delta.Y)
            )
            frame.Size = newSize
        end
    end)

    return ResizeHandle
end

local function CreateUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or CurrentTheme.Border
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function Horizon:CreateWindow(config)
    local WindowConfig = {
        Name = config.Name or "Horizon",
        Theme = config.Theme or "Dark",
        Size = config.Size or UDim2.new(0, 550, 0, 400),
        Position = config.Position or UDim2.new(0.5, -275, 0.5, -200),
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl,
        SaveConfig = config.SaveConfig or false,
        ConfigFolder = config.ConfigFolder or "HorizonUI",
        Resizable = config.Resizable ~= false,
    }

    CurrentTheme = Horizon.Themes[WindowConfig.Theme] or Horizon.Themes.Dark
    CurrentThemeName = WindowConfig.Theme

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HorizonUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game.CoreGui

    local LoadingScreen = Instance.new("Frame")
    LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
    LoadingScreen.BackgroundTransparency = 1
    LoadingScreen.BorderSizePixel = 0
    LoadingScreen.ZIndex = 100
    LoadingScreen.Parent = ScreenGui

    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 1000, 0, 1000)
    Logo.Position = UDim2.new(0.5, -500, 0.5, -500)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://100688931675624"
    Logo.ImageTransparency = 1
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.ZIndex = 101
    Logo.Parent = LoadingScreen

    local LoadingText = Instance.new("TextLabel")
    LoadingText.Size = UDim2.new(0, 400, 0, 50)
    LoadingText.Position = UDim2.new(0.5, -200, 0.65, 0)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Text = "Horizon UI Library"
    LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingText.TextTransparency = 1
    LoadingText.TextSize = 28
    LoadingText.Font = Enum.Font.GothamBold
    LoadingText.ZIndex = 101
    LoadingText.Parent = LoadingScreen

    local LoadingSubText = Instance.new("TextLabel")
    LoadingSubText.Size = UDim2.new(0, 400, 0, 30)
    LoadingSubText.Position = UDim2.new(0.5, -200, 0.7, 0)
    LoadingSubText.BackgroundTransparency = 1
    LoadingSubText.Text = "Loading..."
    LoadingSubText.TextColor3 = Color3.fromRGB(180, 180, 180)
    LoadingSubText.TextTransparency = 1
    LoadingSubText.TextSize = 16
    LoadingSubText.Font = Enum.Font.Gotham
    LoadingSubText.ZIndex = 101
    LoadingSubText.Parent = LoadingScreen

    TweenService:Create(Logo, TweenInfo.new(1, Enum.EasingStyle.Quad), {ImageTransparency = 0}):Play()
    wait(0.5)
    TweenService:Create(LoadingText, TweenInfo.new(1, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    wait(0.3)
    TweenService:Create(LoadingSubText, TweenInfo.new(1, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    wait(1.5)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = WindowConfig.Size
    MainFrame.Position = WindowConfig.Position
    MainFrame.BackgroundColor3 = CurrentTheme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    CreateUICorner(MainFrame, 10)
    local MainStroke = CreateStroke(MainFrame, 1, CurrentTheme.Border)

    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = CurrentTheme.Secondary
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    CreateUICorner(TopBar, 10)

    local TopBarFix = Instance.new("Frame")
    TopBarFix.Size = UDim2.new(1, 0, 0, 10)
    TopBarFix.Position = UDim2.new(0, 0, 1, -10)
    TopBarFix.BackgroundColor3 = CurrentTheme.Secondary
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Parent = TopBar

    local TitleIcon = Instance.new("ImageLabel")
    TitleIcon.Size = UDim2.new(0, 125, 0, 125)
    TitleIcon.Position = UDim2.new(0, -40, 0, -42)
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.Image = "rbxassetid://100688931675624"
    TitleIcon.ScaleType = Enum.ScaleType.Fit
    TitleIcon.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 50, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = WindowConfig.Name
    Title.TextColor3 = CurrentTheme.Text
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = CurrentTheme.Secondary
    CloseButton.Text = "×"
    CloseButton.TextColor3 = CurrentTheme.Text
    CloseButton.TextSize = 20
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TopBar
    CreateUICorner(CloseButton, 6)

    CloseButton.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        closeTween:Play()
        closeTween.Completed:Wait()
        ScreenGui:Destroy()
    end)

    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Accent}):Play()
    end)

    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Secondary}):Play()
    end)

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
    MinimizeButton.BackgroundColor3 = CurrentTheme.Secondary
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = CurrentTheme.Text
    MinimizeButton.TextSize = 20
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Parent = TopBar
    CreateUICorner(MinimizeButton, 6)

    local Minimized = false
    local OriginalSize = WindowConfig.Size

    MinimizeButton.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 550, 0, 45)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = OriginalSize}):Play()
        end
    end)

    MinimizeButton.MouseEnter:Connect(function()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Accent}):Play()
    end)

    MinimizeButton.MouseLeave:Connect(function()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Secondary}):Play()
    end)

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 150, 1, -50)
    TabContainer.Position = UDim2.new(0, 10, 0, 45)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabContainer

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -175, 1, -50)
    ContentContainer.Position = UDim2.new(0, 165, 0, 45)
    ContentContainer.BackgroundColor3 = CurrentTheme.Secondary
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame
    CreateUICorner(ContentContainer, 8)
    local ContentStroke = CreateStroke(ContentContainer, 1, CurrentTheme.Border)

    MakeDraggable(MainFrame, TopBar)

    local ResizeHandle
    if WindowConfig.Resizable then
        ResizeHandle = MakeResizable(MainFrame)
    end

    TweenService:Create(Logo, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {ImageTransparency = 1}):Play()
    TweenService:Create(LoadingText, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
    TweenService:Create(LoadingSubText, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
    
    wait(0.6)
    LoadingScreen:Destroy()

    local openTween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = WindowConfig.Size,
        Position = WindowConfig.Position
    })
    openTween:Play()

    local Window = {
        GUI = ScreenGui,
        MainFrame = MainFrame,
        TabContainer = TabContainer,
        ContentContainer = ContentContainer,
        ResizeHandle = ResizeHandle,
        Tabs = {},
        CurrentTab = nil,
        ThemeElements = {},
        Notifications = {},
        ToggleKey = WindowConfig.ToggleKey,
        UIVisible = true,
        ConfigData = {},
        OriginalSize = WindowConfig.Size,
        OriginalPosition = WindowConfig.Position,
    }

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.ToggleKey then
            Window.UIVisible = not Window.UIVisible
            
            if Window.UIVisible then
                MainFrame.Visible = true
                MainFrame.Size = UDim2.new(0, 0, 0, 0)
                MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = Window.OriginalSize,
                    Position = Window.OriginalPosition
                }):Play()
            else
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                }):Play()
                wait(0.3)
                MainFrame.Visible = false
            end
        end
    end)

    function Window:Notify(config)
        local NotifDuration = config.Duration or 3
        local NotifTitle = config.Title or "Notification"
        local NotifContent = config.Content or ""

        local NotifContainer = Instance.new("Frame")
        NotifContainer.Size = UDim2.new(0, 300, 0, 80)
        NotifContainer.Position = UDim2.new(1, -310, 1, -90)
        NotifContainer.BackgroundColor3 = CurrentTheme.Secondary
        NotifContainer.BorderSizePixel = 0
        NotifContainer.ZIndex = 200
        NotifContainer.Parent = ScreenGui
        CreateUICorner(NotifContainer, 8)
        CreateStroke(NotifContainer, 1, CurrentTheme.Accent)

        local NotifTitleLabel = Instance.new("TextLabel")
        NotifTitleLabel.Size = UDim2.new(1, -20, 0, 25)
        NotifTitleLabel.Position = UDim2.new(0, 10, 0, 5)
        NotifTitleLabel.BackgroundTransparency = 1
        NotifTitleLabel.Text = NotifTitle
        NotifTitleLabel.TextColor3 = CurrentTheme.Text
        NotifTitleLabel.TextSize = 14
        NotifTitleLabel.Font = Enum.Font.GothamBold
        NotifTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        NotifTitleLabel.ZIndex = 201
        NotifTitleLabel.Parent = NotifContainer

        local NotifContentLabel = Instance.new("TextLabel")
        NotifContentLabel.Size = UDim2.new(1, -20, 0, 45)
        NotifContentLabel.Position = UDim2.new(0, 10, 0, 30)
        NotifContentLabel.BackgroundTransparency = 1
        NotifContentLabel.Text = NotifContent
        NotifContentLabel.TextColor3 = CurrentTheme.SubText
        NotifContentLabel.TextSize = 12
        NotifContentLabel.Font = Enum.Font.Gotham
        NotifContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        NotifContentLabel.TextYAlignment = Enum.TextYAlignment.Top
        NotifContentLabel.TextWrapped = true
        NotifContentLabel.ZIndex = 201
        NotifContentLabel.Parent = NotifContainer

        NotifContainer.Position = UDim2.new(1, 10, 1, -90)
        TweenService:Create(NotifContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -310, 1, -90)
        }):Play()

        for _, notif in pairs(Window.Notifications) do
            TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = UDim2.new(notif.Position.X.Scale, notif.Position.X.Offset, notif.Position.Y.Scale, notif.Position.Y.Offset - 90)
            }):Play()
        end

        table.insert(Window.Notifications, NotifContainer)

        wait(NotifDuration)
        TweenService:Create(NotifContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 10, NotifContainer.Position.Y.Scale, NotifContainer.Position.Y.Offset)
        }):Play()
        wait(0.5)
        
        for i, notif in pairs(Window.Notifications) do
            if notif == NotifContainer then
                table.remove(Window.Notifications, i)
            end
        end
        
        NotifContainer:Destroy()
    end

    function Window:SaveConfig()
        if not WindowConfig.SaveConfig then return end

        local configData = {
            Theme = CurrentThemeName,
            ToggleKey = Window.ToggleKey.Name,
        }

        for tabName, tab in pairs(Window.Tabs) do
            configData[tabName] = {}
            for _, element in pairs(tab.Elements) do
                if element.ConfigKey and element.Value ~= nil then
                    configData[tabName][element.ConfigKey] = element.Value
                end
            end
        end

        local success, err = pcall(function()
            if not isfolder(WindowConfig.ConfigFolder) then
                makefolder(WindowConfig.ConfigFolder)
            end
            writefile(WindowConfig.ConfigFolder .. "/config.json", HttpService:JSONEncode(configData))
        end)

        if success then
            Window:Notify({
                Title = "Saved",
                Content = "Configuration saved",
                Duration = 3
            })
        end
    end

    function Window:LoadConfig()
        if not WindowConfig.SaveConfig then return end

        local success, configData = pcall(function()
            return HttpService:JSONDecode(readfile(WindowConfig.ConfigFolder .. "/config.json"))
        end)

        if success and configData then
            Window.ConfigData = configData

            if configData.Theme then
                Window:UpdateTheme(configData.Theme)
            end

            if configData.ToggleKey then
                Window.ToggleKey = Enum.KeyCode[configData.ToggleKey]
            end

            Window:Notify({
                Title = "Loaded",
                Content = "Configuration loaded",
                Duration = 3
            })
        end
    end

    function Window:UpdateTheme(themeName)
        if not Horizon.Themes[themeName] then
            warn("Horizon: Theme '" .. themeName .. "' not found")
            return
        end
        
        CurrentTheme = Horizon.Themes[themeName]
        CurrentThemeName = themeName

        MainFrame.BackgroundColor3 = CurrentTheme.Background
        MainStroke.Color = CurrentTheme.Border
        TopBar.BackgroundColor3 = CurrentTheme.Secondary
        TopBarFix.BackgroundColor3 = CurrentTheme.Secondary
        ContentContainer.BackgroundColor3 = CurrentTheme.Secondary
        ContentStroke.Color = CurrentTheme.Border
        Title.TextColor3 = CurrentTheme.Text
        TitleIcon.ImageColor3 = CurrentTheme.Accent
        CloseButton.TextColor3 = CurrentTheme.Text
        MinimizeButton.TextColor3 = CurrentTheme.Text

        if ResizeHandle then
            ResizeHandle.BackgroundColor3 = CurrentTheme.Accent
        end

        for _, tab in pairs(Window.Tabs) do
            if Window.CurrentTab == tab then
                tab.Button.BackgroundColor3 = CurrentTheme.Accent
                tab.Button.TextColor3 = CurrentTheme.Text
            else
                tab.Button.BackgroundColor3 = CurrentTheme.Secondary
                tab.Button.TextColor3 = CurrentTheme.SubText
            end

            tab.Content.ScrollBarImageColor3 = CurrentTheme.Accent

            for _, element in pairs(tab.Elements) do
                if element.UpdateColors then
                    element:UpdateColors()
                end
            end
        end
    end

	function Window:CreateTab(name, icon)
        local Tab = {
            Name = name,
            Button = nil,
            Content = nil,
            Elements = {},
        }

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.BackgroundColor3 = CurrentTheme.Secondary
        TabButton.Text = "  " .. name
        TabButton.TextColor3 = CurrentTheme.SubText
        TabButton.TextSize = 14
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BorderSizePixel = 0
        TabButton.Parent = TabContainer
        CreateUICorner(TabButton, 6)

        Tab.Button = TabButton

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, -20, 1, -20)
        TabContent.Position = UDim2.new(0, 10, 0, 10)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = CurrentTheme.Accent
        TabContent.Visible = false
        TabContent.Parent = ContentContainer

        local ContentList = Instance.new("UIListLayout")
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Padding = UDim.new(0, 8)
        ContentList.Parent = TabContent

        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
        end)

        Tab.Content = TabContent

        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = CurrentTheme.Secondary
                tab.Button.TextColor3 = CurrentTheme.SubText
                tab.Content.Visible = false
            end

            TabButton.BackgroundColor3 = CurrentTheme.Accent
            TabButton.TextColor3 = CurrentTheme.Text
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end)

        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Border}):Play()
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Secondary}):Play()
            end
        end)

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            TabButton.BackgroundColor3 = CurrentTheme.Accent
            TabButton.TextColor3 = CurrentTheme.Text
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end

        function Tab:AddDivider(text)
            local DividerFrame = Instance.new("Frame")
            DividerFrame.Size = UDim2.new(1, 0, 0, 20)
            DividerFrame.BackgroundTransparency = 1
            DividerFrame.Parent = TabContent

            if text and text ~= "" then
                local DividerLabel = Instance.new("TextLabel")
                DividerLabel.Size = UDim2.new(0, 0, 1, 0)
                DividerLabel.Position = UDim2.new(0, 0, 0, 0)
                DividerLabel.BackgroundTransparency = 1
                DividerLabel.Text = text
                DividerLabel.TextColor3 = CurrentTheme.SubText
                DividerLabel.TextSize = 12
                DividerLabel.Font = Enum.Font.GothamBold
                DividerLabel.TextXAlignment = Enum.TextXAlignment.Left
                DividerLabel.Parent = DividerFrame

                local textSize = game:GetService("TextService"):GetTextSize(
                    text,
                    12,
                    Enum.Font.GothamBold,
                    Vector2.new(math.huge, math.huge)
                )
                DividerLabel.Size = UDim2.new(0, textSize.X + 10, 1, 0)

                local Line = Instance.new("Frame")
                Line.Size = UDim2.new(1, -(textSize.X + 20), 0, 1)
                Line.Position = UDim2.new(0, textSize.X + 15, 0.5, 0)
                Line.BackgroundColor3 = CurrentTheme.Border
                Line.BorderSizePixel = 0
                Line.Parent = DividerFrame

                local element = {
                    Frame = DividerFrame,
                    Label = DividerLabel,
                    Line = Line,
                    UpdateColors = function(self)
                        DividerLabel.TextColor3 = CurrentTheme.SubText
                        Line.BackgroundColor3 = CurrentTheme.Border
                    end
                }

                table.insert(Tab.Elements, element)
                return element
            else
                local Line = Instance.new("Frame")
                Line.Size = UDim2.new(1, 0, 0, 1)
                Line.Position = UDim2.new(0, 0, 0.5, 0)
                Line.BackgroundColor3 = CurrentTheme.Border
                Line.BorderSizePixel = 0
                Line.Parent = DividerFrame

                local element = {
                    Frame = DividerFrame,
                    Line = Line,
                    UpdateColors = function(self)
                        Line.BackgroundColor3 = CurrentTheme.Border
                    end
                }

                table.insert(Tab.Elements, element)
                return element
            end
        end

        function Tab:AddLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 30)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = CurrentTheme.Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.Parent = TabContent

            local element = {
                Label = Label,
                UpdateColors = function(self)
                    Label.TextColor3 = CurrentTheme.Text
                end,
                SetText = function(self, newText)
                    Label.Text = newText
                end
            }

            table.insert(Tab.Elements, element)
            return element
        end

        function Tab:AddParagraph(config)
            local ParagraphFrame = Instance.new("Frame")
            ParagraphFrame.Size = UDim2.new(1, 0, 0, 60)
            ParagraphFrame.BackgroundColor3 = CurrentTheme.Secondary
            ParagraphFrame.BorderSizePixel = 0
            ParagraphFrame.Parent = TabContent
            CreateUICorner(ParagraphFrame, 6)

            local ParagraphTitle = Instance.new("TextLabel")
            ParagraphTitle.Size = UDim2.new(1, -20, 0, 20)
            ParagraphTitle.Position = UDim2.new(0, 10, 0, 5)
            ParagraphTitle.BackgroundTransparency = 1
            ParagraphTitle.Text = config.Title or "Paragraph"
            ParagraphTitle.TextColor3 = CurrentTheme.Text
            ParagraphTitle.TextSize = 14
            ParagraphTitle.Font = Enum.Font.GothamBold
            ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
            ParagraphTitle.Parent = ParagraphFrame

            local ParagraphContent = Instance.new("TextLabel")
            ParagraphContent.Size = UDim2.new(1, -20, 0, 35)
            ParagraphContent.Position = UDim2.new(0, 10, 0, 25)
            ParagraphContent.BackgroundTransparency = 1
            ParagraphContent.Text = config.Content or ""
            ParagraphContent.TextColor3 = CurrentTheme.SubText
            ParagraphContent.TextSize = 12
            ParagraphContent.Font = Enum.Font.Gotham
            ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
            ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
            ParagraphContent.TextWrapped = true
            ParagraphContent.Parent = ParagraphFrame

            local textSize = game:GetService("TextService"):GetTextSize(
                ParagraphContent.Text,
                ParagraphContent.TextSize,
                ParagraphContent.Font,
                Vector2.new(ParagraphFrame.AbsoluteSize.X - 20, math.huge)
            )
            ParagraphFrame.Size = UDim2.new(1, 0, 0, textSize.Y + 35)

            local element = {
                Frame = ParagraphFrame,
                Title = ParagraphTitle,
                Content = ParagraphContent,
                UpdateColors = function(self)
                    ParagraphFrame.BackgroundColor3 = CurrentTheme.Secondary
                    ParagraphTitle.TextColor3 = CurrentTheme.Text
                    ParagraphContent.TextColor3 = CurrentTheme.SubText
                end
            }

            table.insert(Tab.Elements, element)
            return element
        end

        function Tab:AddButton(config)
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
            ButtonFrame.BackgroundColor3 = CurrentTheme.Secondary
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Parent = TabContent
            CreateUICorner(ButtonFrame, 6)

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 1, -10)
            Button.Position = UDim2.new(0, 5, 0, 5)
            Button.BackgroundTransparency = 1
            Button.Text = config.Name or "Button"
            Button.TextColor3 = CurrentTheme.Text
            Button.TextSize = 13
            Button.Font = Enum.Font.Gotham
            Button.Parent = ButtonFrame

            Button.MouseButton1Click:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = CurrentTheme.Accent}):Play()
                wait(0.1)
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = CurrentTheme.Secondary}):Play()
                
                if config.Callback then
                    pcall(config.Callback)
                end
            end)

            Button.MouseEnter:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Border}):Play()
            end)

            Button.MouseLeave:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Secondary}):Play()
            end)

            local element = {
                Frame = ButtonFrame,
                Button = Button,
                UpdateColors = function(self)
                    ButtonFrame.BackgroundColor3 = CurrentTheme.Secondary
                    Button.TextColor3 = CurrentTheme.Text
                end
            }

            table.insert(Tab.Elements, element)
            return element
        end

        function Tab:AddToggle(config)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = CurrentTheme.Secondary
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabContent
            CreateUICorner(ToggleFrame, 6)

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = config.Name or "Toggle"
            ToggleLabel.TextColor3 = CurrentTheme.Text
            ToggleLabel.TextSize = 13
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 40, 0, 20)
            ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
            ToggleButton.BackgroundColor3 = CurrentTheme.Border
            ToggleButton.Text = ""
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Parent = ToggleFrame
            CreateUICorner(ToggleButton, 10)

            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
            ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
            ToggleIndicator.BackgroundColor3 = CurrentTheme.Text
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Parent = ToggleButton
            CreateUICorner(ToggleIndicator, 8)

            local Toggled = config.Default or false

            if Toggled then
                ToggleButton.BackgroundColor3 = CurrentTheme.Accent
                ToggleIndicator.Position = UDim2.new(1, -18, 0.5, -8)
            end

            ToggleButton.MouseButton1Click:Connect(function()
                Toggled = not Toggled

                if Toggled then
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Accent}):Play()
                    TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                else
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Border}):Play()
                    TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                end

                if config.Callback then
                    pcall(function()
                        config.Callback(Toggled)
                    end)
                end
            end)

            local element = {
                Frame = ToggleFrame,
                Label = ToggleLabel,
                Button = ToggleButton,
                Indicator = ToggleIndicator,
                Value = Toggled,
                ConfigKey = config.Flag,
                UpdateColors = function(self)
                    ToggleFrame.BackgroundColor3 = CurrentTheme.Secondary
                    ToggleLabel.TextColor3 = CurrentTheme.Text
                    ToggleIndicator.BackgroundColor3 = CurrentTheme.Text
                    if Toggled then
                        ToggleButton.BackgroundColor3 = CurrentTheme.Accent
                    else
                        ToggleButton.BackgroundColor3 = CurrentTheme.Border
                    end
                end,
                SetValue = function(self, val)
                    Toggled = val
                    if Toggled then
                        ToggleButton.BackgroundColor3 = CurrentTheme.Accent
                        ToggleIndicator.Position = UDim2.new(1, -18, 0.5, -8)
                    else
                        ToggleButton.BackgroundColor3 = CurrentTheme.Border
                        ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
                    end
                end
            }

            table.insert(Tab.Elements, element)
            return element
        end

        function Tab:AddSlider(config)
            local minValue = config.Min or 0
            local maxValue = config.Max or 100
            local defaultValue = config.Default or minValue
            local increment = config.Increment or 1
            local currentValue = defaultValue

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            SliderFrame.BackgroundColor3 = CurrentTheme.Secondary
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabContent
            CreateUICorner(SliderFrame, 6)

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(0.5, -10, 0, 20)
            SliderLabel.Position = UDim2.new(0, 10, 0, 5)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = config.Name or "Slider"
            SliderLabel.TextColor3 = CurrentTheme.Text
            SliderLabel.TextSize = 13
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame

            local SliderValue = Instance.new("TextLabel")
            SliderValue.Size = UDim2.new(0.5, -10, 0, 20)
            SliderValue.Position = UDim2.new(0.5, 0, 0, 5)
            SliderValue.BackgroundTransparency = 1
            SliderValue.Text = tostring(currentValue)
            SliderValue.TextColor3 = CurrentTheme.SubText
            SliderValue.TextSize = 13
            SliderValue.Font = Enum.Font.Gotham
            SliderValue.TextXAlignment = Enum.TextXAlignment.Right
            SliderValue.Parent = SliderFrame

            local SliderTrack = Instance.new("Frame")
            SliderTrack.Size = UDim2.new(1, -20, 0, 4)
            SliderTrack.Position = UDim2.new(0, 10, 1, -15)
            SliderTrack.BackgroundColor3 = CurrentTheme.Border
            SliderTrack.BorderSizePixel = 0
            SliderTrack.Parent = SliderFrame
            CreateUICorner(SliderTrack, 2)

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((currentValue - minValue) / (maxValue - minValue), 0, 1, 0)
            SliderFill.BackgroundColor3 = CurrentTheme.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderTrack
            CreateUICorner(SliderFill, 2)

            local SliderButton = Instance.new("TextButton")
            SliderButton.Size = UDim2.new(1, 0, 1, 0)
            SliderButton.BackgroundTransparency = 1
            SliderButton.Text = ""
            SliderButton.Parent = SliderTrack

            local dragging = false

            SliderButton.MouseButton1Down:Connect(function()
                dragging = true
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mouse = UserInputService:GetMouseLocation()
                    local relativePos = math.clamp((mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    currentValue = math.floor((minValue + (maxValue - minValue) * relativePos) / increment + 0.5) * increment
                    currentValue = math.clamp(currentValue, minValue, maxValue)

                    SliderValue.Text = tostring(currentValue)
                    TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(relativePos, 0, 1, 0)}):Play()

                    if config.Callback then
                        pcall(function()
                            config.Callback(currentValue)
                        end)
                    end
                end
            end)

            local element = {
                Frame = SliderFrame,
                Label = SliderLabel,
                ValueLabel = SliderValue,
                Track = SliderTrack,
                Fill = SliderFill,
                Value = currentValue,
                ConfigKey = config.Flag,
                UpdateColors = function(self)
                    SliderFrame.BackgroundColor3 = CurrentTheme.Secondary
                    SliderLabel.TextColor3 = CurrentTheme.Text
                    SliderValue.TextColor3 = CurrentTheme.SubText
                    SliderTrack.BackgroundColor3 = CurrentTheme.Border
                    SliderFill.BackgroundColor3 = CurrentTheme.Accent
                end,
                SetValue = function(self, val)
                    currentValue = math.clamp(val, minValue, maxValue)
                    SliderValue.Text = tostring(currentValue)
                    local relativePos = (currentValue - minValue) / (maxValue - minValue)
                    SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                end
            }

            table.insert(Tab.Elements, element)
            return element
        end

        function Tab:AddDropdown(config)
            local options = config.Options or {"Option 1", "Option 2"}
            local currentOption = config.Default or options[1]

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            DropdownFrame.BackgroundColor3 = CurrentTheme.Secondary
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Parent = TabContent
            DropdownFrame.ClipsDescendants = false
            DropdownFrame.ZIndex = 5
            CreateUICorner(DropdownFrame, 6)

            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Size = UDim2.new(0, 100, 1, 0)
            DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = config.Name or "Dropdown"
            DropdownLabel.TextColor3 = CurrentTheme.Text
            DropdownLabel.TextSize = 13
            DropdownLabel.Font = Enum.Font.Gotham
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.ZIndex = 6
            DropdownLabel.Parent = DropdownFrame

            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(1, -120, 0, 25)
            DropdownButton.Position = UDim2.new(0, 115, 0.5, -12.5)
            DropdownButton.BackgroundColor3 = CurrentTheme.Border
            DropdownButton.Text = currentOption
            DropdownButton.TextColor3 = CurrentTheme.Text
            DropdownButton.TextSize = 12
            DropdownButton.Font = Enum.Font.Gotham
            DropdownButton.BorderSizePixel = 0
            DropdownButton.ZIndex = 6
            DropdownButton.Parent = DropdownFrame
            CreateUICorner(DropdownButton, 4)

            local DropdownList = Instance.new("ScrollingFrame")
            DropdownList.Size = UDim2.new(1, -120, 0, math.min(#options * 30, 120))
            DropdownList.Position = UDim2.new(0, 115, 1, 5)
            DropdownList.BackgroundColor3 = CurrentTheme.Secondary
            DropdownList.BorderSizePixel = 0
            DropdownList.Visible = false
            DropdownList.ZIndex = 50
            DropdownList.ScrollBarThickness = 4
            DropdownList.ScrollBarImageColor3 = CurrentTheme.Accent
            DropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
            DropdownList.Parent = DropdownFrame
            CreateUICorner(DropdownList, 4)
            CreateStroke(DropdownList, 1, CurrentTheme.Border)

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = DropdownList

            local optionButtons = {}

            for _, option in pairs(options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 30)
                OptionButton.BackgroundColor3 = CurrentTheme.Secondary
                OptionButton.Text = option
                OptionButton.TextColor3 = CurrentTheme.Text
                OptionButton.TextSize = 12
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.BorderSizePixel = 0
                OptionButton.ZIndex = 51
                OptionButton.Parent = DropdownList

                table.insert(optionButtons, OptionButton)

                OptionButton.MouseButton1Click:Connect(function()
                    currentOption = option
                    DropdownButton.Text = option
                    DropdownList.Visible = false

                    if config.Callback then
                        pcall(function()
                            config.Callback(option)
                        end)
                    end
                end)

                OptionButton.MouseEnter:Connect(function()
                    OptionButton.BackgroundColor3 = CurrentTheme.Border
                end)

                OptionButton.MouseLeave:Connect(function()
                    OptionButton.BackgroundColor3 = CurrentTheme.Secondary
                end)
            end

            DropdownButton.MouseButton1Click:Connect(function()
                DropdownList.Visible = not DropdownList.Visible
            end)

            local element = {
                Frame = DropdownFrame,
                Label = DropdownLabel,
                Button = DropdownButton,
                List = DropdownList,
                OptionButtons = optionButtons,
                Value = currentOption,
                ConfigKey = config.Flag,
                UpdateColors = function(self)
                    DropdownFrame.BackgroundColor3 = CurrentTheme.Secondary
                    DropdownLabel.TextColor3 = CurrentTheme.Text
                    DropdownButton.BackgroundColor3 = CurrentTheme.Border
                    DropdownButton.TextColor3 = CurrentTheme.Text
                    DropdownList.BackgroundColor3 = CurrentTheme.Secondary
                    DropdownList.ScrollBarImageColor3 = CurrentTheme.Accent
                    
                    for _, btn in pairs(optionButtons) do
                        btn.BackgroundColor3 = CurrentTheme.Secondary
                        btn.TextColor3 = CurrentTheme.Text
                    end
                end
            }

            table.insert(Tab.Elements, element)
            return element
        end

        function Tab:AddSearchableDropdown(config)
            local options = config.Options or {"Option 1", "Option 2"}
            local currentOption = config.Default or options[1]
            local searchText = ""

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            DropdownFrame.BackgroundColor3 = CurrentTheme.Secondary
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Parent = TabContent
            DropdownFrame.ClipsDescendants = false
            DropdownFrame.ZIndex = 5
            CreateUICorner(DropdownFrame, 6)

            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Size = UDim2.new(0, 100, 1, 0)
            DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = config.Name or "Searchable Dropdown"
            DropdownLabel.TextColor3 = CurrentTheme.Text
            DropdownLabel.TextSize = 13
            DropdownLabel.Font = Enum.Font.Gotham
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.ZIndex = 6
            DropdownLabel.Parent = DropdownFrame

            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(1, -120, 0, 25)
            DropdownButton.Position = UDim2.new(0, 115, 0.5, -12.5)
            DropdownButton.BackgroundColor3 = CurrentTheme.Border
            DropdownButton.Text = currentOption
            DropdownButton.TextColor3 = CurrentTheme.Text
            DropdownButton.TextSize = 12
            DropdownButton.Font = Enum.Font.Gotham
            DropdownButton.BorderSizePixel = 0
            DropdownButton.ZIndex = 6
            DropdownButton.Parent = DropdownFrame
            CreateUICorner(DropdownButton, 4)

            local DropdownList = Instance.new("ScrollingFrame")
            DropdownList.Size = UDim2.new(1, -120, 0, 150)
            DropdownList.Position = UDim2.new(0, 115, 1, 5)
            DropdownList.BackgroundColor3 = CurrentTheme.Secondary
            DropdownList.BorderSizePixel = 0
            DropdownList.Visible = false
            DropdownList.ZIndex = 50
            DropdownList.ScrollBarThickness = 4
            DropdownList.ScrollBarImageColor3 = CurrentTheme.Accent
            DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
            DropdownList.Parent = DropdownFrame
            CreateUICorner(DropdownList, 4)
            CreateStroke(DropdownList, 1, CurrentTheme.Border)

            local SearchBox = Instance.new("TextBox")
            SearchBox.Size = UDim2.new(1, -10, 0, 25)
            SearchBox.Position = UDim2.new(0, 5, 0, 5)
            SearchBox.BackgroundColor3 = CurrentTheme.Border
            SearchBox.Text = ""
            SearchBox.PlaceholderText = "Search..."
            SearchBox.TextColor3 = CurrentTheme.Text
            SearchBox.PlaceholderColor3 = CurrentTheme.SubText
            SearchBox.TextSize = 12
            SearchBox.Font = Enum.Font.Gotham
            SearchBox.BorderSizePixel = 0
            SearchBox.ClearTextOnFocus = false
            SearchBox.ZIndex = 51
            SearchBox.Parent = DropdownList
            CreateUICorner(SearchBox, 4)

            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Size = UDim2.new(1, 0, 1, -35)
            OptionsContainer.Position = UDim2.new(0, 0, 0, 35)
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.ZIndex = 51
            OptionsContainer.Parent = DropdownList

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = OptionsContainer

            local optionButtons = {}

            local function createOptionButton(option)
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 30)
                OptionButton.BackgroundColor3 = CurrentTheme.Secondary
                OptionButton.Text = option
                OptionButton.TextColor3 = CurrentTheme.Text
                OptionButton.TextSize = 12
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.BorderSizePixel = 0
                OptionButton.ZIndex = 52
                OptionButton.Parent = OptionsContainer

                OptionButton.MouseButton1Click:Connect(function()
                    currentOption = option
                    DropdownButton.Text = option
                    DropdownList.Visible = false
                    SearchBox.Text = ""
                    searchText = ""
                    
                    if config.Callback then
                        pcall(function()
                            config.Callback(option)
                        end)
                    end
                end)

                OptionButton.MouseEnter:Connect(function()
                    OptionButton.BackgroundColor3 = CurrentTheme.Border
                end)

                OptionButton.MouseLeave:Connect(function()
                    OptionButton.BackgroundColor3 = CurrentTheme.Secondary
                end)

                return OptionButton
            end

            for _, option in pairs(options) do
                local btn = createOptionButton(option)
                table.insert(optionButtons, {button = btn, text = option})
            end

            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                OptionsContainer.Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y)
                DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 40)
            end)

            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                searchText = SearchBox.Text:lower()
                
                for _, optionData in pairs(optionButtons) do
                    if searchText == "" or optionData.text:lower():find(searchText, 1, true) then
                        optionData.button.Visible = true
                    else
                        optionData.button.Visible = false
                    end
                end
            end)

            DropdownButton.MouseButton1Click:Connect(function()
                DropdownList.Visible = not DropdownList.Visible
                if DropdownList.Visible then
                    SearchBox:CaptureFocus()
                end
            end)

            local element = {
                Frame = DropdownFrame,
                Label = DropdownLabel,
                Button = DropdownButton,
                List = DropdownList,
                SearchBox = SearchBox,
                OptionButtons = optionButtons,
                Value = currentOption,
                ConfigKey = config.Flag,
                UpdateColors = function(self)
                    DropdownFrame.BackgroundColor3 = CurrentTheme.Secondary
                    DropdownLabel.TextColor3 = CurrentTheme.Text
                    DropdownButton.BackgroundColor3 = CurrentTheme.Border
                    DropdownButton.TextColor3 = CurrentTheme.Text
                    DropdownList.BackgroundColor3 = CurrentTheme.Secondary
                    DropdownList.ScrollBarImageColor3 = CurrentTheme.Accent
                    SearchBox.BackgroundColor3 = CurrentTheme.Border
                    SearchBox.TextColor3 = CurrentTheme.Text
                    SearchBox.PlaceholderColor3 = CurrentTheme.SubText
                    
                    for _, optionData in pairs(optionButtons) do
                        optionData.button.BackgroundColor3 = CurrentTheme.Secondary
                        optionData.button.TextColor3 = CurrentTheme.Text
                    end
                end
            }

            table.insert(Tab.Elements, element)
            return element
        end

        function Tab:AddMultiDropdown(config)
            local options = config.Options or {"Option 1", "Option 2"}
            local selectedOptions = config.Default or {}
            local selectedDict = {}
            
            for _, option in pairs(selectedOptions) do
                selectedDict[option] = true
            end

            local MultiDropdownFrame = Instance.new("Frame")
            MultiDropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            MultiDropdownFrame.BackgroundColor3 = CurrentTheme.Secondary
            MultiDropdownFrame.BorderSizePixel = 0
            MultiDropdownFrame.Parent = TabContent
            MultiDropdownFrame.ClipsDescendants = false
            MultiDropdownFrame.ZIndex = 5
            CreateUICorner(MultiDropdownFrame, 6)

            local MultiDropdownLabel = Instance.new("TextLabel")
            MultiDropdownLabel.Size = UDim2.new(0, 100, 1, 0)
            MultiDropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            MultiDropdownLabel.BackgroundTransparency = 1
            MultiDropdownLabel.Text = config.Name or "Multi Dropdown"
            MultiDropdownLabel.TextColor3 = CurrentTheme.Text
            MultiDropdownLabel.TextSize = 13
            MultiDropdownLabel.Font = Enum.Font.Gotham
            MultiDropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            MultiDropdownLabel.ZIndex = 6
            MultiDropdownLabel.Parent = MultiDropdownFrame

            local MultiDropdownButton = Instance.new("TextButton")
            MultiDropdownButton.Size = UDim2.new(1, -120, 0, 25)
            MultiDropdownButton.Position = UDim2.new(0, 115, 0.5, -12.5)
            MultiDropdownButton.BackgroundColor3 = CurrentTheme.Border
            MultiDropdownButton.Text = #selectedOptions > 0 and (#selectedOptions .. " selected") or "None"
            MultiDropdownButton.TextColor3 = CurrentTheme.Text
            MultiDropdownButton.TextSize = 12
            MultiDropdownButton.Font = Enum.Font.Gotham
            MultiDropdownButton.BorderSizePixel = 0
            MultiDropdownButton.ZIndex = 6
            MultiDropdownButton.Parent = MultiDropdownFrame
            CreateUICorner(MultiDropdownButton, 4)

            local MultiDropdownList = Instance.new("ScrollingFrame")
            MultiDropdownList.Size = UDim2.new(1, -120, 0, math.min(#options * 30 + 40, 180))
            MultiDropdownList.Position = UDim2.new(0, 115, 1, 5)
            MultiDropdownList.BackgroundColor3 = CurrentTheme.Secondary
            MultiDropdownList.BorderSizePixel = 0
            MultiDropdownList.Visible = false
            MultiDropdownList.ZIndex = 50
            MultiDropdownList.ScrollBarThickness = 4
            MultiDropdownList.ScrollBarImageColor3 = CurrentTheme.Accent
            MultiDropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 30 + 40)
            MultiDropdownList.Parent = MultiDropdownFrame
            CreateUICorner(MultiDropdownList, 4)
            CreateStroke(MultiDropdownList, 1, CurrentTheme.Border)

            local ButtonContainer = Instance.new("Frame")
            ButtonContainer.Size = UDim2.new(1, -10, 0, 30)
            ButtonContainer.Position = UDim2.new(0, 5, 0, 5)
            ButtonContainer.BackgroundTransparency = 1
            ButtonContainer.ZIndex = 51
            ButtonContainer.Parent = MultiDropdownList

            local SelectAllButton = Instance.new("TextButton")
            SelectAllButton.Size = UDim2.new(0.48, 0, 1, 0)
            SelectAllButton.Position = UDim2.new(0, 0, 0, 0)
            SelectAllButton.BackgroundColor3 = CurrentTheme.Border
            SelectAllButton.Text = "Select All"
            SelectAllButton.TextColor3 = CurrentTheme.Text
            SelectAllButton.TextSize = 11
            SelectAllButton.Font = Enum.Font.Gotham
            SelectAllButton.BorderSizePixel = 0
            SelectAllButton.ZIndex = 52
            SelectAllButton.Parent = ButtonContainer
            CreateUICorner(SelectAllButton, 4)

            local ClearAllButton = Instance.new("TextButton")
            ClearAllButton.Size = UDim2.new(0.48, 0, 1, 0)
            ClearAllButton.Position = UDim2.new(0.52, 0, 0, 0)
            ClearAllButton.BackgroundColor3 = CurrentTheme.Border
            ClearAllButton.Text = "Clear All"
            ClearAllButton.TextColor3 = CurrentTheme.Text
            ClearAllButton.TextSize = 11
            ClearAllButton.Font = Enum.Font.Gotham
            ClearAllButton.BorderSizePixel = 0
            ClearAllButton.ZIndex = 52
            ClearAllButton.Parent = ButtonContainer
            CreateUICorner(ClearAllButton, 4)

            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Size = UDim2.new(1, 0, 1, -40)
            OptionsContainer.Position = UDim2.new(0, 0, 0, 40)
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.ZIndex = 51
            OptionsContainer.Parent = MultiDropdownList

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = OptionsContainer

            local optionCheckboxes = {}

            local function updateButtonText()
                local count = 0
                for _ in pairs(selectedDict) do
                    count = count + 1
                end
                
                if count == 0 then
                    MultiDropdownButton.Text = "None"
                elseif count == 1 then
                    for option in pairs(selectedDict) do
                        MultiDropdownButton.Text = option
                        break
                    end
                else
                    MultiDropdownButton.Text = count .. " selected"
                end
            end

            local function fireCallback()
                local selected = {}
                for option in pairs(selectedDict) do
                    table.insert(selected, option)
                end
                
                if config.Callback then
                    pcall(function()
                        config.Callback(selected)
                    end)
                end
            end

            for _, option in pairs(options) do
                local OptionFrame = Instance.new("Frame")
                OptionFrame.Size = UDim2.new(1, 0, 0, 30)
                OptionFrame.BackgroundColor3 = CurrentTheme.Secondary
                OptionFrame.BorderSizePixel = 0
                OptionFrame.ZIndex = 52
                OptionFrame.Parent = OptionsContainer

                local Checkbox = Instance.new("Frame")
                Checkbox.Size = UDim2.new(0, 16, 0, 16)
                Checkbox.Position = UDim2.new(0, 8, 0.5, -8)
                Checkbox.BackgroundColor3 = CurrentTheme.Border
                Checkbox.BorderSizePixel = 0
                Checkbox.ZIndex = 53
                Checkbox.Parent = OptionFrame
                CreateUICorner(Checkbox, 3)

                local CheckboxIndicator = Instance.new("Frame")
                CheckboxIndicator.Size = UDim2.new(0, 10, 0, 10)
                CheckboxIndicator.Position = UDim2.new(0.5, -5, 0.5, -5)
                CheckboxIndicator.BackgroundColor3 = CurrentTheme.Accent
                CheckboxIndicator.BorderSizePixel = 0
                CheckboxIndicator.Visible = selectedDict[option] or false
                CheckboxIndicator.ZIndex = 54
                CheckboxIndicator.Parent = Checkbox
                CreateUICorner(CheckboxIndicator, 2)

                local OptionLabel = Instance.new("TextLabel")
                OptionLabel.Size = UDim2.new(1, -35, 1, 0)
                OptionLabel.Position = UDim2.new(0, 30, 0, 0)
                OptionLabel.BackgroundTransparency = 1
                OptionLabel.Text = option
                OptionLabel.TextColor3 = CurrentTheme.Text
                OptionLabel.TextSize = 12
                OptionLabel.Font = Enum.Font.Gotham
                OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                OptionLabel.ZIndex = 53
                OptionLabel.Parent = OptionFrame

                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 1, 0)
                OptionButton.BackgroundTransparency = 1
                OptionButton.Text = ""
                OptionButton.ZIndex = 55
                OptionButton.Parent = OptionFrame

                OptionButton.MouseButton1Click:Connect(function()
                    if selectedDict[option] then
                        selectedDict[option] = nil
                        CheckboxIndicator.Visible = false
                    else
                        selectedDict[option] = true
                        CheckboxIndicator.Visible = true
                    end
                    
                    updateButtonText()
                    fireCallback()
                end)

                OptionButton.MouseEnter:Connect(function()
                    OptionFrame.BackgroundColor3 = CurrentTheme.Border
                end)

                OptionButton.MouseLeave:Connect(function()
                    OptionFrame.BackgroundColor3 = CurrentTheme.Secondary
                end)

                table.insert(optionCheckboxes, {
                    frame = OptionFrame,
                    checkbox = Checkbox,
                    indicator = CheckboxIndicator,
                    label = OptionLabel,
                    option = option
                })
            end

            SelectAllButton.MouseButton1Click:Connect(function()
                for _, option in pairs(options) do
                    selectedDict[option] = true
                end
                
                for _, checkboxData in pairs(optionCheckboxes) do
                    checkboxData.indicator.Visible = true
                end
                
                updateButtonText()
                fireCallback()
            end)

            ClearAllButton.MouseButton1Click:Connect(function()
                selectedDict = {}
                
                for _, checkboxData in pairs(optionCheckboxes) do
                    checkboxData.indicator.Visible = false
                end
                
                updateButtonText()
                fireCallback()
            end)

            SelectAllButton.MouseEnter:Connect(function()
                SelectAllButton.BackgroundColor3 = CurrentTheme.Accent
            end)

            SelectAllButton.MouseLeave:Connect(function()
                SelectAllButton.BackgroundColor3 = CurrentTheme.Border
            end)

            ClearAllButton.MouseEnter:Connect(function()
                ClearAllButton.BackgroundColor3 = CurrentTheme.Accent
            end)

            ClearAllButton.MouseLeave:Connect(function()
                ClearAllButton.BackgroundColor3 = CurrentTheme.Border
            end)

            MultiDropdownButton.MouseButton1Click:Connect(function()
                MultiDropdownList.Visible = not MultiDropdownList.Visible
            end)

            local element = {
                Frame = MultiDropdownFrame,
                Label = MultiDropdownLabel,
                Button = MultiDropdownButton,
                List = MultiDropdownList,
                SelectAll = SelectAllButton,
                ClearAll = ClearAllButton,
                Checkboxes = optionCheckboxes,
                Value = selectedOptions,
                ConfigKey = config.Flag,
                UpdateColors = function(self)
                    MultiDropdownFrame.BackgroundColor3 = CurrentTheme.Secondary
                    MultiDropdownLabel.TextColor3 = CurrentTheme.Text
                    MultiDropdownButton.BackgroundColor3 = CurrentTheme.Border
                    MultiDropdownButton.TextColor3 = CurrentTheme.Text
                    MultiDropdownList.BackgroundColor3 = CurrentTheme.Secondary
                    MultiDropdownList.ScrollBarImageColor3 = CurrentTheme.Accent
                    SelectAllButton.BackgroundColor3 = CurrentTheme.Border
                    SelectAllButton.TextColor3 = CurrentTheme.Text
                    ClearAllButton.BackgroundColor3 = CurrentTheme.Border
                    ClearAllButton.TextColor3 = CurrentTheme.Text
                    
                    for _, checkboxData in pairs(optionCheckboxes) do
                        checkboxData.frame.BackgroundColor3 = CurrentTheme.Secondary
                        checkboxData.checkbox.BackgroundColor3 = CurrentTheme.Border
                        checkboxData.indicator.BackgroundColor3 = CurrentTheme.Accent
                        checkboxData.label.TextColor3 = CurrentTheme.Text
                    end
                end
            }

            table.insert(Tab.Elements, element)
            return element
        end

        function Tab:AddTextbox(config)
            local TextboxFrame = Instance.new("Frame")
            TextboxFrame.Size = UDim2.new(1, 0, 0, 35)
            TextboxFrame.BackgroundColor3 = CurrentTheme.Secondary
            TextboxFrame.BorderSizePixel = 0
            TextboxFrame.Parent = TabContent
            CreateUICorner(TextboxFrame, 6)

            local TextboxLabel = Instance.new("TextLabel")
            TextboxLabel.Size = UDim2.new(0, 100, 1, 0)
            TextboxLabel.Position = UDim2.new(0, 10, 0, 0)
            TextboxLabel.BackgroundTransparency = 1
            TextboxLabel.Text = config.Name or "Textbox"
            TextboxLabel.TextColor3 = CurrentTheme.Text
            TextboxLabel.TextSize = 13
            TextboxLabel.Font = Enum.Font.Gotham
            TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextboxLabel.Parent = TextboxFrame

            local TextboxInput = Instance.new("TextBox")
            TextboxInput.Size = UDim2.new(1, -120, 0, 25)
            TextboxInput.Position = UDim2.new(0, 115, 0.5, -12.5)
            TextboxInput.BackgroundColor3 = CurrentTheme.Border
            TextboxInput.Text = config.Default or ""
            TextboxInput.PlaceholderText = config.Placeholder or "Enter text..."
            TextboxInput.TextColor3 = CurrentTheme.Text
            TextboxInput.PlaceholderColor3 = CurrentTheme.SubText
            TextboxInput.TextSize = 12
            TextboxInput.Font = Enum.Font.Gotham
            TextboxInput.BorderSizePixel = 0
            TextboxInput.ClearTextOnFocus = false
            TextboxInput.Parent = TextboxFrame
            CreateUICorner(TextboxInput, 4)

            TextboxInput.FocusLost:Connect(function(enterPressed)
                if config.Callback then
                    pcall(function()
                        config.Callback(TextboxInput.Text)
                    end)
                end
            end)

            local element = {
                Frame = TextboxFrame,
                Label = TextboxLabel,
                Input = TextboxInput,
                Value = TextboxInput.Text,
                ConfigKey = config.Flag,
                UpdateColors = function(self)
                    TextboxFrame.BackgroundColor3 = CurrentTheme.Secondary
                    TextboxLabel.TextColor3 = CurrentTheme.Text
                    TextboxInput.BackgroundColor3 = CurrentTheme.Border
                    TextboxInput.TextColor3 = CurrentTheme.Text
                    TextboxInput.PlaceholderColor3 = CurrentTheme.SubText
                end,
                SetValue = function(self, val)
                    TextboxInput.Text = val
                end
            }

            table.insert(Tab.Elements, element)
            return element
        end

        function Tab:AddKeybind(config)
            local currentKey = config.Default or Enum.KeyCode.E
            local listening = false

            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Size = UDim2.new(1, 0, 0, 35)
            KeybindFrame.BackgroundColor3 = CurrentTheme.Secondary
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.Parent = TabContent
            CreateUICorner(KeybindFrame, 6)

            local KeybindLabel = Instance.new("TextLabel")
            KeybindLabel.Size = UDim2.new(0, 100, 1, 0)
            KeybindLabel.Position = UDim2.new(0, 10, 0, 0)
            KeybindLabel.BackgroundTransparency = 1
            KeybindLabel.Text = config.Name or "Keybind"
            KeybindLabel.TextColor3 = CurrentTheme.Text
            KeybindLabel.TextSize = 13
            KeybindLabel.Font = Enum.Font.Gotham
            KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeybindLabel.Parent = KeybindFrame

            local KeybindButton = Instance.new("TextButton")
            KeybindButton.Size = UDim2.new(1, -120, 0, 25)
            KeybindButton.Position = UDim2.new(0, 115, 0.5, -12.5)
            KeybindButton.BackgroundColor3 = CurrentTheme.Border
            KeybindButton.Text = currentKey.Name
            KeybindButton.TextColor3 = CurrentTheme.Text
            KeybindButton.TextSize = 12
            KeybindButton.Font = Enum.Font.Gotham
            KeybindButton.BorderSizePixel = 0
            KeybindButton.Parent = KeybindFrame
            CreateUICorner(KeybindButton, 4)

            KeybindButton.MouseButton1Click:Connect(function()
                listening = true
                KeybindButton.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    KeybindButton.Text = currentKey.Name
                    listening = false

                    if config.Callback then
                        pcall(function()
                            config.Callback(currentKey)
                        end)
                    end
                end
            end)

            local element = {
                Frame = KeybindFrame,
                Label = KeybindLabel,
                Button = KeybindButton,
                Value = currentKey,
                ConfigKey = config.Flag,
                UpdateColors = function(self)
                    KeybindFrame.BackgroundColor3 = CurrentTheme.Secondary
                    KeybindLabel.TextColor3 = CurrentTheme.Text
                    KeybindButton.BackgroundColor3 = CurrentTheme.Border
                    KeybindButton.TextColor3 = CurrentTheme.Text
                end,
                SetValue = function(self, val)
                    currentKey = val
                    KeybindButton.Text = currentKey.Name
                end
            }

            table.insert(Tab.Elements, element)
            return element
        end

        function Tab:AddColorPicker(config)
            local currentColor = config.Default or Color3.fromRGB(255, 255, 255)

            local ColorPickerFrame = Instance.new("Frame")
            ColorPickerFrame.Size = UDim2.new(1, 0, 0, 35)
            ColorPickerFrame.BackgroundColor3 = CurrentTheme.Secondary
            ColorPickerFrame.BorderSizePixel = 0
            ColorPickerFrame.Parent = TabContent
            ColorPickerFrame.ClipsDescendants = false
            ColorPickerFrame.ZIndex = 5
            CreateUICorner(ColorPickerFrame, 6)

            local ColorPickerLabel = Instance.new("TextLabel")
            ColorPickerLabel.Size = UDim2.new(1, -50, 1, 0)
            ColorPickerLabel.Position = UDim2.new(0, 10, 0, 0)
            ColorPickerLabel.BackgroundTransparency = 1
            ColorPickerLabel.Text = config.Name or "Color Picker"
            ColorPickerLabel.TextColor3 = CurrentTheme.Text
            ColorPickerLabel.TextSize = 13
            ColorPickerLabel.Font = Enum.Font.Gotham
            ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
            ColorPickerLabel.ZIndex = 6
            ColorPickerLabel.Parent = ColorPickerFrame

            local ColorDisplay = Instance.new("Frame")
            ColorDisplay.Size = UDim2.new(0, 30, 0, 25)
            ColorDisplay.Position = UDim2.new(1, -40, 0.5, -12.5)
            ColorDisplay.BackgroundColor3 = currentColor
            ColorDisplay.BorderSizePixel = 0
            ColorDisplay.ZIndex = 6
            ColorDisplay.Parent = ColorPickerFrame
            CreateUICorner(ColorDisplay, 4)
            CreateStroke(ColorDisplay, 1, CurrentTheme.Border)

            local ColorButton = Instance.new("TextButton")
            ColorButton.Size = UDim2.new(1, 0, 1, 0)
            ColorButton.BackgroundTransparency = 1
            ColorButton.Text = ""
            ColorButton.ZIndex = 7
            ColorButton.Parent = ColorDisplay

            local ColorPickerPopup = Instance.new("Frame")
            ColorPickerPopup.Size = UDim2.new(0, 200, 0, 150)
            ColorPickerPopup.Position = UDim2.new(1, -200, 0, -155)
            ColorPickerPopup.BackgroundColor3 = CurrentTheme.Secondary
            ColorPickerPopup.BorderSizePixel = 0
            ColorPickerPopup.Visible = false
            ColorPickerPopup.ZIndex = 100
            ColorPickerPopup.Parent = ColorPickerFrame
            CreateUICorner(ColorPickerPopup, 6)
            CreateStroke(ColorPickerPopup, 1, CurrentTheme.Border)

            local function createColorSlider(name, yPos, defaultValue)
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Size = UDim2.new(1, -20, 0, 30)
                sliderFrame.Position = UDim2.new(0, 10, 0, yPos)
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.ZIndex = 101
                sliderFrame.Parent = ColorPickerPopup

                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Size = UDim2.new(0, 20, 1, 0)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = name
                sliderLabel.TextColor3 = CurrentTheme.Text
                sliderLabel.TextSize = 12
                sliderLabel.Font = Enum.Font.GothamBold
                sliderLabel.ZIndex = 101
                sliderLabel.Parent = sliderFrame

                local sliderTrack = Instance.new("Frame")
                sliderTrack.Size = UDim2.new(1, -70, 0, 4)
                sliderTrack.Position = UDim2.new(0, 30, 0.5, -2)
                sliderTrack.BackgroundColor3 = CurrentTheme.Border
                sliderTrack.BorderSizePixel = 0
                sliderTrack.ZIndex = 101
                sliderTrack.Parent = sliderFrame
                CreateUICorner(sliderTrack, 2)

                local sliderFill = Instance.new("Frame")
                sliderFill.Size = UDim2.new(defaultValue / 255, 0, 1, 0)
                sliderFill.BackgroundColor3 = CurrentTheme.Accent
                sliderFill.BorderSizePixel = 0
                sliderFill.ZIndex = 101
                sliderFill.Parent = sliderTrack
                CreateUICorner(sliderFill, 2)

                local sliderValue = Instance.new("TextLabel")
                sliderValue.Size = UDim2.new(0, 40, 1, 0)
                sliderValue.Position = UDim2.new(1, -40, 0, 0)
                sliderValue.BackgroundTransparency = 1
                sliderValue.Text = tostring(defaultValue)
                sliderValue.TextColor3 = CurrentTheme.SubText
                sliderValue.TextSize = 12
                sliderValue.Font = Enum.Font.Gotham
                sliderValue.TextXAlignment = Enum.TextXAlignment.Right
                sliderValue.ZIndex = 101
                sliderValue.Parent = sliderFrame

                local sliderButton = Instance.new("TextButton")
                sliderButton.Size = UDim2.new(1, 0, 1, 0)
                sliderButton.BackgroundTransparency = 1
                sliderButton.Text = ""
                sliderButton.ZIndex = 102
                sliderButton.Parent = sliderTrack

                local dragging = false
                sliderButton.MouseButton1Down:Connect(function()
                    dragging = true
                end)

                return {
                    Track = sliderTrack,
                    Fill = sliderFill,
                    ValueLabel = sliderValue,
                    Dragging = function() return dragging end,
                    SetDragging = function(val) dragging = val end
                }
            end

            local rSlider = createColorSlider("R", 10, math.floor(currentColor.R * 255))
            local gSlider = createColorSlider("G", 50, math.floor(currentColor.G * 255))
            local bSlider = createColorSlider("B", 90, math.floor(currentColor.B * 255))

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    rSlider.SetDragging(false)
                    gSlider.SetDragging(false)
                    bSlider.SetDragging(false)
                end
            end)

            local function updateColor()
                local r = tonumber(rSlider.ValueLabel.Text) or 0
                local g = tonumber(gSlider.ValueLabel.Text) or 0
                local b = tonumber(bSlider.ValueLabel.Text) or 0
                currentColor = Color3.fromRGB(r, g, b)
                ColorDisplay.BackgroundColor3 = currentColor

                if config.Callback then
                    pcall(function()
                        config.Callback(currentColor)
                    end)
                end
            end

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    for _, sliderData in pairs({rSlider, gSlider, bSlider}) do
                        if sliderData.Dragging() then
                            local mouse = UserInputService:GetMouseLocation()
                            local relativePos = math.clamp((mouse.X - sliderData.Track.AbsolutePosition.X) / sliderData.Track.AbsoluteSize.X, 0, 1)
                            local value = math.floor(relativePos * 255)

                            sliderData.ValueLabel.Text = tostring(value)
                            TweenService:Create(sliderData.Fill, TweenInfo.new(0.1), {Size = UDim2.new(relativePos, 0, 1, 0)}):Play()

                            updateColor()
                        end
                    end
                end
            end)

            ColorButton.MouseButton1Click:Connect(function()
                ColorPickerPopup.Visible = not ColorPickerPopup.Visible
            end)

            local element = {
                Frame = ColorPickerFrame,
                Label = ColorPickerLabel,
                Display = ColorDisplay,
                Popup = ColorPickerPopup,
                Value = currentColor,
                ConfigKey = config.Flag,
                UpdateColors = function(self)
                    ColorPickerFrame.BackgroundColor3 = CurrentTheme.Secondary
                    ColorPickerLabel.TextColor3 = CurrentTheme.Text
                    ColorPickerPopup.BackgroundColor3 = CurrentTheme.Secondary
                end,
                SetValue = function(self, val)
                    currentColor = val
                    ColorDisplay.BackgroundColor3 = currentColor
                    rSlider.ValueLabel.Text = tostring(math.floor(val.R * 255))
                    gSlider.ValueLabel.Text = tostring(math.floor(val.G * 255))
                    bSlider.ValueLabel.Text = tostring(math.floor(val.B * 255))
                end
            }

            table.insert(Tab.Elements, element)
            return element
        end

        return Tab
    end

    local HomeTab = Window:CreateTab("Home")

    local AvatarContainer = Instance.new("Frame")
    AvatarContainer.Size = UDim2.new(1, 0, 0, 200)
    AvatarContainer.BackgroundTransparency = 1
    AvatarContainer.Parent = HomeTab.Content

    local PlayerAvatar = Instance.new("ImageLabel")
    PlayerAvatar.Size = UDim2.new(0, 120, 0, 120)
    PlayerAvatar.Position = UDim2.new(0.5, -60, 0, 10)
    PlayerAvatar.BackgroundColor3 = CurrentTheme.Border
    PlayerAvatar.BorderSizePixel = 0
    PlayerAvatar.ScaleType = Enum.ScaleType.Crop
    PlayerAvatar.Parent = AvatarContainer
    CreateUICorner(PlayerAvatar, 8)
    CreateStroke(PlayerAvatar, 2, CurrentTheme.Accent)

    local userId = LocalPlayer.UserId
    
    local success, avatarImage = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)

    if success then
        PlayerAvatar.Image = avatarImage
    else
        PlayerAvatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    end

    local WelcomeText = Instance.new("TextLabel")
    WelcomeText.Size = UDim2.new(1, 0, 0, 30)
    WelcomeText.Position = UDim2.new(0, 0, 0, 140)
    WelcomeText.BackgroundTransparency = 1
    WelcomeText.Text = "Welcome Back!"
    WelcomeText.TextColor3 = CurrentTheme.Text
    WelcomeText.TextSize = 18
    WelcomeText.Font = Enum.Font.GothamBold
    WelcomeText.Parent = AvatarContainer

    local PlayerInfo = Instance.new("TextLabel")
    PlayerInfo.Size = UDim2.new(1, 0, 0, 25)
    PlayerInfo.Position = UDim2.new(0, 0, 0, 170)
    PlayerInfo.BackgroundTransparency = 1
    PlayerInfo.Text = LocalPlayer.Name .. " | ID: " .. userId
    PlayerInfo.TextColor3 = CurrentTheme.SubText
    PlayerInfo.TextSize = 14
    PlayerInfo.Font = Enum.Font.Gotham
    PlayerInfo.Parent = AvatarContainer

    HomeTab:AddDivider("UI Configuration")

    local themeNames = Horizon:GetThemes()
    HomeTab:AddDropdown({
        Name = "Theme",
        Options = themeNames,
        Default = CurrentThemeName,
        Callback = function(selected)
            Window:UpdateTheme(selected)
        end
    })

    HomeTab:AddKeybind({
        Name = "Toggle UI Key",
        Default = Window.ToggleKey,
        Callback = function(key)
            Window.ToggleKey = key
            Window:Notify({
                Title = "Keybind Updated",
                Content = "UI toggle key set to " .. key.Name,
                Duration = 3
            })
        end
    })

    if WindowConfig.SaveConfig then
        HomeTab:AddDivider("Configuration")
        
        HomeTab:AddButton({
            Name = "Save Configuration",
            Callback = function()
                Window:SaveConfig()
            end
        })

        HomeTab:AddButton({
            Name = "Load Configuration",
            Callback = function()
                Window:LoadConfig()
            end
        })
    end

    HomeTab:AddDivider("Information")
    HomeTab:AddParagraph({
        Title = "Horizon UI Library",
        Content = "Got modify by Razz"
    })

    if WindowConfig.SaveConfig then
        pcall(function()
            Window:LoadConfig()
        end)
    end

    task.spawn(function()
        wait(0.5)
        Window:Notify({
            Title = "Horizon UI Library",
            Content = "This UI is powered by Horizon.",
            Duration = 8
        })
        
        wait(3)
        Window:Notify({
            Title = "UI Controls",
            Content = "Tekan Kontrol Kanan untuk menampilkan/menyembunyikan UI",
            Duration = 5
        })
    end)

    return Window
end

return Horizon

local Window = Horizon:CreateWindow({
    Name = "Razz",
    Theme = "Purple",
    Size = UDim2.new(0, 600, 0, 450),
    ToggleKey = Enum.KeyCode.F1,
    SaveConfig = true,
    ConfigFolder = "_Config",
    Resizable = true
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = false
local ESPObjects = {}
local BoxESPEnabled = false
local NameESPEnabled = false
local DistanceESPEnabled = false
local HealthESPEnabled = false
local TracerESPEnabled = false
local TeamCheckEnabled = false

local AimbotEnabled = false
local AimbotFOV = 100
local AimbotTarget = "Head"
local AimbotKeyEnum = Enum.KeyCode.E
local AimbotKeyType = "Keyboard"
local UseKeybind = true
local UseFOVCircle = true
local FOVCircle = nil
local MouseButtonDown = false
local CurrentMouseButton = Enum.UserInputType.MouseButton1

local SilentAimEnabled = false
local SilentAimFOV = 80
local HeadshotChance = 80
local HitChance = 100
local SilentAimFOVCircle = nil
local UseSilentFOVCircle = true
local SilentPrediction = true
local SilentVisibilityCheck = true
local SilentAimKeyEnum = Enum.KeyCode.Q
local SilentAimKeyType = "Keyboard"
local UseSilentKeybind = true
local SilentMouseButtonDown = false
local CurrentSilentMouseButton = Enum.UserInputType.MouseButton2

local WalkspeedEnabled = false
local WalkspeedValue = 16
local OriginalWalkspeed = 16
local SpeedMultiplierMode = false
local SpeedMultiplier = 1.5
local BypassSpeedLimit = false
local JumpPowerEnabled = false
local JumpPowerValue = 50
local OriginalJumpPower = 50
local NoclipEnabled = false

local MOUSE_BUTTONS = {
    ["Left Click"] = Enum.UserInputType.MouseButton1,
    ["Right Click"] = Enum.UserInputType.MouseButton2,
    ["Middle Click"] = Enum.UserInputType.MouseButton3,
}

local function createFOVCircle()
    if FOVCircle then
        FOVCircle:Remove()
    end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 50
    FOVCircle.Radius = AimbotFOV
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Transparency = 1
    FOVCircle.Visible = false
    FOVCircle.Filled = false
end

local function createSilentFOVCircle()
    if SilentAimFOVCircle then
        SilentAimFOVCircle:Remove()
    end
    
    SilentAimFOVCircle = Drawing.new("Circle")
    SilentAimFOVCircle.Thickness = 2
    SilentAimFOVCircle.NumSides = 50
    SilentAimFOVCircle.Radius = SilentAimFOV
    SilentAimFOVCircle.Color = Color3.fromRGB(255, 100, 100)
    SilentAimFOVCircle.Transparency = 1
    SilentAimFOVCircle.Visible = false
    SilentAimFOVCircle.Filled = false
end

createFOVCircle()
createSilentFOVCircle()

local function getCharacterPart(character, partName)
    if partName == "Head" then
        return character:FindFirstChild("Head")
    elseif partName == "Torso" then
        return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    elseif partName == "HumanoidRootPart" then
        return character:FindFirstChild("HumanoidRootPart")
    elseif partName == "Left Arm" then
        return character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm")
    elseif partName == "Right Arm" then
        return character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")
    elseif partName == "Left Leg" then
        return character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg")
    elseif partName == "Right Leg" then
        return character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
    end
    return nil
end

local function isTeamMate(player)
    if not TeamCheckEnabled then return false end
    if not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function isVisible(targetPart)
    if not SilentVisibilityCheck then return true end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        if hitPart:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    
    return true
end

local function createESP(player)
    if player == LocalPlayer then return end
    
    local esp = {
        Player = player,
        Box = nil,
        Name = nil,
        Distance = nil,
        Health = nil,
        Tracer = nil
    }
    
    esp.Box = Drawing.new("Square")
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    esp.Box.Color = Color3.fromRGB(255, 255, 255)
    esp.Box.Visible = false
    esp.Box.Transparency = 1
    
    esp.Name = Drawing.new("Text")
    esp.Name.Size = 18
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Visible = false
    esp.Name.Transparency = 1
    
    esp.Distance = Drawing.new("Text")
    esp.Distance.Size = 16
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.fromRGB(255, 255, 255)
    esp.Distance.Visible = false
    esp.Distance.Transparency = 1
    
    esp.Health = Drawing.new("Text")
    esp.Health.Size = 16
    esp.Health.Center = true
    esp.Health.Outline = true
    esp.Health.Color = Color3.fromRGB(0, 255, 0)
    esp.Health.Visible = false
    esp.Health.Transparency = 1
    
    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Thickness = 1
    esp.Tracer.Color = Color3.fromRGB(255, 255, 255)
    esp.Tracer.Visible = false
    esp.Tracer.Transparency = 1
    
    return esp
end

local function updateESP(esp)
    local player = esp.Player
    local character = player.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
        esp.Box.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Health.Visible = false
        esp.Tracer.Visible = false
        return
    end
    
    if isTeamMate(player) then
        esp.Box.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Health.Visible = false
        esp.Tracer.Visible = false
        return
    end
    
    local hrp = character.HumanoidRootPart
    local head = character:FindFirstChild("Head")
    local humanoid = character.Humanoid
    
    local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    
    if onScreen then
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        
        local height = math.abs(headPos.Y - legPos.Y)
        local width = height / 2
        
        if BoxESPEnabled and ESPEnabled then
            esp.Box.Size = Vector2.new(width, height)
            esp.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
            esp.Box.Visible = true
            esp.Box.Color = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
        else
            esp.Box.Visible = false
        end
        
        if NameESPEnabled and ESPEnabled then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(vector.X, headPos.Y - 20)
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        if DistanceESPEnabled and ESPEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
            esp.Distance.Text = distance .. "m"
            esp.Distance.Position = Vector2.new(vector.X, legPos.Y + 5)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        if HealthESPEnabled and ESPEnabled then
            local health = math.floor(humanoid.Health)
            local maxHealth = math.floor(humanoid.MaxHealth)
            esp.Health.Text = health .. "/" .. maxHealth
            esp.Health.Position = Vector2.new(vector.X, vector.Y)
            esp.Health.Color = Color3.fromRGB(255 - (health / maxHealth) * 255, (health / maxHealth) * 255, 0)
            esp.Health.Visible = true
        else
            esp.Health.Visible = false
        end
        
        if TracerESPEnabled and ESPEnabled then
            esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(vector.X, vector.Y)
            esp.Tracer.Visible = true
            esp.Tracer.Color = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
        else
            esp.Tracer.Visible = false
        end
    else
        esp.Box.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Health.Visible = false
        esp.Tracer.Visible = false
    end
end

local function removeESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Box then ESPObjects[player].Box:Remove() end
        if ESPObjects[player].Name then ESPObjects[player].Name:Remove() end
        if ESPObjects[player].Distance then ESPObjects[player].Distance:Remove() end
        if ESPObjects[player].Health then ESPObjects[player].Health:Remove() end
        if ESPObjects[player].Tracer then ESPObjects[player].Tracer:Remove() end
        ESPObjects[player] = nil
    end
end

local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if isTeamMate(player) then continue end
            
            local targetPart = getCharacterPart(player.Character, AimbotTarget)
            if not targetPart then continue end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen then
                local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                
                if UseFOVCircle then
                    if distance < AimbotFOV and distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                else
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function isSilentAimKeyPressed()
    if SilentAimKeyType == "Mouse" then
        return SilentMouseButtonDown
    else
        return UserInputService:IsKeyDown(SilentAimKeyEnum)
    end
end

local function getSilentAimTarget()
    if not SilentAimEnabled then return nil end
    
    if UseSilentKeybind and not isSilentAimKeyPressed() then
        return nil
    end
    
    if math.random(1, 100) > HitChance then
        return nil
    end
    
    local closestPlayer = nil
    local shortestDistance = math.huge
    local closestPart = nil
    
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if isTeamMate(player) then continue end
            
            local useHead = math.random(1, 100) <= HeadshotChance
            local targetPart = nil
            
            if useHead then
                targetPart = getCharacterPart(player.Character, "Head")
            else
                targetPart = getCharacterPart(player.Character, "Torso")
            end
            
            if not targetPart then continue end
            
            if SilentVisibilityCheck and not isVisible(targetPart) then
                continue
            end
            
            local targetPos = targetPart.Position
            if SilentPrediction and targetPart.Parent:FindFirstChild("HumanoidRootPart") then
                local hrp = targetPart.Parent.HumanoidRootPart
                local velocity = hrp.AssemblyLinearVelocity or hrp.Velocity
                local distance = (targetPos - Camera.CFrame.Position).Magnitude
                local timeToHit = distance / 1000
                targetPos = targetPos + (velocity * timeToHit)
            end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
            
            if onScreen then
                local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                
                if UseSilentFOVCircle then
                    if distance < SilentAimFOV and distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                        closestPart = targetPart
                    end
                else
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                        closestPart = targetPart
                    end
                end
            end
        end
    end
    
    return closestPart
end

if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(...)
        local args = {...}
        local method = getnamecallmethod()
        
        if SilentAimEnabled and (method == "FireServer" or method == "InvokeServer") then
            local silentTarget = getSilentAimTarget()
            
            if silentTarget then
                for i, arg in pairs(args) do
                    if typeof(arg) == "Vector3" then
                        if SilentPrediction and silentTarget.Parent:FindFirstChild("HumanoidRootPart") then
                            local hrp = silentTarget.Parent.HumanoidRootPart
                            local velocity = hrp.AssemblyLinearVelocity or hrp.Velocity
                            local distance = (silentTarget.Position - Camera.CFrame.Position).Magnitude
                            local timeToHit = distance / 1000
                            args[i] = silentTarget.Position + (velocity * timeToHit)
                        else
                            args[i] = silentTarget.Position
                        end
                    elseif typeof(arg) == "CFrame" then
                        args[i] = CFrame.new(Camera.CFrame.Position, silentTarget.Position)
                    elseif typeof(arg) == "Ray" then
                        args[i] = Ray.new(Camera.CFrame.Position, (silentTarget.Position - Camera.CFrame.Position).Unit * 1000)
                    end
                end
            end
        end
        
        return oldNamecall(...)
    end)
end

local function isAimbotKeyPressed()
    if AimbotKeyType == "Mouse" then
        return MouseButtonDown
    else
        return UserInputService:IsKeyDown(AimbotKeyEnum)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if AimbotKeyType == "Mouse" and input.UserInputType == CurrentMouseButton then
        MouseButtonDown = true
    end
    if SilentAimKeyType == "Mouse" and input.UserInputType == CurrentSilentMouseButton then
        SilentMouseButtonDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if AimbotKeyType == "Mouse" and input.UserInputType == CurrentMouseButton then
        MouseButtonDown = false
    end
    if SilentAimKeyType == "Mouse" and input.UserInputType == CurrentSilentMouseButton then
        SilentMouseButtonDown = false
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.5)
    local humanoid = character:WaitForChild("Humanoid")
    if humanoid then
        OriginalWalkspeed = humanoid.WalkSpeed
        OriginalJumpPower = humanoid.JumpPower
    end
end)

Players.PlayerAdded:Connect(function(player)
    ESPObjects[player] = createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        ESPObjects[player] = createESP(player)
    end
end

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    OriginalWalkspeed = LocalPlayer.Character.Humanoid.WalkSpeed
    OriginalJumpPower = LocalPlayer.Character.Humanoid.JumpPower
end

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for player, esp in pairs(ESPObjects) do
            if player and player.Parent then
                updateESP(esp)
            else
                removeESP(player)
            end
        end
    end
    
    if FOVCircle then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Radius = AimbotFOV
        FOVCircle.Visible = AimbotEnabled and UseFOVCircle
    end
    
    if SilentAimFOVCircle then
        local mousePos = UserInputService:GetMouseLocation()
        SilentAimFOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        SilentAimFOVCircle.Radius = SilentAimFOV
        SilentAimFOVCircle.Visible = SilentAimEnabled and UseSilentFOVCircle
    end
    
    local shouldAim = false
    if UseKeybind then
        shouldAim = AimbotEnabled and isAimbotKeyPressed()
    else
        shouldAim = AimbotEnabled
    end
    
    if shouldAim then
        local target = getClosestPlayerToMouse()
        if target and target.Character then
            local targetPart = getCharacterPart(target.Character, AimbotTarget)
            if targetPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            end
        end
    end
    
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        
        if WalkspeedEnabled then
            if SpeedMultiplierMode then
                local newSpeed = OriginalWalkspeed * SpeedMultiplier
                if BypassSpeedLimit then
                    humanoid.WalkSpeed = newSpeed
                else
                    humanoid.WalkSpeed = math.min(newSpeed, 500)
                end
            else
                humanoid.WalkSpeed = WalkspeedValue
            end
        else
            humanoid.WalkSpeed = OriginalWalkspeed
        end
        
        if JumpPowerEnabled then
            humanoid.JumpPower = JumpPowerValue
        else
            humanoid.JumpPower = OriginalJumpPower
        end
    end
end)

local ESPTab = Window:CreateTab("ESP")

ESPTab:AddParagraph({
    Title = "ESP Controls",
    Content = "Toggle different ESP features to see players through walls and track their info."
})

ESPTab:AddDivider("Main ESP")

ESPTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        ESPEnabled = Value
    end,
})

ESPTab:AddToggle({
    Name = "Box ESP",
    Default = false,
    Flag = "BoxESP",
    Callback = function(Value)
        BoxESPEnabled = Value
    end,
})

ESPTab:AddToggle({
    Name = "Name ESP",
    Default = false,
    Flag = "NameESP",
    Callback = function(Value)
        NameESPEnabled = Value
    end,
})

ESPTab:AddToggle({
    Name = "Distance ESP",
    Default = false,
    Flag = "DistanceESP",
    Callback = function(Value)
        DistanceESPEnabled = Value
    end,
})

ESPTab:AddToggle({
    Name = "Health ESP",
    Default = false,
    Flag = "HealthESP",
    Callback = function(Value)
        HealthESPEnabled = Value
    end,
})

ESPTab:AddToggle({
    Name = "Tracer ESP",
    Default = false,
    Flag = "TracerESP",
    Callback = function(Value)
        TracerESPEnabled = Value
    end,
})

ESPTab:AddDivider("Options")

ESPTab:AddToggle({
    Name = "Team Check",
    Default = false,
    Flag = "TeamCheck",
    Callback = function(Value)
        TeamCheckEnabled = Value
    end,
})

local AimbotTab = Window:CreateTab("Aimbot")

AimbotTab:AddParagraph({
    Title = "Aimbot Settings",
    Content = "Advanced aimbot with customizable targeting and FOV controls."
})

AimbotTab:AddDivider("Main Settings")

AimbotTab:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Flag = "Aimbot",
    Callback = function(Value)
        AimbotEnabled = Value
    end,
})

AimbotTab:AddDropdown({
    Name = "Target Part",
    Options = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    Default = "Head",
    Flag = "AimbotTarget",
    Callback = function(Option)
        AimbotTarget = Option
    end,
})

AimbotTab:AddDivider("FOV Settings")

AimbotTab:AddToggle({
    Name = "Use FOV Circle",
    Default = true,
    Flag = "UseFOV",
    Callback = function(Value)
        UseFOVCircle = Value
    end,
})

AimbotTab:AddSlider({
    Name = "FOV Size",
    Min = 10,
    Max = 500,
    Default = 100,
    Increment = 5,
    Flag = "FOV",
    Callback = function(Value)
        AimbotFOV = Value
    end,
})

AimbotTab:AddDivider("Keybind Settings")

AimbotTab:AddToggle({
    Name = "Use Keybind",
    Default = true,
    Flag = "UseKeybind",
    Callback = function(Value)
        UseKeybind = Value
    end,
})

AimbotTab:AddDropdown({
    Name = "Bind Type",
    Options = {"Keyboard", "Mouse"},
    Default = "Keyboard",
    Flag = "BindType",
    Callback = function(Option)
        AimbotKeyType = Option
        MouseButtonDown = false
    end,
})

AimbotTab:AddKeybind({
    Name = "Keyboard Key",
    Default = Enum.KeyCode.E,
    Flag = "AimbotKeybind",
    Callback = function(Key)
        AimbotKeyEnum = Key
    end,
})

AimbotTab:AddDropdown({
    Name = "Mouse Button",
    Options = {"Left Click", "Right Click", "Middle Click"},
    Default = "Left Click",
    Flag = "MouseButton",
    Callback = function(Option)
        CurrentMouseButton = MOUSE_BUTTONS[Option]
        MouseButtonDown = false
    end,
})

AimbotTab:AddDivider("READ")

AimbotTab:AddParagraph({
    Title = "Beware",
    Content = "Use at your own risk. Aimbot should only be used when raging and with the chance of being banned kept in mind."
})

local SilentAimTab = Window:CreateTab("Silent Aim")

SilentAimTab:AddParagraph({
    Title = "Silent Aim System",
    Content = "Automatically redirects your shots to hit enemies with customizable headshot chance."
})

SilentAimTab:AddDivider("Main Settings")

SilentAimTab:AddToggle({
    Name = "Enable Silent Aim",
    Default = false,
    Flag = "SilentAim",
    Callback = function(Value)
        SilentAimEnabled = Value
        if Value then
            if hookmetamethod then
                Window:Notify({
                    Title = "Silent Aim Active",
                    Content = "Hooks initialized - may not work in all games",
                    Duration = 5,
                })
            else
                Window:Notify({
                    Title = "Silent Aim Unavailable",
                    Content = "Your executor doesn't support silent aim",
                    Duration = 5,
                })
                SilentAimEnabled = false
            end
        end
    end,
})

SilentAimTab:AddSlider({
    Name = "Headshot Chance",
    Min = 0,
    Max = 100,
    Default = 80,
    Increment = 1,
    Flag = "HeadshotChance",
    Callback = function(Value)
        HeadshotChance = Value
    end,
})

SilentAimTab:AddSlider({
    Name = "Hit Chance",
    Min = 0,
    Max = 100,
    Default = 100,
    Increment = 1,
    Flag = "HitChance",
    Callback = function(Value)
        HitChance = Value
    end,
})

SilentAimTab:AddDivider("FOV Settings")

SilentAimTab:AddToggle({
    Name = "Use FOV Circle",
    Default = true,
    Flag = "SilentFOV",
    Callback = function(Value)
        UseSilentFOVCircle = Value
    end,
})

SilentAimTab:AddSlider({
    Name = "FOV Size",
    Min = 10,
    Max = 500,
    Default = 80,
    Increment = 5,
    Flag = "SilentFOVSize",
    Callback = function(Value)
        SilentAimFOV = Value
    end,
})

SilentAimTab:AddDivider("Keybind Settings")

SilentAimTab:AddToggle({
    Name = "Use Keybind",
    Default = true,
    Flag = "UseSilentKeybind",
    Callback = function(Value)
        UseSilentKeybind = Value
        Window:Notify({
            Title = "Silent Aim Keybind",
            Content = Value and "Hold key to use silent aim" or "Always using silent aim",
            Duration = 3,
        })
    end,
})

SilentAimTab:AddDropdown({
    Name = "Bind Type",
    Options = {"Keyboard", "Mouse"},
    Default = "Keyboard",
    Flag = "SilentBindType",
    Callback = function(Option)
        SilentAimKeyType = Option
        SilentMouseButtonDown = false
        Window:Notify({
            Title = "Silent Aim Bind Type",
            Content = "Now using " .. Option .. " - set your key below",
            Duration = 3,
        })
    end,
})

SilentAimTab:AddKeybind({
    Name = "Keyboard Key",
    Default = Enum.KeyCode.Q,
    Flag = "SilentAimKeybind",
    Callback = function(Key)
        SilentAimKeyEnum = Key
    end,
})

SilentAimTab:AddDropdown({
    Name = "Mouse Button",
    Options = {"Left Click", "Right Click", "Middle Click"},
    Default = "Right Click",
    Flag = "SilentMouseButton",
    Callback = function(Option)
        CurrentSilentMouseButton = MOUSE_BUTTONS[Option]
        SilentMouseButtonDown = false
    end,
})

SilentAimTab:AddDivider("Options")

SilentAimTab:AddToggle({
    Name = "Visibility Check",
    Default = true,
    Flag = "VisCheck",
    Callback = function(Value)
        SilentVisibilityCheck = Value
    end,
})

SilentAimTab:AddToggle({
    Name = "Prediction",
    Default = true,
    Flag = "Prediction",
    Callback = function(Value)
        SilentPrediction = Value
    end,
})

SilentAimTab:AddDivider("Info")

SilentAimTab:AddLabel("Silent aim hooks into shooting remotes")
SilentAimTab:AddLabel("May not work in all games (game-dependent)")
SilentAimTab:AddLabel("Headshot %: Chance to aim at head")
SilentAimTab:AddLabel("Hit %: Chance to land shots (legit)")
SilentAimTab:AddLabel("Prediction: Lead moving targets")
SilentAimTab:AddLabel("Red circle = Silent aim FOV range")

local MovementTab = Window:CreateTab("Movement")

MovementTab:AddParagraph({
    Title = "Movement Enhancements",
    Content = "Boost your movement speed, jump height, and walk through walls."
})

MovementTab:AddDivider("Speed")

MovementTab:AddToggle({
    Name = "Speed Boost",
    Default = false,
    Flag = "Speed",
    Callback = function(Value)
        WalkspeedEnabled = Value
        if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = OriginalWalkspeed
        end
    end,
})

MovementTab:AddToggle({
    Name = "Use Multiplier Mode",
    Default = false,
    Flag = "MultiplierMode",
    Callback = function(Value)
        SpeedMultiplierMode = Value
        Window:Notify({
            Title = "Speed Mode",
            Content = Value and "Using speed multiplier" or "Using set speed value",
            Duration = 3,
        })
    end,
})

MovementTab:AddSlider({
    Name = "Set Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Increment = 1,
    Flag = "WalkspeedValue",
    Callback = function(Value)
        WalkspeedValue = Value
    end,
})

MovementTab:AddSlider({
    Name = "Speed Multiplier",
    Min = 0.1,
    Max = 10,
    Default = 1.5,
    Increment = 0.1,
    Flag = "SpeedMultiplier",
    Callback = function(Value)
        SpeedMultiplier = Value
    end,
})

MovementTab:AddToggle({
    Name = "Bypass Speed Limit",
    Default = false,
    Flag = "BypassLimit",
    Callback = function(Value)
        BypassSpeedLimit = Value
        Window:Notify({
            Title = "Speed Limit",
            Content = Value and "Speed limit bypassed (use carefully!)" or "Speed limit enforced",
            Duration = 3,
        })
    end,
})

MovementTab:AddDivider("Jump")

MovementTab:AddToggle({
    Name = "Jump Boost",
    Default = false,
    Flag = "Jump",
    Callback = function(Value)
        JumpPowerEnabled = Value
        if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = OriginalJumpPower
        end
    end,
})

MovementTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Increment = 5,
    Flag = "JumpValue",
    Callback = function(Value)
        JumpPowerValue = Value
    end,
})

MovementTab:AddDivider("Noclip")

MovementTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Flag = "Noclip",
    Callback = function(Value)
        NoclipEnabled = Value
        if not Value and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end,
})

local MiscTab = Window:CreateTab("Misc")

MiscTab:AddParagraph({
    Title = "Miscellaneous",
    Content = "Extra utilities and server options."
})

MiscTab:AddDivider("Server")

MiscTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        Window:Notify({
            Title = "Rejoining",
            Content = "Rejoining server in 2 seconds...",
            Duration = 2,
        })
        wait(2)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

local AboutTab = Window:CreateTab("About")

AboutTab:AddParagraph({
    Title = "RAZZ - Universal ESP & Aimbot",
    Content = "Made by Razz."
})

AboutTab:AddDivider("Features")

AboutTab:AddLabel("✓ Box, Name, Distance, Health & Tracer ESP")
AboutTab:AddLabel("✓ Customizable Aimbot with FOV circle")
AboutTab:AddLabel("✓ Silent Aim with headshot chance")
AboutTab:AddLabel("✓ Speed multiplier mode (suggested by MCVclone)")
AboutTab:AddLabel("✓ Target specific body parts")
AboutTab:AddLabel("✓ Keyboard & Mouse button support")
AboutTab:AddLabel("✓ Team check to avoid teammates")
AboutTab:AddLabel("✓ Speed and Jump boost")
AboutTab:AddLabel("✓ Noclip to walk through walls")

AboutTab:AddDivider("Info")

AboutTab:AddParagraph({
    Title = "Important",
    Content = "This script is KEYLESS. And then got modify by Razz"
})

Window:Notify({
    Title = "RAZZ V1 Loaded",
    Content = "I Got You Nigga",
    Duration = 5,
})
```