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
local DynamicIsland = Screen:WaitForChild("DynamicIsland")

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

-- Function to handle phone visibility states
local function togglePhone()
    isShown = not isShown
    setPhonePosition(isShown and SHOWN_POSITION or PEEK_POSITION)
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
DynamicIsland.InputBegan:Connect(function(input)
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

-- Initialize phone in peeking position
PhoneFrame.Position = PEEK_POSITION

-- Adjust phone position based on screen size
local function adjustForScreenSize()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local aspectRatio = viewportSize.X / viewportSize.Y
    
    -- Adjust peek position based on screen aspect ratio
    if aspectRatio < 1.2 then
        -- For taller/narrower screens
        PEEK_POSITION = UDim2.fromScale(0.85, 0.985)  -- Shows just a tiny bit
    else
        -- For wider screens
        PEEK_POSITION = UDim2.fromScale(0.85, 0.99)  -- Shows just a tiny bit
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