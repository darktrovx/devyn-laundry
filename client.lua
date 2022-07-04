
local QBCore = exports['qb-core']:GetCoreObject()

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
    local pay
    for washer, data in pairs(Config.washers) do 
        if Config.washers[washer].cost > 0 then
            pay = "for $" .. Config.washers[washer].cost
        else
            pay = ""
        end
        exports['qb-target']:AddBoxZone("wash"..washer, vector3(data.vec.x, data.vec.y, data.vec.z), 0.8, 1.2, {
            name="wash"..washer,
            heading=data.vec.w,
            debugPoly=data.debug,
            minZ=data.vec.z - 1,
            maxZ=data.vec.z + 1,
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
                        label = "Start Washer " .. pay,
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
