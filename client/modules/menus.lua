function DeleteDeliveryMenu(data)
    local options = {}
    options[#options + 1] = {
        title = Lang:t('info.go_to_location'),
        description = "",
        arrow = true,
        onSelect = function()
            SetEntityCoords(PlayerPedId(), data.coords.x, data.coords.y, data.coords.z, false, false, false, true)
        end
    }
    options[#options + 1] = {
        id = data.distance,
        title = Lang:t('info.delete_route_id', { id = data.id, distance = data.distance }),
        description = "",
        arrow = true,
        onSelect = function()
            QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:deleteRoute", function(_data)
                if _data.status then
                    Notify(_data.message)
                    SelectRouteTypeMenu()
                elseif not _data.status then
                    Notify(_data.error)
                    SelectRouteTypeMenu()
                end
            end, data.id)
        end
    }
    options[#options + 1] = { title = Lang:t('info.back'), description = '', arrow = false, onSelect = function() SelectRouteTypeMenu() end }
    lib.registerContext({ id = 'DeleteDeliveryMenu', title = "Delivery Action Menu", options = options })
    lib.showContext('DeleteDeliveryMenu')
end

function DeleteDeliveryTypeMenu(type)
    local options = {}
    local data = { type = type, coords = GetEntityCoords(PlayerPedId()), heading = GetEntityHeading(PlayerPedId()) }
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:getClosestRoutes", function(data)
        if data.status then
            if #data.data >= 1 then
                for k, v in pairs(data.data) do
                    if v.type == type then
                        options[#options + 1] = {
                            id = v.distance,
                            title = Lang:t('info.delete_route_id', { id = v.id, distance = v.distance }),
                            description = "",
                            arrow = true,
                            onSelect = function()
                                DeleteDeliveryMenu(v)
                            end
                        }
                    end
                end
                table.sort(options, function(a, b) return a.id < b.id end)
                options[#options + 1] = { title = Lang:t('info.back'), description = '', arrow = false, onSelect = function() SelectRouteTypeMenu() end }
                lib.registerContext({ id = 'DeleteDeliveryTypeMenu', title = Lang:t('info.delete_delivery_point'), options = options })
                lib.showContext('DeleteDeliveryTypeMenu')
            elseif #data.data <= 0 then
                Notify(Lang:t('info.no_route_founded', { type = type }))
                SelectRouteTypeMenu()
            end
        elseif not data.status then
            Notify(Lang:t('info.no_route_founded', { type = type }))
            SelectRouteTypeMenu()
        end
    end, data)
end

function SelectRouteTypeMenu()
    local options = {}
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:countRouteTypes", function(data)
        if data ~= nil then
            for k, v in pairs(config.RouteTypes) do
                if data[v:lower()] then
                    options[#options + 1] = {
                        title = FirstToUpper(v) .. " " .. Lang:t('info.routes'),
                        description = "Total "..data[v:lower()].." delivery routes exsist.",
                        arrow = true,
                        onSelect = function()
                            DeleteDeliveryTypeMenu(v)
                            if devMode then
                                DeleteDevBlips()
                                LoadAllBlips()
                            end
                        end
                    }
                end
            end
            options[#options + 1] = { title = Lang:t('info.back'), description = '', arrow = false, onSelect = function() AdminRouteMenu() end }
            lib.registerContext({ id = 'SelectRouteType', title = Lang:t('info.select_route_type'), options = options })
            lib.showContext('SelectRouteType')
        end
    end)
end

function CreateDeliveryMenu()
    local options = {}
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:countRouteTypes", function(data)
        if data ~= nil then
            for k, v in pairs(config.RouteTypes) do
                if data[v:lower()] then
                    options[#options + 1] = {
                        title = Lang:t('info.create_deliverie', { type = FirstToUpper(v) }),
                        description = "Total "..data[v:lower()].." delivery routes exsist.",
                        arrow = true,
                        onSelect = function()
                            local data = { type = v, coords = GetEntityCoords(PlayerPedId()), heading = GetEntityHeading(PlayerPedId()) }
                            QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:createRoute", function(data)
                                if data.status then
                                    Notify(data.message)
                                elseif not data.status then
                                    Notify(data.error)
                                end
                                if devMode then
                                    DeleteDevBlips()
                                    LoadAllBlips()
                                end
                            end, data)
                        end
                    }
                end
            end
            options[#options + 1] = { title = Lang:t('info.back'), description = '', arrow = false, onSelect = function() AdminRouteMenu() end }
            lib.registerContext({ id = 'CreateDeliveryMenu', title = Lang:t('info.create_delivery_point'), options = options })
            lib.showContext('CreateDeliveryMenu')
        end
    end)
