local activeBounties = {}

-- Notify players when a bounty is placed
RegisterNetEvent('bounty:notify')
AddEventHandler('bounty:notify', function(targetName, reward)
    TriggerEvent('chat:addMessage', { args = { 'Bounty System', 'A bounty of $' .. reward .. ' has been placed on ' .. targetName .. '!' } })

    -- Add marker for bounty hunter
    if GetPlayerName(PlayerId()) ~= targetName then
        activeBounties[targetName] = { reward = reward }
    end
end)

-- Remove bounty when claimed
RegisterNetEvent('bounty:remove')
AddEventHandler('bounty:remove', function(targetID)
    activeBounties[targetID] = nil
end)

-- Draw markers for bounty targets
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for targetName, bountyData in pairs(activeBounties) do
            local playerPed = GetPlayerPed(GetPlayerFromServerId(targetName))
            if DoesEntityExist(playerPed) then
                local playerCoords = GetEntityCoords(playerPed)
                DrawMarker(1, playerCoords.x, playerCoords.y, playerCoords.z + 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, false, false, false)
            end
        end
    end
end)

-- Add a command to track bounties
RegisterCommand('trackbounties', function()
    for targetName, bountyData in pairs(activeBounties) do
        TriggerEvent('chat:addMessage', { args = { 'Bounty System', targetName .. ' has a bounty of $' .. bountyData.reward } })
    end
end, false)
