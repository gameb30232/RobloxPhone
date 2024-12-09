local DataStoreService = game:GetService("DataStoreService")
local WalletStore = DataStoreService:GetDataStore("WalletData")

local WalletData = {}

-- Default wallet structure
local function createDefaultWallet()
    return {
        created = true,
        balance = 0,
        address = generateWalletAddress(), -- You'll need to implement this
        transactions = {},
        lastUpdated = os.time()
    }
end

function WalletData:getWallet(userId)
    local success, wallet = pcall(function()
        return WalletStore:GetAsync(userId)
    end)
    
    if success and wallet then
        return wallet
    end
    return nil
end

function WalletData:createWallet(userId)
    local wallet = createDefaultWallet()
    local success, _ = pcall(function()
        WalletStore:SetAsync(userId, wallet)
    end)
    return success and wallet or nil
end

function WalletData:updateBalance(userId, newBalance)
    local wallet = self:getWallet(userId)
    if wallet then
        wallet.balance = newBalance
        wallet.lastUpdated = os.time()
        pcall(function()
            WalletStore:SetAsync(userId, wallet)
        end)
    end
end

return WalletData 