

local washers = {
    {x=1135.70, y=-992.30, z=46.11, h=99.29},
    {x=1135.43, y=-990.81, z=46.11, h=99.29},
    {x=1135.30, y=-989.52, z=46.11, h=99.29},
    {x=1135.15, y=-988.17, z=46.11, h=99.29},
}

Citizen.CreateThread(function()

    for k,v in pairs(washers) do 
        exports['qb-target']:AddBoxZone("wash"..k, vector3(v.x, v.y, v.z), 0.8, 1.2, {
            name="wash"..k,
            heading=v.h,
            debugPoly=false,
            minZ=v.z - 1,
            maxZ=v.z + 1,
            }, {
                options = {
                    {
                        type = "client",
                        event = "laundry:openwasher",
                        icon = "fas fa-washer",
                        label = "Open Washer",
                        id = k,
                        canInteract = function()
                            local c = false 
                            QBCore.Functions.TriggerCallback("laundry:isWashing", function(result)
                                c = result
                            end, k)
                            Wait(200)
                            if not c then return true else return false end 
                        end
                    },
                    {
                        type = "server",
                        event = "laundry:startwasher",
                        icon = "fad fa-hourglass-start",
                        label = "Start Washer",
                        id = k,
                        canInteract = function()
                            local c = false 
                            QBCore.Functions.TriggerCallback("laundry:isWashing", function(result)
                                c = result
                            end, k)
                            Wait(200)
                            if not c then return true else return false end
                        end
                    },
                    {
                        type = "server",
                        event = "laundry:collect",
                        icon = "fas fa-hand-holding-usd",
                        label = "Collect Money",
                        id = k,
                        canInteract = function()
                            local c = false
                            QBCore.Functions.TriggerCallback("laundry:isReady", function(result)
                                c = result
                            end, k)
                            Wait(200)
                            return c
                        end
                    },
                },
                distance = 3.0
        })
    end
    Wait(100)
end)

RegisterNetEvent("laundry:openwasher")
AddEventHandler("laundry:openwasher", function(data)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "washer"..data.id, {maxweight = 1500000, slots = 10})
    TriggerEvent("inventory:client:SetCurrentStash", "washer"..data.id)
end)