end

function DeliveriesInfoMenu()
    local options = {}
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:countRouteTypes", function(data)
        if data ~= nil then
            options[#options + 1] = {
                title = 'Total deliveries info',
                description = "There are total "..data['total'].." deliveries",
                arrow = false,
                onSelect = function()
                    AdminDeliveryMenu()
                end
            }
            for k, v in pairs(config.RouteTypes) do
                if data[v:lower()] then
                    options[#options + 1] = {
                        title = FirstToUpper(v).." delivery info",
                        description = "Total "..data[v:lower()].." routes.",
                        arrow = false,
                        onSelect = function()
                            AdminDeliveryMenu()
                        end
                    }
                end
            end
            options[#options + 1] = { title = Lang:t('info.back'), description = '', arrow = false, onSelect = function() AdminDeliveryMenu() end }
            lib.registerContext({ id = 'DeliveriesInfoMenu', title = 'Deliveries Info Menu', options = options })
            lib.showContext('DeliveriesInfoMenu')
        end
    end)
end

function SelectVehicleMenu(warehouse)
    local options = {}
    local name = "unknow"
    local brand = "unknow"
    local models = config.DeliveryVehicleModels
    if config.Storeage ~= nil then
        for model, data in pairs(config.Storeage) do
            if models[model:lower()] then
                if data.deliveryType == config.deliveryType then
                    local vehicle = GetVehicleNameFromModel(model)
                    if vehicle then
                        if vehicle.brand ~= nil then brand = FirstToUpper(vehicle.brand) end
                        if vehicle.name ~= nil then name = FirstToUpper(vehicle.name) end
                    end
                    if band == nil then brand = "" end
                    if name ~= "unknow" then
                        local image = exports['mh-vehicleimages']:GetImage(vehicle.name)
                        options[#options + 1] = {
                            id = config.Storeage[model:lower()].maxCapacity,
                            icon = image,
                            title = FirstToUpper(model) .. " " .. brand,
                            description = config.Storeage[model:lower()].discription,
                            arrow = false,
                            onSelect = function()
                                config.Storeage[model:lower()].deliverItem = warehouse.needItem
                                if not SpawnClear(warehouse.vehicle.spawn.coords, 5.0) then
                                    return Notify(Lang:t('info.area_is_obstructed'), 'error', 5000)
                                else
                                    local plate = CreateJobVehiclePlate()
                                    config.TrunkInventory = Trim("trunk-"..plate)
                                    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:startJob", function(data)
                                        if data.status then
                                            currentDelivery = 0
                                            config.DeliverVan = model:lower()
                                            SpawnVan(config.DeliverVan, config.DeliveryVehicleSpawn, config.DeliveryVehicleHeading, plate)
                                            Wait(10)
                                            if config.UseAutoLoadTrunk then
                                                SetRandomRoutes()
                                                AutoLoadTrunk()
                                                CreateNewRoute()
                                            elseif not config.UseAutoLoadTrunk then
                                                SetRandomRoutes()
                                                ToggleJob(true)
                                            end
                                        end
                                    end, config.TrunkInventory)
                                end
                            end
                        }
                    end
                end
            end
        end
        table.sort(options, function(a, b) return a.id < b.id end)
        options[#options + 1] = { title = Lang:t('info.back'), description = '', arrow = false, onSelect = function() SelectTypeRouteMenu() end }
        lib.registerContext({id = 'selectVehicleMenu', title = Lang:t('info.select_vehicle_menu'), options = options})
        lib.showContext('selectVehicleMenu')
    end
end

function SelectTypeRouteMenu(warehouse) -- used in target when starting a job
    local options = {}
    for k, v in pairs(config.RouteTypes) do
        options[#options + 1] = {
            title = FirstToUpper(v) .. " " .. Lang:t('info.routes'),
            description = "",
            arrow = true,
            onSelect = function()
                QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:LabHasItem", function(result)
                    if result.status then
                        config.deliveryType = v
                        SelectVehicleMenu(warehouse)
                    elseif not result.status then
                        Notify("The lab has no "..config.Labs[warehouse.id].needItem.." in stock", 'error', 5000)
                    end
                end, config.Labs[warehouse.id].needItem)
            end
        }
    end
    options[#options + 1] = { title = Lang:t('info.back'), description = '', arrow = false, onSelect = function() AdminDeliveryMenu() end }
    lib.registerContext({ id = 'SelectTypeRoute', title = Lang:t('info.select_route_type'), options = options })
    lib.showContext('SelectTypeRoute')
end

function BlipsOptionMenu()
    local options = {}
    options[#options + 1] = {
        title = "Enable Blips",
        description = "Enable",
        arrow = false,
        onSelect = function()
            devMode = true
            LoadAllBlips()
        end
    }
    options[#options + 1] = {
        title = "Disable Blips",
        description = "Disable",
        arrow = false,
        onSelect = function()
            devMode = false
            DeleteDevBlips()
        end
    }
    options[#options + 1] = { title = Lang:t('info.back'), description = '', arrow = false, onSelect = function() AdminDeliveryMenu() end }
    lib.registerContext({ id = 'BlipsOptionMenu', title = "Blips Option Menu", options = options })
    lib.showContext('BlipsOptionMenu')
end

function BlipsTypeDisplayMenu()
    local options = {}
    if not devMode then
        options[#options + 1] = {
            title = "Show drugs blips",
            description = "Display all drugs deliverie blips on the map",
            arrow = false,
            onSelect = function()
                devMode = true
                LoadAllBlips('drugs')
                BlipsTypeDisplayMenu()
            end
        }
    else
        options[#options + 1] = {
            title = "Disable Blips",
            description = "disable blips on the map",
            arrow = false,
            onSelect = function()
                devMode = false
                DeleteDevBlips()
                BlipsTypeDisplayMenu()
            end
        }
    end
    options[#options + 1] = { title = Lang:t('info.back'), description = '', arrow = false, onSelect = function() AdminDeliveryMenu() end }
    lib.registerContext({ id = 'BlipsTypeDisplayMenu', title = "Blips Type Display Menu", options = options })
    lib.showContext('BlipsTypeDisplayMenu')
end

function AdminRouteMenu()
    local options = {}
    options[#options + 1] = {
        title = "Create Route",
        description = "",
        arrow = false,
        onSelect = function()
            CreateDeliveryMenu()
        end
    }
    options[#options + 1] = {
        title = "Delete Route",
        description = "",
        arrow = false,
        onSelect = function()
            SelectRouteTypeMenu()
        end
    }
    options[#options + 1] = { title = Lang:t('info.back'), description = '', arrow = false, onSelect = function() AdminDeliveryMenu() end }
    lib.registerContext({ id = 'AdminRouteMenu', title = "Delivery Admin Menu", options = options })
    lib.showContext('AdminRouteMenu')
end

function BuyLapMenu(warehouse)
    local options = {}
    if warehouse ~= nil then
        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:isOwner", function(result)
            if result.status then
                options[#options + 1] = {
                    title = "Buy a new "..warehouse.labOwnerKeyItem .." for "..config.MoneySign.."50",
                    description = "This if you lose your key",
                    arrow = false,
                    onSelect = function()
                        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:buyNewLabkey", function(data)
                            if data.status == true then -- buy key
                                Notify(data.message, "success", 10000)
                            elseif data.status == false then -- error
                                Notify(data.message, "error", 10000)
                            end
                        end, warehouse.id)
                    end
                }
                options[#options + 1] = { title = Lang:t('info.close'), description = '', arrow = false, onSelect = function() end }
                lib.registerContext({ id = 'BuyLapMenu', title = "Key shop", options = options })
                lib.showContext('BuyLapMenu')
            elseif not result.status then
                options[#options + 1] = {
                    title = "Buy "..warehouse.labOwnerKeyItem .." for "..config.MoneySign..""..warehouse.shop.price,
                    description = "",
                    arrow = false,
                    onSelect = function()
                        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:buyLabkey", function(data)
                            if data.status == true and data.hasOwner == false then -- buy key
                                Notify(data.message, "success", 10000)
                            elseif data.status == false and data.hasOwner == true then -- has owner
                                Notify(data.message, "error", 10000)
                            elseif data.status == false and data.hasOwner == false then -- error
                                Notify(data.message, "error", 10000)
                            end
                        end, warehouse.id)
                    end
                }
                options[#options + 1] = { title = Lang:t('info.close'), description = '', arrow = false, onSelect = function() end }
                lib.registerContext({ id = 'BuyLapMenu', title = "Key shop", options = options })
                lib.showContext('BuyLapMenu')
            end
        end, warehouse.id)
    end
end

function AdminDeliveryMenu()
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:countRouteTypes", function(data)
        if data ~= nil then
            local options = {}
            options[#options + 1] = {
                title = "Routes Options",
                description = "",
                arrow = false,
                onSelect = function()
                    AdminRouteMenu()
                end
            }
            options[#options + 1] = {
                title = "Blip Options",
                description = "",
                arrow = false,
                onSelect = function()
                    BlipsTypeDisplayMenu()
                end
            }
            options[#options + 1] = {
                title = "Deliveries Info",
                description = "",
                arrow = false,
                onSelect = function()
                    DeliveriesInfoMenu()
                end
            }
            options[#options + 1] = { title = Lang:t('info.close'), description = '', arrow = false, onSelect = function() end }
            lib.registerContext({ id = 'AdminDeliveryMenu', title = 'Admin Delivery | Routes('..data['total']..')', options = options })
            lib.showContext('AdminDeliveryMenu')
        end
    end)
end

-------------------------
function CompanyMoneyMenu(id)
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:GetMoneyAmount", function(companyCash)
        if companyCash == nil or companyCash < 0 then companyCash = 0 end
        local options = {}
        options[#options + 1] = {
            title = 'Current Money',
            icon = config.Fontawesome.boss,
            description = 'Current money' .. ' ' .. config.MoneySign .. companyCash,
            arrow = false,
            onSelect = function()
                CompanyMoneyMenu(id)
            end
        }
        options[#options + 1] = {
            title = 'Add Money',
            icon = config.Fontawesome.boss,
            description = 'Add money to account',
            arrow = false,
            onSelect = function()
                local input = lib.inputDialog('Add money', {{ type = 'number', label = 'Add Money', description = 'Add money', required = true, icon = 'hashtag' }})
                if not input then return end
                QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:AddMoney", function(result)
                    if not result.status then Notify(result.message, "error", 5000) end
                end, {id = id, amount = tonumber(input[1])})
            end
        }
        options[#options + 1] = {
            title = 'Take Money',
            icon = config.Fontawesome.boss,
            description = 'Take money from account',
            arrow = false,
            onSelect = function()
                local input = lib.inputDialog('Take Money', {{ type = 'number', label = 'Take Money', description = 'Take money', required = true, icon = 'hashtag' }})
                if not input then return end
                QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:TakeMoney", function(result)
                    if not result.status then Notify(result.message, "error", 5000) end
                end, {id = id, amount = tonumber(input[1])})
            end
        }
        options[#options + 1] = {
            title = Lang:t('info.back'),
            icon = config.Fontawesome.goback,
            description = '',
            arrow = false,
            onSelect = function()
                LabOwnerMenu(id)
            end
        }
        lib.registerContext({ id = 'labmoneyMenu', title = 'Lab Money Menu', icon = config.Fontawesome.garage, options = options })
        lib.showContext('labmoneyMenu')
    end, id)
