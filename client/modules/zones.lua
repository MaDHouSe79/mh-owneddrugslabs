local function PrepareProcess(id)
    disableControll = true
    isBizy = true
    LockInventory(true)
    local options = {
        duration = 5000,
        label = 'Finish Process',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true },
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_player',
            flag = 16,
        },
    }
    if lib.progressCircle(options) then
        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:process", function(result)
            if result.status then Notify(result.message) else Notify(result.message) end
            ClearPedTasks(PlayerPedId())
            LockInventory(false)
            isBizy = false
            disableControll = false
        end, {labid=id, type='prepare'})
    else
        ClearPedTasks(PlayerPedId())
        LockInventory(false)
        isBizy = false
        disableControll = false
    end
end

local function FinishProcess(id)
    disableControll = true
    isBizy = true
    LockInventory(true)
    local options = {
        duration = 10000,
        label = 'Finish Process',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true },
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_player',
            flag = 16,
        },
    }
    if lib.progressCircle(options) then
        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:process", function(result)
            if result.status then Notify(result.message) else Notify(result.message) end
            ClearPedTasks(PlayerPedId())
            LockInventory(false)
            isBizy = false
            disableControll = false
        end, {labid=id, type='finish'})
    else
        ClearPedTasks(PlayerPedId())
        LockInventory(false)
        isBizy = false
        disableControll = false
    end
end

local function RollJointProcess(id)
    disableControll = true
    isBizy = true
    LockInventory(true)
    local options = {
        duration = 10000,
        label = 'Finish Process',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true },
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_player',
            flag = 16,
        },
    }
    if lib.progressCircle(options) then
        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:process", function(result)
            if result.status then Notify(result.message) else Notify(result.message) end
            ClearPedTasks(PlayerPedId())
            LockInventory(false)
            isBizy = false
            disableControll = false
        end, {labid=id, type='rollfinish'})
    else
        ClearPedTasks(PlayerPedId())
        LockInventory(false)
        isBizy = false
        disableControll = false
    end
end

