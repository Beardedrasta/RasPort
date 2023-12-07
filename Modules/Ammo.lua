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
local _, _, U, _ = RP:Unpack() -- m, p, u, c
RP:AddModule("Ammo", "A tidy little QOL ammunition tracker", function(L)
    if RP:IsDisabled("Ammo") then return end

    -- API
    local _G = getfenv(0)
    local CreateFrame = _G.CreateFrame
    local insert = _G.table.insert
    local pairs = _G.pairs
    local pi, sin = _G.math.pi, _G.math.sin
    local find, lower = _G.string.find, _G.string.lower


    --[[
    ################################################################
    #################           Functions          #################
    ################################################################
    ]]--

    local function IsPlayerRogueWarriorOrHunter()
        local _, playerClass = UnitClass("player")
        return playerClass == "HUNTER"
    end

    if IsPlayerRogueWarriorOrHunter() then
        local frame
        local ammoText
        local ammoStatusBar
        local ammoIcon
        local ammoSlotId = 0;
        local c = RAID_CLASS_COLORS[select(2, UnitClass("player"))]


        local function IsAmmoBag(bagId)
            local bagName = C_Container.GetBagName(bagId)

            if bagName then
                local _, _, _, _, _, itemType = GetItemInfo(bagName)
                if itemType and find(lower(itemType), "quiver") then
                    return true
                end
            end
            return false
        end

        local function GetAmmoMaxCapacity()
            local numSlots = 0;
            local maxCapacity = 0;

            for bagId = 1, 4 do
                if IsAmmoBag(bagId) then
                    numSlots = numSlots + C_Container.GetContainerNumSlots(bagId)
                end
            end

            local itemId = GetInventoryItemID("player", 0)
            if itemId then
                local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(itemId)
                if not itemStackCount then
                    itemStackCount = 0
                end
                maxCapacity = numSlots * itemStackCount
            end

            if maxCapacity == 0 then
                return 1000
            else
                return maxCapacity
            end
        end

        local maxAmmo = GetAmmoMaxCapacity()
        local thresh = (maxAmmo / 6)
        local redThresh = thresh * 1;
        local dOrangeLowThresh = thresh * 1;
        local dOrangeHighThresh = thresh * 2;
        local lOrangeLowThresh = thresh * 2;
        local lOrangeHighThresh = thresh * 3;
        local yellowLowThresh = thresh * 3;
        local yellowHighThresh = thresh * 4;
        local lLimeLowThresh = thresh * 4;
        local lLimeHighThresh = thresh * 5;
        local greenLowThresh = thresh * 5;
        local greenHighThresh = thresh * 6;
        local RASCOLOR = {0, 0, 0, 1}

        local function ApplyVertexColorToFrame(frame)
            local profile = RP.db.profile
            if profile["Class"] then
                frame:SetBackdropBorderColor(c.r, c.g, c.b, 1)
            elseif profile["Blackout"] then
                frame:SetBackdropBorderColor(0.15, 0.15, 0.15, 1)
            elseif profile["Custom Color"] then
                local customColor = profile["CC"]
                frame:SetBackdropBorderColor(customColor.red, customColor.green, customColor.blue, 1)
            else
                frame:SetBackdropBorderColor(1, 1, 1, 1)
            end
        end

        if not frame then
            frame = CreateFrame("Frame", "AmmoAmount", RasPortGoldAddonFrame,"BackdropTemplate")
            frame:SetSize(105, 50)
            frame:SetPoint("BOTTOM",RasPortGoldAddonFrame, "TOP", -15, -5)
            frame:SetFrameStrata("HIGH")
            frame:SetBackdrop({
                bgFile = "Interface\\HELPFRAME\\DarkSandstone-Tile", "REPEAT", "REPEAT",
                edgeFile = "Interface\\AddOns\\RasPort\\Media\\Border\\border-modified.tga",
                tile = false,
                edgeSize = 10,
                insets = {
                    left = 2,
                    right = 2,
                    top = 2,
                    bottom = 2
                }
            })
            frame:SetBackdropColor(1, 0.15, 0.15, 1)
            ApplyVertexColorToFrame(frame)

            ammoText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            ammoText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
            ammoText:SetPoint("CENTER", 0, 13)

            ammoStatusBar = CreateFrame("StatusBar", "AmmoAmountStatusBar", frame)
            ammoStatusBar:SetSize(100, 20)
            ammoStatusBar:SetPoint("CENTER", 10, -8)
            ammoStatusBar:SetStatusBarTexture(U.LSM:Fetch("statusbar", "Default"))

            ammoIcon = frame:CreateTexture(nil, "OVERLAY")
            ammoIcon:SetSize(20, 20)
            ammoIcon:SetPoint("LEFT", ammoStatusBar, -20, 0)

            local statusBarBackground = ammoStatusBar:CreateTexture(nil, "BACKGROUND")
            statusBarBackground:SetAllPoints(ammoStatusBar)
            statusBarBackground:SetColorTexture(0.1, 0.1, 0.1, 0.8)
        end

        -- Function to update the ammo information
        local function UpdateAmmoInfo()
            local ammoCount = GetInventoryItemCount("player", ammoSlotId);
            if ammoCount < redThresh and ammoCount >= 1 then
                RASCOLOR = {1, 0, .01, 1}
            elseif ammoCount < dOrangeHighThresh and ammoCount >= dOrangeLowThresh then
                RASCOLOR = {1, .19, 0, 1}
            elseif ammoCount < lOrangeHighThresh and ammoCount >= lOrangeLowThresh then
                RASCOLOR = {1, .56, 0, 1}
            elseif ammoCount < yellowHighThresh and ammoCount >= yellowLowThresh then
                RASCOLOR = {1, .87, 0, 1}
            elseif ammoCount < lLimeHighThresh and ammoCount >= lLimeLowThresh then
                RASCOLOR = {.63, 1, 0, 1}
            elseif (ammoCount <= greenHighThresh or ammoCount > greenHighThresh) and ammoCount >= greenLowThresh then
                RASCOLOR = {.24, 1, 0, 1}
            else
                RASCOLOR = {0, 0, 0, 1}
            end

            if not ammoCount or ammoCount == 0 or ammoCount == 1 then
                RP:Print("RasAmmo: Ensure ammo is equipped.")
                ammoCount = 0
            end

            ammoText:SetText("Ammo: " .. ammoCount)
            ammoStatusBar:SetSize(ammoText:GetWidth(), 20)

            ammoStatusBar:SetMinMaxValues(0, maxAmmo)
            ammoStatusBar:SetValue(ammoCount)
            ammoStatusBar:SetStatusBarColor(unpack(RASCOLOR))

            local ammoTexture = GetInventoryItemTexture("player", ammoSlotId)
            if ammoTexture then
                ammoIcon:SetTexture(ammoTexture)
                ammoIcon:Show()
            else
                ammoIcon:Hide()
            end

            if ammoCount <= 50 then
                ammoText:SetTextColor(1, 0, 0)
            elseif ammoCount <= 200 then
                ammoText:SetTextColor(1, 1, 0)
            else
                ammoText:SetTextColor(1, 1, 1)
            end

            ApplyVertexColorToFrame(frame)
        end

        local eventFrame = CreateFrame("Frame")
        eventFrame:RegisterEvent("PLAYER_LOGIN")
        eventFrame:RegisterEvent("BAG_UPDATE")
        eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
        eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

        eventFrame:SetScript("OnEvent", function(self, event, ...)
            if event == "PLAYER_ENTERING_WORLD" then
                UpdateAmmoInfo()
                self:UnregisterEvent(event)
            end
            if event == "BAG_UPDATE" or "UNIT_INVENTORY_CHANGED" or "PLAYER_TARGET_CHANGED" then
                UpdateAmmoInfo()
            end
        end)

        SLASH_RASAMMO1 = "/ammo"
        SlashCmdList["RASAMMO"] = function()
            UpdateAmmoInfo()
        end
    end
end)