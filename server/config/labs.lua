--[[
    if you change something wrong here, the script will brake,
    the best option is not edit this below and keep it as it is.
    If something hase to change in here then make sure you know what you are doeing...
]]

SV_Config.Labs = {
    -- weed lab
    [1] = {
        id = 1,                                                                                                       -- uniqeu id
        name = "Weed Lab",                                                                                            -- name
        owner = nil,                                                                                                  -- is always nil here
        rewardItem = "pay_slip_weed",                                                                                 -- item to get when you do a delivery
        rewardAmount = 2,                                                                                             -- total rewardItem per delivery
        payout = 500,                                                                                                 -- total payout per rewardItem
        needItem = "weed_brick",                                                                                      -- you need this item in your inventory
        labOwnerKeyItem = SV_Config.KeyItems['weedlabkeys'].owner,                                                    -- you need this item in your inventory ot you can not access stashes or menus.
        labEmployeeKeyItem = SV_Config.KeyItems['weedlabkeys'].employee,                                              -- you need this or you can't do any jobs
        deliveryTypes = { "drugs" },                                                                                  -- delivery types
        deliveryType = "drugs",
        deliveryBlip = { label = "Drugs deliveries", sprite = 514, color = 66, scale = 0.3 },                         -- delivery blip on the map when you are deliver a item
        stash = { coords = vector3(381.2554, -819.6379, 29.3026), name = "delivery_weed_stash", label = "Weed Lab Employee Stash" },                     -- job stash
        ownerstash = { coords = vector3(380.4364, -819.6639, 29.3026), name = "delivery_weed_owner_stash", label = "Weed Lab Owner Stash" },
        vehicle = {                                                                                                   -- used vehicle for the job
            models = { ["adder"] = true },                                                                            -- used model
            spawn = { coords = vector3(369.5169, -828.9938, 28.8802), heading = 179.9660 },                           -- spawn vehicle
            garage = { coords = vector3(365.1218, -820.4238, 29.2930) },                                              -- job garage
        },
        computer = {                                                                                                  -- toggle job enable and deliver items
            coords = vector3(375.9185, -823.8154, 29.3029),                                                           -- location where to start
            radius = 2.5,                                                                                             -- the interact radius
            blip = { enable = false, label = "Weed Delivery", sprite = 521, color = 29, scale = 0.8, radius = 25.0 }, -- blip on the map
        },
        pickups = {                                                                                                   -- this are pickes in the lab
            { coords = vector3(381.8190, -820.8743, 29.3026), pickups = 2, count = 0, isDone = false, entity = nil },
        },
        process = { -- crafting stuff
            prepare = {
                coords = vector3(382.5915, -816.6628, 29.3042),
                label = "Weed Process",
                needItems = {
                    { name = "empty_baggy", amount = 1 },
                    { name = "cannabis",    amount = 4 },
                },
                rewardItem = "weed_baggy",
                rewardAmount = 1
            },
            finish = {
                coords = vector3(374.7289, -816.1457, 29.6603),
                label = "Create Weed blocks",
                needItems = {
                    { name = "weed_baggy", amount = 8 },
                },
                rewardItem = "weed_brick",
                rewardAmount = 1
            },
            rolljoint = {
                coords = vector3(377.1258, -826.7159, 29.3022),
                label = "Create Joints",
                needItems = {
                    { name = "rolling_paper", amount = 1 },
                    { name = "cigarette",     amount = 1 },
                    { name = "weed_baggy",    amount = 1 },
                },
                rewardItem = "joint",
                rewardAmount = 3
            }
        },
        shop = { -- shop to buy a job key
            label = "Open Shop",
            coords = vector3(172.1505, -1095.7942, 49.1560),
            stash = { coords = vector3(376.6964, -828.0456, 29.3024), name = "weed_shop_tray", inventory = 'delivery_weed_owner_stash' },
            heading = 90.0,
            price = 25000,
            ped = {
                model = "a_m_y_latino_01",
                scenario = "WORLD_HUMAN_STAND_MOBILE",
            },
            items = {
                { name = "rolling_paper", price = 1 },
                { name = "cigarettebox",  price = 25 },
                { name = "empty_baggy",   price = 1 },
                { name = "weed_baggy",    price = 15 },
                { name = "weed_brick",    price = 1000 },
                { name = "joint",         price = 5 },
            },
            blip = { enable = false, label = "Weed Lab Key Shop", sprite = 186, color = 29, scale = 0.8 },
        },
        -- the total zone where the lab is, keep in mind that you dont have the garage in here, keep it out the zone.
        -- the vehicle spawn need to be inside the job zone.
        zone = {
            name = 'zone_weedlap',
            minZ = 26.291648864746,
            maxZ = 32.291648864746,
            vectors = {
                vector2(384.28369140625, -840.39855957031),
                vector2(367.24969482422, -840.54107666016),
                vector2(367.90502929688, -811.65301513672),
                vector2(383.64340209961, -811.43615722656),
            },
        },
    },

    -- coke lab job
    [2] = {
        id = 2,
        owner = nil,
        name = "Coke Lab",
        rewardItem = "pay_slip_coke",
        rewardAmount = 2,
        payout = 1000,
        needItem = "coke_brick",
        labOwnerKeyItem = SV_Config.KeyItems['cokelabkeys'].owner,
        labEmployeeKeyItem = SV_Config.KeyItems['cokelabkeys'].employee, -- you need this or you can't do any jobs
        deliveryTypes = { "drugs" },
        deliveryType = "drugs",
        deliveryBlip = { label = "Drugs deliveries", sprite = 51, color = 66, scale = 0.3 },
        stash = { coords = vector3(874.1304, -1137.5724, 26.0383), name = "delivery_coke_stash", label = "Coke Lab Employee Stash" },
        ownerstash = { coords = vector3(1948.7639, 5177.1821, 47.9838), name = "delivery_coke_owner_stash", label = "Coke Lab Owner Stash" },
        vehicle = {
            models = { ["ignus"] = true },
            spawn = { coords = vector3(867.9643, -1145.8876, 23.5525), heading = 179.3318 },
            garage = { coords = vector3(841.9030, -1162.2957, 24.6319) },
        },
        computer = {
            coords = vector3(880.0386, -1147.5243, 26.0384),
            radius = 2.5,
            blip = { enable = false, label = "Coke Delivery", sprite = 521, color = 29, scale = 0.8, radius = 25.0 },
        },
        pickups = {
            { coords = vector3(873.9833, -1138.9448, 26.0383), pickups = 2, count = 0, isDone = false, entity = nil },
        },
        process = {
            prepare = {
                coords = vector3(881.3988, -1141.9603, 26.0802),
                label = "Coke Process",
                needItems = {
                    { name = "empty_baggy",  amount = 1 },
                    { name = "cigarettebox", price = 25 },
                    { name = "cocaineleaf",  amount = 4 },
                },
                rewardItem = "coke_baggy",
                rewardAmount = 1
            },
            finish = {
                coords = vector3(885.2247, -1134.0093, 26.22397),
                label = "Create Coke blocks",
                needItems = {
                    { name = "coke_baggy", amount = 8 },
                },
                rewardItem = "coke_brick",
                rewardAmount = 1
            }
        },
        shop = {
            label = "Open Shop",
            coords = vector3(44.5346, -1029.2838, 79.7362),
            stash = { coords = vector3(880.0076, -1135.0374, 26.0384), name = "coke_shop_tray", inventory = 'delivery_coke_owner_stash' },
            heading = 159.0988,
            price = 500000,
            ped = {
                model = "g_m_y_lost_01",
                scenario = "WORLD_HUMAN_STAND_MOBILE",
            },
            items = {
                { name = "empty_baggy",  price = 1 },
                { name = "cigarettebox", price = 25 },
                { name = "coke_baggy",   price = 200 },
                { name = "coke_brick",   price = 3000 },
            },
            blip = { enable = false, label = "Coke Lab Key Shop", sprite = 186, color = 29, scale = 0.8 },
        },
        zone = {
            name = 'zone_cokelab',
            minZ = 22.00,
            maxZ = 35.00,
            vectors = {
                vector2(887.54357910156, -1155.1099853516),
                vector2(887.56097412109, -1130.0592041016),
                vector2(861.67156982422, -1130.1944580078),
                vector2(863.02984619141, -1155.2016601562),
            },
        },
    },

    -- meth lab job
    [3] = {
        id = 3,
        owner = nil,
        name = "Meth Lab",
        rewardItem = "pay_slip_meth",
        rewardAmount = 2,
        payout = 500,
        needItem = "meth_baggy",
        labOwnerKeyItem = SV_Config.KeyItems['methlabkeys'].owner,
        labEmployeeKeyItem = SV_Config.KeyItems['methlabkeys'].employee,
        deliveryTypes = { "drugs" },
        deliveryType = "drugs",
        deliveryBlip = { label = "Drugs deliveries", sprite = 514, color = 66, scale = 0.3 },
        stash = { coords = vector3(1946.5460, 5183.5317, 47.9838), name = "delivery_meth_stash", label = "Meth Lab Employee Stash" },
        ownerstash = { coords = vector3(1948.7639, 5177.1821, 47.9838), name = "delivery_meth_owner_stash", label = "Meth Lab Owner Stash" },
        vehicle = {
            models = { ["xa21"] = true },
            spawn = { coords = vector3(1965.5411, 5175.0776, 47.4288), heading = 180.9558 },
            garage = { coords = vector3(1974.7562, 5168.1855, 47.2272) },
        },
        computer = {
            coords = vector3(1958.2317, 5179.4194, 47.9838),
            radius = 2.5,
            blip = { enable = false, label = "Meth Delivery", sprite = 521, color = 29, scale = 0.8, radius = 25.0 },
        },
        pickups = {
            { coords = vector3(1948.7548, 5177.1421, 47.9838), pickups = 2, count = 0, isDone = false, entity = nil },
        },
        process = {
            prepare = {
                coords = vector3(1953.3877, 5179.2207, 47.9838),
                label = "Meth Process",
                needItems = {
                    { name = "methylamine", amount = 2 },
                    { name = "ammonia",     amount = 2 },
                },
                rewardItem = "meth_tray",
                rewardAmount = 1
            },
            finish = {
                coords = vector3(1943.1429, 5182.8955, 47.9838),
                label = "Create Meth Baggy",
                needItems = {
                    { name = "empty_baggy", amount = 1 },
                    { name = "meth_tray",   amount = 1 },
                },
                rewardItem = "meth_baggy",
                rewardAmount = 1
            }
        },
        shop = {
            label = "Open Shop",
            coords = vector3(155.1258, -769.5474, 47.0769),
            stash = { coords = vector3(1958.3221, 5182.7183, 47.9838), name = "meth_shop_tray", inventory = 'delivery_meth_owner_stash' },
            heading = 206.0091,
            price = 250000,
            ped = {
                model = "a_m_y_latino_01",
                scenario = "WORLD_HUMAN_STAND_MOBILE",
            },
            items = {
                { name = "empty_baggy", price = 1 },
                { name = "cigarettebox", price = 25 },
                { name = "meth_baggy",  price = 300 },
            },
            blip = { enable = false, label = "Meth Lab Key Shop", sprite = 186, color = 29, scale = 0.8 },
        },
        zone = {
            name = 'zone_methlab',
            minZ = 40.863815307617,
            maxZ = 50.863815307617,
            vectors = {
                vector2(1936.3850097656, 5186.1533203125),
                vector2(1936.8778076172, 5165.9345703125),
                vector2(1969.4997558594, 5166.17578125),
                vector2(1969.2574462891, 5187.0405273438),
            },
        },
    },

}
