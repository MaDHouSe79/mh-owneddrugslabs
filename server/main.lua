
--[[ ===================================================== ]] --
--[[           MH Delivery Jobs Script by MaDHouSe         ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()
local players, stealData, netEntities = {}, {}, {}

local function OpenInventory(src, type, label)
    return exports['qb-inventory']:OpenInventory(src, type, { label = label, maxweight = 5000000, slots = 50 })
end

local function GetInventory(src, inventory)
    return exports['qb-inventory']:GetInventory(inventory)
end

local function UpdateStash(identifier, items)
    exports['qb-inventory']:UpdateStash(identifier, items)
end

local function AddItem(src, item, amount, slot, info, reason)
    local addReason = reason or 'No reason specified'
    exports['qb-inventory']:AddItem(src, item, amount, slot, info, addReason)
    if type(src) == 'number' then
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
    elseif type(src) == 'string' then
        local inventory = exports['qb-inventory']:GetInventory(src)
        exports['qb-inventory']:SetInventory(src, inventory.items)
    end
end

local function RemoveItem(src, item, amount, slot)
    exports['qb-inventory']:RemoveItem(src, item, amount, slot, false)
    if type(src) == 'number' then 
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount)
    elseif type(src) == 'string' then
        local inventory = exports['qb-inventory']:GetInventory(src)
        exports['qb-inventory']:SetInventory(src, inventory.items)
    end
end

local function HasItem(src, item, amount)
    return exports['qb-inventory']:HasItem(src, item, amount)
end

local function GetItemByName(src, item)
    return exports['qb-inventory']:GetItemByName(src, item)
end

local function CountItem(src, item)
    local count = 0
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and type(Player.PlayerData.items) == "table" then
        for _, itemData in pairs(Player.PlayerData.items) do
            if itemData.name:lower() == item:lower() then
                count = count + itemData.amount
            end
        end
    end
    return count
end
--
local function AddMoney(src, account, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.Functions.AddMoney(account, amount, nil)
end

local function GetMoney(src, account)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.money[account]
end

local function RemoveMoney(src, account, amount, reason)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.Functions.RemoveMoney(account, amount, reason)
end

local function GetCitizenid(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.citizenid
end

local function SetItemData(src, item)
    if type(item) == 'table' and item.slot ~= nil then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.PlayerData.items[item.slot] = item
        Player.Functions.SetPlayerData('items', Player.PlayerData.items)
    end
end

local function Notify(src, message, type, length)
    TriggerClientEvent('mh-owneddrugslabs:client:notify', src, message, type, length)
end

local function ResetAreas()
    Citizen.SetTimeout(SV_Config.ResetTimer * 1000, function()
        netEntities = {}
        Notify(-1, 'areas reset')
        TriggerClientEvent('mh-owneddrugslabs:client:refreshFlields', -1)
        ResetAreas()
    end)
end

local function IsAlreadyLooted(netID)
    local isLooted = false
    if netEntities[netID] then isLooted = true end
    return isLooted
end

local function SetIsLooted(netID)
    if not netEntities[netID] then netEntities[netID] = true end
end

local function IsAdmin(src)
    if IsPlayerAceAllowed(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        return true
    end
    return false
end

local function IsPlayerExist(src)
    if players[src] then return true end
    return false
end

local function AddPlayer(src)
    players[src] = true
end

local function RemovePlayer(src)
    for key in pairs(players) do
        if key == src then
            key = nil
            return true
        end
    end
    return false
end

local function UpdateMoney(labid, amount)
    MySQL.Async.execute("UPDATE owneddrugslabs SET cash = cash + ? WHERE labid = ?", { amount, labid }) -- buy from inventory
end

local function PayslipPlayer(src, labid)
    if IsPlayerExist(src) then
        for zoneid, lab in pairs(SV_Config.Labs) do
            if zoneid == labid then
                if lab.needItem ~= nil then
                    RemoveItem(src, lab.needItem, 1)
                    Wait(10)
                end
                AddItem(src, lab.rewardItem, lab.rewardAmount)
                UpdateMoney(lab.id, lab.payout * lab.rewardAmount)
                break
            end
        end
        return true
    end
    return false
end

local function GetAllRoutes()
    local list = {}
    MySQL.Async.fetchAll("SELECT * FROM drugsdeliveries", function(rs)
        if type(rs) == 'table' and #rs > 0 then
            for k, v in pairs(rs) do
                list[#list + 1] = { id = v.id, type = v.type, coords = json.decode(v.coords), deliverd = false }
            end
            TriggerClientEvent('mh-owneddrugslabs:client:updateDeliveries', -1, list)
        end
        return list
    end)
end

local function GetBlipData(type)
    for k, v in pairs(SV_Config.Labs) do
        for k, t in pairs(v.deliveryTypes) do
            if t == type then
                return v.deliveryBlip
            end
        end
    end
    return false
end

local function HasOwner(labid)
    local warehouse = MySQL.query.await('SELECT * FROM owneddrugslabs WHERE labid = ?', { labid })[1]
    if warehouse ~= nil and warehouse.labid == labid then
        if warehouse.owner == "none" then
            return false
        elseif warehouse.owner ~= "none" then
            return true
        end
    else
        return false
    end
end

local function GetOwner(labid)
    local warehouse = MySQL.query.await('SELECT * FROM owneddrugslabs WHERE labid = ?', { labid })[1]
    if warehouse ~= nil and warehouse.labid == labid then
        return warehouse.owner
    end
    return nil
end

local function IsOwner(labid, citizenid)
    local warehouse = MySQL.query.await('SELECT * FROM owneddrugslabs WHERE labid = ? and owner = ?', { labid, citizenid })[1]
    if warehouse ~= nil and tonumber(warehouse.labid) == tonumber(labid) then return true end
    return false
end

local function IsEmployee(labid, citizenid)
    local warehouse = MySQL.query.await('SELECT * FROM owneddrugslabs WHERE labid = ?', { labid })[1]
    local employees = json.decode(warehouse.employees)
    for key, employee in pairs(employees) do
        if employee.citizenid == citizenid then
            return true
        end
    end
    return false
end

local function RegisterWarehouseOwers()
    MySQL.Async.fetchAll("SELECT * FROM owneddrugslabs", function(rs)
        if type(rs) == 'table' and #rs > 0 then
            for k, v in pairs(rs) do
                SV_Config.Labs[v.labid].owner = v.owner
            end
        end
    end)
end

local function SetAsOwner(src, labid)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        MySQL.Async.fetchAll("SELECT * FROM owneddrugslabs", function(rs)
            if type(rs) == 'table' and #rs > 0 and labid > 0 then
                for k, v in pairs(rs) do
                    if v.labid == labid and v.owner == "none" then
                        local citizenid = GetCitizenid(src)
                        MySQL.Async.execute("UPDATE owneddrugslabs SET owner = ? WHERE labid = ?", { citizenid, labid })
                        local data = { id = labid, owner = v.owner }
                        SV_Config.Labs[labid].owner = v.owner
                        TriggerClientEvent('mh-owneddrugslabs:client:refreshOwner', -1, data)
                        break
                    end
                end
            end
        end)
    end
end

local function AddLabMoney(src, labid, amount)
    local citizenid = GetCitizenid(src)
    local isOwner = IsOwner(labid, citizenid)
    if isOwner then MySQL.Async.execute("UPDATE owneddrugslabs SET cash = cash + ? WHERE labid = ?", { amount, labid }) end
end

local function TakeLabMoney(src, labid, amount)
    local citizenid = GetCitizenid(src)
    local isOwner = IsOwner(labid, citizenid)
    if isOwner then
        local warehouse = MySQL.query.await('SELECT * FROM owneddrugslabs WHERE labid = ?', { labid })[1]
        if warehouse ~= nil and warehouse.cash >= amount then
            local leftOver = warehouse.cash - amount
            MySQL.Async.execute("UPDATE owneddrugslabs SET cash = ? WHERE labid = ?", { leftOver, labid })
            AddMoney(src, "cash", amount)
        end
    end
end

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:isAdmin', function(source, cb)
    local src = source
    if IsAdmin(src) then
        cb({ status = true })
        return
    end
    cb({ status = false })
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:isOwner', function(source, cb, labid)
    local src = source
    local isOwner = IsOwner(labid, GetCitizenid(src))
    if isOwner then
        cb({ status = true })
        return
    end
    cb({ status = false })
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:isEmployee', function(source, cb, labid)
    local src = source
    local isEmployee = IsEmployee(labid, GetCitizenid(src))
    if isEmployee then
        cb({ status = true })
        return
    end
    cb({ status = false })
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:submitPayslip', function(source, cb, id)
    local src = source
    if SV_Config.Labs[id] then
        local Player = QBCore.Functions.GetPlayer(src)
        local warehouse = SV_Config.Labs[id]
        if HasItem(src, warehouse.rewardItem, 1) then
            local amount = CountItem(src, warehouse.rewardItem)
            if amount >= 1 then
                RemoveItem(src, warehouse.rewardItem, amount)
                local payout = warehouse.payout * warehouse.rewardAmount
                AddMoney(src, "cash", payout)
                cb({ status = true, amount = payout })
                return
            end
        end
    end
    cb({ status = false })
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:onjoin', function(source, cb)
    local deliveries = GetAllRoutes()
    cb({status = true, config = SV_Config, deliveries = deliveries })
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:startJob', function(source, cb, inventory)
    local src = source
    MySQL.prepare('INSERT INTO inventories (identifier, items) VALUES (?, ?)', { inventory, '[]' }) -- trunk inventory
    UpdateStash(inventory, '[]')
    AddPlayer(src)
    cb({ status = true })
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:stopJob', function(source, cb, inventory)
    local src = source
    if IsPlayerExist(src) then
        if inventory ~= nil then
            local trunk = MySQL.query.await('SELECT * FROM inventories WHERE identifier = ?', { inventory })[1]
            if trunk ~= nil then MySQL.Async.execute('DELETE FROM inventories WHERE identifier = ?', { inventory }) end
            exports['qb-vehiclekeys']:RemoveKeys(src, plate)
            TriggerEvent('qb-vehiclekeys:client:RemoveKeys', src, plate)
        end
        RemovePlayer(src)
        cb({ status = true })
        return
    end
    cb({ status = false })
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:payslip', function(source, cb, id)
    local src = source
    if PayslipPlayer(src, id) then
        cb({ status = true })
        return
    end
    cb({ status = false })
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:GetAllRoutesData', function(source, cb)
    MySQL.Async.fetchAll("SELECT * FROM drugsdeliveries", function(rs)
        local list = {}
        if type(rs) == 'table' and #rs > 0 then
            for k, v in pairs(rs) do
                local blip = GetBlipData(v.type)
                list[#list + 1] = { id = v.id, type = v.type, coords = json.decode(v.coords), deliverd = false, blip = blip }
            end
        end
        cb(list)
    end)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:GetAllRoutes', function(source, cb, routeType)
    local list = {}
    MySQL.Async.fetchAll("SELECT * FROM drugsdeliveries", function(rs)
        if type(rs) == 'table' and #rs > 0 then
            for k, v in pairs(rs) do
                if v.type == routeType then
                    local blip = GetBlipData(v.type)
                    list[#list + 1] = { id = v.id, type = v.type, coords = json.decode(v.coords), deliverd = false, blip = blip }
                end
            end
            cb({ status = true, deliveries = list })
            return
        end
        cb({ status = false, deliveries = list })
    end)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:getClosestRoutes', function(source, cb, _data)
    MySQL.Async.fetchAll("SELECT * FROM drugsdeliveries", function(rs)
        local list = {}
        if type(rs) == 'table' and #rs > 0 then
            for k, v in pairs(rs) do
                if v.type == _data.type and v.coords ~= nil then
                    local tmpCoords = json.decode(v.coords)
                    local pos1 = vector3(_data.coords.x, _data.coords.y, _data.coords.z)
                    local pos2 = vector3(tmpCoords.x, tmpCoords.y, tmpCoords.z)
                    local distance = #(pos1 - pos2)
                    if distance <= 100.0 then list[#list + 1] = { id = v.id, distance = Round(distance, 2), coords = tmpCoords, type = v.type } end
                end
            end
            table.sort(list, function(a, b) return a.distance < b.distance end)
            cb({ status = true, data = list })
            return
        end
        cb({ status = false, data = list })
    end)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:createRoute', function(source, cb, data)
    MySQL.Async.fetchAll("SELECT * FROM drugsdeliveries WHERE type = ?", { data.type }, function(rs)
        if type(rs) == 'table' and #rs > 0 then
            local found = false
            for k, v in pairs(rs) do
                if v.coords ~= nil and v.type == data.type then
                    local tmpCoords = json.decode(v.coords)
                    local distance = GetDistance(data.coords, tmpCoords)
                    if distance < 2.0 then
                        found = true
                        break
                    end
                end
            end
            if not found then
                MySQL.Async.execute("INSERT INTO drugsdeliveries (type, coords) VALUES (?, ?)", { data.type, json.encode(data.coords) })
                GetAllRoutes()
                cb({ status = true, message = Lang:t('info.create_route_done', { type = data.type }) })
                return
            else
                cb({ status = false, error = Lang:t('info.location_exsist') })
                return
            end
        else
            MySQL.Async.execute("INSERT INTO drugsdeliveries (type, coords) VALUES (?, ?)", { data.type, json.encode(data.coords) })
            cb({ status = true, message = Lang:t('info.create_route_done', { type = data.type }) })
            return
        end
    end)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:countRouteTypes', function(source, cb)
    local total = 0
    local drugs = MySQL.query.await('SELECT type FROM drugsdeliveries WHERE type = ?', { "drugs" })
    total = total + #drugs
    cb({ ['drugs'] = #drugs, ['total'] = total })
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:deleteRoute', function(source, cb, id)
    MySQL.Async.fetchAll("SELECT * FROM drugsdeliveries", function(rs)
        if type(rs) == 'table' and #rs > 0 then
            local type = nil
            for k, v in pairs(rs) do
                if v.id == id then
                    type = v.type
                    MySQL.Async.execute('DELETE FROM drugsdeliveries WHERE id = ?', { v.id })
                    GetAllRoutes()
                    break
                end
            end
            cb({ status = true, message = Lang:t('info.delete_route_done', { id = id, type = type }) })
            return
        end
        cb({ status = false, error = Lang:t('info.locations_not_found') })
    end)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:buyLabkey', function(source, cb, id)
    local src = source
    if SV_Config.Labs[id] then
        local warehouse = SV_Config.Labs[id]
        local hasOwner = HasOwner(warehouse.id)
        if hasOwner == true then
            cb({ status = false, message = "Iemand heeft deze lab al gekocht...", hasOwner = true })
            return
        elseif hasOwner == false then
            local hasmoney = GetMoney(src, "cash")
            if hasmoney >= warehouse.shop.price then
                if warehouse.labOwnerKeyItem ~= nil then
                    RemoveMoney(src, "cash", warehouse.shop.price, false)
                    local info = { typekey = "Owner Key", labid = warehouse.id }
                    for i = 1, SV_Config.GiveKeys, 1 do
                        AddItem(src, warehouse.labOwnerKeyItem, 1, false, info)
                    end
                    SetAsOwner(src, id)
                    TriggerClientEvent('mh-owneddrugslabs:client:setWaypoint', src, id)
                    cb({ status = true, message = "je bent een lab sleutel gekocht", hasOwner = false })
                    return
                else
                    return
                end
            else
                cb({ status = false, message = "je hebt niet genoeg geld", hasOwner = false })
                return
            end
        end
    end
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:buyNewLabkey', function(source, cb, id)
    local src = source
    if SV_Config.Labs[id] then
        local warehouse = SV_Config.Labs[id]
        local hasOwner = HasOwner(warehouse.id)
        if hasOwner then
            local citizenid = GetCitizenid(src)
            local owner = GetOwner(warehouse.id)
            if citizenid == owner then
                local hasmoney = GetMoney(src, "cash")
                if hasmoney >= SV_Config.KeyPrice then
                    RemoveMoney(src, "cash", SV_Config.KeyPrice, false)
                    local info = { keyType = "Owner Key", labid = warehouse.id }
                    AddItem(src, warehouse.labOwnerKeyItem, SV_Config.GiveKeys, false, info, false)
                    cb({ status = true, message = "je hebt een nieuwe eigenaar lab sleutel gekocht" })
                    return
                else
                    cb({ status = false, message = "je hebt niet genoeg geld" })
                    return
                end
            else
                cb({ status = false, message = "je bent geen lab eigenaar..." })
                return
            end
        end
    else
        cb({ status = false, message = "er gaat iets mis..." })
        return
    end
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:buyEmpoyeeKeys', function(source, cb, id, amount)
    local src = source
    if SV_Config.Labs[id] then
        local warehouse = SV_Config.Labs[id]
        local hasOwner = HasOwner(warehouse.id)
        if hasOwner then
            local citizenid = GetCitizenid(src)
            local owner = GetOwner(warehouse.id)
            if citizenid == owner then
                local hasmoney = GetMoney(src, "cash")
                if hasmoney >= SV_Config.KeyPrice then
                    RemoveMoney(src, "cash", SV_Config.KeyPrice, false)
                    local info = { keyType = "Employee Key", labid = warehouse.id }
                    AddItem(src, warehouse.labEmployeeKeyItem, amount, false, info, false)
                    cb({ status = true, message = "je hebt een nieuwe werknamers lab sleutel gekocht" })
                    return
                else
                    cb({ status = false, message = "je hebt niet genoeg geld" })
                    return
                end
            else
                cb({ status = false, message = "je bent geen lab eigenaar..." })
                return
            end
        end
    else
        cb({ status = false, message = "er gaat iets mis..." })
        return
    end
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:openStash', function(source, cb, type, label)
    local src = source
    if type ~= nil then OpenInventory(src, type, label) end
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:openShop', function(source, cb, data)
    local src = source
    if data.type ~= nil then OpenShop(src, data) end
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:addItem', function(source, cb, data)
    local src = source
    if SV_Config.Labs[data.labid] then
        local labData = SV_Config.Labs[data.labid]
        AddItem(src, data.inventory, data.item, 1)
        RemoveItem(src, labData.ownerstash.name, data.item, 1)
        cb(true)
        return
    else
        cb(false)
        return
    end
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:removeItem', function(source, cb, data)
    local src = source
    RemoveItem(src, data.inventory, data.item, 1)
    cb(true)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:process', function(source, cb, data)
    local src = source
    if SV_Config.Labs[data.labid] then
        local lab = SV_Config.Labs[data.labid]
        if data.type == "prepare" then
            if lab.process.prepare.needItems ~= nil then
                for k, item in pairs(lab.process.prepare.needItems) do
                    local countItem = CountItem(src, item.name)
                    if countItem >= item.amount then
                        RemoveItem(src, item.name, item.amount, false)
                    else
                        cb({ status = false, message = "Je hebt niet genoeg items" })
                        return
                    end
                end
                if SV_Config.GiveItemsToPlayers then
                    AddItem(src, lab.process.prepare.rewardItem, lab.process.prepare.rewardAmount, false)
                else
                    AddItem(lab.ownerstash.name, lab.process.prepare.rewardItem, lab.process.prepare.rewardAmount, false)
                    local inventory = exports['qb-inventory']:GetInventory(lab.ownerstash.name)
                    exports['qb-inventory']:SetInventory(lab.ownerstash.name, inventory.items)
                end
                cb({ status = true, message = "Je hebt je item voorbereid" })
                return
            end
        elseif data.type == "finish" then
            if lab.process.finish.needItems ~= nil then
                for k, item in pairs(lab.process.finish.needItems) do
                    local countItem = CountItem(src, item.name)
                    if countItem >= item.amount then
                        RemoveItem(src, item.name, item.amount, false)
                    else
                        cb({ status = false, message = "Je hebt niet genoeg items" })
                        return
                    end
                end
                if SV_Config.GiveItemsToPlayers then
                    AddItem(src, lab.process.finish.rewardItem, lab.process.finish.rewardAmount, false)
                else
                    AddItem(lab.ownerstash.name, lab.process.finish.rewardItem, lab.process.finish.rewardAmount, false)
                    local inventory = exports['qb-inventory']:GetInventory(lab.ownerstash.name)
                    exports['qb-inventory']:SetInventory(lab.ownerstash.name, inventory.items)
                end
                cb({ status = true, message = "Je hebt je item afgemaakt" })
                return
            end
        elseif data.type == "rollfinish" then
            if lab.process.rolljoint.needItems ~= nil then
                for k, item in pairs(lab.process.rolljoint.needItems) do
                    local countItem = CountItem(src, item.name)
                    if countItem >= item.amount then
                        RemoveItem(src, item.name, item.amount, false)
                    else
                        cb({ status = false, message = "Je hebt niet genoeg items" })
                        return
                    end
                end
                if SV_Config.GiveItemsToPlayers then
                    AddItem(src, lab.process.rolljoint.rewardItem, lab.process.rolljoint.rewardAmount, false)
                else
                    AddItem(lab.ownerstash.name, lab.process.rolljoint.rewardItem, lab.process.rolljoint.rewardAmount, false)
                    local inventory = exports['qb-inventory']:GetInventory(lab.ownerstash.name)
                    exports['qb-inventory']:SetInventory(lab.ownerstash.name, inventory.items)
                end
                cb({ status = true, message = "Je hebt je item afgemaakt" })
                return
            end
        end
    end
    cb({ status = false, message = "Er is een fout opgetreden...." })
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:robPlayer', function(source, cb)
    local src = source
    local result = { status = false, message = nil }
    for _, warehouse in pairs(SV_Config.Labs) do
        if HasItem(src, warehouse.rewardItem, 1) then
            local amount = CountItem(src, warehouse.rewardItem)
            if amount >= 1 then
                local random = math.random(1, amount)
                if not stealData[src] then stealData[src] = {} end
                stealData[src] = { item = warehouse.rewardItem, amount = random }
                RemoveItem(src, warehouse.rewardItem, random, nil)
                result = { status = false, message = Lang:t('info.stole_your_payslips') }
                break
            elseif amount <= 0 then
                break
            end
        else
            break
        end
    end
    cb(result)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:takeItemsBack', function(source, cb, thieve_netid)
    local src = source
    if stealData[src] and stealData[src].item and stealData[src].amount then
        if stealData[src].item ~= nil and stealData[src].amount ~= nil then
            AddItem(src, stealData[src].item, stealData[src].amount, nil)
            stealData[src] = {}
            TriggerClientEvent('mh-owneddrugslabs:client:deletethieve', -1, thieve_netid)
            cb({ status = true, message = Lang:t('info.take_payslips_back') })
        end
    end
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:loot', function(source, cb, data)
    local src = source
    local result = { status = false, message = nil }
    if not IsAlreadyLooted(data.entity) then
        local win = math.random(1, 100)
        if data.chance >= 100 then win = 100 end
        if win >= data.chance then
            SetIsLooted(data.entity)
            AddItem(src, data.rewardItem, data.rewardAmount)
            result = { status = true }
        else
            result = { status = false, message = 'you did not find anyting here' }
        end
    else
        result = { status = false, message = 'already taken' }
    end
    cb(result)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:GetInventory', function(source, cb, inventory)
    local src = source
    local data = GetInventory(src, inventory)
    cb(data)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:GetMoneyAmount', function(source, cb, labid)
    local src = source
    local warehouse = MySQL.query.await('SELECT * FROM owneddrugslabs WHERE labid = ?', { labid })[1]
    if warehouse ~= nil and warehouse.cash ~= nil then
        cb(warehouse.cash)
        return
    end
    cb(0)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:GetEmployees', function(source, cb, data)
    local employees = {}
    local lab = MySQL.query.await('SELECT * FROM owneddrugslabs WHERE labid = ?', { data.labid })[1]
    if lab ~= nil then employees = json.decode(lab.employees) end
    cb(employees)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:AddEmployee', function(source, cb, data)
    local lab = MySQL.query.await('SELECT * FROM owneddrugslabs WHERE labid = ?', { data.labid })[1]
    local result = { status = false, message = nil }
    if lab ~= nil then
        local warehouse = SV_Config.Labs[data.labid]
        local target = QBCore.Functions.GetPlayer(data.targetId)
        if target then
            local employees = json.decode(lab.employees)
            local exsist = false
            for key, employee in pairs(employees) do
                if employee.citizenid == target.PlayerData.citizenid then exsist = true end
            end
            if exsist then
                result = { status = false, message = "Player already exsist" }
            elseif not exsist then
                local citizenid = target.PlayerData.citizenid
                local firstname = target.PlayerData.charinfo.firstname
                local lastname = target.PlayerData.charinfo.lastname
                local info = { typekey = "Employee Key", labid = warehouse.id, labName = warehouse.name }
                AddItem(data.targetId, warehouse.labEmployeeKeyItem, 1, false, info, false)
                employees[#employees + 1] = { citizenid = citizenid, firstname = firstname, lastname = lastname }
                MySQL.Async.execute("UPDATE owneddrugslabs SET employees = ? WHERE labid = ?", { json.encode(employees), data.labid })
                result = { status = false, message = "Player is added as lab employee" }
            end
        else
            result = { status = false, message = "Player not found in qb-core players" }
        end
    else
        result = { status = false, message = "This lab does not exsist" }
    end
    cb(result)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:RemoveEmployee', function(source, cb, data)
    local lab = MySQL.query.await('SELECT * FROM owneddrugslabs WHERE labid = ?', { data.labid })[1]
    local result = { status = false, message = nil }
    if lab ~= nil then
        local employees = json.decode(lab.employees)
        local exsist = false
        for key, employee in pairs(employees) do
            if employee.citizenid == data.citizenid then
                employees[key] = nil
                exsist = true
                break
            end
        end
        if exsist then
            MySQL.Async.execute("UPDATE owneddrugslabs SET employees = ? WHERE labid = ?", { json.encode(employees), data.labid })
            result = { status = false, message = "Player is removesd as lab employee" }
        end
    else
        result = { status = false, message = "This lab does not exsist" }
    end
    cb(result)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:IsEmployee', function(source, cb, data)
    local src = source
    local lab = MySQL.query.await('SELECT type FROM owneddrugslabs WHERE labid = ?', { data.labid })[1]
    local result = { status = false }
    if lab ~= nil then
        local target = QBCore.Functions.GetPlayer(src)
        if target then
            local employees = json.decode(lab.employees)
            local exsist = false
            for _, employee in pairs(employees) do
                if employee.citizenid == target.PlayerData.citizenid then exsist = true end
            end
            if exsist then result = { status = true } end
        end
    end
    cb(result)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:AddMoney', function(source, cb, data)
    local src = source
    local result = { status = false }
    if IsOwner(labid, GetCitizenid(src)) then
        AddLabMoney(src, labid, amount)
        result = { status = true }
    end
    cb(result)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:TakeMoney', function(source, cb, data)
    local src = source
    local result = { status = false }
    if IsOwner(labid, GetCitizenid(src)) then
        TakeLabMoney(src, labid, amount)
        result = { status = true }
    end
    cb(result)
end)

QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:LabHasItem', function(source, cb, data)
    local result = {status = false}
    if HasItem(data.ownerstash, data.item, data.amount) then result = {status = true} end
    cb(result)
end)

-- todo
QBCore.Functions.CreateCallback('mh-owneddrugslabs:server:ArrestDealer', function(source, cb, data)
    --print(json.encode(data,{indent=true}))
end)

QBCore.Functions.CreateUseableItem('cigarettebox', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = GetItemByName(src, 'cigarettebox')
    if item.info ~= nil and item.info.amount >= 1 then
        AddItem(src, 'cigarette', 1)
        item.info.amount = item.info.amount - 1
        if item.info.amount <= 0 then
            RemoveItem(src, 'cigarettebox', 1, item.slot)
        else
            SetItemData(src, item)
        end
    end
end)

for key, item in pairs(SV_Config.UseableItems) do
    QBCore.Functions.CreateUseableItem(item.name, function(source)
        local src = source
        if HasItem(src, item.name, 1) then
            RemoveItem(src, item.name, 1)
            TriggerClientEvent(item.trigger, src)
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for id, warehouse in pairs(SV_Config.Labs) do warehouse.owner = nil end
        netEntities = {}
        ResetAreas()
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        RegisterWarehouseOwers()
        netEntities = {}
        ResetAreas()
    end
end)

RegisterNetEvent('mh-owneddrugslabs:server:buyItems', function(data)
    local src = data.src
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local total = tonumber(data.price) * data.amount
        if Player.PlayerData.money["cash"] >= total then
            if HasItem(data.ownerstash, data.item, data.amount) then
                if RemoveMoney(src, "cash", total, false) then
                    if data.item == "cigarettebox" then
                        RemoveItem(data.ownerstash, data.item, data.amount, false)
                        for i = 1, data.amount, 1 do
                            AddItem(src, data.item, 1, false, { amount = 25 })
                        end
                    end
                else
                    if RemoveMoney(src, "cash", total, false) then
                        RemoveItem(data.ownerstash, data.item, data.amount, false)
                        AddItem(src, data.item, data.amount, false)
                    end
                end
            end
        else
            TriggerClientEvent("mh-owneddrugslabs:client:notify", src "Je hebt niet genoeg geld op zak...", "error")
        end
    end
end)

RegisterNetEvent('mh-owneddrugslabs:server:buyChemicalShopItems', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local price = SV_Config.ItemPrice[data.item:lower()].price
        if tonumber(price) >= 1 then
            local total = tonumber(price) * data.amount
            local hasmoney = GetMoney(src, "cash")
            if hasmoney >= total then
                if RemoveMoney(src, "cash", total, false) then
                    AddItem(src, data.item, data.amount)
                end
            else
                Notify(src, "Je hebt niet genoeg geld op zak...", "error", 5000)
            end
        end
    end
end)