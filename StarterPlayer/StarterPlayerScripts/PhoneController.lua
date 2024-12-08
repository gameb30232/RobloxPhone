local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local spring = require(game:GetService("ReplicatedStorage"):WaitForChild("modules"):WaitForChild("spring"))

-- Wait for player and UI to load
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local PhoneUI = playerGui:WaitForChild("PhoneUI")
local PhoneFrame = PhoneUI:WaitForChild("PhoneFrame")
local Screen = PhoneFrame:WaitForChild("Screen")
local DynamicIsland = Screen:WaitForChild("DynamicIsland")

-- Position settings
local SHOWN_POSITION = UDim2.fromScale(0.85, 0.5)
local PEEK_POSITION = UDim2.fromScale(0.85, 0.92) -- Shows just the top of the phone
local HIDDEN_POSITION = UDim2.fromScale(0.85, 1.2)

-- State
local isShown = false
local isPeeking = true

-- Function to animate the phone using spring
local function setPhonePosition(position)
    spring.target(PhoneFrame, 0.8, 1, {
        Position = position
    })
end

-- Function to handle phone visibility states
local function togglePhone()
    if isShown then
        -- If phone is shown, hide it but keep peeking
        isShown = false
        isPeeking = true
        setPhonePosition(PEEK_POSITION)
    else
        -- If phone is peeking or hidden, show it
        isShown = true
        isPeeking = false
        setPhonePosition(SHOWN_POSITION)
    end
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
        PEEK_POSITION = UDim2.fromScale(0.85, 0.90)
    else
        -- For wider screens
        PEEK_POSITION = UDim2.fromScale(0.85, 0.92)
    end
    
    if not isShown then
        setPhonePosition(isPeeking and PEEK_POSITION or HIDDEN_POSITION)
    end
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adjustForScreenSize)
adjustForScreenSize() 