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
local RP = RasPort
RP:AddModule("ID", "Adds IDs to the ingame tooltips.", function()
    if RP:IsDisabled("ID") then return end

    -- Setup
    local IDs = {}
    RP.IDs = IDs
    LibStub("AceHook-3.0"):Embed(IDs)

    -- API
    local _G = getfenv(0)
    local select, pairs, match, find, format, strsub = _G.select, _G.pairs, _G.string.match, _G.string.find, _G.string.format, _G.string.sub
    local GetUnitName, UnitIsPlayer, UnitClass, UnitReaction = _G.GetUnitName, _G.UnitIsPlayer, _G.UnitClass, _G.UnitReaction
    local UnitAura, UnitBuff, UnitDebuff, GameTooltip, ItemRefTooltip = _G.UnitAura, _G.UnitBuff, _G.UnitDebuff, _G.GameTooltip, _G.ItemRefTooltip
    local classColors = _G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS

    --[[
    ################################################################
    #################           Functions          #################
    ################################################################
    ]]--

    local FACTION_BAR_COLOR = {
        [1] = {r = 217 / 255, g = 69 / 255, b = 69 / 255},
        [2] = {r = 217 / 255, g = 69 / 255, b = 69 / 255},
        [3] = {r = 217 / 255, g = 69 / 255, b = 69 / 255},
        [4] = {r = 217 / 255, g = 196 / 255, b = 92 / 255},
        [5] = {r = 84 / 255, g = 150 / 255, b = 84 / 255},
        [6] = {r = 84 / 255, g = 150 / 255, b = 84 / 255},
        [7] = {r = 84 / 255, g = 150 / 255, b = 84 / 255},
        [8] = {r = 84 / 255, g = 150 / 255, b = 84 / 255}
    }

    local function addLine(tooltip, left, right)
        tooltip:AddDoubleLine(left, right)
        tooltip:Show()
    end

    local function onTooltipSetSpell(tooltip)
        local _, id = tooltip:GetSpell()
        if id then
            addLine(tooltip, "Spell ID", id)
        else
            RP:Print("Spell ID not found.")
        end
    end

    local function RasPort_AddAuraSource(self, func, unit, index, filter)
        local srcUnit = select(8, func(unit, index, filter))
        if srcUnit then
            local src = GetUnitName(srcUnit, true)
            if srcUnit == "pet" or srcUnit == "vehicle" then
                local color = classColors[select(2, UnitClass("player"))]
                src = format("%s (|cff%02x%02x%02x%s|r)", src, color.r * 255, color.g * 255, color.b * 255, GetUnitName("player", true))
            else
                local partypet = match(srcUnit, "^partypet(%d+)$")
                local raidpet = match(srcUnit, "^raidpet(%d+)$")
                if partypet then
                    src = format("%s (%s)", src, GetUnitName("party" .. partypet, true))
                elseif raidpet then
                    src = format("%s (%s)", src, GetUnitName("raid" .. raidpet, true))
                end
            end
            if UnitIsPlayer(srcUnit) then
                local color = classColors[select(2, UnitClass(srcUnit))]
                if color then
                    src = format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, src)
                end
            else
                local color = FACTION_BAR_COLOR[UnitReaction(srcUnit, "player")]
                if color then
                    src = format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, src)
                end
            end
            self:AddLine(DONE_BY .. " " .. src)
            self:Show()
        end
    end

    RP:RegisterForEvent("PLAYER_ENTERING_WORLD", function()
        if not IDs:IsHooked(GameTooltip, "OnTooltipSetSpell") then
            IDs:HookScript(GameTooltip, "OnTooltipSetSpell", onTooltipSetSpell)
        end
        if not IDs:IsHooked(GameTooltip, "OnTooltipSetSpell") then
            IDs:HookScript(GameTooltip, "OnTooltipSetSpell", function(self)
                local id = select(3, self:GetSpell())
                if id then
                    addLine(self, "Spell ID", id)
                end
            end)
        end

        if not IDs:IsHooked(GameTooltip, "OnTooltipSetItem") then
            IDs:HookScript(GameTooltip, "OnTooltipSetItem", function(self)
                local _, itemlink = self:GetItem()
                if itemlink then
                    local _, itemid = strsplit(":", match(itemlink, "item[%-?%d:]+"))
                    addLine(self, "Item ID", itemid)
                end
            end)
        end

        if not IDs:IsHooked(GameTooltip, "SetUnitBuff") then
            IDs:SecureHook(GameTooltip, "SetUnitBuff", function(self, ...)
                RasPort_AddAuraSource(self, UnitBuff, ...)
                local id = select(11, UnitBuff(...))
                if id then
                    addLine(self, "Spell ID", id)
                end
            end)
        end

        if not IDs:IsHooked(GameTooltip, "SetUnitDebuff") then
            IDs:SecureHook(GameTooltip, "SetUnitDebuff", function(self, ...)
                RasPort_AddAuraSource(self, UnitDebuff, ...)
                local id = select(11, UnitDebuff(...))
                if id then
                    addLine(self, "Spell ID", id)
                end
            end)
        end

        if not IDs:IsHooked(GameTooltip, "SetUnitAura") then
            IDs:SecureHook(GameTooltip, "SetUnitAura", function(self, ...)
                RasPort_AddAuraSource(self, UnitAura, ...)
                local id = select(11, UnitAura(...))
                if id then
                    addLine(self, "Spell ID", id)
                end
            end)
        end

        if not IDs:IsHooked("SetItemRef") then
            IDs:SecureHook("SetItemRef", function(link, text, button, chatFrame)
                if find(link, "^spell:") or find(link, "^enchant:") then
                    local pos = find(link, ":") + 1
                    local id = strsub(link, pos)
                    if find(id, ":") then
                        pos = find(id, ":") - 1
                        id = id:sub(1, pos)
                    end
                    if id then
                        addLine(ItemRefTooltip, "Spell ID", id)
                    end
                elseif find(link, "^achievement:") then
                    local pos = find(link, ":") + 1
                    local endpos = find(link, ":", pos) - 1
                    if pos and endpos then
                        local id = strsub(link, pos, endpos)
                        if id then
                            addLine(ItemRefTooltip, "Achievement ID", id)
                        end
                    end
                elseif find(link, "^quest:") then
                    local pos = find(link, ":") + 1
                    local endpos = find(link, ":", pos) - 1
                    if pos and endpos then
                        local id = strsub(link, pos, endpos)
                        if id then
                            addLine(ItemRefTooltip, "Quest ID", id)
                        end
                    end
                elseif find(link, "^item:") then
                    local pos = find(link, ":") + 1
                    local endpos = find(link, ":", pos) - 1
                    if pos and endpos then
                        local id = strsub(link, pos, endpos)
                        if id then
                            addLine(ItemRefTooltip, "Item ID", id)
                        end
                    end
                end
            end)
        end
    end)

end)