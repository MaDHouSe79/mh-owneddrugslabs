----------------------------------------------------------------
--- [ DO NOT EDIT OR CHANGE ANYTHING BELOW THIS ] ---
--- This are main settings that can not be edit because the script will no longer work propperly. 
SV_Config = {}
SV_Config.Deliveries = {}
SV_Config.DefaultRouteTypes = {"box", "moneybag", "drugs"}
SV_Config.RouteTypes = {"box", "moneybag", "drugs"}
--- [ DO NOT EDIT OF CHANGE ANYTHING ABOVE THIS ] ---
----------------------------------------------------------------

--- [ YOU CAN EDIT THIS BELOW TO YOUR NEEDS ] ---

-- Fuel script needs to have 2 exports like below.
-- 1: exports["<your script>"]:SetFuel(entity, fuel)
-- 2: exports["<your script>"]:GetFuel(entity)
SV_Config.FuelResource = "mh-fuel" -- LegacyFuel
----------------------------------------------------------------
-- Interact Key Buttons
SV_Config.Interactkey = 38         -- E
SV_Config.InteractkeyDisplay = "E" -- E
----------------------------------------------------------------
-- Note you need atleast 1 item like a joint or 1 weed_baggy in the job stash before this works.
SV_Config.GiveItemsToPlayers = false -- when true crafted items goes to players inventory, if false if goes to the job stash inventory.
----------------------------------------------------------------
SV_Config.MoneySign = "$"
----------------------------------------------------------------
SV_Config.KeyPrice = 50 -- if you lose your key you can buy a new key.
SV_Config.GiveKeys = 1 -- give 3 keys when you bey a lab or keys
----------------------------------------------------------------
SV_Config.RenderPropsInTrunk = true -- for performance set this to false
SV_Config.UseNavigation = false -- If true it uses waypoints.
SV_Config.UseAutoLoadTrunk = false -- If true players does not have to load the trunk.
----------------------------------------------------------------
SV_Config.MinDistanceBetweenRoutes = 100 -- distance between 2 routes must be higher then this value in meters.
----------------------------------------------------------------
SV_Config.NpcRobPlayer = false -- If trye an npc can steel your payslips.
SV_Config.UseDangerZones = false -- use danger zones when you doing a drugs job
SV_Config.ChanceToRobPlayer = 0.1 -- 1% Chance
----------------------------------------------------------------
SV_Config.RenderDistanceForPeds = true -- if true peds are only visable when you are close
----------------------------------------------------------------
SV_Config.Fontawesome = {
    boss = "fa-solid fa-people-roof",
    pump = "fa-solid fa-gas-pump",
    trucks = "fa-solid fa-truck",
    trailers = "fa-solid fa-trailer",
    garage = "fa-solid fa-warehouse",
    goback = "fa-solid fa-backward-step",
    shop = "fa-solid fa-basket-shopping",
    buy = "fa-solid fa-cash-register",
    stop = "fa-solid fa-stop",
    store = "fa-solid fa-store",
}
----------------------------------------------------------------

SV_Config.ChemicalShop = {
    coords = vector3(-586.5180, -1005.2057, 25.9834),
    header = 353.9794,
    pedModel = "g_m_y_korean_01",
    scenario = "WORLD_HUMAN_STAND_MOBILE",
    blip = { enable = true, label = "Chemical Shop", sprite = 630, color = 29, scale = 0.8 },
    items = {
        { name = "methylamine", amount = 50, price = 10 },
        { name = "ammonia", amount = 50, price = 10 }
    }
}

SV_Config.DefaultShopItems = {
    { name = "cigarettebox", amount = 50, price = 25 },
    { name = "cigarette", amount = 50, price = 1 }
}

-- Item prices
SV_Config.ItemPrice = {
    ['cigarettebox'] = { price = 25 },
    ['cigarette'] = { price = 1 },
    ['rolling_paper'] = { price = 1 },
    ['joint'] = { price = 5 },
    ['weed_baggy'] = { price = 15 },
    ['weed_brick'] = { price = 1000 },
    ['empty_baggy'] = { price = 50 },
    ['coke_baggy'] = { price = 50 },
    ['coke_brick'] = { price = 2000 },
    ['meth_baggy'] = { price = 100 },
}

-- Drugs Props
SV_Config.DrugsProps = {
    weed = "prop_weed_01",
    coke = "prop_plant_fern_02b",
    meth = "prop_methbarrel",
    ammonia = "prop_rad_waste_barrel_01",
}

-- Drugs lab key items
SV_Config.KeyItems = {
    ['weedlabkeys'] = {
        owner = "weedlabownerkey",       -- you need this item in your inventory or you can not access stashes or menus.
        employee = "weedlabemployeekey", -- you need this or you can't do any jobs
    },
    ['cokelabkeys'] = {
        owner = "cokelabownerkey",       -- you need this item in your inventory or you can not access stashes or menus.
        employee = "cokelabemployeekey", -- you need this or you can't do any jobs
    },
    ['methlabkeys'] = {
        owner = "methlabownerkey",       -- you need this item in your inventory or you can not access stashes or menus.
        employee = "methlabemployeekey", -- you need this or you can't do any jobs
    },
}

-- Fields Config
SV_Config.ResetTimer = 900 -- 900 -- 15 min
SV_Config.FieldsConfig = {
    ['weedfield'] = { needItem = "trowel", rewardItem = "cannabis", rewardAmount = 1 },
    ['cokefield'] = { needItem = "trowel", rewardItem = "cocaineleaf", rewardAmount = 1 },
    ['methylaminefield'] = { needItem = nil, rewardItem = "methylamine", rewardAmount = 1 },
    ['ammoniafield'] = { needItem = nil, rewardItem = "ammonia", rewardAmount = 1 }
}

SV_Config.UseableItems = {
    { name = "cigarette",  trigger = "mh-owneddrugslabs:client:UseCigarette" },
    { name = "joint",      trigger = "consumables:client:UseJoint" },
    { name = "coke_baggy", trigger = "consumables:client:Cokebaggy" },
    { name = "meth_baggy", trigger = "consumables:client:meth" },
}

SV_Config.HarvestTimer = 15000
SV_Config.HarvestDefaultTimer = 10000
----------------------------------------------------------------
-- Weapon used when you rob a dealer, a dealer wil use one off this weapons below.
SV_Config.Weapons = { "weapon_assaultrifle_mk2", "weapon_assaultrifle", "weapon_specialcarbine_mk2", "weapon_combatmg_mk2" }
--
SV_Config.InventoryImagesFolder = "qb-inventory/html/images/"
-- smoking
SV_Config.Smoke = 38 -- draw smoke from a cigarette, cigar, joint  -- https://docs.fivem.net/docs/game-references/controls/
SV_Config.Throw = 105 -- throw away a cigarette, cigar, joint
SV_Config.Mouth = 11 -- from hand to mouth
SV_Config.inHand = 10 -- From mouth to hands
--
SV_Config.Debug = false -- If true you will see polyzones.