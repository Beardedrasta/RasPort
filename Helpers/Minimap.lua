local RP = RasPort
local M, P, U, _ = RP:Unpack() -- m, p, u, c

RP.RasPortLDB = LibStub("LibDataBroker-1.1"):NewDataObject("RasPort", {
    type = "launcher",
    text = "RasPort",
    icon = RP.Meta.logo,
    OnClick = function(_, button)
        if button == "RightButton" then
            RP["Minimap Button"] = true
            U.Icon:Hide("RasPort")
        elseif button == "LeftButton" then
            RP:OpenConfig()
        end
    end,
    OnTooltipShow = function(tt)
        tt:AddDoubleLine("RasPort", "1.4.5", 1, 1, 1)
        tt:AddLine(" ")
        tt:AddLine("|cffeda55fLeft-Click|r to open configuration.", 0.2, 1, 0.2)
        tt:AddLine("|cffeda55fRight-Click|r to hide minimap button.", 0.2, 1, 0.2)
        tt:AddLine(" ")
        tt:AddDoubleLine("|cff707070Discord:|r", "|cff707070rasta0818|r")
    end
})