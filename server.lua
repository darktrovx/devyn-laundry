local QBCore = exports['qb-core']:GetCoreObject()

local washer = { }

for k,v in pairs(Config.washers) do
    if washer[k] == nil then
        washer[k] = {washing = false, ready = false, collect = 0, time = 0}
    end
end

-- Start the washer if it is not already started.
RegisterServerEvent("laundry:startwasher", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local balance = Player.PlayerData.money['cash']

    if #(GetWasherItems(data.id)) > 0 then
        if not washer[data.id].washing then
            if Config.washers[data.id].cost > 0 then
                if balance >= Config.washers[data.id].cost then
                    Player.Functions.RemoveMoney('cash', Config.washers[data.id].cost, Config.washers[data.id].nickName)
                    wash(data.id, src)
                    for _, playerId in ipairs(GetPlayers()) do
                        TriggerClientEvent("laundry:client:isWashing", playerId, data.id, true)
                    end
                else
                    TriggerClientEvent('QBCore:Notify', src, "You need more cash to start this washer!", 'error')
                end
            else
                wash(data.id, src)
                for _, playerId in ipairs(GetPlayers()) do
                    TriggerClientEvent("laundry:client:isWashing", playerId, data.id, true)
                end
            end
        else 
            TriggerClientEvent('QBCore:Notify', src, "This washer is already started!", 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "There is nothing to wash!", 'error')
    end
end)

-- Check Time
RegisterServerEvent("laundry:check", function(data)
    local src = source
    if washer[data.id].time > 0 then
        TriggerClientEvent('QBCore:Notify', src, "There is " .. washer[data.id].time .. " minutes remaining", 'primary')
    else
        TriggerClientEvent('QBCore:Notify', src, "There's nothing washing", 'error')
    end
end)

-- Collect any waiting money from the washer.
RegisterServerEvent("laundry:collect", function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if washer[data.id].ready then 
        local payout = washer[data.id].collect
        if Config.washers[data.id].bonuses ~= nil then
            local bonus = Config.washers[data.id].bonuses
            if bonus.gang ~= nil then
                local theirGang = QBCore.Functions.GetPlayer(source).PlayerData.gang.name
                for gang, count in pairs(bonus.gang) do
                    if theirGang == gang then
                        local plus = payout * count
                        payout = math.floor(payout + plus)
                    end
                end
            end
            if bonus.job ~= nil then
                local theirJob = QBCore.Functions.GetPlayer(source).PlayerData.job.name
                for job, count in pairs(bonus.job) do
                    if theirJob == job then
                        local plus = payout * count
                        payout = math.floor(payout + plus)
                    end
                end
            end
        end

        if payout > 0 then
            player.Functions.AddMoney("cash", payout, "Money Washed")
            washer[data.id].collect = 0
            washer[data.id].ready = false
            washer[data.id].washing = false
            for _, playerId in ipairs(GetPlayers()) do
                TriggerClientEvent("laundry:client:isWashing", playerId, data.id, false)
                TriggerClientEvent("laundry:client:isReady", playerId, data.id, false)
            end
        else 
            TriggerClientEvent('QBCore:Notify', src, "There is no clean money to collect!", 'error')
            washer[data.id].collect = 0
            washer[data.id].ready = false
            washer[data.id].washing = false
            for _, playerId in ipairs(GetPlayers()) do
                TriggerClientEvent("laundry:client:isWashing", playerId, data.id, false)
                TriggerClientEvent("laundry:client:isReady", playerId, data.id, false)
            end
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
            cleaned = cleaned + (data.info.worth * data.amount)
        end 
    end
    local itemCount = #items
    local extraWashTime = 0
    if itemCount > 1 then
        extraWashTime = (itemCount-1) * Config.washers[washerId].washExtra
    else 
        extraWashTime = 0
    end

    local time = Config.washers[washerId].washTime + extraWashTime
    if cleaned > 0 then 
        washer[washerId].washing = true
        TriggerClientEvent('QBCore:Notify', source, Config.washers[washerId].nickName .. " will be done in " .. time .. " minutes.", 'primary')

        cleaned = math.floor(cleaned * Config.washers[washerId].rtrnPerc)

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

        washer[washerId].time = time
        Citizen.CreateThread(function()
            while washer[washerId].time ~= 0  do
                if washer[washerId].time < 0 then
                    washer[washerId].time = 0
                else
                    Wait(60000)
                    washer[washerId].time = washer[washerId].time - 1
                end
            end
        
            TriggerClientEvent('qb-phone:client:LaunderNotify', source)
            washer[washerId].collect = cleaned
            washer[washerId].ready = true
            for _, playerId in ipairs(GetPlayers()) do
                TriggerClientEvent("laundry:client:isReady", playerId, washerId, true)
            end
            
            MySQL.Sync.fetchAll("UPDATE stashitems SET items = '[]' WHERE stash = ?", { stash })
        end)
    else 
        TriggerClientEvent('QBCore:Notify', source, "There is nothing to wash!", 'error')
    end
end
