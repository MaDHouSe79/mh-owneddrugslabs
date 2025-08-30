--[[ if you change something wrong here the script will brake. ]]

SV_Config.Storeage = {

    ['ignus'] = {
        prop = "prop_coke_block_01",                 -- used prop 
        discription = "Job: Deliver 2 coke blocks.", -- menu discription
        deliveryType = "drugs",                      -- delivery type
        deliverItem = nil,                           -- delivery item is always nil here.
        maxCapacity = 2,                             -- max trunk space
        maxDisplay = 3,                              -- max display props in trunk
        trunkPos = 2.8,                              -- trunk poition to open the trunk
        doors = 5,                                   -- doors can be a number or a table like {3, 4} this is door 3 and 4 if you set only one number like 4 it use it as a number.
        storages = {                                 -- storage prop locations (don't edit this)
            [1] = { coords = vector3(0.10, 2.1, 0.2), rotation = vector3(0.0, 0.0, 90.0), loaded = false, entity = nil, visable = false },  -- don't edit this
            [2] = { coords = vector3(-0.25, 2.1, 0.2), rotation = vector3(0.0, 0.0, 90.0), loaded = false, entity = nil, visable = false }, -- don't edit this
        },
    },

    ['adder'] = {
        prop = "bkr_prop_weed_bigbag_01a",
        discription = "Job: Deliver 2 weed blocks.",
        deliveryType = "drugs",
        deliverItem = nil,
        maxCapacity = 2,
        maxDisplay = 2,
        trunkPos = 2.0,
        doors = 4,
        storages = {
            [1] = { coords = vector3(0.24, 1.5, 0.05), rotation = vector3(0.0, 0.0, 90.0), loaded = false, entity = nil, visable = false },
            [2] = { coords = vector3(-0.24, 1.5, 0.05), rotation = vector3(0.0, 0.0, 90.0), loaded = false, entity = nil, visable = false },
        },
    },

    ['xa21'] = {
        prop = "prop_meth_bag_01",
        discription = "Job: Deliver 10 meth bags.",
        deliveryType = "drugs",
        deliverItem = nil,
        maxCapacity = 10,
        maxDisplay = 3,
        trunkPos = 2.0,
        doors = 4,
        storages = {
            [1] = { coords = vector3(0.15, 1.80, 0.20), rotation = vector3(89.0, 0.0, 0.0), loaded = false, entity = nil, visable = false },
            [2] = { coords = vector3(-0.15, 1.80, 0.20), rotation = vector3(89.0, 0.0, 0.0), loaded = false, entity = nil, visable = false },
            [3] = { coords = vector3(0.15, 1.80, 0.20), rotation = vector3(89.0, 0.0, 0.0), loaded = false, entity = nil, visable = false },
            [4] = { coords = vector3(-0.15, 1.80, 0.20), rotation = vector3(89.0, 0.0, 0.0), loaded = false, entity = nil, visable = false },
            [5] = { coords = vector3(0.15, 1.08, 0.20), rotation = vector3(89.0, 0.0, 0.0), loaded = false, entity = nil, visable = false },
            [6] = { coords = vector3(-0.15, 1.80, 0.20), rotation = vector3(89.0, 0.0, 0.0), loaded = false, entity = nil, visable = false },
            [7] = { coords = vector3(0.15, 1.80, 0.20), rotation = vector3(89.0, 0.0, 0.0), loaded = false, entity = nil, visable = false },
            [8] = { coords = vector3(-0.15, 1.80, 0.20), rotation = vector3(89.0, 0.0, 0.0), loaded = false, entity = nil, visable = false },
            [9] = { coords = vector3(0.15, 1.80, 0.20), rotation = vector3(89.0, 0.0, 0.0), loaded = false, entity = nil, visable = false },
            [10] = { coords = vector3(-0.15, 1.80, 0.20), rotation = vector3(89.0, 0.0, 0.0), loaded = false, entity = nil, visable = false },
        },
    },
}