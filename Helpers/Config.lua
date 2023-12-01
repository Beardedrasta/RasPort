local RP = RasPort
local M, P, U, _ = RP:Unpack() -- m, p, u, c
local Window = LibStub("LibWindow-1.1")

local _G = getfenv(0)
local format = _G.string.format
local off
local L = U.L

RP.changelog = [=[
v1.5.0
	Organized settings.
    Organized addon folder.

v1.4.9
	Improved and remodeled config options.
	Added Minimap Module. *Temporarily Disabled to fix*
	Fixed several bugs.
	Cleaned up script functionality.
]=]

RP.COL_HEX = {

    [1] = "|cff99cdff",
    [2] = "|cff0291b0",
    [5] = "|cff7bbb4e",
    [11] = "|cff99cdff",

    [321076] = "|cff2aa2ff",
    [321079] = "|cffe40d0d",
    [321077] = "|cff80b5fd",
    [321078] = "|cff17c864",

    ["PERFORMANCE_BLUE"] = "|cff99cdff",
    ["MINT"] = "|cff99ffcd",
    ["CURSE_ORANGE"] = "|cfff16436",
    ["TWITCH_PURPLE"] = "|cff9146ff",
    ["RED"] = "|cffc10003",
    ["MAROON"] = "|cff69000b",
    ["NORMAL_FONT"] = "|cffffd200",
    ["HIGHLIGHT_FONT"] = "|cffffffff",
    ["RED_FONT"] = "|cffff2020",
    ["GREEN_FONT"] = "|cff20ff20",
    ["GRAY_FONT"] = "|cff808080",
    ["YELLOW_FONT"] = "|cffffff00",
    ["LIGHTYELLOW_FONT"] = "|cffffff9a",
    ["ORANGE_FONT"] = "|cffff7f3f",
    ["ACHIEVEMENT"] = "|cffffff00",
    ["BATTLENET_FONT"] = "|cff82c5ff",
    ["DISABLED_FONT"] = "|cff7f7f7f",
    ["CLOSE"] = "|r"
}

local isFound
local changelog = RP.changelog:gsub("^[ \t\n]*", RP.COL_HEX["ORANGE_FONT"]):gsub("\n\nv([%d%.]+)", function(ver)
    if not isFound and ver ~= M.Version then
        isFound = true
        return "|cff808080\n\nv" .. ver
    end
end):gsub("\t", "\32\32\32\32\32\32\32\32")

local fieldText = {}

do
    local localization = M.Localizations
    localization = localization:gsub("enUS", ENUS):gsub("esMX", ESMX):gsub("frFR", FRFR)

    fieldText.localizations = localization
end

