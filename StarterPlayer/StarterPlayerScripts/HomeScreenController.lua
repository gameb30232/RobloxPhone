local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local theme = require(game:GetService("ReplicatedStorage").modules.phoneTheme)
local spring = require(game:GetService("ReplicatedStorage").modules.spring)

local HomeScreenController = {}

-- Get UI references
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local PhoneUI = playerGui:WaitForChild("PhoneUI")
local Screen = PhoneUI.PhoneFrame:WaitForChild("Screen")
local HomeScreen = Screen:WaitForChild("HomeScreen")

-- App registry state
local registeredApps = {}

-- Pure function to create app button
local function createAppButton(appInfo)
    local button = Instance.new("ImageButton")
    button.Name = appInfo.name
    button.BackgroundColor3 = theme.colors.primary
    button.Size = UDim2.fromScale(0.2, 0.1) -- Size will be controlled by UIGridLayout
    button.Image = appInfo.icon
    button.BackgroundTransparency = 0
    button.LayoutOrder = appInfo.order or #registeredApps + 1
    
    -- Add clay styling
    local corner = Instance.new("UICorner")
    corner.CornerRadius = theme.cornerRadius.medium
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.colors.accent
    stroke.Thickness = theme.strokeThickness.medium
    stroke.Parent = button
    
    -- Add label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = appInfo.displayName
    label.TextColor3 = theme.colors.text
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 0.3)
    label.Position = UDim2.fromScale(0.5, 1.2)
    label.AnchorPoint = Vector2.new(0.5, 1)
    label.TextScaled = true
    label.Font = Enum.Font.Cartoon
    label.Parent = button
    
    -- Add bounce effect
    button.MouseEnter:Connect(function()
        spring.target(button,
            theme.animations.bounce.springParams.frequency,
            theme.animations.bounce.springParams.dampingRatio,
            {
                Size = button.Size * UDim2.fromScale(1.1, 1.1)
            }
        )
    end)
    
    button.MouseLeave:Connect(function()
        spring.target(button,
            theme.animations.bounce.springParams.frequency,
            theme.animations.bounce.springParams.dampingRatio,
            {
                Size = UDim2.fromScale(0.2, 0.1)
            }
        )
    end)
    
    return button
end

-- Public methods
function HomeScreenController:registerApp(appInfo)
    if not appInfo.name or not appInfo.icon or not appInfo.displayName then
        warn("App registration failed: missing required info")
        return
    end
    
    -- Create immutable app registration
    local newApp = table.freeze({
        name = appInfo.name,
        icon = appInfo.icon,
        displayName = appInfo.displayName,
        order = appInfo.order or #registeredApps + 1,
        button = createAppButton(appInfo)
    })
    
    registeredApps[appInfo.name] = newApp
    newApp.button.Parent = HomeScreen
    
    -- Connect click handler
    newApp.button.MouseButton1Click:Connect(function()
        if appInfo.onActivated then
            appInfo.onActivated()
        end
    end)
    
    return newApp
end

function HomeScreenController:unregisterApp(appName)
    local app = registeredApps[appName]
    if app and app.button then
        app.button:Destroy()
    end
    registeredApps[appName] = nil
end

function HomeScreenController:getRegisteredApps()
    return table.freeze(table.clone(registeredApps))
end

return HomeScreenController 