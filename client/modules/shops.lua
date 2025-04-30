
local shopPeds = {}
local ChemicalShopPed = nil

function DeleteShopPeds()
    if #shopPeds > 0 then
        for k, ped in pairs(shopPeds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
        shopPeds = {}
    end
end

function CreateShopPeds() -- peds where you can buy drugs labs
    if config.Labs ~= nil then
        local lastItem = nil
        for id, warehouse in pairs(config.Labs) do
            if warehouse.shop ~= nil and type(warehouse.shop) == 'table' then
                if warehouse.shop.stash ~= nil then
                    if GetResourceState("qb-target") ~= 'missing' then
                        exports['qb-target']:AddBoxZone('shoptraystash_'..warehouse.id, vector3(warehouse.shop.stash.coords.x, warehouse.shop.stash.coords.y, warehouse.shop.stash.coords.z), 1.5, 1.5, {
                            name = 'shoptraystash_'..warehouse.id,
                            heading = 0.0,
                            minZ = warehouse.shop.stash.coords.z - 1,
                            maxZ = warehouse.shop.stash.coords.z + 1,
                            debugPoly = false,
                        }, {
                            options = {
                                {
                                    type = "client",
                                    event = "",
                                    icon = 'fa fa-hand',
                                    label = 'Open Shop',
                                    action = function(entity)
                                        ShopMenu({id = warehouse.id, type = warehouse.shop.stash.name, inventory = warehouse.shop.stash.inventory})
                                    end,
                                    canInteract = function(entity, distance, data)
                                        return true
                                    end,
                                }
                            },
                            distance = 1.5
                        })
                    elseif GetResourceState("ox_target") ~= 'missing' then
                        exports.ox_target:addBoxZone({
                            name = 'shoptraystash_'..warehouse.id,
                            coords = vector3(warehouse.shop.stash.coords.x, warehouse.shop.stash.coords.y, warehouse.shop.stash.coords.z - 0.5),
                            size = vector3(1.5, 1.5, 1.5),
                            rotation = 0.0,
                            debug = config.Debug,
                            options = {
                                {
                                    type = 'server',
                                    event = '',
                                    icon = 'fa fa-hand',
                                    label = 'Open Shop',
                                    onSelect = function(data)
                                        ShopMenu({id = warehouse.id, type = warehouse.shop.stash.name, inventory = warehouse.shop.stash.inventory})
                                    end,
                                    canInteract = function(entity, distance, data)
                                        return true
                                    end,
                                    distance = 1.5,
                                },
                            },
                        })
                    end
                end

                if lastItem ~= warehouse.labOwnerKeyItem then
                    lastItem = warehouse.labOwnerKeyItem
                    if warehouse.shop.blip ~= nil then
                        if warehouse.shop.blip.enable then
                            local blip = AddBlipForCoord(warehouse.shop.coords.x, warehouse.shop.coords.y, warehouse.shop.coords.z)
                            SetBlipSprite(blip, warehouse.shop.blip.sprite)
                            SetBlipScale(blip, warehouse.shop.blip.scale)
                            SetBlipColour(blip, warehouse.shop.blip.color)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString(warehouse.shop.blip.label)
                            EndTextCommandSetBlipName(blip)
                            SetBlipAsShortRange(blip, true)
                            blips[#blips + 1] = blip
                        end
                    end
                    local current = GetHashKey(warehouse.shop.ped.model)
                    LoadModel(current)
                    local ped = CreatePed(0, current, warehouse.shop.coords.x, warehouse.shop.coords.y, warehouse.shop.coords.z - 1, warehouse.shop.heading, true, false)
                    while not DoesEntityExist(ped) do Wait(1) end
                    shopPeds[#shopPeds + 1 ] = ped
                    TaskStartScenarioInPlace(ped, warehouse.shop.ped.scenario, true, false)
                    FreezeEntityPosition(ped, true)
                    SetEntityInvincible(ped, true)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    local netid = NetworkGetNetworkIdFromEntity(ped)
                    if GetResourceState("qb-target") ~= 'missing' then
                        exports['qb-target']:AddTargetEntity(netid, {
                            options = {
                                {
                                    name = "shops",
                                    label = warehouse.shop.label,
                                    icon = 'fa-solid fa-microscope',
                                    action = function()
                                        BuyLapMenu(warehouse)
                                    end,
                                    canInteract = function(entity)
                                        if HasItem(warehouse.labOwnerKeyItem, 1) then return false end
                                        if HasItem(warehouse.labEmployeeKeyItem, 1) then return false end
                                        if HasKeyWithLabId(warehouse.id) then return false end
                                        return true
                                    end,
                                }
                            },
                            distance = 2.0
                        })
                    elseif GetResourceState("ox_target") ~= 'missing' then
                        exports.ox_target:addEntity(netid, {
                            {
                                name = 'shops',
                                icon = 'fa-solid fa-microscope',
                                label = warehouse.shop.label,
                                onSelect = function(data)
                                    BuyLapMenu(warehouse)
                                end,
                                canInteract = function(data)
                                    if HasItem(warehouse.labOwnerKeyItem, 1) then return false end
                                    if HasItem(warehouse.labEmployeeKeyItem, 1) then return false end
                                    if HasKeyWithLabId(warehouse.id) then return false end
                                    return true
                                end,
                                distance = 2.0
                            },
                        })
                    end
                end

            end
            Wait(5)
        end
    end
end

function DeleteChemicalShopPed()
    if DoesEntityExist(ChemicalShopPed) then
        DeleteEntity(ChemicalShopPed)
        ChemicalShopPed = nil
    end
end

function CreateChemicalShopPed()
    local model = config.ChemicalShop.pedModel
    local current = GetHashKey(model)
    LoadModel(current)
    local ped = CreatePed(0, current, config.ChemicalShop.coords.x, config.ChemicalShop.coords.y, config.ChemicalShop.coords.z - 1, config.ChemicalShop.heading, false, false)
    while not DoesEntityExist(ped) do Citizen.Wait(10) end
    ChemicalShopPed = ped
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityHeading(ped, config.ChemicalShop.heading)
    TaskStartScenarioInPlace(ped, config.ChemicalShop.scenario, 0, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetPedKeepTask(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    if config.ChemicalShop.blip.enable then
        local blip = AddBlipForCoord(config.ChemicalShop.coords.x, config.ChemicalShop.coords.y, config.ChemicalShop.coords.z)
        SetBlipSprite(blip, config.ChemicalShop.blip.sprite)
        SetBlipScale(blip, config.ChemicalShop.blip.scale)
        SetBlipColour(blip, config.ChemicalShop.blip.color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(config.ChemicalShop.blip.label)
        EndTextCommandSetBlipName(blip)
        SetBlipAsShortRange(blip, true)
        blips[#blips + 1] = blip
    end
    if GetResourceState("qb-target") ~= 'missing' then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {{
                label = "Chemical Shop",
                icon = 'fa-solid fa-stash',
                action = function()
                    ChemicalShopMenu()
                end,
                canInteract = function(entity, distance, data)
                    if not isLoggedIn then return false end
                    return true
                end
            }},
            distance = 2.0
        })
    elseif GetResourceState("ox_target") ~= 'missing' then
        exports.ox_target.addEntity(ped, {
            options = {{
                name = "vehiclesabotage",
                label = "Chemical Shop",
                icon = 'fa-solid fa-stash',
                action = function()
                    ChemicalShopMenu()
                end,
                canInteract = function(entity, distance, data)
                    if not isLoggedIn then return false end
                    return true
                end
            }},
            distance = 2.0
        })
    end
end

CreateThread(function()
    while true do
        Wait(1000)
        if isLoggedIn and config.RenderDistanceForPeds and #shopPeds > 0 and ChemicalShopPed ~= nil then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local ChemicalShopPedCoords = GetEntityCoords(ChemicalShopPed)
            if GetDistance(playerCoords, ChemicalShopPedCoords) < 15 and not IsEntityVisible(ChemicalShopPed) then
                SetEntityVisible(ChemicalShopPed, true, false)
            elseif GetDistance(playerCoords, ChemicalShopPedCoords) > 15 and IsEntityVisible(ChemicalShopPed) then
                SetEntityVisible(ChemicalShopPed, false, false)
            end
            for _, ped in pairs(shopPeds) do
                local pedCoords = GetEntityCoords(ped)
                if GetDistance(playerCoords, pedCoords) < 50 and not IsEntityVisible(ped) then
                    SetEntityVisible(ped, true, false)
                elseif GetDistance(playerCoords, pedCoords) > 50 and IsEntityVisible(ped) then
                    SetEntityVisible(ped, false, false)
                end
            end
        end
    end
end)