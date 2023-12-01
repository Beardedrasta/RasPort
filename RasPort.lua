--[[
###########################################################################
#  ___/\\\\\\\\\\____/\\\\\\\\\\___/\\\________/\\\__/\\\\\\\\\\\_______  #
#  ___\/\\\_____\\\__\/\\\_____\\\_\/\\\_______\/\\\_\/////\\\///_______  #
#  ____\/\\\_____\\\__\/\\\_____\\\_\/\\\_______\/\\\_____\/\\\_________  #
#  _____\/\\\____\\\___\/\\\____\\\__\/\\\_______\/\\\_____\/\\\________  #
#  ______\/\\\\\\\\\____\/\\\\\\\\____\/\\\_______\/\\\_____\/\\\_______  #
#  _______\/\\\__\/\\\___\/\\\_________\/\\\_______\/\\\_____\/\\\______  #
#  ________\/\\\__\/\\\___\/\\\_________\//\\\______/\\\______\/\\\_____  #
#  _________\/\\\__\/\\\___\/\\\_________\///\\\\\\\\\/____/\\\\\\\\\\\_  #
#  __________\///___\///____\///____________\/////////_____\///////////_  #
###########################################################################
#                  Rasta - Port - UI   By: Beardedrasta                   #
###########################################################################
]] --
local addon, RP = ...
RP = LibStub("AceAddon-3.0"):NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0")
RP.callbacks = RP.callbacks or LibStub("CallbackHandler-1.0"):New(RP)

-- Lua APIs
local _G = getfenv(0)
local format = _G.string.format
local select = _G.select

-- WoW APIs
local UnitClass = _G.UnitClass
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetPhysicalScreenSize = _G.GetPhysicalScreenSize
local PlaySound = _G.PlaySound
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
-- My API
RP.Meta = {
    Title = GetAddOnMetadata(addon, "Title"),
    logo = [[Interface\AddOns\RasPort\Media\Logo\logo-new]],
    disc = [[Interface\AddOns\RasPort\Media\Logo\disc]],
    Version = GetAddOnMetadata(addon, "Version"),
    Author = GetAddOnMetadata(addon, "Author"),
    Notes = GetAddOnMetadata(addon, "Notes"),
    License = GetAddOnMetadata(addon, "X-License"),
    Localizations = GetAddOnMetadata(addon, "X-Localizations")
    -- Other metadata...
}

RP.Player = {
    userName = UnitName("player"),
    userClass = select(2, UnitClass("player")),
    userRace = select(2, UnitRace("player")),
    userLevel = UnitLevel("player"),
    userFaction = UnitFactionGroup("player"),
    userClassColorHex = "|c" .. select(4, GetClassColor(RP.userClass)),
    userClassColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
    -- Other user-related data...
}
RP.UI = {
    Config = LibStub("AceConfig-3.0"),
    GUI = LibStub("AceGUI-3.0"),
    ACD = LibStub("AceConfigDialog-3.0-RasPort"),
    ACR = LibStub("AceConfigRegistry-3.0"),
    LSM = LibStub("LibSharedMedia-3.0"),
    Icon = LibStub("LibDBIcon-1.0"),
    L = LibStub("AceLocale-3.0"):GetLocale(addon),
    RPUI = LibStub("RPUI")
}
RP.Color = {
    BLUE_COLOR = CreateColor(0.0, 0.4392, 0.8706),
    TURQ_COLOR = CreateColor(0.251, 0.878, 0.816),
    GOLD_COLOR = CreateColor(1, 0.81960791349411, 0, 1),
    RED_COLOR = CreateColor(0.6, 0.1, 0.1)
}
RP.WoWPatch, RP.WoWBuild, RP.WoWPatchReleaseDate, RP.TocVersion = GetBuildInfo()
RP.changelog = RP.changelog or {}

_G.RasPort = RP

function RP:Unpack()
    return self.Meta, self.Player, self.UI, self.Color
end

-- Core

function RP:Refresh()
    db = RP
end

