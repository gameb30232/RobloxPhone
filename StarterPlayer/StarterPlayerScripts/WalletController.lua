local Players = game:GetService("Players")
local spring = require(game:GetService("ReplicatedStorage").modules.spring)

local WalletController = {}

-- Screen states enum
WalletController.Screens = {
    WELCOME = "WelcomeScreen",
    CREATE = "CreateWalletScreen",
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

-- Screen transition function
local function transitionToScreen(screenName)
    -- Fade out current screen
    local currentScreen = Screens:FindFirstChild(state.currentScreen)
    if currentScreen then
        spring.target(currentScreen, 0.3, 0.8, {
            Position = UDim2.fromScale(-1, 0.5),
            BackgroundTransparency = 1
        })
    end
    
    -- Show and fade in new screen
    local newScreen = Screens:FindFirstChild(screenName)
    if newScreen then
        newScreen.Position = UDim2.fromScale(1, 0.5)
        newScreen.Visible = true
        spring.target(newScreen, 0.3, 0.8, {
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 0
        })
    end
    
    state.currentScreen = screenName
end

-- Public methods
function WalletController:init()
    -- Register with HomeScreen
    local HomeScreen = Screen:WaitForChild("HomeScreen")
    local walletButton = HomeScreen:FindFirstChild("WalletApp")
    if not walletButton then
        -- Create wallet app button if it doesn't exist
        -- (You'll need to implement this based on your HomeScreen structure)
    end
    
    -- Check if user has wallet
    -- This would typically check some persistent data store
    if not state.hasWallet then
        transitionToScreen(self.Screens.WELCOME)
    else
        transitionToScreen(self.Screens.MAIN)
    end
end

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