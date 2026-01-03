RegisterNetEvent('rpa-jobs:server:pay', function(jobType)
    local src = source
    local player = exports['rpa-lib']:GetFramework().Functions.GetPlayer(src)
    
    if jobType == 'delivery' then
        player.Functions.AddMoney('cash', Config.Delivery.Pay)
        exports['rpa-lib']:Notify(src, "You received $"..Config.Delivery.Pay, "success")
    end
end)
