local RP = RasPort
local _, _, U, C = RP:Unpack() -- m, p, u, c
RP:AddModule("Minimap", function()
    if RP:IsDisabled("Minimap") or RP.ElvUI then
        return
    end

    -- list of addons for which the module is disabled
    -- add as many addons as you want, i just added few.
    local disabled, reason = RP:AddOnIsLoaded("SexyMap", "MinimapBar", "KkthnxUI")

    local _G = getfenv(0)
    local pairs, ipairs, select, format = _G.pairs, _G.ipairs, _G.select, _G.string.format
    local UnitName, UnitClass = UnitName, UnitClass
    local UIFrameFlash = UIFrameFlash
    local CreateFrame = _G.CreateFrame
    local DB = RP.db.profile.minimap

    -- cache frequently used globals
    local ToggleCharacter = ToggleCharacter
    local ToggleSpellBook = ToggleSpellBook
    local ToggleTalentFrame = ToggleTalentFrame
    local ToggleAchievementFrame = ToggleAchievementFrame
    local ToggleFriendsFrame = ToggleFriendsFrame
    local ToggleHelpFrame = ToggleHelpFrame
    local ToggleFrame = ToggleFrame

    local PLAYER_ENTERING_WORLD, Minimap_GrabButtons

    RP:RegisterForEvent("PLAYER_LOGIN", function()

        local function _disabled()
            return not DB.enabled or disabled
        end
        RP.options.args.Options.args.Minimap = {
            type = "group",
            name = C.TURQ_COLOR:WrapTextInColorCode(MINIMAP_LABEL),
            order = 7,
            get = function(i)
                return DB[i[#i]]
            end,
            set = function(i, val)
                DB[i[#i]] = val
                PLAYER_ENTERING_WORLD()
            end,
            args = {
                status = {
                    type = "description",
                    name = format("This module is disabled because you are using: |cffffd700%s|r", reason or UNKNOWN),
                    fontSize = "medium",
                    order = 0,
                    hidden = not disabled
                },
                enabled = {
                    type = "toggle",
                    name = "Enable",
                    order = 1,
                    desc = "Allows you to change the settings, disable to lock settings.",
                    disabled = disabled
                },
                toggles = {
                    order = 2,
                    type = "group",
                    name = C.TURQ_COLOR:WrapTextInColorCode("Toggles"),
                    inline = true,
                    args = {
                        grabber = {
                            type = "toggle",
                            name = "Button Grabber",
                            order = 2,
                            disabled = _disabled
                        },
                        locked = {
                            type = "toggle",
                            name = "Lock Minimap",
                            order = 3,
                            disabled = _disabled
                        },
                        hide = {
                            type = "toggle",
                            name = "Hide Minimap",
                            order = 4,
                            disabled = _disabled
                        },
                        zone = {
                            type = "toggle",
                            name = "Hide Zone Text",
                            order = 5,
                            disabled = _disabled
                        },
                        combat = {
                            type = "toggle",
                            name = "Hide in combat",
                            order = 6,
                            disabled = _disabled
                        }
                    }
                },
                size = {
                    order = 3,
                    type = "group",
                    name = C.TURQ_COLOR:WrapTextInColorCode("Size"),
                    inline = true,
                    args = {
                        scale = {
                            type = "range",
                            name = "Scale",
                            order = 1,
                            disabled = _disabled,
                            width = "double",
                            min = 0.5,
                            max = 3,
                            step = 0.01,
                            bigStep = 0.1
                        }
                    }
                }
            }
        }
    end)

    --------------------------------------------------------------------------------

    do
        local find, len, sub = _G.string.find, _G.string.len, _G.string.sub
        local ceil, unpack, tinsert = _G.math.ceil, _G.unpack, _G.table.insert

        local LockButton, UnlockButton
        local CheckVisibility, GetVisibleList
        local GrabMinimapButtons, SkinMinimapButton, UpdateLayout

        local ignoreButtons = {"BattlefieldMinimap", "ButtonCollectFrame", "GameTimeFrame", "MiniMapBattlefieldFrame",
                               "MiniMapLFGFrame", "MiniMapMailFrame", "MiniMapPing", "MiniMapRecordingButton",
                               "MiniMapTracking", "MiniMapTrackingButton", "MiniMapVoiceChatFrame",
                               "MiniMapWorldMapButton", "Minimap", "MinimapBackdrop", "MinimapToggleButton",
                               "MinimapZoneTextButton", "MinimapZoomIn", "MinimapZoomOut", "TimeManagerClockButton"}

        local genericIgnores = {"GuildInstance", "GatherMatePin", "GatherNote", "GuildMap3Mini", "HandyNotesPin",
                                "LibRockConfig-1.0_MinimapButton", "NauticusMiniIcon", "WestPointer", "poiMinimap",
                                "Spy_MapNoteList_mini"}

        local partialIgnores = {"Node", "Note", "Pin"}
        local whiteList = {"LibDBIcon"}
        local buttonFunctions = {"SetParent", "SetFrameStrata", "SetFrameLevel", "ClearAllPoints", "SetPoint",
                                 "SetScale", "SetSize", "SetWidth", "SetHeight"}

        local grabberFrame, needUpdate
        local minimapFrames, skinnedButtons

        function LockButton(btn)
            for _, func in ipairs(buttonFunctions) do
                btn[func] = RP.Noop
            end
        end

        function UnlockButton(btn)
            for _, func in ipairs(buttonFunctions) do
                btn[func] = nil
            end
        end

        function CheckVisibility()
            local updateLayout

            for _, button in ipairs(skinnedButtons) do
                if button:IsVisible() and button.__hidden then
                    button.__hidden = false
                    updateLayout = true
                elseif not button:IsVisible() and not button.__hidden then
                    button.__hidden = true
                    updateLayout = true
                end
            end

            return updateLayout
        end

        function GetVisibleList()
            local t = {}

            for _, button in ipairs(skinnedButtons) do
                if button:IsVisible() then
                    tinsert(t, button)
                end
            end

            return t
        end

        function GrabMinimapButtons()
            for _, frame in ipairs(minimapFrames) do
                for i = 1, frame:GetNumChildren() do
                    local object = select(i, frame:GetChildren())

                    if object and object:IsObjectType("Button") then
                        SkinMinimapButton(object)
                    end
                end
            end

            if needUpdate or CheckVisibility() then
                UpdateLayout()
            end
        end

        function SkinMinimapButton(button)
            if not button or button.__skinned then
                return
            end

            local name = button:GetName()
            if not name then
                return
            end

            if button:IsObjectType("Button") then
                local validIcon

                for i = 1, #whiteList do
                    if sub(name, 1, len(whiteList[i])) == whiteList[i] then
                        validIcon = true
                        break
                    end
                end

                if not validIcon then
                    if tContains(ignoreButtons, name) then
                        return
                    end

                    for i = 1, #genericIgnores do
                        if sub(name, 1, len(genericIgnores[i])) == genericIgnores[i] then
                            return
                        end
                    end

                    for i = 1, #partialIgnores do
                        if find(name, partialIgnores[i]) then
                            return
                        end
                    end
                end

                -- button:SetPushedTexture(nil)
                -- button:SetHighlightTexture(nil)
                -- button:SetDisabledTexture(nil)
            end

            button:SetParent(grabberFrame)
            button:SetFrameLevel(grabberFrame:GetFrameLevel() + 5)
            LockButton(button)

            button:SetScript("OnDragStart", nil)
            button:SetScript("OnDragStop", nil)

            button.__hidden = button:IsVisible() and true or false
            button.__skinned = true
            tinsert(skinnedButtons, button)

            needUpdate = true
        end

        function UpdateLayout()
            if #skinnedButtons == 0 then
                return
            end

            local spacing = 2
            local visibleButtons = GetVisibleList()

            if #visibleButtons == 0 then
                grabberFrame:SetSize(21 + (spacing * 2), 21 + (spacing * 2))
                return
            end

            local numButtons = #visibleButtons
            local buttonsPerRow = 6
            local numColumns = ceil(numButtons / buttonsPerRow)

            if buttonsPerRow > numButtons then
                buttonsPerRow = numButtons
            end

            local barWidth = (21 * numColumns) + (1 * (numColumns - 1)) + spacing * 2
            local barHeight = (21 * buttonsPerRow) + (1 * (buttonsPerRow - 1)) + spacing * 2

            grabberFrame:SetSize(barWidth, barHeight)

            for i, button in ipairs(visibleButtons) do
                UnlockButton(button)

                button:SetSize(21, 21)
                button:ClearAllPoints()

                if i == 1 then
                    button:SetPoint("TOPRIGHT", grabberFrame, "TOPRIGHT")
                elseif (i - 1) % buttonsPerRow == 0 then
                    button:SetPoint("RIGHT", visibleButtons[i - buttonsPerRow], "LEFT", -spacing, 0)
                else
                    button:SetPoint("TOP", visibleButtons[i - 1], "BOTTOM", 0, -spacing)
                end

                LockButton(button)
            end

            needUpdate = nil
        end

        function Minimap_GrabButtons()
            if not DB["grabber"] then
                return
            end
            skinnedButtons = RP.WeakTable(skinnedButtons)
            minimapFrames = {Minimap, MinimapBackdrop}

            grabberFrame = CreateFrame("Frame", "RPMinimapButtonGrabber", Minimap)
            grabberFrame:SetSize(21, 21)
            grabberFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -2, -2)
            grabberFrame:SetFrameStrata("LOW")
            grabberFrame:SetClampedToScreen(true)

            GrabMinimapButtons()
            RP.NewTicker(5, GrabMinimapButtons)
        end
    end

    --------------------------------------------------------------------------------

    do
        local backdrop = {
            bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
            edgeFile = [[Interface\ChatFrame\ChatFrameBackground]],
            edgeSize = 1,
            insets = {
                top = 0,
                left = 0,
                bottom = 0,
                right = 0
            }
        }

        -- menu list
        local menuList = {{
            text = CHARACTER_BUTTON,
            notCheckable = 1,
            func = function()
                ToggleCharacter("PaperDollFrame")
            end
        }, {
            text = SPELLBOOK_ABILITIES_BUTTON,
            notCheckable = 1,
            func = function()
                ToggleFrame(SpellBookFrame)
            end
        }, {
            text = TALENTS_BUTTON,
            notCheckable = 1,
            func = ToggleTalentFrame
        }, {
            text = ACHIEVEMENT_BUTTON,
            notCheckable = 1,
            func = ToggleAchievementFrame
        }, {
            text = QUESTLOG_BUTTON,
            notCheckable = 1,
            func = function()
                ToggleFrame(QuestLogFrame)
            end
        }, {
            text = SOCIAL_BUTTON,
            notCheckable = 1,
            func = function()
                ToggleFriendsFrame(1)
            end
        }, {
            text = "Calendar",
            notCheckable = 1,
            func = function()
                GameTimeFrame:Click()
            end
        }, {
            text = BATTLEFIELD_MINIMAP,
            notCheckable = 1,
            func = ToggleBattlefieldMinimap
        }, {
            text = TIMEMANAGER_TITLE,
            notCheckable = 1,
            func = ToggleTimeManager
        }, {
            text = PLAYER_V_PLAYER,
            notCheckable = 1,
            func = function()
                ToggleFrame(PVPParentFrame)
            end
        }, {
            text = LFG_TITLE,
            notCheckable = 1,
            func = function()
                ToggleFrame(LFDParentFrame)
            end
        }, {
            text = LOOKING_FOR_RAID,
            notCheckable = 1,
            func = function()
                ToggleFrame(LFRParentFrame)
            end
        }, {
            text = MAINMENU_BUTTON,
            notCheckable = 1,
            func = function()
                if GameMenuFrame:IsShown() then
                    HideUIPanel(GameMenuFrame)
                else
                    ShowUIPanel(GameMenuFrame)
                end
            end
        }, {
            text = HELP_BUTTON,
            notCheckable = 1,
            func = ToggleHelpFrame
        }}

        -- handles mouse wheel action on minimap
        local function Minimap_OnMouseWheel(self, z)
            local c = Minimap:GetZoom()
            if z > 0 and c < 5 then
                Minimap:SetZoom(c + 1)
            elseif (z < 0 and c > 0) then
                Minimap:SetZoom(c - 1)
            end
        end

        local function Cluster_OnMouseDown(self, button)
            if button == "LeftButton" and not DB.locked then
                self:StartMoving()
            end
        end

        local function Cluster_OnMouseUp(self, button)
            if button == "LeftButton" and not DB.locked then
                self:StopMovingOrSizing()
                -- Save the new position
                local point, _, _, xOfs, yOfs = self:GetPoint()
                DB.moved = true
                DB.point = point
                DB.x = xOfs
                DB.y = yOfs
                MinimapCluster:ClearAllPoints()
                MinimapCluster:SetPoint(DB.point, DB.x, DB.y)
            end
        end

        local menuFrame = CreateFrame("Frame", "RPMinimapRightClickMenu", UIParent, "UIDropDownMenuTemplate")
        menuFrame:SetFrameLevel(Minimap:GetFrameLevel() + 1)
        menuFrame:SetPoint('TOPLEFT', Minimap, 20, -20)
        menuFrame:SetPoint('BOTTOMRIGHT', Minimap, -20, 20)
        menuFrame:SetAlpha(0)

        -- handle mouse clicks on minimap
        local function Minimap_OnMouseUp(self, button)
            -- create the menu frame
            if button == "RightButton" then
                EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
            elseif button == "MiddleButton" then
                ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self)
            else
                Minimap_OnClick(self)
            end
        end

        menuFrame:SetScript("OnMouseUp", Minimap_OnMouseUp)

        -- called once the user enter the world
        function PLAYER_ENTERING_WORLD()
            if disabled then
                return
            end

            -- fix the stupid buff with MoveAnything Condolidate buffs
            if not (_G.MOVANY or _G.MovAny or RP.MA) then
                ConsolidatedBuffs:SetParent(UIParent)
                ConsolidatedBuffs:ClearAllPoints()
                ConsolidatedBuffs:SetPoint("TOPRIGHT", -205, -13)
                --[[ ConsolidatedBuffs.SetPoint = RP.Noop ]]
            end

            for i, v in pairs({MinimapBorder, MiniMapMailBorder, _G.QueueStatusMinimapButtonBorder,
                               select(1, TimeManagerClockButton:GetRegions()), select(1, GameTimeFrame:GetRegions())}) do
                v:SetVertexColor(.3, .3, .3)
            end

            MinimapBorderTop:Hide()
            MinimapZoomIn:Hide()
            MinimapZoomOut:Hide()
            MiniMapWorldMapButton:Hide()
            RP:Kill(GameTimeFrame)
            RP:Kill(MiniMapTracking)
            MinimapZoneText:SetPoint("TOPLEFT", "MinimapZoneTextButton", "TOPLEFT", 5, 5)
            if RP.db.profile.minimap.zone then
                MinimapZoneTextButton:Hide()
            else
                MinimapZoneTextButton:Show()
            end
            Minimap:EnableMouseWheel(true)

            Minimap:SetScript("OnMouseWheel", Minimap_OnMouseWheel)
            -- Minimap:SetScript("OnMouseUp", Minimap_OnMouseUp)

            -- Make is square
            MinimapBorder:SetTexture(nil)
            Minimap:SetFrameLevel(2)
            Minimap:SetFrameStrata("BACKGROUND")
            Minimap:SetMaskTexture([[Interface\ChatFrame\ChatFrameBackground]])
            -- local BDFrame = CreateFrame("Frame", "Minimap_BD", Minimap, "BackdropTemplate")
            -- BDFrame:SetAllPoints(Minimap)
            -- BDFrame:SetBackdrop({
            --	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
            --	insets = {top = -2, bottom = -1, left = -2, right = -1}
            -- })
            -- BDFrame:SetBackdropColor(0, 0, 0, 1)
            -- BDFrame:SetFrameLevel(Minimap:GetFrameLevel()-1)

            MinimapCluster:SetScale(DB.scale or 1)

            if DB.hide then
                MinimapCluster:Hide()
            elseif not DB.combat and not RP.InCombat then
                MinimapCluster:Show()
            end

            if DB.locked then
                if MinimapCluster.handle then

                    MinimapCluster.handle:EnableMouse(false)
                    MinimapCluster.handle:SetMovable(false)
                    -- MinimapCluster.handle:RegisterForDrag(nil)
                    MinimapCluster.handle:SetScript("OnMouseDown", nil)
                    MinimapCluster.handle:SetScript("OnMouseUp", nil)
                    MinimapCluster.handle:Hide()
                end
            else
                if not MinimapCluster.handle then
                    MinimapCluster.handle = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
                    MinimapCluster.handle:SetPoint("TOPLEFT", MinimapCluster, 10, -10)
                    MinimapCluster.handle:SetPoint("BOTTOMRIGHT", MinimapCluster, -10, 10)
                    MinimapCluster.handle:SetBackdrop(backdrop)
                    MinimapCluster.handle:SetBackdropColor(1, 0, 0, 0.5)
                    MinimapCluster.handle:SetBackdropBorderColor(0, 0, 0, 1)
                    MinimapCluster.handle:SetClampedToScreen(false)
                end

                MinimapCluster.handle:EnableMouse(true)
                MinimapCluster.handle:SetMovable(true)
                MinimapCluster.handle:RegisterForDrag("LeftButton")
                MinimapCluster.handle:SetScript("OnMouseDown", Cluster_OnMouseDown)
                MinimapCluster.handle:SetScript("OnMouseUp", Cluster_OnMouseUp)
                MinimapCluster.handle:Show()
            end

            -- move to position
            if DB.moved then
                MinimapCluster:ClearAllPoints()
                MinimapCluster:SetPoint(DB.point, DB.x, DB.y)
                MinimapCluster:SetClampedToScreen(false)
            end

            Minimap_GrabButtons()
        end
        RP:RegisterForEvent("PLAYER_LOGIN", PLAYER_ENTERING_WORLD)
    end

    RP:RegisterForEvent("PLAYER_REGEN_ENABLED", function()
        if not disabled and DB.enabled and DB.combat and not MinimapCluster:IsShown() and not DB.hide then
            MinimapCluster:Show()
        end
    end)

    RP:RegisterForEvent("PLAYER_REGEN_DISABLED", function()
        if not disabled and DB.enabled and DB.combat and MinimapCluster:IsShown() then
            MinimapCluster:Hide()
        end
    end)


    local pinger, timer
    local frame = CreateFrame("Frame")
    RP:RegisterForEvent("MINIMAP_PING", function(_, unit, coordx, coordy)
        if UnitName(unit) ~= RP.name then
            -- create the pinger
            if not pinger then
                pinger = frame:CreateFontString(nil, "OVERLAY")
                pinger:SetFont("Fonts\\FRIZQT__.ttf", 13, "OUTLINE")
                pinger:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
                pinger:SetJustifyH("CENTER")
            end

            if timer and time() - timer > 1 or not timer then
                local Class = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS[select(2, UnitClass(unit))]
                pinger:SetText(format("|cffff0000*|r %s |cffff0000*|r", UnitName(unit)))
                pinger:SetTextColor(Class.r, Class.g, Class.b)
                UIFrameFlash(frame, 0.2, 2.8, 5, false, 0, 5)
                timer = time()
            end
        end
    end)

    local mapBorder = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
    mapBorder:SetBackdrop({
        edgeFile = "Interface\\AddOns\\RasPort\\Media\\Border\\border-modified.tga",
        tileEdge = true,
        edgeSize = 10
    })
    mapBorder:SetFrameLevel(Minimap:GetFrameLevel() + 1)
    mapBorder:SetPoint("TOPLEFT", Minimap, "BOTTOMRIGHT", 2, -2)
    mapBorder:SetPoint("BOTTOMRIGHT", Minimap, "TOPLEFT", -2, 2)
    mapBorder:SetAlpha(1)

    function RP:UpdateMapBorder()
        local CC = RP.rasColor
        local function SetColorByProfile()
            if RP.db.profile["Class"] then
                return CC.r, CC.g, CC.b
            elseif RP.db.profile["Blackout"] then
                return 0.15, 0.15, 0.15
            elseif RP.db.profile["Custom Color"] then
                return RP.db.profile["CC"].red, RP.db.profile["CC"].green, RP.db.profile["CC"].blue
            end
            return 1, 0, 0
        end

        local r, g, b = SetColorByProfile()
        mapBorder:SetBackdropBorderColor(r, g, b, 1)
    end

    local function MoveBuff()
        if BuffButton1 then
            BuffButton1:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -20, 0)
        end
        MiniMapWorldMapButton:Hide()
        RP:UpdateMapBorder()
    end

    local taint = CreateFrame("Frame")
    taint:RegisterUnitEvent("UNIT_AURA", "player")
    taint:RegisterEvent("PLAYER_ENTERING_WORLD")
    taint:SetScript("OnEvent", function(self)
        MoveBuff()
        ToggleFrame(SpellBookFrame)
        ToggleFrame(SpellBookFrame)
    end)
end)
