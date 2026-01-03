local activeJob = nil
local currentDrop = nil
local blip = nil
local jobVeh = nil

local function StartDelivery()
    if activeJob then return end
    activeJob = true
    
    -- Spawn Vehicle
    local model = GetHashKey(Config.Delivery.Vehicle)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    
    local coords = Config.Delivery.Depot
    jobVeh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, false)
    SetVehicleNumberPlateText(jobVeh, "WORK"..math.random(100,999))
    TaskWarpPedIntoVehicle(PlayerPedId(), jobVeh, -1)
    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(jobVeh))
    exports['rpa-fuel']:SetFuel(jobVeh, 100)

    -- Select Drop
    currentDrop = Config.Delivery.Locations[math.random(#Config.Delivery.Locations)]
    blip = AddBlipForCoord(currentDrop.x, currentDrop.y, currentDrop.z)
    SetBlipSprite(blip, 1)
    SetBlipRoute(blip, true)
    
    exports['rpa-lib']:Notify("Delivery Started. Go to the GPS location.", "success")
end

local function FinishDrop()
    if not activeJob then return end
    
    TriggerServerEvent('rpa-jobs:server:pay', 'delivery')
    RemoveBlip(blip)
    
    -- Loop or end? Let's loop
    exports['rpa-lib']:Notify("Delivery Complete. Next stop updated.", "success")
    currentDrop = Config.Delivery.Locations[math.random(#Config.Delivery.Locations)]
    blip = AddBlipForCoord(currentDrop.x, currentDrop.y, currentDrop.z)
    SetBlipSprite(blip, 1)
    SetBlipRoute(blip, true)
end

CreateThread(function()
    -- Start Point
    exports['rpa-lib']:AddTargetModel('s_m_m_postal_01', {
         options = {
            {
                label = "Start Delivery Job",
                icon = "fas fa-box",
                action = function() StartDelivery() end
            }
         }
    })
    
    -- Drop Logic (Distance check for now, ideally Target on Prop)
    while true do
        Wait(1000)
        if activeJob and currentDrop then
            local ped = PlayerPedId()
            local dist = #(GetEntityCoords(ped) - currentDrop)
            if dist < 5.0 and IsPedInVehicle(ped, jobVeh, false) then
                exports['rpa-lib']:TextUI("Press [E] to Deliver")
                -- Input check needs real loop
            end
        end
    end
end)

-- Button listener separate
CreateThread(function()
    while true do
        Wait(0)
        if activeJob and currentDrop then
            local ped = PlayerPedId()
            local dist = #(GetEntityCoords(ped) - currentDrop)
            if dist < 5.0 and IsPedInVehicle(ped, jobVeh, false) then
                if IsControlJustPressed(0, 38) then -- E
                    FinishDrop()
                end
            end
        end
    end
end)
