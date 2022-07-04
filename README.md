# BrianTU's Update
This is a modified version of the public resource uploaded by [devin-monro](https://github.com/devin-monro/devyn-laundry)
Some inspiration by [JamesSc0tt's laundry](https://github.com/JamesSc0tt/qb-overlord-laundering) another public laundry resource.

What my edits do is introduces a config file, that lets you customize each washer easily and fast.

Additionally, I added support for the qb-phone alert provided by JamesSc0tt's laundry.

If you want to add the alert, add the following code to qb-phone/client/main.lua
```
RegisterNetEvent('qb-phone:client:LaunderNotify')
AddEventHandler('qb-phone:client:LaunderNotify', function(message)
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = "Washing Machine",
            text = "Cycle Completed",
            icon = "fas fa-check",
            color = "#ebc934",
            timeout = 3500,
        },
    })
end)
```

I've put notes where I can.

# FiveM-QBCore-Money-Wash (Original)

MLO: https://www.gta5-mods.com/maps/abandoned-laundromat-interior-singleplayer-fivem-gtadps

qb-target: https://github.com/BerkieBb/qb-target

This is a script I made for players to wash money at a laundromat. Players deposit up to 10 marked bills and can start the washer. In 10 minutes the marked bills will be turned into 80% of the total worth of the bags. The players can collect the cash for pickup when the washer has compeleted its cycle.

NOTE: This allows ANY player to come and collect the money once the cycle is done.

![image](https://user-images.githubusercontent.com/7463741/134788660-b9813e9a-4271-49d3-8b00-ac8510949623.png)
