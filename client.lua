
-- Table of washers for the thread to generate polyzones for qb-target.
local washers = {
    {x=1135.70, y=-992.30, z=46.11, h=99.29, length=0.8, width=1.2},
    {x=1135.43, y=-990.81, z=46.11, h=99.29, length=0.8, width=1.2},
    {x=1135.30, y=-989.52, z=46.11, h=99.29, length=0.8, width=1.2},
    {x=1135.15, y=-988.17, z=46.11, h=99.29, length=0.8, width=1.2},
}

-- This thread creates the polyzone targets for qb-target using the washers table.
Citizen.CreateThread(function()
    -- Loop through each washer in "washers" and create a box zone with three target options: Open Washer, Start Washer and Collect.
    -- Open and Start washer options can only been seen when the washer is not started.
    -- Collect can only be seen when the washer has completed the cleaning cycle and has pending money to collect.
    for washer, data in pairs(washers) do 
        exports['qb-target']:AddBoxZone("wash"..washer, vector3(data.x, data.y, data.z), data.length, data.width, {
            name="wash"..washer,
            heading=data.h,
            debugPoly=false,
            minZ=data.z - 1,
            maxZ=data.z + 1,
            }, {
                options = {
                    {
                        type = "client",
                        event = "laundry:openwasher",
                        icon = "fas fa-washer",
                        label = "Open Washer",
                        id = washer,
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
                        icon = "fas fa-hourglass-start",
                        label = "Start Washer",
                        id = washer,
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
                        id = washer,
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
end)


-- Open the passed washerId's stash.
RegisterNetEvent("laundry:openwasher")
AddEventHandler("laundry:openwasher", function(data)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "washer"..data.id, {maxweight = 1500000, slots = 10})
    TriggerEvent("inventory:client:SetCurrentStash", "washer"..data.id)
end)
