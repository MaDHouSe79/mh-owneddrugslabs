--[[ ===================================================== ]] --
--[[           MH Delivery Jobs Script by MaDHouSe         ]] --
--[[ ===================================================== ]] --
QBCore, IsLoggedIn = exports['qb-core']:GetCoreObject(), false
config, zones, zonecombos, blips, delivery, warehousePickups, bestTimeData, deliveries, dev_blips = {}, {}, {}, {}, {}, {}, {}, {}, {}
isInZone, goToCompany, trunkIsOpen, isDrivingRoute, disableControll, busy, allBlips = false, false, false, false, false, false, false
currentVan, currentVanPlate, missionBlip, boxEntity, radialmenu, isJobEnable, devMode = nil, nil, nil, nil, nil, false, false
count, countBoxes, totalboxes, deliveryId, currentDelivery, lastDeliveryId, isDeadCounter = 0, 0, 0, 0, 0, 0, 0
robthieve, isRobPlayer, hasStolenItem, inWaterCounter, jobRitTime, lastDeliveryId, cooldown = nil, false, false, 0, 0, 0, false

local function DisplayOnlyTwoRows()
    if config.RenderPropsInTrunk then
        local max = config.Storeage[config.DeliverVan].maxDisplay
        local total = countBoxes - max
        for i = 1, #config.Storeage[config.DeliverVan].storages, 1 do
            if config.Storeage[config.DeliverVan].storages[i] then
                if i <= total then
                    if DoesEntityExist(config.Storeage[config.DeliverVan].storages[i].entity) then
                        SetEntityVisible(config.Storeage[config.DeliverVan].storages[i].entity, false, true)
                        config.Storeage[config.DeliverVan].storages[i].visable = false
                    end
                elseif i > total then
                    if DoesEntityExist(config.Storeage[config.DeliverVan].storages[i].entity) then
                        SetEntityVisible(config.Storeage[config.DeliverVan].storages[i].entity, true, true)
                        config.Storeage[config.DeliverVan].storages[i].visable = true
                    end
                end
            end
        end
    end
end

local function HideBoxes()
    for i = 1, config.Storeage[config.DeliverVan].maxCapacity, 1 do
        if config.Storeage[config.DeliverVan].storages[i] then
            if DoesEntityExist(config.Storeage[config.DeliverVan].storages[i].entity) then
                if not config.RenderPropsInTrunk then
                    SetEntityVisible(config.Storeage[config.DeliverVan].storages[i].entity, false, true)
                end
            end
        end
    end
    DisplayOnlyTwoRows()
end

local function ShowBoxes()
    for i = 1, config.Storeage[config.DeliverVan].maxCapacity, 1 do
        if config.Storeage[config.DeliverVan].storages[i] then
            if DoesEntityExist(config.Storeage[config.DeliverVan].storages[i].entity) then
                if config.RenderPropsInTrunk then
                    SetEntityVisible(config.Storeage[config.DeliverVan].storages[i].entity, true, true)
                end
            end
        end
    end
    DisplayOnlyTwoRows()
end

local function OpenTrunk(vehicle)
    if vehicle ~= nil then
        RemoveControllAnimation()
        ShowBoxes()
        if type(config.Storeage[config.DeliverVan].doors) == 'number' then
            while GetVehicleDoorAngleRatio(vehicle, config.Storeage[config.DeliverVan].doors) < 1.0 do
                SetVehicleDoorOpen(vehicle, config.Storeage[config.DeliverVan].doors, false, true)
                Wait(10)
            end
        elseif type(config.Storeage[config.DeliverVan].doors) == 'table' then
            for door in pairs(config.Storeage[config.DeliverVan].doors) do
                while GetVehicleDoorAngleRatio(vehicle, config.Storeage[config.DeliverVan].doors[door]) < 1.0 do
                    SetVehicleDoorOpen(vehicle, config.Storeage[config.DeliverVan].doors[door], false, true)
                    Wait(10)
                end
            end
        end
        trunkIsOpen = true
    end
end

local function CloseTrunk(vehicle)
    if vehicle ~= nil then
        RemoveControllAnimation()
        if type(config.Storeage[config.DeliverVan].doors) == 'number' then
            while GetVehicleDoorAngleRatio(vehicle, config.Storeage[config.DeliverVan].doors) > 0.0 do
                SetVehicleDoorShut(vehicle, config.Storeage[config.DeliverVan].doors, true)
                Wait(1)
            end
        elseif type(config.Storeage[config.DeliverVan].doors) == 'table' then
            for door in pairs(config.Storeage[config.DeliverVan].doors) do
                while GetVehicleDoorAngleRatio(vehicle, config.Storeage[config.DeliverVan].doors[door]) > 0.0 do
                    SetVehicleDoorShut(vehicle, config.Storeage[config.DeliverVan].doors[door], true)
                    Wait(1)
                end
            end
        end
        HideBoxes()
        trunkIsOpen = false
    end
