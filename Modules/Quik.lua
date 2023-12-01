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
]]--
local folder, RP = ..., RasPort
RP:AddModule("Quik Load", "Disables certain events during loading screens to improve loading times.", function()
    if RP:IsDisabled("Quik Load") then return end

    local _G = getfenv(0)
    local pairs, wipe, select, pcall = _G.pairs, _G.wipe, _G.select, _G.pcall
    local getmetatable, geterrorhandler = _G.getmetatable, _G.geterrorhandler
    local GetFramesRegisteredForEvent = _G.GetFramesRegisteredForEvent
    local issecurevariable, hooksecurefunc = _G.issecurevariable, _G.hooksecurefunc

    local enteredOnce, listenForUnreg
    local occured, list = {}
    local events = {
        SPELLS_CHANGED = {},
        USE_GLYPH = {},
        PET_TALENT_UPDATE = {},
        PLAYER_TALENT_UPDATE = {},
        WORLD_MAP_UPDATE = {},
        UPDATE_WORLD_STATES = {},
        CRITERIA_UPDATE = {},
        RECEIVED_ACHIEVEMENT_LIST = {},
        ACTIONBAR_SLOT_CHANGED = {},
        SPELL_UPDATE_USABLE = {},
        UPDATE_FACTION = {}
    }

    local Quik = CreateFrame("Frame")
    Quik:RegisterEvent("ADDON_LOADED")

    local validUnregisterFuncs = {[Quik.UnregisterEvent] = true}

    local function SpeedyLoad_IsValidUnregisterFunc(tbl, func)
        if not func then return false end
        local valid = issecurevariable(tbl, "UnregisterEvent")
        if not validUnregisterFuncs[func] then
            validUnregisterFuncs[func] = not (not valid)
        end
        return valid
    end

    local function SpeedyLoad_Unregister(event, ...)
        for i = 1, select("#", ...) do
            local frame = select(i, ...)
            local UnregisterEvent = frame.UnregisterEvent

            if validUnregisterFuncs[UnregisterEvent] or SpeedyLoad_IsValidUnregisterFunc(frame, UnregisterEvent) then
                UnregisterEvent(frame, event)
                events[event][frame] = 1
            end
        end
    end

    local function EventHandler(self, event, ...)
        if event == "ADDON_LOADED" then
            local name = ...
            if name:lower() == folder:lower() then
                Quik:UnregisterEvent("ADDON_LOADED")

                list = {GetFramesRegisteredForEvent("PLAYER_ENTERING_WORLD")}
                for i, frame in ipairs(list) do
                    frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
                end

                Quik:RegisterEvent("PLAYER_ENTERING_WORLD")
                for i, frame in ipairs(list) do
                    if frame then
                        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
                    end
                end
                wipe(list)
                list = nil

                if PetStableFrame then
                    PetStableFrame:UnregisterEvent("SPELLS_CHANGED")
                end
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            if not enteredOnce then
                Quik:RegisterEvent("PLAYER_LEAVING_WORLD")
                hooksecurefunc(getmetatable(Quik).__index, "UnregisterEvent", function(frame, event)
                    if listenForUnreg then
                        local frames = events[event]
                        if frames then
                            frames[frame] = nil
                        end
                    end
                end)
                enteredOnce = 1
            else
                listenForUnreg = nil
                for e, frames in pairs(events) do
                    for frame in pairs(frames) do
                        frame:RegisterEvent(e)
                        local OnEvent = occured[e] and frame:GetScript("OnEvent")
                        if OnEvent then
                            local arg1 = (e == "ACTIONBAR_SLOT_CHANGED") and 0 or nil

                            local success, err = pcall(OnEvent, frame, e, arg1)
                            if not success then
                                geterrorhandler()(err, 1)
                            end
                        end
                        frames[frame] = nil
                    end
                end
                wipe(occured)
            end
        elseif event == "PLAYER_LEAVING_WORLD" then
            wipe(occured)
            for e in pairs(events) do
                SpeedyLoad_Unregister(e, GetFramesRegisteredForEvent(e))
                Quik:RegisterEvent(e)
            end
            listenForUnreg = 1
        else
            occured[event] = 1
            Quik:UnregisterEvent(event)
        end
    end
    Quik:SetScript("OnEvent", EventHandler)
end)