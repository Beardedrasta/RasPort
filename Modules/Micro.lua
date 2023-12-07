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
local _, P, U, _ = RP:Unpack() -- m, p, u, c
RP:AddModule("Micro","Micro Bar with a rasport flare!", function()
    if RP:IsDisabled("Micro") then return end

    local _G = getfenv(0)
    local pairs, wipe, select, pcall = _G.pairs, _G.wipe, _G.select, _G.pcall
    local getmetatable, geterrorhandler = _G.getmetatable, _G.geterrorhandler
    local GetFramesRegisteredForEvent = _G.GetFramesRegisteredForEvent
    local issecurevariable, hooksecurefunc = _G.issecurevariable, _G.hooksecurefunc

	local spacing = 15
	local microTexture = 'Interface\\Addons\\RasPort\\Media\\Button\\uimicromenu2x'
	local sizeX, sizeY = 32, 40
    local L = U.L
    local fontPath = U.LSM:Fetch("font", RP.db.profile.info["Font"])
    local DB = RP.db.profile


    local MB = CreateFrame("Frame" , nil, UIParent)
    MB:SetFrameLevel(7)
    MB:RegisterEvent("PLAYER_LOGIN")

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



local buttons = {
    CharacterMicroButton,
SpellbookMicroButton,
TalentMicroButton,
QuestLogMicroButton,
SocialsMicroButton,
WorldMapMicroButton,
MainMenuMicroButton,
HelpMicroButton,
}

local Atlas = {
	--SpellBook
	["UI-HUD-MicroMenu-SpellbookAbilities-Disabled"] = {16, 20, 0.452148, 0.514648, 0.494141, 0.654297, false, false, "2x"},
    ["UI-HUD-MicroMenu-SpellbookAbilities-Down"] = {16, 20, 0.452148, 0.514648, 0.658203, 0.818359, false, false, "2x"},
    ["UI-HUD-MicroMenu-SpellbookAbilities-Mouseover"] = {16, 20, 0.452148, 0.514648, 0.822266, 0.982422, false, false, "2x"},
    ["UI-HUD-MicroMenu-SpellbookAbilities-Up"] = {16, 20, 0.516602, 0.579102, 0.00195312, 0.162109, false, false, "2x"},
	--Talents
	["UI-HUD-MicroMenu-SpecTalents-Disabled"] = {16, 20, 0.387695, 0.450195, 0.822266, 0.982422, false, false, "2x"},
    ["UI-HUD-MicroMenu-SpecTalents-Down"] = {16, 20, 0.452148, 0.514648, 0.00195312, 0.162109, false, false, "2x"},
    ["UI-HUD-MicroMenu-SpecTalents-Mouseover"] = {16, 20, 0.452148, 0.514648, 0.166016, 0.326172, false, false, "2x"},
    ["UI-HUD-MicroMenu-SpecTalents-Up"] = {16, 20, 0.452148, 0.514648, 0.330078, 0.490234, false, false, "2x"},
	--Questlog
    ["UI-HUD-MicroMenu-Questlog-Disabled"] = {16, 20, 0.323242, 0.385742, 0.494141, 0.654297, false, false, "2x"},
    ["UI-HUD-MicroMenu-Questlog-Down"] = {16, 20, 0.323242, 0.385742, 0.658203, 0.818359, false, false, "2x"},
    ["UI-HUD-MicroMenu-Questlog-Mouseover"] = {16, 20, 0.323242, 0.385742, 0.822266, 0.982422, false, false, "2x"},
    ["UI-HUD-MicroMenu-Questlog-Up"] = {16, 20, 0.387695, 0.450195, 0.00195312, 0.162109, false, false, "2x"},
    --Socials
    ["UI-HUD-MicroMenu-Socials-Disabled"] = {16, 20, 0.194336, 0.256836, 0.658203, 0.818359, false, false, "2x"},
    ["UI-HUD-MicroMenu-Socials-Down"] = {16, 20, 0.194336, 0.256836, 0.822266, 0.982422, false, false, "2x"},
    ["UI-HUD-MicroMenu-Socials-Mouseover"] = {16, 20, 0.258789, 0.321289, 0.658203, 0.818359, false, false, "2x"},
    ["UI-HUD-MicroMenu-Socials-Up"] = {16, 20, 0.258789, 0.321289, 0.822266, 0.982422, false, false, "2x"},
    --WorldMap
    --GameMenu
    ["UI-HUD-MicroMenu-GameMenu-Disabled"] = {16, 20, 0.129883, 0.192383, 0.330078, 0.490234, false, false, "2x"},
    ["UI-HUD-MicroMenu-GameMenu-Down"] = {16, 20, 0.129883, 0.192383, 0.494141, 0.654297, false, false, "2x"},
    ["UI-HUD-MicroMenu-GameMenu-Mouseover"] = {16, 20, 0.129883, 0.192383, 0.658203, 0.818359, false, false, "2x"},
    ["UI-HUD-MicroMenu-GameMenu-Up"] = {16, 20, 0.129883, 0.192383, 0.822266, 0.982422, false, false, "2x"},
    --Help
    ["UI-HUD-MicroMenu-Shop-Disabled"] = {16, 20, 0.387695, 0.450195, 0.166016, 0.326172, false, false, "2x"},
    ["UI-HUD-MicroMenu-Shop-Mouseover"] = {16, 20, 0.387695, 0.450195, 0.330078, 0.490234, false, false, "2x"},
    ["UI-HUD-MicroMenu-Shop-Down"] = {16, 20, 0.387695, 0.450195, 0.494141, 0.654297, false, false, "2x"},
    ["UI-HUD-MicroMenu-Shop-Up"] = {16, 20, 0.387695, 0.450195, 0.658203, 0.818359, false, false, "2x"},
}

function MB.SetButtonFromAtlas(frame, atlas, textureRef, pre, name)
    local key = pre .. name

    local up = atlas[key .. '-Up']
    frame:SetHitRectInsets(0, 0, 0, 0)

    frame:SetNormalTexture(textureRef)
    frame:GetNormalTexture():SetTexCoord(up[3], up[4], up[5], up[6])

    local disabled = atlas[key .. '-Disabled']
    frame:SetDisabledTexture(textureRef)
    frame:GetDisabledTexture():SetTexCoord(disabled[3], disabled[4], disabled[5], disabled[6])

    local down = atlas[key .. '-Down']
    frame:SetPushedTexture(textureRef)
    frame:GetPushedTexture():SetTexCoord(down[3], down[4], down[5], down[6])

    local mouseover = atlas[key .. '-Mouseover']
    frame:SetHighlightTexture(textureRef)
    frame:GetHighlightTexture():SetTexCoord(mouseover[3], mouseover[4], mouseover[5], mouseover[6])

    return frame
end

function MB.SetMapButton(frame, mapRef)
    frame:SetHitRectInsets(0, 0, 0, 0)
    frame:SetNormalTexture(mapRef)
    frame:SetDisabledTexture(mapRef)
    frame:SetPushedTexture(mapRef)
    frame:SetHighlightTexture(mapRef)

    return frame
end

function MB.ChangeCharacterMicroButton()

    local frame = CharacterMicroButton
    local sizeX, sizeY = 32, 40
    local offX, offY = frame:GetPushedTextOffset()

    frame:SetSize(sizeX, sizeY)
    frame:SetHitRectInsets(0, 0, 0, 0)

    frame:GetNormalTexture():SetAlpha(0)
    frame:GetPushedTexture():SetAlpha(0)
    frame:GetHighlightTexture():SetAlpha(0)

    MicroButtonPortrait:ClearAllPoints()
    MicroButtonPortrait:Hide()

    local newPort = frame:CreateTexture('NewPort', 'ARTWORK')
    newPort:SetAllPoints()
    newPort:SetPoint('TOPLEFT', 8, -7)
    newPort:SetPoint('BOTTOMRIGHT', -6, 7)
    newPort:SetTexCoord(0.2, 0.8, 0.0666, 0.9)
    frame.newPort = newPort

    local microPortraitMaskTexture = "Interface\\AddOns\\RasPort\\Media\\Button\\circle"

    local newPortMask = frame:CreateMaskTexture()
    newPortMask:SetTexture(microPortraitMaskTexture, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
    newPortMask:SetPoint('CENTER')
    newPortMask:SetSize(35, 65)
    newPort:AddMaskTexture(newPortMask)
    frame.newPortMask = newPortMask

    local newPortShadow = frame:CreateTexture('NewPortShadow', 'OVERLAY')
    newPortShadow:SetTexture(microTexture)
    newPortShadow:SetTexCoord(0.323242, 0.385742, 0.166016, 0.326172)
    newPortShadow:SetSize(32, 41)
    newPortShadow:SetPoint('CENTER', 1, -4)
    newPortShadow:Hide()
    frame.newPortShadow = newPortShadow

    SetPortraitTexture(frame.newPort, 'player')

    CharacterMicroButton:HookScript('OnEvent', function(self)
        SetPortraitTexture(frame.newPort, 'player')
    end)

    frame.SetState = function(pushed)
        if pushed then
            local delta = offX / 2
            frame.newPortMask:ClearAllPoints()
            frame.newPortMask:SetPoint('CENTER', delta, -delta)

            frame.newPort:ClearAllPoints()
            frame.newPort:SetPoint('TOPLEFT', 8 + delta, -7 - delta)
            frame.newPort:SetPoint('BOTTOMRIGHT', -6 + delta, 7 - delta)

            newPortShadow:Show()
        else
            frame.newPortMask:ClearAllPoints()
            frame.newPortMask:SetPoint('CENTER', 0, 0)

            frame.newPort:ClearAllPoints()
            frame.newPort:SetPoint('TOPLEFT', 8, -7)
            frame.newPort:SetPoint('BOTTOMRIGHT', -6, 7)

            newPortShadow:Hide()
        end
    end

    do
        local dx, dy = -1, 1

        local bg = frame:CreateTexture('Background', 'BACKGROUND')
        bg:SetTexture(microTexture)
        bg:SetSize(sizeX, sizeY + 1)
        bg:SetTexCoord(0.0654297, 0.12793, 0.330078, 0.490234)
        bg:SetPoint('CENTER', dx, dy)
        frame.Background = bg

        local bgPushed = frame:CreateTexture('Background', 'BACKGROUND')
        bgPushed:SetTexture(microTexture)
        bgPushed:SetSize(sizeX, sizeY + 1)
        bgPushed:SetTexCoord(0.0654297, 0.12793, 0.494141, 0.654297)
        bgPushed:SetPoint('CENTER', dx + offX, dy + offY)
        bgPushed:Hide()
        frame.BackgroundPushed = bgPushed

        frame.State = {}
        frame.State.pushed = false
        frame.State.highlight = false

        frame.HandleState = function()
            local state = frame.State

            if state.pushed then
                frame.Background:Hide()
                frame.BackgroundPushed:Show()
                frame:GetHighlightTexture():ClearAllPoints()
                frame:GetHighlightTexture():SetPoint('CENTER', offX, offY)
            else
                frame.Background:Show()
                frame.BackgroundPushed:Hide()
                frame:GetHighlightTexture():ClearAllPoints()

                frame:GetHighlightTexture():SetPoint('CENTER', 0, 0)
            end
            frame.SetState(state.pushed)
        end
        frame.HandleState()

        frame:GetNormalTexture():HookScript('OnShow', function(self)
            frame.State.pushed = false
            frame.HandleState()
        end)
        frame:GetPushedTexture():HookScript('OnShow', function(self)
            frame.State.pushed = true
            frame.HandleState()
        end)
        frame:HookScript('OnEnter', function(self)
            frame.State.highlight = true
            frame.HandleState()
        end)

        frame:HookScript('OnLeave', function(self)
            frame.State.highlight = false
            frame.HandleState()
        end)
        local flash = _G[frame:GetName() .. 'Flash']
        if flash then
            flash:SetSize(sizeX, sizeY)
            flash:SetTexture(microTexture)
            flash:SetTexCoord(0.323242, 0.385742, 0.00195312, 0.162109)
            flash:ClearAllPoints()
            flash:SetPoint('CENTER', 0, 0)
        end
    end
end

function MB.ChangeMicroMenuButton()

    local frame = MainMenuMicroButton
    local sizeX, sizeY = 32, 40
    local offX, offY = frame:GetPushedTextOffset()

    frame:SetSize(sizeX, sizeY)
    frame:SetHitRectInsets(0, 0, 0, 0)

    MicroButtonPortrait:ClearAllPoints()
    MicroButtonPortrait:Hide()

    local newPort = frame:CreateTexture('NewPort', 'ARTWORK')
    newPort:SetTexture(microTexture)
    newPort:SetAllPoints()
    newPort:SetPoint('TOPLEFT', 0,0)
    newPort:SetPoint('BOTTOMRIGHT', 0,0)
    newPort:SetTexCoord(0.387695, 0.450195, 0.658203, 0.818359)
    frame.newPort = newPort

    local microPortraitMaskTexture = "Interface\\AddOns\\RasPort\\Media\\Button\\circle"

    local newPortMask = frame:CreateMaskTexture()
    newPortMask:SetTexture(microPortraitMaskTexture, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
    newPortMask:SetPoint('CENTER')
    newPortMask:SetSize(35, 65)
    newPort:AddMaskTexture(newPortMask)
    frame.newPortMask = newPortMask

    local newPortShadow = frame:CreateTexture('NewPortShadow', 'OVERLAY')
    newPortShadow:SetTexture(microTexture)
    newPortShadow:SetTexCoord(0.323242, 0.385742, 0.166016, 0.326172)
    newPortShadow:SetSize(32, 41)
    newPortShadow:SetPoint('CENTER', 1, -4)
    newPortShadow:Hide()
    frame.newPortShadow = newPortShadow

    frame.SetState = function(pushed)
        if pushed then
            local delta = offX / 2
            frame.newPortMask:ClearAllPoints()
            frame.newPortMask:SetPoint('CENTER', delta, -delta)

            frame.newPort:ClearAllPoints()
            frame.newPort:SetPoint('TOPLEFT', 0 + delta, 0 - delta)
            frame.newPort:SetPoint('BOTTOMRIGHT', 0 + delta, 0 - delta)

            newPortShadow:Show()
        else
            frame.newPortMask:ClearAllPoints()
            frame.newPortMask:SetPoint('CENTER', 0, 0)

            frame.newPort:ClearAllPoints()
            frame.newPort:SetPoint('TOPLEFT', 0,0)
            frame.newPort:SetPoint('BOTTOMRIGHT', 0,0)

            newPortShadow:Hide()
        end
    end

    do
        local dx, dy = -1, 1

        local bg = frame:CreateTexture('Background', 'BACKGROUND')
        bg:SetTexture(microTexture)
        bg:SetSize(sizeX, sizeY + 1)
        bg:SetTexCoord(0.0654297, 0.12793, 0.330078, 0.490234)
        bg:SetPoint('CENTER', dx, dy)
        frame.Background = bg

        local bgPushed = frame:CreateTexture('Background', 'BACKGROUND')
        bgPushed:SetTexture(microTexture)
        bgPushed:SetSize(sizeX, sizeY + 1)
        bgPushed:SetTexCoord(0.0654297, 0.12793, 0.494141, 0.654297)
        bgPushed:SetPoint('CENTER', dx + offX, dy + offY)
        bgPushed:Hide()
        frame.BackgroundPushed = bgPushed

        frame.State = {}
        frame.State.pushed = false
        frame.State.highlight = false

        frame.HandleState = function()
            local state = frame.State

            if state.pushed then
                frame.Background:Hide()
                frame.BackgroundPushed:Show()
                frame:GetHighlightTexture():ClearAllPoints()
                frame:GetHighlightTexture():SetPoint('CENTER', offX, offY)
            else
                frame.Background:Show()
                frame.BackgroundPushed:Hide()
                frame:GetHighlightTexture():ClearAllPoints()

                frame:GetHighlightTexture():SetPoint('CENTER', 0, 0)
            end
            frame.SetState(state.pushed)
        end
        frame.HandleState()

        frame:GetNormalTexture():HookScript('OnShow', function(self)
            frame.State.pushed = false
            frame.HandleState()
        end)
        frame:GetPushedTexture():HookScript('OnShow', function(self)
            frame.State.pushed = true
            frame.HandleState()
        end)
        frame:HookScript('OnEnter', function(self)
            frame.State.highlight = true
            frame.HandleState()
        end)

        frame:HookScript('OnLeave', function(self)
            frame.State.highlight = false
            frame.HandleState()
        end)
        local flash = _G[frame:GetName() .. 'Flash']
        if flash then
            flash:SetSize(sizeX, sizeY)
            flash:SetTexture(microTexture)
            flash:SetTexCoord(0.323242, 0.385742, 0.00195312, 0.162109)
            flash:ClearAllPoints()
            flash:SetPoint('CENTER', 0, 0)
        end
    end
end


local function UpdateMicroTexture()
	if CharacterMicroButton then
        MB.ChangeCharacterMicroButton()
	end

	if SpellbookMicroButton then
		MB.SetButtonFromAtlas(SpellbookMicroButton, Atlas, microTexture, 'UI-HUD-MicroMenu-', 'SpellbookAbilities')
	end

	if TalentMicroButton then
	    MB.SetButtonFromAtlas(TalentMicroButton, Atlas, microTexture, 'UI-HUD-MicroMenu-', 'SpecTalents')
	end

	if QuestLogMicroButton then
	    MB.SetButtonFromAtlas(QuestLogMicroButton, Atlas, microTexture, 'UI-HUD-MicroMenu-', 'Questlog')
	end

	if SocialsMicroButton then
        MB.SetButtonFromAtlas(SocialsMicroButton, Atlas, microTexture, 'UI-HUD-MicroMenu-', 'Socials')
	end

	if WorldMapMicroButton then
        local mapRef = "Interface\\AddOns\\RasPort\\Media\\Button\\worldmapbutton"
        MB.SetMapButton(WorldMapMicroButton, mapRef)
	end

	if MainMenuMicroButton then
       MB.ChangeMicroMenuButton()
        local a, b, c, d, e, f = buttons[7]:GetRegions();
		for _, v in pairs({a, b, c, d, e, f}) do
			if v then
				v:SetAlpha(0)
			end
		end
	end

	if HelpMicroButton then
         MB.SetButtonFromAtlas(buttons[8], Atlas, microTexture, 'UI-HUD-MicroMenu-', 'GameMenu')
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_LOGIN" then
		local barAnchor = CreateFrame("Frame", "MicroBarAnchor", UIParent, "BackdropTemplate")

		buttons[1]:ClearAllPoints()
		buttons[1]:SetPoint("LEFT", barAnchor, "LEFT", 0, 0)
		buttons[1]:SetSize(32, 40)

		local moving
		hooksecurefunc(CharacterMicroButton, "SetPoint", function(self)
			if moving or InCombatLockdown() then return end
			moving = true
			self:ClearAllPoints()
			self:SetPoint("LEFT", barAnchor, "LEFT", 0, 0)
            MainMenuMicroButton:SetAlpha(0)
			moving = nil
		end)

		local buttonBG = buttons[1]:CreateTexture(nil, "BACKGROUND")
		buttonBG:SetTexture("Interface\\AddOns\\RasPort\\Media\\Button\\circle")
		buttonBG:SetPoint("CENTER",  buttons[1], 0, 0)
		buttonBG:SetSize(40, 40)
		buttonBG:SetVertexColor(0, 0, 0, 0.5)

		local buttonBorder = buttons[1]:CreateTexture(nil, "BORDER")
		buttonBorder:SetTexture("Interface\\AddOns\\RasPort\\Media\\Button\\PORTRAIT-RING")
		buttonBorder:SetPoint("CENTER",  buttons[1], 0, 0)
		buttonBorder:SetSize(40, 40)
        local r, g, b = SetColorByProfile(buttonBorder)
		buttonBorder:SetVertexColor(r, g, b, 0.5)

		for i = 2, #buttons do
			buttons[i]:ClearAllPoints()
            buttons[i]:SetPoint("LEFT", buttons[i-1], "RIGHT", spacing, 0)
			buttons[i]:SetSize(32, 40)
			
			local buttonBG = buttons[i]:CreateTexture(nil, "BACKGROUND")
			buttonBG:SetTexture("Interface\\AddOns\\RasPort\\Media\\Button\\circle")
			buttonBG:SetPoint("CENTER",  buttons[i], 0, 0)
			buttonBG:SetSize(40, 40)
			buttonBG:SetVertexColor(0, 0, 0, 0.5)

			local buttonBorder = buttons[i]:CreateTexture(nil, "BORDER")
			buttonBorder:SetTexture("Interface\\AddOns\\RasPort\\Media\\Button\\PORTRAIT-RING")
			buttonBorder:SetPoint("CENTER",  buttons[i], 0, 0)
			buttonBorder:SetSize(40, 40)
            local r, g, b = SetColorByProfile(buttonBorder)
		    buttonBorder:SetVertexColor(r, g, b, 0.5)

        end

		barAnchor:SetSize(290, 30)
        local pos = RP.db.profile.micro.barAnchorPosition
        barAnchor:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
		barAnchor:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
		})
		barAnchor:SetBackdropColor(0, 0, 0, 0.5)
		barAnchor:SetBackdropBorderColor(0, 0, 0, 1)
		barAnchor:SetClampedToScreen(true)

        local barAnchorLock = MB:CreateTexture(nil, "OVERLAY")
        barAnchorLock:SetPoint("TOPLEFT", barAnchor, -3, 3)
        barAnchorLock:SetPoint("BOTTOMRIGHT", barAnchor, 3, -3)
        barAnchorLock:SetTexture("Interface\\Buttons\\WHITE8x8")
		barAnchorLock:SetVertexColor(0, 0.6, 0, 0.5)
        barAnchorLock:EnableMouse(false)
        barAnchorLock:SetAlpha(0)
        barAnchor:SetAlpha(0)

        local lockText = MB:CreateFontString(nil, "OVERLAY")
        lockText:SetFont(fontPath, 15, "OUTLINE")
        lockText:SetPoint("BOTTOM", barAnchor, "TOP", 0, 5)
        lockText:SetText("Microbar is unlocked")
        lockText:SetTextColor(0.6, 0, 0, 1)
        lockText:Hide()

        lockText.bg = MB:CreateTexture(nil, "BACKGROUND")
        lockText.bg:SetTexture("Interface\\Buttons\\WHITE8x8")
        lockText.bg:SetPoint("TOPLEFT", lockText, -3, 3)
        lockText.bg:SetPoint("BOTTOMRIGHT", lockText, 3, -3)
        lockText.bg:SetVertexColor(0, 0, 0, 0.5)
        lockText.bg:Hide()

        lockText.arrowLeft = MB:CreateTexture(nil, "ARTWORK")
        lockText.arrowLeft:SetTexture("Interface\\AddOns\\RasPort\\Media\\Button\\arrowLock")
        lockText.arrowLeft:SetSize(50,50)
        lockText.arrowLeft:SetPoint("RIGHT", barAnchorLock, "LEFT", -10, 0)
        lockText.arrowLeft:SetVertexColor(1, 0, 0, 0.5)
        lockText.arrowLeft:Hide()

        local arrowAnimGroupLeft = lockText.arrowLeft:CreateAnimationGroup()
        local animRightL = arrowAnimGroupLeft:CreateAnimation("Translation")
        animRightL:SetOffset(10, 0)  -- Move 10 pixels to the right; adjust as needed
        animRightL:SetDuration(0.5)  -- Duration of the movement; adjust as needed
        animRightL:SetOrder(1) 
        local animLeftL = arrowAnimGroupLeft:CreateAnimation("Translation")
        animLeftL:SetOffset(-10, 0)  -- Move back to the left; should match the right movement
        animLeftL:SetDuration(0.5)   -- Should match the duration of the right movement
        animLeftL:SetOrder(2)
        arrowAnimGroupLeft:SetLooping("REPEAT")

        lockText.arrowRight = MB:CreateTexture(nil, "ARTWORK")
        lockText.arrowRight:SetTexture("Interface\\AddOns\\RasPort\\Media\\Button\\arrowLock")
        lockText.arrowRight:SetSize(50, 50)
        lockText.arrowRight:SetPoint("LEFT", barAnchorLock, "RIGHT", 10, 0)
        lockText.arrowRight:SetVertexColor(1, 0, 0, 0.5)
        lockText.arrowRight:SetTexCoord(1, 0, 0, 1)
        lockText.arrowRight:Hide()

        local arrowAnimGroupRight = lockText.arrowRight:CreateAnimationGroup()
        local animRightR = arrowAnimGroupRight:CreateAnimation("Translation")
        animRightR:SetOffset(-10, 0)  -- Move 10 pixels to the right; adjust as needed
        animRightR:SetDuration(0.5)  -- Duration of the movement; adjust as needed
        animRightR:SetOrder(1) 
        local animLeftR = arrowAnimGroupRight:CreateAnimation("Translation")
        animLeftR:SetOffset(10, 0)  -- Move back to the left; should match the right movement
        animLeftR:SetDuration(0.5)   -- Should match the duration of the right movement
        animLeftR:SetOrder(2)
        arrowAnimGroupRight:SetLooping("REPEAT")


		barAnchor:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				self:StartMoving()
			end
		end)
		barAnchor:SetScript("OnMouseUp", function(self, button)
			self:StopMovingOrSizing()
            local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
            RP.db.profile.micro.barAnchorPosition.point = point--{point, relativePoint, xOfs, yOfs}
            RP.db.profile.micro.barAnchorPosition.relativePoint = relativePoint
            RP.db.profile.micro.barAnchorPosition.xOfs = xOfs
            RP.db.profile.micro.barAnchorPosition.yOfs = yOfs
		end)
		barAnchor:Show()

		UpdateMicroTexture()

        local function _UpdateLock()
            if RP.db.profile.micro["Lock"] then
				barAnchor:SetMovable(true)
		        barAnchor:EnableMouse(true)
				barAnchorLock:SetAlpha(0.5)
                lockText:Show()
                lockText.bg:Show()
                lockText.arrowRight:Show()
                lockText.arrowLeft:Show()
                arrowAnimGroupLeft:Play()
                arrowAnimGroupRight:Play()
			else
				barAnchor:SetMovable(false)
		        barAnchor:EnableMouse(false)
				barAnchorLock:SetAlpha(0)
                lockText:Hide()
                lockText.bg:Hide()
                lockText.arrowLeft:Hide()
                lockText.arrowRight:Hide()
                arrowAnimGroupLeft:Stop()
                arrowAnimGroupRight:Stop()
			end
        end

        _UpdateLock()

        local function _disabled()
            return not RP.db.profile.micro.enabled
        end

        local options = {
        type = "group",
        name = "Microbar",
        order = 4,
        get = function(i)
            return RP.db.profile.micro[i[#i]]
        end,
        set = function(i, val)
            RP.db.profile.micro[i[#i]] = val
        end,
        args = {
            enabled = {
                type = "toggle",
                name = L["Enable"],
                order = 1,
                desc = L["Allows you to change the settings, disable to lock settings"],
            },
            fontselect = {
                order = 3,
                type = "group",
                name = L["Toggles"],
                disabled = _disabled,
                inline = true,
                args = {
                    Font = {
                        order = 1,
                        type = "toggle",
                        name = "Unlock",
                        desc = "Allows microbar to be repositioned",
                        get = function()
                            return RP.db.profile.micro["Lock"]
                        end,
                        set = function(_, val)
                            RP.db.profile.micro["Lock"] = val
                            _UpdateLock()
                        end
                    }
                }
            }
        }
    }

    RP.options.args.Options.args.Micro = options
	end
end

MB:SetScript("OnEvent", OnEvent)

    
end)