Config = {}

Config.Debug = false

-- Settings
Config.PickaxeItem = 'pickaxe'
Config.RawMaterial = 'stone'
Config.MineTime = 5000     -- Time in ms to mine
Config.ProcessTime = 8000  -- Time in ms to wash stone

-- Locations
-- Add as many locations as you want
Config.MiningZones = {
    vec3(2927.9116, 2789.9231, 40.5600),
    vec3(2925.8887, 2792.4053, 41.2975),
    vec3(2925.8796, 2796.1997, 41.4496),
    vec3(2921.7395, 2799.7314, 42.1562),
    vec3(2918.3596, 2799.8555, 41.7401),
    vec3(2926.3682, 2813.1604, 45.5691),
    vec3(2938.3542, 2813.3469, 43.4886),
    vec3(2944.5613, 2818.5298, 43.5433),
    vec3(2947.9355, 2820.5315, 43.4810),
    vec3(2956.0288, 2819.8235, 43.1449),
    vec3(2959.1042, 2820.0562, 43.7499),
    vec3(2972.2393, 2798.8718, 42.2280),
    vec3(2976.4448, 2795.0117, 41.6448),
    vec3(2976.8889, 2792.5710, 41.3856),
    vec3(2979.5791, 2791.0254, 41.6617),
    vec3(2982.0471, 2787.0554, 41.1897),
    vec3(2981.1091, 2781.8062, 40.1598),
    vec3(2972.2559, 2775.4260, 39.2087),
    vec3(2969.5295, 2775.6357, 39.6301),
    vec3(2964.6536, 2773.9026, 39.9693),
    vec3(2930.6196, 2787.0068, 40.1617),
    vec3(2934.8704, 2784.1030, 40.2391),
    vec3(2956.7781, 2772.7297, 40.0695),
    vec3(2953.6423, 2770.3416, 39.5971),
    vec3(2952.3154, 2768.2537, 39.9464),
    vec3(2948.3047, 2767.3113, 39.8611),
}

Config.ProcessPed = {
    model = 's_m_y_construct_01',             -- ped model
    coords = vec4(287.2970, 2843.3594, 44.7042, 30.8049)
}

Config.SellPed = {
    model = 's_m_m_dockwork_01',              -- ped model
    coords = vec4(463.8470, -770.5849, 27.3599, 93.5369)
}

-- processing/economy
-- When a player processes 1 'stone', they get ONE of these based on chance
Config.Ores = {
    {item = 'copper', chance = 60, price = 500},   -- 50% chance
    {item = 'iron', chance = 40, price = 800},     -- 35% chance
    {item = 'gold', chance = 25, price = 1100},    -- 10% chance
    {item = 'diamond', chance = 10, price = 2000}   -- 5% chance
}

Config.NotificationType = 'okok' -- 'esx', 'okok', 'ox'

-- DONT CHANGE THIS
function SendNotification(src, title, message, type)
    if IsDuplicityVersion() then
        if Config.NotificationType == 'esx' then
            TriggerClientEvent('esx:showNotification', src, message)
        elseif Config.NotificationType == 'okok' then
            TriggerClientEvent('okokNotify:Alert', src, title, message, 4000, type)
        elseif Config.NotificationType == 'ox' then
            TriggerClientEvent('ox_lib:notify', src, { title = title, description = message, type = type })
        end
    else
        if Config.NotificationType == 'esx' then
            ESX.ShowNotification(message)
        elseif Config.NotificationType == 'okok' then
            exports['okokNotify']:Alert(title, message, 4000, type)
        elseif Config.NotificationType == 'ox' then
            lib.notify({ title = title, description = message, type = type })
        end
    end
end