local dealerPeds = {}
local isRobbing = false
local robbedEntity = nil
local currentEntityCoords = nil
local currentEntityHeading = nil

function DeletePeds()
    for key, dealer in pairs(dealerPeds) do
        if DoesEntityExist(dealer) then
            DeleteEntity(dealer)
        end
    end
    dealerPeds = {}
end

--- Set Relationship
local function SetRelationship()
    SetRelationshipBetweenGroups(0, GetHashKey("Guards"), GetHashKey("Guards"))
    SetRelationshipBetweenGroups(5, GetHashKey("Guards"), GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("Guards"))
end

--- Reset Relationship
local function ResetRelationship()
    SetRelationshipBetweenGroups(0, GetHashKey("Guards"), GetHashKey("Guards"))
    SetRelationshipBetweenGroups(0, GetHashKey("Guards"), GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetHashKey("Guards"))
end

function GetBackToLocation()
    ResetRelationship()
    ClearPedTasks(robbedEntity)
    ClearPedTasksImmediately(robbedEntity)
    ClearPedSecondaryTask(robbedEntity)
    SetCurrentPedWeapon(robbedEntity, GetHashKey("WEAPON_UNARMED"), true)
    Wait(10)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_GUARD_STAND_ARMY", true, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    currentEntityCoords = nil
    currentEntityHeading = nil
    robbedEntity = nil
    isRobbing = false
end