end

local function DeleteVan()
    if DoesEntityExist(currentVan) then
        SetEntityAsMissionEntity(currentVan, true, true)
        DeleteEntity(currentVan)
        currentVan = nil
        currentVanPlate = nil
        isDrivingRoute = false
        isStealing = false
        trunkIsOpen = false
    end
end

local function DeleteMissionBlip()
    if DoesBlipExist(missionBlip) then
        RemoveBlip(missionBlip)
        missionBlip = nil
    end
end

local function CreateMissionBlip(coords, sprite, label)
    missionBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(missionBlip, sprite)
    SetBlipColour(missionBlip, 5)
    SetBlipScale(missionBlip, 0.5)
    SetBlipAsShortRange(missionBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(missionBlip)
    if config.UseNavigation then
        SetBlipRoute(missionBlip, true)
    else
        SetBlipRoute(missionBlip, false)
    end
    return missionBlip
end

local function DespawnVan()
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:stopJob", function(result)
        if result.status then
            ResetWarehouse()
            DeleteVan()
        end
    end, currentVanPlate)
end

local function ResetGame()
    countBoxes = 0
    DeleteBoxes()
    DespawnVan()
    DeleteMissionBlip()
    isJobEnable = false
    trunkIsOpen = false
    jobRitTime = 0
    count = 0
    deliveryId = 0
    lastDeliveryId = 0
    totalboxes = 0
    currentVan = nil
    isInZone = false
    goToCompany = false
    isDrivingRoute = false
    isStealing = false
end

