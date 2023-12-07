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
local _, P, _, C = RP:Unpack() -- m, p, u, c
RP:AddModule("Theme", "UI Theme, and style change when in reduced mode", function(L)
    if RP:IsDisabled("Theme") then
        return
    end

    -- API
    local _G = getfenv(0)
    local CreateFrame = _G.CreateFrame
    local insert = _G.table.insert
    local pairs = _G.pairs
    local pi, sin = _G.math.pi, _G.math.sin
    local UnitInVehicle = _G.UnitInVehicle

    -- Config
    local DB = RP.db.profile
    local doneInit
    local addonpath = "Interface\\AddOns\\RasPort"
    local sections = {'TOPLEFT', 'TOPRIGHT', 'BOTTOMLEFT', 'BOTTOMRIGHT', 'TOP', 'BOTTOM', 'LEFT', 'RIGHT'}
    local colorTable = {
        gold = {1, 0.81960791349411, 0, 1},
        turq = {0.251, 0.878, 0.816, 1}
    }

    -- Setup
    local TM = RP.Theme or CreateFrame("Frame", nil, UIParent)
    local GN = RP.General or CreateFrame('Frame', nil, UIParent)

    local buttons = {SpellbookMicroButton, CharacterMicroButton, AchievementMicroButton, QuestLogMicroButton,
                     SocialsMicroButton, CollectionsMicroButton, PVPMicroButton, LFGMicroButton, MainMenuMicroButton,
                     TalentMicroButton, HelpMicroButton}

    local move = {MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MainMenuExpBar, ReputationWatchBar,
                  MainMenuBarLeftEndCap, MainMenuBarRightEndCap}

    local hide = {MainMenuXPBarTexture0, MainMenuXPBarTexture1, ReputationXPBarTexture0, ReputationXPBarTexture1,
                  ReputationXPBarTexture2, ReputationXPBarTexture3, ReputationWatchBarTexture0,
                  ReputationWatchBarTexture1, MainMenuMaxLevelBar1, MainMenuMaxLevelBar0}
    -- MainMenuBarTexture0, MainMenuBarTexture1, 

    local blizzardAddons = {"Blizzard_GlyphUI", "Blizzard_Calendar", "Blizzard_AchievementUI", "Blizzard_BarbershopUI",
                            "Blizzard_TradeSkillUI", "Blizzard_TalentUI", "Blizzard_AuctionUI", "Auctionator",
                            "Blizzard_TrainerUI", "Blizzard_LookingForGroupUI", "Blizzard_Collections",
                            "Blizzard_MacroUI"}

    --[[
    ################################################################
    #################           Functions          #################
    ################################################################
    ]] --

    -- Color
    function RP:GetColor(info)
        return RP.db.profile["CC"].red, RP.db.profile["CC"].green, RP.db.profile["CC"].blue
    end
    function RP:SetColor(_, r, g, b)
        RP.db.profile["CC"].red = r
        RP.db.profile["CC"].green = g
        RP.db.profile["CC"].blue = b
        RP:UpdateButtons()
        RP:BorderColorAccept()
        RP:FrameColour()
        RP:ColorBlizzAddon()
        RP:UpdateMoney()
        -- RP:UpdateMapBorder()
        for _, addonName in pairs(blizzardAddons) do
            RP:BlizzFrames(addonName)
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

    local function ApplyVertexColorToRegions(...)
        for _, region in pairs({...}) do
            region:SetVertexColor(r, g, b, 1)
        end
    end

    local function ApplyThemeColor(items)
        for _, v in pairs(items) do
            if DB["Class"] then
                v:SetVertexColor(P.userClassColor.r, P.userClassColor.g, P.userClassColor.b, 1)
            elseif DB["Blackout"] then
                v:SetVertexColor(0.15, 0.15, 0.15, 1)
            elseif DB["Custom Color"] then
                local c = RP.db.profile["CC"]
                v:SetVertexColor(c.red, c.green, c.blue, 1)
            else
                v:SetVertexColor(1, 1, 1, 1)
            end
        end
    end

    local function ApplyVertexColorToFrame(v)
        if DB["Class"] then
            v:SetVertexColor(P.userClassColor.r, P.userClassColor.g, P.userClassColor.b, 1)
        elseif DB["Blackout"] then
            v:SetVertexColor(0.15, 0.15, 0.15, 1)
        elseif DB["Custom Color"] then
            local customColor = DB["CC"]
            v:SetVertexColor(customColor.red, customColor.green, customColor.blue, 1)
        else
            v:SetVertexColor(1, 1, 1, 1)
        end
    end

    local function AddRainbowColorAnimation(fontString, frame)

        -- Initialize rainbow variables
        local t, i, p, c, w, m = 0, 0, 0, 128, 127, 180
        local hz = (pi * 2) / m
        local r, g, b

        local updaterFrame = CreateFrame("Frame", nil, frame)
        updaterFrame:Hide()

        updaterFrame:SetScript("OnUpdate", function(_, elapsed)
            t = t + elapsed
            if t > 0.1 then
                i = i + 1
                r = (sin((hz * i) + 0 + p) * w + c) / 255
                g = (sin((hz * i) + 2 + p) * w + c) / 255
                b = (sin((hz * i) + 4 + p) * w + c) / 255
                if i > m then
                    i = i - m
                end
                fontString:SetTextColor(r, g, b)
                t = 0
            end
        end)

        updaterFrame:Show()
    end

    --[[
    ################################################################
    #################           Level-Up           #################
    ################################################################
    ]] --

    local levelUpFrame = CreateFrame("Frame", "LevelUpFrame", UIParent)
    levelUpFrame:SetSize(400, 100)
    levelUpFrame:SetPoint("TOP", 0, -200)
    levelUpFrame:Hide()

    local levelUpText = levelUpFrame:CreateFontString(nil, "OVERLAY")
    levelUpText:SetFont(STANDARD_TEXT_FONT, 20, "OUTLINE")
    levelUpText:SetText(_G.string.format("You've Reached\n\n|cffffd200Level %s|r", P.userLevel))
    levelUpText:SetPoint("CENTER", 0, 0)

    levelUpFrame.Top = levelUpFrame:CreateTexture(nil, 'OVERLAY')
    levelUpFrame.Top:SetPoint('TOPLEFT', levelUpFrame, -40, 4)
    levelUpFrame.Top:SetPoint('TOPRIGHT', levelUpFrame, 40, 4)
    levelUpFrame.Top:SetHeight(2)
    levelUpFrame.Top:SetTexture("Interface\\AddOns\\RasPort\\Media\\Border\\Slice")
    levelUpFrame.Top:SetVertexColor(1, 0.81960791349411, 0)

    levelUpFrame.Bottom = levelUpFrame:CreateTexture(nil, 'OVERLAY')
    levelUpFrame.Bottom:SetPoint('BOTTOMLEFT', levelUpFrame, -40, -4)
    levelUpFrame.Bottom:SetPoint('BOTTOMRIGHT', levelUpFrame, 40, -4)
    levelUpFrame.Bottom:SetHeight(2)
    levelUpFrame.Bottom:SetTexture("Interface\\AddOns\\RasPort\\Media\\Border\\Slice")
    levelUpFrame.Bottom:SetVertexColor(1, 0.81960791349411, 0)

    local function ShowLevelUpMessage()
        levelUpFrame:Show()
        if levelUpFrame:IsShown() then
            levelUpText:SetText(_G.string.format("You've Reached\n\n|cffffd200Level %s|r", P.userLevel))
        end

        C_Timer.After(5, function()
            levelUpFrame:Hide()
        end)
    end

    TM:RegisterEvent("PLAYER_LEVEL_UP")

    TM:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_LEVEL_UP" then
            local newLevel = ...
            P.userLevel = newLevel
            ShowLevelUpMessage()
        end
    end)

    --[[
    ################################################################
    #################           Functions          #################
    ################################################################
    ]] --

    -- Color Frames
    function RP:FrameColour()
        for _, v in pairs({MainMenuXPBarTexture0, MainMenuXPBarTexture1, MainMenuXPBarTexture2, MainMenuXPBarTexture3,
                           MainMenuXPBarTexture4, ReputationWatchBar.StatusBar.XPBarTexture0,
                           ReputationWatchBar.StatusBar.XPBarTexture1, ReputationWatchBar.StatusBar.XPBarTexture2,
                           ReputationWatchBar.StatusBar.XPBarTexture3}) do
            v:SetAlpha(0)
        end

        CHAT_FONT_HEIGHTS = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

        local blizzFrames = {LFGListingFrameFrameBackgroundBottom, PlayerFrameTexture,
                             PlayerFrameAlternateManaBarBorder, PlayerFrameAlternateManaBarLeftBorder,
                             PlayerFrameAlternateManaBarRightBorder, PlayerFrameAlternatePowerBarBorder,
                             PlayerFrameAlternatePowerBarLeftBorder, PlayerFrameAlternatePowerBarRightBorder,
                             TargetFrameTextureFrameTexture, TargetFrameToTTextureFrameTexture, PetFrameTexture,
                             PartyMemberFrame1Texture, PartyMemberFrame2Texture, PartyMemberFrame3Texture,
                             PartyMemberFrame4Texture, PartyMemberFrame1PetFrameTexture,
                             PartyMemberFrame2PetFrameTexture, PartyMemberFrame3PetFrameTexture,
                             PartyMemberFrame4PetFrameTexture, SlidingActionBarTexture0, SlidingActionBarTexture1,
                             MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3,
                             MainMenuMaxLevelBar0, MainMenuMaxLevelBar1, MainMenuMaxLevelBar2, MainMenuMaxLevelBar3,
                             MinimapBorder, MirrorTimer1Border, MirrorTimer2Border, MirrorTimer3Border,
                             MiniMapTrackingBorder, MiniMapLFGFrameBorder, MiniMapBattlefieldBorder, MiniMapMailBorder,
                             MiniMapBorderTop, QueueStatusMinimapButtonBorder, CastingBarFrame.Border,
                             TargetFrameSpellBar.Border, ReputationWatchBar.StatusBar.WatchBarTexture0,
                             ReputationWatchBar.StatusBar.WatchBarTexture1,
                             ReputationWatchBar.StatusBar.WatchBarTexture2,
                             ReputationWatchBar.StatusBar.WatchBarTexture3, ReputationWatchBar.StatusBar.XPBarTexture0,
                             ReputationWatchBar.StatusBar.XPBarTexture1, ReputationWatchBar.StatusBar.XPBarTexture2,
                             ReputationWatchBar.StatusBar.XPBarTexture3, Rune1BorderTexture, Rune2BorderTexture,
                             Rune3BorderTexture, Rune4BorderTexture, Rune5BorderTexture, Rune6BorderTexture,
                             MainMenuBarLeftEndCap, MainMenuBarRightEndCap, StanceBarLeft, StanceBarMiddle,
                             StanceBarRight, GameMenuFrameHeader, GameMenuFrame.BottomEdge,
                             GameMenuFrame.BottomLeftCorner, GameMenuFrame.BottomRightCorner, GameMenuFrame.LeftEdge,
                             GameMenuFrame.RightEdge, GameMenuFrame.TopEdge, GameMenuFrame.TopLeftCorner,
                             GameMenuFrame.TopRightCorner, InterfaceOptionsFrameHeader,
                             InterfaceOptionsFrame.BottomEdge, InterfaceOptionsFrame.BottomLeftCorner,
                             InterfaceOptionsFrame.BottomRightCorner, InterfaceOptionsFrame.LeftEdge,
                             InterfaceOptionsFrame.RightEdge, InterfaceOptionsFrame.TopEdge,
                             InterfaceOptionsFrame.TopLeftCorner, InterfaceOptionsFrame.TopRightCorner,
                             VideoOptionsFrameHeader, VideoOptionsFrame.BottomEdge, VideoOptionsFrame.BottomLeftCorner,
                             VideoOptionsFrame.BottomRightCorner, VideoOptionsFrame.LeftEdge,
                             VideoOptionsFrame.RightEdge, VideoOptionsFrame.TopEdge, VideoOptionsFrame.TopLeftCorner,
                             VideoOptionsFrame.TopRightCorner, AddonListBotLeftCorner, AddonListBotRightCorner,
                             AddonListBottomBorder, AddonListLeftBorder, AddonListRightBorder, AddonListTopBorder,
                             AddonListTopLeftCorner, AddonListTopRightCorner, AddonListBtnCornerLeft,
                             AddonListBtnCornerRight, AddonListBg, AddonListTitleBg, ExhaustionTickNormal,
                             AddonListEnableAllButton_RightSeparator, AddonListDisableAllButton_RightSeparator,
                             AddonListCancelButton_LeftSeparator, AddonListOkayButton_LeftSeparator,
                             StaticPopup1.BottomEdge, StaticPopup1.BottomLeftCorner, StaticPopup1.BottomRightCorner,
                             StaticPopup1.LeftEdge, StaticPopup1.RightEdge, StaticPopup1.TopEdge,
                             StaticPopup1.TopLeftCorner, StaticPopup1.TopRightCorner, StaticPopup2.BottomEdge,
                             StaticPopup2.BottomLeftCorner, StaticPopup2.BottomRightCorner, StaticPopup2.LeftEdge,
                             StaticPopup2.RightEdge, StaticPopup2.TopEdge, StaticPopup2.TopLeftCorner,
                             StaticPopup2.TopRightCorner, StaticPopup3.BottomEdge, StaticPopup3.BottomLeftCorner,
                             StaticPopup3.BottomRightCorner, StaticPopup3.LeftEdge, StaticPopup3.RightEdge,
                             StaticPopup3.TopEdge, StaticPopup3.TopLeftCorner, StaticPopup3.TopRightCorner,
                             StaticPopup4.BottomEdge, StaticPopup4.BottomLeftCorner, StaticPopup4.BottomRightCorner,
                             StaticPopup4.LeftEdge, StaticPopup4.RightEdge, StaticPopup4.TopEdge,
                             StaticPopup4.TopLeftCorner, StaticPopup4.TopRightCorner,
                             DropDownList1MenuBackdrop.BottomEdge, DropDownList1MenuBackdrop.BottomLeftCorner,
                             DropDownList1MenuBackdrop.BottomRightCorner, DropDownList1MenuBackdrop.LeftEdge,
                             DropDownList1MenuBackdrop.RightEdge, DropDownList1MenuBackdrop.TopEdge,
                             DropDownList1MenuBackdrop.TopLeftCorner, DropDownList1MenuBackdrop.TopRightCorner,
                             DropDownList2MenuBackdrop.BottomEdge, DropDownList2MenuBackdrop.BottomLeftCorner,
                             DropDownList2MenuBackdrop.BottomRightCorner, DropDownList2MenuBackdrop.LeftEdge,
                             DropDownList2MenuBackdrop.RightEdge, DropDownList2MenuBackdrop.TopEdge,
                             DropDownList2MenuBackdrop.TopLeftCorner, DropDownList2MenuBackdrop.TopRightCorner,
                             ContainerFrame1BackgroundTop, ContainerFrame1BackgroundMiddle1,
                             ContainerFrame1BackgroundBottom, ContainerFrame2BackgroundTop,
                             ContainerFrame2BackgroundMiddle1, ContainerFrame2BackgroundBottom,
                             ContainerFrame3BackgroundTop, ContainerFrame3BackgroundMiddle1,
                             ContainerFrame3BackgroundBottom, ContainerFrame4BackgroundTop,
                             ContainerFrame4BackgroundMiddle1, ContainerFrame4BackgroundBottom,
                             ContainerFrame5BackgroundTop, ContainerFrame5BackgroundMiddle1,
                             ContainerFrame5BackgroundBottom, ContainerFrame6BackgroundTop,
                             ContainerFrame6BackgroundMiddle1, ContainerFrame6BackgroundBottom,
                             ContainerFrame7BackgroundTop, ContainerFrame7BackgroundMiddle1,
                             ContainerFrame7BackgroundBottom, ContainerFrame8BackgroundTop,
                             ContainerFrame8BackgroundMiddle1, ContainerFrame8BackgroundBottom,
                             ContainerFrame9BackgroundTop, ContainerFrame9BackgroundMiddle1,
                             ContainerFrame9BackgroundBottom, ContainerFrame10BackgroundTop,
                             ContainerFrame10BackgroundMiddle1, ContainerFrame10BackgroundBottom,
                             ContainerFrame11BackgroundTop, ContainerFrame11BackgroundMiddle1,
                             ContainerFrame11BackgroundBottom, ContainerFrame12BackgroundTop,
                             ContainerFrame12BackgroundMiddle1, ContainerFrame12BackgroundBottom,
                             MerchantFrameInsetInsetBottomBorder, TradeFrameBg, TradeFrameBottomBorder,
                             TradeFrameButtonBottomBorder, TradeFrameLeftBorder, TradeFrameRightBorder,
                             TradeFrameTitleBg, TradeFrameTopBorder, TradeFrameTopRightCorner, TradeRecipientLeftBorder,
                             TradeFrameBtnCornerLeft, TradeFrameBtnCornerRight, TradeRecipientBG,
                             TradeFramePortraitFrame, TradeRecipientPortraitFrame, TradeRecipientBotLeftCorner,
                             PVPReadyDialog.BottomEdge, PVPReadyDialog.BottomLeftCorner,
                             PVPReadyDialog.BottomRightCorner, PVPReadyDialog.LeftEdge, PVPReadyDialog.RightEdge,
                             PVPReadyDialog.TopEdge, PVPReadyDialog.TopLeftCorner, PVPReadyDialog.TopRightCorner,
                             MailFrameBg, MailFrameBotLeftCorner, MailFrameBotRightCorner, MailFrameBottomBorder,
                             MailFrameBtnCornerLeft, MailFrameBtnCornerRight, MailFrameButtonBottomBorder,
                             MailFrameLeftBorder, MailFramePortraitFrame, MailFrameRightBorder, MailFrameTitleBg,
                             MailFrameTopBorder, MailFrameTopLeftCorner, MailFrameTopRightCorner,
                             MailFrameInsetInsetBottomBorder, MailFrameInsetInsetBotLeftCorner,
                             MailFrameInsetInsetBotRightCorner, LootFrameBg, LootFrameRightBorder, LootFrameLeftBorder,
                             LootFrameTopBorder, LootFrameBottomBorder, LootFrameTopRightCorner, LootFrameTopLeftCorner,
                             LootFrameBotRightCorner, LootFrameBotLeftCorner, LootFrameInsetInsetTopRightCorner,
                             LootFrameInsetInsetTopLeftCorner, LootFrameInsetInsetBotRightCorner,
                             LootFrameInsetInsetBotLeftCorner, LootFrameInsetInsetRightBorder,
                             LootFrameInsetInsetLeftBorder, LootFrameInsetInsetTopBorder,
                             LootFrameInsetInsetBottomBorder, LootFramePortraitFrame, MerchantFrameTitleBg,
                             MerchantFrameTopBorder, MerchantFrameBtnCornerRight, MerchantFrameBtnCornerLeft,
                             MerchantFrameBottomRightBorder, MerchantFrameBottomLeftBorder,
                             MerchantFrameButtonBottomBorder, MerchantFrameBg}

        ApplyThemeColor(blizzFrames)
        -- ApplyThemeColor(select(1, TimeManagerClockButton:GetRegions()))
        -- time TimeManagerClockButton
        if TimeManagerClockButton then
            local a = TimeManagerClockButton:GetRegions()
            ApplyVertexColorToRegions(a)
        end
        -- BankFrame
        local a, b, c, d, e = BankFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e)

        -- MerchantFrame
        local a, b, c, d, e, f = MerchantFrameTab1:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        local a, b, c, d, e, f = MerchantFrameTab2:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        local _, a, b, c, d, _, _, _, e, f, g, h, j, k = MerchantFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f, g, h, j, k)

        -- Paperdoll

        local a, b, c, d, _, e = PaperDollFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e)

        local _, b, c, d, e = PetPaperDollFrame:GetRegions()
        ApplyVertexColorToRegions(b, c, d, e)

        -- TokenFrame

        local a, b, c, d = TokenFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d)

        for i = 1, 20 do
            local vertex = _G["TokenFrameContainerButton" .. i .. "Stripe"]
            ApplyVertexColorToFrame(vertex)
        end

        -- Skill

        local a, b, c, d, e, f = SkillFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        -- Reputation Frame

        local a, b, c, d = ReputationFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d)

        for _, v in pairs({ReputationDetailCorner, ReputationDetailDivider}) do
            ApplyVertexColorToFrame(v)
        end

        -- PvPFrame

        --[[         local _, _, c, d, e, f, g, h = PVPFrame:GetRegions()
        for _, v in pairs({c, d, e, f, g, h}) do
            if v then
                ApplyVertexColorToFrame(v)
            end
        end ]]

        -- Character Tabs

        local a, b, c, d, e, f = CharacterFrameTab1:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        local a, b, c, d, e, f = CharacterFrameTab2:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        local a, b, c, d, e, f = CharacterFrameTab3:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        local a, b, c, d, e, f = CharacterFrameTab4:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        local a, b, c, d, e, f = CharacterFrameTab5:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        local a, b, c, d, _, _, g, h, i, j = HonorFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, g, h, i, j)


        -- Social Frame
        local a, b, c, d, e, f, g, _, i, j, k, l, n, o, p, q, r, _, _ = FriendsFrame:GetRegions()
        for _, v in pairs({a, b, c, d, e, f, g, h, i, j, k, l, n, o, p, q, r, FriendsFrameInset:GetRegions(),
                           WhoFrameListInset:GetRegions()}) do
            ApplyVertexColorToFrame(v)
        end

        local a, b, c, d, e, f, g, h, i = WhoFrameEditBoxInset:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f, g, h, i)

        local a, b, c, d, e, f = FriendsFrameTab1:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        local a, b, c, d, e, f = FriendsFrameTab2:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        local a, b, c, d, e, f = FriendsFrameTab3:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        local a, b, c, d, e, f = FriendsFrameTab4:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        -- GuildFrame

        local _, _, _, _, e, f = GuildFrame:GetRegions()
        ApplyVertexColorToRegions(e, f)

        -- MailFrame

        local a, b, c, d, e, f = MailFrameTab1:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        local a, b, c, d, e, f = MailFrameTab2:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f)

        for i = 1, MAX_SKILLLINE_TABS do
            local vertex = _G["SpellBookSkillLineTab" .. i]:GetRegions()
            if vertex then
                ApplyVertexColorToFrame(vertex)
            end
        end

        -- Should remain untouched
        for _, v in pairs({BankPortraitTexture, BankFrameTitleText, WhoFrameTotals, MerchantFramePortrait}) do
            v:SetVertexColor(1, 1, 1)
        end

        if ChatFrame1EditBoxLeft then
            ApplyVertexColorToFrame(ChatFrame1EditBoxLeft)
        end
        if ChatFrame1EditBoxMid then
            ApplyVertexColorToFrame(ChatFrame1EditBoxMid)
        end
        if ChatFrame1EditBoxRight then
            ApplyVertexColorToFrame(ChatFrame1EditBoxRight)
        end

        GameTooltip:SetBackdropBorderColor(P.userClassColor.r, P.userClassColor.g, P.userClassColor.b)

        if GetBuildInfo() == "3.4.3" then -- Blizz lack of quality control
            MainMenuMaxLevelBar0:SetPoint("CENTER", -394, 4)
            MainMenuMaxLevelBar0:SetSize(261, 7)
            MainMenuMaxLevelBar1:SetSize(261, 7)
            MainMenuMaxLevelBar2:SetSize(261, 7)
            MainMenuMaxLevelBar3:SetSize(261, 7)
            ApplyVertexColorToFrame(MainMenuBarTextureExtender)

            if PVEFrame then
                for _, region in pairs({PVEFrame:GetRegions()}) do
                    if region and region:IsObjectType("Texture") then
                        ApplyVertexColorToFrame(region)
                    end
                end
                for _, region in pairs({PVEFrame.shadows:GetRegions()}) do
                    if region and region:IsObjectType("Texture") then
                        region:SetVertexColor(0, 0, 0)
                    end
                end
                for _, region in pairs({LFDParentFrame:GetRegions()}) do
                    if region and region:IsObjectType("Texture") then
                        ApplyVertexColorToFrame(region)
                    end
                end
                for _, region in pairs({LFDParentFrameInset:GetRegions()}) do
                    if region and region:IsObjectType("Texture") then
                        ApplyVertexColorToFrame(region)
                    end
                end
                for _, region in pairs({LFGListFrame.CategorySelection.Inset:GetRegions()}) do
                    if region and region:IsObjectType("Texture") then
                        ApplyVertexColorToFrame(region)
                    end
                end
                ApplyVertexColorToFrame(LFDQueueFrameFindGroupButton_LeftSeparator)
                ApplyVertexColorToFrame(LFDQueueFrameFindGroupButton_RightSeparator)
                ApplyVertexColorToFrame(PVEFrameLeftInsetInsetLeftBorder)
                ApplyVertexColorToFrame(PVEFrameLeftInsetInsetBottomBorder)
                ApplyVertexColorToFrame(PVEFrameLeftInsetInsetBotLeftCorner)
                ApplyVertexColorToFrame(LFGListFrame.CategorySelection.FindGroupButton.LeftSeparator)
                ApplyVertexColorToFrame(LFGListFrame.CategorySelection.StartGroupButton.RightSeparator)
                PVEFramePortrait:SetVertexColor(1, 1, 1)
            end
        end
        if CompactRaidFrameContainerBorderFrame then
            for _, region in pairs({CompactRaidFrameContainerBorderFrame:GetRegions()}) do
                if region and region:IsObjectType("Texture") then
                    ApplyVertexColorToFrame(region)
                end
            end
        end
    end

    --[[
    ################################################################
    #################           Inspect            #################
    ################################################################
    ]] --

    local function GetTargetClassColor()
        local unit = "target" -- You can change this to any valid unit ID ("player", "target", "party1", etc.)

        local _, class = UnitClass(unit)
        if class then
            local classColor = RAID_CLASS_COLORS[class]
            if classColor then
                local r, g, b = classColor.r, classColor.g, classColor.b
                return r, g, b
            end
        end
        return 1, 1, 1
    end

    local function ColorInspector()
        -- inspect
        if InspectFrame and UnitExists("target") then
            for _, v in pairs({InspectTalentFramePointsBarBorderLeft, InspectTalentFramePointsBarBorderMiddle,
                               InspectTalentFramePointsBarBorderRight, InspectTalentFramePointsBarBackground,
                               InspectFrameTab1LeftDisabled, InspectFrameTab1MiddleDisabled,
                               InspectFrameTab1RightDisabled, InspectFrameTab2LeftDisabled,
                               InspectFrameTab2MiddleDisabled, InspectFrameTab2RightDisabled,
                               InspectFrameTab3LeftDisabled, InspectFrameTab3MiddleDisabled,
                               InspectFrameTab3RightDisabled, InspectTalentFrameTab1Left, InspectTalentFrameTab1Right,
                               InspectTalentFrameTab1Middle, InspectTalentFrameTab1LeftDisabled,
                               InspectTalentFrameTab1MiddleDisabled, InspectTalentFrameTab1RightDisabled,
                               InspectTalentFrameTab2Left, InspectTalentFrameTab2Right, InspectTalentFrameTab2Middle,
                               InspectTalentFrameTab2LeftDisabled, InspectTalentFrameTab2MiddleDisabled,
                               InspectTalentFrameTab2RightDisabled, InspectTalentFrameTab3Left,
                               InspectTalentFrameTab3Right, InspectTalentFrameTab3Middle,
                               InspectTalentFrameTab3LeftDisabled, InspectTalentFrameTab3MiddleDisabled,
                               InspectTalentFrameTab3RightDisabled}) do
                if v then
                    v:SetVertexColor(GetTargetClassColor())
                end
            end
            local vectors = {InspectPaperDollFrame:GetRegions()}
            for i = 1, 4 do
                if vectors[i] then
                    vectors[i]:SetVertexColor(GetTargetClassColor())
                end
            end

            -- local vectors = {InspectPVPFrame:GetRegions()}
            -- for i = 1, 5 do
            -- if vectors[i] then
            -- vectors[i]:SetVertexColor(GetTargetClassColor())
            -- end
            -- end

            local vectors = {InspectTalentFrame:GetRegions()}
            for i = 1, 5 do
                if vectors[i] then
                    vectors[i]:SetVertexColor(GetTargetClassColor())
                end
            end

            local vectors = {InspectTalentFrameScrollFrame:GetRegions()}
            for i = 1, 2 do
                if vectors[i] then
                    vectors[i]:SetVertexColor(GetTargetClassColor())
                end
            end
        end
    end

    local eventFrame = CreateFrame("Frame")
    eventFrame:UnregisterAllEvents()
    eventFrame:RegisterEvent("INSPECT_READY")
    eventFrame:SetScript("OnEvent", ColorInspector)

    --[[
    ################################################################
    #################           Addons             #################
    ##########
    ######################################################
    ]] --

    local function IsThisClassic()
        return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
    end

    local function IsThisWrath()
        return WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
    end

    function RP:ColorBlizzAddon()

        -- SpellBookFrame

        local _, a, b, c, d = SpellBookFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d)

        if not SpellBookFrame.Material then
            SpellBookFrame.Material = SpellBookFrame:CreateTexture(nil, "OVERLAY", nil, 7)
            SpellBookFrame.Material:SetTexture("Interface\\AddOns\\RasPort\\Media\\Background\\QuestBG.tga")
            SpellBookFrame.Material:SetWidth(547)
            SpellBookFrame.Material:SetHeight(541)
            SpellBookFrame.Material:SetPoint("TOPLEFT", SpellBookFrame, 22, -74)
            SpellBookFrame.Material:SetVertexColor(.9, .9, .9)
        end

        -- QuestLogFrame
        local _, b, c, d, e, f = QuestLogFrame:GetRegions()
        for _, v in pairs({a, b, c, d, e, f}) do
            if v then
                ApplyVertexColorToFrame(v)
            end
        end

        -- CreateBackgroundFrameTemplate(QuestLogFrame, 10, 10, "CENTER", 5, 0)

        if IsAddOnLoaded("Leatrix_Plus") and LeaPlusDB["EnhanceQuestLog"] == "On" then
            QuestLogFrame.Material = QuestLogFrame:CreateTexture(nil, "OVERLAY", nil, 7)
            QuestLogFrame.Material:SetTexture("Interface\\AddOns\\RasPort\\Media\\Background\\QuestBG.tga")
            QuestLogFrame.Material:SetWidth(531)
            QuestLogFrame.Material:SetHeight(625)
            QuestLogFrame.Material:SetPoint("TOPLEFT", QuestLogDetailScrollFrame, -10, 0)
            QuestLogFrame.Material:SetVertexColor(.9, .9, .9)
        elseif IsThisClassic() then
            QuestLogFrame.Material = QuestLogFrame:CreateTexture(nil, "OVERLAY", nil, 7)
            QuestLogFrame.Material:SetTexture("Interface\\AddOns\\RasPort\\Media\\Background\\QuestBG.tga")
            QuestLogFrame.Material:SetWidth(511)
            QuestLogFrame.Material:SetHeight(400)
            QuestLogFrame.Material:SetPoint("TOPLEFT", QuestLogDetailScrollFrame, 0, 0)
            QuestLogFrame.Material:SetVertexColor(.9, .9, .9)
        elseif IsThisWrath() then
            QuestLogFrame.Material = QuestLogFrame:CreateTexture(nil, "OVERLAY", nil, 7)
            QuestLogFrame.Material:SetTexture("Interface\\AddOns\\RasPort\\Media\\Background\\QuestBG.tga")
            QuestLogFrame.Material:SetWidth(531)
            QuestLogFrame.Material:SetHeight(480)
            QuestLogFrame.Material:SetPoint("TOPLEFT", QuestLogDetailScrollFrame, -10, 0)
            QuestLogFrame.Material:SetVertexColor(.9, .9, .9)
        end

        for _, v in pairs({GossipFrame.GreetingPanel, QuestFrameRewardPanel, QuestFrameDetailPanel,
                           QuestFrameProgressPanel, QuestFrameGreetingPanel}) do
            for _, j in pairs({v:GetRegions()}) do
                if j then
                    ApplyVertexColorToFrame(j)
                end
            end

            if not v.Material then
                v.Material = v:CreateTexture(nil, "OVERLAY", nil, 7)
                v.Material:SetTexture("Interface\\AddOns\\RasPort\\Media\\Background\\QuestBG.tga")
                v.Material:SetWidth(514)
                v.Material:SetHeight(522)
                v.Material:SetPoint("TOPLEFT", v, 22, -74)
                v.Material:SetVertexColor(.9, .9, .9)
            end

            if v == GossipFrame.GreetingPanel or v == QuestFrameGreetingPanel then
                v.Material = v:CreateTexture(nil, "OVERLAY", nil, 7)
                v.Material:SetTexture("Interface\\AddOns\\RasPort\\Media\\Background\\QuestBG.tga")
                v.Material:SetWidth(514)
                v.Material:SetHeight(522)
                v.Material:SetPoint("TOPLEFT", v, 22, -74)
                v.Material:SetVertexColor(.9, .9, .9)

                v.Corner = v:CreateTexture(nil, "OVERLAY", nil, 7)
                v.Corner:SetTexture("Interface\\QuestFrame\\UI-Quest-BotLeftPatch")
                v.Corner:SetSize(132, 64)
                v.Corner:SetPoint("BOTTOMLEFT", v, 21, 68)
                ApplyVertexColorToFrame(v.Corner)
            end
        end

        -- Wardrobe
        local _, a, b, c, d = DressUpFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d)

        -- Readycheck
        local _, a = ReadyCheckListenerFrame:GetRegions()
        ApplyVertexColorToRegions(a)

        -- Taxiframe
        local _, a, b, c, d = TaxiFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d)

        -- TabardFrame
        local _, a, b, c, d = TabardFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d)

        -- Scoreboard
        local a, b, c, d, e, f, _, _, _, _, _, l = WorldStateScoreFrame:GetRegions()
        for _, v in pairs({a, b, c, d, e, f, l}) do
            if v then
                ApplyVertexColorToFrame(v)
            end
        end

        local a, b, c, d, e, f, g, h, i, j, k, l = WorldMapFrame.BorderFrame:GetRegions()
        for _, v in pairs({a, b, c, d, e, f, g, h, i, j, k, l}) do
            v:SetVertexColor(.5, .5, .5)
        end

        -- Readycheck
        local _, a = ReadyCheckListenerFrame:GetRegions()
        a:SetVertexColor(P.userClassColor.r, P.userClassColor.g, P.userClassColor.b)

        -- Scoreboard
        local a, b, c, d, e, f, _, _, _, _, _, l = WorldStateScoreFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e, f, l)

        -- Taxiframe
        local _, a, b, c, d = TaxiFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d)

        -- TabardFrame
        local _, a, b, c, d = TabardFrame:GetRegions()
        ApplyVertexColorToRegions(a, b, c, d, e)

        -- PetStable
        for _, v in pairs({PetStableFrame:GetRegions()}) do
            if v:GetObjectType() == "Texture" and v ~= PetStableFramePortrait then
                ApplyVertexColorToFrame(v)
            end

            doneInit = true
        end
    end

    function RP:BlizzFrames(addon)
        if EngravingFrame then
            for value = 1, 3 do
                local frame = _G["EngravingFrameHeader" .. value]
                if frame then
                    local vectors = {frame:GetRegions()}
                    for i = 1, 3 do
                        if vectors[i] then
                            ApplyVertexColorToFrame(vectors[i])
                        end
                    end
                end
            end
            local a = EngravingFrameCollectedFrame:GetRegions()
            for _, v in pairs({a}) do
                if v then
                    v:SetVertexColor(P.userClassColor.r, P.userClassColor.g, P.userClassColor.b)
                end
            end

            local _, _, c, d, e = EngravingFrameSearchBox:GetRegions()
            for _, v in pairs({c, d, e}) do
                if v then
                    ApplyVertexColorToFrame(v)
                end
            end

            local a, b, c, _, e = EngravingFrameFilterDropDown:GetRegions()
            for _, v in pairs({a, b, c, e}) do
                if v then
                    ApplyVertexColorToFrame(v)
                end
            end
            local a, b, c, d, e, f, g, h = EngravingFrame.Border.NineSlice:GetRegions()
            for _, v in pairs({a, b, c, d, e, f, g, h}) do
                if v then
                    ApplyVertexColorToFrame(v)
                end
            end
        end
        -- glyphs
        if addon == "Blizzard_GlyphUI" then
            if GlyphFrame then
                local a, _, c, d, e, f, g, h, i = GlyphFrame:GetRegions()
                for _, v in pairs({a, c, d, e, f, g, h, i}) do
                    if v then
                        ApplyVertexColorToFrame(v)
                    end
                end
            end
        end

        -- CalendarFrame
        if addon == "Blizzard_Calendar" then
            if CalendarFrame then
                local vectors = {CalendarFrame:GetRegions()}
                for i = 1, 13 do
                    if vectors[i] then
                        ApplyVertexColorToFrame(vectors[i])
                    end
                end
            end
        end

        -- achievements

        if addon == "Blizzard_AchievementUI" then
            if AchievementFrame then
                local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o = AchievementFrame:GetRegions()
                for _, v in pairs({a, b, c, d, e, f, g, h, i, j, k, l, m, n, o}) do
                    if v then
                        ApplyVertexColorToFrame(v)
                    end
                end
            end
        end

        -- Barber
        if addon == "Blizzard_BarbershopUI" then
            if BarbershopFrame then
                local a, b, c = BarberShopFrame:GetRegions()
                for _, v in pairs({a, b, c}) do
                    if v then
                        ApplyVertexColorToFrame(v)
                    end
                end
            end
        end

        -- Tradeskill
        if addon == "Blizzard_TradeSkillUI" then
            if TradeSkillFrame then
                local _, b, c, d, e, f, _, h, i = TradeSkillFrame:GetRegions()
                for _, v in pairs({b, c, d, e, f, h, i}) do
                    if v then
                        ApplyVertexColorToFrame(v)
                    end
                end
            end
        end

        -- Talentframe
        if addon == "Blizzard_TalentUI" then
            if PlayerTalentFrame then
                local vectors = {PlayerTalentFrame:GetRegions()}
                for i = 2, 6 do
                    if vectors[i] then
                        ApplyVertexColorToFrame(vectors[i])
                    end
                end

                if PlayerTalentFramePointsBar then
                    local vectors = {PlayerTalentFramePointsBar:GetRegions()}
                    for i = 1, 4 do
                        if vectors[i] then
                            ApplyVertexColorToFrame(vectors[i])
                        end
                    end
                end

                for _, v in pairs({PlayerTalentFrameScrollFrameBackgroundTop,
                                   PlayerTalentFrameScrollFrameBackgroundBottom, PlayerTalentFrameTab1LeftDisabled,
                                   PlayerTalentFrameTab1MiddleDisabled, PlayerTalentFrameTab1RightDisabled,
                                   PlayerTalentFrameTab2LeftDisabled, PlayerTalentFrameTab2MiddleDisabled,
                                   PlayerTalentFrameTab2RightDisabled, PlayerTalentFrameTab3LeftDisabled,
                                   PlayerTalentFrameTab3MiddleDisabled, PlayerTalentFrameTab3RightDisabled,
                                   PlayerTalentFrameTab4LeftDisabled, PlayerTalentFrameTab4MiddleDisabled,
                                   PlayerTalentFrameTab4RightDisabled, PlayerSpecTab1Background,
                                   PlayerSpecTab2Background}) do
                    ApplyVertexColorToFrame(v)
                end
            end
        end

        -- Auction
        if addon == "Blizzard_AuctionUI" then
            if AuctionFrame then
                local _, a, b, c, d, e, f, g = AuctionFrame:GetRegions()
                for _, v in pairs({a, b, c, d, e, f, g}) do
                    if v then
                        ApplyVertexColorToRegions(v)
                    end
                end

                -- AuctionHouse Tabs
                local a, b, c, d, e, f = AuctionFrameTab1:GetRegions()
                ApplyVertexColorToRegions(a, b, c, d, e, f)
                local a, b, c, d, e, f = AuctionFrameTab2:GetRegions()
                ApplyVertexColorToRegions(a, b, c, d, e, f)
                local a, b, c, d, e, f = AuctionFrameTab3:GetRegions()
                ApplyVertexColorToRegions(a, b, c, d, e, f)
            end

            if addon == "Auctionator" then
                local a, b, c, d, e, f = AuctionFrameTab4:GetRegions()
                ApplyVertexColorToRegions(a, b, c, d, e, f)
                local a, b, c, d, e, f = AuctionFrameTab5:GetRegions()
                ApplyVertexColorToRegions(a, b, c, d, e, f)
                local a, b, c, d, e, f = AuctionFrameTab6:GetRegions()
                ApplyVertexColorToRegions(a, b, c, d, e, f)
            end
        end

        -- ClassTrainerFrame
        if addon == "Blizzard_TrainerUI" then
            if ClassTrainerFrame then
                local _, a, b, c, d, _, e, f, g, h = ClassTrainerFrame:GetRegions()

                for _, v in pairs({a, b, c, d, e, f, g, h}) do
                    if v then
                        ApplyVertexColorToFrame(v)
                    end
                end
                ClassTrainerFrame.Material = ClassTrainerFrame:CreateTexture(nil, "OVERLAY", nil, 7)
                ClassTrainerFrame.Material:SetTexture("Interface\\AddOns\\RasPort\\Media\\Background\\QuestBG.tga")
                ClassTrainerFrame.Material:SetWidth(520)
                ClassTrainerFrame.Material:SetHeight(280)
                ClassTrainerFrame.Material:SetPoint("TOPLEFT", ClassTrainerListScrollFrame, -5, 0)
                ClassTrainerFrame.Material:SetVertexColor(.9, .9, .9)
            end
        end

        -- //////////////////////////////////////////////////////////////////////

        -- Dungeon finder
        if addon == "Blizzard_LookingForGroupUI" and GetBuildInfo() == "3.4.2" then
            if LFGListingFrame then
                local a, b, c = LFGListingFrame:GetRegions()
                for _, v in pairs({a, b, c}) do
                    if v then
                        ApplyVertexColorToFrame(v)
                    end
                end
            end

            if LFGBrowseFrame then
                local a, b, c, d = LFGBrowseFrame:GetRegions()
                for _, v in pairs({a, b, c, d}) do
                    if v then
                        ApplyVertexColorToFrame(v)
                    end
                end
            end
        end

        if addon == "Blizzard_Collections" then
            if CollectionsJournal then
                for _, v in pairs({CollectionsJournal:GetRegions()}) do
                    if v and v:IsObjectType("Texture") then
                        ApplyVertexColorToFrame(v)
                    end
                end
                for _, v in pairs({MountJournal:GetRegions()}) do
                    if v and v:IsObjectType("Texture") then
                        ApplyVertexColorToFrame(v)
                    end
                end
                for _, v in pairs({MountJournal.RightInset:GetRegions()}) do
                    if v and v:IsObjectType("Texture") then
                        ApplyVertexColorToFrame(v)
                    end
                end
                for _, v in pairs({MountJournal.LeftInset:GetRegions()}) do
                    if v and v:IsObjectType("Texture") then
                        ApplyVertexColorToFrame(v)
                    end
                end
                for _, v in pairs({PetJournal:GetRegions()}) do
                    if v and v:IsObjectType("Texture") then
                        ApplyVertexColorToFrame(v)
                    end
                end
                for _, v in pairs({PetJournalRightInset:GetRegions()}) do
                    if v and v:IsObjectType("Texture") then
                        ApplyVertexColorToFrame(v)
                    end
                end
                for _, v in pairs({PetJournalLeftInset:GetRegions()}) do
                    if v and v:IsObjectType("Texture") then
                        ApplyVertexColorToFrame(v)
                    end
                end
                CollectionsJournalTitleText:SetVertexColor(1, 1, 1)
                CollectionsJournalPortrait:SetVertexColor(1, 1, 1)
                ApplyVertexColorToFrame(MountJournalInsetBottomBorder)
                ApplyVertexColorToFrame(MountJournalInsetBotRightCorner)
            end
        end

        if addon == "Blizzard_MacroUI" then
            if MacroFrame then
                local a, b, c, d, e, f, g, h, i, j, k, l, n, o, p, q, r = MacroFrame:GetRegions()
                for _, v in pairs({a, b, c, d, e, f, g, h, i, j, k, l, n, o, p, q, r}) do
                    if v then
                        ApplyVertexColorToFrame(v)
                    end
                end

                for _, v in pairs({MacroFrameTab1Left, MacroFrameTab1Right, MacroFrameTab1Middle,
                                   MacroFrameTab1LeftDisabled, MacroFrameTab1MiddleDisabled,
                                   MacroFrameTab1RightDisabled, MacroFrameTab2Left, MacroFrameTab2Right,
                                   MacroFrameTab2Middle, MacroFrameTab2LeftDisabled, MacroFrameTab2MiddleDisabled,
                                   MacroFrameTab2RightDisabled}) do
                    if v then
                        ApplyVertexColorToFrame(v)
                    end
                end
            end
        end

        if addon == "Blizzard_CharacterUI" then
            if EngravingFrame then
                local a, b, c, d, e = EngravingFrame:GetRegions()
                ApplyVertexColorToRegions(a, b, c, d, e)
            end
        end
    end

    -- local function Minimap
    do
        Minimap:SetScript("OnMouseUp", function(self, btn)
            if btn == "MiddleButton" then
                _G.ToggleDropDownMenu(1, nil, _G.MiniMapTrackingDropDown, self)
            else
                _G.Minimap_OnClick(self)
            end
        end)

        MinimapZoneText:SetPoint("CENTER", Minimap, 0, 80)
        Minimap:EnableMouseWheel(true)
        Minimap:SetScript("OnMouseWheel", function(self, z)
            local c = Minimap:GetZoom()
            if (z > 0 and c < 5) then
                Minimap:SetZoom(c + 1)
            elseif (z < 0 and c > 0) then
                Minimap:SetZoom(c - 1)
            end
        end)

        if RP:IsDisabled("Info Bar") then
            MinimapZoneText:SetPoint("CENTER", Minimap, 0, 80)
        else
            MinimapZoneText:SetAlpha(0)
        end
    end

    local function ApplyMap()
        if RP.db.profile.minimap["Mail"] then
            if MiniMapMailFrame then
                MiniMapMailFrame:Hide()
                MiniMapMailFrame:UnregisterAllEvents()
                MiniMapMailFrame.Show = kill
            else
                MiniMapMailFrame:Show()
            end
        end

        if RP.db.profile.minimap["Date"] then
            GameTimeFrame:Hide()
            GameTimeFrame:UnregisterAllEvents()
            GameTimeFrame.Show = kill
        end

        if RP.db.profile.minimap["Tracking"] then
            if MiniMapTracking then
                MiniMapTracking:Hide()
                MiniMapTracking:UnregisterAllEvents()
                MiniMapTracking.Show = kill
            end
        end

        if RP.db.profile.minimap["Clock"] then
            TimeManagerClockButton:Hide()
        else
            TimeManagerClockButton:Show()
        end

        MiniMapWorldMapButton:SetAlpha(0)
        MiniMapWorldMapButton:EnableMouse(false)
        MinimapBorderTop:Hide()
        MinimapZoomIn:Hide()
        MinimapZoomOut:Hide()
    end

    local function ApplyGlow()
        PlayerStatusTexture:SetTexture()
    end

    -- Copy Chatah

    function RP:Copy()
        local patterns =
            {"(https://%S+%.%S+)", "(http://%S+%.%S+)", "(www%.%S+%.%S+)", "(%d+%.%d+%.%d+%.%d+:?%d*/?%S*)"}

        for _, event in next,
            {"CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_GUILD",
             "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER",
             "CHAT_MSG_RAID_WARNING", "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
             "CHAT_MSG_BATTLEGROUND", "CHAT_MSG_BATTLEGROUND_LEADER", "CHAT_MSG_BN_WHISPER",
             "CHAT_MSG_BN_WHISPER_INFORM", "CHAT_MSG_BN_CONVERSATION", "CHAT_MSG_CHANNEL", "CHAT_MSG_SYSTEM"} do
            ChatFrame_AddMessageEventFilter(event, function(self, event, str, ...)
                for _, pattern in pairs(patterns) do
                    local result, match = string.gsub(str, pattern, "|cff69000b|Hurl:%1|h[%1]|h|r")
                    if match > 0 then
                        return false, result, ...
                    end
                end
            end)
        end

        local SetHyperlink = _G.ItemRefTooltip.SetHyperlink
        function _G.ItemRefTooltip:SetHyperlink(link, ...)
            if link and (strsub(link, 1, 3) == "url") then
                local editbox = ChatEdit_ChooseBoxForSend()
                ChatEdit_ActivateChat(editbox)
                editbox:Insert(string.sub(link, 5))
                editbox:HighlightText()
                return
            end

            SetHyperlink(self, link, ...)
        end
    end

    RP:RegisterForEvent("ADDON_LOADED", function(self)
        ApplyGlow()
        RP:FrameColour()
        RP:ColorBlizzAddon()
        for _, addonName in pairs(blizzardAddons) do
            RP:BlizzFrames(addonName)
        end
        if doneInit then
            RP:UnregisterEvent("ADDON_LOADED")
        end
    end)

    RP:RegisterForEvent("INSPECT_READY", function(_, addon)
        ColorInspector(addon)
    end)

    local options = {
        type = "group",
        name = "",
        order = 1,
        inline = true,
        get = function(i)
            return RP.db.profile[i[#i]]
        end,
        set = function(i, val)
            RP.db.profile[i[#i]] = val
        end,
        args = {
            topSpacer = {
                type = "header",
                name = "Theme Config",
                order = 1
            },
            theme = {
                order = 3,
                type = "group",
                name = "Theme",
                inline = true,
                args = {
                    Class = {
                        order = 0,
                        type = "toggle",
                        name = "Class",
                        desc = 'Sets the color theme to Class Color',
                        width = 0.65,
                        get = function()
                            return RP.db.profile["Class"]
                        end,
                        set = function(_, value)
                            RP.db.profile["Class"] = value
                            if value then
                                RP.db.profile["Blackout"] = false
                                RP.db.profile["Custom Color"] = false
                            end
                            RP:UpdateButtons()
                            RP:BorderColorAccept()
                            RP:FrameColour()
                            RP:ColorBlizzAddon()
                            -- RP:UpdateMapBorder()
                            for _, addonName in pairs(blizzardAddons) do
                                RP:BlizzFrames(addonName)
                            end
                        end
                    },
                    Blackout = {
                        order = 2,
                        type = "toggle",
                        name = "Blackout",
                        desc = 'Sets the color theme to Black',
                        width = 0.75,
                        get = function()
                            return RP.db.profile["Blackout"]
                        end,
                        set = function(_, value)
                            RP.db.profile["Blackout"] = value
                            if value then
                                RP.db.profile["Class"] = false
                                RP.db.profile["Custom Color"] = false
                            end
                            RP:UpdateButtons()
                            RP:BorderColorAccept()
                            RP:FrameColour()
                            RP:ColorBlizzAddon()
                            -- RP:UpdateMapBorder()
                            for _, addonName in pairs(blizzardAddons) do
                                RP:BlizzFrames(addonName)
                            end
                        end
                    },
                    CustomColor = {
                        order = 4,
                        type = "toggle",
                        name = "Custom Color",
                        desc = 'Sets the color theme to Custom Color',
                        width = 0.75,
                        get = function()
                            return RP.db.profile["Custom Color"]
                        end,
                        set = function(_, value)
                            RP.db.profile["Custom Color"] = value
                            if value then
                                RP.db.profile["Class"] = false
                                RP.db.profile["Blackout"] = false
                            end
                            RP:UpdateButtons()
                            RP:BorderColorAccept()
                            RP:FrameColour()
                            RP:ColorBlizzAddon()
                            -- RP:UpdateMapBorder()
                            for _, addonName in pairs(blizzardAddons) do
                                RP:BlizzFrames(addonName)
                            end
                        end
                    },
                    CustomColorPicker = {
                        order = 5,
                        type = "color",
                        name = " ",
                        dialogControl = "ColorPicker-RasPort",
                        width = 0.25,
                        hidden = function()
                            return not RP.db.profile["Custom Color"]
                        end,
                        get = "GetColor",
                        set = "SetColor"
                    }
                }
            },
            toggles = {
                order = 4,
                type = "group",
                name = "Toggles",
                inline = true,
                args = {
                    date = {
                        order = 0,
                        type = "toggle",
                        name = "Date",
                        desc = 'Hide the calendar button ' ..
                            C.GOLD_COLOR:WrapTextInColorCode("\n\n/reload to get the button to show again"),
                        width = 0.65,
                        get = function()
                            return RP.db.profile.minimap["Date"]
                        end,
                        set = function(_, value)
                            RP.db.profile.minimap["Date"] = value
                        end
                    },
                    clock = {
                        order = 1,
                        type = "toggle",
                        name = "Clock",
                        desc = 'Hide the clock button',
                        width = 0.65,
                        get = function()
                            return RP.db.profile.minimap["Clock"]
                        end,
                        set = function(_, value)
                            RP.db.profile.minimap["Clock"] = value
                            ApplyMap()
                        end
                    },
                    tracking = {
                        order = 2,
                        type = "toggle",
                        name = "Tracking",
                        desc = 'Hide the tracking button ' ..
                            C.BLUE_COLOR:WrapTextInColorCode("\n\n* Middle - Click minimap to show tracking menu *") ..
                            C.GOLD_COLOR:WrapTextInColorCode("\n\n/reload to get the button to show again"),
                        width = 0.65,
                        get = function()
                            return RP.db.profile.minimap["Tracking"]
                        end,
                        set = function(_, value)
                            RP.db.profile.minimap["Tracking"] = value
                        end
                    },
                    mail = {
                        order = 3,
                        type = "toggle",
                        name = "Mail",
                        desc = 'Hide the mail notification ' ..
                            C.GOLD_COLOR:WrapTextInColorCode("\n\n/reload to get the button to show again"),
                        width = 0.65,
                        get = function()
                            return RP.db.profile.minimap["Mail"]
                        end,
                        set = function(_, value)
                            RP.db.profile.minimap["Mail"] = value
                        end
                    }
                }
            }
        }
    }

    RP:RegisterForEvent("PLAYER_LOGIN", function()
        RP.options.args.Options.args.Theme = options
        --TM:buttons()
        ApplyMap()
        RP:Copy()

    end)
end)
