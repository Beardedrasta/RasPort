local MAJOR, MINOR = "RPUI", 4
local RPUI, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not RPUI then
	return
end

RPUI.GameFontNormal = CreateFont("GameFontNormal-RasPort")
RPUI.GameFontNormal:CopyFontObject("GameFontNormal")
RPUI.GameFontHighlight = CreateFont("GameFontHighlight-RasPort")
RPUI.GameFontHighlight:CopyFontObject("GameFontHighlight")
RPUI.GameFontDisabled = CreateFont("GameFontDisable-RasPort")
RPUI.GameFontDisabled:CopyFontObject("GameFontDisable")
RPUI.GameFontNormalSmall = CreateFont("GameFontNormalSmall-RasPort")
RPUI.GameFontNormalSmall:CopyFontObject("GameFontNormalSmall")
RPUI.GameFontHighlightSmall = CreateFont("GameFontHighlightSmall-RasPort")
RPUI.GameFontHighlightSmall:CopyFontObject("GameFontHighlightSmall")

function RPUI.SetFontProperties(fontString, db)
	local LSM = LibStub("LibSharedMedia-3.0")
	if LSM then
		local font, size, flag, r, g, b, ofsX, ofsY = unpack(db)
		local fontPath = LSM:Fetch("font", font)
		if fontPath then -- fallbacks to default fonts
			fontString:SetShadowOffset(ofsX, ofsY)
			fontString:SetShadowColor(r, g, b, ofsX == 0 and ofsY == 0 and 0 or 1)
			-- DF, WOTLKC 30401, ClassicEra 11404
			flag = flag == "NONE"
			fontString:SetFont(fontPath, size, flag)
		end
	end
end

function RPUI.SetOptionFontDefaults(option, optionSmall)
	if RPUI.isFontSet then
		return
	end

	option = option or RPUI.defaultFonts.option
	optionSmall = optionSmall or RPUI.defaultFonts.optionSmall
	RPUI.SetFontProperties(RPUI.GameFontNormal, option)
	RPUI.SetFontProperties(RPUI.GameFontHighlight, option)
	RPUI.SetFontProperties(RPUI.GameFontDisabled, option)
	RPUI.SetFontProperties(RPUI.GameFontNormalSmall, optionSmall)
	RPUI.SetFontProperties(RPUI.GameFontHighlightSmall, optionSmall)

	-- Set tooltip font
	local AceConfigDialog = LibStub("AceConfigDialog-3.0-RasPort")
	if AceConfigDialog then
		for i = 1, 13 do
			if i > 3 then
				AceConfigDialog.tooltip:AddLine(" ")
			else
				AceConfigDialog.tooltip:AddDoubleLine(" ", " ")
			end
		end
		for i = 1, select("#", AceConfigDialog.tooltip:GetRegions()) do
			local region = select(i, AceConfigDialog.tooltip:GetRegions())
			if region and region:GetObjectType() == "FontString" then
				RPUI.SetFontProperties(region, option)
			end
		end
	end

	RPUI.isFontSet = true
end


RPUI.backdropStyle = {}

local textureUVs = {
	"TopLeftCorner",
	"TopRightCorner",
	"BottomLeftCorner",
	"BottomRightCorner",
	"TopEdge",
	"BottomEdge",
	"LeftEdge",
	"RightEdge",
	"Center"
}

function RPUI.GetPixelMult()
	local _, screenheight = GetPhysicalScreenSize()
	local uiUnitFactor = 768 / screenheight
	local uiScale = UIParent:GetScale()
	return uiUnitFactor / uiScale, uiUnitFactor
end

function RPUI.SetBackdrop(frame, style, bgFile, edgeFile, edgeSize, force)
	if not RPUI.pixelMult then
		RPUI.pixelMult = RPUI.GetPixelMult()
	end

	style = style or "default"

	local backdrop = RPUI.backdropStyle[style]
	if not backdrop or force then
		-- ACD is never called before opening the option panel. ACD:Open() will set ACDPixelMult value
		backdrop = {
			bgFile = bgFile or "Interface\\BUTTONS\\White8x8",
			edgeFile = edgeFile or "Interface\\AddOns\\RasPort\\Media\\Border\\border-modified.tga",
			edgeSize = (edgeSize or 14) * (style == "ACD" and RPUI.ACDPixelMult or RPUI.pixelMult),
            insets = {left = 1, right = 1, top = 1, bottom = 1}
		}
		RPUI.backdropStyle[style] = backdrop
	end
	frame:SetBackdrop(backdrop)

	for _, pieceName in ipairs(textureUVs) do
		local region = frame[pieceName]
		if region then
			region:SetTexelSnappingBias(0.0)
			region:SetSnapToPixelGrid(false)
		end
	end
