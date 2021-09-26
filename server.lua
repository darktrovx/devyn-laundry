
-- List of washers. The table key is the washerId.
local washers = {
    [1] = {washing = false, pickup = false, cleaned = 0},
    [2] = {washing = false, pickup = false, cleaned = 0},
    [3] = {washing = false, pickup = false, cleaned = 0},
    [4] = {washing = false, pickup = false, cleaned = 0},
}

-- Callback to check if the passed washerId is already washing.
QBCore.Functions.CreateCallback("laundry:isWashing", function(source, cb, washerId)
    cb(washers[washerId].washing)
end)

-- Callback check to see if the passed washerId is ready for collection/pickup.
QBCore.Functions.CreateCallback("laundry:isReady", function(source, cb, washerId)
    cb(washers[washerId].pickup)
end)

-- Start the washer if it is not already started.
RegisterServerEvent("laundry:startwasher")
AddEventHandler("laundry:startwasher", function(data)
    src = source
    if not washers[data.id].washing then
        wash(data.id, src)
    else 
        TriggerClientEvent('QBCore:Notify', src, "This washer is already started!", 'error')
    end
end)

-- Collect any waiting money from the washer.
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


-- Get the stash items for the passed washerId: This function was taken from qb-inventory and modifed.
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

-- Attempt to start the washing cycle of the passed washerId.
function wash(washerId, source)

    local stash = 'washer'..washerId
    local items = GetWasherItems(washerId)
    local cleaned = 0

    -- Loop through the items in the stash. If its a "markedbills" item then get its "worth" from the info table and add it to the total "cleaned" amount.
    for item, data in pairs(items) do 
        if data.name == "markedbills" then
            if data.info.worth ~= nil then
                cleaned = cleaned + data.info.worth
            end
        end 
    end

    -- Check to make sure there is anything to clean/wash. 
    if cleaned > 0 then 
        washers[washerId].washing = true
        TriggerClientEvent('QBCore:Notify', source, "Washer will be done in 10 minutes.", 'primary')

        -- Set total to 80% of total marked bills worth.
        local cleaned = (cleaned * 0.8)
        -- Wait 10 minutes for wash cycle.
        Citizen.Wait(60000 * 10)
        print("[LAUNDRY]: CLEANED "..cleaned)
        washers[washerId].cleaned = cleaned
        washers[washerId].pickup = true

        -- Remove the items from the stash by setting it to be empty in the database.
        exports.ghmattimysql:execute("UPDATE stashitems SET items = '[]' WHERE stash = @stash", {
            ['@stash'] = stash,
        })
    else 
        TriggerClientEvent('QBCore:Notify', source, "There is nothing to wash!", 'error')
    end
end