local getFieldText = function(info)
    local key = info[#info]
    return M[key] or fieldText[key] or ""
end

do
    local function initializeOptions()
        if not RP.options then
            RP.options = {
                name = "RasPort",
                handler = RP,
                type = "group",
                args = {
                    minusScale = {
                        disabled = function()
                            return RP.db.profile["Panel Scale"] < 0.84
                        end,
                        image = "Interface\\AddOns\\RasPort\\Media\\Config\\rasport-resizer.tga",
                        imageWidth = 18,
                        imageHeight = 18,
                        name = "",
                        order = 0,
                        type = "execute",
                        func = function()
                            local currScale = RP.db.profile["Panel Scale"]
                            if currScale > 0.84 then
                                currScale = currScale - 0.05
                                RP.db.profile["Panel Scale"] = currScale
                                RP.UI.ACD:SetDefaultSize("RasPort", nil, nil, currScale)
                            end
                        end,
                        width = 0.15
                    },
                    currScale = {
                        name = function()
                            return format("%s%%", RP.db.profile["Panel Scale"] * 100)
                        end,
                        order = 1,
                        type = "description",
                        width = 0.3,
                        justifyH = "CENTER"
                    },
                    plusScale = {
                        disabled = function()
                            return RP.db.profile["Panel Scale"] == 1.5
                        end,
                        image = "Interface\\AddOns\\RasPort\\Media\\Config\\plus.tga",
                        imageWidth = 18,
                        imageHeight = 18,
                        name = "",
                        order = 2,
                        type = "execute",
                        func = function()
                            local currScale = RP.db.profile["Panel Scale"]
                            if currScale < 1.46 then
                                currScale = currScale + 0.05
                                RP.db.profile["Panel Scale"] = currScale
                                RP.UI.ACD:SetDefaultSize("RasPort", nil, nil, currScale)
                            end
                        end,
                        width = 0.15
                    },
                    discord = {
                        type = "execute",
                        name = format("|T%s:32|t %s", RP.Meta.disc, "Discord"),
                        order = 3,
                        dialogControl = "Button-RasPort",
                        func = function()
                            local AceGUI = LibStub("AceGUI-3.0")
                            local dialog = AceGUI:Create("Frame-RasPort")
                            dialog:SetTitle("")
                            dialog:SetLayout("Fill")
                            dialog:SetCallback("OnClose", function(widget)
                                AceGUI:Release(widget)
                            end)
                            dialog:SetWidth(300)
                            dialog:SetHeight(100)

                            local editbox = AceGUI:Create("EditBox")
                            editbox:SetLabel("Discord")
                            editbox:SetText("https://discord.gg/As3tA2nS6A") -- Use the popup text
                            editbox:SetFullWidth(true)
                            dialog:AddChild(editbox)
                        end
                    },
                    info = {
                        name = format("|T%s:18|t %s", RP.Meta.logo, "RasPort"), --    format("|TInterface\\AddOns\\RasPort\\Media\\Minimap\\icon2:25:25|t".."%s", RP.version),
                        order = 5,
                        type = "group",
                        childGroups = "tab",
                        get = function(info)
                            return RP.db.profile[info[#info]]
                        end,
                        set = function(info, value)
                            RP.db.profile[info[#info]] = value
                        end,
                        args = {
                            title = {
                                image = RP.Meta.logo,
                                imageWidth = 64,
                                imageHeight = 64,
                                imageCoords = {0, 1, 0, 1},
                                name = "RasPort",
                                order = 0,
                                type = "description",
                                fontSize = "large"
                            },
                            sep1 = {
                                name = "\n\n",
                                order = 1,
                                type = "description"
                            },
                            Version = {
                                name = L["Version"],
                                order = 2,
                                type = "input",
                                dialogControl = "Info-RasPort",
                                get = getFieldText
                            },
                            Author = {
                                name = L["Author"],
                                order = 3,
                                type = "input",
                                dialogControl = "Info-RasPort",
                                get = getFieldText
                            },
                            sep2 = {
                                name = "\n\n",
                                order = 10,
                                type = "description"
                            },
                            localizations = {
                                name = LANGUAGES_LABEL,
                                order = 5,
                                type = "input",
                                dialogControl = "Info-RasPort",
                                get = getFieldText
                            },
                            sep4 = {
                                name = " ",
                                order = 17,
                                type = "description"
                            },
                            minimap = {
                                order = 18,
                                type = "toggle",
                                name = L["Show Minimap Icon"],
                                desc = "Toggle the display of the minimap icon",
                                get = function()
                                    return not RP.db["Minimap Button"]
                                end,
                                set = function(_, value)
                                    RP.db["Minimap Button"] = not value
                                    if value then
                                        U.Icon:Show("RasPort")
                                    else
                                        U.Icon:Hide("RasPort")
                                    end
                                end
                            },
                            sep5 = {
                                name = "\n",
                                order = 19,
                                type = "description"
                            },
                            reminder = {
                                image = "Interface\\AddOns\\RasPort\\Media\\lime-notif.tga",
                                imageWidth = 32,
                                imageHeight = 16,
                                imageCoords = {0, 1, 0, 1},
                                name = " ",
                                order = 20,
                                type = "description",
                                width = "full"
                            },
                            notice1 = {
                                name = format("|cff7FE817* %s", (L["Most issues can be solved with a simple /reload!"])),
                                order = 21,
                                type = "description",
                                justifyH = "LEFT"
                            },
                            sep6 = {
                                name = "\n\n",
                                order = 22,
                                type = "description"
                            },
                            changelog = {
                                name = L["Changelog"],
                                order = 20,
                                type = "group",
                                args = {
                                    lb1 = {
                                        name = "\n",
                                        order = 0,
                                        type = "description"
                                    },
                                    changelog = {
                                        name = changelog,
                                        order = 1,
                                        type = "description"
                                    }
                                }
                            },
                            slash = {
                                name = L["Slash Commands"],
                                order = 30,
                                type = "group",
                                args = {
                                    t1 = {
                                        name = L["Usage:"],
                                        order = 1,
                                        type = "description"
                                    },
                                    t2 = {
                                        name = "/rp <command>",
                                        order = 2,
                                        type = "description"
                                    },
                                    t3 = {
                                        name = "\n\n",
                                        order = 3,
                                        type = "description"
                                    },
                                    t4 = {
                                        name = L["Commands:"],
                                        order = 4,
                                        type = "description"
                                    },
                                    theme = {
                                        name = "/rp theme:",
                                        order = 5,
                                        type = "input",
                                        dialogControl = "Info-RasPort",
                                        get = function()
                                            return L["Open the theme selection."]
                                        end
                                    },
                                    info = {
                                        name = "/rp info:",
                                        order = 6,
                                        type = "input",
                                        dialogControl = "Info-RasPort",
                                        get = function()
                                            return L["Open Info bar config options."]
                                        end
                                    },
                                    action = {
                                        name = "/rp action:",
                                        order = 7,
                                        type = "input",
                                        dialogControl = "Info-RasPort",
                                        get = function()
                                            return L["Open Actionbar config options."]
                                        end
                                    },
                                    currency = {
                                        name = "/rp cash:",
                                        order = 8,
                                        type = "input",
                                        dialogControl = "Info-RasPort",
                                        get = function()
                                            return L["Open Currency config options."]
                                        end
                                    },
                                    auto = {
                                        name = "/rp auto:",
                                        order = 9,
                                        type = "input",
                                        dialogControl = "Info-RasPort",
                                        get = function()
                                            return L["Open Automation options."]
                                        end
                                    },
                                    unitframe = {
                                        name = "/rp uf:",
                                        order = 10,
                                        type = "input",
                                        dialogControl = "Info-RasPort",
                                        get = function()
                                            return L["Display Unitframe commands in chat window."]
                                        end
                                    },
                                    resetDB = {
                                        name = "/rp reset:",
                                        order = 12,
                                        type = "input",
                                        dialogControl = "Info-RasPort",
                                        get = function()
                                            return
                                                L["Clean wipe the savedvariable file. |cffff2020Warning|r: This can not be undone!"]
                                        end
                                    }
                                }
                            }
                        }
                    },
                    Options = {
                        type = "group",
                        name = "Options",
                        order = 6,
                        hidden = function()
                            return (off == #RP.modulesList)
                        end,
                        args = {}
                    },
                    Modules = {
                        type = "group",
                        name = "Modules",
                        order = 7,
                        width = "full",
                        args = {
                            apply = {
                                type = "execute",
                                name = APPLY,
                                order = 1,
                                width = "full",
                                disabled = true,
                                confirm = function()
                                    return "This change requires a UI reload. Are you sure?"
                                end,
                                func = function()
                                    ReloadUI()
                                end
                            },
                            list = {
                                type = "group",
                                name = "Tick the modules you want to enable.",
                                order = 2,
                                inline = true,
                                args = {}
                            }
                        }
                    }
                }
            }
        end
        return RP.options
    end
    initializeOptions()

    -- Register the options table
    U.Config:RegisterOptionsTable("RasPort", RP.options)

    -- Add it to Blizzard's Interface Options
    U.ACD:AddToBlizOptions("RasPort", "RasPort")
end
