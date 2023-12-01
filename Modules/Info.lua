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
local _, _, U, C = RP:Unpack() -- m, p, u, c
RP:AddModule("Info Bar", "Display Values:\nDurability\nFPS/MS\nZone\nTime\nDate\nNew Mail", function()
    if RP:IsDisabled("Info Bar") then
        return
    end

    --[[
    ################################################################
    #################           CONFIG             #################
    ################################################################
    ]] --
    local position = {"TOP", UIParent, 0, -5}
    local cCol = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
    local bg = "Interface\\HELPFRAME\\DarkSandstone-Tile"
    local edge = "Interface\\AddOns\\RasPort\\Media\\Border\\border-modified.tga"
    local duraMemoryFrame
    local fontPath = U.LSM:Fetch("font", RP.db.profile.info["Font"])

    --[[
    ################################################################
    #################           Globals            #################
    ################################################################
    ]] --

    local _G = getfenv(0)
    local CreateFrame, GetFramerate = _G.CreateFrame, _G.GetFramerate
    local HasNewMail = _G.HasNewMail
    local select, format, lower = _G.select, _G.string.format, _G.string.lower
    local floor, mod = _G.math.floor, _G.math.modf
    local date, _, GetNetStats = _G.date, _G.gcinfo, _G.GetNetStats
    local tinsert = _G.table.insert
    local tsort = _G.table.sort
    local len, sub = _G.string.len, _G.string.sub
    local L = U.L

    --[[
    ################################################################
    #################           Functions          #################
    ################################################################
    ]] --

    local function SetColorByProfile(self)
        local p = RP.db.profile
        if p["Class"] then
            return cCol.r, cCol.g, cCol.b
        elseif p["Blackout"] then
            return 0.15, 0.15, 0.15
        elseif p["Custom Color"] then
            return p["CC"].red, p["CC"].green, p["CC"].blue
        end
        return 1, 0, 0
    end

    local rr, gg, bb = SetColorByProfile(self)

    local function createButton(name, parent, width, height, text)
        local r, g, b, a = C.GOLD_COLOR:GetRGBA()
        local btn = CreateFrame("Button", name, parent, "RPButtonTemplate")
        btn:SetSize(width, height)
        btn:SetPoint(unpack(position))
        -- btn:SetNormalTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-norm.tga")
        -- btn:SetPushedTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-norm.tga")
        -- btn:SetHighlightTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-pressed.tga")
        btn.text = btn:CreateFontString(nil, "OVERLAY")
        btn.text:SetFont(fontPath, 16, "OUTLINE")
        btn.text:SetTextColor(r, g, b, a)
        btn.text:SetText(text)
        btn.text:SetAllPoints()
        return btn
    end

    local function createMiniButton(name, parent, width, height, text, point, anchor, x, y)
        local r, g, b, a = C.GOLD_COLOR:GetRGBA()
        local btn = CreateFrame("Button", name, parent, "RPMiniButtonTemplate")
        btn:SetSize(width, height)
        btn:SetPoint(point, anchor, x, y)
        btn.text = btn:CreateFontString(nil, "OVERLAY")
        btn.text:SetFont(fontPath, 10, "OUTLINE")
        btn.text:SetTextColor(r, g, b, a)
        btn.text:SetText(text)
        btn.text:SetAllPoints()
        return btn, btn.text
    end

    --[[
    ################################################################
    #################           Zone Button        #################
    ################################################################
    ]] --

    local zoneButton = createButton("ZoneButton", UIParent, 200, 35, "Zone")

    zoneButton:SetScript("OnClick", function()
        ToggleWorldMap()
    end)

    local function updateZone()
        zoneButton.text:SetText(GetRealZoneText())
    end

    zoneButton:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    zoneButton:RegisterEvent("PLAYER_ENTERING_WORLD")
    zoneButton:SetScript("OnEvent", updateZone)

    --[[
    ################################################################
    #################           FPS/MS Button      #################
    ################################################################
    ]] --

    local function getFpsMsText()
        local fpsText = "|cffFFD700" .. floor(GetFramerate()) .. "|r fps"
        local msText = "|cffFFD700" .. select(3, GetNetStats()) .. "|r ms"
        return fpsText .. "  " .. msText
    end

    local function updateFpsMsButtonText(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed > 1 then
            self.text:SetText(getFpsMsText())
            self.elapsed = 0
        end
    end

    local fpsMSButton = createMiniButton("FPS_MS", UIParent, 150, 30, getFpsMsText(), "LEFT", zoneButton, -90, 0)
    fpsMSButton:SetScript("OnUpdate", updateFpsMsButtonText)

    local addonMemoryFrame = CreateFrame("Frame", "AddonMemoryFrame", UIParent, "BackdropTemplate")
    addonMemoryFrame:SetPoint("TOP", fpsMSButton, "BOTTOM", 0, -5)
    addonMemoryFrame:SetSize(250, 150)
    addonMemoryFrame:SetBackdrop({
        bgFile = bg,
        edgeFile = edge,
        tile = false,
        tileSize = 8,
        edgeSize = 16,
        insets = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2
        }
    })
    addonMemoryFrame:SetBackdropBorderColor(rr, gg, bb, 1)
    addonMemoryFrame:Hide()
    RP.memoryFrame = addonMemoryFrame

    local scrollFrame = CreateFrame("ScrollFrame", nil, addonMemoryFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local upButton = scrollFrame.ScrollBar.ScrollUpButton
    local downButton = scrollFrame.ScrollBar.ScrollDownButton

    upButton:SetNormalTexture("Interface\\AddOns\\RasPort\\Media\\Button\\arrow-up-norm.tga")
    upButton:SetPushedTexture("Interface\\AddOns\\RasPort\\Media\\Button\\arrow-up-norm.tga")
    upButton:SetDisabledTexture("Interface\\AddOns\\RasPort\\Media\\Button\\arrow-up-disabled.tga")

    downButton:SetNormalTexture("Interface\\AddOns\\RasPort\\Media\\Button\\arrow-down-norm.tga")
    downButton:SetPushedTexture("Interface\\AddOns\\RasPort\\Media\\Button\\arrow-down-norm.tga")
    downButton:SetDisabledTexture("Interface\\AddOns\\RasPort\\Media\\Button\\arrow-down-disabled.tga")

    upButton:SetSize(15, 18)
    downButton:SetSize(15, 18)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(contentFrame)
    contentFrame:SetSize(addonMemoryFrame:GetWidth() - 30, addonMemoryFrame:GetHeight())
    contentFrame.fontStrings = {}

    local function ClearFontStrings()
        for _, fs in pairs(contentFrame.fontStrings) do
            fs:Hide()
            fs:SetText("")
        end
        wipe(contentFrame.fontStrings)
    end

    local function AbbreviateName(name, maxLength)
        maxLength = maxLength or 15
        if string.len(name) > maxLength then
            return string.sub(name, 1, maxLength) .. "..."
        else
            return name
        end
    end

    local function GetSortedAddonInfo()
        local addonInfo = {}
        UpdateAddOnMemoryUsage()
        for i = 1, GetNumAddOns() do
            local memUsage = GetAddOnMemoryUsage(i)
            if memUsage > 0 then
                local name, title = GetAddOnInfo(i)
                title = AbbreviateName(title or name)
                tinsert(addonInfo, {
                    name = name,
                    title = title,
                    memory = memUsage
                })
            end
        end
        -- Sort by memory usage
        tsort(addonInfo, function(a, b)
            return a.memory > b.memory
        end)
        return addonInfo
    end

    local function UpdateAddonMemoryFrame()
        addonMemoryFrame:Hide()
        ClearFontStrings()

        local addonInfo = GetSortedAddonInfo()
        local totalMemory = 0
        local yOffset = 0

        for i, info in ipairs(addonInfo) do
            totalMemory = totalMemory + info.memory

            local addonText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            addonText:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, yOffset)
            addonText:SetText(info.title)
            tinsert(contentFrame.fontStrings, addonText)

            local memoryText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            memoryText:SetPoint("TOPRIGHT", contentFrame, "TOPRIGHT", -10, yOffset)
            memoryText:SetText(format("%.0f kb", info.memory))
            tinsert(contentFrame.fontStrings, memoryText)

            yOffset = yOffset - 15
        end

        -- Separator Line
        local separator = contentFrame:CreateTexture(nil, "BACKGROUND")
        separator:SetHeight(1)
        separator:SetColorTexture(1, 1, 1, 0.5)
        separator:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOffset - 5)
        separator:SetPoint("TOPRIGHT", contentFrame, "TOPRIGHT", 0, yOffset - 5)

        -- Total Memory Usage
        yOffset = yOffset - 20
        local r, g, b, a = RP.Color.TURQ_COLOR:GetRGBA()
        local totalText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        totalText:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, yOffset)
        totalText:SetText("Total")
        totalText:SetTextColor(r, g, b, a)

        local totalMemoryText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        totalMemoryText:SetPoint("TOPRIGHT", contentFrame, "TOPRIGHT", -10, yOffset)
        totalMemoryText:SetText(format("%.0f kb", totalMemory))
        totalMemoryText:SetTextColor(r, g, b, a)
        tinsert(contentFrame.fontStrings, totalMemoryText)

        -- Update scroll child height
        contentFrame:SetHeight(-yOffset)
        addonMemoryFrame:Show()
    end

    fpsMSButton:SetScript("OnClick", function()
        if addonMemoryFrame:IsShown() then
            addonMemoryFrame:Hide()
        else
            duraMemoryFrame:Hide()
            UpdateAddonMemoryFrame()
        end
    end)

    --[[
    ################################################################
    #################           Durability         #################
    ################################################################
    ]] --

    local slotNames = {
        [1] = "HeadSlot",
        [2] = "NeckSlot",
        [3] = "ShoulderSlot",
        [4] = "ShirtSlot",
        [5] = "ChestSlot",
        [6] = "WaistSlot",
        [7] = "LegsSlot",
        [8] = "FeetSlot",
        [9] = "WristSlot",
        [10] = "HandsSlot",
        [11] = "Finger0Slot",
        [12] = "Finger1Slot",
        [13] = "Trinket0Slot",
        [14] = "Trinket1Slot",
        [15] = "BackSlot",
        [16] = "MainHandSlot",
        [17] = "SecondaryHandSlot",
        [18] = "RangedSlot"
    }

    local duraButton = createMiniButton("Durability", UIParent, 150, 30, "Durability", "LEFT", fpsMSButton, -90, 0)

    local function ClearDuraStrings()
        for _, fs in pairs(duraMemoryFrame.fontStrings) do
            fs:Hide()
            fs:SetText("")
        end
        wipe(duraMemoryFrame.fontStrings)
    end

    duraMemoryFrame = CreateFrame("Frame", "CustomDropdownBg", UIParent, "BackdropTemplate")
    duraMemoryFrame:SetBackdrop({
        bgFile = bg,
        edgeFile = edge,
        tile = false,
        tileSize = 8,
        edgeSize = 16,
        insets = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2
        }
    })
    duraMemoryFrame:SetSize(200, 300)
    duraMemoryFrame:SetPoint("TOP", duraButton, "BOTTOM", 0, -5)
    duraMemoryFrame:SetBackdropBorderColor(rr, gg, bb, 1)
    duraMemoryFrame:Hide()
    RP.duraFrame = duraMemoryFrame
    duraMemoryFrame.fontStrings = {}

    local function UpdateDurabilityButtonText()
        local totalDurability, numItems = 0, 0
        for i = 1, 18 do
            local current, maximum = GetInventoryItemDurability(i)
            if current and maximum and maximum ~= 0 then
                totalDurability = totalDurability + current / maximum
                numItems = numItems + 1
            end
        end

        if numItems > 0 then
            local overallDurability = (totalDurability / numItems) * 100
            duraButton.text:SetText(format("|cffFFD700Durability:|r %.0f%%", overallDurability))
            if overallDurability <= 10 then
                duraButton.text:SetTextColor(1, 0, 0)
            else
                RP:ColorProfile(duraButton.text)
            end
        end

    end

    local function UpdateDurabilityFrame()
        ClearDuraStrings()

        local totalDurability, numItems = 0, 0
        local yOffset = -10

        for i, slotName in pairs(slotNames) do
            local current, maximum = GetInventoryItemDurability(i)
            if current and maximum and maximum ~= 0 then
                local durability = (current / maximum) * 100
                totalDurability = totalDurability + durability
                numItems = numItems + 1

                local slotText = duraMemoryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                slotText:SetPoint("TOPLEFT", duraMemoryFrame, "TOPLEFT", 10, yOffset)
                slotText:SetText(slotName:gsub("Slot", "") .. ":")
                tinsert(duraMemoryFrame.fontStrings, slotText)

                local durabilityText = duraMemoryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                durabilityText:SetPoint("TOPRIGHT", duraMemoryFrame, "TOPRIGHT", -10, yOffset)
                durabilityText:SetText(format("%.0f%%", durability))
                local r, g = 1 - durability / 100, durability / 100
                durabilityText:SetTextColor(r, g, 0)
                tinsert(duraMemoryFrame.fontStrings, durabilityText)

                yOffset = yOffset - 15
            end
        end

        if numItems > 0 then
            local r, g, b, a = RP.Color.TURQ_COLOR:GetRGBA()
            local separator = duraMemoryFrame:CreateTexture(nil, "OVERLAY")
            separator:SetHeight(1)
            separator:SetColorTexture(1, 1, 1, 0.5)
            separator:SetPoint("TOPLEFT", duraMemoryFrame, "TOPLEFT", 10, yOffset - 4)
            separator:SetPoint("TOPRIGHT", duraMemoryFrame, "TOPRIGHT", -10, yOffset - 4)
            yOffset = yOffset - 15 -- Adjust for next item

            local overallDurability = totalDurability / numItems
            local totalText = duraMemoryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            totalText:SetPoint("TOPLEFT", duraMemoryFrame, "TOPLEFT", 10, yOffset)
            totalText:SetText("Overall:")
            totalText:SetTextColor(r, g, b, a)
            tinsert(duraMemoryFrame.fontStrings, totalText)

            local totalDurabilityText = duraMemoryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            totalDurabilityText:SetPoint("TOPRIGHT", duraMemoryFrame, "TOPRIGHT", -10, yOffset)
            totalDurabilityText:SetText(format("%.0f%%", overallDurability))
            totalDurabilityText:SetTextColor(r, g, b, a)
            tinsert(duraMemoryFrame.fontStrings, totalDurabilityText)

            yOffset = yOffset - 20
        end

        -- Update scroll child height
        duraMemoryFrame:SetHeight(-yOffset)
    end

    duraButton:SetScript("OnClick", function()
        if duraMemoryFrame:IsShown() then
            duraMemoryFrame:Hide()
        else
            addonMemoryFrame:Hide()
            UpdateDurabilityFrame()
            duraMemoryFrame:Show()
        end
    end)

    duraButton:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed > 1 then
            UpdateDurabilityButtonText()
            self.elapsed = 0
        end
    end)


    

    --[[
    ################################################################
    #################           Time               #################
    ################################################################
    ]] --

    local function getTime()
        if RP.db.profile.info["12-Hour"] then
            local t = date("%I:%M")
            local ampm = date("%p")
            return "|cffFFD700" .. t .. "|r " .. lower(ampm)
        else
            local t = date("%H:%M")
            return "|cffFFD700" .. t .. "|r"
        end
    end

    local timeButton = createMiniButton("Time", UIParent, 150, 30, "Time", "RIGHT", zoneButton, 90, 0)

    local function UpdateTimeButtonText()
        timeButton.text:SetText(getTime())
    end

    timeButton:SetScript("OnEvent", UpdateTimeButtonText)

    timeButton:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed > 1 then
            self.text:SetText(getTime())
            self.elapsed = 0
        end
    end)

    local timeDropdownBg = CreateFrame("Frame", "TimeDropdownBg", UIParent, "BackdropTemplate")
    timeDropdownBg:SetBackdrop({
        bgFile = bg,
        edgeFile = edge,
        tile = false,
        tileSize = 8,
        edgeSize = 16,
        insets = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2
        }
    })
    timeDropdownBg:SetSize(150, 35)
    timeDropdownBg:SetBackdropBorderColor(rr, gg, bb, 1)
    timeDropdownBg:SetPoint("TOP", timeButton, "BOTTOM", 0, -5)
    timeDropdownBg:Hide()
    RP.timeBG = timeDropdownBg

    local checkBox = CreateFrame("CheckButton", "TwelveHourFormatCheckBox", timeDropdownBg, "UICheckButtonTemplate")
    checkBox:SetPoint("TOPLEFT", 5, -1)
    checkBox.text = checkBox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    checkBox.text:SetPoint("LEFT", checkBox, "RIGHT", 5, 0)
    checkBox.text:SetText("12-Hour Format")
    checkBox:SetChecked(RP.db.profile.info["12-Hour"])

    checkBox:SetScript("OnClick", function(self)
        RP.db.profile.info["12-Hour"] = self:GetChecked()
        UpdateTimeButtonText()
        timeDropdownBg:Hide()
    end)

    timeButton:SetScript("OnClick", function()
        if timeDropdownBg:IsShown() then
            timeDropdownBg:Hide()
        else
            timeDropdownBg:Show()
        end
    end)

    --[[
    ################################################################
    #################           Date               #################
    ################################################################
    ]] --

    local function getDateLetters()
        local currentNoM = date("%d")
        local currentNoMString = len(currentNoM)
        local firstNumber, secondNumber = "", ""

        if currentNoMString == 1 then
            firstNumber = currentNoM
        else
            firstNumber = sub(currentNoM, 1, 1)
            secondNumber = sub(currentNoM, 2, 2)
        end

        -- Handle 11th, 12th, and 13th
        if currentNoM == "11" or currentNoM == "12" or currentNoM == "13" then
            return "th"
        end

        -- Determine suffix for other numbers
        if secondNumber == "1" then
            return "st"
        elseif secondNumber == "2" then
            return "nd"
        elseif secondNumber == "3" then
            return "rd"
        else
            return "th"
        end
    end

    local function getDateTotal()
        local dateletter = getDateLetters()
        return date("|cffFFD700%B|r " .. "" .. "%d") .. dateletter
    end

    local dateButton = createMiniButton("Date", UIParent, 150, 30, "Date", "RIGHT", timeButton, 90, 0)


    dateButton:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed > 1 then
            self.text:SetText(getDateTotal())
            self:SetScript("OnUpdate", nil)
            self.elapsed = 0
        end
    end)


    dateButton:SetScript("OnClick", function()
        if not CalendarFrame then
            LoadAddOn("Blizzard_Calendar")
        end
        Calendar_Toggle()
    end)

    --[[
    ################################################################
    #################           Mail               #################
    ################################################################
    ]] --

    local mailFrame = CreateFrame("Frame", "CustomDropdownBg", UIParent, "BackdropTemplate")
    mailFrame:SetBackdrop({
        bgFile = "Interface\\AddOns\\RasPort\\Media\\Button\\banner.tga",
        tile = false,
        tileSize = 8,
        insets = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2
        }
    })
    mailFrame:SetSize(100, 40)
    mailFrame:SetPoint("CENTER", zoneButton, "BOTTOM", 0, 5)
    mailFrame:SetBackdropBorderColor(rr, gg, bb, 1)
    mailFrame:SetFrameLevel(0)
    RP.mailFrame = mailFrame

    mailFrame.text = mailFrame:CreateFontString(nil, "OVERLAY")
    mailFrame.text:SetFont(fontPath, 10, "OUTLINE")
    mailFrame.text:SetPoint("CENTER", 0, 3)
    mailFrame.text:SetText("")
    mailFrame.text:Hide()

    local function UpdateMailStatus()
        if HasNewMail() then
            local mailColor = RP.db.profile.info["Mail Color"]
            mailFrame.text:SetFont(fontPath, 10, "OUTLINE")
            mailFrame.text:SetTextColor(mailColor.red, mailColor.green, mailColor.blue)
            mailFrame.text:SetText("Mail!")
            mailFrame.text:Show()
            PlaySoundFile(U.LSM:Fetch("sound", RP.db.profile.info["Mail Sound"] or "RasPort"))
            mailFrame:SetPoint("CENTER", zoneButton, "BOTTOM", 0, -12)
        else
            mailFrame.text:SetText("")
            mailFrame:SetPoint("CENTER", zoneButton, "BOTTOM", 0, 5)
            mailFrame.text:Hide()
        end
    end

    mailFrame:SetScript("OnEvent", UpdateMailStatus)
    mailFrame:RegisterEvent("UPDATE_PENDING_MAIL")
    mailFrame:RegisterEvent("PLAYER_LOGIN")
    mailFrame:RegisterEvent("MAIL_CLOSED")

    function RP:UpdateButtons()
        local frames = {timeDropdownBg, duraMemoryFrame, addonMemoryFrame}
        local p = RP.db.profile
        for _, frame in pairs(frames) do
            if p["Class"] then
                frame:SetBackdropBorderColor(cCol.r, cCol.g, cCol.b, 1)
            elseif p["Blackout"] then
                frame:SetBackdropBorderColor(0.15, 0.15, 0.15, 1)
            elseif p["Custom Color"] then
                frame:SetBackdropBorderColor(p["CC"].red, p["CC"].green, p["CC"].blue, 1)
            end
        end
    end

    function RP:ColorProfile(font)
        local DB = RP.db.profile.info
        local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

        if DB["Class"] then
            font:SetTextColor(classColor.r, classColor.g, classColor.b)
        elseif DB["Custom Color"] then
            local customColor = DB["Primary Color"]
            font:SetTextColor(customColor.red, customColor.green, customColor.blue)
        end
    end

    function RP:UpdateInfoFont()
        local fontFrame = {mailFrame.text, zoneButton.text, fpsMSButton.text, duraButton.text, timeButton.text,
                           dateButton.text}

        for _, font in pairs(fontFrame) do
            local size = 10
            local outline = "OUTLINE"
            local mailColor = RP.db.profile.info["Mail Color"]

            font:SetFont(fontPath, size, outline)

            if font == zoneButton.text then
                size = 16
                font:SetFont(fontPath, size, outline)
                RP:ColorProfile(font)
            elseif font == mailFrame.text then
                font:SetTextColor(mailColor.red, mailColor.green, mailColor.blue)
            else
                RP:ColorProfile(font)
            end
        end
    end

    local function _disabled()
        return not RP.db.profile.info.enabled
    end

    local LSM_Font = {}
    local LSM_Sound = {}
    local info = {
        type = "group",
        name = L["Info Bar"],
        order = 2,
        get = function(i)
            return RP.db.profile.info[i[#i]]
        end,
        set = function(i, val)
            RP.db.profile.info[i[#i]] = val
        end,
        args = {
            enabled = {
                type = "toggle",
                name = L["Enable"],
                order = 0,
                desc = L["Allows you to change the settings, disable to lock settings"]
            },
            textcolor = {
                type = "group",
                name = L["Text Color"],
                inline = true,
                disabled = _disabled,
                order = 1,
                args = {
                    Class = {
                        order = 1,
                        type = "toggle",
                        name = L["Class"],
                        desc = L["Sets the primary text color to class"],
                        get = function()
                            return RP.db.profile.info["Class"]
                        end,
                        set = function(_, value)
                            RP.db.profile.info["Class"] = value
                            if value then
                                RP.db.profile.info["Custom Color"] = false
                            end
                            RP:UpdateInfoFont()
                        end
                    },
                    CustomColor = {
                        order = 2,
                        type = "toggle",
                        name = L["Custom Color"],
                        desc = L["Set the primary text color"],
                        get = function()
                            return RP.db.profile.info["Custom Color"]
                        end,
                        set = function(_, value)
                            RP.db.profile.info["Custom Color"] = value
                            if value then
                                RP.db.profile.info["Class"] = false
                            end
                            RP:UpdateInfoFont()
                        end
                    },
                    PrimaryColor = {
                        order = 3,
                        type = "color",
                        name = "Choose Primary",
                        desc = "Sets the primary color of the info bar text",
                        dialogControl = "ColorPicker-RasPort",
                        width = "half",
                        disabled = function()
                            return RP.db.profile.info["Class"]
                        end,
                        get = function(info)
                            return RP.db.profile.info["Primary Color"].red, RP.db.profile.info["Primary Color"].green,
                                RP.db.profile.info["Primary Color"].blue
                        end,
                        set = function(_, r, g, b)
                            RP.db.profile.info["Primary Color"].red = r
                            RP.db.profile.info["Primary Color"].green = g
                            RP.db.profile.info["Primary Color"].blue = b
                            RP:UpdateInfoFont()
                        end
                    }
                }
            },
            textfont = {
                type = "group",
                name = L["Text Font"],
                inline = true,
                disabled = _disabled,
                order = 2,
                args = {
                    Font = {
                        order = 1,
                        type = "select",
                        name = L["Font"],
                        desc = L["Choose a font"],
                        values = LSM_Font,
                        get = function()
                            return RP.db.profile.info["Font"]
                        end,
                        set = function(_, val)
                            RP.db.profile.info["Font"] = val
                            RP:UpdateInfoFont()
                        end
                    }
                }
            },
            mailnotif = {
                type = "group",
                name = L["Mail Notification"], -- C.TURQ_COLOR:WrapTextInColorCode(L["Mail Notification"]),
                inline = true,
                disabled = _disabled,
                order = 3,
                args = {
                    MailColor = {
                        order = 2,
                        type = "color",
                        name = L["Mail Color"],
                        desc = L["Set the mail text color"],
                        get = function(info)
                            return RP.db.profile.info["Mail Color"].red, RP.db.profile.info["Mail Color"].green,
                                RP.db.profile.info["Mail Color"].blue
                        end,
                        set = function(_, r, g, b)
                            RP.db.profile.info["Mail Color"].red = r
                            RP.db.profile.info["Mail Color"].green = g
                            RP.db.profile.info["Mail Color"].blue = b
                            RP:UpdateInfoFont()
                        end
                    },
                    mailSound = {
                        order = 1,
                        type = "select",
                        name = L["New Mail"],
                        desc = L["Choose a sound"],
                        values = LSM_Sound,
                        get = function()
                            return RP.db.profile.info["Mail Sound"]
                        end,
                        set = function(_, val)
                            RP.db.profile.info["Mail Sound"] = val
                            PlaySoundFile(U.LSM:Fetch("sound", val))
                        end
                    }
                }
            }
        }
    }
    RP:RegisterForEvent("PLAYER_LOGIN", function()
        RP:UpdateInfoFont()
        -- Run Twice to assure text setting.
        for fontName, fontPath in pairs(RP.UI.LSM:HashTable("font")) do
            LSM_Font[fontName] = fontName
        end

        for soundName, soundPath in pairs(RP.UI.LSM:HashTable("sound")) do
            LSM_Sound[soundName] = soundName
        end
        RP.options.args.Options.args.info = info

    end)
end)