end

RPUI.StaticPopupDialogs = {}

local function Button_OnLeave(self)
	self:SetBackdropBorderColor(0, 0, 0)
end

local function Button_OnEnter(self)
	local r, g, b = GetClassColor(select(2, UnitClass("player")))
	self:SetBackdropBorderColor(r, g, b)
end

function RPUI.GetStaticPopup()
	local frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	frame:Hide()
	frame:SetPoint("CENTER", UIParent, "CENTER")
	frame:SetSize(320, 72)
	frame:SetFrameStrata("TOOLTIP")
	frame:SetBackdrop({
        bgFile = "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Parchment-Horizontal",
        edgeFile = "Interface\\AddOns\\RasPort\\Media\\Border\\border-modified.tga",
        edgeSize = 10,
        insets = {
            left = 1,
            right = 1,
            top = 1,
            bottom = 1
        }
    })
	frame:SetBackdropColor(1, 1, 1, 1)
	frame:SetBackdropBorderColor(0.4, 0.4, 0.4)
	frame:SetScript("OnKeyDown", function(self, key)
		if key == "ESCAPE" then
			self:SetPropagateKeyboardInput(false)
			if self.cancel:IsShown() then
				self.cancel:Click()
			else
				self:Hide()
			end
		else
			self:SetPropagateKeyboardInput(true)
		end
	end)

	local text = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	text:SetSize(290, 0)
	text:SetPoint("TOP", 0, -16)
	frame.text = text

	local function newButton(name)
		local button = CreateFrame("Button", nil, frame, BackdropTemplateMixin and "RPButtonTemplate, BackdropTemplate" or nil)
		button:SetSize(128, 21)
--[[ 		RPUI.SetBackdrop(button)
		button:SetBackdropColor(0.2, 0.2, 0.2, 1)
		button:SetBackdropBorderColor(0, 0, 0, 1) ]]
		button:SetScript("OnEnter", Button_OnEnter)
		button:SetScript("OnLeave", Button_OnLeave)
		button:SetNormalFontObject("GameFontNormal")
		button:SetHighlightFontObject("GameFontHighlight")
		button:SetText(name)
		return button
	end

	local accept = newButton(ACCEPT)
	accept:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -6, 16)
	frame.accept = accept

	local cancel = newButton(CANCEL)
	cancel:SetPoint("LEFT", accept, "RIGHT", 13, 0)
	frame.cancel = cancel

	local alt = newButton(OKAY)
	alt:SetWidth(86)
	alt:SetPoint("BOTTOM", frame, "BOTTOM", 0, 16)
	frame.alt = alt

	return frame
end

local function StaticPopup_OnShow(self)
	local info = self.info
	local OnShow = info.OnShow
	if OnShow then
		OnShow(self, self.data, self.data2)
	end
end

local function StaticPopup_OnHide(self)
	local info = self.info
	local OnHide = info.OnHide
	if OnHide then
		OnHide(self, self.data, self.data2)
	end
end

