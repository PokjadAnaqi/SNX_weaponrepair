Config = Config or {}

Config.Weapon = {
    progressbar = {
        duration = 25000, -- ms
    },

    marker = {
        enabled = true,
        type = 22,
        color = { r = 255, g = 0, b = 0, a = 200 },
        DrawDistance = 20,
    },

    blip = {
        enabled    = true,
        sprite     = 110,      -- wrench
        color      = 1,        -- red
        scale      = 0.8,
        shortRange = true,
        name       = 'Weapon Repair Station',
    },
    
    vipRepair = {
        enabled     = true,
        money       = 'money',       -- 'money' | 'bank' | 'black_money'
        money_label = 'Cash',
        discount    = 0,             -- % diskaun VIP
    },
    
    coords = {
        [1] = {
            coords      = vec3(523.93, 5519.69, 777.98),
            money       = 'money',
            money_label = 'Cash',
            target      = true, -- use ox_target
            bench = {
                enabled    = true,
                model      = `gr_prop_gr_bench_01a`, -- tukar ikut suka
                heading    = 91.80,
                offset     = vec3(0.0, 0.0, 0.0),
                freeze     = true,
                invincible = true,
            },
        },
        [2] = {
            coords      = vec3(1886.69, 3683.38, 33.75),
            money       = 'money',
            money_label = 'Cash',
            target      = true, -- fallback E + marker
            bench       = {                 
                enabled    = true,
                model      = `gr_prop_gr_bench_01a`, -- tukar ikut suka
                heading    = 210.51,
                offset     = vec3(0.0, 0.0, 0.0),
                freeze     = true,
                invincible = true,
            },
        },
        [3] = {
            coords      = vec3(-766.75, -1461.41, 5.02),
            money       = 'money',
            money_label = 'Cash',
            target      = true, -- fallback E + marker
            bench       = {                 
                enabled    = true,
                model      = `gr_prop_gr_bench_01a`, -- tukar ikut suka
                heading    = 319.75,
                offset     = vec3(0.0, 0.0, 0.0),
                freeze     = true,
                invincible = true,
            },            
        },
    },

    language = {
        HelpUI      = 'to open the repair station!',
        menu_title  = 'Weapon Repair Station',
        no_weapon   = 'You have no weapon in your hand',
        not_damaged = 'Your weapon [%s] cannot be repaired because it is not damaged!',
        cancelled   = 'You cancelled repairing your weapon [%s]!',
        repaired    = 'You repaired your weapon [%s] for %s %s!',
        not_enough  = 'You don’t have enough money! You are missing %s %s',
        error       = 'An error occurred!',
        city        = 'BLACKLINE CITY',
    }
}