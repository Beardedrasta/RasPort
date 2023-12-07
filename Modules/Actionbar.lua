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
local _, P, U, C = RP:Unpack() -- m, p, u, c
RP:AddModule("Actionbar", "Action bar modifications within blizzard standard", function()
    if RP:IsDisabled("Actionbar") then
        return
    end

    local _G = getfenv(0)
    local CreateFrame = _G.CreateFrame
    local insert = _G.table.insert
    local UnitInVehicle = _G.UnitInVehicle

    local L = U.L
    local DB = RP.db.profile.actionbar
    local UPDATE_DELAY = .2
    local buttonColors, buttonsToUpdate = {}, {}
    local updater = CreateFrame("Frame")
    local colorTable = {
        gold = {1, 0.81960791349411, 0, 1},
        turq = {0.251, 0.878, 0.816, 1}
    }
    local colors = {
        ["normal"] = {1, 1, 1},
        ["oor"] = {.8, .1, .1},
        ["oom"] = {.5, .5, 1},
        ["unusable"] = {.3, .3, .3}
    }

    local AB = RP.Actionbar or CreateFrame("Frame")
    local rpMicro = CreateFrame("Frame", "RasPortMicroParent", CharacterMicroButton, "BackdropTemplate")
    local xpbg = CreateFrame("Frame", "XPBG", MainMenuExpBar, "BackdropTemplate")
    local rpbg = CreateFrame("Frame", "XPBG", ReputationWatchBar, "BackdropTemplate")
    AB:SetScript("OnEvent", function(self, event, ...)
        self[event](self, ...)
    end)

    RP.Actionbar = AB
    LibStub("AceHook-3.0"):Embed(AB)

    local pairs, ipairs, _, next = _G.pairs, _G.ipairs, _G.type, _G.next
    local HasAction = _G.HasAction
    local IsActionInRange = _G.IsActionInRange
    local IsUsableAction = _G.IsUsableAction

    --[[
    ################################################################
    #################           Functions          #################
    ################################################################
    ]] --

    local function hide(frame, texture)
        if not frame then
            return
        end

        if texture and texture == 1 and frame.SetTexture then
            frame:SetTexture("")
        elseif texture and texture == 2 and frame.SetNormalTexture then
            frame:SetNormalTexture("")
        else
            frame:ClearAllPoints()
            frame.Show = function()
                return
            end
            frame:Hide()
            frame:SetPoint("BOTTOM", UIParent, 0, -1000)
        end
    end

    local function noFunc()
        return
    end

    local function Show(frame)
        if frame and frame.Show then
            frame:Show()
        end
    end

    local function Hide(frame)
        if frame and frame.Hide then
            frame:Hide()
        end
    end

    local function InVehicle()
        return UnitInVehicle("player")
    end

    local function borderColor(f)
        if RP["Class"] then
            f:SetBackdropBorderColor(P.userClassColor.r, P.userClassColor.g, P.userClassColor.b)
        elseif RP["Blackout"] then
            f:SetBackdropBorderColor(0.15, 0.15, 0.15)
        elseif RP["Custom Color"] then
            f:SetBackdropBorderColor(RP["CC"].red, RP["CC"].green, RP["CC"].blue)
        elseif not RP["Class"] and not RP["Blackout"] and not RP["Custom Color"] then
            f:SetBackdropBorderColor(1, 1, 1)
        end
    end

    local function SetColorByProfile()
        if DB["Class"] then
            return P.userClassColor.r, P.userClassColor.g, P.userClassColor.b
        elseif DB["Blackout"] then
            return 0.15, 0.15, 0.15
        elseif DB["Custom Color"] then
            return DB["CC"].red, DB["CC"].green, DB["CC"].blue
        end
        return 1, 0, 0
    end

    local r, g, b = SetColorByProfile()

    function RP:BorderColorAccept()
        local frames = {rpMicro.border, xpbg.border, rpbg.border}
        local p = RP.db.profile
        for _, frame in pairs(frames) do
            if p["Class"] then
                frame:SetBackdropBorderColor(P.userClassColor.r, P.userClassColor.g, P.userClassColor.b, 1)
            elseif p["Blackout"] then
                frame:SetBackdropBorderColor(0.15, 0.15, 0.15, 1)
            elseif p["Custom Color"] then
                frame:SetBackdropBorderColor(p["CC"].red, p["CC"].green, p["CC"].blue, 1)
            end
        end
    end

    --[[
    ################################################################
    #################           Gryphons           #################
    ################################################################
    ]] --

    function RP:ActionBars_Gryphons()
        if DB["Hide Gryphons"] then
            _G.MainMenuBarLeftEndCap:Hide()
            _G.MainMenuBarRightEndCap:Hide()
        else
            _G.MainMenuBarLeftEndCap:Show()
            _G.MainMenuBarRightEndCap:Show()
        end
    end

    --[[
    ################################################################
    #################           Keybinds           #################
    ################################################################
    ]] --

    function RP:ActionBars_Hotkeys()
        local opacity
        opacity = opacity or DB["Keybinds"] or 1
        local mopacity = opacity / 1.2
        for i = 1, 12 do
            _G["ActionButton" .. i .. "HotKey"]:SetAlpha(opacity)
            _G["MultiBarBottomRightButton" .. i .. "HotKey"]:SetAlpha(opacity)
            _G["MultiBarBottomLeftButton" .. i .. "HotKey"]:SetAlpha(opacity)
            _G["MultiBarRightButton" .. i .. "HotKey"]:SetAlpha(opacity)
            _G["MultiBarLeftButton" .. i .. "HotKey"]:SetAlpha(opacity)

            _G["ActionButton" .. i .. "Name"]:SetAlpha(mopacity)
            _G["MultiBarBottomRightButton" .. i .. "Name"]:SetAlpha(mopacity)
            _G["MultiBarBottomLeftButton" .. i .. "Name"]:SetAlpha(mopacity)
            _G["MultiBarRightButton" .. i .. "Name"]:SetAlpha(mopacity)
            _G["MultiBarLeftButton" .. i .. "Name"]:SetAlpha(mopacity)
        end
    end

    --[[
    ################################################################
    #################           Mouseover          #################
    ################################################################
    ]] --

    local function MouseOver_OnUpdate(self, elapsed)
        self.lastUpdate = self.lastUpdate + elapsed
        if self.lastUpdate > 0.5 then
            self:SetAlpha(MouseIsOver(self) and 1 or 0)
        end
    end

    function RP:ActionBars_MouseOver()
        local bars = {}
        if DB["Bottom Actionbars"] then
            insert(bars, MultiBarBottomLeft)
            insert(bars, MultiBarBottomRight)
            insert(bars, StanceButton1)
            insert(bars, StanceButton2)
            insert(bars, StanceButton3)
            insert(bars, StanceButton4)
            insert(bars, StanceButton5)
            insert(bars, StanceButton6)
        end
        if DB["Side Actionbars"] then
            insert(bars, MultiBarLeft)
            insert(bars, MultiBarRight)
        end
        if DB["Bottom Actionbars"] or DB["Side Actionbars"] then
            for _, frame in ipairs(bars) do
                if frame:IsShown() then
                    frame.lastUpdate = 0
                    frame:SetScript("OnUpdate", MouseOver_OnUpdate)
                else
                    frame:SetScript("OnUpdate", nil)
                end
            end
        else
            for _, frame in ipairs({MultiBarLeft, MultiBarRight, MultiBarBottomLeft, MultiBarBottomRight,
                                    StanceBarFrame, StanceButton1, StanceButton2, StanceButton3, StanceButton4,
                                    StanceButton5, StanceButton6}) do
                if frame:IsShown() and frame.lastUpdate then
                    frame.lastUpdate = nil
                    frame:SetScript("OnUpdate", nil)
                    frame:SetAlpha(1)
                end
            end
        end
    end

    --[[
    ################################################################
    #################           Reduced            #################
    ################################################################
    ]] --

    function RP:actionbarOnEnable()
        if InCombatLockdown() or not DB["Reduced"] then
            return
        end

        -- frames that i will hide
        local frames = { -- actionbar paging
        MainMenuBarPageNumber, ActionBarUpButton, ActionBarDownButton, -- xp and reputation bar
        MainMenuXPBarTexture2, MainMenuXPBarTexture3, ReputationWatchBarTexture2, ReputationWatchBarTexture3,
        ReputationWatchBarTexture0, ReputationWatchBarTexture1, ReputationWatchBar.StatusBar.XPBarTexture0,
        ReputationWatchBar.StatusBar.XPBarTexture3, ReputationWatchBar.StatusBar.XPBarTexture2,
        ReputationWatchBar.StatusBar.WatchBarTexture2, ReputationWatchBar.StatusBar.WatchBarTexture1,
        ReputationWatchBar.StatusBar.WatchBarTexture3, ReputationWatchBar.StatusBar.WatchBarTexture0, KeyRingButton,
        -- actionbar backgrounds
        MainMenuBarTexture2, MainMenuBarTexture3, MainMenuMaxLevelBar2, MainMenuMaxLevelBar3,
        MainMenuBarTextureExtender, -- shapeshift backgrounds
        ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight, StanceBarLeft, StanceBarRight}

        -- textures that i will set empty
        local textures = {ReputationWatchBarTexture2, ReputationWatchBarTexture3, ReputationXPBarTexture2,
                          ReputationXPBarTexture3, SlidingActionBarTexture0, SlidingActionBarTexture1}

        -- button textures that i will set empty
        local normtextures = {ShapeshiftButton1, ShapeshiftButton2, ShapeshiftButton3, ShapeshiftButton4,
                              ShapeshiftButton5, ShapeshiftButton6}

        -- elements that i will resize to 511px
        local resizes = {MainMenuBar, MainMenuExpBar, MainMenuBarMaxLevelBar, ReputationWatchBar.StatusBar,
                         ReputationWatchStatusBar, ReputationWatchBar, ExhaustionLevelFillBar}

        -- hide frames
        for id, frame in pairs(frames) do
            hide(frame)
        end

        -- clear textures
        for id, frame in pairs(textures) do
            hide(frame, 1)
        end
        for id, frame in pairs(normtextures) do
            hide(frame, 2)
        end

        -- resize actionbar
        for id, frame in pairs(resizes) do
            frame:SetWidth(500)
        end

        --[[             -- move castbar ontop of other bars
            local anchor = MainMenuBarArtFrame
            anchor = MultiBarBottomLeft:IsVisible() and MultiBarBottomLeft or anchor
            anchor = MultiBarBottomRight:IsVisible() and MultiBarBottomRight or anchor
            local pet_offset = PetActionBarFrame:IsVisible() and 40 or 0
            CastingBarFrame:SetPoint("BOTTOM", anchor, "TOP", 0, 10 + pet_offset) ]]
    end

    function RP:ActionBarReduced_OnEnable()
        if DB["Reduced"] then
            if InVehicle() then
                return
            end
            local size = DB.buttons.size
            local spacing = 5
            MainMenuBar:SetWidth(1)

            local reduced = CreateFrame("Frame", nil)
            reduced:EnableMouse(false)
            reduced:Hide()

            local Hide = {MainMenuBarArtFrameBackground, MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2,
                          MainMenuBarTexture3, ActionBarUpButton, ActionBarDownButton, ReputationWatchBar,
                          ArtifactWatchBar, HonorWatchBar, MainMenuBarPageNumber,
                          MainMenuBarPerformanceBar, MainMenuBarPerformanceBarFrameButton, SlidingActionBarTexture0,
                          SlidingActionBarTexture1, MainMenuMaxLevelBar0, MainMenuMaxLevelBar1, MainMenuMaxLevelBar2,
                          MainMenuMaxLevelBar3, StanceButton1.bg, StanceButton2.bg, StanceButton3.bg, StanceButton4.bg,
                          StanceButton5.bg, StanceButton6.bg, StanceButton7.bg, StanceButton8.bg, StanceBarLeft,
                          StanceBarMiddle, StanceBarRight}

            for _, frame in pairs(Hide) do
                frame:SetParent(reduced)
            end

            local anchor = CreateFrame("Frame", "BarAchor", UIParent)
            anchor:SetSize(size * 12 + spacing * 11, size)
            anchor:SetPoint("BOTTOM", UIParent, -150, 22)
            AB.anchor = anchor

            -- move gryphon textures
            MainMenuBarLeftEndCap:ClearAllPoints()
            MainMenuBarLeftEndCap:SetPoint("LEFT", MainMenuBarArtFrame, "LEFT", -10, 55)
            MainMenuBarRightEndCap:ClearAllPoints()
            MainMenuBarRightEndCap:SetPoint("RIGHT", MainMenuBarArtFrame, "RIGHT", 8, 55)


            local function updatePositions()
                ActionButton1:ClearAllPoints()
                ActionButton1:SetPoint("BOTTOMLEFT", anchor, 0, 0)

                MultiBarBottomLeftButton1:ClearAllPoints()
                MultiBarBottomLeftButton1:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, 5)

                MultiBarBottomRightButton1:ClearAllPoints()
                MultiBarBottomRightButton1:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton1, "TOPLEFT", 0, 6)

                MultiBarBottomRightButton7:ClearAllPoints()
                MultiBarBottomRightButton7:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton7, "TOPLEFT", 0, 6)

                MultiBarLeftButton1:ClearAllPoints()
                MultiBarLeftButton1:SetPoint("TOPLEFT", MultiBarRightButton1, "TOPLEFT", -43, 0)

                MultiBarRightButton1:ClearAllPoints()
                MultiBarRightButton1:SetPoint("RIGHT", UIParent, "RIGHT", -2, 150)

                MainMenuExpBar:ClearAllPoints()
                MainMenuExpBar:Show()
                MainMenuExpBar:SetPoint("CENTER", MainMenuBar, "CENTER", 0, -14)

                -- Get Player class
                local playerClass = UnitClass("player")

                -- Pet Action Bar
                if (SHOW_MULTI_ACTIONBAR_2) then
                    if (playerClass == "Druid") then
                        PetActionButton1:ClearAllPoints()
                        PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 3, 11)
                    elseif (playerClass == "Death Knight") then
                        PetActionButton1:ClearAllPoints()
                        PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 150, 5)
                    else
                        PetActionButton1:ClearAllPoints()
                        PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 3, 11)
                    end
                elseif (SHOW_MULTI_ACTIONBAR_1) then
                    if (playerClass == "Druid") then
                        PetActionButton1:ClearAllPoints()
                        PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 3, -33)
                    elseif (playerClass == "Death Knight" or playerClass == "Paladin") then
                        PetActionButton1:ClearAllPoints()
                        PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 150, -35)
                    else
                        PetActionButton1:ClearAllPoints()
                        PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 3, -33)
                    end
                else
                    if (playerClass == "Druid") then
                        PetActionButton1:ClearAllPoints()
                        PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 3, -75)
                    elseif (playerClass == "Death Knight") then
                        PetActionButton1:ClearAllPoints()
                        PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 150, -73)
                    else
                        PetActionButton1:ClearAllPoints()
                        PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 3, -75)
                    end
                end

                -- Stance Bar
                StanceButton2:SetPoint("TOPLEFT", StanceButton1, 32.5, 0)
                StanceButton3:SetPoint("TOPLEFT", StanceButton1, 65, 0)
                StanceButton4:SetPoint("TOPLEFT", StanceButton1, 97.5, 0)
                StanceButton5:SetPoint("TOPLEFT", StanceButton1, 130, 0)
                StanceButton6:SetPoint("TOPLEFT", StanceButton1, 162.5, 0)
                StanceButton7:SetPoint("TOPLEFT", StanceButton1, 195, 0)
                StanceButton8:SetPoint("TOPLEFT", StanceButton1, 227.5, 0)

                StanceBarFrame:SetMovable(true)
                StanceBarFrame:ClearAllPoints()
                StanceBarFrame:SetUserPlaced(true)
                if (SHOW_MULTI_ACTIONBAR_2) then
                    if (playerClass == "Druid") then
                        StanceBarFrame:SetPoint("TOPLEFT", MultiBarBottomRightButton1, "TOPLEFT", -8, 35)
                    else
                        StanceBarFrame:SetPoint("TOPLEFT", MultiBarBottomRightButton1, "TOPLEFT", -8, 35)
                    end
                elseif (SHOW_MULTI_ACTIONBAR_1) then
                    if (playerClass == "Druid") then
                        StanceBarFrame:SetPoint("TOPLEFT", MultiBarBottomRightButton1, "TOPLEFT", -8, 30)
                    else
                        StanceBarFrame:SetPoint("TOPLEFT", MultiBarBottomRightButton1, "TOPLEFT", -8, -5)
                    end
                else
                    if (playerClass == "Druid") then
                        StanceBarFrame:SetPoint("TOPLEFT", MultiBarBottomRightButton1, "TOPLEFT", -8, -12)
                    else
                        StanceBarFrame:SetPoint("TOPLEFT", MultiBarBottomRightButton1, "TOPLEFT", -8, -45)
                    end
                end
            end
            updatePositions()
            hooksecurefunc("SetActionBarToggles", updatePositions)

            -- Shaman Totem Bar
            --[[ local fixing -- flag to prevent infinite looping
        hooksecurefunc(MultiCastActionBarFrame, "SetPoint", function()
            -- if this call came from your hook, or you're in combat, exit:
            if fixing or InCombatLockdown() then
                return
            end
            -- set the flag so our SetPoint call doesn't trigger an infinite loop:
            fixing = true
            -- move the frame as desired:
            if (SHOW_MULTI_ACTIONBAR_2) then
                MultiCastActionBarFrame:ClearAllPoints()
                MultiCastActionBarFrame:SetPoint("TOPLEFT", MultiBarBottomRightButton1, "TOPLEFT", 0, 45)
            elseif (SHOW_MULTI_ACTIONBAR_1) then
                MultiCastActionBarFrame:ClearAllPoints()
                MultiCastActionBarFrame:SetPoint("TOPLEFT", MultiBarBottomRightButton1, "TOPLEFT", 0, 0)
            else
                MultiCastActionBarFrame:ClearAllPoints()
                MultiCastActionBarFrame:SetPoint("TOPLEFT", MultiBarBottomRightButton1, "TOPLEFT", 0, -45)
            end
            -- unset the flag so the next call from Blizzard code will trigger your hook:
            fixing = nil
        end) ]]

            --[[ for i = 1, NUM_ACTIONBAR_BUTTONS do
            local ab = _G["ActionButton" .. i]
            local mbbl = _G["MultiBarBottomLeftButton" .. i]
            local mbbr = _G["MultiBarBottomRightButton" .. i]
            local mbl = _G["MultiBarLeftButton" .. i]
            local mbr = _G["MultiBarRightButton" .. i]
            local pab = _G["PetActionButton" .. i]
            local mcab = _G["MultiCastActionButton" .. i]
            local pb = _G["PossessButton" .. i]

            ab:SetSize(size, size)
            mbbl:SetSize(size, size)
            mbbr:SetSize(size, size)
            mbl:SetSize(size, size)
            mbr:SetSize(size, size)

            if pab then
                -- pab:SetSize(size, size)
            end

            if pb then
                pb:SetSize(size, size)
            end
        end ]]

            if UnitLevel("player") < SHOW_SPEC_LEVEL and RP:IsDisabled("Micro") then
                CharacterMicroButton:ClearAllPoints()
                CharacterMicroButton:SetPoint("BOTTOMRIGHT", MicroButtonAndBagsBar, -230, 5.5)

                local moving
                hooksecurefunc(CharacterMicroButton, "SetPoint", function(self)
                    if moving or InCombatLockdown() then
                        return
                    end
                    moving = true
                    self:ClearAllPoints()
                    self:SetPoint("BOTTOMRIGHT", MicroButtonAndBagsBar, -230, 5.5)
                    moving = nil
                end)
            elseif RP:IsDisabled("Micro") then
                CharacterMicroButton:ClearAllPoints()
                CharacterMicroButton:SetPoint("BOTTOMRIGHT", MicroButtonAndBagsBar, -250, 5.5)

                local moving
                hooksecurefunc(CharacterMicroButton, "SetPoint", function(self)
                    if moving or InCombatLockdown() then
                        return
                    end
                    moving = true
                    self:ClearAllPoints()
                    self:SetPoint("BOTTOMRIGHT", MicroButtonAndBagsBar, -250, 5.5)
                    moving = nil
                end)
            end

            if RP:IsDisabled("Micro") then

            rpMicro:SetHeight(CharacterMicroButton:GetHeight())
            rpMicro:SetPoint("TOPLEFT", CharacterMicroButton, -7, -13)
            rpMicro:SetPoint("BOTTOMRIGHT", HelpMicroButton, 7, -7)
            rpMicro:SetBackdrop({
                bgFile = "Interface\\HELPFRAME\\DarkSandstone-Tile",
                "REPEAT",
                "REPEAT",
                tile = true,
                tileSize = 8,
                insets = {
                    left = 5,
                    right = 5,
                    top = 5,
                    bottom = 5
                }
            })
            rpMicro:SetFrameLevel(0)
            rpMicro:SetFrameStrata("BACKGROUND")
            rpMicro:SetBackdropColor(1, 0.15, 0.15, 1)

            rpMicro.border = CreateFrame("Frame", nil, rpMicro, "BackdropTemplate")
            rpMicro.border:SetBackdrop({
                edgeFile = "Interface\\AddOns\\RasPort\\Media\\Border\\border-modified.tga",
                tileEdge = true,
                edgeSize = 10,
                insets = {
                    left = 6,
                    right = 6,
                    top = 6,
                    bottom = 6
                }
            })
            rpMicro.border:SetFrameLevel(rpMicro:GetFrameLevel() + 1)
            rpMicro.border:SetPoint("TOPLEFT", rpMicro, "BOTTOMRIGHT", -4, 4)
            rpMicro.border:SetPoint("BOTTOMRIGHT", rpMicro, "TOPLEFT", 4, -4)
            rpMicro.border:SetBackdropBorderColor(r, g, b, 1)
            end

            -- Bag buttons
            MainMenuBarBackpackButton:ClearAllPoints()
            MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", MicroButtonAndBagsBar, -5, 50)

            if (RP.db.profile.actionbar.menu.mouseovermicro) then
                -- MicroMenu
                local ignore

                local function setAlphaMicroMenu(b, a)
                    if ignore then
                        return
                    end
                    ignore = true
                    if b:IsMouseOver() then
                        b:SetAlpha(1)
                        rpMicro:SetAlpha(1)
                    else
                        b:SetAlpha(0)
                        rpMicro:SetAlpha(0)
                    end
                    ignore = nil
                end

                local function showMicroMenu(self)
                    for _, v in ipairs(MICRO_BUTTONS) do
                        ignore = true
                        _G[v]:SetAlpha(1)
                        rpMicro:SetAlpha(1)
                        ignore = nil
                    end
                end

                local function hideMicroMenu(self)
                    for _, v in ipairs(MICRO_BUTTONS) do
                        ignore = true
                        _G[v]:SetAlpha(0)
                        rpMicro:SetAlpha(0)
                        ignore = nil
                    end
                end

                for _, v in ipairs(MICRO_BUTTONS) do
                    v = _G[v]
                    hooksecurefunc(v, "SetAlpha", setAlphaMicroMenu)
                    v:HookScript("OnEnter", showMicroMenu)
                    v:HookScript("OnLeave", hideMicroMenu)
                    v:SetAlpha(0)
                end
            end

            local BagButtons = {MainMenuBarBackpackButton, CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot,
                                CharacterBag3Slot, MainMenuBarBackpackButton.Back, CharacterBag0Slot.Back,
                                CharacterBag1Slot.Back, CharacterBag2Slot.Back, CharacterBag3Slot.Back, KeyRingButton,
                                KeyRingButton.Back}

            if (RP.db.profile.actionbar.menu.mouseoverbags) then
                -- Bags bar
                for _, frame in pairs(BagButtons) do
                    frame:SetAlpha(0)
                    frame:SetScript('OnEnter', function()
                        MainMenuBarBackpackButton:SetAlpha(1)
                        CharacterBag0Slot:SetAlpha(1)
                        CharacterBag1Slot:SetAlpha(1)
                        CharacterBag2Slot:SetAlpha(1)
                        CharacterBag3Slot:SetAlpha(1)
                        KeyRingButton:SetAlpha(1)
                    end)
                    frame:SetScript('OnLeave', function()
                        if not (MouseIsOver(frame)) then
                            MainMenuBarBackpackButton:SetAlpha(0)
                            CharacterBag0Slot:SetAlpha(0)
                            CharacterBag1Slot:SetAlpha(0)
                            CharacterBag2Slot:SetAlpha(0)
                            CharacterBag3Slot:SetAlpha(0)
                            KeyRingButton:SetAlpha(0)
                        end
                    end)
                end
            end
            -- RP:UpdateBackdropColor(rpMicro)

            --[[              for _, btn in pairs(MICRO_BUTTONS) do
            btn:SetParent(rpMicro)
        end ]]
            -- Move Micro Menu and Bags
            --[[             CharacterMicroButton:ClearAllPoints()
        CharacterMicroButton:SetPoint("LEFT", rpMicro, 8, 10)
        CharacterMicroButton:SetScale(1)

        MainMenuBarBackpackButton:ClearAllPoints()
        MainMenuBarBackpackButton:SetParent(rpMicro)
        MainMenuBarBackpackButton:SetPoint("LEFT", rpMicro, -35, 0)
        MainMenuBarBackpackButton:SetScale(1)

        CharacterBag0Slot:SetParent(rpMicro)
        CharacterBag1Slot:SetParent(rpMicro)
        CharacterBag2Slot:SetParent(rpMicro)
        CharacterBag3Slot:SetParent(rpMicro)
        KeyRingButton:SetParent(rpMicro) ]]

            local scaleFactor = RP.db.profile.theme["Scale"]

            -- experience bar
            MainMenuExpBar:SetStatusBarTexture("Interface\\AddOns\\RasPort\\Media\\Statusbar\\Default.tga")

            -- reputation bar
            ReputationWatchBar.StatusBar.XPBarTexture0:SetAlpha(0)

            -- action bar bg
            xpbg:SetFrameStrata("MEDIUM")
            xpbg:SetPoint("CENTER", MainMenuExpBar, 0, 0)
            xpbg:SetSize(MainMenuExpBar:GetWidth()/2, 25)
            xpbg.bd = CreateFrame("Frame", nil, xpbg, "BackdropTemplate")
            xpbg.bd:SetBackdrop({
                bgFile = "Interface\\AddOns\\RasPort\\Media\\Background\\UI-Background-Rock.blp",
                tile = false,
                tileSize = 8,
                insets = {
                    left = 5,
                    right = 5,
                    top = 5,
                    bottom = 5
                }
            })
            xpbg.bd:SetFrameLevel(0)
            xpbg.bd:SetFrameStrata("BACKGROUND")
            xpbg.bd:SetBackdropColor(0.1, 0.1, 0.1, 1)
            xpbg.bd:SetAllPoints(xpbg)
            xpbg.border = CreateFrame("Frame", nil, xpbg, "BackdropTemplate")
            xpbg.border:SetBackdrop({
                edgeFile = "Interface\\AddOns\\RasPort\\Media\\Border\\border-modified.tga",
                tileEdge = true,
                edgeSize = 10,
                insets = {
                    left = 6,
                    right = 6,
                    top = 6,
                    bottom = 6
                }
            })
            xpbg.border:SetFrameLevel(xpbg:GetFrameLevel() + 1)
            xpbg.border:SetPoint("TOPLEFT", xpbg, "BOTTOMRIGHT", -4, 4)
            xpbg.border:SetPoint("BOTTOMRIGHT", xpbg, "TOPLEFT", 4, -4)
            xpbg.border:SetBackdropBorderColor(r, g, b, 1)

            -- action bar bg
            rpbg:SetFrameStrata("MEDIUM")
            rpbg:SetPoint("CENTER", ReputationWatchBar, -1, 1)
            rpbg:SetSize(522, 21)
            rpbg.bd = CreateFrame("Frame", nil, rpbg, "BackdropTemplate")
            rpbg.bd:SetBackdrop({
                bgFile = "Interface\\AddOns\\RasPort\\Media\\Background\\UI-Background-Rock.blp",
                tile = false,
                tileSize = 8,
                insets = {
                    left = 4,
                    right = 4,
                    top = 4,
                    bottom = 4
                }
            })
            rpbg.bd:SetFrameLevel(0)
            rpbg.bd:SetFrameStrata("BACKGROUND")
            rpbg.bd:SetBackdropColor(0.1, 0.1, 0.1, 1)
            rpbg.bd:SetAllPoints(rpbg)
            rpbg.border = CreateFrame("Frame", nil, rpbg, "BackdropTemplate")
            rpbg.border:SetBackdrop({
                edgeFile = "Interface\\AddOns\\RasPort\\Media\\Border\\border-modified.tga",
                tileEdge = true,
                edgeSize = 10,
                insets = {
                    left = 6,
                    right = 6,
                    top = 6,
                    bottom = 6
                }
            })
            rpbg.border:SetFrameLevel(rpbg:GetFrameLevel() + 1)
            rpbg.border:SetPoint("TOPLEFT", rpbg, "BOTTOMRIGHT", -4, 4)
            rpbg.border:SetPoint("BOTTOMRIGHT", rpbg, "TOPLEFT", 4, -4)
            rpbg.border:SetBackdropBorderColor(r, g, b, 1)

            -- action bar empty buttons
            for i = 1, 12 do
                for _, button in pairs({_G['ActionButton' .. i]}) do
                    local t = MainMenuBar:CreateTexture(nil, "OVERLAY", nil, 1)
                    local i = 12
                    t:SetPoint("TOPLEFT", button, "TOPLEFT", -i, i - 1)
                    t:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", i, -i - 1)
                    t:SetTexture("Interface\\AddOns\\RasPort\\Media\\Button\\UI-EmptySlot.blp")
                    t:SetVertexColor(.25, .25, .25, 1)
                end
            end

            borderColor(xpbg)
            borderColor(rpbg)

        end
    end

    function ScaleBars(scale)
        DB = DB or RP.db.profile or {}
        scale = scale or DB.theme["Scale"] or 1
        _G.MainMenuBar:SetScale(scale)
        if AB.anchor then
            AB.anchor:SetScale(scale)
        end
    end

    --[[
    ################################################################
    #################           OutOfRange         #################
    ################################################################
    ]] --

    function UpdateUse(abButton)
        if (abButton.UpdateUsable ~= nil) then
            hooksecurefunc(abButton, "UpdateUsable", function(self)
                local action = self.action;
                local icon = self.icon;
                local isUsable, notEnoughMana = IsUsableAction(action)
                local normalTexture = self.NormalTexture;
                if (not normalTexture) then
                    return;
                end
                if (ActionHasRange(action) and IsActionInRange(action) == false) then
                    icon:SetVertexColor(.5, .1, .1);
                    normalTexture:SetVertexColor(.5, .1, .1);
                    self.RangeColor = true;
                elseif (self.RangeColor) then
                    if (isUsable) then
                        icon:SetVertexColor(1, 1, 1);
                        normalTexture:SetVertexColor(1, 1, 1);
                        self.RangeColor = false;
                    elseif (notEnoughMana) then
                        icon:SetVertexColor(.5, .5, 1);
                        normalTexture:SetVertexColor(.5, .5, 1);
                        self.RangeColor = false;
                    else
                        icon:SetVertexColor(.4, .4, .4);
                        normalTexture:SetVertexColor(1, 1, 1);
                        self.RangeColor = false;
                    end
                end
            end)
        end
    end

    function UpdateRng(self, checksRange, inRange)
        if (checksRange and not inRange) then
            local icon = self.icon;
            local normalTexture = self.NormalTexture;
            icon:SetVertexColor(.5, .1, .1);
            if (normalTexture ~= nil) and (next(normalTexture) ~= nil) then
                normalTexture:SetVertexColor(.5, .1, .1);
            end
            self.RangeColor = true;
        elseif (self.RangeColor) then
            local icon = self.icon;
            local normalTexture = self.NormalTexture;
            local action = self.action;
            if (action) then
                local isUsable, notEnoughMana = IsUsableAction(action)
                if (isUsable) then
                    icon:SetVertexColor(1, 1, 1);
                    if (normalTexture ~= nil) and (next(normalTexture) ~= nil) then
                        normalTexture:SetVertexColor(1, 1, 1);
                    end
                elseif (notEnoughMana) then
                    icon:SetVertexColor(.5, .5, 1);
                    if (normalTexture ~= nil) and (next(normalTexture) ~= nil) then
                        normalTexture:SetVertexColor(.5, .5, 1);
                    end
                else
                    icon:SetVertexColor(.3, .3, .3);
                    if (normalTexture ~= nil) and (next(normalTexture) ~= nil) then
                        normalTexture:SetVertexColor(1, 1, 1);
                    end
                end
            else
                icon:SetVertexColor(1, 1, 1);
                if (normalTexture ~= nil) and (next(normalTexture) ~= nil) then
                    normalTexture:SetVertexColor(1, 1, 1);
                end
            end
            self.RangeColor = false;
        end
    end

    if (not OUTOFRANGE) then
        if DB.buttons["Out of Range"] then
            hooksecurefunc("ActionButton_UpdateRangeIndicator", UpdateRng);
            for i = 1, 12 do
                local actionButton
                actionButton = _G["ExtraActionButton" .. i]
                if (actionButton) then
                    UpdateUse(actionButton)
                end
                actionButton = _G["ActionButton" .. i]
                if (actionButton) then
                    UpdateUse(actionButton)
                end
                actionButton = _G["MultiBarBottomLeftButton" .. i]
                if (actionButton) then
                    UpdateUse(actionButton)
                end
                actionButton = _G["MultiBarBottomRightButton" .. i]
                if (actionButton) then
                    UpdateUse(actionButton)
                end
                actionButton = _G["MultiBarLeftButton" .. i]
                if (actionButton) then
                    UpdateUse(actionButton)
                end
                actionButton = _G["MultiBarRightButton" .. i]
                if (actionButton) then
                    UpdateUse(actionButton)
                end
                actionButton = _G["PetActionButton" .. i]
                if (actionButton) then
                    UpdateUse(actionButton)
                end
                actionButton = _G["StanceButton" .. i]
                if (actionButton) then
                    UpdateUse(actionButton)
                end
                actionButton = _G["PossessButton" .. i]
                if (actionButton) then
                    UpdateUse(actionButton)
                end
                actionButton = _G["OverrideActionBarButton" .. i]
                if (actionButton) then
                    UpdateUse(actionButton)
                end
            end
            OUTOFRANGE = true
        end
    end

    --[[
    ################################################################
    #################           Experience         #################
    ################################################################
    ]] --

    local function CreateFontString(parent, anchorFrame, font, size, outline)
        local string = parent:CreateFontString(nil, "OVERLAY", "GameFontWhite")
        string:SetFont(font, size, outline)
        string:ClearAllPoints()
        string:SetPoint("CENTER", anchorFrame, "CENTER", 0, 2)
        string:SetJustifyH("CENTER")
        string:SetTextColor(1, 1, 1)
        return string
    end

    local exp = CreateFrame("Frame", "RasExp", UIParent)
    local font, size, outline = "Fonts\\frizqt__.TTF", 12, "OUTLINE"

    exp.expstring = CreateFontString(exp, MainMenuExpBar, font, size, outline)
    exp.repstring = CreateFontString(exp, ReputationWatchBar, font, size, outline)

    local expArt = {ExhaustionTick, MainMenuXPBarTexture0, MainMenuXPBarTexture1, MainMenuXPBarTexture2,
                    MainMenuXPBarTexture3, ReputationWatchBarTexture0, ReputationWatchBarTexture1,
                    ReputationWatchBarTexture2, ReputationWatchBarTexture3}

    local isMousing

    local function updateExp(mouseover)
        local playerlevel = UnitLevel("player")
        local xp, xpmax, exh = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion() or 0
        local xp_perc = RP:Round(xp / xpmax * 100)
        local exh_perc = RP:Round(exh / xpmax * 100) or 0
        local remaining = xpmax - xp
        local remaining_perc = RP:Round(remaining / xpmax * 100)
        exh = RP:Abbreviate(exh, 1)
        remaining = RP:Abbreviate(remaining, 1)

        if playerlevel < 60 then
            if (not mouseover) then
                if IsResting() then
                    if exh_perc > 0 then
                        exp.expstring:SetText(exh .. " (" .. exh_perc .. "%) rested")
                    end
                else
                    exp.expstring:SetText("")
                end
            else
                if (exh == 0) then
                    exp.expstring:SetText("Level " .. playerlevel .. " - " .. remaining .. " (" .. remaining_perc ..
                                              "%) remaining")
                else
                    exp.expstring:SetText("Level " .. playerlevel .. " - " .. remaining .. " (" .. remaining_perc ..
                                              "%) remaining - " .. exh .. " (" .. exh_perc .. "%) rested")
                end
            end
        end

        local rested = GetRestState()
        if (rested == 1) then
            if (exh_perc == 150) then
                MainMenuExpBar:SetStatusBarColor(0, 1, 0.6, 1)
            else
                MainMenuExpBar:SetStatusBarColor(0.0, 0.39, 0.88, 1.0)
            end
        elseif (rested == 2) then
            MainMenuExpBar:SetStatusBarColor(0.58, 0.0, 0.55, 1.0)
        end
    end

    local function expShow()
        isMousing = true
        updateExp(isMousing)
        exp.expstring:Show()
    end

    local function expHide()
        isMousing = nil
        if not IsResting() then
            exp.expstring:Hide()
        else
            updateExp(isMousing)
        end
    end

