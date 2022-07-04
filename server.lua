local QBCore = exports['qb-core']:GetCoreObject()

-- Callback to check if the passed washerId is already washing.
QBCore.Functions.CreateCallback("laundry:isWashing", function(source, cb, washerId)
    cb(Config.washers[washerId].washing)
end)

-- Callback check to see if the passed washerId is ready for collection/pickup.
QBCore.Functions.CreateCallback("laundry:isReady", function(source, cb, washerId)
    cb(Config.washers[washerId].pickup)
end)

-- Start the washer if it is not already started.
RegisterServerEvent("laundry:startwasher", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Config.washers[data.id].washing then
        if Config.washers[data.id].cost > 0 then
            Player.Functions.RemoveMoney('cash', Config.washers[data.id].cost, Config.washers[data.id].nickName)
        end
        wash(data.id, src)
    else 
        TriggerClientEvent('QBCore:Notify', src, "This washer is already started!", 'error')
    end
end)

-- Collect any waiting money from the washer.
RegisterServerEvent("laundry:collect", function(data)
    src = source
    local player = QBCore.Functions.GetPlayer(src)
    if Config.washers[data.id].pickup then 
        if Config.washers[data.id].cleaned > 0 then
            player.Functions.AddMoney("cash", Config.washers[data.id].cleaned, "Money Washed")
            Config.washers[data.id].cleaned = 0
            Config.washers[data.id].pickup = false
            Config.washers[data.id].washing = false
        else 
            TriggerClientEvent('QBCore:Notify', src, "There is no clean money to collect!", 'error')
            Config.washers[data.id].cleaned = 0
            Config.washers[data.id].pickup = false
            Config.washers[data.id].washing = false
        end
    else 
        TriggerClientEvent('QBCore:Notify', src, "This washer is currently cleaning!", 'error')
    end
end)


-- Get the stash items for the passed washerId: This function was taken from qb-inventory and modifed.
function GetWasherItems(washerId)
	local items = {}
    local stash = 'washer'..washerId
	local result = MySQL.Sync.fetchAll("SELECT items FROM stashitems WHERE stash=?", { stash })
    Wait(500)
	if result[1] ~= nil then 
		if result[1].items ~= nil then
			result[1].items = json.decode(result[1].items)
			if result[1].items ~= nil then 
				for k, item in pairs(result[1].items) do
					local itemInfo = QBCore.Shared.Items[item.name:lower()]
					items[item.slot] = {
						name = itemInfo["name"],
						amount = tonumber(item.amount),
						info = item.info ~= nil and item.info or "",
						label = itemInfo["label"],
						description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
						weight = itemInfo["weight"], 
						type = itemInfo["type"], 
						unique = itemInfo["unique"], 
						useable = itemInfo["useable"], 
						image = itemInfo["image"],
						slot = item.slot,
					}
				end
			end
		end
	end
	return items
end


function wash(washerId, source)
    local stash = 'washer'..washerId
    local items = GetWasherItems(washerId)
    local cleaned = 0

    for item, data in pairs(items) do
        if data.name == "markedbills" then
            --cleaned = cleaned + (1000 * data.amount) -- This gives $1000 per bag.
            cleaned = cleaned + (data.info.worth * data.amount) -- This gives the worth amount per bag.
        end 
    end

    if cleaned > 0 then 
        Config.washers[washerId].washing = true
        TriggerClientEvent('QBCore:Notify', source, Config.washers[washerId].nickName .. " will be done in " .. Config.washers[washerId].washTime .. " minutes.", 'primary')

        cleaned = math.floor(cleaned * Config.washers[washerId].rtrnPerc) -- Returns 80%

        if Config.policeOnDutyBonus > 0 then
            local num_police = 0
            for k, v in pairs(QBCore.Functions.GetPlayers()) do
                local job = QBCore.Functions.GetPlayer(v).PlayerData.job
                if job.name == 'police' and job.onduty then
                    num_police = num_police + 1
                end
            end
    
            local plus = cleaned * Config.policeOnDutyBonus
            plus = plus * num_police
    
            cleaned = math.floor(cleaned + plus)
        end

        Wait(Config.washers[washerId].washTime * 60000)
        print("[LAUNDRY]: CLEANED "..cleaned)
        TriggerClientEvent('qb-phone:client:LaunderNotify', source)
        Config.washers[washerId].cleaned = cleaned
        Config.washers[washerId].pickup = true

        MySQL.Sync.fetchAll("UPDATE stashitems SET items = '[]' WHERE stash = ?", { stash })
    else 
        TriggerClientEvent('QBCore:Notify', source, "There is nothing to wash!", 'error')
    end
end
