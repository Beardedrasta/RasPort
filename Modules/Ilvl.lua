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
local RP = RasPort
RP:AddModule("Ilvl", "Adds a ILvl display to tooltip and icon", function()
    if RP:IsDisabled("Ilvl") then
        return
    end

    -- API
    local _G = getfenv(0)
    local pairs, select = _G.pairs, _G.select

    local LV = RP.ItemLevel or {}
    RP.ItemLevel = LV

    local slots = {"HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot",
                   "WristSlot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot", "HandsSlot", "WaistSlot", "LegsSlot",
                   "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot"}

    --[[
    ################################################################
    #################           Equipment          #################
    ################################################################
    ]] --

    local function CreateButtonsText(frame)
        for _, slot in pairs(slots) do
            local button = _G[frame .. slot]
            button.t = button:CreateFontString(nil, "OVERLAY")
            button.t:SetFont(NumberFontNormal:GetFont())
            button.t:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 2)
            button.t:SetText("")
        end
    end

    local function UpdateButtonsText(frame)
        if frame == "Inspect" and not (InspectFrame and InspectFrame:IsShown()) then
            return
        end

        for _, slot in pairs(slots) do
            local id = GetInventorySlotInfo(slot)
            local item
            local text = _G[frame .. slot].t

            if frame == "Inspect" then
                item = GetInventoryItemLink("target", id)
            else
                item = GetInventoryItemLink("player", id)
            end

            if slot == "ShirtSlot" or slot == "TabardSlot" then
                text:SetText("")
            elseif item then
                local oldilevel = text:GetText()
                local ilevel = select(4, GetItemInfo(item))

                if ilevel then
                    if ilevel ~= oldilevel then
                        text:SetText("|cFFFFFF00" .. ilevel)
                    end
                else
                    text:SetText("")
                end
            else
                text:SetText("")
            end
        end
    end

    RP:RegisterForEvent("PLAYER_LOGIN", function()
        CreateButtonsText("Character")
        UpdateButtonsText("Character")
    end)

    RP:RegisterForEvent("PLAYER_EQUIPMENT_CHANGED", function()
        UpdateButtonsText("Character")
    end)

    RP:RegisterForEvent("PLAYER_TARGET_CHANGED", function()
        UpdateButtonsText("Inspect")
    end)

    RP:RegisterForEvent("ADDON_LOADED", function(_, name)
        if name == "Blizzard_InspectUI" then
            CreateButtonsText("Inspect")
            InspectFrame:HookScript("OnShow", function(self)
                UpdateButtonsText("Inspect")
            end)
        end
    end)

    --[[
    ################################################################
    #################           Tooltip            #################
    ################################################################
    ]] --

    local ceil = _G.math.ceil
    local UnitIsPlayer = UnitIsPlayer
    local GetInventoryItemID = GetInventoryItemID
    local GetInventorySlotInfo = GetInventorySlotInfo

    local function CalculateItemLevel(unit)
        if unit and UnitIsPlayer(unit) then
            local total, itn = 0, 0

            for i = 1, 18 do
                if i ~= 4 and i ~= 17 then
                    local sLink = GetInventoryItemLink(unit, i)
                    if sLink then
                        local _, _, _, iLevel, _, _, _, _ = GetItemInfo(sLink)
                        if iLevel and iLevel > 0 then
                            itn = itn + 1
                            total = total + iLevel
                        end
                    end
                end
            end
            return (total < 1 or itn < 1) and 0 or ceil(total / itn)
        end
    end

end)
