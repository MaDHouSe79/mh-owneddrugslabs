local isInsideDangerZone = false
local isSet = false

local function TakeItemsBack()
    if IsEntityDead(robthieve) then
        TaskLookAtEntity(PlayerPedId(), robthieve, 5500.0, 2048, 3)
        TaskTurnPedToFaceEntity(PlayerPedId(), robthieve, 5500)
        LoadAnimDict("pickup_object")
        Wait(500)
        TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", -8.0, 8.0, -1, 49, 1.0, 0, 0, 0)
        Wait(800)
        QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:takeItemsBack", function(result)
            if result.status then
                Notify(result.message, "success", 5000)
            else
                Notify(result.message, "error", 5000)
            end
            ClearPedTasksImmediately(PlayerPedId())
        end, NetworkGetNetworkIdFromEntity(robthieve))
    end
end

function SetRelationship(state)
    if state then
        isRobPlayer = true
        SetRelationshipBetweenGroups(5, 'AMBIENT_GANG_HILLBILLY', 'PLAYER')
        SetRelationshipBetweenGroups(5, 'AMBIENT_GANG_BALLAS', 'PLAYER')
        SetRelationshipBetweenGroups(5, 'AMBIENT_GANG_MEXICAN', 'PLAYER')
        SetRelationshipBetweenGroups(5, 'AMBIENT_GANG_FAMILY', 'PLAYER')
        SetRelationshipBetweenGroups(5, 'AMBIENT_GANG_MARABUNTE', 'PLAYER')
        SetRelationshipBetweenGroups(5, 'AMBIENT_GANG_SALVA', 'PLAYER')
        SetRelationshipBetweenGroups(5, 'AMBIENT_GANG_LOST', 'PLAYER')
        SetRelationshipBetweenGroups(5, 'GANG_1', 'PLAYER')
        SetRelationshipBetweenGroups(5, 'GANG_2', 'PLAYER')
        SetRelationshipBetweenGroups(5, 'GANG_9', 'PLAYER')
        SetRelationshipBetweenGroups(5, 'GANG_10', 'PLAYER')
    elseif not state then
        isRobPlayer = false
        SetRelationshipBetweenGroups(1, 'AMBIENT_GANG_HILLBILLY', 'PLAYER')
        SetRelationshipBetweenGroups(1, 'AMBIENT_GANG_BALLAS', 'PLAYER')
        SetRelationshipBetweenGroups(1, 'AMBIENT_GANG_MEXICAN', 'PLAYER')
        SetRelationshipBetweenGroups(1, 'AMBIENT_GANG_FAMILY', 'PLAYER')
        SetRelationshipBetweenGroups(1, 'AMBIENT_GANG_MARABUNTE', 'PLAYER')
        SetRelationshipBetweenGroups(1, 'AMBIENT_GANG_SALVA', 'PLAYER')
        SetRelationshipBetweenGroups(1, 'AMBIENT_GANG_LOST', 'PLAYER')
        SetRelationshipBetweenGroups(1, 'GANG_1', 'PLAYER')
        SetRelationshipBetweenGroups(1, 'GANG_2', 'PLAYER')
        SetRelationshipBetweenGroups(1, 'GANG_9', 'PLAYER')
        SetRelationshipBetweenGroups(1, 'GANG_10', 'PLAYER')
    end
end

