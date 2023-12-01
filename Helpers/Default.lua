local RP = RasPort
local M, P, U, _ = RP:Unpack() -- m, p, u, c

-- Default Values
RP.defaults = {
    profile = {
        disabledModules = {
            ["Away"] = true,
            ["Info Bar"] = true,
            ["Actionbar"] = true,
            ["Theme"] = true,
            ["Money"] = true,
            ["Quick Load"] = true,
            ["ID"] = true,
            ["Grid"] = true,
            ["Auto"] = true,
            ["Ammo"] = true,
            ["Unitframe"] = true,
            ["Copy Pasta"] = true,
            ["Ilvl"] = true,
            ["Minimap"] = false,
        },
        ["Class"] = true,
        ["Blackout"] = false,
        ["Custom Color"] = false,
        ["Minimap Button"] = true,
        ["CC"] = {
            red = 0,
            green = 0,
            blue = 0
        },
        ["Panel Scale"] = 1,
        info = {
            enabled = true,
            ["12-Hour"] = true,
            ["Mail Sound"] = "RasPort",
            ["Font"] = "Friz Quadrata TT",
            ["Class"] = true,
            ["Custom Color"] = false,
            ["Primary Color"] = {
                red = 1,
                green = 0.81960791349411,
                blue = 0
            },
            ["Mail Color"] = {
                red = 0.251,
                green = 0.878,
                blue = 0.816
            }
        },
        actionbar = {
            enabled = true,
            ["Hide Gryphons"] = true,
            ["Keybinds"] = 1,
            ["Bottom Actionbars"] = false,
            ["Side Actionbars"] = false,
            ["Hide Bags"] = true,
            ["Reduced"] = true,
            ["One Bag"] = true,
            buttons = {
                key = true,
                ["Out of Range"] = true,
                size = 12
            },
            menu = {
                mouseovermicro = true,
                mouseoverbags = true,
                size = 0.8
            },
            bars = {
                bar1 = true,
                bar2 = false,
                bar3 = false,
                bar4 = false,
                bar5 = false,
                bar6 = false,
                bar7 = false,
                bar8 = false,
                petbar = false,
                stancebar = false
            }
        },
        theme = {
            enabled = true,
            ["Scale"] = 1
        },
        money = {
            enabled = true,
            ["Font"] = "Friz Quadrata TT"
        },
        auto = {
            enabled = true,
            ["Decline Duels"] = true,
            ["Sell Junk"] = true,
            ["Grey Items"] = true,
            ["White Items"] = false,
            ["Green Items"] = false,
            ["Blue Items"] = false,
            ["Repair Equipment"] = true,
            excludedItems = {},
            ["Insert Delete"] = true,
        },
        unitframe = {
            enabled = true,
            ["Improved"] = true,
            ["Font"] = "Friz Quadrata TT",
            ["Font Size"] = 10,
            ["Font Outline"] = "OUTLINE",
            ["Texture"] = "RasPort - Smooth",
            ["Hide Level"] = false,
            ["Portrait"] = false,
            ["Hide Indicator"] = true,
            ["Friendly"] = {
                red = 0,
                green = 0.7,
                blue = 0,
                alpha = 1
            },
            ["Hostile"] = {
                red = 0.7,
                green = 0,
                blue = 0,
                alpha = 1
            },
            ["Neutral"] = {
                red = 0.7,
                green = 0.7,
                blue = 0,
                alpha = 1
            },
            ["Buff Size"] = 25,
            ["Debuff Size"] = 25,
            ["Buffs Cast by Me"] = true

        },
        minimap = {
            enabled = true,
            ["Date"] = true,
            ["Tracking"] = true,
            ["Clock"] = true,
            ["Mail"] = true,
            ["grabber"] = true,
            locked = true,
            zone = false,
            scale = 1,
            combat = false,
            moved = false,
            point = "TOPRIGHT",
            x = 0,
            y = 0
        }
    }
}
