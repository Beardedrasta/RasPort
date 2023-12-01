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
RP:AddModule("Money", "Simple Money / Emblem tracker", function()
    if RP:IsDisabled("Money") then
        return
    end

    -- API
    local _G = getfenv(0)
    local CreateFrame = _G.CreateFrame
    local GetCurrencyListSize = _G.GetCurrencyListSize
    local CurreencyInfo = _G.C_CurrencyInfo
    local GetCurrencyListInfo = _G.GetCurrencyListInfo
    local insert = _G.table.insert
    local floor, pairs, time, GetMoney = _G.math.floor, _G.pairs, _G.time, _G.GetMoney
    local GameTooltip = _G.GameTooltip
    local MoneyAddonInitialMoney, MoneyAddonStartTime
    local L = U.L

    -- Config
    local tab = {}
    local DB = RP.db.profile
    local fontPath = U.LSM:Fetch("font", RP.db.profile.money["Font"])

    local RasMoney = RP.Money or CreateFrame("Frame", "RasPortGoldAddonFrame", UIParent, "BackdropTemplate")
    RasMoney:SetWidth(170)
    RasMoney:SetHeight(35)
    RasMoney:SetPoint("BOTTOMLEFT", UIParent, 3, -2)

    RasMoney.moneyText = RasMoney:CreateFontString(nil, "OVERLAY")
    RasMoney.moneyText:SetPoint("LEFT", 15, 0)
    RasMoney.moneyText:SetFont(fontPath, 12, "OUTLINE")
    RasMoney.moneyText:SetTextColor(1, 0.81960791349411, 0, 1)

    RasMoney.tokenText = RasMoney:CreateFontString(nil, "OVERLAY")
    RasMoney.tokenText:SetPoint("RIGHT", RasMoney.moneyText, 105, 0)
    RasMoney.tokenText:SetFont(fontPath, 12, "OUTLINE")
    RasMoney.tokenText:SetTextColor(1, 0.81960791349411, 0, 1)

    local function UpdateMoneyFont()
        RasMoney.moneyText:SetFont(U.LSM:Fetch("font", RP.db.profile.money["Font"]), 12, "OUTLINE")
        RasMoney.tokenText:SetFont(U.LSM:Fetch("font", RP.db.profile.money["Font"]), 12, "OUTLINE")
        RasMoney:GetTokenList()
        local tokenList = tab
        local tokenString = ""
        for i, token in pairs(tokenList) do
            if tokenString ~= "" then
                tokenString = tokenString .. " "
            end
            tokenString = tokenString .. token.count .. "|T" .. token.icon .. ":0:0:0:0:64:64:2:38:2:38|t"
        end
        local moneyTextWidth = RasMoney.moneyText:GetStringWidth()
        local tokenTextWidth = RasMoney.tokenText:GetStringWidth()
        local totalWidth = moneyTextWidth + (tokenString ~= "" and tokenTextWidth + 10 or 0)
        RasMoney:SetWidth(totalWidth + 60)
    end


    function RasMoney:GetTokenList()
        tab = {}
        local max = 1

        if GetCurrencyListSize then
            max = GetCurrencyListSize()
        elseif CurreencyInfo.GetCurrencyListSize then
            max = CurreencyInfo.GetCurrencyListSize()
        end

        for index = 1, max do
            local name, _, _, _, isWatched, count, icon, _, _, _ = nil

            if GetCurrencyListInfo then
                name, _, _, _, isWatched, count, icon, _, _, _ = GetCurrencyListInfo(index)
            elseif CurreencyInfo.GetCurrencyListInfo then
                local info = CurreencyInfo.GetCurrencyListInfo(index)
                name = info.name
                isWatched = info.isShowInBackpack
                icon = info.iconFileID
                count = info.quantity
            end

            if name then
                if isWatched then
                    insert(tab, {
                        ["name"] = name,
                        ["count"] = count,
                        ["icon"] = icon
                    })
                    RasMoney:SetWidth(350)
                end
            else
                break
            end
        end

        if RasMoney and RasMoney.text then
            local text = ""

            for i, token in pairs(tab) do
                if text ~= "" then
                    text = text .. " "
                end

                text = text .. token.count .. "|T" .. token.icon .. ":0:0:0:0:64:64:2:38:2:38|t"
            end

            RasMoney.text:SetText(text)
        end
    end

    local function FormatGoldSilverCopper(copperAmount)
        local gold = floor(copperAmount / 10000)
        local leftover = copperAmount % 10000
        local silver = floor(leftover / 100)
        local copper = leftover % 100

        local goldIcon = "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"
        local silverIcon = "|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t"
        local copperIcon = "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"

        local result = ""
        if gold > 0 then
            result = result .. gold .. goldIcon .. " "
        end
        if silver > 0 or gold > 0 then
            result = result .. silver .. silverIcon .. " "
        end
        result = result .. copper .. copperIcon

        return result
    end

    local function UpdateMoney()
        local money = GetMoney()
        local goldString = FormatGoldSilverCopper(money) -- Changed to your custom function
        RasMoney.moneyText:SetText("Money: " .. goldString)

        RasMoney:GetTokenList()
        local tokenList = tab
        local tokenString = ""
        for i, token in pairs(tokenList) do
            if tokenString ~= "" then
                tokenString = tokenString .. " "
            end
            tokenString = tokenString .. token.count .. "|T" .. token.icon .. ":0:0:0:0:64:64:2:38:2:38|t"
        end
        RasMoney.tokenText:SetText(tokenString)

        local moneyTextWidth = RasMoney.moneyText:GetStringWidth()
        local tokenTextWidth = RasMoney.tokenText:GetStringWidth()
        local totalWidth = moneyTextWidth + (tokenString ~= "" and tokenTextWidth + 10 or 0)
        RasMoney:SetWidth(totalWidth + 55)
        if not MoneyAddonInitialMoney then
            MoneyAddonInitialMoney = money
        end
    end

    local function CalculateGoldDifference()
        local currentMoney = GetMoney()
        local initialMoney = MoneyAddonInitialMoney or currentMoney
        local goldDifference = currentMoney - initialMoney
        return goldDifference
    end

    local function OnFrameEnter(self)
        local goldDifference = CalculateGoldDifference()
        GameTooltip:SetOwner(self, "ANCHOR_TOP")

        if goldDifference >= 0 then
            GameTooltip:AddLine("Gold Earned Since Login: " .. FormatGoldSilverCopper(goldDifference))
        else
            GameTooltip:AddLine("Gold Spent Since Login: " .. FormatGoldSilverCopper(-goldDifference))
        end

        GameTooltip:Show()
    end

    local function OnFrameLeave()
        GameTooltip:Hide()
    end

    RasMoney:RegisterEvent("PLAYER_LOGIN")
    RasMoney:RegisterEvent("PLAYER_MONEY")
    RasMoney:SetScript("OnEvent", UpdateMoney)
    RasMoney:SetScript("OnEnter", OnFrameEnter)
    RasMoney:SetScript("OnLeave", OnFrameLeave)

    RasMoney:RegisterEvent("PLAYER_ENTERING_WORLD")

    RasMoney:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            MoneyAddonStartTime = time()
            if not MoneyAddonInitialMoney then
                MoneyAddonInitialMoney = GetMoney()
            end
            self:UnregisterEvent(event)
        elseif event == "PLAYER_MONEY" then
            UpdateMoney()
        end
    end)

    local LSM_Font = {}
    local function _disabled()
        return not RP.db.profile.money.enabled
    end

    TokenFramePopupBackpackCheckBox:HookScript("OnClick", UpdateMoney)

    local options = {
        type = "group",
        name = L["Currency"],
        order = 4,
        get = function(i)
            return RP.db.profile.money[i[#i]]
        end,
        set = function(i, val)
            RP.db.profile.money[i[#i]] = val
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
                name = L["Tracker Font"],
                disabled = _disabled,
                inline = true,
                args = {
                    Font = {
                        order = 1,
                        type = "select",
                        name = L["Font"],
                        desc = "Choose a font",
                        values = LSM_Font,
                        get = function()
                            return RP.db.profile.money["Font"]
                        end,
                        set = function(_, val)
                            RP.db.profile.money["Font"] = val
                            UpdateMoneyFont()
                        end
                    }
                }
            }
        }
    }

    RP:RegisterForEvent("PLAYER_LOGIN", function()
        for fontName, fontPath in pairs(RP.UI.LSM:HashTable("font")) do
            LSM_Font[fontName] = fontName
        end
        RP.options.args.Options.args.Money = options
        UpdateMoneyFont()
        UpdateMoney()
    end)

end)
