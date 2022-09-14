
local QBCore = exports['qb-core']:GetCoreObject()

local washers = { }

for k,v in pairs(Config.washers) do
    if washers[k] == nil then
        washers[k] = {washing = false, ready = false}
    end
end

RegisterNetEvent("laundry:client:isWashing")
AddEventHandler("laundry:client:isWashing", function(id, verify)
    washers[id].isWashing = verify
end)

RegisterNetEvent("laundry:client:isReady")
AddEventHandler("laundry:client:isReady", function(id, verify)
    washers[id].isReady = verify
end)

CreateThread(function()
    local pay
    for washer, data in pairs(Config.washers) do 
        if Config.washers[washer].cost > 0 then
            pay = "for $" .. Config.washers[washer].cost
        else
            pay = ""
        end
        exports['qb-target']:AddBoxZone("wash"..washer, vector3(data.vec.x, data.vec.y, data.vec.z), 1.8, 1.3, {
            name="wash"..washer,
            heading=data.vec.w,
            debugPoly=data.debug,
            minZ=data.vec.z - 1.25,
            maxZ=data.vec.z + 1.25,
            }, {
                options = {
                    {
                        type = "client",
                        event = "laundry:openwasher",
                        icon = "fa-solid fa-gauge-high",
                        label = "Open Washer",
                        id = washer,
                        canInteract = function()
                            return not washers[washer].isWashing
                        end
                    },
                    {
                        type = "server",
                        event = "laundry:startwasher",
                        icon = "fa-solid fa-hourglass-start",
                        label = "Start Washer " .. pay,
                        id = washer,
                        canInteract = function()
                            return not washers[washer].isWashing
                        end
                    },
                    {
                        type = "server",
                        event = "laundry:check",
                        icon = "fa-solid fa-hourglass-start",
                        label = "Check Remaining Time",
                        id = washer,
                        canInteract = function()
                            return (washers[washer].isWashing and not washers[washer].isReady)
                        end
                    },
                    {
                        type = "server",
                        event = "laundry:collect",
                        icon = "fa-solid fa-hand-holding-usd",
                        label = "Collect Money",
                        id = washer,
                        canInteract = function()
                            return washers[washer].isReady
                        end
                    },
                },
            distance = 3.0
        })
    end
    if Config.UseTargetDoors then
        exports['qb-target']:AddBoxZone("laundryentrance", Config.Entrance.coords, Config.Entrance.width, Config.Entrance.length, {
            name = "laundryentrance",
            heading = Config.Entrance.coords.w,
            debugPoly = Config.Entrance.Debug,
            minZ = Config.Entrance.coords.z - Config.Entrance.minZ,
            maxZ = Config.Entrance.coords.z + Config.Entrance.maxZ,
            }, {
            options = {
                {
                    label = Config.Entrance.text,
                    action = function()
                        local targetPos = Config.Exit.coords
                        local Player = PlayerPedId()
                        DoScreenFadeOut(1000)
                        Wait(1000)
                        FreezeEntityPosition(Player, true)
                        SetEntityCoords(Player, targetPos.x, targetPos.y, targetPos.z-1)
                        SetEntityHeading(Player, targetPos.w)
                        DoScreenFadeIn(1000)
                        Wait(1000)
                        FreezeEntityPosition(Player, false)
                    end
                },
            },
            distance = 2.0
        })

        exports['qb-target']:AddBoxZone("laundryexit", Config.Exit.coords, Config.Exit.width, Config.Exit.length, {
            name = "laundryexit",
            heading = Config.Exit.coords.w,
            debugPoly = Config.Exit.Debug,
            minZ = Config.Exit.coords.z - Config.Exit.minZ,
            maxZ = Config.Exit.coords.z + Config.Exit.maxZ,
            }, {
            options = {
                {
                    label = Config.Exit.text,
                    action = function()
                        local targetPos = Config.Entrance.coords
                        local Player = PlayerPedId()
                        DoScreenFadeOut(1000)
                        Wait(1000)
                        FreezeEntityPosition(Player, true)
                        SetEntityCoords(Player, targetPos.x, targetPos.y, targetPos.z-1)
                        SetEntityHeading(Player, targetPos.w)
                        DoScreenFadeIn(1000)
                        Wait(1000)
                        FreezeEntityPosition(Player, false)
                    end
                },
            },
            distance = 2.0
        })
    end
end)

-- Open the passed washerId's stash.
RegisterNetEvent("laundry:openwasher", function(data)
    if not checka then
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "washer"..data.id, {maxweight = 1500000, slots = 10})
    TriggerEvent("inventory:client:SetCurrentStash", "washer"..data.id)
    else
        QBCore.Functions.Notify('This washer is currently cleaning!', 'error', 1500)
    end
end)