RegisterNetEvent('rpa-jobs:server:pay', function(jobType)
    local src = source
    local player = exports['rpa-lib']:GetFramework().Functions.GetPlayer(src)
    
    if jobType == 'delivery' then
        -- XP Logic
        local currentXP = player.PlayerData.metadata['job_xp'] or 0
        local nextXP = currentXP + 10 -- 10 XP per delivery
        player.Functions.SetMetaData('job_xp', nextXP)
        
        -- Calculate Multiplier
        local mult = 1.0
        local level = 1
        for lvl, data in ipairs(Config.Levels) do
            if nextXP >= data.xp then
                level = lvl
                mult = data.multiplier
            end
        end
        
        local pay = math.floor(Config.Delivery.Pay * mult)
        
        player.Functions.AddMoney('cash', pay)
        exports['rpa-lib']:Notify(src, "You received $"..pay.." (Level "..level..")", "success")
        exports['rpa-lib']:Notify(src, "+10 XP", "info")
    end
end)
