local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local spring = require(game:GetService("ReplicatedStorage"):WaitForChild("modules"):WaitForChild("spring"))
local theme = require(game:GetService("ReplicatedStorage").modules.phoneTheme)

-- Phone states enum
local PhoneState = {
    OFF = "off",        -- Phone is peeking, screen off
    HOME = "home",      -- Home screen visible
    APP = "app"         -- Specific app running
}

-- Pure function to create initial state
local function createInitialState()
    return {
        isShown = false,
        screenState = PhoneState.OFF,
        currentApp = nil,
        position = UDim2.fromScale(0.85, 0.99) -- PEEK_POSITION
    }
end

-- Constants
local POSITIONS = {
    SHOWN = UDim2.fromScale(0.85, 0.5),
    PEEK = UDim2.fromScale(0.85, 0.99)
}

-- Pure functions for state transformations
local function getNextPhoneState(currentState)
    if currentState.isShown then
        return {
            isShown = false,
            screenState = PhoneState.OFF,
            currentApp = currentState.currentApp,
            position = POSITIONS.PEEK
        }
    else
        return {
            isShown = true,
            screenState = currentState.currentApp and PhoneState.APP or PhoneState.HOME,
            currentApp = currentState.currentApp,
            position = POSITIONS.SHOWN
        }
    end
end

local function getNextAppState(currentState, appName)
    return {
        isShown = currentState.isShown,
        screenState = PhoneState.APP,
        currentApp = appName,
        position = currentState.position
    }
end

local function getHomeState(currentState)
    return {
        isShown = currentState.isShown,
        screenState = PhoneState.HOME,
        currentApp = nil,
        position = currentState.position
    }
end

-- Pure functions for UI updates
local function updatePhonePosition(frame, position)
    spring.target(frame, 0.8, 1, {
        Position = position
    })
end

local function updateScreenVisibility(screen, state)
    local isOn = state.isShown
    
    spring.target(screen:WaitForChild("ScreenOverlay"), isOn and 0.3 or 0.2, isOn and 0.8 or 0.9, {
        BackgroundTransparency = isOn and 1 or 0
    })
    
    spring.target(screen, isOn and 0.3 or 0.2, isOn and 0.8 or 0.9, {
        BackgroundTransparency = isOn and 0 or 1
    })
    
    for _, child in ipairs(screen:GetChildren()) do
        if child:IsA("Frame") then
            child.Visible = isOn
            
            spring.target(child, isOn and 0.3 or 0.2, isOn and 0.8 or 0.9, {
                BackgroundTransparency = child.BackgroundTransparency < 1 and (isOn and 0 or 1) or 1
            })
            
            for _, descendant in ipairs(child:GetDescendants()) do
                if descendant:IsA("GuiObject") then
                    spring.target(descendant, isOn and 0.3 or 0.2, isOn and 0.8 or 0.9, {
                        BackgroundTransparency = descendant.BackgroundTransparency < 1 and (isOn and 0 or 1) or 1,
                        TextTransparency = descendant:IsA("TextLabel") and (isOn and 0 or 1) or descendant.TextTransparency,
                        ImageTransparency = descendant:IsA("ImageLabel") and (isOn and 0 or 1) or descendant.ImageTransparency
                    })
                end
            end
        end
    end
end

local function updateAppVisibility(screen, state)
    if state.isShown then
        local homeScreen = screen:WaitForChild("HomeScreen")
        homeScreen.Visible = state.screenState == PhoneState.HOME
        
        for _, app in ipairs(screen:GetChildren()) do
            if app:IsA("Frame") and app.Name:match("App$") then
                app.Visible = state.screenState == PhoneState.APP and app.Name == state.currentApp
            end
        end
    end
end

-- UI effect functions
local function addBouncyEffect(button)
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
                Size = button.Size
            }
        )
    end)
end

-- Main phone controller
local function createPhoneController()
    -- Initialize references
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local PhoneUI = playerGui:WaitForChild("PhoneUI")
    local PhoneFrame = PhoneUI:WaitForChild("PhoneFrame")
    local Screen = PhoneFrame:WaitForChild("Screen")
    local HomeScreen = Screen:WaitForChild("HomeScreen")
    local ScreenOverlay = Screen:WaitForChild("ScreenOverlay")
    
    -- Initialize state
    local state = createInitialState()
    
    -- State update function
    local function updateState(newState)
        -- Update internal state
        state = newState
        
        -- Update UI based on new state
        updatePhonePosition(PhoneFrame, state.position)
        updateScreenVisibility(Screen, state)
        updateAppVisibility(Screen, state)
    end
    
    -- Input handlers
    local function handlePhoneClick()
        updateState(getNextPhoneState(state))
    end
    
    local function handleOutsideClick(input)
        if not state.isShown then return end
        
        local position = input.Position
        local phoneFrame = PhoneFrame.AbsolutePosition
        local phoneSize = PhoneFrame.AbsoluteSize
        
        if position.X < phoneFrame.X or 
           position.X > phoneFrame.X + phoneSize.X or
           position.Y < phoneFrame.Y or
           position.Y > phoneFrame.Y + phoneSize.Y then
            updateState(getNextPhoneState(state))
        end
    end
    
    -- Initialize UI and connect app buttons
    for _, button in ipairs(HomeScreen:GetChildren()) do
        if button:IsA("ImageButton") then
            -- Add click handler for app launching
            button.MouseButton1Click:Connect(function()
                if state.screenState == PhoneState.HOME then
                    updateState(getNextAppState(state, button.Name))
                end
            end)
            addBouncyEffect(button)
        end
    end
    
    -- Connect events
    PhoneFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            handlePhoneClick()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            handleOutsideClick(input)
        end
    end)
    
    -- Screen size adjustment
    local function adjustForScreenSize()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local aspectRatio = viewportSize.X / viewportSize.Y
        
        POSITIONS.PEEK = UDim2.fromScale(0.85, aspectRatio < 1.2 and 0.985 or 0.99)
        
        if not state.isShown then
            updatePhonePosition(PhoneFrame, POSITIONS.PEEK)
        end
    end
    
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adjustForScreenSize)
    adjustForScreenSize()
    
    -- Initialize UI state
    updateState(state)
    
    -- Return controller interface
    return {
        getState = function() return table.clone(state) end,
        switchApp = function(appName) 
            updateState(getNextAppState(state, appName))
        end,
        goHome = function()
            updateState(getHomeState(state))
        end,
        getCurrentApp = function()
            return state.currentApp
        end,
        isShown = function()
            return state.isShown
        end
    }
end

-- Create and store controller
local phoneController = createPhoneController()
return phoneController 