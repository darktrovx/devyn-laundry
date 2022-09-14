Config = {}

Config.policeOnDutyBonus = 0.05 -- Is added to the base amount

Config.UseTargetDoors = true
Config.Entrance = {
    coords = vector4(-372.2, 194.22, 84.06, 5.32),
    width = 1,
    length = 1,
    minZ = 1,
    maxZ = 1.25,
    text = 'Enter',
    debug = false
}

Config.Exit = {
    coords = vector4(1138.07, -3199.2, -39.67, 359.79),
    width = 1,
    length = 1,
    minZ = 1,
    maxZ = 1.25,
    text = 'Exit',
    debug = false
}

Config.washers = {
    [1] = {
        nickName = "Washer 1", -- This only reflects on the notification and charge to player
        cost = 500, -- Cost to wash your money in cash
        rtrnPerc = 0.8, -- Return percentage on what is put into the washer
        vec = vector4(1122.37, -3193.47, -40.3, 0), -- The location where the interaction will happen
        washTime = math.random(2,7), -- How long the first item will take, to wash in this washer (by minutes) in random between 2 and 7 minutes. 
        washExtra = math.random(1,3), -- How long every additional item will take to wash. I.E. washTime (item 1) takes 4 minutes, and you have 3 more items in the washer at 1 minute each, so now the washing time is 7 minutes.
        bonuses = {
            gang = {
                ["lostmc"] = 2.00, -- Lost get a 0.05% bonus added to the value of the wash at collection
                ["crips"] = 0.15 -- Crips get a 0.15% bonus added to the value of the wash at collection
            },
            job = {
                ["police"] = 0.05 -- Police get a 0.05% bonus added to the value of the wash at collection
            }
        },
        debug = false -- If you want to see the polyzone boxzones
    },
    [2] = {nickName= "Washer 2", cost= 500, rtrnPerc=0.8, vec=vector4(1123.77, -3193.35, -40.3, 0), washTime = math.random(2,7), washExtra = math.random(1,3), bonuses = {gang = {["lostmc"] = 0.05, ["crips"] = 0.15}}, debug=false},
    [3] = {nickName= "Washer 3", cost= 500, rtrnPerc=0.8, vec=vector4(1125.52, -3193.31, -40.3, 0), washTime = math.random(2,7), washExtra = math.random(1,3), debug=false},
    [4] = {nickName= "Washer 4", cost= 500, rtrnPerc=0.8, vec=vector4(1126.95, -3193.31, -40.3, 0), washTime = math.random(2,7), washExtra = math.random(1,3), debug=false},
}