end

function BuyKeysMenu(id)
    local options = {}
    options[#options + 1] = {
        title = 'Keys Menu',
        icon = config.Fontawesome.boss,
        description = 'Buy keys for your employees',
        arrow = false,
        onSelect = function()
            local input = lib.inputDialog('Buy Empoyee keys', {{ type = 'number', label = 'Enter number', description = 'How many keys do you want to buy?', required = true, icon = 'hashtag' }})
            if not input then return end
            QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:buyEmpoyeeKeys", function(data)
                if data.status == true then -- buy key
                    Notify(data.message, "success", 10000)
                elseif data.status == false then -- error
                    Notify(data.message, "error", 10000)
                end
            end, id, tonumber(input[1]))
        end
    }
    
    options[#options + 1] = {
        title = Lang:t('info.back'),
        icon = config.Fontawesome.goback,
        description = '',
        arrow = false,
        onSelect = function()
            LabOwnerMenu(id)
        end
    }
    lib.registerContext({ id = 'BuyKeysMenu', title = 'Keys Menu', icon = config.Fontawesome.garage, options = options })
    lib.showContext('BuyKeysMenu')
end

function ShowEmployeesMenu(id)
    local options = {}
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:GetEmployees", function(employees)
        if employees ~= nil then
            options[#options + 1] = {
                title = "Total "..#employees.." employees",
                icon = config.Fontawesome.goback,
                description = '',
                arrow = false,
                onSelect = function()
                    EmployeessMenu(id)
                end
            }
            for k, employee in pairs(employees) do
                options[#options + 1] = {
                    title = 'Employee '..FirstToUpper(employee.firstname) ..' '..FirstToUpper(employee.lastname),
                    icon = config.Fontawesome.boss,
                    description = 'Citizen ID:'..employee.citizenid,
                    arrow = false,
                    onSelect = function()
                        EmployeessMenu(id)
                    end
                }
            end
            options[#options + 1] = {
                title = Lang:t('info.back'),
                icon = config.Fontawesome.goback,
                description = '',
                arrow = false,
                onSelect = function()
                    EmployeessMenu(id)
                end
            }
            lib.registerContext({ id = 'RemoveEmployeeMenu', title = 'Add Employee Menu', icon = config.Fontawesome.garage, options = options })
            lib.showContext('RemoveEmployeeMenu')
        end
    end, {labid = id})