function RobDealer(entity)
    isRobbing = true
    robbedEntity = entity
    currentEntityCoords = GetEntityCoords(entity)
    currentEntityHeading = GetEntityHeading(entity)
    ClearPedTasks(entity)
    ClearPedSecondaryTask(entity)
    local weapon = config.Weapons[math.random(1, #config.Weapons)]
    GiveWeaponToPed(entity, weapon, 999, false, true)
    SetCurrentPedWeapon(entity, weapon, true)
    SetEntityAsMissionEntity(entity, true, true)
    SetEntityHealth(entity, 250)
    SetPedArmour(entity, 100)
    SetPedAccuracy(entity, 50)
    SetPedCombatAbility(entity, 1)
    SetPedCombatMovement(entity, 0)
    SetPedCombatRange(entity, 0)
    SetPedCombatAttributes(entity, 42, true)
    SetPedCombatAttributes(entity, 46, true)
    SetPedCombatAttributes(entity, 58, true)
    SetPedFleeAttributes(entity, 0, 0)
    SetPedSeeingRange(entity, 150.0)
    SetPedHearingRange(entity, 150.0)
    SetPedRelationshipGroupHash(entity, GetHashKey("Guards"))
    FreezeEntityPosition(entity, false)
    TaskSetBlockingOfNonTemporaryEvents(entity, true)
    SetRelationship()
end

function ArrestDealer(dealer)
    QBCore.Functions.TriggerCallback("mh-owneddrugslabs:server:ArrestDealer", function(result)
    end, dealer)
end

function CreateDealers()
    isRobbing = false
    if config.Dealers ~= nil then
        for i, dealer in pairs(config.Dealers) do
            local current = GetHashKey(dealer.ped.model)
            LoadModel(current)
            local ped = CreatePed(0, current, dealer.coords.x, dealer.coords.y, dealer.coords.z - 1, dealer.heading, true, false)
            while not DoesEntityExist(ped) do Wait(1) end
            dealerPeds[#dealerPeds + 1 ] = ped
            TaskStartScenarioInPlace(ped, dealer.ped.scenario, true, false)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            local netid = NetworkGetNetworkIdFromEntity(ped)
            if GetResourceState("qb-target") ~= 'missing' then
                exports['qb-target']:AddTargetEntity(netid, {
                    options = {
                        {
                            name = "dealer_"..i,
                            label = dealer.label,
                            icon = 'fa-solid fa-microscope',
                            action = function()
                                BuyDrugsMenu(dealer)
                            end,
                            canInteract = function(entity)
                                if PlayerData.job.name == 'police' then return false end
                                return true
                            end,
                        }, {
                            name = "dealer_"..i + i,
                            label = "Rob dealer",
                            icon = 'fa-solid fa-hand',
                            action = function(entity)
                                local shoot = false
                                local success = lib.skillCheck({'easy'}, {'w', 'a', 's', 'd'})
                                if success then shoot = true else shoot = true end
                                if shoot then RobDealer(entity) end
                            end,
                            canInteract = function(entity)
                                if PlayerData.job.name == 'police' then return false end
                                return true
                            end,
                        }, {
                            name = "dealer_"..i + i,
                            label = "Arrest Drugs Dealer",
                            icon = 'fa-solid fa-handcuffs',
                            action = function(entity)
                                ArrestDealer(dealer)
                            end,
                            canInteract = function(entity)
                                if PlayerData.job.name ~= 'police' then return false end
                                return true
                            end,
                        }
                    },
                    distance = 2.0
                })
            elseif GetResourceState("ox_target") ~= 'missing' then
                exports.ox_target:addEntity(netid, {
                    {
                        name = "dealer_"..i,
                        icon = 'fa-solid fa-microscope',
                        label = dealer.label,
                        onSelect = function(data)
                            BuyDrugsMenu(dealer)
                        end,
                        canInteract = function(data)
                            return true
                        end,
                        distance = 2.0
                    }, {
                        name = "dealer_"..i + i,
                        label = "Rob dealer",
                        icon = 'fa-solid fa-hand',
                        onSelect = function(entity)
                            local shoot = false
                            local success = lib.skillCheck({'easy'}, {'w', 'a', 's', 'd'})
                            if success then shoot = true else shoot = true end
                            if shoot then RobDealer(entity) end
                        end,
                        canInteract = function(entity)
                            return true
                        end,
                        distance = 2.0
                    }, {
                        name = "dealer_"..i + i,
                        label = "Arrest Drugs Dealer",
                        icon = 'fa-solid fa-hand',
                        onSelect = function(entity)
                            ArrestDealer(dealer)
                        end,
                        canInteract = function(entity)
                            if PlayerData.job.name ~= 'police' then return false end
                            return true
                        end,
                        distance = 2.0
                    },
                })
            end
        end
    end
end

CreateThread(function()
    while true do
        Wait(0)
        if isLoggedIn and isRobbing and robbedEntity ~= nil then
            local isDead = PlayerData.metadata['isdead']
            if isDead then
                GetBackToLocation()
                isRobbing = false
            else
                local coords = GetEntityCoords(PlayerPedId())
                if GetDistance(GetEntityCoords(robbedEntity), coords) < 50 then
                    if not isDead then TaskCombatPed(robbedEntity, PlayerPedId(), 0, 16) end
                elseif GetDistance(GetEntityCoords(robbedEntity), coords) > 50 then
                    SetEntityCoords(robbedEntity, currentEntityCoords)
                    SetEntityHeading(robbedEntity, currentEntityHeading)
                    GetBackToLocation()
                    isRobbing = false
                end
            end
        end
    end
end)

CreateThread(function()
	while true do
		Wait(1)
		local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId(-1))
		if aiming and DoesEntityExist(targetPed) and IsEntityAPed(targetPed) then
            for _, ped in pairs(dealerPeds) do
                if targetPed == ped then RobDealer(targetPed) end
            end
		end
	end
end)

CreateThread(function()
    while true do
        Wait(1000)
        if isLoggedIn and config.RenderDistanceForPeds and #dealerPeds > 0 then
            local playerCoords = GetEntityCoords(PlayerPedId())
            for _, ped in pairs(dealerPeds) do
                local pedCoords = GetEntityCoords(ped)
                if not isRobbing then
                    if GetDistance(playerCoords, pedCoords) < 50 and not IsEntityVisible(ped) then
                        SetEntityVisible(ped, true, false)
                    elseif GetDistance(playerCoords, pedCoords) > 50 and IsEntityVisible(ped) then
                        SetEntityVisible(ped, false, false)
                    end
                end
            end
        end
    end
end)