--[[     local function mouseoverExp()
        local expMouse = CreateFrame("Frame", nil, MainMenuExpBar)
        expMouse:SetAllPoints(MainMenuExpBar)
        expMouse:SetFrameStrata("HIGH")
        expMouse:EnableMouse(true)
        expMouse:SetScript("OnEnter", expShow)
        expMouse:SetScript("OnLeave", expHide)
    end ]]

    local function updateResting()
        if IsResting() then
            updateExp(isMousing)
            exp.expstring:Show()
        else
            expHide()
        end
    end

    local function updateRep()
        local name, standing, min, max, value = GetWatchedFactionInfo()
        local max = max - min
        local value = value - min
        local remaining = max - value
        local percent = (value / max) * 100
        local percentFloor = floor(percent + 0.5)
        local repvalues = {"Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted"}
        local level = UnitLevel("player")
        remaining = RP:Round(remaining)
        remaining = RP:Abbreviate(remaining, 1)

        if name then
            -- watching a faction
            exp.repstring:SetText(name .. " (" .. repvalues[standing] .. ") " .. percentFloor .. "% - " .. remaining ..
                                      " remaining")
        else
            exp.repstring:SetText("")
        end
    end

    local function repShow()
        isMousing = true
        updateRep()
        exp.repstring:Show()
    end

    local function repHide()
        isMousing = nil
        exp.repstring:Hide()
    end