function CreateWarehouseZone()
    if config.Labs ~= nil then
        DeleteBlips()
        for id, warehouse in pairs(config.Labs) do
            if (warehouse.setData == nil or not warehouse.setData) then
                warehouse.setData = true
                if config.Debug then
                    local blip = AddBlipForRadius(warehouse.computer.coords.x, warehouse.computer.coords.y, warehouse.computer.coords.z, warehouse.computer.blip.radius)
                    SetBlipHighDetail(blip, true)
                    SetBlipColour(blip, warehouse.computer.blip.color)
                    SetBlipAlpha (blip, 128)
                end
                if warehouse.computer.blip.enable then
                    local blip = AddBlipForCoord(warehouse.computer.coords.x, warehouse.computer.coords.y, warehouse.computer.coords.z)
                    SetBlipSprite(blip, warehouse.computer.blip.sprite)
                    SetBlipScale(blip, warehouse.computer.blip.scale)
                    SetBlipColour(blip, warehouse.computer.blip.color)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(warehouse.computer.blip.label)
                    EndTextCommandSetBlipName(blip)
                    SetBlipAsShortRange(blip, true)
                    blips[#blips + 1] = blip
                end
                zones[#zones + 1] = PolyZone:Create({ table.unpack(warehouse.zone.vectors) }, { name = warehouse.zone.name, minZ = warehouse.zone.minZ, maxZ = warehouse.zone.maxZ })
                zonecombos[id] = ComboZone:Create(zones, { name = "ZonesCombo", debugPoly = config.Debug })
                zonecombos[id]:onPlayerInOut(function(isPointInside)
                    if isPointInside then isInZone = true else isInZone = false end
                end)
            end
        end
    end
end

function CreateWarehouseBoxZone(warehouse)
    if GetResourceState("qb-target") ~= 'missing' then
        if warehouse.stash ~= nil then
            exports['qb-target']:AddBoxZone('jobstash'..warehouse.id, vector3(warehouse.stash.coords.x, warehouse.stash.coords.y, warehouse.stash.coords.z), 1.5, 1.5, {
                name = 'jobstash'..warehouse.id,
                heading = 0.0,
                minZ = warehouse.stash.coords.z - 2,
                maxZ = warehouse.stash.coords.z + 2,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = "client",
                        event = "",
                        icon = 'fa fa-hand',
                        label = 'Open Stash',
                        action = function(entity)
                            QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:openStash", function(result)
                            end, warehouse.stash.name, warehouse.stash.label)
                        end,
                        canInteract = function(entity, distance, data)
                            local result = HasKeyWithLabId(warehouse)
                            if not result.key then return false end
                            return true
                        end,
                    }
                },
                distance = 1.5
            })
        end
        if warehouse.process ~= nil then
            if warehouse.process.prepare ~= nil then
                exports['qb-target']:AddBoxZone('processprepare'..warehouse.id, vector3(warehouse.process.prepare.coords.x, warehouse.process.prepare.coords.y, warehouse.process.prepare.coords.z), 1.5, 1.5, {
                    name = 'processprepare'..warehouse.id,
                    heading = 0.0,
                    minZ = warehouse.process.prepare.coords.z - 2,
                    maxZ = warehouse.process.prepare.coords.z + 2,
                    debugPoly = false,
                }, {
                    options = {
                        {
                            type = "client",
                            event = "",
                            icon = 'fa fa-hand',
                            label = warehouse.process.prepare.label,
                            action = function(entity)
                                PrepareProcess(warehouse.id)
                            end,
                            canInteract = function(entity, distance, data)
                                if isBizy then return false end
                                local result = HasKeyWithLabId(warehouse)
                                if not result.key then return false end

                                if warehouse.process.prepare.needItems ~= nil then
                                    local hasItem = true
                                    for k, item in pairs(warehouse.process.prepare.needItems) do
                                        if not HasItem(item.name) then
                                            hasItem = false
                                            break
                                        end
                                    end
                                    if not hasItem then return false end
                                end
                                return true
                            end
                        }
                    },
                    distance = 1.5
                })
            end
            if warehouse.process.finish ~= nil then
                exports['qb-target']:AddBoxZone('processfinish'..warehouse.id, vector3(warehouse.process.finish.coords.x, warehouse.process.finish.coords.y, warehouse.process.finish.coords.z), 1.5, 1.5, {
                    name = 'processfinish'..warehouse.id,
                    heading = 0.0,
                    minZ = warehouse.process.finish.coords.z - 2,
                    maxZ = warehouse.process.finish.coords.z + 2,
                    debugPoly = false,
                }, {
                    options = {
                        {
                            type = "client",
                            event = "",
                            icon = 'fa fa-hand',
                            label = warehouse.process.finish.label,
                            action = function(entity)
                                FinishProcess(warehouse.id)
                            end,
                            canInteract = function(entity, distance, data)
                                if isBizy then return false end
                                local result = HasKeyWithLabId(warehouse)
                                if not result.key then return false end
                                if warehouse.process.finish.needItems ~= nil then
                                    local hasItem = true
                                    for k, item in pairs(warehouse.process.finish.needItems) do
                                        if not HasItem(item.name) then
                                            hasItem = false
                                            break
                                        end
                                    end
                                    if not hasItem then return false end
                                end
                                return true
                            end
                        }
                    },
                    distance = 1.5
                })
            end
            if warehouse.process.rolljoint ~= nil then
                exports['qb-target']:AddBoxZone('rolljoints'..warehouse.id, vector3(warehouse.process.rolljoint.coords.x, warehouse.process.rolljoint.coords.y, warehouse.process.rolljoint.coords.z), 1.5, 1.5, {
                    name = 'rolljoints'..warehouse.id,
                    heading = 0.0,
                    minZ = warehouse.process.rolljoint.coords.z - 2,
                    maxZ = warehouse.process.rolljoint.coords.z + 2,
                    debugPoly = false,
                }, {
                    options = {
                        {
                            type = "client",
                            event = "",
                            icon = 'fa fa-hand',
                            label = warehouse.process.rolljoint.label,
                            action = function(entity)
                                RollJointProcess(warehouse.id)
                            end,
                            canInteract = function(entity, distance, data)
                                if isBizy then return false end
                                local result = HasKeyWithLabId(warehouse)
                                if not result.key then return false end
                                if warehouse.process.rolljoint.needItems ~= nil then
                                    local hasItem = true
                                    for k, item in pairs(warehouse.process.rolljoint.needItems) do
                                        if not HasItem(item.name) then
                                            hasItem = false
                                            break
                                        end
                                    end
                                    if not hasItem then return false end
                                end
                                return true
                            end
                        }
                    },
                    distance = 1.5
                })
            end
        end
        if warehouse.computer ~= nil then
            exports['qb-target']:AddBoxZone("duty_computer"..warehouse.id, warehouse.computer.coords, 1.5, 1.5, {
                name = "duty_computer"..warehouse.id,
                heading = 0.0,
                minZ = warehouse.computer.coords.z - 1.0,
                maxZ = warehouse.computer.coords.z + 1.0,
                debugPoly = config.Debug,
            }, {
                options = {
                    {
                        type = "server",
                        event = "",
                        name = "payslip2",
                        icon = "fas fa-car",
                        label = "Lab Menu",
                        args = {id = warehouse.id},
                        action = function(entity)
                            LabOwnerMenu(warehouse.id)
                        end,
                        canInteract = function(entity, distance, data)
                            local result = HasKeyWithLabId(warehouse)
                            if not result.key or not result.owner then return false end
                            return true
                        end
                    }, {
                        name = "start_loading",
                        type = "client",
                        event = "",
                        icon = "fas fa-car",
                        label = Lang:t('info.start_loading'),
                        action = function(entity)
                            SelectTypeRouteMenu(warehouse)
                        end,
                        canInteract = function(entity, distance, data)
                            local result = HasKeyWithLabId(warehouse)
                            if not result.key then return false end
                            if isJobEnable then return false end
                            if currentVan ~= nil then return false end
                            return true
                        end
                    }, {
                        type = "client",
                        event = "",
                        name = "payslip",
                        icon = "fas fa-car",
                        label = Lang:t('info.payslip'),
                        action = function(entity)
                            QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:submitPayslip", function(result)
                                if result.status then
                                    Notify(Lang:t('info.get_paid'), 'success', 5000)
                                end
                            end, warehouse.id)
                        end,
                        canInteract = function(entity, distance, data)
                            local result = HasKeyWithLabId(warehouse)
                            if not result.key or not result.owner then return false end
                            return true
                        end
                    }
                },
                distance = 2.5
            })
        end
    elseif GetResourceState("ox_target") ~= 'missing' then
        if warehouse.stash ~= nil then
            exports.ox_target:addBoxZone({
                name = 'jobstash'..warehouse.id,
                coords = vector3(warehouse.stash.coords.x, warehouse.stash.coords.y, warehouse.stash.coords.z - 0.5),
                size = vector3(1.5, 1.5, 1.5),
                rotation = 0.0,
                debug = config.Debug,
                options = {
                    {
                        type = 'server',
                        event = '',
                        icon = 'fa fa-hand',
                        label = warehouse.stash.name,
                        onSelect = function(data)
                            QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:openStash", function(result)
                            end, warehouse.stash.name, warehouse.stash.label)
                        end,
                        canInteract = function(entity, distance, data)
                            local result = HasKeyWithLabId(warehouse)
                            if not result.key then return false end
                            return true
                        end,
                        distance = 2.5,
                    },
                },
            })
        end
        if warehouse.process ~= nil then
            if warehouse.process.prepare ~= nil then
                exports.ox_target:addBoxZone({
                    name = "prepare"..warehouse.id,
                    coords = vec3(warehouse.process.prepare.coords.x, warehouse.process.prepare.coords.y, warehouse.process.prepare.coords.z - 0.5),
                    size = vec3(1.5, 1.5, 1.5),
                    rotation = 0.0,
                    debug = config.Debug,
                    options = {
                        {
                            icon = 'fa fa-hand',
                            label = warehouse.process.prepare.label,
                            onSelect = function(entity)
                                PrepareProcess(warehouse.id)
                            end,
                            canInteract = function(entity, distance, data)
                                if isBizy then return false end
                                local result = HasKeyWithLabId(warehouse)
                                if not result.key then return false end
                                if warehouse.process.prepare.needItems ~= nil then
                                    local hasItem = true
                                    for k, item in pairs(warehouse.process.prepare.needItems) do
                                        if not HasItem(item.name, item.amount) then
                                            hasItem = false
                                            break
                                        end
                                    end
                                    if not hasItem then return false end
                                end
                                return true
                            end,
                            distance = 1.5
                        }
                    }
                })
            end
            if warehouse.process.finish ~= nil then
                exports.ox_target:addBoxZone({
                    name = "finish"..warehouse.id,
                    coords = vec3(warehouse.process.finish.coords.x, warehouse.process.finish.coords.y, warehouse.process.finish.coords.z - 0.5),
                    size = vec3(1.5, 1.5, 1.5),
                    rotation = 0.0,
                    debug = config.Debug,
                    options = {
                        {
                            icon = 'fa fa-hand',
                            label = warehouse.process.finish.label,
                            onSelect = function(entity)
                                FinishProcess(warehouse.id)
                            end,
                            canInteract = function(entity, distance, data)
                                if isBizy then return false end
                                local result = HasKeyWithLabId(warehouse)
                                if not result.key then return false end
                                if warehouse.process.finish.needItems ~= nil then
                                    local hasItem = true
                                    for k, item in pairs(warehouse.process.finish.needItems) do
                                        if not HasItem(item.name, item.amount) then
                                            hasItem = false
                                            break
                                        end
                                    end
                                    if not hasItem then return false end
                                end
                                
                                return true
                            end,
                            distance = 2.0
                        }
                    }
                })
            end
            if warehouse.process.rolljoint ~= nil then
                exports.ox_target:addBoxZone({
                    name = "rolljoint"..warehouse.id,
                    coords = vec3(warehouse.process.rolljoint.coords.x, warehouse.process.rolljoint.coords.y, warehouse.process.rolljoint.coords.z - 0.5),
                    size = vec3(1.5, 1.5, 1.5),
                    rotation = 0.0,
                    debug = config.Debug,
                    options = {
                        {
                            icon = 'fa fa-hand',
                            label = warehouse.process.rolljoint.label,
                            onSelect = function(entity)
                                RollJointProcess(warehouse.id)
                            end,
                            canInteract = function(entity, distance, data)
                                if isBizy then return false end
                                local result = HasKeyWithLabId(warehouse)
                                if not result.key then return false end
                                if warehouse.process.rolljoint.needItems ~= nil then
                                    local hasItem = true
                                    for k, item in pairs(warehouse.process.rolljoint.needItems) do
                                        if not HasItem(item.name, item.amount) then
                                            hasItem = false
                                            break
                                        end
                                    end
                                    if not hasItem then return false end
                                end
                                return true
                            end,
                            distance = 2.0
                        }
                    }
                })
            end
        end
        if warehouse.computer ~= nil then
            exports.ox_target:addBoxZone({
                name = "warehouse"..warehouse.id,
                coords = vec3(warehouse.computer.coords.x, warehouse.computer.coords.y, warehouse.computer.coords.z - 0.5),
                size = vec3(1.5, 1.5, 1.5),
                rotation = 0.0,
                debug = config.Debug,
                options = {
                    {
                        type = "server",
                        event = "",
                        name = "payslip2",
                        icon = "fas fa-car",
                        label = "Lab Menu",
                        args = {id = warehouse.id},
                        onSelect = function(entity)
                            LabOwnerMenu(warehouse.id)
                        end,
                        canInteract = function(entity, distance, data)
                            local result = HasKeyWithLabId(warehouse)
                            if not result.key or not result.owner then return false end
                            return true
                        end
                    }, {
                        name = "start_loading",
                        icon = "fas fa-car",
                        label = Lang:t('info.start_loading'),
                        onSelect = function(data)
                            SelectTypeRouteMenu(warehouse)
                        end,
                        canInteract = function(entity, distance, data)
                            if isJobEnable then return false end
                            if currentVan ~= nil then return false end
                            local result = HasKeyWithLabId(warehouse)
                            if not result.key then return false end
                            return true
                        end,
                        distance = 2.5,
                    }, {
                        name = "payslip",
                        icon = "fas fa-car",
                        label = Lang:t('info.payslip'),
                        onSelect = function(data)
                            QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:getMoney", function(result)
                                if result.status then
                                    Notify(Lang:t('info.get_paid'), 'success', 5000)
                                end
                            end, config.WarehouseID)
                        end,
                        canInteract = function(entity, distance, data)
                            local result = HasKeyWithLabId(warehouse)
                            if not result.key or not result.owner then return false end
                            return true
                        end,
                        distance = 2.5,
                    },
                }
            })
        end
    end
end