end

function RemoveEmployeeMenu(id)
    local options = {}
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:GetEmployees", function(employees)
        if employees ~= nil then
            for k, employee in pairs(employees) do
                options[#options + 1] = {
                    title = 'Remove ' .. FirstToUpper(employee.firstname) ..' '..FirstToUpper(employee.lastname),
                    icon = config.Fontawesome.boss,
                    description = 'Citizen ID:'..employee.citizenid..')',
                    arrow = false,
                    onSelect = function()
                        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:RemoveEmployee", function(result)
                            if result.status then
                                Notify(result.message, "success", 5000)
                            else
                                Notify(result.message, "error", 5000)
                            end
                            EmployeessMenu(id)
                        end, { labid = id, citizenid = employee.citizenid})
                    end
                }
            end
            options[#options + 1] = {
                title = Lang:t('info.back'),
                icon = config.Fontawesome.goback,
                description = '',
                arrow = false,
                onSelect = function()
                    EmployeessMenu(id)
                end
            }
            lib.registerContext({ id = 'RemoveEmployeeMenu', title = 'Add Employee Menu', icon = config.Fontawesome.garage, options = options })
            lib.showContext('RemoveEmployeeMenu')
        end
    end, {labid = id})
end

function AddEmployeeMenu(id)
    local options = {}
    local closestPlayers = GetClosestPlayers()
    if closestPlayers ~= -1 then
        for key, target in pairs(closestPlayers) do
            options[#options + 1] = {
                title = 'Add Player ' ..GetPlayerName(target),
                icon = config.Fontawesome.boss,
                description = '',
                arrow = false,
                onSelect = function()
                    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:AddEmployee", function(result)
                        if result.status then
                            Notify(result.message, "success", 5000)
                        else
                            Notify(result.message, "errir", 5000)
                        end
                        EmployeessMenu(id)
                    end, {labid = id, targetId = GetPlayerServerId(target) })
                end
            }
        end
        options[#options + 1] = {
            title = Lang:t('info.back'),
            icon = config.Fontawesome.goback,
            description = '',
            arrow = false,
            onSelect = function()
                EmployeessMenu(id)
            end
        }
        lib.registerContext({ id = 'AddEmployeessMenu', title = 'Add Employee Menu', icon = config.Fontawesome.garage, options = options })
        lib.showContext('AddEmployeessMenu')        
    else
        Notify("There are no player neerby...")
    end
