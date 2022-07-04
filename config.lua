Config = {}

Config.policeOnDutyBonus = 0.05

Config.washers = {
    [1] = {
        nickName= "Washer 1", --This only reflects on the notification and charge to player
        cost= 500, --Cost to wash your money
        rtrnPerc=0.8, --Return on what is put into the washer
        vec=vector4(1122.39, -3194.4, -40.4, 359.74), --The location where the interaction will happen
        washTime = math.random(5,10), --How long it will take to wash in this washer (by minutes) NOTE: This is multipled by how many items they have in that wash. I.E. 2 stacks of markedbills = washtime * 2 and so forth.
        washing = false, --Do not touch, this is used by the server
        pickup = false, --Do not touch, this is used by the server
        cleaned = 0, --Do not touch, this is used by the server
        debug=false --If you want to see the polyzone boxzones
    },
    [2] = {nickName= "Washer 2", cost= 500, rtrnPerc=0.8, vec=vector4(1123.8, -3194.27, -40.4, 0.51), washTime = math.random(5,10), washing = false, pickup = false, cleaned = 0, debug=false},
    [3] = {nickName= "Washer 3", cost= 500, rtrnPerc=0.8, vec=vector4(1125.51, -3194.26, -40.4, 358.39), washTime = math.random(5,10), washing = false, pickup = false, cleaned = 0, debug=false},
    [4] = {nickName= "Washer 4", cost= 500, rtrnPerc=0.8, vec=vector4(1126.97, -3194.24, -40.4, 0.22), washTime = math.random(5,10), washing = false, pickup = false, cleaned = 0, debug=false},
}