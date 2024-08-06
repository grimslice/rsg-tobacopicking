local RSGCore = exports['rsg-core']:GetCoreObject()

-- Debug function (unchanged)
local function DebugPrint(message)
    if Config.Debug then
        print("[RSG-Tobacco Debug] " .. message)
    end
end

-- Function to check if the object is a tobacco plant (unchanged)
local function IsTobaccoPlant(object)
    local model = GetEntityModel(object)
    for _, plantModel in ipairs(Config.TobaccoPlants) do
        if model == plantModel then
            DebugPrint("Found matching plant model: " .. model)
            return true
        end
    end
    DebugPrint("No matching plant model found for: " .. model)
    return false
end

-- New function to get the closest tobacco plant
local function GetClosestTobaccoPlant()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local itemSet = CreateItemset(true)
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, coords, 2.0, itemSet, 3, Citizen.ResultAsInteger())
    local closestPlant = nil
    local closestDistance = 5.0

    if size > 0 then
        for index = 0, size - 1 do
            local entity = GetIndexedItemInItemset(index, itemSet)
            if IsTobaccoPlant(entity) then
                local plantCoords = GetEntityCoords(entity)
                local distance = #(coords - plantCoords)
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlant = entity
                end
            end
        end
    end

    if IsItemsetValid(itemSet) then
        DestroyItemset(itemSet)
    end

    return closestPlant, closestDistance
end

local function PickTobacco()
    local playerPed = PlayerPedId()
    local closestPlant, distance = GetClosestTobaccoPlant()
    
    if closestPlant then
        DebugPrint("Found plant with model hash: " .. GetEntityModel(closestPlant) .. " at distance: " .. distance)

        -- Check if player is in range to pick
        if distance <= 2.0 then
            local plantCoords = GetEntityCoords(closestPlant)
            RequestAnimDict(Config.PickingAnimation.dict)
            while not HasAnimDictLoaded(Config.PickingAnimation.dict) do
                Wait(100)
            end

            local picking = true
            TaskPlayAnim(playerPed, Config.PickingAnimation.dict, Config.PickingAnimation.enterAnim, 8.0, -8.0, -1, 0, 0, false, false, false)
            Wait(800)
            TaskPlayAnim(playerPed, Config.PickingAnimation.dict, Config.PickingAnimation.baseAnim, 8.0, -8.0, -1, 0, 0, false, false, false)

            RSGCore.Functions.Progressbar("pick_tobacco", Lang:t('progress.picking_tobacco'), Config.PickingTime, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                picking = false
                ClearPedTasks(playerPed)
                TriggerServerEvent('rsg-tobacco:server:AddTobacco')
                
                

            end, function() -- Cancel
                picking = false
                ClearPedTasks(playerPed)
            end)

            -- Anti-cheat: Check if player moves away during picking
            Citizen.CreateThread(function()
                while picking do
                    local playerCoords = GetEntityCoords(playerPed)
                    if #(playerCoords - plantCoords) > 3.0 then
                        RSGCore.Functions.Progressbar("pick_tobacco", Lang:t('progress.picking_tobacco'), false)
                        ClearPedTasks(playerPed)
                        RSGCore.Functions.Notify(Lang:t('error.moved_too_far'), "error")
                        picking = false
                    end
                    Wait(500)
                end
            end)

        else
            RSGCore.Functions.Notify(Lang:t('error.too_far'), "error")
        end
    else
        DebugPrint("No tobacco plant found nearby")
        RSGCore.Functions.Notify(Lang:t('error.no_plant_nearby'), "error")
    end
end

-- Function to set up RSG Target (unchanged)
local function SetupTobaccoTarget()
    exports['rsg-target']:AddTargetModel(Config.TobaccoPlants, {
        options = {
            {
                type = "client",
                event = "rsg-tobacco:client:PickTobacco",
                icon = "fas fa-leaf",
                label = Lang:t('target.pick_tobacco'),
            },
        },
        distance = 2.0
    })
    DebugPrint("RSG Target set up for tobacco plants")
end

-- Event handler for picking tobacco (unchanged)
RegisterNetEvent('rsg-tobacco:client:PickTobacco')
AddEventHandler('rsg-tobacco:client:PickTobacco', function()
    DebugPrint("PickTobacco event triggered")
    PickTobacco()
end)

-- Initialize the script (unchanged)
CreateThread(function()
    SetupTobaccoTarget()
end)