end

function EmployeessMenu(id)
    local options = {}

    options[#options + 1] = {
        title = 'Show Employees',
        icon = config.Fontawesome.boss,
        description = '',
        arrow = false,
        onSelect = function()
            ShowEmployeesMenu(id)
        end
    }

    options[#options + 1] = {
        title = 'Add Employees',
        icon = config.Fontawesome.boss,
        description = '',
        arrow = false,
        onSelect = function()
            AddEmployeeMenu(id)
        end
    }

    options[#options + 1] = {
        title = 'Remove Employees',
        icon = config.Fontawesome.boss,
        description = '',
        arrow = false,
        onSelect = function()
            RemoveEmployeeMenu(id)
        end
    }

    options[#options + 1] = {
        title = Lang:t('info.back'),
        icon = config.Fontawesome.goback,
        description = '',
        arrow = false,
        onSelect = function()
            LabOwnerMenu(id)
        end
    }
    lib.registerContext({ id = 'AddEmployeessMenu', title = 'Add Employee Menu', icon = config.Fontawesome.garage, options = options })
    lib.showContext('AddEmployeessMenu')
end

function LabOwnerMenu(id)
    local options = {}

    options[#options + 1] = {
        title = 'Money Account',
        icon = config.Fontawesome.boss,
        description = '',
        arrow = false,
        onSelect = function()
            CompanyMoneyMenu(id)
        end
    }

    options[#options + 1] = {
        title = 'Employees Menu',
        icon = config.Fontawesome.boss,
        description = '',
        arrow = false,
        onSelect = function()
            EmployeessMenu(id)
        end
    }

    options[#options + 1] = {
        title = 'Keys Menu',
        icon = config.Fontawesome.boss,
        description = '',
        arrow = false,
        onSelect = function()
            BuyKeysMenu(id)
        end
    }

    options[#options + 1] = {
        title = 'Open Shop Stash',
        icon = config.Fontawesome.boss,
        description = '',
        arrow = false,
        onSelect = function()
            if config.Labs[id] then
                QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:openStash", function(result)
                end, config.Labs[id].ownerstash.name, config.Labs[id].ownerstash.label)
            end
        end
    }

    options[#options + 1] = {
        title = Lang:t('info.close'),
        icon = config.Fontawesome.goback,
        description = '',
        arrow = false,
        onSelect = function()
        end
    }
    lib.registerContext({ id = 'LabOwnerMenu', title = 'Lab Menu', icon = config.Fontawesome.garage, options = options })
    lib.showContext('LabOwnerMenu')
