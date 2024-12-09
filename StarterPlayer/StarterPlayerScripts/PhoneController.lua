local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local spring = require(game:GetService("ReplicatedStorage"):WaitForChild("modules"):WaitForChild("spring"))
local theme = require(game:GetService("ReplicatedStorage").modules.phoneTheme)

-- Wait for player and UI to load
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local PhoneUI = playerGui:WaitForChild("PhoneUI")
local PhoneFrame = PhoneUI:WaitForChild("PhoneFrame")
local Screen = PhoneFrame:WaitForChild("Screen")

-- Position settings
local SHOWN_POSITION = UDim2.fromScale(0.85, 0.5)  -- Phone fully visible
local PEEK_POSITION = UDim2.fromScale(0.85, 0.99)  -- Only shows a tiny bit at the top

-- State
local isShown = false

-- Function to animate the phone using spring
local function setPhonePosition(position)
    spring.target(PhoneFrame, 0.8, 1, {
        Position = position
    })
end

-- Function to toggle screen state
local function setScreenState(on)
    if on then
        spring.target(Screen, 0.3, 0.8, {
            BackgroundTransparency = 0
        })
        -- Fade in all children
        for _, child in ipairs(Screen:GetDescendants()) do
            if child:IsA("GuiObject") then
                spring.target(child, 0.3, 0.8, {
                    BackgroundTransparency = child.BackgroundTransparency < 1 and 0 or 1,
                    TextTransparency = child:IsA("TextLabel") and 0 or child.TextTransparency,
                    ImageTransparency = child:IsA("ImageLabel") and 0 or child.ImageTransparency
                })
            end
        end
    else
        spring.target(Screen, 0.2, 0.9, {
            BackgroundTransparency = 0.8
        })
        -- Fade out all children
        for _, child in ipairs(Screen:GetDescendants()) do
            if child:IsA("GuiObject") then
                spring.target(child, 0.2, 0.9, {
                    BackgroundTransparency = 1,
                    TextTransparency = 1,
                    ImageTransparency = 1
                })
            end
        end
    end
end

-- Function to handle phone visibility states
local function togglePhone()
    isShown = not isShown
    setPhonePosition(isShown and SHOWN_POSITION or PEEK_POSITION)
    setScreenState(isShown)
end

-- Handle clicking outside the phone
local function handleOutsideClick(input)
    if not isShown then return end
    
    local position = input.Position
    local phoneFrame = PhoneFrame.AbsolutePosition
    local phoneSize = PhoneFrame.AbsoluteSize
    
    -- Check if click is outside phone bounds
    if position.X < phoneFrame.X or 
       position.X > phoneFrame.X + phoneSize.X or
       position.Y < phoneFrame.Y or
       position.Y > phoneFrame.Y + phoneSize.Y then
        togglePhone()
    end
end

-- Connect input events
PhoneFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        togglePhone()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        handleOutsideClick(input)
    end
end)

-- Initialize phone in peeking position with screen off
PhoneFrame.Position = PEEK_POSITION
setScreenState(false)

-- Adjust phone position based on screen size
local function adjustForScreenSize()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local aspectRatio = viewportSize.X / viewportSize.Y
    
    if aspectRatio < 1.2 then
        PEEK_POSITION = UDim2.fromScale(0.85, 0.985)
    else
        PEEK_POSITION = UDim2.fromScale(0.85, 0.99)
    end
    
    if not isShown then
        setPhonePosition(PEEK_POSITION)
    end
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adjustForScreenSize)
adjustForScreenSize()

-- Initialize HomeScreen as default app
local HomeScreen = Screen:WaitForChild("HomeScreen")
HomeScreen.Visible = true

-- Add bouncy animation for that clay-animation feel
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

-- Apply bouncy effect to all app buttons
for _, button in ipairs(HomeScreen:GetChildren()) do
    if button:IsA("ImageButton") then
        addBouncyEffect(button)
    end
end 