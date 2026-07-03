local spawnedPeds = {}

local function spawnJobPed(model, coords, scenario)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local ped = CreatePed(4, hash, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
    
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    
    if scenario then
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end

    table.insert(spawnedPeds, ped)
    return ped
end

local function mineRock()
    local hasPickaxe = lib.callback.await('NS_minerjob:checkItem', false, Config.PickaxeItem)
    
    if not hasPickaxe then
        SendNotification(nil, "Miner Job", "You need a pickaxe to mine this!", 'error')
        return
    end

    local success = lib.skillCheck({'easy', 'easy'}, {'w', 'a', 's', 'd'})
    if not success then
        SendNotification(nil, "Miner Job", "You slipped and failed to mine the rock.", 'warning')
        return
    end

    if lib.progressBar({
        duration = Config.MineTime,
        label = 'Mining rock...',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = {
            dict = 'melee@hatchet@streamed_core',
            clip = 'plyr_rear_takedown_b',
            flag = 49
        },
        prop = {
            model = `prop_tool_pickaxe`,
            bone = 57005,
            pos = vec3(0.09, -0.53, -0.22),
            rot = vec3(252.0, 180.0, 0.0)
        }
    }) then
        TriggerServerEvent('NS_minerjob:giveStone')
    else
        SendNotification(nil, "Miner Job", "Mining canceled.", 'warning')
    end
end

local function processRocks()
    local hasStone = lib.callback.await('NS_minerjob:checkItem', false, Config.RawMaterial)
    
    if not hasStone then
        SendNotification(nil, "Miner Job", "You don't have any stone to process!", 'error')
        return
    end

    if lib.progressBar({
        duration = Config.ProcessTime,
        label = 'Washing rocks...',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'amb@prop_human_bum_bin@idle_a', clip = 'idle_a' }
    }) then
        TriggerServerEvent('NS_minerjob:processRocks')
    else
        SendNotification(nil, "Miner Job", "Processing canceled.", 'warning')
    end
end

Citizen.CreateThread(function()
    for i, coords in ipairs(Config.MiningZones) do
        exports.ox_target:addSphereZone({
            coords = coords,
            radius = 2.0,
            debug = Config.Debug,
            options = {
                {
                    name = 'mine_rock_'..i,
                    icon = 'fa-solid fa-hammer',
                    label = 'Mine Rock',
                    distance = 2.5,
                    onSelect = function()
                        mineRock()
                    end
                }
            }
        })
    end

    local processPed = spawnJobPed(Config.ProcessPed.model, Config.ProcessPed.coords, "WORLD_HUMAN_CLIPBOARD")
    exports.ox_target:addLocalEntity(processPed, {
        {
            name = 'process_rocks',
            icon = 'fa-solid fa-gem',
            label = 'Process Stone',
            distance = 2.0,
            onSelect = function()
                processRocks()
            end
        }
    })

    local sellPed = spawnJobPed(Config.SellPed.model, Config.SellPed.coords, "WORLD_HUMAN_COP_IDLES")
    exports.ox_target:addLocalEntity(sellPed, {
        {
            name = 'sell_ores',
            icon = 'fa-solid fa-sack-dollar',
            label = 'Sell Ores',
            distance = 2.0,
            onSelect = function()
                TriggerServerEvent('NS_minerjob:sellOres')
            end
        }
    })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, ped in ipairs(spawnedPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)