end

-------------------------
function BuyDrugsMenu(dealer)
    if config.Labs[dealer.labid] then
        local options = {}
        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:GetInventory", function(inventory)
            if inventory ~= nil then
                for _, inventoryItem in pairs(inventory.items) do
                    for _, dealerItem in pairs(dealer.items) do
                        if inventoryItem.name == dealerItem.name and inventoryItem.amount >= 1  then
                            local price = tonumber(config.ItemPrice[inventoryItem.name:lower()].price)
                            local tmpItem = inventoryItem.name:gsub('_', ' ')
                            local more = ""
                            if inventoryItem.amount > 1 then more = "'s" end
                            options[#options + 1] = {
                                title = "i have "..inventoryItem.amount .." "..tmpItem .. more,
                                icon = 'nui://'..config.InventoryImagesFolder..'/' .. inventoryItem.name .. ".png",
                                description = 'Price '..config.MoneySign..price .. " per piece\nClick here to buy",
                                arrow = true,
                                onSelect = function()
                                    local input = lib.inputDialog('Buy '..FirstToUpper(tmpItem)..'', {{ type = 'number', label = 'Enter number', description = 'How many items do you want to buy?', required = true, icon = 'hashtag' }})
                                    if not input then return end
                                    local data = {ownerstash = lab.ownerstash.name, item = inventoryItem.name, amount = tonumber(input[1]), price = item.price}
                                    TriggerServerEvent('mh-owneddrugslabs:server:buyItems', data)
                                end
                            }
                        end
                    end
                end
                options[#options + 1] = {
                    title = Lang:t('info.close'),
                    icon = config.Fontawesome.goback,
                    description = '',
                    arrow = false,
                    onSelect = function()
                    end
                }
                lib.registerContext({ id = 'BuyDrugsMenu', title = 'Buy Drugs Menu', icon = config.Fontawesome.garage, options = options })
                lib.showContext('BuyDrugsMenu')
            end
        end, dealer.inventory)
    end