local function StaticPopup_OnAccept(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	local frame = self:GetParent()
	local info = frame.info
	local OnAccept = info.OnAccept
	local keepVisible
	if OnAccept then
		keepVisible = OnAccept(self, frame.data, frame.data2)
	end
	if not keepVisible then
		frame:Hide()
		self:SetScript("OnClick", nil)
		frame.cancel:SetScript("OnClick", nil)
		frame.alt:SetScript("OnClick", nil)
	end
end

local function StaticPopup_OnCancel(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	local frame = self:GetParent()
	local info = frame.info
	local OnCancel = info.OnCancel
	if OnCancel then
		OnCancel(self, frame.data, frame.data2)
	end
	frame:Hide()
	self:SetScript("OnClick", nil)
	frame.accept:SetScript("OnClick", nil)
	frame.alt:SetScript("OnClick", nil)
end

local function StaticPopup_OnAlt(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	local frame = self:GetParent()
	local info = frame.info
	local OnAlt = info.OnAlt
	if OnAlt then
		OnAlt(self, frame.data, frame.data2)
	end
	frame:Hide()
	self:SetScript("OnClick", nil)
	frame.accept:SetScript("OnClick", nil)
	frame.cancel:SetScript("OnClick", nil)
end

function RPUI.StaticPopup_Show(which, text_arg1, text_arg2, data, data2)
	local frame = RPUI.popup
	if not frame then
		frame = RPUI.GetStaticPopup()
		RPUI.popup = frame
	end

	local info = RPUI.StaticPopupDialogs[which]
	local message = format(info.text, text_arg1 or "", text_arg2 or "")
	frame.text:SetText(message)
	local height = 61 + frame.text:GetHeight()
	frame:SetHeight(height)

	if info.button3 then
		frame.accept:SetWidth(86)
		frame.cancel:SetWidth(86)
		frame.accept:ClearAllPoints()
		frame.cancel:ClearAllPoints()
		frame.accept:SetPoint("RIGHT", frame.alt, "LEFT", -6, 0)
		frame.cancel:SetPoint("LEFT", frame.alt, "RIGHT", 6, 0)
		frame.alt:Show()
	else
		frame.accept:SetWidth(128)
		frame.cancel:SetWidth(128)
		frame.accept:ClearAllPoints()
		frame.cancel:ClearAllPoints()
		frame.accept:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -6, 16)
		frame.cancel:SetPoint("LEFT", frame.accept, "RIGHT", 13, 0)
		frame.alt:Hide()
	end

	frame.info = info
	frame.data = data
	frame.data2 = data2

	frame.accept:SetText(info.button1 or ACCEPT)
	frame.cancel:SetText(info.button2 or CANCEL)
	frame.alt:SetText(info.button3 or OKAY)
	frame:SetScript("OnShow", StaticPopup_OnShow)
	frame:SetScript("OnHide", StaticPopup_OnHide)
	frame.accept:SetScript("OnClick", StaticPopup_OnAccept)
	frame.cancel:SetScript("OnClick", StaticPopup_OnCancel)
	frame.alt:SetScript("OnClick", StaticPopup_OnAlt)

	frame:Show()
end

function RPUI.GetStaticPopupDialog(key)
	return RPUI.StaticPopupDialogs[key]
end

local function FlashButton_OnLeave(self)
	local fadeIn = self.fadeIn
	if fadeIn:IsPlaying() then
		fadeIn:Stop()
	end
	self.fadeOut:Play()
end

local function FlashButton_OnEnter(self)
	PlaySound(1217)
	local fadeOut = self.fadeOut
	if fadeOut:IsPlaying() then
		fadeOut:Stop()
	end
	self.fadeIn:Play()
end

function RPUI.CreateFlashButton(parent, text, width, height, style)
	local Button = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "RPButtonTemplate, BackdropTemplate" or nil)
	Button:SetSize(width or 80, height or 20)
	--RPUI.SetBackdrop(Button, style)
	--Button:SetBackdropColor(1, 0.81960791349411, 0)
	Button:SetBackdropBorderColor(0, 0, 0)
	Button:SetScript("OnEnter", FlashButton_OnEnter)
	Button:SetScript("OnLeave", FlashButton_OnLeave)
	Button:SetNormalFontObject("GameFontHighlight")
	Button:SetHighlightFontObject("GameFontHighlight")
	Button:SetHighlightTexture(0)
	Button:SetText(text or "")

	Button.bg = Button:CreateTexture(nil, "OVERLAY")
	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
		Button.bg:SetAllPoints()
	else
		Button.bg:SetTexelSnappingBias(0.0)
		Button.bg:SetSnapToPixelGrid(false)
		Button.bg:SetPoint("TOPLEFT", Button, "BOTTOMLEFT")
		Button.bg:SetPoint("BOTTOMRIGHT", Button, "TOPRIGHT")
	end
	Button.bg:SetTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-highlight-gold")
	Button.bg:Hide()

	Button.fadeIn = Button.bg:CreateAnimationGroup()
	Button.fadeIn:SetScript("OnPlay", function() Button.bg:Show() end)
	local fadeIn = Button.fadeIn:CreateAnimation("Alpha")
	fadeIn:SetFromAlpha(0)
	fadeIn:SetToAlpha(1)
	fadeIn:SetDuration(0.4)
	fadeIn:SetSmoothing("OUT")

	Button.fadeOut = Button.bg:CreateAnimationGroup()
	Button.fadeOut:SetScript("OnFinished", function() Button.bg:Hide() end)
	local fadeOut = Button.fadeOut:CreateAnimation("Alpha")
	fadeOut:SetFromAlpha(1)
	fadeOut:SetToAlpha(0)
	fadeOut:SetDuration(0.3)
	fadeOut:SetSmoothing("OUT")

	return Button
end