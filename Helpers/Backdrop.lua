local RP = RasPort
local _, P, _, _ = RP:Unpack() -- m, p, u, c


RP:RegisterForEvent("PLAYER_ENTERING_WORLD", function()
    local CC = RP.rasColor
    local DB = RP.db.profile
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

    function RP:CreateBackdrop(parent, alpha, level)
        local border = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        border:SetBackdrop({
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
        border:SetFrameLevel(level or parent:GetFrameLevel() + 1)
        border:SetPoint("TOPLEFT", parent, "BOTTOMRIGHT", -4, 4)
        border:SetPoint("BOTTOMRIGHT", parent, "TOPLEFT", 4, -4)
        border:SetBackdropBorderColor(r, g, b, 1)
        border:SetAlpha(alpha or 1)

        local backdrop = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        backdrop:SetBackdrop({
            bgFile = "Interface\\AddOns\\RasPort\\Media\\Background\\UI-Background-Rock.blp", "REPEAT", "REPEAT",
            tile = false,
            tileSize = 8,
            insets = {
                left = 0,
                right = 0,
                top = 0,
                bottom = 0
            }
        })
        backdrop:SetFrameLevel(parent:GetFrameLevel() - 1)
        backdrop:SetFrameStrata("BACKGROUND")
        backdrop:SetAllPoints(border)

        parent.rpBorder = border

        return border, backdrop
    end
end)