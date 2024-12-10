local Players = game:GetService("Players")
local spring = require(game:GetService("ReplicatedStorage").modules.spring)
local theme = require(game:GetService("ReplicatedStorage").modules.phoneTheme)
local walletData = require(game:GetService("ReplicatedStorage").modules.walletData)
local HomeScreenController = require(script.Parent.HomeScreenController)

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
    -- Register wallet app on home screen
    HomeScreenController:registerApp({
        name = "WalletApp",
        displayName = "Wallet",
        icon = "rbxassetid://YOUR_WALLET_ICON_ID", -- Replace with actual wallet icon asset
        order = 1,
        onActivated = function()
            -- This will be called when the app icon is clicked
            if PhoneController then
                PhoneController.switchApp("WalletApp")
            end
        end
    })
    
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
    
    -- Add tab switching functionality
    local tabs = mainScreen:WaitForChild("Tabs")
    
    local function switchTab(tabName)
        for _, tab in ipairs(tabs:GetChildren()) do
            if tab:IsA("Frame") then
                local isSelected = tab.Name == "Tab_"..tabName
                tab.BackgroundColor3 = isSelected and 
                    Color3.fromRGB(39, 39, 41) or -- Selected color
                    Color3.fromRGB(243, 245, 246) -- Unselected color
                
                local textLabel = tab:FindFirstChildWhichIsA("TextLabel")
                if textLabel then
                    textLabel.TextColor3 = isSelected and
                        Color3.fromRGB(227, 223, 223) or -- Selected text
                        Color3.fromRGB(39, 39, 41)       -- Unselected text
                end
            end
        end
    end
    
    -- Connect tab buttons
    for _, tab in ipairs(tabs:GetChildren()) do
        if tab:IsA("Frame") then
            tab.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local tabName = tab.Name:gsub("Tab_", "")
                    switchTab(tabName)
                end
            end)
        end
    end
    
    -- Initial token display update
    updateTokenDisplay()
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

local function formatCurrency(amount)
    return string.format("$%.2f", amount)
end

local function formatPercentage(percent, isPositive)
    return string.format("%.2f%%", math.abs(percent))
end

-- Add this function to update token display
local function updateTokenDisplay()
    local mainScreen = Screens:WaitForChild("MainScreen")
    local balanceCard = mainScreen:WaitForChild("BalanceCard")
    local balanceText = balanceCard:WaitForChild("Balance")
    
    -- Update total balance
    balanceText.Text = formatCurrency(state.balance)
    
    -- Update token list
    local tokensList = mainScreen:WaitForChild("Tokens")
    
    -- Example token data - replace with actual data from your system
    local tokens = {
        {name = "NEAR", amount = 198.24, price = 6.34, change = 2.5, isPositive = true},
        {name = "OCT", amount = 0.6317, price = 0.71, change = 3.87, isPositive = true},
        {name = "DEIP", amount = 555.94874, price = 1.76, change = -0.97, isPositive = false},
        {name = "Aurora", amount = 300, price = 3.79, change = -0.32, isPositive = false},
        {name = "USN", amount = 205, price = 1.33, change = 38.76, isPositive = true}
    }
    
    -- Update each token row
    for i, token in ipairs(tokens) do
        local tokenRow = tokensList:FindFirstChild(token.name.."_Token")
        if tokenRow then
            local amountLabel = tokenRow:FindFirstChild("Amount")
            local priceLabel = tokenRow:FindFirstChild("Price")
            local changeLabel = tokenRow:FindFirstChild("%")
            
            if amountLabel then
                amountLabel.Text = string.format("%.8g", token.amount)
            end
            if priceLabel then
                priceLabel.Text = formatCurrency(token.price)
            end
            if changeLabel then
                changeLabel.Text = formatPercentage(token.change)
                changeLabel.TextColor3 = token.isPositive and 
                    Color3.fromRGB(95, 200, 143) or -- Green
                    Color3.fromRGB(255, 100, 100)   -- Red
            end
        end
    end
end

return WalletController 