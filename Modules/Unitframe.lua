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
RP:AddModule("Unitframe", "Improve the standard blizzard unitframes without going beyond the boundaries set by them.",
    function()
        if RP:IsDisabled("Unitframe") then
            return
        end

        -- Setup
        local UF = CreateFrame("Frame")
        local DB = RP.db.profile.unitframe
        local c = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

        -- API
        local _G = getfenv(0)
        local strgmatch, strsub, strlower = _G.string.gmatch, _G.string.sub, _G.string.lower
        local ceil, format, tonumber, tostring = _G.math.ceil, _G.string.format, _G.tonumber, _G.tostring
        local GetCVar, SetCVar, GetCVarBool = GetCVar, SetCVar, GetCVarBool
        local rad = _G.math.rad
        local L = U.L

        local StaticPopup_Show = StaticPopup_Show

        local hooksecurefunc = hooksecurefunc
        local InCombatLockdown = InCombatLockdown
        local UnitClass = UnitClass
        local UnitClassification = UnitClassification
        local UnitExists = UnitExists
        local UnitIsConnected = UnitIsConnected
        local UnitIsEnemy = UnitIsEnemy
        local UnitIsPlayer = UnitIsPlayer
        local UnitIsPVP = UnitIsPVP
        local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
        local UnitSelectionColor = UnitSelectionColor

        local __BossTargetFrame_Show
        local __PartyMemberFrame_ToPlayerArt
        local __PartyMemberFrame_ToVehicleArt
        local __PartyMemberFrame_Style
        local __ColorHealthBar
        local __ColorNames
        local __UnitFrameHealthBar_Update
        local UnitFrameName_Update
        local __UnitFramePortrait_Update
        local __PlayerFrame_ToPlayerArt
        local __TargetFrame_CheckClassification
        local __TargetFrame_CheckFaction
        local __TargetFrame_Update
        local __TextStatusBar_UpdateTextString
        local __PVPIcon_UpdateTexture

        --[[
    ################################################################
    #################           Functions          #################
    ################################################################
    ]] --

        -- Spark Creation
        local function CreateSpark(frame, w, h)
            local Spark = frame:CreateTexture(nil, 'OVERLAY')
            Spark:SetHeight(h)
            Spark:SetWidth(w)
            Spark:SetTexture("Interface\\AddOns\\RasPortUF\\Media\\spark")
            Spark:SetBlendMode('ADD')
            Spark:SetVertexColor(1, 1, 1)
            Spark:Hide()
            frame.Spark = Spark
        end

        -- Health Spark
        local function UpdateHealthSpark(frame, spark, unit)
            local currentTargetHealth = UnitHealth(unit)
            local maxTargetHealth = UnitHealthMax(unit)
            local percentage = currentTargetHealth / maxTargetHealth
            local sparkPosition = percentage * frame:GetWidth() - spark:GetWidth() / 2

            if unit == 'target' then
                spark:SetPoint('RIGHT', frame, 'RIGHT', -sparkPosition - 0.5, 0)
            else
                spark:SetPoint('LEFT', frame, 'LEFT', sparkPosition + 0.5, 0)
            end
            if percentage == 1 or percentage == 0 then
                spark:Hide()
            else
                spark:Show()
            end
        end

        -- Mana Spark
        local function UpdateManaSpark(frame, spark, unit)
            local currentTargetHealth = UnitPower(unit)
            local maxTargetHealth = UnitPowerMax(unit)
            local percentage = currentTargetHealth / maxTargetHealth
            local sparkPosition = percentage * frame:GetWidth() - spark:GetWidth() / 2

            if unit == 'target' then
                spark:SetPoint('RIGHT', frame, 'RIGHT', -sparkPosition - 0.5, 0)
            else
                spark:SetPoint('LEFT', frame, 'LEFT', sparkPosition + 0.5, 0)
            end
            if percentage == 1 or percentage == 0 then
                spark:Hide()
            else
                spark:Show()
            end
        end

        function UF:CapDisplayOfNumericValue(value)
            local strLen = strlen(value)
            local retString = value
            if true then
                if strLen >= 10 then
                    retString = strsub(value, 1, -10) .. "." .. strsub(value, -9, -9) .. "B"
                elseif strLen >= 7 then
                    retString = strsub(value, 1, -7) .. "." .. strsub(value, -6, -6) .. "M"
                elseif strLen >= 4 then
                    retString = strsub(value, 1, -4) .. "." .. strsub(value, -3, -3) .. "K"
                end
            end
            return retString
        end

        --[[
    ################################################################
    #################           Player             #################
    ################################################################
    ]] --
        function __PlayerFrame_ToPlayerArt()
            if DB["Improved"] then
                PlayerFrame.name:SetPoint("CENTER", 50, 35)
                PlayerFrame.name:SetFont(U.LSM:Fetch("font", DB["Font"]), DB["Font Size"], DB["Font Outline"])
                PlayerFrameHealthBar:SetWidth(120)
                PlayerFrameHealthBar:SetHeight(29)
                PlayerFrameHealthBar:SetPoint("TOPLEFT", 106, -22)
                PlayerFrameHealthBarText:SetPoint("CENTER", PlayerFrameHealthBar, "CENTER", 0, 0)
                PlayerFrameHealthBarTextLeft:ClearAllPoints()
                PlayerFrameHealthBarTextLeft:SetPoint("LEFT", PlayerFrameHealthBar, "LEFT", 4, 0)
                PlayerFrameHealthBarTextRight:SetPoint("CENTER", PlayerFrameHealthBar, "CENTER", 0, 0)
                if DB["Hide Level"] then
                    PlayerLevelText:Hide()
                    PlayerFrameTexture:SetTexture(
                        "Interface\\AddOns\\RasPort\\Media\\Unit\\NoLevel-Thick-TargetingFrame")
                else
                    PlayerFrameTexture:SetTexture("Interface\\AddOns\\RasPort\\Media\\Unit\\UI-TargetingFrame")
                end
                PlayerStatusTexture:SetTexture([[Interface\AddOns\RasPort\Media\Unit\UI-Player-Status]])
                PlayerFrameHealthBar:SetStatusBarTexture(U.LSM:Fetch("statusbar", DB["Texture"]))
                PlayerFrameManaBar:SetWidth(120)
            end
        end

        

        local playerFrame = CreateFrame("Frame", "MyPlayerFrame", PlayerFrame, "BackdropTemplate")
        playerFrame:SetPoint("TOPLEFT", PlayerFrameHealthBar, "TOPLEFT", -4, 2)
        playerFrame:SetPoint("BOTTOMRIGHT", PlayerFrameHealthBar, "BOTTOMRIGHT", 4, -3)
        playerFrame:SetBackdrop({
            bgFile = "Interface\\HELPFRAME\\DarkSandstone-Tile",
            "REPEAT",
            "REPEAT",
            tile = false,
            insets = {
                left = 4,
                right = 4,
                top = 4,
                bottom = 4
            }
        })
        playerFrame:SetBackdropColor(1, 0.15, 0.15, 1)
        playerFrame:SetFrameStrata("BACKGROUND")
        playerFrame:SetFrameLevel(0)

        --[[
    ################################################################
    #################           Target             #################
    ################################################################
    ]] --
        function __TargetFrame_Update(self)
            if not DB["Improved"] then
                return
            end
            if DB["Hide Level"] then
                self.levelText:SetAlpha(0)
                self.threatIndicator:SetTexture("Interface\\AddOns\\RasPort\\Media\\Unit\\ui-targetingframe-flash")
            end
            self.healthbar.lockColor = true
            self.healthbar:SetWidth(120)
            self.healthbar:SetHeight(29)
            self.healthbar:SetPoint("TOPLEFT", 6.5, -22)
            self.healthbar:SetReverseFill(true)
            --self.textureFrame.HealthBarText:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)
            self.deadText:SetPoint("CENTER", -50, 6)
            self.name:SetPoint("CENTER", -50, 35)
            self.name:SetFont(U.LSM:Fetch("font", DB["Font"]), DB["Font Size"], DB["Font Outline"])
            self.nameBackground:Hide()
            self.Background:SetSize(119, 42)
            self.healthbar:SetStatusBarTexture(U.LSM:Fetch("statusbar", DB["Texture"]))
            self.manabar:SetWidth(120)
            self.manabar:SetReverseFill(true)
        end

        hooksecurefunc("TargetFrame_UpdateAuras", function(self)
            local showOnlyPlayerAuras = DB["Buffs Cast by Me"]

            for i = 1, MAX_TARGET_BUFFS do
                local buffName = "TargetFrameBuff" .. i
                local buff = _G[buffName]
                if buff and buff:IsShown() then
                    local name, icon, count, dispelType, duration, expirationTime, source, isStealable,
                        nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll,
                        timeMod = UnitBuff(self.unit, i)
                    if name and (not showOnlyPlayerAuras or castByPlayer) then
                        buff:SetSize(DB["Buff Size"], DB["Buff Size"])
                        -- CreateCooldownTimer(buff, duration, expirationTime)
                    elseif showOnlyPlayerAuras then
                        buff:Hide()
                    end
                end
            end

            for i = 1, MAX_TARGET_DEBUFFS do
                local debuffName = "TargetFrameDebuff" .. i
                local debuff = _G[debuffName]
                if debuff and debuff:IsShown() then
                    local name, icon, count, dispelType, duration, expirationTime, source, isStealable,
                        nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll,
                        timeMod = UnitDebuff(self.unit, i)
                    if name and (not showOnlyPlayerAuras or source == "player") then
                        debuff:SetSize(DB["Debuff Size"], DB["Debuff Size"])
                        -- CreateCooldownTimer(debuff, duration, expirationTime)
                    elseif showOnlyPlayerAuras then
                        debuff:Hide()
                    end
                end
            end
        end)

        local targetFrame = CreateFrame("Frame", "MyTargetFrame", TargetFrame, "BackdropTemplate")
        targetFrame:SetPoint("TOPLEFT", TargetFrameHealthBar, "TOPLEFT", -4, 2)
        targetFrame:SetPoint("BOTTOMRIGHT", TargetFrameHealthBar, "BOTTOMRIGHT", 4, -3)
        targetFrame:SetBackdrop({
            bgFile = "Interface\\HELPFRAME\\DarkSandstone-Tile",
            "REPEAT",
            "REPEAT",
            tile = false,
            insets = {
                left = 4,
                right = 4,
                top = 4,
                bottom = 4
            }
        })
        targetFrame:SetBackdropColor(1, 0.15, 0.15, 1)
        targetFrame:SetFrameStrata("BACKGROUND")
        targetFrame:SetFrameLevel(0)
        targetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        targetFrame:SetScript("OnEvent", function(self, event, ...)
            if event == "TARGET_CHANGED" then
                UnitFrameName_Update()
            end
        end)

        --[[
    ################################################################
    #################           Target Faction     #################
    ################################################################
    ]] --
        function __TargetFrame_CheckFaction(self)
            if not DB["Improved"] then
                return
            end
            local factionGroup = UnitFactionGroup(self.unit)
            self.pvpIcon:Hide()
            if UnitIsPVPFreeForAll(self.unit) then
                self.pvpIcon:Hide()
            elseif factionGroup and UnitIsPVP(self.unit) and UnitIsEnemy("player", self.unit) then
                self.pvpIcon:Hide()
            elseif factionGroup then
                self.pvpIcon:Hide()
            else
                self.pvpIcon:Hide()
            end
        end

        local customPVPIcon = CreateFrame("Frame", "CustomPVPIconFrame", TargetFrame)
        customPVPIcon:SetSize(35, 40)

        local iconTexture = customPVPIcon:CreateTexture(nil, "ARTWORK")
        iconTexture:SetAllPoints(customPVPIcon)
        customPVPIcon.texture = iconTexture
        customPVPIcon:SetPoint("LEFT", TargetFrame, "RIGHT", -52, 9)

        local function UpdateCustomPVPIcon()
            local factionGroup = UnitFactionGroup("target")

            if UnitIsPVPFreeForAll("target") or (factionGroup and UnitIsPVP("target")) then
                customPVPIcon.texture:SetTexture([[Interface\AddOns\RasPort\Media\Unit\pvp-banner-]] .. factionGroup)
                customPVPIcon:Show()
            else
                customPVPIcon:Hide()
            end
        end

        TargetFrame:HookScript("OnShow", UpdateCustomPVPIcon)
        TargetFrame:HookScript("OnEvent", function(self, event)
            if event == "PLAYER_TARGET_CHANGED" then
                UpdateCustomPVPIcon()
            end
        end)

        function __PVPIcon_UpdateTexture()
            local factionGroup = UnitFactionGroup("player");

            -- Check the conditions you care about
            if (UnitIsPVP("player")) then
                PlayerPVPIcon:SetSize(35, 40)
                -- Set your custom texture based on the condition
                if (factionGroup == "Horde") then
                    PlayerPVPIcon:SetTexture("Interface\\AddOns\\RasPort\\Media\\Unit\\pvp-banner-HORDE.tga");
                elseif (factionGroup == "Alliance") then
                    PlayerPVPIcon:SetTexture("Interface\\AddOns\\RasPort\\Media\\Unit\\pvp-banner-ALLIANCE.tga");
                end
            end
        end

        --[[
    ################################################################
    #################     Target Classification    #################
    ################################################################
    ]] --
        function __TargetFrame_CheckClassification(self, forceNormalTexture)
            if not DB["Improved"] then
                return
            end

            local texture
            local classification = UnitClassification(self.unit)
            if classification == "worldboss" or classification == "elite" then
                texture = [[Interface\AddOns\RasPort\Media\Unit\UI-TargetingFrame-Elite]]
            elseif classification == "rareelite" then
                texture = [[Interface\AddOns\RasPort\Media\Unit\UI-TargetingFrame-Rare-Elite]]
            elseif classification == "rare" then
                texture = [[Interface\AddOns\RasPort\Media\Unit\UI-TargetingFrame-Rare]]
            end
            if texture and not forceNormalTexture then
                self.borderTexture:SetTexture(texture)
            else
                if DB["Hide Level"] then
                    self.borderTexture:SetTexture(
                        "Interface\\AddOns\\RasPort\\Media\\Unit\\NoLevel-Thick-TargetingFrame")
                else
                    self.borderTexture:SetTexture("Interface\\AddOns\\RasPort\\Media\\Unit\\UI-TargetingFrame")
                end
            end
        end

        --[[
    ################################################################
    #################     Party Style              #################
    ################################################################
    ]] --

        function __PartyMemberFrame_ToPlayerArt(self)
            if not InCombatLockdown() then
                __PartyMemberFrame_Style()
            end
        end

        function __PartyMemberFrame_ToVehicleArt(self)
            if DB["Improved"] then
                for i = 1, 4 do
                    if UnitExists("party" .. i) and UnitInVehicle("party" .. i) then
                        _G["PartyMemberFrame" .. i .. "VehicleTexture"]:SetTexture(
                            [[Interface\AddOns\RasPort\Media\Unit\UI-Vehicles-Partyframe]])
                        if not InCombatLockdown() then
                            _G["PartyMemberFrame" .. i .. "VehicleTexture"]:SetPoint("TOPLEFT", 0, 12)
                            _G["PartyMemberFrame" .. i .. "VehicleTexture"]:SetHeight(75)
                            _G["PartyMemberFrame" .. i .. "VehicleTexture"]:SetWidth(150)
                        end
                    end
                end
            end
        end

        function __PartyMemberFrame_Style()
            if not InCombatLockdown() and DB["Improved"] then
                for i = 1, 4 do
                    local frame = _G["PartyMemberFrame" .. i]
                    if frame and not frame.RasPorted then
                        frame.RasPorted = true
                        __ColorHealthBar(_G["PartyMemberFrame" .. i .. "HealthBar"], "party" .. i)
                        __UnitFramePortrait_Update(_G["PartyMemberFrame" .. i])

                        _G["PartyMemberFrame" .. i .. "HealthBar"]:SetStatusBarTexture(U.LSM:Fetch("statusbar",
                            DB["Texture"]))
                        _G["PartyMemberFrame" .. i .. "ManaBar"]:SetStatusBarTexture(
                            U.LSM:Fetch("statusbar", DB["Texture"]))
                        -- Text
                        _G["PartyMemberFrame" .. i .. "Name"]:SetPoint("BOTTOMLEFT", 57, 35)
                        -- Border Texture
                        _G["PartyMemberFrame" .. i .. "Texture"]:SetPoint("TOPLEFT", 0, 12)
                        _G["PartyMemberFrame" .. i .. "Texture"]:SetHeight(75)
                        _G["PartyMemberFrame" .. i .. "Texture"]:SetWidth(150)
                        -- Border Flash
                        _G["PartyMemberFrame" .. i .. "Flash"]:SetPoint("TOPLEFT", 0, 12)
                        _G["PartyMemberFrame" .. i .. "Flash"]:SetHeight(75)
                        _G["PartyMemberFrame" .. i .. "Flash"]:SetWidth(150)
                        -- Health Bar
                        _G["PartyMemberFrame" .. i .. "HealthBar"]:ClearAllPoints()
                        _G["PartyMemberFrame" .. i .. "HealthBar"]:SetPoint("TOPLEFT", 54, -6)
                        _G["PartyMemberFrame" .. i .. "HealthBar"]:SetPoint("BOTTOMRIGHT", 10, 20)
                        _G["PartyMemberFrame" .. i .. "HealthBar"]:SetHeight(27)
                        _G["PartyMemberFrame" .. i .. "HealthBar"]:SetWidth(80)
                        -- Mana Bar
                        _G["PartyMemberFrame" .. i .. "ManaBar"]:ClearAllPoints()
                        _G["PartyMemberFrame" .. i .. "ManaBar"]:SetPoint("TOPLEFT", 53, -34)
                        _G["PartyMemberFrame" .. i .. "ManaBar"]:SetPoint("BOTTOMRIGHT", 11, 11)
                        _G["PartyMemberFrame" .. i .. "ManaBar"]:SetHeight(10)
                        _G["PartyMemberFrame" .. i .. "ManaBar"]:SetWidth(80)
                        -- Portrait
                        _G["PartyMemberFrame" .. i .. "Portrait"]:SetPoint("TOPLEFT", 7, -2)
                        _G["PartyMemberFrame" .. i .. "Portrait"]:SetHeight(43)
                        _G["PartyMemberFrame" .. i .. "Portrait"]:SetWidth(43)
                        -- Background
                        _G["PartyMemberFrame" .. i .. "Background"]:ClearAllPoints()
                        _G["PartyMemberFrame" .. i .. "Background"]:SetPoint("TOPLEFT", 55, -7)
                        _G["PartyMemberFrame" .. i .. "Background"]:SetPoint("BOTTOMRIGHT", 11, 11)
                        _G["PartyMemberFrame" .. i .. "Background"]:SetHeight(35)
                        _G["PartyMemberFrame" .. i .. "Background"]:SetWidth(80)
                        _G["PartyMemberFrame" .. i .. "Texture"]:SetTexture(
                            [[Interface\AddOns\RasPort\Media\Unit\UI-PartyFrame]])
                        _G["PartyMemberFrame" .. i .. "Flash"]:SetTexture(
                            [[Interface\AddOns\RasPort\Media\Unit\UI-Partyframe-Flash]])
                    end
                end
            end
        end

        --[[
    ################################################################
    #################     Update Functions         #################
    ################################################################
    ]] --

        function __UnitFrameHealthBar_Update(statusbar, unit)
            if unit and unit ~= "mouseover" and UnitIsConnected(unit) and unit == statusbar.unit then
                __ColorHealthBar(statusbar, unit)
            end
            UnitFrameName_Update()
            MainMenuExpBar:SetStatusBarTexture(U.LSM:Fetch("statusbar", DB["Texture"]))
            MainMenuExpBar:SetHeight(10)
            ReputationWatchBar.StatusBar:SetStatusBarTexture(U.LSM:Fetch("statusbar", DB["Texture"]))
            ReputationWatchBar.StatusBar:SetHeight(10)
        end

        function UnitFrameName_Update()
            __ColorNames(PlayerName, "player")
            __ColorNames(TargetFrame.name, "target")
        end

        function __UnitFramePortrait_Update(self)
            if self.portrait and self.unit then
                if DB["Portrait"] and UnitIsPlayer(self.unit) then
                    -- Handle 2D class icon
                    local tex = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))]
                    if tex then
                        self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
                        self.portrait:SetTexCoord(unpack(tex))
                        self.portrait:Show()
                        if self.portrait3D then
                            self.portrait3D:Hide()
                        end
                    end
                else
                    -- Default behavior (e.g., Blizzard's default 2D portrait)
                    SetPortraitTexture(self.portrait, self.unit)
                    self.portrait:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
                    self.portrait:Show()
                    if self.portrait3D then
                        self.portrait3D:Hide()
                    end
                end
            end
        end

        function __TextStatusBar_UpdateTextString(textStatusBar)
            local textString = textStatusBar.TextString
            if textString then
                local value = textStatusBar:GetValue()
                local valueMin, valueMax = textStatusBar:GetMinMaxValues()
    
                textString:SetFont(
                    RP:MediaFetch("font", RP.db.profile.unitframe["Font"]),
                    RP.db.profile.unitframe["Font Size"],
                    RP.db.profile.unitframe["Font Outline"]
                )
            end
        end

        function __BossTargetFrame_Show(self)
            if not InCombatLockdown() and DB["Improved"] and not self.RasPorted then
                self.RasPorted = true
                self.borderTexture:SetTexture([[Interface\AddOns\RasPort\Media\Unit\UI-UnitFrame-Boss]])
            end
        end

        local function MoveBuffs()
            if TargetFrameBuff1 then
                TargetFrameBuff1:ClearAllPoints()
                TargetFrameBuff1:SetPoint("TOPLEFT", TargetFrame, "BOTTOMLEFT", 0, 15)
            end
        end

        TargetFrame:HookScript("OnEvent", MoveBuffs)

        --[[
    ################################################################
    #################     Hook Functions           #################
    ################################################################
    ]] --

        function UF:Initialize()
            if InCombatLockdown() then
                return
            end
            TargetFrame:SetParent(UIParent)
            TargetFrame:SetAlpha(1)
            TargetFrame:Show()
            UpdateCustomPVPIcon()

            hooksecurefunc("PlayerFrame_UpdatePvPStatus", __PVPIcon_UpdateTexture)

            hooksecurefunc("TextStatusBar_UpdateTextString", __TextStatusBar_UpdateTextString)
            __TextStatusBar_UpdateTextString(PlayerFrameHealthBar)
            __TextStatusBar_UpdateTextString(PlayerFrameManaBar)

            hooksecurefunc("PlayerFrame_ToPlayerArt", __PlayerFrame_ToPlayerArt)

            if DB["Hide Indicator"] then
                hooksecurefunc(PlayerHitIndicator, "Show", PlayerHitIndicator.Hide)
                hooksecurefunc(PetHitIndicator, "Show", PetHitIndicator.Hide)
            end

            __PlayerFrame_ToPlayerArt()
            PlayerFrameHealthBar.lockColor = true

            hooksecurefunc("TargetFrame_Update", __TargetFrame_Update)
            hooksecurefunc("TargetFrame_CheckFaction", __TargetFrame_CheckFaction)
            hooksecurefunc("TargetFrame_CheckClassification", __TargetFrame_CheckClassification)

            hooksecurefunc("PartyMemberFrame_ToPlayerArt", __PartyMemberFrame_ToPlayerArt)
            hooksecurefunc("PartyMemberFrame_ToVehicleArt", __PartyMemberFrame_ToVehicleArt)
            UnitFrameName_Update()
            hooksecurefunc("UnitFrameHealthBar_Update", __UnitFrameHealthBar_Update)
            hooksecurefunc("HealthBar_OnValueChanged", function(statusbar, frame, unit)
                __ColorHealthBar(statusbar, statusbar.unit)
            end)
            hooksecurefunc("UnitFrameHealthBar_Update", UnitFrameName_Update)
            hooksecurefunc("UnitFramePortrait_Update", __UnitFramePortrait_Update)

            __UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player")
            __UnitFramePortrait_Update(PlayerFrame)
            __PartyMemberFrame_Style()

            hooksecurefunc(Boss1TargetFrame, "Show", __BossTargetFrame_Show)
            hooksecurefunc(Boss2TargetFrame, "Show", __BossTargetFrame_Show)
            hooksecurefunc(Boss3TargetFrame, "Show", __BossTargetFrame_Show)
            hooksecurefunc(Boss4TargetFrame, "Show", __BossTargetFrame_Show)
        end

        function UF:Update()
            if InCombatLockdown() then
                return
            end
            UpdateCustomPVPIcon()

            hooksecurefunc("PlayerFrame_UpdatePvPStatus", __PVPIcon_UpdateTexture)

            hooksecurefunc("TextStatusBar_UpdateTextString", __TextStatusBar_UpdateTextString)
            __TextStatusBar_UpdateTextString(PlayerFrameHealthBar)
            __TextStatusBar_UpdateTextString(PlayerFrameManaBar)

            hooksecurefunc("PlayerFrame_ToPlayerArt", __PlayerFrame_ToPlayerArt)

            if DB["Hide Indicator"] then
                hooksecurefunc(PlayerHitIndicator, "Show", PlayerHitIndicator.Hide)
                hooksecurefunc(PetHitIndicator, "Show", PetHitIndicator.Hide)
            end

            __PlayerFrame_ToPlayerArt()
            PlayerFrameHealthBar.lockColor = true

            hooksecurefunc("TargetFrame_Update", __TargetFrame_Update)

            hooksecurefunc("PartyMemberFrame_ToPlayerArt", __PartyMemberFrame_ToPlayerArt)
            hooksecurefunc("PartyMemberFrame_ToVehicleArt", __PartyMemberFrame_ToVehicleArt)
            UnitFrameName_Update()
            hooksecurefunc("UnitFrameHealthBar_Update", __UnitFrameHealthBar_Update)
            hooksecurefunc("HealthBar_OnValueChanged", function(statusbar, frame, unit)
                __ColorHealthBar(statusbar, statusbar.unit)
            end)
            hooksecurefunc("UnitFrameHealthBar_Update", UnitFrameName_Update)
            hooksecurefunc("UnitFramePortrait_Update", __UnitFramePortrait_Update)

            __UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player")
            __UnitFramePortrait_Update(PlayerFrame)
            __PartyMemberFrame_Style()

            hooksecurefunc(Boss1TargetFrame, "Show", __BossTargetFrame_Show)
            hooksecurefunc(Boss2TargetFrame, "Show", __BossTargetFrame_Show)
            hooksecurefunc(Boss3TargetFrame, "Show", __BossTargetFrame_Show)
            hooksecurefunc(Boss4TargetFrame, "Show", __BossTargetFrame_Show)
        end

        --[[
    ################################################################
    #################     Color Functions          #################
    ################################################################
    ]] --

        function __ColorNames(fontString, unit)
            if not unit then
                return
            end

            local r, g, b

            if UnitIsPlayer(unit) then
                local _, class = UnitClass(unit)
                if class then
                    local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
                    r, g, b = color.r, color.g, color.b
                end
            else
                r, g, b = UnitSelectionColor(unit)
                if r == 0 then
                    r = DB["Friendly"].red
                    g = DB["Friendly"].green
                    b = DB["Friendly"].blue
                elseif g == 0 then
                    r = DB["Hostile"].red
                    g = DB["Hostile"].green
                    b = DB["Hostile"].blue
                else
                    r = DB["Neutral"].red
                    g = DB["Neutral"].green
                    b = DB["Neutral"].blue
                end
            end
            fontString:SetTextColor(r, g, b)
        end

        function __ColorHealthBar(statusbar, unit)
            if not unit then
                return
            elseif UnitIsPlayer(unit) then
                local _, class = UnitClass(unit)
                if class then
                    local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
                    statusbar:SetStatusBarColor(color.r, color.g, color.b)
                    return
                end
            end

            local r, g, b = UnitSelectionColor(unit)
            if r == 0 then
                r = DB["Friendly"].red
                g = DB["Friendly"].green
                b = DB["Friendly"].blue
            elseif g == 0 then
                r = DB["Hostile"].red
                g = DB["Hostile"].green
                b = DB["Hostile"].blue
            else
                r = DB["Neutral"].red
                g = DB["Neutral"].green
                b = DB["Neutral"].blue
            end

            statusbar:SetStatusBarColor(r, g, b)
        end

        --[[
    ################################################################
    #################             Config           #################
    ################################################################
    ]] --

    local LSM_Font = {}
    local LSM_Statusbar = {}
    local function _disabled()
        return not DB.enabled
    end

        local options = {
            type = "group",
            name = L["Unitframe"],
            childGroups = "tab",
            order = 5,
            get = function(i)
                return DB[i[#i]]
            end,
            set = function(i, val)
                DB[i[#i]] = val
            end,
            args = {
                enabled = {
                    type = "toggle",
                    name = "Enable",
                    order = 1,
                    desc = "Allows you to change the settings, disable to lock settings.",
                },
                statusbar = {
                    order = 3,
                    type = "group",
                    name = "Statusbar",
                    inline = true,
                    disabled = _disabled,
                    args = {
                        texture = {
                            order = 0,
                            type = "select",
                            name = "Status Bar Texture",
                            desc = "Choose a texture for the status bars.",
                            values = LSM_Statusbar,
                            get = function(info)
                                return DB["Texture"]
                            end,
                            set = function(info, value)
                                DB["Texture"] = value
                                UF:Update()
                            end
                        },
                        sep1 = {
                            type = "description",
                            name = " ",
                            order = 0.5,
                        },
                        friendly = {
                            order = 1,
                            type = "color",
                            name = "Friendly",
                            desc = "Sets the friendly unit color",
                            dialogControl = "ColorPicker-RasPort",
                            width = "half",
                            get = function(info)
                                return DB["Friendly"].red, DB["Friendly"].green, DB["Friendly"].blue
                            end,
                            set = function(_, r, g, b)
                                DB["Friendly"].red = r
                                DB["Friendly"].green = g
                                DB["Friendly"].blue = r
                            end
                        },
                        neutral = {
                            order = 2,
                            type = "color",
                            name = "Neutral",
                            desc = "Sets the neutral unit color",
                            dialogControl = "ColorPicker-RasPort",
                            width = "half",
                            get = function(info)
                                return DB["Neutral"].red, DB["Neutral"].green, DB["Neutral"].blue
                            end,
                            set = function(_, r, g, b)
                                DB["Neutral"].red = r
                                DB["Neutral"].green = g
                                DB["Neutral"].blue = r
                            end
                        },
                        hostile = {
                            order = 3,
                            type = "color",
                            name = "Hostile",
                            desc = "Sets the hostile unit color",
                            dialogControl = "ColorPicker-RasPort",
                            width = "half",
                            get = function(info)
                                return DB["Hostile"].red, DB["Hostile"].green, DB["Hostile"].blue
                            end,
                            set = function(_, r, g, b)
                                DB["Hostile"].red = r
                                DB["Hostile"].green = g
                                DB["Hostile"].blue = r
                            end
                        }
                    }
                },
                toggles = {
                    order = 4,
                    type = "group",
                    name = "Toggles",
                    inline = true,
                    disabled = _disabled,
                    args = {
                        improved = {
                            order = 0,
                            type = "toggle",
                            name = "Improved Unitframes",
                            desc = 'Enhances the look and feel of the blizzard unitframes',
                            get = function()
                                return DB["Improved"]
                            end,
                            set = function(_, value)
                                DB["Improved"] = value
                                UF:Update()
                            end
                        },
                        hideLevel = {
                            order = 1,
                            type = "toggle",
                            name = "Hide Level",
                            desc = 'Hide the level display',
                            disabled = function()
                                return not DB["Improved"]
                            end,
                            get = function()
                                return DB["Hide Level"]
                            end,
                            set = function(_, value)
                                DB["Hide Level"] = value
                                UF:Update()
                            end
                        },
                        hideDamage = {
                            order = 2,
                            type = "toggle",
                            name = "Hide Indicator",
                            desc = 'Hides the damage indicator on unitframe portrait',
                            get = function()
                                return DB["Hide Indicator"]
                            end,
                            set = function(_, value)
                                DB["Hide Indicator"] = value
                                UF:Update()
                            end
                        },
                        portrait = {
                            order = 3,
                            type = "toggle",
                            name = "Class Portrait",
                            desc = 'Display class icon instead of portrait',
                            get = function()
                                return DB["Portrait"]
                            end,
                            set = function(_, value)
                                DB["Portrait"] = value
                                UF:Update()
                            end
                        }
                    }
                },
                font = {
                    order = 5,
                    type = "group",
                    name = "Font",
                    inline = true,
                    disabled = _disabled,
                    args = {
                        Font = {
                            order = 1,
                            type = "select",
                            name = "Font",
                            desc = "Choose a font",
                            values = LSM_Font,
                            get = function()
                                return DB["Font"]
                            end,
                            set = function(_, val)
                                DB["Font"] = val
                                UF:Update()
                            end
                        },
                        outline = {
                            order = 2,
                            type = "select",
                            name = "Font Outline",
                            desc = "Set the font outline",
                            values = {
                                ["NONE"] = "None",
                                ["OUTLINE"] = "Outline",
                                ["THICKOUTLINE"] = "Thick Outline",
                                ["MONOCHROME"] = "Monochrome"
                            },
                            get = function(info)
                                return DB["Font Outline"]
                            end,
                            set = function(info, value)
                                DB["Font Outline"] = value
                                UF:Update()
                            end
                        },
                        fontSize = {
                            type = "range",
                            name = "Font Size",
                            desc = "Changes the font size",
                            order = 3,
                            min = 10,
                            max = 30,
                            step = 0.1,
                            bigStep = 1,
                            get = function()
                                return DB["Font Size"]
                            end,
                            set = function(_, value)
                                DB["Font Size"] = value
                                UF:Update()
                            end
                        }
                    }
                },
                auras = {
                    order = 6,
                    type = "group",
                    name = "Auras",
                    inline = true,
                    disabled = _disabled,
                    args = {
                        personal = {
                            order = 7,
                            type = "toggle",
                            name = "Player Auras",
                            desc = 'Only display buffs/debuffs cast by self',
                            width = "full",
                            get = function()
                                return DB["Buffs Cast by Me"]
                            end,
                            set = function(_, value)
                                DB["Buffs Cast by Me"] = value
                            end
                        },
                        buffsize = {
                            type = "range",
                            name = "Buff Size",
                            desc = "Changes the target buff size",
                            order = 8,
                            min = 10,
                            max = 50,
                            step = 0.1,
                            bigStep = 1,
                            get = function()
                                return DB["Buff Size"]
                            end,
                            set = function(_, value)
                                DB["Buff Size"] = value
                            end
                        },
                        debuffsize = {
                            type = "range",
                            name = "Debuff Size",
                            desc = "Changes the target buff size",
                            order = 9,
                            min = 10,
                            max = 50,
                            step = 0.1,
                            bigStep = 1,
                            get = function()
                                return DB["Debuff Size"]
                            end,
                            set = function(_, value)
                                DB["Debuff Size"] = value
                            end
                        }
                    }
                }
            }
        }

        --[[
    ################################################################
    #################     Chat Command             #################
    ################################################################
    ]] --

        RP:RegisterForEvent("PLAYER_LOGIN", function()
            if RP:AddOnIsLoaded("RUF", "ShadowUF", "ElvUI") then
                return
            end
            for fontName, fontPath in pairs(RP.UI.LSM:HashTable("font")) do
                LSM_Font[fontName] = fontName
            end
            for statusName, statusPath in pairs(RP.UI.LSM:HashTable("statusbar")) do
                LSM_Statusbar[statusName] = statusName
            end
            RP.options.args.Options.args.Unitframe = options
            UF:Initialize()

            SLASH_RASPORTUNITFRAMES1 = "/uf"
            SLASH_RASPORTUNITFRAMES2 = "/rasuf"
            SlashCmdList["RASPORTUNITFRAMES"] = function(msg)
                local cmd, rest = strsplit(" ", msg, 2)
                cmd = strlower(cmd)

                if cmd == "style" or cmd == "improve" then
                    DB["Improved"] = not DB["Improved"]
                    ReloadUI()
                elseif cmd == "config" or cmd == "options" then
                    RP:OpenConfig("Options", "Unitframe")
                else
                    RP:Print("Acceptable commands for: |caaf49141/uf|r")
                    local helpStr = "|cffffd700%s|r: %s"
                    RP:Print(helpStr:format("style, improve", "Enables improved unit frames textures."))
                    RP:Print(helpStr:format("config", "Access module settings."))
                end
            end
        end)

    end)
