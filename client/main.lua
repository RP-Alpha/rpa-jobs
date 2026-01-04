local activeJob = nil
local currentDrop = nil
local blip = nil
local jobVeh = nil
local showingTextUI = false
local jobNPC = nil

-- Helper function to load model with timeout
local function LoadModel(model, timeout)
    timeout = timeout or 5000
    local hash = type(model) == 'string' and GetHashKey(model) or model
    
    if not IsModelValid(hash) then
        return false
    end
    
    RequestModel(hash)
    local startTime = GetGameTimer()
    while not HasModelLoaded(hash) do
        if GetGameTimer() - startTime > timeout then
            return false
        end
        Wait(10)
    end
    return true
end

local function StartDelivery()
    if activeJob then 
        exports['rpa-lib']:Notify("You already have an active job", "error")
        return 
    end
    activeJob = true
    
    -- Spawn Vehicle
    local model = GetHashKey(Config.Delivery.Vehicle)
    if not LoadModel(model) then
        exports['rpa-lib']:Notify("Failed to load vehicle", "error")
        activeJob = nil
        return
    end
    
    local coords = Config.Delivery.Depot
    jobVeh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, false)
    local plate = "WORK"..math.random(100,999)
    SetVehicleNumberPlateText(jobVeh, plate)
    TaskWarpPedIntoVehicle(PlayerPedId(), jobVeh, -1)
    
    -- Give keys using proper rpa-vehiclekeys export
    if GetResourceState('rpa-vehiclekeys') == 'started' then
        exports['rpa-vehiclekeys']:GiveKeys(plate)
    end
    
    -- Set fuel
    if GetResourceState('rpa-fuel') == 'started' then
        exports['rpa-fuel']:SetFuel(jobVeh, 100)
    end

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
    
    -- Select next drop
    exports['rpa-lib']:Notify("Delivery Complete. Next stop updated.", "success")
    currentDrop = Config.Delivery.Locations[math.random(#Config.Delivery.Locations)]
    blip = AddBlipForCoord(currentDrop.x, currentDrop.y, currentDrop.z)
    SetBlipSprite(blip, 1)
    SetBlipRoute(blip, true)
end

local function EndJob()
    if not activeJob then return end
    
    -- Cleanup
    if blip then RemoveBlip(blip) end
    if jobVeh and DoesEntityExist(jobVeh) then
        DeleteEntity(jobVeh)
    end
    
    activeJob = nil
    currentDrop = nil
    blip = nil
    jobVeh = nil
    
    if showingTextUI then
        exports['rpa-lib']:HideTextUI()
        showingTextUI = false
    end
    
    exports['rpa-lib']:Notify("Job ended", "info")
end

-- Spawn job NPC at depot
CreateThread(function()
    local npcModel = 's_m_m_postal_01'
    if not LoadModel(npcModel) then
        print('[rpa-jobs] Failed to load job NPC model')
        return
    end
    
    local coords = Config.Delivery.Depot
    jobNPC = CreatePed(4, GetHashKey(npcModel), coords.x + 2.0, coords.y, coords.z, coords.w - 180.0, false, true)
    FreezeEntityPosition(jobNPC, true)
    SetEntityInvincible(jobNPC, true)
    SetBlockingOfNonTemporaryEvents(jobNPC, true)
    
    -- Add target to the NPC
    exports['rpa-lib']:AddTargetModel(npcModel, {
         options = {
            {
                label = "Start Delivery Job",
                icon = "fas fa-box",
                action = function() StartDelivery() end,
                canInteract = function() return not activeJob end
            },
            {
                label = "End Delivery Job",
                icon = "fas fa-times",
                action = function() EndJob() end,
                canInteract = function() return activeJob end
            }
         }
    })
    
    -- Add blip for depot
    local depotBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(depotBlip, 318)
    SetBlipDisplay(depotBlip, 4)
    SetBlipScale(depotBlip, 0.7)
    SetBlipColour(depotBlip, 5)
    SetBlipAsShortRange(depotBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Delivery Job")
    EndTextCommandSetBlipName(depotBlip)
end)

-- Drop detection with proper TextUI handling
CreateThread(function()
    while true do
        Wait(500)
        if activeJob and currentDrop then
            local ped = PlayerPedId()
            local dist = #(GetEntityCoords(ped) - currentDrop)
            
            if dist < 5.0 and jobVeh and IsPedInVehicle(ped, jobVeh, false) then
                if not showingTextUI then
                    exports['rpa-lib']:TextUI("Press [E] to Deliver")
                    showingTextUI = true
                end
            else
                if showingTextUI then
                    exports['rpa-lib']:HideTextUI()
                    showingTextUI = false
                end
            end
        elseif showingTextUI then
            exports['rpa-lib']:HideTextUI()
            showingTextUI = false
        end
    end
end)

-- Button listener
CreateThread(function()
    while true do
        Wait(0)
        if activeJob and currentDrop then
            local ped = PlayerPedId()
            local dist = #(GetEntityCoords(ped) - currentDrop)
            if dist < 5.0 and jobVeh and IsPedInVehicle(ped, jobVeh, false) then
                if IsControlJustPressed(0, 38) then -- E
                    FinishDrop()
                end
            end
        end
    end
end)

-- End job command
RegisterCommand('endjob', function()
    EndJob()
end, false)
