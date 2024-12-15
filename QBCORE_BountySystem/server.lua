local QBCore = exports['qb-core']:GetCoreObject()
local bounties = {} -- Store active bounties

-- Config: Allow placing bounties on oneself
local allowSelfBounty = true -- Set to true if players can place bounties on themselves

-- Command to place a bounty
RegisterCommand('placebounty', function(source, args)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local targetID = tonumber(args[1])
    local reward = tonumber(args[2])

    if not targetID or not reward then
        TriggerClientEvent('chat:addMessage', source, { args = { 'Bounty System', 'Usage: /placebounty [targetID] [reward]' } })
        return
    end

    if targetID == source and not allowSelfBounty then
        TriggerClientEvent('chat:addMessage', source, { args = { 'Bounty System', 'You cannot place a bounty on yourself!' } })
        return
    end

    if bounties[targetID] then
        TriggerClientEvent('chat:addMessage', source, { args = { 'Bounty System', 'This player already has a bounty!' } })
        return
    end

    local bankBalance = xPlayer.PlayerData.money['bank']

    if bankBalance < reward then
        TriggerClientEvent('chat:addMessage', source, { args = { 'Bounty System', 'You do not have enough money in your bank account!' } })
        return
    end

    -- Deduct the bounty amount from the player's bank account
    xPlayer.Functions.RemoveMoney('bank', reward, 'bounty-placed')

    -- Add the bounty
    local targetName = GetPlayerName(targetID)
    bounties[targetID] = { reward = reward, placedBy = source }
    TriggerClientEvent('bounty:notify', -1, targetName, reward)

    -- Notify the player
    TriggerClientEvent('chat:addMessage', source, { args = { 'Bounty System', 'You have placed a bounty of $' .. reward .. ' on ' .. targetName .. '.' } })
end, false)

-- Command for bounty hunters to claim a reward
RegisterCommand('claimbounty', function(source, args)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local targetID = tonumber(args[1])

    if not targetID or not bounties[targetID] then
        TriggerClientEvent('chat:addMessage', source, { args = { 'Bounty System', 'No active bounty on this player!' } })
        return
    end

    -- Pay the reward to the hunter
    local reward = bounties[targetID].reward
    local targetName = GetPlayerName(targetID)
    bounties[targetID] = nil

    xPlayer.Functions.AddMoney('bank', reward, 'bounty-claimed')

    -- Notify players
    TriggerClientEvent('bounty:remove', -1, targetID)
    TriggerClientEvent('chat:addMessage', source, { args = { 'Bounty System', 'You claimed the bounty on ' .. targetName .. '! Reward: $' .. reward } })
    TriggerClientEvent('chat:addMessage', targetID, { args = { 'Bounty System', 'Your bounty has been claimed!' } })
end, false)

-- Remove bounty if target disconnects
AddEventHandler('playerDropped', function(reason)
    local playerID = source
    if bounties[playerID] then
        bounties[playerID] = nil
        TriggerClientEvent('bounty:remove', -1, playerID)
    end
end)
