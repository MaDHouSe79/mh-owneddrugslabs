# QB Inventory
- Add the image insite `inventory images folder` to your `inventory/html/images` folder


# QB-INVENTORY
- to add in qb-inventory/server/functions.lua around line 51.
```lua
function UpdateStash(identifier, items)
    if Inventories[identifier] then
        Inventories[identifier].items = items
    elseif not Inventories[identifier] then
        CreateInventory(identifier, { maxweight = Config.StashSize.maxweight, slots = Config.StashSize.slots, items = items })
    end
end

exports('UpdateStash', UpdateStash)
```

# QB Shared Items
```lua
pay_slip_coke                = { name = 'pay_slip_coke', label = 'Pay Slip', weight = 0, type = 'item', image = 'pay_slip.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Pay slip for coke brick delivery' },
pay_slip_weed                = { name = 'pay_slip_weed', label = 'Pay Slip', weight = 0, type = 'item', image = 'pay_slip.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Pay slip for weed brick delivery' },
pay_slip_meth                = { name = 'pay_slip_meth', label = 'Pay Slip', weight = 0, type = 'item', image = 'pay_slip.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Pay slip for meth delivery' },
weedlabownerkey              = { name = 'weedlabownerkey', label = 'Weed Lab Owner Key', weight = 500, type = 'item', image = 'labkey.png', unique = true, useable = true, shouldClose = true, description = 'Key for a weed lab.' },
cokelabownerkey              = { name = 'cokelabownerkey', label = 'Coke Lab Owner Key', weight = 500, type = 'item', image = 'labkey.png', unique = true, useable = true, shouldClose = true, description = 'Key for a coke lab.' },
methlabownerkey              = { name = 'methlabownerkey', label = 'Meth Lab Owner Key', weight = 500, type = 'item', image = 'labkey.png', unique = true, useable = true, shouldClose = true, description = 'Key for a meth lab.' },
weedlabemployeekey           = { name = 'weedlabemployeekey', label = 'Weed Lab Employee Key', weight = 500, type = 'item', image = 'labkey.png', unique = true, useable = true, shouldClose = true, description = 'Key for a weed lab.' },
cokelabemployeekey           = { name = 'cokelabemployeekey', label = 'Coke Lab Employee Key', weight = 500, type = 'item', image = 'labkey.png', unique = true, useable = true, shouldClose = true, description = 'Key for a coke lab.' },
methlabemployeekey           = { name = 'methlabemployeekey', label = 'Meth Lab Employee Key', weight = 500, type = 'item', image = 'labkey.png', unique = true, useable = true, shouldClose = true, description = 'Key for a meth lab.' }, 
cigarettebox                 = { name = 'cigarettebox', label = 'Cigarette box', weight = 5, type = 'item', image = 'cigarettebox.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'A Cigarette Box (25)' },
cigarette                    = { name = 'cigarette', label = 'Cigarette', weight = 1, type = 'item', image = 'cigarette.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A cigarette...' },
empty_baggy                  = { name = 'empty_baggy', label = 'Empty Baggy', weight = 0, type = 'item', image = 'empty_baggy.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Empty Baggy' },
trowel                       = { name = 'trowel', label = 'Trowel', weight = 0, type = 'item', image = 'trowel.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Trowel' },
cannabis                     = { name = 'cannabis', label = 'Cannabis', weight = 0, type = 'item', image = 'cannabis.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'cannabis' },
weed_baggy                   = { name = 'weed_baggy', label = 'Weed Baggy', weight = 0, type = 'item', image = 'weed_baggy.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Weed Baggy' },
cocaineleaf                  = { name = 'cocaineleaf', label = 'Cocaineleaf', weight = 0, type = 'item', image = 'cocaineleaf.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Cocaineleaf' },
coke_baggy                   = { name = 'coke_baggy', label = 'Coke Baggy', weight = 0, type = 'item', image = 'coke_baggy.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Coke Baggy' },
methylamine                  = { name = 'methylamine', label = 'Methylamine', weight = 0, type = 'item', image = 'methylamine.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Methylamine' },
ammonia                      = { name = 'ammonia', label = 'Ammonia', weight = 0, type = 'item', image = 'ammonia.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Ammonia' },
meth_tray                    = { name = 'meth_tray', label = 'Meth Tray', weight = 0, type = 'item', image = 'meth_tray.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Meth Tray' },
meth_baggy                   = { name = 'meth_baggy', label = 'Meth Baggy', weight = 0, type = 'item', image = 'meth_baggy.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Meth Baggy' },
```



# Replace in QB-Inventory
- replace in qb-inventory/server/main.lua
```lua
QBCore.Functions.CreateCallback('qb-inventory:server:attemptPurchase', function(source, cb, data)
    local itemInfo = data.item
    local amount = data.amount
    local shop = string.gsub(data.shop, 'shop%-', '')
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        cb(false)
        return
    end

    local shopInfo = RegisteredShops[shop]
    if not shopInfo then
        cb(false)
        return
    end

    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    if shopInfo.coords then
        local shopCoords = vector3(shopInfo.coords.x, shopInfo.coords.y, shopInfo.coords.z)
        if #(playerCoords - shopCoords) > 10 then
            cb(false)
            return
        end
    end

    if shopInfo.items[itemInfo.slot].name ~= itemInfo.name then -- Check if item name passed is the same as the item in that slot
        cb(false)
        return
    end

    if amount > shopInfo.items[itemInfo.slot].amount then
        TriggerClientEvent('QBCore:Notify', source, 'Cannot purchase larger quantity than currently in stock', 'error')
        cb(false)
        return
    end

    if not CanAddItem(source, itemInfo.name, amount) then
        TriggerClientEvent('QBCore:Notify', source, 'Cannot hold item', 'error')
        cb(false)
        return
    end

    local price = shopInfo.items[itemInfo.slot].price * amount

    if itemInfo.name == "cigarettebox" then
        TriggerEvent('mh-owneddrugslabs:server:buyItems', {src = source, item = itemInfo.name, amount = amount, price = price})
    else
        if Player.PlayerData.money.cash >= price then
            Player.Functions.RemoveMoney('cash', price, 'shop-purchase')
            AddItem(source, itemInfo.name, amount, nil, itemInfo.info, 'shop-purchase')
            TriggerEvent('qb-shops:server:UpdateShopItems', shop, itemInfo, amount)
            cb(true)
        else
            TriggerClientEvent('QBCore:Notify', source, 'You do not have enough money', 'error')
            cb(false)
        end
    end
end)
```
