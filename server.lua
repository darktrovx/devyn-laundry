


local washers = {
    [1] = {washing = false, pickup = false, cleaned = 0},
    [2] = {washing = false, pickup = false, cleaned = 0},
    [3] = {washing = false, pickup = false, cleaned = 0},
    [4] = {washing = false, pickup = false, cleaned = 0},
}

QBCore.Functions.CreateCallback("laundry:isWashing", function(source, cb, washerId)
    cb(washers[washerId].washing)
end)

QBCore.Functions.CreateCallback("laundry:isReady", function(source, cb, washerId)
    cb(washers[washerId].pickup)
end)

RegisterServerEvent("laundry:startwasher")
AddEventHandler("laundry:startwasher", function(data)
    src = source
    if not washers[data.id].washing then 
        washers[data.id].washing = true
        TriggerClientEvent('QBCore:Notify', src, "Washer will be done in 10 minutes.", 'info')
        wash(data.id)
    else 
        TriggerClientEvent('QBCore:Notify', src, "This washer is already started!", 'error')
    end
end)

RegisterServerEvent("laundry:collect")
AddEventHandler("laundry:collect", function(data)
    src = source
    local player = QBCore.Functions.GetPlayer(src)

    if washers[data.id].pickup then 
        if washers[data.id].cleaned > 0 then
            player.Functions.AddMoney("cash", washers[data.id].cleaned, "Money Washed")
            washers[data.id].cleaned = 0
            washers[data.id].pickup = false
            washers[data.id].washing = false
        else 
            TriggerClientEvent('QBCore:Notify', src, "There is no clean money to collect!", 'error')
            washers[data.id].cleaned = 0
            washers[data.id].pickup = false
            washers[data.id].washing = false
        end
    else 
        TriggerClientEvent('QBCore:Notify', src, "This washer is currently cleaning!", 'error')
    end
end)


-- Stash Items
function GetWasherItems(washerId)
	local items = {}
    local stash = 'washer'..washerId
	local result = exports.ghmattimysql:executeSync("SELECT items FROM stashitems WHERE stash=@stash", {['@stash'] = stash})
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

function wash(washerId)

    local stash = 'washer'..washerId
    local items = GetWasherItems(washerId)
    local cleaned = 0

    for k,v in pairs(items) do 
        if v.name == "markedbills" then 
            cleaned = cleaned + v.info.worth 
        end 
    end

    local cleaned = (cleaned * 0.6)
    Citizen.Wait(60000 * 10)
    print("[LAUNDRY]: CLEANED "..cleaned)
    washers[washerId].cleaned = cleaned
    washers[washerId].pickup = true

    exports.ghmattimysql:execute("UPDATE stashitems SET items = '[]' WHERE stash = @stash", {
        ['@stash'] = stash,
    })
end