--[[     local function mouseoverRep()
        local repMouse = CreateFrame("Frame")
        repMouse:SetAllPoints(ReputationWatchBar)
        repMouse:SetFrameStrata("HIGH")
        repMouse:EnableMouse(true)
        repMouse:SetScript("OnEnter", repShow)
        repMouse:SetScript("OnLeave", repHide)
    end ]]

    local function HideExpArt()
        for _, element in pairs(expArt) do
            element:SetAlpha(0)
        end
    end

    local events = CreateFrame("Frame", nil, UIParent)
    events:RegisterEvent("PLAYER_ENTERING_WORLD")
    events:RegisterEvent("PLAYER_UPDATE_RESTING")
    events:RegisterEvent("UPDATE_EXHAUSTION")
    events:RegisterEvent("PLAYER_XP_UPDATE")
    events:RegisterEvent("UPDATE_FACTION")

    events:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_UPDATE_RESTING" then
            updateResting()
        elseif event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_EXHAUSTION" or event == "PLAYER_XP_UPDATE" or event ==
            "UPDATE_FACTION" then
            updateExp(isMousing)
            HideExpArt()
        end
    end)

    --[[
    ################################################################
    #################           Buttons         #################
    ################################################################
    ]] --

    local tex = {
        norm = "Interface\\Addons\\RasPort\\Media\\Button\\normStyle.tga",
        fl = "Interface\\Addons\\RasPort\\Media\\Button\\flashStyle.tga",
        light = "Interface\\Addons\\RasPort\\Media\\Button\\lightStyle.tga",
        push = "Interface\\Addons\\RasPort\\Media\\Button\\pushStyle.tga",
        check = "Interface\\Addons\\RasPort\\Media\\Button\\checkStyle.tga",
        quip = "Interface\\Addons\\RasPort\\Media\\Button\\quipStyle.tga"
    }

    local col = {
        norm = {
            r = 0.37,
            g = 0.37,
            b = 0.37,
            a = 1
        },
        quip = {
            r = 0.1,
            g = 0.5,
            b = 0.1,
            a = 1
        }
    }

    local function Style_Button(name)
        if not name or not _G[name] or _G[name].kpacked then
            return
        end
        _G[name].kpacked = true
        local btn = _G[name]

        -- crop icon
        local t = _G[name .. "Icon"]
        if t then
            t:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            t:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
            t:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
        end

        -- remove border
        t = _G[name .. "Border"]
        if t then
            t:ClearAllPoints()
            t:SetAllPoints(btn)
            t:SetTexture(tex.quip)
            if btn.action and IsEquippedAction(btn.action) then
                t:SetVertexColor(col.quip.r, col.quip.g, col.quip.b, col.quip.a)
                t:Show()
            elseif btn.action then
                t:Hide()
            end
            local _SetVertexColor = t.SetVertexColor
            t.SetVertexColor = function(self, r, g, b, a)
                if btn.action and IsEquippedAction(btn.action) then
                    _SetVertexColor(self, col.quip.r, col.quip.g, col.quip.b, col.quip.a)
                else
                    _SetVertexColor(self, r, g, b, a)
                end
            end
        end

        -- position cooldown
        t = _G[name .. "Cooldown"]
        if t then
            t:SetAllPoints(btn)
        end

        -- flash texture
        t = _G[name .. "Flash"]
        if t then
            t:SetTexture(tex.fl)
        end

        -- normal texture
        t = _G[name .. "NormalTexture2"] or _G[name .. "NormalTexture"] or btn.GetNormalTexture and
                btn:GetNormalTexture()
        if t then
            if btn.action and IsEquippedAction(btn.action) then
                t:SetVertexColor(col.quip.r, col.quip.g, col.quip.b, col.quip.a)
            else
                t:SetVertexColor(1, 1, 1, 1)
            end
            t:SetAllPoints(btn)
            hooksecurefunc(t, "SetVertexColor", function(self, r, g, b, a)
                local bn = self:GetParent()
                if r == 1 and g == 1 and b == 1 and bn.action and (IsEquippedAction(btn.action)) then
                    if col.quip.r == 1 and col.quip.g == 1 and col.quip.b == 1 then
                        self:SetVertexColor(0.99, 0.99, 0.99, 1)
                    else
                        self:SetVertexColor(col.quip.r, col.quip.g, col.quip.b, col.quip.a)
                    end
                elseif r == 0.5 and g == 0.5 and b == 1 then
                    if col.norm.r == 0.5 and col.norm.g == 0.5 and col.norm.b == 1 then
                        self:SetVertexColor(0.49, 0.49, 0.99, 1)
                    else
                        self:SetVertexColor(col.norm.r, col.norm.g, col.norm.b, col.norm.a or 1)
                    end
                elseif r == 1 and g == 1 and b == 1 then
                    if col.norm.r == 1 and col.norm.g == 1 and col.norm.b == 1 then
                        self:SetVertexColor(0.99, 0.99, 0.99, 1)
                    else
                        self:SetVertexColor(col.norm.r, col.norm.g, col.norm.b, col.norm.a or 1)
                    end
                end
            end)
        end

        -- normal texture
        if btn.SetNormalTexture then
            btn:SetNormalTexture(tex.norm)
            hooksecurefunc(btn, "SetNormalTexture", function(self, texture)
                if texture and texture ~= tex.norm then
                    self:SetNormalTexture(tex.norm)
                end
            end)
        end

        -- hightlight texture
        if btn.SetHighlightTexture then
            btn:SetHighlightTexture(tex.light)
            hooksecurefunc(btn, "SetHighlightTexture", function(self, texture)
                if texture and texture ~= tex.light then
                    self:SetHighlightTexture(tex.light)
                end
            end)
        end

        -- pushed texture
        if btn.SetPushedtTexture then
            btn:SetPushedtTexture(tex.push)
            hooksecurefunc(btn, "SetPushedtTexture", function(self, texture)
                if texture and texture ~= tex.push then
                    self:SetPushedtTexture(tex.push)
                end
            end)
        end

        -- checked texture
        if btn.SetCheckedTexture then
            btn:SetCheckedTexture(tex.check)
            hooksecurefunc(btn, "SetCheckedTexture", function(self, texture)
                if texture and texture ~= tex.check then
                    self:SetCheckedTexture(tex.check)
                end
            end)
        end
    end

    local function Style_Bag(name, vertex)
        if not name or not _G[name] or _G[name].kpacked then
            return
        end
        _G[name].kpacked = true
        local btn = _G[name]

        -- icon
        local t = _G[name .. "IconTexture"]
        if t then
            t:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            t:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
            t:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
        end

        -- normal texture
        t = _G[name .. "NormalTexture"] or btn:GetNormalTexture()
        if t then
            t:SetTexCoord(0, 1, 0, 1)
            t:SetDrawLayer("BACKGROUND", -7)
            t:SetVertexColor(vertex, vertex, vertex)
            t:SetAllPoints(btn)
        end
        if btn.SetNormalTexture then
            btn:SetNormalTexture(tex.norm)
            hooksecurefunc(btn, "SetNormalTexture", function(self, texture)
                if texture and texture ~= tex.norm then
                    self:SetNormalTexture(tex.norm)
                end
            end)
        end

        -- hightlight texture
        if btn.SetHighlightTexture then
            btn:SetHighlightTexture(tex.light)
            hooksecurefunc(btn, "SetHighlightTexture", function(self, texture)
                if texture and texture ~= tex.light then
                    self:SetHighlightTexture(tex.light)
                end
            end)
        end

        -- pushed texture
        if btn.SetPushedtTexture then
            btn:SetPushedtTexture(tex.push)
            hooksecurefunc(btn, "SetPushedtTexture", function(self, texture)
                if texture and texture ~= tex.push then
                    self:SetPushedtTexture(tex.push)
                end
            end)
        end

        -- checked texture
        if btn.SetCheckedTexture then
            btn:SetCheckedTexture(tex.check)
            hooksecurefunc(btn, "SetCheckedTexture", function(self, texture)
                if texture and texture ~= tex.check then
                    self:SetCheckedTexture(tex.check)
                end
            end)
        end
    end

    local function ApplyStyle()
        for i = 0, NUM_ACTIONBAR_BUTTONS do
            Style_Button("ActionButton" .. i)
            Style_Button("BonusActionButton" .. i)
            Style_Button("MultiBarBottomLeftButton" .. i)
            Style_Button("MultiBarBottomRightButton" .. i)
            Style_Button("MultiBarRightButton" .. i)
            Style_Button("MultiBarLeftButton" .. i)
            Style_Button("ShapeshiftButton" .. i)
            Style_Button("PetActionButton" .. i)
            Style_Button("BuffButton" .. i)
            Style_Button("StanceButton" .. i)

            if i <= 3 then
                Style_Bag("CharacterBag" .. i .. "Slot", 1)
            end
        end
        Style_Bag("MainMenuBarBackpackButton", 1)
        for b = 0, 24 do
            Style_Button("ContainerFrame1Item" .. b)
            Style_Button("ContainerFrame2Item" .. b)
            Style_Button("ContainerFrame3Item" .. b)
            Style_Button("ContainerFrame4Item" .. b)
            Style_Button("ContainerFrame5Item" .. b)
        end
    end

    --[[
    ################################################################
    #################           Search             #################
    ################################################################
    ]] --

    do
    hooksecurefunc("ContainerFrame_Update", function( self )
        if self:GetID() == 0 then
            BagItemSearchBox:SetParent(self)
            BagItemSearchBox:SetPoint("TOPLEFT", self, "TOPLEFT", 55, -29)
            BagItemSearchBox:SetWidth(125)
            BagItemSearchBox.anchorBag = self
            BagItemSearchBox:Show()
        elseif BagItemSearchBox.anchorBag == self then
            BagItemSearchBox:ClearAllPoints()
            BagItemSearchBox:Hide()
            BagItemSearchBox.anchorBag = nil
        end
    end)
    end


    --[[
    ################################################################
    #################           Leave              #################
    ################################################################
    ]] --

    local leaveButton = CreateFrame("Button", "LeavePartyButton", UIParent, "BackdropTemplate")
    leaveButton.text = CreateFontString(leaveButton, leaveButton, font, size, outline)
    leaveButton.text:SetText("Leave Party")
    leaveButton.text:SetTextColor(unpack(colorTable.gold))
    leaveButton:SetSize(130, 30)
    leaveButton:SetPoint("CENTER", UIParent, "CENTER", 0, 300)
    leaveButton:Hide()

    leaveButton:SetNormalTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-norm.tga")
    leaveButton:SetPushedTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-norm.tga")
    leaveButton:SetHighlightTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-pressed.tga")

    -- Create a confirmation dialog frame
    local confirmDialog = CreateFrame("Frame", "LeavePartyConfirmDialog", UIParent, "BasicFrameTemplate")
    confirmDialog:SetSize(300, 110) -- Adjust the height to accommodate the text
    confirmDialog:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    confirmDialog:Hide()

    confirmDialog.title = confirmDialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    confirmDialog.title:SetPoint("TOP", confirmDialog, "TOP", 0, -5)
    confirmDialog.title:SetText("Confirmation")

    confirmDialog.text = confirmDialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    confirmDialog.text:SetPoint("TOPLEFT", confirmDialog, "TOPLEFT", 20, 0)
    confirmDialog.text:SetPoint("BOTTOMRIGHT", confirmDialog, "BOTTOMRIGHT", -20, 10)
    confirmDialog.text:SetText("Are you sure you would like to leave the instance group?") -- Adjust the text as needed

    local acceptButton = CreateFrame("Button", "AcceptButton", confirmDialog, "BackdropTemplate")
    acceptButton.text = CreateFontString(acceptButton, acceptButton, font, size, outline)
    acceptButton.text:SetText("Accept")
    acceptButton.text:SetTextColor(unpack(colorTable.gold))
    acceptButton:SetSize(100, 30)
    acceptButton:SetPoint("BOTTOMLEFT", confirmDialog, "BOTTOMLEFT", 20, 10)
    acceptButton:SetNormalTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-norm.tga")
    acceptButton:SetPushedTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-norm.tga")
    acceptButton:SetHighlightTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-pressed.tga")

    local declineButton = CreateFrame("Button", "DeclineButton", confirmDialog, "BackdropTemplate")
    declineButton.text = CreateFontString(declineButton, declineButton, font, size, outline)
    declineButton.text:SetText("Decline")
    declineButton.text:SetTextColor(unpack(colorTable.gold))
    declineButton:SetSize(100, 30)
    declineButton:SetPoint("BOTTOMRIGHT", confirmDialog, "BOTTOMRIGHT", -20, 10)
    declineButton:SetNormalTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-norm.tga")
    declineButton:SetPushedTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-norm.tga")
    declineButton:SetHighlightTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-pressed.tga")

    acceptButton:SetScript("OnClick", function()
        LeaveParty()
        confirmDialog:Hide()
    end)

    declineButton:SetScript("OnClick", function()
        confirmDialog:Hide()
    end)

    leaveButton:SetScript("OnClick", function()
        confirmDialog:Show()
    end)

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("LFG_COMPLETION_REWARD")

    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "LFG_COMPLETION_REWARD" then
            leaveButton:Show()
        end
    end)

    frame:RegisterEvent("PLAYER_LEAVING_WORLD")
    frame:RegisterEvent("GROUP_LEFT")

    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "LFG_COMPLETION_REWARD" then
            leaveButton:Show()
        elseif event == "PLAYER_LEAVING_WORLD" or event == "GROUP_LEFT" then
            leaveButton:Hide()
        end
    end)

    --[[
    ################################################################
    #################           OneBag             #################
    ################################################################
    ]] --

    local function OneBag()
        if DB["Reduced"] then
            local bagsAreShown = CharacterBag0Slot:IsShown()
            if bagsAreShown and DB["Hide Bags"] then
                CharacterBag0Slot:Hide()
                CharacterBag1Slot:Hide()
                CharacterBag2Slot:Hide()
                CharacterBag3Slot:Hide()
                KeyRingButton:Hide()
            else
                CharacterBag0Slot:Show()
                CharacterBag1Slot:Show()
                CharacterBag2Slot:Show()
                CharacterBag3Slot:Show()
                KeyRingButton:Show()
            end
        end
    end

    --[[
    ################################################################
    #################           Config             #################
    ################################################################
    ]] --

    local function _disabled()
        return not RP.db.profile.actionbar.enabled
    end

    local options = {
        type = "group",
        name = L["Actionbar"],
        order = 3,
        get = function(i)
            return DB[i[#i]]
        end,
        set = function(i, val)
            DB[i[#i]] = val
        end,
        args = {
            enabled = {
                type = "toggle",
                name = L["Enable"],
                order = 0,
                desc = L["Allows you to change the settings, disable to lock settings"]
            },
            toggles = {
                order = 1,
                type = "group",
                name = L["Toggles"],
                disabled = _disabled,
                inline = true,
                args = {
                    HideGryphons = {
                        order = 0,
                        type = "toggle",
                        name = L["Hide Gryphons"],
                        desc = L["Hides the actionbar gryphons"],
                        get = function()
                            return DB["Hide Gryphons"]
                        end,
                        set = function(_, value)
                            DB["Hide Gryphons"] = value
                            RP:ActionBars_Gryphons()
                        end
                    },
                    Reduced = {
                        order = 2,
                        type = "toggle",
                        name = L["Reduced"],
                        desc = "Reduces the actionbars to a more compact style, " ..
                            C.GOLD_COLOR:WrapTextInColorCode("\n\n/reload to apply setting"),
                        get = function()
                            return DB["Reduced"]
                        end,
                        set = function(_, value)
                            DB["Reduced"] = value
                        end
                    },
                    onebag = {
                        order = 4,
                        type = "toggle",
                        name = L["One Bag"],
                        desc = L["Hides the bag buttons"],
                        get = function()
                            return DB["Hide Bags"]
                        end,
                        set = function(_, value)
                            DB["Hide Bags"] = value
                            OneBag()
                        end
                    },
                    range = {
                        order = 5,
                        type = "toggle",
                        name = "Out of Range",
                        desc = "Colors action button red if not in range of current target, This option requires a " ..
                            C.GOLD_COLOR:WrapTextInColorCode("\n\n/reload to enable or disable"),
                        get = function()
                            return DB["Hide Bags"]
                        end,
                        set = function(_, value)
                            DB["Hide Bags"] = value
                            OneBag()
                        end
                    }
                }
            },
            appearance = {
                order = 2,
                type = "group",
                name = L["Appearance"],
                disabled = _disabled,
                inline = true,
                args = {
                    hotkeys = {
                        type = "range",
                        name = L["Keybinds"],
                        desc = L["Changes the visibility of actionbar keybinds"],
                        order = 1,
                        min = 0,
                        max = 1,
                        step = 0.01,
                        bigStep = 0.1,
                        get = function()
                            return DB["Keybinds"]
                        end,
                        set = function(_, value)
                            DB["Keybinds"] = value
                            RP:ActionBars_Hotkeys()
                        end
                    },
                    scale = {
                        type = "range",
                        name = L["Scale"],
                        desc = L["Changes the scale of actionbars"],
                        order = 3,
                        min = 0.5,
                        max = 2,
                        step = 0.01,
                        bigStep = 0.1,
                        get = function()
                            return RP.db.profile.theme["Scale"]
                        end,
                        set = function(_, value)
                            RP.db.profile.theme["Scale"] = value
                            ScaleBars(value)
                        end
                    }
                }
            },
            HoverMode = {
                order = 3,
                type = "group",
                name = L["Hover Mode"],
                disabled = _disabled,
                inline = true,
                args = {
                    BottomActionbar = {
                        order = 1,
                        type = "toggle",
                        name = L["Bottom Actionbars"],
                        desc = L["Hides/Shows the bottom left and bottom right actionbars on mouseover"],
                        get = function()
                            return DB["Bottom Actionbars"]
                        end,
                        set = function(_, value)
                            DB["Bottom Actionbars"] = value
                            RP:ActionBars_MouseOver()
                        end
                    },
                    SideActionbar = {
                        order = 3,
                        type = "toggle",
                        name = L["Side Actionbars"],
                        desc = L["Hides/Shows the side actionbars on mouseover"],
                        get = function()
                            return DB["Side Actionbars"]
                        end,
                        set = function(_, value)
                            DB["Side Actionbars"] = value
                            RP:ActionBars_MouseOver()
                        end
                    },
                    Menu = {
                        order = 4,
                        type = "toggle",
                        name = "Micro Menu",
                        desc = "Hides/Shows the micro menu on mouseover "..
                            C.GOLD_COLOR:WrapTextInColorCode("\n\n/reload to restore micro bar visibility when turned off"),
                        get = function()
                            return DB.menu.mouseovermicro
                        end,
                        set = function(_, value)
                            DB.menu.mouseovermicro = value
                            RP:ActionBarReduced_OnEnable()
                        end
                    },
                    Bags = {
                        order = 5,
                        type = "toggle",
                        name = "Bags",
                        desc = "Hides/Shows the backpack on mouseover "..
                            C.GOLD_COLOR:WrapTextInColorCode("\n\n/reload to restore micro bar visibility when turned off"),
                        get = function()
                            return DB.menu.mouseoverbags
                        end,
                        set = function(_, value)
                            DB.menu.mouseoverbags = value
                            RP:ActionBarReduced_OnEnable()
                        end
                    }
                }
            }
        }
    }

    RP:RegisterForEvent("PLAYER_ENTERING_WORLD", function()
        RP:ActionBars_MouseOver()
        RP:actionbarOnEnable()
        ScaleBars(RP.db.profile.theme["Scale"])
--[[         mouseoverExp() ]]
        --[[ mouseoverRep() ]]
        ApplyStyle()
    end)

    RP:RegisterForEvent("UNIT_AURA", ApplyStyle)

    RP:RegisterForEvent("PLAYER_LOGIN", function()
        RP.options.args.Options.args.Actionbar = options
        RP:ActionBars_Gryphons()
        RP:ActionBars_Hotkeys()
        RP:ActionBars_MouseOver()
        RP:ActionBarReduced_OnEnable()
        RP:BorderColorAccept()
        HideExpArt()
        OneBag()
        updateExp(isMousing)

        SLASH_RASPORTACTIONBAR1 = "/raction"
        SlashCmdList["RASPORTACTIONBAR"] = function()
            RP:OpenConfig("Options", "Actionbar")
        end
    end)
end)
