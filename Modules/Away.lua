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
local _, P, _, C = RP:Unpack() -- m, p, u, c
RP:AddModule("Away", "Away from keyboard screen", function()
    if RP:IsDisabled("Away") or RP.ElvUI then return end

    local _G = getfenv(0)
    local select = _G.select
    local pi = _G.math.pi
    local sin = _G.math.sin
    local rad = _G.math.rad
    local date = _G.date
    local getmetatable = _G.getmetatable
    local CreateFrame = _G.CreateFrame
    local EnumerateFrames = _G.EnumerateFrames
    local format = _G.string.format
    local len = _G.string.len
    local sub = _G.string.sub
    local lower = _G.string.lower

    --RP.Player.userName
    --RP.Player.userLevel
    --RP.Player.userRace
    --RP.Player.userClass
    --RP.Player.userFaction
    --RP.Player.userClassColor
    RP.playerGuild = " "

    local font = STANDARD_TEXT_FONT
    local blank = [[Interface\AddOns\SUI\textures\blank.tga]]
    local borderr, borderg, borderb, backdropa
    local backdropr, backdropg, backdropb

    local backdrop = {
        bgFile = "Interface\\AddOns\\RasPort\\Media\\Background\\Square_White.tga",
        tile = false,
        tileSize = 16,
        edgeSize = 16,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    }

    local spinning

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

    local function SetTemplate(f, t)

        if t == "Transparent" then
            backdropr, backdropg, backdropb, backdropa = 0.05, 0.05, 0.05, 0.7
            borderr, borderg, borderb = 0.125, 0.125, 0.125
        else
            backdropr, backdropg, backdropb, backdropa = 0, 0, 0, 1
            borderr, borderg, borderb = 0, 0, 0
        end

        f:SetBackdrop({
            edgeFile = blank,
            tile = false,
            tileSize = 0,
            edgeSize = 1
        })

        f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
        f:SetBackdropBorderColor(borderr, borderg, borderb)
    end

    local function addapi(object)
        local mt = getmetatable(object).__index
        if not object.SetTemplate then
            mt.SetTemplate = SetTemplate
        end
    end

    local handled = {
        ["Frame"] = true
    }
    local object = CreateFrame("Frame")
    addapi(object)
    addapi(object:CreateTexture())
    addapi(object:CreateFontString())

    object = EnumerateFrames()
    while object do
        if not handled[object:GetObjectType()] then
            addapi(object)
            handled[object:GetObjectType()] = true
        end

        object = EnumerateFrames(object)
    end

    local rpAway = CreateFrame("Frame", "RasPort - Away", nil, "BackdropTemplate")
    rpAway:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -2, -2)
    rpAway:SetPoint("TOPRIGHT", UIParent, "BOTTOMRIGHT", 2, 150)
    rpAway:SetTemplate("Transparent")
    rpAway:Hide()

    local rpAwayTop = CreateFrame("Frame", "RASAFKTop", nil, "BackdropTemplate")
    rpAwayTop:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -20, 5)
    rpAwayTop:SetPoint("BOTTOMRIGHT", UIParent, "TOPRIGHT", 20, -140)
    rpAwayTop:SetBackdrop(backdrop)
    rpAwayTop:SetBackdropColor(0.15, 0.15, 0.15, 0.7)
    rpAwayTop:SetFrameStrata("FULLSCREEN")
    rpAwayTop:Hide()

    rpAwayTop.Text = rpAwayTop:CreateFontString(nil, "OVERLAY")
    rpAwayTop.Text:SetPoint("CENTER", rpAwayTop, "CENTER", 0, 0)
    rpAwayTop.Text:SetFont(font, 60, "OUTLINE")
    rpAwayTop.Text:SetText("AFK")
    AddRainbowColorAnimation(rpAwayTop.Text, rpAwayTop)

    rpAwayTop.DateText = rpAwayTop:CreateFontString(nil, "OVERLAY")
    rpAwayTop.DateText:SetPoint("RIGHT", rpAwayTop, -40, -30)
    rpAwayTop.DateText:SetFont(font, 15, "OUTLINE")

    rpAwayTop.ClockText = rpAwayTop:CreateFontString(nil, "OVERLAY")
    rpAwayTop.ClockText:SetPoint("RIGHT", rpAwayTop, -40, -50)
    rpAwayTop.ClockText:SetFont(font, 20, "OUTLINE")

    rpAwayTop.PlayerNameText = rpAwayTop:CreateFontString(nil, "OVERLAY")
    rpAwayTop.PlayerNameText:SetPoint("LEFT", rpAwayTop, "LEFT", 25, 19)
    rpAwayTop.PlayerNameText:SetFont(font, 26, "OUTLINE")
    rpAwayTop.PlayerNameText:SetText(RP.Player.userName.." ".."("..RP.Player.userClass..")")
    rpAwayTop.PlayerNameText:SetTextColor(RP.Player.userClassColor.r, RP.Player.userClassColor.g, RP.Player.userClassColor.b)

    rpAway.Text = rpAwayTop:CreateFontString(nil, "OVERLAY")
    rpAway.Text:SetPoint("BOTTOMLEFT", rpAway, "BOTTOMLEFT", 20, 10)
    rpAway.Text:SetFont(font, 22, "OUTLINE")
    rpAway.Text:SetText("|cfffcc200v|r|cff8601111.4.5|r")

    -- Set Up the Player Model
    rpAway.playerModel = CreateFrame('PlayerModel', nil, rpAway);
    rpAway.playerModel:SetSize(800, 1000)
    rpAway.playerModel:SetPoint("RIGHT", rpAway, "RIGHT", 250, 110)
    rpAway.playerModel:SetUnit('player');
    rpAway.playerModel:SetAnimation(96);
    rpAway.playerModel:SetRotation(rad(-15));
    rpAway.playerModel:SetCamDistanceScale(1.8);
    rpAway.playerModel:SetFrameStrata("FULLSCREEN")


    local rpAwayBottom = CreateFrame("Frame", "rpAwayBottom", nil, "BackdropTemplate")
    rpAwayBottom:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -20, -5)
    rpAwayBottom:SetPoint("TOPRIGHT", UIParent, "BOTTOMRIGHT", 20, 140)
    rpAwayBottom:SetBackdrop(backdrop)
    rpAwayBottom:SetBackdropColor(0.15, 0.15, 0.15, 0.7)
    rpAwayBottom:SetFrameStrata("FULLSCREEN")
    rpAwayBottom:Hide()

    rpAway.texture = rpAwayBottom:CreateTexture(nil, "BACKGROUND")
    rpAway.texture:SetSize(250, 250)
    rpAway.texture:SetPoint("LEFT", rpAwayBottom, 20, 45)
    rpAway.texture:SetTexture("Interface\\AddOns\\RasPort\\Media\\Logo\\AFKLogo.tga")
    rpAway.texture:SetDrawLayer("OVERLAY", 7)

    local function getguild()
        local guildstatus = true

        if IsInGuild() then
            RP.playerGuild = GetGuildInfo("player")

            if (RP.playerGuild == nil) then
                return "..."
            else
                return RP.playerGuild
            end
        else
            return " "
        end

    end

    rpAwayTop.GuildText = rpAwayTop:CreateFontString(nil, "OVERLAY")
    rpAwayTop.GuildText:SetPoint("LEFT", rpAwayTop, "LEFT", 25, -3)
    rpAwayTop.GuildText:SetFont(font, 15, "OUTLINE")
    rpAwayTop.GuildText:SetText("|cff8a2be2" .. getguild() .. "|r")

    rpAwayTop.PlayerInfoText = rpAwayTop:CreateFontString(nil, "OVERLAY")
    rpAwayTop.PlayerInfoText:SetPoint("LEFT", rpAwayTop, "LEFT", 25, -20)
    rpAwayTop.PlayerInfoText:SetFont(font, 15, "OUTLINE")
    rpAwayTop.PlayerInfoText:SetText("Level" .. " " .. RP.Player.userLevel .. " " .. RP.Player.userFaction)

    local function getTime()
        if RP.db.profile.info["12-Hour"] then
            local t = date("%I:%M")
            local ampm = date("%p")
            return "|c00ffffff" .. t .. "|r " .. lower(ampm)
        else
            local t = date("%H:%M")
            return "|c00ffffff" .. t .. "|r"
        end
    end

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
        return date("|c00ffffff%B|r ".."".."%d")..dateletter
    end

    local interval = 0
    rpAwayTop:SetScript("OnUpdate", function(self, elapsed)
        interval = interval - elapsed
        if (interval <= 0) then
            rpAwayTop.ClockText:SetText(format("%s", getTime()))
            rpAwayTop.DateText:SetText(format("%s", getDateTotal()))
            interval = 0.5
        end
    end)

    local OnEvent = function(self, event, unit)
        if event == "PLAYER_FLAGS_CHANGED" then
            local isArena, isRegistered = IsActiveBattlefieldArena()
            if unit == "player" then
                if UnitIsAFK(unit) and not UnitIsDead(unit) and not InCombatLockdown() and not isArena then
                    SpinStart()
                    rpAway:Show()
                    rpAwayTop:Show()
                    rpAwayBottom:Show()
                    Minimap:Hide()
                else
                    SpinStop()
                    rpAway:Hide()
                    rpAwayTop:Hide()
                    rpAwayBottom:Hide()
                    Minimap:Show()
                end
            end
        elseif event == "PLAYER_STARTED_MOVING" then
            SpinStop()
        elseif event == "PLAYER_LEAVING_WORLD" then
            SpinStop()
        elseif event == "PLAYER_DEAD" then
            if UnitIsAFK("player") then
                SpinStop()
                rpAway:Hide()
                rpAwayTop:Hide()
                Minimap:Show()
            end
        end
    end

    rpAway:RegisterEvent("PLAYER_ENTERING_WORLD")
    rpAway:RegisterEvent("PLAYER_LEAVING_WORLD")
    rpAway:RegisterEvent("PLAYER_FLAGS_CHANGED")
    rpAway:RegisterEvent("PLAYER_STARTED_MOVING")
    rpAway:RegisterEvent("PLAYER_DEAD")
    rpAway:SetScript("OnEvent", OnEvent)

    rpAway:SetScript("OnShow", function(self)
        UIParent:SetAlpha(0);
    end)

    rpAway:SetScript("OnHide", function(self)
        UIFrameFadeOut(UIParent, 0.5, 0, 1)
    end)

    function SpinStart()
        spinning = true
        MoveViewRightStart(0.03)
    end

    function SpinStop()
        if (not spinning) then
            return
        end
        spinning = nil
        MoveViewRightStop()
    end
end)