function RP:OnInitialize()
    -- self.db = LibStub("AceDB-3.0"):New("RasPortDB", defaults, true)
    self.db = LibStub("AceDB-3.0"):New("RasPortDB", RP.defaults, true)

    RP.options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    RP.options.args.profile.order = 10

    local rl = function()
        ReloadUI()
    end
    self.db.RegisterCallback(self, "OnProfileChanged", rl)
    self.db.RegisterCallback(self, "OnProfileCopied", rl)
    self.db.RegisterCallback(self, "OnProfileReset", rl)

    self.UI.Icon:Register("RasPort", RP.RasPortLDB, self.db["Minimap Button"])

    RP:MediaRegister("statusbar", "RasPort", [[Interface\Addons\RasPort\Media\Statusbar\Default]])
    RP:MediaRegister("statusbar", "RasPort - Gloss", [[Interface\Addons\RasPort\Media\Statusbar\Gloss]])
    RP:MediaRegister("statusbar", "RasPort - Smooth", [[Interface\Addons\RasPort\Media\Statusbar\Smooth]])
    RP:MediaRegister("font", "RasPort", [[Interface\Addons\RasPort\Media\Font\!Title]])
    RP:MediaRegister("sound", "RasPort", [[Interface\Addons\RasPort\Media\Sound\mail.ogg]])

    RP:Print(" loaded. use |cffff6347/|r|cffffd700rp|r to access options.")

    if self.modulesList then
        for i = 1, #self.modulesList do
            self.modulesList[i](self.UI.L, addon)
        end
    end

    SLASH_RASPORT1 = "/rp"
    SLASH_RASPORT2 = "/rasport"
    SlashCmdList["RASPORT"] = function(cmd)
        cmd = cmd and cmd:lower()
        if cmd == "help" then
            RP:Print(format(L["Acceptable commands for: |caaf49141/%s|r"], L["rp"]))
            print(L["/rp mm |caaf49141- enables the minimap button if its been hidden|r"])
            print(L["/rp theme |caaf49141- opens theme selection|r"])
            print(L["/rp info |caaf49141- opens info bar config|r"])
            print(L["/rp action |caaf49141- opens action bar config |r"])
            print(L["/rp cash |caaf49141- opens currency config |r"])
            print(L["/rp auto |caaf49141- opens automation config |r"])
            print(L["/rp uf |caaf49141- displays list of unit frame commands |r"])
            print(L["/rp about |caaf49141- short message about addon |r"])
        elseif cmd == "theme" then
            RP:OpenConfig("Options", "Theme")
        elseif cmd == "info" then 
            RP:OpenConfig("Options", "info")
        elseif cmd == "action" then
            RP:OpenConfig("Options", "Actionbar")
        elseif cmd == "cash" then
            RP:OpenConfig("Options", "Money")
        elseif cmd == "auto" then
            RP:OpenConfig("Options", "Auto")
        elseif cmd == "mm" then
            RP.db["Minimap Button"] = true
            self.UI.Icon:Show("RasPort")
        elseif cmd == "about" or cmd == "info" then
            RP:Print("This small addon was made by Beardedrasta.\n If you have suggestions or you are facing issues with my addons, feel free to message me on discord, or Github.")
        elseif cmd == "reinstall" or cmd == "default" then
            wipe(RasPortDB)
            ReloadUI()
        elseif cmd == "uf" then
            RP:Print(L["Acceptable commands for: |caaf49141 /uf"])
            local helpStr = "|cffffd700%s|r: %s"
            print(helpStr:format("style, improve", "Enables improved unit frames textures."))
            print(helpStr:format("config", "Access module settings."))
        elseif cmd == "style" or cmd == "improve" then
            RP.db.profile.unitframe["Improved"] = not RP.db.profile.unitframe["Improved"]
            ReloadUI()
        elseif cmd == "config" or cmd == "options" then
            RP:OpenConfig("Options", "Unitframe")
        else
            RP:OpenConfig("Options", "RasPort")
        end
    end
end