end

function ShopMenu(data)
    local options = {}
    local lab = config.Labs[data.id]
    if lab ~= nil and lab.id == data.id and lab.shop.items ~= nil then
        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:GetInventory", function(inventory)
            if inventory ~= nil then
                for _, item in pairs(lab.shop.items) do
                    for _, v in pairs(inventory.items) do
                        if v.name == item.name then
                            local amount = v.amount or v.count
                            local tmpItem = v.name:gsub('_', ' ')
                            options[#options + 1] = {
                                title = FirstToUpper(tmpItem).. " (Price p/p "..config.MoneySign..item.price..")",
                                icon = 'nui://'..config.InventoryImagesFolder..'/' .. v.name .. ".png",
                                description = "We have "..amount.." in storage.",
                                arrow = true,
                                onSelect = function()
                                    local input = lib.inputDialog('Buy '..FirstToUpper(tmpItem)..'', {{ type = 'number', label = 'Enter number', description = 'How many items do you want to buy?', required = true, icon = 'hashtag' }})
                                    if not input then return end
                                    local data = {ownerstash = lab.ownerstash.name, item = v.name, amount = tonumber(input[1]), price = item.price}
                                    TriggerServerEvent('mh-owneddrugslabs:server:buyItems', data)
                                end
                            }
                        end
                    end
                end

                options[#options + 1] = {
                    title = Lang:t('info.close'),
                    icon = config.Fontawesome.goback,
                    description = '',
                    arrow = false,
                    onSelect = function()
                    end
                }
                lib.registerContext({ id = 'LabOwnerMenu', title = 'Shop Menu', icon = config.Fontawesome.garage, options = options })
                lib.showContext('LabOwnerMenu')
            end
        end, data.inventory)
    end

end

function ChemicalShopMenu()
    local options = {}
    for _, v in pairs(config.ChemicalShop.items) do
        local tmpItem = v.name:gsub('_', ' ')
        options[#options + 1] = {
            title = FirstToUpper(tmpItem),
            icon = 'nui://'..config.InventoryImagesFolder..'/' .. v.name .. ".png",
            description = 'This item cost '..config.MoneySign..v.price,
            arrow = false,
            onSelect = function()
                local input = lib.inputDialog('Buy '..FirstToUpper(tmpItem)..'', {{ type = 'number', label = 'Enter number', description = 'How many items do you want to buy?', required = true, icon = 'hashtag' }})
                if not input then return end
                local data = {item = v.name, amount = tonumber(input[1]), price = v.price}
                TriggerServerEvent('mh-owneddrugslabs:server:buyChemicalShopItems', data)
            end
        }
    end
    options[#options + 1] = {
        title = Lang:t('info.close'),
        icon = config.Fontawesome.goback,
        description = '',
        arrow = false,
        onSelect = function()
        end
    }
    lib.registerContext({ id = 'ChemicalShopMenu', title = 'Chemical Shop', icon = config.Fontawesome.garage, options = options })
    lib.showContext('ChemicalShopMenu')
end