local drugsProps = {}
local lootedEntities = {}
local fieldBlips = {}

local function DeleteFieldBlips()
    if #fieldBlips > 0 then
        for k, blip in pairs(fieldBlips) do
            if DoesBlipExist(blip) then
                SetBlipAlpha(blip, 0)
                RemoveBlip(blip)
            end
        end
    end
    fieldBlips = {}
end

local function GetRandomPosition(coords, radius)
    local x = (coords.x + math.random(-radius, radius)) 
	local y = (coords.y + math.random(-radius, radius)) 
	local _, z = GetGroundZFor_3dCoord(x, y, coords.z, false)
    return x, y, z
end

local function IsAlreadyLooted(entity)
    if lootedEntities[entity] then return true end
    return false
end

local function SetIsLooted(entity)
    if not lootedEntities[entity] then lootedEntities[entity] = true end
end

local function LootEntity(data)
    local dojob = false
    local player = PlayerPedId()
    local timer = config.HarvestDefaultTimer
    if data.harvestTimer ~= nil then timer = data.harvestTimer end
    if data.needItem ~= nil then
        if not HasItem(data.needItem, 1) then
            RequiredJobItems({data.needItem})
            disableControll = false
            isBizy = false
            return
        elseif HasItem(data.needItem, 1) then
            dojob = true
        end
    else
        dojob = true
    end
    if dojob then
        if not IsAlreadyLooted(data.entity) then
            disableControll = true
            isBizy = true
            LockInventory(true)
            TaskTurnPedToFaceEntity(player, data.entity, 5000)
            Wait(1000)
            local options = {
                duration = timer,
                label = 'Search',
                useWhileDead = false,
                canCancel = false,
                disable = {car = true},
                anim = { dict = 'amb@world_human_gardener_plant@male@base', clip = 'base', flag = 49 },
            }
            if lib.progressCircle(options) then
                SetIsLooted(data.entity)
                QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:loot", function(result)
                    if not result.status then Notify(result.message, 'error', 5000) end
                    ClearPedTasks(player)
                    LockInventory(false)
                    isBizy = false
                    disableControll = false
                end, {entity = data.entity, rewardItem = data.rewardItem, rewardAmount = data.rewardAmount, chance = data.chance})
            else
                ClearPedTasks(player)
                LockInventory(false)
                isBizy = false
                disableControll = false
            end
        elseif IsAlreadyLooted(data.entity) then
            ClearPedTasks(player)
            LockInventory(false)
            isBizy = false
            disableControll = false
            Notify('Already taken', "error", 5000)
        end
    end
end

local function SetFieldBlip(blip, coords, radius)
    if blip.enable then
        if config.Debug then
            local _blip = AddBlipForRadius(coords.x, coords.y, coords.z, radius)
            SetBlipHighDetail(_blip, true)
            SetBlipColour(_blip, blip.color)
            SetBlipAlpha (_blip, 128)
        end
        local _blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(_blip, blip.sprite)
        SetBlipDisplay(_blip, 4)
        SetBlipScale(_blip, blip.scale)
        SetBlipColour(_blip, blip.color)
        SetBlipAsShortRange(_blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blip.label)
        EndTextCommandSetBlipName(_blip)
        fieldBlips[#fieldBlips + 1] = _blip
    end
end

local function LoadFields(coords)
    for k, v in pairs(config.Fields) do
        if GetDistance(coords, v.coords) < 50 then
            SetFieldBlip(v.blip, v.coords, v.radius)
            for i = 0, v.amount do
                local x, y, z = GetRandomPosition(v.coords, v.radius)
                LoadModel(v.prop)
                local spawn = CreateObject(v.prop, x, y, z, true, true, false)
                drugsProps[#drugsProps + 1] = spawn
                SetEntityAsMissionEntity(spawn, true, true)
                SetEntityHeading(spawn, 0.0)
                FreezeEntityPosition(spawn, true)
                if DoesEntityExist(spawn) then
                    if GetResourceState("qb-target") ~= 'missing' then
                        exports['qb-target']:AddTargetModel(v.prop, {
                            options = {
                                {
                                    type = "client",
                                    icon = "fas fa-hand",
                                    label = 'Harvest '..v.rewardItem,
                                    action = function(entity)
                                        disableControll = true
                                        LootEntity({ entity = entity, chance = v.chance, needItem = v.needItem, rewardItem = v.rewardItem, rewardAmount = v.rewardAmount })
                                    end,
                                    canInteract = function(entity, distance, data)
                                        if disableControll then return false end
                                        if isBizy then return false end
                                        return true
                                    end
                                },
                            },
                            distance = 1.5 
                        })
                    elseif GetResourceState("ox_target") ~= 'missing' then
                        exports.ox_target:addModel(v.prop, {
                            {
                                name = "weedplant",
                                type = "client",
                                icon = "fas fa-hand",
                                label = 'Harvest '..v.rewardItem,
                                onSelect = function(data)
                                    disableControll = true
                                    LootEntity({ entity = data.entity, chance = v.chance, needItem = v.needItem, rewardItem = v.rewardItem, rewardAmount = v.rewardAmount })
                                end,
                                canInteract = function(entity, distance, data)
                                    if disableControll then return false end
                                    if isBizy then return false end
                                    return true
                                end,
                                distance = 1.5
                            },
                        })
                    end
                end
            end
            break
        end
    end
end

function DeleteAllFields()
    DeleteFieldBlips()
    for k, v in pairs(drugsProps) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
end

RegisterNetEvent('mh-owneddrugslabs:client:refreshFlields', function()
    lootedEntities = {}
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn then
            local player_coords = GetEntityCoords(PlayerPedId())
            if config.Fields ~= nil then
                for _, field in pairs(config.Fields) do
                    local pos1 = vector3(player_coords.x, player_coords.y, player_coords.z)
                    local pos2 = vector3(field.coords.x, field.coords.y, field.coords.z)
                    local distance = GetDistance(pos1, pos2)
                    if distance < field.radius + 100.0 and not field.loaded then
                        field.loaded = true
                        LoadFields(field.coords)
                    elseif distance > field.radius + 100.0 and field.loaded then
                        field.loaded = false
                        DeleteAllFields()
                    end
                end
            end
        end
        Wait(sleep)
    end
end)