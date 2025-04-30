local enableBlips = true

SV_Config.Dealers = {
    [1] = {
        labid = 1,
        enable = true,
        name = 'weed_dealer',
        label = "Weed Dealer",
        coords = vector3(-1174.1208, -1570.0919, 4.3953),
        heading = 301.4698,
        ped = { model = "g_m_y_lost_01", scenario = "WORLD_HUMAN_STAND_MOBILE" },
        inventory = "delivery_weed_owner_stash",
        items = { {name = "joint"}, {name = "weed_baggy"}, {name = "cigarettebox"} },
        blip = { enable = enableBlips, label = "Weed Dealer", sprite = 465, scale = 0.8, color = 38 },
    },
    [2] = {
        labid = 2,
        enable = true,
        name = 'coke_dealer',
        label = "Coke Dealer",
        coords = vector3(595.9880, -456.8961, 24.7449),
        heading = 2.2012,
        ped = { model = "g_m_y_lost_01", scenario = "WORLD_HUMAN_STAND_MOBILE" },
        inventory = "delivery_coke_owner_stash",
        items = { {name = "cigarettebox"}, {name = "coke_baggy"} },
        blip = { enable = enableBlips, label = "Coke Dealer", sprite = 465, scale = 0.8, color = 38 },
    },
    [3] = {
        labid = 3,
        enable = true,
        name = 'meth_dealer',
        label = "Meth Dealer",
        coords = vector3(106.4704, -1964.3954, 20.8775),
        heading = 270.8762,
        ped = { model = "g_m_y_lost_01", scenario = "WORLD_HUMAN_STAND_MOBILE" },
        inventory = "delivery_meth_owner_stash",
        items = { {name = "cigarettebox"}, {name = "meth_baggy"} },
        blip = { enable = enableBlips, label = "Meth Dealer", sprite = 465, scale = 0.8, color = 38 },
    }
}