RegisterNetEvent('mh-owneddrugslabs:client:deletethieve', function(netid)
    local ped = NetworkGetEntityFromNetworkId(netid)
    if DoesEntityExist(ped) then
        Wait(1000)
        DeleteEntity(ped)
        robthieve = nil
        isRobPlayer = false
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and (config.NpcRobPlayer and HasItem(config.Warehouse[config.WarehouseID].rewardItem, 1)) and not PlayerData.metadata['isdead'] and not cooldown and not isJobEnable and not isInZone and not disableControll then
            if (config.ChanceToRobPlayer == nil) then
                sleep = 6
            elseif (config.ChanceToRobPlayer ~= nil) then
                local mycoords = GetEntityCoords(PlayerPedId())
                local random = 10.0
                if robthieve == nil and not isRobPlayer then
                    if not IsPedInAnyVehicle(PlayerPedId(), false) then
                        local stealingPed, dist = GetClosestPed(mycoords)
                        if stealingPed ~= -1 and dist ~= -1 and not IsEntityDead(stealingPed) and dist < 100.0 then
                            if not IsPedInAnyVehicle(stealingPed, false) then
                                if not isRobPlayer then random = Round(math.random(), 2) end
                                local pedcoords = GetEntityCoords(stealingPed)
                                local distance = GetDistance(mycoords, pedcoords)
                                if distance > 1.5 and random < config.ChanceToRobPlayer then
                                    SetBlockingOfNonTemporaryEvents(robthieve, true)
                                    TaskSetBlockingOfNonTemporaryEvents(robthieve, true)
                                    isRobPlayer = true
                                    robthieve = stealingPed
                                    sleep = 5
                                    local weapon = config.Weapons[math.random(1, #config.Weapons)]
                                    GiveWeaponToPed(stealingPed, weapon, 999, false, true)
                                    SetPedInfiniteAmmo(stealingPed, true, GetHashKey(weapon))
                                    SetPedKeepTask(stealingPed, true)
                                    SetPedAccuracy(stealingPed, 50)
                                end
                            end
                        end
                    end
                elseif robthieve ~= nil and isRobPlayer and not hasStolenItem then
                    if not IsPedInAnyVehicle(PlayerPedId(), false) then
                        if not IsEntityDead(robthieve) then
                            sleep = 5
                            local pedcoords = GetEntityCoords(robthieve)
                            local distance = GetDistance(mycoords, pedcoords)
                            if distance > 2.0 and distance < 100.0 then
                                TaskCombatPed(stealingPed, PlayerPedId(), 0, 16)
                                TaskLookAtEntity(robthieve, PlayerPedId(), 5500.0, 2048, 3)
                                TaskGoStraightToCoord(robthieve, mycoords.x, mycoords.y, mycoords.z, 15.0, -1, 0.0, 0.0)
                            elseif distance < 2.0 then
                                TaskLookAtEntity(robthieve, PlayerPedId(), 5500.0, 2048, 3)
                                TaskTurnPedToFaceEntity(robthieve, PlayerPedId(), 5500)
                                Wait(500)
                                QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:robPlayer", function(result)
                                    if result.status then
                                        Notify(result.message, "success", 5000)
                                        local netid = NetworkGetNetworkIdFromEntity(robthieve)
                                        if GetResourceState("qb-target") ~= 'missing' then
                                            exports['qb-target']:AddTargetEntity(netid, {
                                                options = {{
                                                    type = "client",
                                                    icon = 'fas fa-skull-crossbones',
                                                    label = Lang:t('info.take_items_back'),
                                                    action = function(entity)
                                                        TakeItemsBack()
                                                    end,
                                                    canInteract = function(entity, distance, data)
                                                        if IsPedAPlayer(entity) then return false end
                                                        if not IsEntityDead(entity) then return false end
                                                        return true
                                                    end
                                                }},
                                                distance = 1.5
                                            })
                                        elseif GetResourceState("ox_target") ~= 'missing' then
                                            exports.ox_target:addEntity(netid, {
                                                options = {
                                                    icon = 'fas fa-skull-crossbones',
                                                    label = Lang:t('info.take_items_back'),
                                                    onSelect = function(data)
                                                        TakeItemsBack()
                                                    end,
                                                    canInteract = function(data)
                                                        if IsPedAPlayer(data.entity) then return false end
                                                        if not IsEntityDead(data.entity) then return false end
                                                        return true
                                                    end,
                                                    distance = 1.5
                                                },
                                            })
                                        end
                                        TaskStartScenarioInPlace(robthieve, "WORLD_HUMAN_STAND_IMPATIENT_UPRIGHT", 0, false)
                                        Wait(500)
                                        hasStolenItem = true
                                        SetPedKeepTask(robthieve, false)
                                        ClearPedTasksImmediately(robthieve)
                                        Wait(1000)
                                        Cooldown(300)
                                    else
                                        Notify(result.message, "error", 5000)
                                    end
                                end)

                            elseif distance > 100.0 then
                                ClearPedTasksImmediately(robthieve)
                                robthieve = nil
                                isRobPlayer = false
                                Cooldown(300)
                            end
                        end
                    end
                end
            end
        end
        if sleep > 5 and sleep ~= 1000 then sleep = math.random(10000, 300000) end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and config.UseDangerZones and not PlayerData.metadata['isdead'] then
            local coords = GetEntityCoords(PlayerPedId())
            local random = 1.0
            if config.NpcRobPlayer then
                for id, zone in pairs(config.DangerZones) do
                    if GetDistance(zone.coords, coords) < 50 then
                        sleep = 3000
                        if not isRobPlayer then random = Round(math.random(), 2) end
                        if random <= config.ChanceToRobPlayer then isInsideDangerZone = true end
                    end
                end
                if isInsideDangerZone and not isSet then
                    isSet = true
                    SetRelationship(true)
                elseif not isInsideDangerZone and isSet then
                    isSet = false
                    SetRelationship(false)
                end
            end
        end
        Wait(sleep)
    end
end)