local function GetRandomRoutes(model)
    local data = {}
    local lastCoords = config.DeliveryVehicleSpawn
    local distance = nil
    for i = 1, #deliveries, 1 do
        if deliveries[i].type == config.deliveryType then
            data[#data + 1] = deliveries[i]
        end
    end
    local count = 1
    local routes = {}
    for i = 1, #data, 1 do
        if count <= config.Storeage[model:lower()].maxCapacity then
            local num = math.random(1, #data)
            if GetDistance(lastCoords, data[num].coords) >= config.MinDistanceBetweenRoutes then
                count = count + 1
                lastCoords = data[num].coords
                routes[#routes + 1] = data[num]
            end
        end
    end
    return routes
end

local function GetWarehousePickups(model)
    local pickups = {}
    local done = false
    local count = 1
    if config.Labs ~= nil then
        config.Labs[config.LabID].pickups[1].pickups = config.Storeage[model].maxCapacity
        for id, warehouse in pairs(config.Labs) do
            if id == config.LabID then
                if not done then
                    if count < config.Storeage[model].maxCapacity then
                        for _, pickup in pairs(warehouse.pickups) do
                            if count < config.Storeage[model].maxCapacity then
                                count = count + pickup.pickups
                                pickups[#pickups + 1] = pickup
                                done = false
                            elseif #pickups >= config.Storeage[model].maxCapacity then
                                done = true
                                break
                            end
                        end
                    elseif count >= config.Storeage[model].maxCapacity then
                        done = true
                        break
                    end
                elseif done then
                    break
                end
            end
        end
    end
    return pickups
end

local function CreateDeliverieData(model, plate)
    trunkIsOpen = false
    currentVanPlate = plate
    config.Deliveries = {}
    if not config.Deliveries[model] then config.Deliveries[model] = {} end
    config.Deliveries[model] = GetRandomRoutes(model)
    warehousePickups = GetWarehousePickups(model)
    cooldown = false
end

local function SpawnTruck(model, position, heading, plate)
    LoadModel(model)
    config.DeliverVan = model
    local vehicle = CreateVehicle(model, position.x, position.y, position.z, heading, true, true)
    local netid = NetworkGetNetworkIdFromEntity(vehicle)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetNetworkIdCanMigrate(netid, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleNumberPlateText(vehicle, plate)
    CreateDeliverieData(model, plate)
    SetEntityHeading(vehicle, heading)
    SetVehicleOnGroundProperly(vehicle)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetVehicleDirtLevel(vehicle, 0)
    WashDecalsFromVehicle(vehicle, 1.0)
    SetVehRadioStation(vehicle, 'OFF')
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetModelAsNoLongerNeeded(model)
    if warehouse ~= nil and warehouse.needItem ~= nil then config.Storeage[model].deliverItem = warehouse.needItem end
    if GetResourceState("qb-vehiclekeys") ~= 'missing' then
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
    end
    if GetResourceState(config.FuelResource) ~= 'missing' then
        exports[config.FuelResource]:SetFuel(vehicle, 100.0 + 0.0)
    elseif GetResourceState(config.FuelResource) == 'missing' then
        SetVehicleFuelLevel(vehicle, 100.0 + 0.0)
        DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
    end
    return vehicle, plate
end

local function AddBoxToTruck(vehicle)
    local model = GetHashKey(config.Storeage[config.DeliverVan].prop)
    LoadModel(model)
    for k, v in pairs(config.Storeage[config.DeliverVan].storages) do
        if count < config.Storeage[config.DeliverVan].maxCapacity and not v.loaded then
            v.loaded = true
            local box = CreateObject(model, v.coords.x, v.coords.y, v.coords.z, true, true, true)
            AttachEntityToEntity(box, vehicle, 0, v.coords.x, v.coords.y, v.coords.z - 0.2, v.rotation.x, v.rotation.y, v.rotation.z, true, true, false, true, 1, true)
            v.entity = box
            count = count + 1
            break
        end
    end
end

local function RemoveBoxFromTruck(num)
    if config.Storeage[config.DeliverVan].storages[num] and config.Storeage[config.DeliverVan].storages[num].loaded and DoesEntityExist(config.Storeage[config.DeliverVan].storages[num].entity) then
        config.Storeage[config.DeliverVan].storages[num].loaded = false
        DeleteEntity(config.Storeage[config.DeliverVan].storages[num].entity)
        config.Storeage[config.DeliverVan].storages[num].entity = nil
    end
end

local function StartCarryAnimation()
    local player = PlayerPedId()
    LoadAnimDict('amb@prop_human_bum_bin@idle_b')
    LoadAnimDict("anim@heists@box_carry@")
    disableControll = true
    TaskPlayAnim(player, 'amb@prop_human_bum_bin@idle_b', 'idle_d', 4.0, 4.0, -1, 50, 0, false, false, false)
    Wait(1500)
    TaskPlayAnim(player, "amb@prop_human_bum_bin@idle_b", "exit", 8.0, 8.0, -1, 50, 0, 0, 0, 0)
    local model = GetHashKey(config.Storeage[config.DeliverVan].prop)
    LoadModel(model)
    if not IsPedInAnyVehicle(player, false) and (DoesEntityExist(player) and not IsEntityDead(player)) and not hasBox then
        local x, y, z = table.unpack(GetEntityCoords(player))
        boxEntity = CreateObject(model, x, y, z + 0.2, true, true, true)
        AttachEntityToEntity(boxEntity, player, GetPedBoneIndex(player, 60309), 0.2, 0.08, 0.2, -45.0, 290.0, 0.0, true, true, false, true, 1, true)
        TaskPlayAnim(player, "anim@heists@box_carry@", "idle", 3.0, -8, -1, 63, 0, 0, 0, 0)
        hasBox = true
        busy = true
        disableControll = false
    end
end

local function PutBoxInTrunkAnimation()
    local player = PlayerPedId()
    LoadAnimDict('amb@prop_human_bum_bin@idle_b')
    if not IsPedInAnyVehicle(player, false) and (DoesEntityExist(player) and not IsEntityDead(player)) and hasBox then
        hasBox = false
        disableControll = true
        TaskTurnPedToFaceEntity(PlayerPedId(), currentVan, 1000)
        Wait(1500)
        DetachEntity(boxEntity, 1, 1)
        DeleteObject(boxEntity)
        boxEntity = nil
        TaskPlayAnim(player, 'amb@prop_human_bum_bin@idle_b', 'idle_d', 4.0, 4.0, -1, 50, 0, false, false, false)
        Wait(1500)
        TaskPlayAnim(player, "amb@prop_human_bum_bin@idle_b", "exit", 8.0, 8.0, -1, 50, 0, 0, 0, 0)
        ClearPedSecondaryTask(PlayerPedId())
        Wait(500)
        disableControll = false
    end
end

local function GiveAnimation()
    local player = PlayerPedId()
    LoadAnimDict('amb@prop_human_bum_bin@idle_b')
    if not IsPedInAnyVehicle(player, false) and (DoesEntityExist(player) and not IsEntityDead(player)) and hasBox then
        hasBox = false
        disableControll = true
        TaskPlayAnim(player, 'amb@prop_human_bum_bin@idle_b', 'idle_d', 4.0, 4.0, -1, 50, 0, false, false, false)
        DetachEntity(boxEntity, 1, 1)
        DeleteObject(boxEntity)
        boxEntity = nil
        Wait(1500)
        TaskPlayAnim(player, "amb@prop_human_bum_bin@idle_b", "exit", 8.0, 8.0, -1, 50, 0, 0, 0, 0)
        ClearPedSecondaryTask(PlayerPedId())
        Wait(500)
        disableControll = false
    end
end

local function IsVanToCloseByRack(coords)
    for key, warehouse in pairs(config.Labs) do
        if key == config.LabID then
            for k, v in pairs(warehouse.pickups) do
                if GetDistance(v.coords, coords) < 5 then
                    return true
                end
            end
        end
    end
    return false
end

local function IsVanCloseByDeliverPoint(entity)
    local coords = GetEntityCoords(entity)
    if config.Deliveries[config.DeliverVan] then
        for _, delivery in pairs(config.Deliveries[config.DeliverVan]) do
            if GetDistance(delivery.coords, coords) < 60 then
                return true
            end
        end
    end
    return false
end

local function IsToFarFromJobVehicle(vehicle)
    local player_coords = GetEntityCoords(PlayerPedId())
    local vehicle_coords = GetEntityCoords(vehicle)
    if GetDistance(player_coords, vehicle_coords) > 100 then return true end
    return false
end

local function GetNewDeliveryRoute()
    local data = 'busy'
    currentDelivery = currentDelivery + 1
    if currentDelivery <= config.Storeage[config.DeliverVan].maxCapacity then
        if lastDeliveryId == 0 or lastDeliveryId ~= currentDelivery then
            lastDeliveryId = currentDelivery
            if not config.Deliveries[config.DeliverVan][currentDelivery].deliverd then
                deliveryId = currentDelivery
                data = config.Deliveries[config.DeliverVan][currentDelivery]
            end
        end
    elseif currentDelivery >= config.Storeage[config.DeliverVan].maxCapacity then
        data = 'done'
    end
    return data
end

local function DeleteWarehouseBoxZone()
    if GetResourceState("qb-target") ~= 'missing' then
        exports['qb-target']:RemoveZone("duty_computer")
        exports['qb-target']:RemoveZone("jobstash")
        exports['qb-target']:RemoveZone("cokelabkey")
        exports['qb-target']:RemoveZone("weedlabkey")
        exports['qb-target']:RemoveZone("methlabkey")
        exports['qb-target']:RemoveZone("processprepare")
        exports['qb-target']:RemoveZone("processfinish")
        exports['qb-target']:RemoveZone("warehouse")
        exports['qb-target']:RemoveZone("start_loading")
        exports['qb-target']:RemoveZone("stop_loading")
        exports['qb-target']:RemoveZone("payslip")
    elseif GetResourceState("ox_target") ~= 'missing' then
        exports.ox_target:removeZone("duty_computer")
        exports.ox_target:removeZone("jobstash")
        exports.ox_target:removeZone("cokelabkey")
        exports.ox_target:removeZone("weedlabkey")
        exports.ox_target:removeZone("methlabkey")
        exports.ox_target:removeZone("processprepare")
        exports.ox_target:removeZone("processfinish")
        exports.ox_target:removeZone("warehouse")
        exports.ox_target:removeZone("start_loading")
        exports.ox_target:removeZone("stop_loading")
        exports.ox_target:removeZone("payslip")
    end
end

local function IsVehicleToDamaged(vehicle)
    if GetEntityHealth(vehicle) <= 250 then
        return true
    else
        return false
    end
end

local function DeleteAll()
    SetRelationship(false)
    ResetWarehouse()
    DeleteBlips()
    DeleteBoxes()
    DeleteDevBlips()
    DeleteShopPeds()
    DeleteAllFields()
    DeleteChemicalShopPed()
    DeletePeds()
end

local function CreateDevBlips(type, data)
    DeleteDevBlips()
    Wait(10)
    for k, v in pairs(data) do
        if v.type == type or type == 'all' or type == nil then
            local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
            SetBlipSprite(blip, v.blip.sprite)
            SetBlipScale(blip, v.blip.scale)
            SetBlipColour(blip, v.blip.color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.blip.label)
            EndTextCommandSetBlipName(blip)
            SetBlipAsShortRange(blip, true)
            dev_blips[#dev_blips + 1] = blip
        end
    end
end

function ResetWarehouse()
    if config.Labs ~= nil then
        for _, warehouses in pairs(config.Labs) do
            for k, pickup in pairs(warehouses.pickups) do
                pickup.count = 0
                pickup.isDone = false
            end
        end
        warehousePickups = {}
    end
end

function DeleteBlips()
    if #blips > 0 then
        for key, blip in pairs(blips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
    end
    blips = {}
end

function onjoin()
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:onjoin", function(result)
        if result.status then
            PlayerData = QBCore.Functions.GetPlayerData()
            config = result.config
            deliveries = result.deliveries
            CreateWarehouseZone()
            CreateShopPeds()
            CreateDealers()
            CreateChemicalShopPed()
        end
    end)
end

function DeleteBoxes()
    if config.DeliverVan ~= nil then
        for k, v in pairs(config.Storeage[config.DeliverVan].storages) do
            if v and v.entity ~= nil and DoesEntityExist(v.entity) then
                DeleteEntity(v.entity)
            end
            v.entity = nil
            v.loaded = false
        end
    end
end

function HasItem(item, amount)
    return exports['qb-inventory']:HasItem(item, amount)
end

function CountItem(item)
    local count = 0
    if PlayerData and type(PlayerData.items) == "table" then
        for _, itemData in pairs(PlayerData.items) do
            if itemData.name:lower() == item:lower() then
                count = count + itemData.amount
            end
        end
    end
    return count
end

function LockInventory(state)
    if state then
        LocalPlayer.state:set("inv_busy", true, true) -- lock
    else
        LocalPlayer.state:set("inv_busy", false, true) -- unlock
    end
end

function RequiredItems(items, bool)
    TriggerEvent('qb-inventory:client:requiredItems', items, bool)
end

function Notify(message, type, length)
    if GetResourceState("ox_lib") ~= 'missing' then
        lib.notify({ title = "MH Owned Drugs Labs", description = message, type = type })
    else
        if type == nil then type = 'primary' end
        if length == nil then length = 5000 end
        QBCore.Functions.Notify({ text = "MH Owned Drugs Labs", caption = message }, type, length)
    end
end

function DeleteDevBlips()
    if #dev_blips > 0 then
        for key, blip in pairs(dev_blips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
    end
    dev_blips = {}
end

function LoadAllBlips(type)
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:GetAllRoutesData", function(data)
        if data then CreateDevBlips(type, data) end
    end)
end

function CreateJobVehiclePlate()
    return Trim('J' .. math.random(10, 99) .. 'O' .. math.random(10, 99) .. 'B' .. math.random(1, 9))
end

function SpawnVan(model, coords, heading, plate)
    currentVan, currentVanPlate = SpawnTruck(model, coords, heading, plate)
end

function ToggleJob(state)
    isJobEnable = state
    if isJobEnable then
        OpenTrunk(currentVan)
    elseif not isJobEnable then
        ResetWarehouse()
        CloseTrunk(currentVan)
    end
end

function SetRandomRoutes()
    config.Deliveries[config.DeliverVan] = GetRandomRoutes(config.DeliverVan)
end

function AutoLoadTrunk()
    if currentVan ~= nil then
        count = 0
        countBoxes = 0
        for i = 1, config.Storeage[config.DeliverVan].maxCapacity, 1 do
            countBoxes = countBoxes + 1
            AddBoxToTruck(currentVan)
        end
        HideBoxes()
        totalboxes = countBoxes
    end
end

function CreateNewRoute()
    DeleteMissionBlip()
    isDrivingRoute = true
    goToCompany = false
    delivery = GetNewDeliveryRoute()
    if type(delivery) == 'table' then
        CreateMissionBlip(delivery.coords, 478, Lang:t('info.deliver_point'))
    elseif type(delivery) == 'string' then
        if delivery == 'done' then
            goToCompany = true
            CreateMissionBlip(config.DeliveryVehicleGarage, 473, Lang:t('info.warehouse_garage_blip'))
        elseif delivery == 'busy' then
            CreateNewRoute()
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeleteAll()
        if DoesEntityExist(currentVan) then
            if GetResourceState("qb-vehiclekeys") ~= 'missing' then
                TriggerEvent('qb-vehiclekeys:client:RemoveKeys', GetPlate(currentVan))
            end
            DeleteEntity(currentVan)
            currentVan = nil
            currentVanPlate = nil
        end
        config = {}
        PlayerData = {}
        warehousePickups = {}
        isLoggedIn = false
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        config = {}
        PlayerData = QBCore.Functions.GetPlayerData()
        isLoggedIn = true
        onjoin()
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    config = {}
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    onjoin()
end)

AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    ResetWarehouse()
    DeleteBlips()
    DeleteBoxes()
    if DoesEntityExist(currentVan) then
        if GetResourceState("qb-vehiclekeys") ~= 'missing' then
            TriggerEvent('qb-vehiclekeys:client:RemoveKeys', GetPlate(currentVan))
        end
        DeleteEntity(currentVan)
        currentVan = nil
    end
    config = {}
    PlayerData = {}
    warehousePickups = {}
    isLoggedIn = false
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate')
AddEventHandler('QBCore:Client:OnGangUpdate', function(gang)
    PlayerData.gang = gang
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    PlayerData = data
end)

RegisterNetEvent('QBCore:Client:UpdateObject', function()
    QBCore = exports['qb-core']:GetCoreObject()
end)

RegisterNetEvent('mh-owneddrugslabs:client:notify', function(message, type, length)
    Notify(message, type, length)
end)

RegisterNetEvent('mh-owneddrugslabs:client:updateDeliveries', function(data)
    deliveries = data
end)

RegisterNetEvent('mh-owneddrugslabs:client:refreshOwner', function(data)
    if config.Labs[data.id] then config.Labs[data.id].owner = data.owner end
end)

RegisterNetEvent('mh-owneddrugslabs:client:setWaypoint', function(id)
    if config.Labs[id] then
        if HasItem(config.Labs[id].labOwnerKeyItem) then
            SetNewWaypoint(config.Labs[id].computer.coords.x, config.Labs[id].computer.coords.y)
        end
    end
end)

AddEventHandler('gameEventTriggered', function(event, data)
    if isLoggedIn then
        if event == "CEventNetworkEntityDamage" then
            local victim, isDead = data[1], data[4]
            if isDead and victim == PlayerPedId() and currentVan ~= nil then
                if PlayerData.metadata['isdead'] then
                    ResetGame()
                    Notify(Lang:t('info.job_failed'), 'primary', 15000)
                end
            end
        end
    end
end)

RegisterNetEvent('mh-owneddrugslabs:client:adminDeliveryMenu', function()
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:isAdmin", function(admin)
        if admin.status then AdminDeliveryMenu() end
    end)
end)

RegisterNetEvent('mh-owneddrugslabs:client:UseCigarette', function()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        TaskPlayAnim(ped, 'timetable@gardener@smoking_joint', 'smoke_idle', 8.0, 8.0, -1, 16, 0, true, true, true)
    else
        TaskPlayAnim(ped, 'timetable@gardener@smoking_joint', 'smoke_idle', 8.0, 8.0, -1, 16, 0, true, true, true)
    end
end)

if GetResourceState("qb-radialmenu") ~= 'missing' then
    RegisterNetEvent('qb-radialmenu:client:onRadialmenuOpen', function()
        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:isAdmin", function(admin)
            if admin.status == true then
                if radialmenu ~= nil then
                    exports['qb-radialmenu']:RemoveOption(radialmenu)
                    radialmenu = nil
                end
                radialmenu = exports['qb-radialmenu']:AddOption({
                    id = 'delivery_admin',
                    title = 'Admin DrugsLabs',
                    icon = "briefcase",
                    type = 'client',
                    event = "mh-owneddrugslabs:client:adminDeliveryMenu",
                    shouldClose = true
                }, radialmenu)
            else
                radialmenu = nil
            end
        end)
    end)
else
    lib.addRadialItem({
        {
            id = 'delivery_admin',
            label = 'Admin DrugsLabs',
            icon = 'briefcase',
            onSelect = function()
                QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:isAdmin", function(admin)
                    if admin.status then
                        AdminDeliveryMenu()
                    end
                end)
            end
        }
    })
end

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and currentVan ~= nil and not isRobPlayer and not PlayerData.metadata['isdead'] then
            local text = ""
            local player = PlayerPedId()
            local player_coords = GetEntityCoords(player)
            local vehicleCoords = GetEntityCoords(currentVan)
            if isJobEnable and isInZone and not isDrivingRoute then -- warehouse pickups
                if IsVanToCloseByRack(vehicleCoords) then
                    sleep = 5
                    Draw3DText(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, Lang:t('info.close_to_the_rack'))
                else
                    if trunkIsOpen then
                        sleep = 5
                        for k, v in pairs(warehousePickups) do
                            if GetDistance(player_coords, v.coords) < 50 then
                                sleep = 2
                                if v.count >= v.pickups then v.isDone = true end
                                if v.count < v.pickups and not v.isDone then
                                    text = Lang:t('info.box_counter', { count = v.count, pickups = v.pickups })
                                    if not hasBox then
                                        if GetDistance(player_coords, v.coords) < 1.0 then
                                            text = Lang:t('info.pickup_box', { key = config.InteractkeyDisplay, count = v.count, pickups = v.pickups })
                                            if IsControlJustPressed(0, config.Interactkey) then -- wharehouse load trunk
                                                text = ""
                                                StartCarryAnimation()
                                                v.count = v.count + 1
                                            end
                                        end
                                    end
                                    Draw3DText(v.coords.x, v.coords.y, v.coords.z, text)
                                end
                            end
                        end
                        if hasBox then -- add in trunk
                            if GetDistance(player_coords, vehicleCoords) < 50 then
                                sleep = 2
                                local textCoords = GetOffsetFromEntityInWorldCoords(currentVan, 0.0, config.Storeage[config.DeliverVan].trunkPos, 0.0)
                                text = Lang:t('info.boxes_loaded', { amount = countBoxes, max = config.Storeage[config.DeliverVan].maxCapacity })
                                if GetDistance(player_coords, textCoords) < 1.0 then
                                    text = Lang:t('info.boxes_loaded_display', { key = config.InteractkeyDisplay, amount = countBoxes, max = config.Storeage[config.DeliverVan].maxCapacity })
                                    if IsControlJustPressed(0, config.Interactkey) then
                                        text = ""
                                        countBoxes = countBoxes + 1
                                        totalboxes = countBoxes
                                        PutBoxInTrunkAnimation()
                                        Wait(500)
                                        AddBoxToTruck(currentVan)
                                        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:addItem", function(_)
                                        end,{item = config.Storeage[config.DeliverVan].deliverItem, labid = config.LabID, inventory = config.TrunkInventory})
                                        Wait(1000)
                                        if countBoxes >= config.Storeage[config.DeliverVan].maxCapacity then
                                            ToggleJob(false)
                                            CreateNewRoute()
                                            Notify(Lang:t('info.deliver_all_boxes'), 'success', 10000)
                                        end
                                    end
                                end
                                Draw3DText(textCoords.x, textCoords.y, textCoords.z, text)
                            end
                        end
                    else
                        text = ""
                    end
                end
            elseif not isJobEnable and not isInZone and isDrivingRoute then -- deliveries
                if IsVanCloseByDeliverPoint(currentVan) then
                    if not IsPedInAnyVehicle(player, false) then
                        sleep = 15
                        if hasBox then -- deliver item
                            disableControll = false
                            if GetDistance(player_coords, delivery.coords) < 50 then
                                sleep = 2
                                text = Lang:t('info.deliver_storage')
                                if GetDistance(player_coords, delivery.coords) < 1.5 then
                                    DeleteMissionBlip()
                                    text = Lang:t('info.press_to_deliver', { key = config.InteractkeyDisplay })
                                    if IsControlJustPressed(0, config.Interactkey) then
                                        text = ""
                                        TaskLookAtCoord(player, delivery.coords.x, delivery.coords.y, delivery.coords.z , -1, 0, 2)
                                        config.Deliveries[config.DeliverVan][deliveryId].deliverd = true
                                        GiveAnimation()
                                        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:removeItem", function(removed)
                                            if removed then
                                                QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:payslip", function(result)
                                                    if result.status then
                                                        if countBoxes > 0 then
                                                            Notify(Lang:t('info.box_deliverd'), "primary", 5000)
                                                        else
                                                            Notify(Lang:t('info.job_done'), "success", 5000)
                                                        end
                                                        CreateNewRoute()
                                                        CloseTrunk(currentVan)
                                                    end
                                                end, config.LabID)
                                            else
                                                Notify("Item "..config.Storeage[config.DeliverVan].deliverItem.." niet gevonden.....")
                                            end
                                        end,{item = config.Storeage[config.DeliverVan].deliverItem, inventory = config.TrunkInventory})

                                    end
                                end
                                if delivery.coords ~= nil then
                                    Draw3DText(delivery.coords.x, delivery.coords.y, delivery.coords.z, text)
                                end
                            end
                        elseif not hasBox then -- pickup item
                            if trunkIsOpen then
                                local textCoords = GetOffsetFromEntityInWorldCoords(currentVan, 0.0, config.Storeage[config.DeliverVan].trunkPos, 0.0)
                                text = Lang:t('info.pickup_box_display', { amount = countBoxes, total = totalboxes })
                                if GetDistance(player_coords, vehicleCoords) < 50 then
                                    sleep = 2
                                    if GetDistance(player_coords, textCoords) < 2.5 then
                                        text = Lang:t('info.press_to_pickup', { key = config.InteractkeyDisplay, amount = countBoxes, total = totalboxes })
                                        if IsControlJustPressed(0, config.Interactkey) then
                                            text = ""
                                            TaskTurnPedToFaceEntity(PlayerPedId(), currentVan, 1000)
                                            Wait(1500)
                                            StartCarryAnimation()
                                            RemoveBoxFromTruck(countBoxes)
                                            countBoxes = countBoxes - 1
                                        end
                                    end
                                    Draw3DText(textCoords.x, textCoords.y, textCoords.z, text)
                                end
                            elseif not trunkIsOpen then
                                test = ""
                                local textCoords = GetOffsetFromEntityInWorldCoords(currentVan, 0.0, config.Storeage[config.DeliverVan].trunkPos, 0.0)
                                if GetDistance(player_coords, textCoords) > 1.0 and GetDistance(player_coords, textCoords) < 5.0 then
                                    sleep = 2
                                    if not busy then text = "~b~Open Trunk~w~" end
                                    Draw3DText(textCoords.x, textCoords.y, textCoords.z, text)
                                elseif GetDistance(player_coords, textCoords) < 1.0 then
                                    sleep = 2
                                    text = Lang:t('info.press_to_opendoors', { key = config.InteractkeyDisplay })
                                    if IsControlJustPressed(0, config.Interactkey) and not busy then
                                        disableControll = true
                                        text = ""
                                        OpenTrunk(currentVan)
                                    end
                                    Draw3DText(textCoords.x, textCoords.y, textCoords.z, text)
                                end
                            end
                        end
                    end
                end

                if IsPedInAnyVehicle(player, false) and not hasBox then
                    busy = false
                end

                local reset = false
                local txt = nil

                if IsPedInAnyVehicle(player, false) then -- park when job is done.
                    sleep = 15
                    local distance = GetDistance(player_coords, config.DeliveryVehicleGarage)
                    if distance < 25.0 then
                        sleep = 2
                        text = Lang:t('info.warehous_garage_marker')
                        if distance < 2.5 then
                            local plate = GetPlate(GetVehiclePedIsIn(player, false))
                            text = Lang:t('info.press_to_park', { key = config.InteractkeyDisplay })
                            if currentVanPlate == plate then
                                if IsControlJustPressed(0, config.Interactkey) then
                                    text = ""
                                    if countBoxes <= 0 then
                                        reset, txt = true, Lang:t('info.job_done')
                                        DeleteBoxes()
                                        DeleteEntity(GetVehiclePedIsIn(player, false))
                                    elseif countBoxes >= 1 then
                                        reset, txt = false, Lang:t('info.not_finish')
                                    end
                                end
                            elseif currentVanPlate ~= plate then
                                if IsControlJustPressed(0, config.Interactkey) then
                                    text = ""
                                    reset, txt = true, Lang:t('info.job_failed') .. "\n" .. Lang:t('info.not_correct_vehicle')
                                    DeleteBoxes()
                                    DeleteEntity(currentVan)
                                    DeleteEntity(GetVehiclePedIsIn(player, false))
                                end
                            end
                        end
                        Draw3DText(config.DeliveryVehicleGarage.x, config.DeliveryVehicleGarage.y, config.DeliveryVehicleGarage.z, text)
                    end
                end

                if txt ~= nil then
                    if reset then ResetGame() end
                    Notify(txt, 'primary', 15000)
                    sleep = 10000
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    LoadAnimDict("anim@heists@box_carry@")
    while true do
        local sleep = 1000
        if isLoggedIn and hasBox then
            sleep = 0
            if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 3) then
                TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 3.0, -8, -1, 63, 0, 0, 0, 0)
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 5000
        if isLoggedIn and currentVan ~= nil and not PlayerData.metadata['isdead'] then
            local player = PlayerPedId()
            local reset = false
            local txt = nil

            local health = GetEntityHealth(player)
            if health < 140 then
                isDeadCounter = isDeadCounter + 1
                if isDeadCounter > 3 then reset = true end
            end

            local vehicleCoords = GetEntityCoords(currentVan)
            local water, _ = GetWaterHeight(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)
            if water and not IsVehicleDriveable(currentVan, 0) then
                inWaterCounter = inWaterCounter + 1
                if inWaterCounter > 5 then reset = true end
            end

            local toFarFromVehicle = IsToFarFromJobVehicle(currentVan)
            if toFarFromVehicle and countBoxes >= 1 then reset = true end

            local isVehicleToDamaged = IsVehicleToDamaged(currentVan)
            if isVehicleToDamaged and countBoxes >= 1 then reset = true end

            local vehicleExist = DoesEntityExist(currentVan)
            if not vehicleExist then reset = true end

            if reset then
                isDeadCounter = 0
                inWaterCounter = 0
                DeleteBoxes()
                DeleteEntity(currentVan)
                ResetGame()
                Notify(Lang:t('info.job_failed'), 'primary', 15000)
                sleep = 10000
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and disableControll and not PlayerData.metadata['isdead'] then
            sleep = 5
            if IsPauseMenuActive() then SetFrontendActive(false) end
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 245, true)
            EnableControlAction(0, 38, true)
            EnableControlAction(0, 0, true)
            EnableControlAction(0, 322, true)
            EnableControlAction(0, 288, true)
            EnableControlAction(0, 213, true)
            EnableControlAction(0, 249, true)
            EnableControlAction(0, 46, true)
            EnableControlAction(0, 47, true)
        end
        Wait(sleep)
    end
end)

local dataSet = false
CreateThread(function()
    while true do
        Wait(2000)
        if isLoggedIn and config.Labs ~= nil then
            if isInZone then
                for id, lab in pairs(config.Labs) do
                    local playercoords = GetEntityCoords(PlayerPedId())
                    local distance = GetDistance(playercoords, lab.vehicle.spawn.coords)
                    if distance < 50 and not dataSet then
                        dataSet = true
                        config.LabID = lab.id
                        config.DeliveryVehicleSpawn = lab.vehicle.spawn.coords
                        config.DeliveryVehicleHeading = lab.vehicle.spawn.heading
                        config.DeliveryVehicleGarage = lab.vehicle.garage.coords
                        config.DeliveryVehicleModels = lab.vehicle.models
                        config.RouteTypes = {lab.deliveryType}
                        CreateWarehouseBoxZone(lab)
                        break
                    end
                end
            elseif not isInZone and dataSet then
                dataSet = false
                config.RouteTypes = config.DefaultRouteTypes
                DeleteWarehouseBoxZone()
            end
        end
    end
end)