
local QBCore = exports['qb-core']:GetCoreObject()
-- Table of washers for the thread to generate polyzones for qb-target.
local washers = {
    {x=1135.70, y=-992.30, z=46.11, h=99.29, length=0.8, width=1.2},
    {x=1135.43, y=-990.81, z=46.11, h=99.29, length=0.8, width=1.2},
    {x=1135.30, y=-989.52, z=46.11, h=99.29, length=0.8, width=1.2},
    {x=1135.15, y=-988.17, z=46.11, h=99.29, length=0.8, width=1.2},
}


function isWashing(washer)
    local washing = promise.new()
    QBCore.Functions.TriggerCallback("laundry:isWashing", function(result)
        washing:resolve(result)
    end, washer)
    Wait(100)
    return Citizen.Await(washing)
end

function isReady(washer)
    local ready = promise.new()
    QBCore.Functions.TriggerCallback("laundry:isReady", function(result)
        ready:resolve(result)
    end, washer)
    Wait(100)
    return Citizen.Await(ready)
end

CreateThread(function()

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
                        icon = "fa-solid fa-gauge-high",
                        label = "Open Washer",
                        id = washer,
                        canInteract = function()
                            if not isWashing(washer) then return true else return false end 
                        end
                    },
                    {
                        type = "server",
                        event = "laundry:startwasher",
                        icon = "fa-solid fa-hourglass-start",
                        label = "Start Washer",
                        id = washer,
                        canInteract = function()
                            if not isWashing(washer) then return true else return false end 
                        end
                    },
                    {
                        type = "server",
                        event = "laundry:collect",
                        icon = "fa-solid fa-hand-holding-usd",
                        label = "Collect Money",
                        id = washer,
                        canInteract = function()
                            return isReady(washer)
                        end
                    },
                },
                distance = 3.0
        })
    end
end)


-- Open the passed washerId's stash.
RegisterNetEvent("laundry:openwasher", function(data)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "washer"..data.id, {maxweight = 1500000, slots = 10})
    TriggerEvent("inventory:client:SetCurrentStash", "washer"..data.id)
end)
