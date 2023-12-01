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
RP:AddModule("Auto", "Automates a few tedious tasks making wow that much more enjoyable!", function()
    if RP:IsDisabled("Auto") then
        return
    end

    local L = U.L

    -- API
    local _G = getfenv(0)
    local CreateFrame = _G.CreateFrame
    local pairs = _G.pairs
    local rep = _G.rep
    local tostring = _G.tostring
    local type = _G.type
    local select = _G.select
    local format = _G.string.format
    local C_Container, ItemLocation, C_Item, GetItemInfo = _G.C_Container, _G.ItemLocation, _G.C_Item, _G.GetItemInfo
    local CanMerchantRepair, GetRepairAllCost, GetGuildBankWithdrawMoney, GetMoneyString = _G.CanMerchantRepair,
        _G.GetRepairAllCost, _G.GetGuildBankWithdrawMoney, _G.GetMoneyString
    local CanGuildBankRepair = _G.CanGuildBankRepair
    local hooksecurefunc = _G.hooksecurefunc

    local AU = RP.Auto or CreateFrame("Frame", nil, UIParent)

    --[[
    ################################################################
    #################           Ignore Duels       #################
    ################################################################
    ]] --

    RP:RegisterForEvent("DUEL_REQUESTED", function()
        if RP.db.auto["Decline Duels"] then
            CancelDuel()
            StaticPopup_Hide("DUEL_REQUESTED")
        end
    end)

    --[[
    ################################################################
    #################           Sell / Repair      #################
    ################################################################
    ]] --

    local function PrintTable(t, indent)
        indent = indent or 0
        for key, value in pairs(t) do
            RP:Print(rep(" ", indent) .. tostring(key) .. ": " .. tostring(value))
            if type(value) == "table" then
                PrintTable(value, indent + 2)
            end
        end
    end

    local function itemQualityToString(quality)
        local qualities = {"Grey", "White", "Green", "Blue"}
        return qualities[quality + 1] or "Unknown"
    end

    local function GetExcludedItemIDs()
        local excludedItems = RP.db.profile.auto.excludedItems or {}
        local excludedItemIDs = {}
        for _, item in ipairs(excludedItems) do
            local itemID = tonumber(item) or select(2, GetItemInfo(item))
            if itemID then
                excludedItemIDs[itemID] = true
            end
        end
        return excludedItemIDs
    end

    local function AutoSellJunk()
        if RP.db.profile.auto["Sell Junk"] then
            local i = 0
            local totalSaleValue = 0
            local excludedItemIDs = GetExcludedItemIDs()

            for bag = 0, 4 do
                for slot = 0, C_Container.GetContainerNumSlots(bag) do
                    local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
                    if C_Item.DoesItemExist(itemLocation) then
                        local itemID = C_Item.GetItemID(itemLocation)
                        local _, _, _, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(itemID)
                        local stackCount = C_Item.GetStackCount(itemLocation)
                        local itemQuality = select(3, GetItemInfo(itemID))

                        local questInfoTable = C_Container.GetContainerItemQuestInfo(bag, slot)
                        local isQuestItem = questInfoTable.isQuestItem

                        local shouldSell = false
                        if not isQuestItem and not excludedItemIDs[itemID] then
                            if itemQuality == 0 and RP.db.profile.auto["Grey Items"] then
                                shouldSell = true
                            elseif itemQuality == 1 and RP.db.profile.auto["White Items"] then
                                shouldSell = true
                            elseif itemQuality == 2 and RP.db.profile.auto["Green Items"] then
                                shouldSell = true
                            elseif itemQuality == 3 and RP.db.profile.auto["Blue Items"] then
                                shouldSell = true
                            end
                            if shouldSell and itemSellPrice > 0 then
                                local saleValue = itemSellPrice * stackCount
                                totalSaleValue = totalSaleValue + saleValue

                                C_Container.UseContainerItem(bag, slot)
                                i = i + 1
                            end
                        end
                    end
                end
            end
            if i > 0 then
                RP:Print(format("You have successfully sold %d items for a total of %s.", i,
                    GetMoneyString(totalSaleValue)))
            end
        end
    end

    local function AutoRepair()
        local canRepair, _ = CanMerchantRepair()
        if RP.db.profile.auto["Repair Equipment"] and canRepair then
            local cost, needed = GetRepairAllCost()
            if needed then
                local guildWithdraw = GetGuildBankWithdrawMoney()
                local useGuild = CanGuildBankRepair() and (guildWithdraw > cost or guildWithdraw == -1)
                if useGuild then
                    RepairAllItems(1)
                    RP:Print(format("Repair cost covered by Guild Bank: %s.", GetMoneyString(cost)))
                elseif cost < GetMoney() then
                    RepairAllItems()
                    RP:Print(format("Your items have been repaired for %s.", GetMoneyString(cost)))
                else
                    RP:Print("You don't have enough money to repair items!")
                end
            end
        end
    end

    RP:RegisterForEvent("MERCHANT_SHOW", function()
        RP:Print("Merchant Active")
        AutoRepair()
        AutoSellJunk()
    end)

    local Old_MerchantItemButton_OnModifiedClick = _G.MerchantItemButton_OnModifiedClick
    _G.MerchantItemButton_OnModifiedClick = function(self, ...)
        if IsAltKeyDown() then
            local maxStack = select(8, GetItemInfo(GetMerchantItemLink(this:GetID())))
            local _, _, _, quantity, _, _, _ = GetMerchantItemInfo(this:GetID())
            if maxStack and maxStack > 1 then
                BuyMerchantItem(this:GetID(), floor(maxStack / quantity))
            end
        end
        Old_MerchantItemButton_OnModifiedClick(self, ...)
    end

    local function Auto_D()
        if RP.db.profile.auto["Insert Delete"] then
          hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(self)
            self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
          end)
        else
            hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(self)
                self.editBox:SetText("")
            end)
        end
      end

    --[[
    ################################################################
    #################           Train All          #################
    ################################################################
    ]] --

    local button, locked
    local skillsToLearn, skillsLearned
    local process

    local function AutoTrainReset()
        button:SetScript("OnUpdate", nil)
        locked = nil
        skillsLearned = nil
        skillsToLearn = nil
        process = nil
        button.delay = nil
    end

    local function AutoTrainAll_OnUpdate(self, elapsed)
        self.delay = self.delay - elapsed
        if self.delay <= 0 then
            AutoTrainReset()
        end
    end

    local function AutoTrainAll()
        locked = true
        button:Disable()

        local j, cost = 0, 0
        local money = GetMoney()

        for i = 1, GetNumTrainerServices() do
            if select(3, GetTrainerServiceInfo(i)) == "available" then
                j = j + 1
                cost = GetTrainerServiceCost(i)
                if money >= cost then
                    money = money - cost
                    BuyTrainerService(i)
                else
                    AutoTrainReset()
                    return
                end
            end
        end

        if j > 0 then
            skillsToLearn = j
            skillsLearned = 0

            process = true
            button.delay = 1
            button:SetScript("OnUpdate", AutoTrainAll_OnUpdate)
        else
            AutoTrainReset()
        end
    end

    RP:RegisterForEvent("TRAINER_UPDATE", function()
        if not process then
            return
        end

        skillsLearned = skillsLearned + 1

        if skillsLearned >= skillsToLearn then
            AutoTrainReset()
            AutoTrainAll()
        else
            button.delay = 1
        end
    end)

    function AU:TrainButtonCreate()
        if button then
            return
        end
        local r, g, b, a = RP.Color.GOLD_COLOR:GetRGBA()
        button = CreateFrame("Button", "RasPortTrainAllButton", ClassTrainerFrame, "BackdropTemplate")
        button.text = button:CreateFontString(nil, "OVERLAY")
        button.text:SetFont("Fonts\\frizqt__.TTF", 12, "OUTLINE")
        button.text:SetFormattedText("%s %s", TRAIN, ALL)
        button.text:SetTextColor(r, g, b, a)
        button.text:SetPoint("CENTER", button, 0, 0)
        button:SetSize(80, 18)
        button:SetPoint("RIGHT", ClassTrainerFrameCloseButton, "LEFT", 1, 0)
        button:SetScript("OnClick", function()
            AutoTrainAll()
        end)

        button:SetNormalTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-norm.tga")
        button:SetPushedTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-norm.tga")
        button:SetHighlightTexture("Interface\\AddOns\\RasPort\\Media\\Button\\button-pressed.tga")
    end

    function AU:TrainButtonUpdate()
        if locked then
            return
        end

        for i = 1, GetNumTrainerServices() do
            if select(3, GetTrainerServiceInfo(i)) == "available" then
                button:Enable()
                return
            end
        end

        button:Disable()
    end

    RP:RegisterForEvent("ADDON_LOADED", function(_, name)
        if name == "Blizzard_TrainerUI" then
            AU:TrainButtonCreate()
            hooksecurefunc("ClassTrainerFrame_Update", AU.TrainButtonUpdate)
        end
    end)

    local function GetExcludedItemIDs()
        local excludedItems = RP.db.profile.auto.excludedItems or {}
        return table.concat(excludedItems, "\n")
    end

    local function GetExcludedItemNames()
        local excludedItems = RP.db.profile.auto.excludedItems or {}
        local itemNames = {}
        for _, itemID in ipairs(excludedItems) do
            local itemName = GetItemInfo(itemID) or "Unknown Item"
            table.insert(itemNames, itemName)
        end
        return table.concat(itemNames, "\n")
    end

    local function GetFormattedExcludedList()
        local excludedItems = RP.db.profile.auto.excludedItems or {}
        local formattedList = {}
        for _, item in ipairs(excludedItems) do
            local itemName, _, _, _, _, _, _, _, _, _, _ = GetItemInfo(item)
            if not itemName then
                itemName = GetItemInfoInstant(item)
            end
            if itemName then
                table.insert(formattedList, itemName .. " (" .. item .. ")")
            else
                table.insert(formattedList, "Item ID: " .. item)
            end
        end
        return table.concat(formattedList, "\n")
    end

    local function _disabled()
        return not RP.db.profile.auto.enabled
    end

    local options = {
        type = "group",
        name = L["Auto"],
        childGroups = "tab",
        order = 5,
        get = function(i)
            return RP.db.profile.auto[i[#i]]
        end,
        set = function(i, val)
            RP.db.profile.auto[i[#i]] = val
        end,
        args = {
            enabled = {
                type = "toggle",
                name = "Enable",
                order = 0,
                desc = "Allows you to change the settings, disable to lock settings."
            },
            toggles = {
                order = 1,
                type = "group",
                name = "Toggles",
                disabled = _disabled,
                inline = true,
                args = {
                    duels = {
                        order = 0,
                        type = "toggle",
                        name = "Decline Duels",
                        desc = 'Automatically decline duel requests',
                        get = function()
                            return RP.db.profile.auto["Decline Duels"]
                        end,
                        set = function(_, value)
                            RP.db.profile.auto["Decline Duels"] = value
                        end
                    },
                    repair = {
                        order = 1,
                        type = "toggle",
                        name = "Repair",
                        desc = 'Automatically repair equipment',
                        get = function()
                            return RP.db.profile.auto["Repair Equipment"]
                        end,
                        set = function(_, value)
                            RP.db.profile.auto["Repair Equipment"] = value
                        end
                    },
                    del = {
                        order = 2,
                        type = "toggle",
                        name = "Insert Delete",
                        desc = 'Automatically insert the *DELETE* text when attempting to delete higher quality items',
                        get = function()
                            return RP.db.profile.auto["Insert Delete"]
                        end,
                        set = function(_, value)
                            RP.db.profile.auto["Insert Delete"] = value
                            Auto_D()
                        end
                    },
                    junk = {
                        order = 3,
                        type = "toggle",
                        name = "Sell Junk",
                        desc = 'Automatically sell junk items',
                        get = function()
                            return RP.db.profile.auto["Sell Junk"]
                        end,
                        set = function(_, value)
                            RP.db.profile.auto["Sell Junk"] = value
                        end
                    }
                }
            },
            category = {
                order = 2,
                type = "group",
                name = "Junk Category",
                disabled = _disabled,
                inline = true,
                hidden = function()
                    return not RP.db.profile.auto["Sell Junk"]
                end,
                args = {
                    grey = {
                        order = 0,
                        type = "toggle",
                        name = "Grey Items",
                        get = function()
                            return RP.db.profile.auto["Grey Items"]
                        end,
                        set = function(_, value)
                            RP.db.profile.auto["Grey Items"] = value
                        end
                    },
                    white = {
                        order = 1,
                        type = "toggle",
                        name = "White Items",
                        get = function()
                            return RP.db.profile.auto["White Items"]
                        end,
                        set = function(_, value)
                            RP.db.profile.auto["White Items"] = value
                        end
                    },
                    green = {
                        order = 2,
                        type = "toggle",
                        name = "Green Items",
                        get = function()
                            return RP.db.profile.auto["Green Items"]
                        end,
                        set = function(_, value)
                            RP.db.profile.auto["Green Items"] = value
                        end
                    },
                    blue = {
                        order = 3,
                        type = "toggle",
                        name = "Blue Items",
                        get = function()
                            return RP.db.profile.auto["Blue Items"]
                        end,
                        set = function(_, value)
                            RP.db.profile.auto["Blue Items"] = value
                        end
                    }
                }
            },
            filter = {
                order = 3,
                type = "group",
                name = "Filter",
                childGroups = "tab",
                disabled = _disabled,
                inline = true,
                hidden = function()
                    return not RP.db.profile.auto["Sell Junk"]
                end,
                args = {
                    desc1 = {
                        type = "description",
                        name = " ",
                        order = 0
                    },
                    exclude = {
                        order = 1,
                        type = "input",
                        width = "full",
                        name = "Exclude Items",
                        desc = "The list of item ID's you want filtered to not automatically sell",
                        usage = "\n" .. "\n" ..
                            "You can use the item ID or the item name but it isn't reliable to use the name. If you want to filter multiple items seperate by commas like this: \n" ..
                            "\n" .. C.BLUE_COLOR:WrapTextInColorCode("9149,9148,9147...") .. "\n" .. "\n" ..
                            "Enable the ID module to easily find the item ID's.",
                        multiline = 5,
                        dialogControl = 'MultiLineEditBox-RasPort', -- Use a multi-line edit box
                        get = function(info)
                            return table.concat(RP.db.profile.auto.excludedItems, ",")
                        end,
                        set = function(info, value)
                            RP.db.profile.auto.excludedItems = {strsplit(",", value)}
                            RP.options.args.Options.args.Auto.args.excludedgroup.args.excludedList.name =
                                function()
                                    return GetExcludedItemIDs()
                                end
                            LibStub("AceConfigRegistry-3.0"):NotifyChange("RasPort")
                        end
                    },
                    sep1 = {
                        name = "\n",
                        order = 2,
                        type = "description"
                    }
                }
            },
            excludedgroup = {
                order = 4,
                type = "group",
                name = "Excluded Items List",
                inline = true,
                args = {
                    excludedList = {
                        order = 3,
                        type = "input",
                        name = function(Info)
                            return GetExcludedItemIDs()
                        end,
                        width = 'full',
                        dialogControl = "Info-RasPort",
                        get = function(info)
                            local names = GetExcludedItemNames()
                            return names
                        end,
                        set = function(info, val)
                            -- Read-only, does not allow user input
                        end,
                        disabled = true -- Make it non-interactive
                    }
                }
            }
        }
    }

    local e = CreateFrame("Frame")
    e:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    e:SetScript("OnEvent", function(self, event, arg1, arg2)
        if event == "GET_ITEM_INFO_RECEIVED" and arg2 then
            -- Refresh the AceConfig dialog here
            LibStub("AceConfigRegistry-3.0"):NotifyChange("RasPort")
        end
    end)

    RP:RegisterForEvent("PLAYER_LOGIN", function()
        RP.options.args.Options.args.Auto = options
        Auto_D()
    end)
end)
