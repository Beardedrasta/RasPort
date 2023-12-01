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
RP:AddModule("Grid", "Align the UI components\n|cff00ff00/rpgrid|r", function()
    if RP:IsDisabled("Grid") then return end

    local grid
    local gridEnabled = false

    local function ShowGrid()
        if not grid then
            grid = CreateFrame("Frame", "GridFrame", UIParent)
            grid:SetAllPoints(UIParent)
            grid:SetFrameStrata("BACKGROUND")
        end

        local width, height = UIParent:GetSize()
        local gridSize = 16
        local centerLineColor = {1, 0, 0, 0.5}
        local gridLineColor = {1, 1, 1, 0.2}

        for x = 0, width, gridSize do
            local color = gridLineColor
            if x == width / 2 then
                color = centerLineColor
            end

            local texture = grid:CreateTexture(nil, "BACKGROUND")
            texture:SetColorTexture(unpack(color))
            texture:SetSize(1, height)
            texture:SetPoint("TOPLEFT", x- 5, 0)
        end

        for y = 0, height, gridSize do
            local color = gridLineColor
            if y == height / 2 then
                color = centerLineColor
            end

            local texture = grid:CreateTexture(nil, "BACKGROUND")
            texture:SetColorTexture(unpack(color))
            texture:SetSize(width, 1)
            texture:SetPoint("TOPLEFT", 0, -y + 5)
        end

        grid:Show()
    end


    local function ShowCenterLines()
        if not grid then
            grid = CreateFrame("Frame", "CenterLinesFrame", UIParent)
            grid:SetAllPoints(UIParent)
            grid:SetFrameStrata("BACKGROUND")
        end

        local width, height = UIParent:GetSize()
        local centerLineColor = {1, 0, 0, 0.5}

        local textureX = grid:CreateTexture(nil, "BACKGROUND")
        textureX:SetColorTexture(unpack(centerLineColor))
        textureX:SetSize(1, height)
        textureX:SetPoint("CENTER", 0, 0)

        local textureY = grid:CreateTexture(nil, "BACKGROUND")
        textureY:SetColorTexture(unpack(centerLineColor))
        textureY:SetSize(width, 1)
        textureY:SetPoint("CENTER", 0, 0)

        grid:Show()
    end

    local function HideCenterLines()
        if grid then
            grid:Hide()
        end
    end

    local function HideGrid()
        if grid then
            grid:Hide()
        end
    end

    SLASH_RASPORTGRID1 = "/rpgrid"
    SlashCmdList["RASPORTGRID"] = function()
        gridEnabled = not gridEnabled
        if gridEnabled then
            ShowCenterLines()
            ShowGrid()
        else
            HideCenterLines()
            HideGrid()
        end
    end

end)