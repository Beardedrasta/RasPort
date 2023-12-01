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
RP:AddModule("Copy Pasta", "Adds a Copy and Paste to Color picker", function()
    if RP:IsDisabled("Copy Pasta") then return end

    -- API
    local _G = getfenv(0)
    local CreateFrame = _G.CreateFrame
    local format = _G.string.format

    local CP = RP.CP or {}
    RP.CP = CP

    --[[
    ################################################################
    #################           Alpha              #################
    ################################################################
    ]]--

    function CP:UpdateAlpha(obj)
		if not obj:GetText() or obj:GetText() == "" then
			return
		end

		local r, g, b = ColorPickerFrame:GetColorRGB()
		local a = OpacitySliderFrame:GetValue()

		local id = obj:GetID()

		if id == 1 then
			r = format("%.2f", obj:GetNumber())
			r = r or 0
		elseif id == 2 then
			g = format("%.2f", obj:GetNumber())
			g = g or 0
		elseif id == 3 then
			b = format("%.2f", obj:GetNumber())
			b = b or 0
		else
			a = format("%.2f", obj:GetNumber())
			a = a or 0
		end

		if id ~= 4 then
			ColorPickerFrame:SetColorRGB(r, g, b)
			ColorSwatch:SetTexture(r, g, b)
		else
			OpacitySliderFrame:SetValue(a)
		end
	end

    --[[
    ################################################################
    #################           Editbox            #################
    ################################################################
    ]]--

    function CP:UpdateEditBox(r, g, b, a)
		if CP.editBoxFocus then
			return
		end

		if not r then
			r, g, b = ColorPickerFrame:GetColorRGB()
		end
		if not a then
			a = OpacitySliderFrame:GetValue()
		end

		_G.CPRedBoxText:SetText(format("%.2f", r))
		_G.CPGreenBoxText:SetText(format("%.2f", g))
		_G.CPBlueBoxText:SetText(format("%.2f", b))
		_G.CPAlphaBoxText:SetText(format("%.2f", a))

		_G.CPRedBox:SetText("")
		_G.CPGreenBox:SetText("")
		_G.CPBlueBox:SetText("")
		_G.CPAlphaBox:SetText("")
	end

    local function CP_OnShow(self)
		if self.hasOpacity then
			_G.CPAlphaBox:Show()
			_G.CPAlphaBoxLabel:Show()
			_G.CPAlphaBoxText:Show()
		else
			_G.CPAlphaBox:Hide()
			_G.CPAlphaBoxLabel:Hide()
			_G.CPAlphaBoxText:Hide()
		end
	end

    local function CP_OnColorSelect(self, ...)
		local arg1, arg2, arg3 = ...
		CP:UpdateEditBox(arg1, arg2, arg3, self.opacity)
	end

	local function CP_OpacityOnValueChanged(self, ...)
		CP:UpdateEditBox(nil, nil, nil, self.opacity)
	end

    --[[
    ################################################################
    #################           Initialize         #################
    ################################################################
    ]]--

    RP:RegisterForEvent("PLAYER_LOGIN", function()
		ColorPickerFrame:HookScript("OnShow", CP_OnShow)
		ColorPickerFrame:HookScript("OnColorSelect", CP_OnColorSelect)
		OpacitySliderFrame:HookScript("OnValueChanged", CP_OpacityOnValueChanged)

		-- Add Buttons and EditBoxes to the original ColorPicker Frame
		local copyButton = CreateFrame("Button", "CPCopy", ColorPickerFrame, "RPButtonTemplate")
		copyButton:SetText("Copy")
		copyButton:SetWidth(75)
		copyButton:SetHeight(22)
		copyButton:SetPoint("BOTTOMLEFT", "ColorPickerFrame", "TOPLEFT", 10, -32)
		copyButton:SetScript("OnClick", function(self)
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = ColorPickerFrame.hasOpacity and OpacitySliderFrame:GetValue() or 1
			local CurrentlyCopiedColor = _G.CurrentlyCopiedColor or {}
			_G.CurrentlyCopiedColor = CurrentlyCopiedColor

			CurrentlyCopiedColor.r = r
			CurrentlyCopiedColor.g = g
			CurrentlyCopiedColor.b = b
			CurrentlyCopiedColor.a = a
		end)

		local pasteButton = CreateFrame("Button", "ECPPaste", ColorPickerFrame, "RPButtonTemplate")
		pasteButton:SetText("Paste")
		pasteButton:SetWidth(75)
		pasteButton:SetHeight(22)
		pasteButton:SetPoint("BOTTOMRIGHT", "ColorPickerFrame", "TOPRIGHT", -10, -32)
		pasteButton:SetScript("OnClick", function(self)
			local CurrentlyCopiedColor = _G.CurrentlyCopiedColor
			if CurrentlyCopiedColor then
				ColorPickerFrame:SetColorRGB(
					CurrentlyCopiedColor.r,
					CurrentlyCopiedColor.g,
					CurrentlyCopiedColor.b
				)
				if ColorPickerFrame.hasOpacity then
					OpacitySliderFrame:SetValue(CurrentlyCopiedColor.a)
				end
				ColorSwatch:SetTexture(
					CurrentlyCopiedColor.r,
					CurrentlyCopiedColor.g,
					CurrentlyCopiedColor.b
				)
			end
		end)

        -- move the Color Picker Wheel
		ColorPickerWheel:ClearAllPoints()
		ColorPickerWheel:SetPoint("TOPLEFT", 16, -34)

		-- move the Opacity Slider Frame
		OpacitySliderFrame:ClearAllPoints()
		OpacitySliderFrame:SetPoint("TOPLEFT", "ColorSwatch", "TOPRIGHT", 52, -4)

        local editBoxes = {"Red", "Green", "Blue", "Alpha"}
		for i = 1, table.getn(editBoxes) do
			local ebn = editBoxes[i]
			local obj = CreateFrame("EditBox", "CP" .. ebn .. "Box", ColorPickerFrame, "InputBoxTemplate")
			obj:SetFrameStrata("DIALOG")
			obj:SetMaxLetters(4)
			obj:SetAutoFocus(false)
			obj:SetWidth(35)
			obj:SetHeight(25)
			obj:SetID(i)
			if i == 1 then
				obj:SetPoint("TOPLEFT", 265, -68)
			else
				obj:SetPoint("TOP", "CP" .. editBoxes[i - 1] .. "Box", "BOTTOM", 0, 3)
			end

			obj:SetScript("OnEscapePressed", function(self)
				self:ClearFocus()
				CP:UpdateEditBox()
			end)
			obj:SetScript("OnEnterPressed", function(self)
				self:ClearFocus()
				CP:UpdateEditBox()
			end)
			obj:SetScript("OnTextChanged", function(self) CP:UpdateAlpha(self) end)
			obj:SetScript("OnEditFocusGained", function() CP.editBoxFocus = true end)
			obj:SetScript("OnEditFocusLost", function() CP.editBoxFocus = nil end)

			local objl = obj:CreateFontString("CP" .. ebn .. "BoxLabel", "ARTWORK", "GameFontNormal")
			objl:SetPoint("RIGHT", "CP" .. ebn .. "Box", "LEFT", -38, 0)
			objl:SetText(string.sub(ebn, 1, 1) .. ":")
			objl:SetTextColor(1, 1, 1)

			local objt = obj:CreateFontString("CP" .. ebn .. "BoxText", "ARTWORK", "GameFontNormal")
			objt:SetPoint("LEFT", "CP" .. ebn .. "Box", "LEFT", -38, 0)
			objt:SetTextColor(1, 1, 1)
			obj:Show()
		end

        -- define the Tab Pressed Scripts
		_G.CPRedBox:SetScript("OnTabPressed", function(self) _G.CPGreenBox:SetFocus() end)
		_G.CPGreenBox:SetScript("OnTabPressed", function(self) _G.CPBlueBox:SetFocus() end)
		_G.CPBlueBox:SetScript("OnTabPressed", function(self) _G.CPAlphaBox:SetFocus() end)
		_G.CPAlphaBox:SetScript("OnTabPressed", function(self) _G.CPRedBox:SetFocus() end)
	end)

end)