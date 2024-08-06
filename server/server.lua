local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterNetEvent('rsg-tobacco:server:AddTobacco')
AddEventHandler('rsg-tobacco:server:AddTobacco', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if Player then
        Player.Functions.AddItem(Config.ItemName, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[Config.ItemName], "add")
    end
end)