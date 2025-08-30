function Cooldown(secs)
    cooldown = true
    SetTimeout(1000 * secs, function()
        cooldown = false
    end)
end

function CreateKeyItem(item, info)
    local tmpItem = {}
    local itemInfo = SharedItems[item:lower()]
    if itemInfo then
        tmpItem = {
            name = itemInfo['name'],
            amount = 1,
            info = info or {},
            label = itemInfo['label'],
            description = itemInfo['description'] or '',
            weight = itemInfo['weight'],
            type = itemInfo['type'],
            unique = itemInfo['unique'],
            useable = itemInfo['useable'],
            image = itemInfo['image'],
            shouldClose = itemInfo['shouldClose'],
            combinable = itemInfo['combinable']
        }
    end
    return tmpItem
end

function RequiredJobItems(items)
    local tmpItems = {}
    for k, item in pairs(items) do tmpItems[#tmpItems + 1] = CreateKeyItem(item) end
    disableControll = false
    RequiredItems(tmpItems, true)
    Wait(5000)
    RequiredItems(tmpItems, false)
end

function Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

function Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end

function FirstToUpper(str)
    if str ~= nil then
        return (str:gsub("^%l", string.upper))
    else
        return
    end
end

function GetBestTime(timer)
    local time = math.ceil(timer)
    local hours = string.format("%02.f", math.floor(time / 3600))
    local minutes = string.format("%02.f", math.floor(time / 60 - (hours * 60)))
    local seconds = string.format("%02.f", math.floor(time - hours * 3600 - minutes * 60))
    return hours, minutes, seconds
end

function LoadModel(model)
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(1) end
    end
end

function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(1) end
    end
end

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(_x, _y)
end

function DrawTxt(x, y, width, height, scale, text, r, g, b, a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

function RemoveControllAnimation()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        LoadAnimDict('anim@mp_player_intmenu@key_fob@')
        local remote = 0
        local model = 'prop_cuff_keys_01'
        LoadModel(model)
        remote = CreateObject(joaat(model), 0, 0, 0, true, true, true)
        while not DoesEntityExist(remote) do Wait(1) end
        AttachEntityToEntity(remote, ped, GetPedBoneIndex(ped, 57005), 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, -8.0, -1, 52, 0, false, false, false)
        Wait(500)
        if IsEntityPlayingAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3) then
            StopAnimTask(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0)
        end
        if remote ~= 0 and DoesEntityExist(remote) then
            DeleteObject(remote)
            remote = 0
        end
    end
end

function GetDistance(pos1, pos2)
    if pos1 ~= nil and pos2 ~= nil then
        return #(vector3(pos1.x, pos1.y, pos1.z) - vector3(pos2.x, pos2.y, pos2.z))
    end
end

function GetPlate(vehicle)
    return Trim(GetVehicleNumberPlateText(vehicle))
end

function GetPeds()
    local pedPool = GetGamePool('CPed')
    local peds = {}
    for i = 1, #pedPool do
        if pedPool[i] ~= PlayerPedId() then
            peds[#peds + 1] = pedPool[i]
        end
    end
    return peds
end

function GetClosestPed(coords)
    local peds = GetPeds()
    local closestDistance = -1
    local closestPed = -1
    for i = 1, #peds, 1 do
        if peds[i] ~= PlayerPedId() and GetEntityType(peds[i]) == 1 then
            local pedCoords = GetEntityCoords(peds[i])
            local distance = #(pedCoords - coords)
            if closestDistance == -1 or closestDistance > distance then
                closestPed = peds[i]
                closestDistance = distance
            end
        end
    end
    return closestPed, closestDistance
end

function GetPlayersFromCoords(coords, distance)
    local players = GetActivePlayers()
    local ped = PlayerPedId()
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    distance = distance or 5
    local closePlayers = {}
    for _, player in ipairs(players) do
        local targetCoords = GetEntityCoords(GetPlayerPed(player))
        local targetdistance = #(targetCoords - coords)
        if targetdistance <= distance then
            closePlayers[#closePlayers + 1] = player
        end
    end
    return closePlayers
end

function GetClosestPlayers()
    local coords = GetEntityCoords(PlayerPedId())
    local closestPlayers = GetPlayersFromCoords(coords)
    local closestPlayer = -1
    local players = {}
    for i = 1, #closestPlayers, 1 do
        if closestPlayers[i] ~= -1 then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)
            if distance < 5.0 then
                players[#players + 1] = closestPlayers[i]
            end
        end
    end
    return players
end

function SpawnClear(coords, radius)
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(PlayerPedId())
    end
    local vehicles = GetGamePool('CVehicle')
    local closeVeh = {}
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)
        if distance <= radius then
            closeVeh[#closeVeh + 1] = vehicles[i]
        end
    end
    if #closeVeh > 0 then return false end
    return true
end

function GetVehicleNameFromModel(model)
    if Vehicles[GetHashKey(model)] then
        return Vehicles[GetHashKey(model)]
    else
        return "unknow"
    end
end

function GetVehicleLabel(vehicle)
    if vehicle == nil or vehicle == 0 then return end
    return GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
end

function HasKeyWithLabId(warehouse)
    local result = {status = false, owner = false}
    for _, item in pairs(PlayerData.items) do
        if item.info.labid ~= nil and tonumber(item.info.labid) == tonumber(warehouse.id) then
            if item.name == warehouse.labOwnerKeyItem then
                result = {key = true, owner = true}
                break
            elseif item.name == warehouse.labEmployeeKeyItem then
                result = {key = true, owner = false}
                break
            end
        end
    end
    return result
end