lib.callback.register('NS_minerjob:checkItem', function(source, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    local item = xPlayer.getInventoryItem(itemName)
    return item and item.count > 0
end)

RegisterNetEvent('NS_minerjob:giveStone', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if xPlayer.canCarryItem(Config.RawMaterial, 1) then
        xPlayer.addInventoryItem(Config.RawMaterial, 1)
        SendNotification(src, "Miner Job", "You found a piece of stone.", 'success')
    else
        SendNotification(src, "Miner Job", "Your inventory is full!", 'error')
    end
end)

RegisterNetEvent('NS_minerjob:processRocks', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local stoneItem = xPlayer.getInventoryItem(Config.RawMaterial)

    if stoneItem and stoneItem.count > 0 then
        xPlayer.removeInventoryItem(Config.RawMaterial, 1)
        
        local rand = math.random(1, 100)
        local currentWeight = 0
        local givenOre = nil

        for _, oreInfo in ipairs(Config.Ores) do
            currentWeight = currentWeight + oreInfo.chance
            if rand <= currentWeight then
                givenOre = oreInfo.item
                break
            end
        end

        if givenOre and xPlayer.canCarryItem(givenOre, 1) then
            xPlayer.addInventoryItem(givenOre, 1)
            SendNotification(src, "Miner Job", "You washed the stone and found " .. givenOre .. "!", 'success')
        else
            SendNotification(src, "Miner Job", "Your inventory is full, the stone washed away.", 'warning')
        end
    else
        SendNotification(src, "Miner Job", "You don't have any stone.", 'error')
    end
end)

RegisterNetEvent('NS_minerjob:sellOres', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local totalEarned = 0
    local itemsSold = 0

    if not xPlayer then return end

    for _, ore in ipairs(Config.Ores) do
        local item = xPlayer.getInventoryItem(ore.item)
        if item and item.count > 0 then
            local amount = item.count
            local payout = amount * ore.price

            xPlayer.removeInventoryItem(ore.item, amount)
            xPlayer.addMoney(payout) 
            
            totalEarned = totalEarned + payout
            itemsSold = itemsSold + amount
        end
    end

    if itemsSold > 0 then
        SendNotification(src, "Miner Job", "You sold " .. itemsSold .. " items for $" .. totalEarned .. ".", 'success')
    else
        SendNotification(src, "Miner Job", "You have nothing valuable to sell.", 'error')
    end
end)