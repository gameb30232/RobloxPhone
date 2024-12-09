local Players = game:GetService("Players")
local spring = require(game:GetService("ReplicatedStorage").modules.spring)
local theme = require(game:GetService("ReplicatedStorage").modules.phoneTheme)
local walletData = require(game:GetService("ReplicatedStorage").modules.walletData)

local WalletController = {}

-- Screen states enum
WalletController.Screens = {
    WELCOME = "WelcomeScreen",
    MAIN = "MainScreen",
    SEND = "SendScreen",
    RECEIVE = "ReceiveScreen",
    MARKET = "MarketScreen"
}

-- Initialize state
local state = {
    currentScreen = WalletController.Screens.WELCOME,
    hasWallet = false,
    balance = 0,
    transactions = {},
}

-- Get UI references
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local PhoneUI = playerGui:WaitForChild("PhoneUI")
local Screen = PhoneUI.PhoneFrame:WaitForChild("Screen")
local WalletApp = Screen:WaitForChild("WalletApp")
local Screens = WalletApp:WaitForChild("Screens")

-- Add bouncy effect to buttons
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

-- Screen transition function with clay animation feel
local function transitionToScreen(screenName)
    -- Fade out current screen
    local currentScreen = Screens:FindFirstChild(state.currentScreen)
    if currentScreen then
        spring.target(currentScreen, 0.4, 0.7, {
            Position = UDim2.fromScale(-1, 0.5),
            BackgroundTransparency = 1
        })
    end
    
    -- Show and fade in new screen
    local newScreen = Screens:FindFirstChild(screenName)
    if newScreen then
        newScreen.Position = UDim2.fromScale(1, 0.5)
        newScreen.Visible = true
        spring.target(newScreen, 0.4, 0.7, {
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 0
        })
    end
    
    state.currentScreen = screenName
end

-- Initialize wallet data
function WalletController:init()
    -- Load wallet data
    local wallet = walletData:getWallet(player.UserId)
    if wallet then
        state.hasWallet = true
        state.balance = wallet.balance
        state.transactions = wallet.transactions
        transitionToScreen(self.Screens.MAIN)
    else
        transitionToScreen(self.Screens.WELCOME)
    end
    
    -- Connect UI elements
    local welcomeScreen = Screens:WaitForChild("WelcomeScreen")
    local createWalletButton = welcomeScreen:WaitForChild("CreateWalletButton")
    addBouncyEffect(createWalletButton)
    
    createWalletButton.MouseButton1Click:Connect(function()
        self:createWallet()
    end)
    
    local mainScreen = Screens:WaitForChild("MainScreen")
    local actionButtons = mainScreen:WaitForChild("ActionButtons")
    
    for _, button in ipairs(actionButtons:GetChildren()) do
        if button:IsA("TextButton") then
            addBouncyEffect(button)
            button.MouseButton1Click:Connect(function()
                if button.Name == "SendButton" then
                    self:navigateTo("SEND")
                elseif button.Name == "ReceiveButton" then
                    self:navigateTo("RECEIVE")
                end
            end)
        end
    end
end

-- Public methods
function WalletController:createWallet()
    -- Wallet creation logic here
    state.hasWallet = true
    transitionToScreen(self.Screens.MAIN)
end

function WalletController:navigateTo(screenName)
    if self.Screens[screenName] then
        transitionToScreen(self.Screens[screenName])
    end
end

function WalletController:getBalance()
    return state.balance
end

function WalletController:getTransactions()
    return table.clone(state.transactions)
end

-- Handle app visibility
local function onAppStateChanged()
    if PhoneController:getCurrentApp() == "WalletApp" then
        WalletApp.Visible = true
        -- Resume at last screen
        transitionToScreen(state.currentScreen)
    else
        WalletApp.Visible = false
    end
end

return WalletController 