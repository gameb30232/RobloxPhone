local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local PhoneUI = playerGui:WaitForChild("PhoneUI")
local PhoneFrame = PhoneUI:WaitForChild("PhoneFrame")
local Screen = PhoneFrame:WaitForChild("Screen")
local HomeScreen = Screen:WaitForChild("HomeScreen")

-- App states
local currentApp = nil
local apps = {}

-- Function to load an app
local function loadApp(appName)
    if currentApp then
        -- Transition out current app
        local fadeOut = TweenService:Create(currentApp, TweenInfo.new(0.3), {
            BackgroundTransparency = 1
        })
        fadeOut:Play()
        fadeOut.Completed:Wait()
        currentApp.Visible = false
    end
    
    -- Show new app
    local app = apps[appName]
    if app then
        app.BackgroundTransparency = 1
        app.Visible = true
        local fadeIn = TweenService:Create(app, TweenInfo.new(0.3), {
            BackgroundTransparency = 0
        })
        fadeIn:Play()
        currentApp = app
    end
end

-- Connect app buttons
for _, button in ipairs(HomeScreen:GetChildren()) do
    if button:IsA("ImageButton") then
        button.MouseButton1Click:Connect(function()
            loadApp(button.Name)
        end)
    end
end

-- Initialize HomeScreen
HomeScreen.Visible = true 