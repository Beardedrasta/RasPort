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

--[[
################################################################
#################           API               #################
################################################################
]] --
local _G = getfenv(0)
local GetLocale = _G.GetLocale

--[[
################################################################
#################           Lua API            #################
################################################################
]] --
local format = _G.string.format
local type = _G.type
local min = _G.math.min
local abs = _G.math.abs
local floor = _G.math.floor
local next = _G.next
local pairs = _G.pairs
local tinsert = _G.table.insert
local tremove = _G.table.remove
local wipe = _G.table.wipe
local max = _G.math.max
local select = _G.select
local off
local assert = assert
local unpack = unpack
local tonumber = tonumber
local getmetatable = getmetatable

--[[
################################################################
#################       LibSharedMedia         #################
################################################################
]] --
function RP:MediaFetch(mediatype, key, default)
    return (key and RP.UI.LSM:Fetch(mediatype, key)) or (default and RP.UI.LSM:Fetch(mediatype, default)) or default
end

function RP:MediaRegister(mediatype, key, path)
    RP.UI.LSM:Register(mediatype, key, path)
end

function RP:RegisterLSMCallback(obj, event, callback)
    RP.UI.LSM.RegisterCallback(obj, event, callback)
end

--[[
################################################################
#################           Locale             #################
################################################################
]] --
function RP:GetLocale(locale)
    return GetLocale() == locale
end

--[[
################################################################
#################           Time Format        #################
################################################################
]] --
function RP.FormatTime(sec)
    if (sec == huge) then
        sec = 0
    end

    if (sec >= 86400) then
        return format('%dd', ceil(sec / 86400))
    elseif (sec >= 3600) then
        return format('%dh', ceil(sec / 3600))
    elseif (sec >= 60) then
        return format('%dm', ceil(sec / 60))
    elseif (sec >= 5) then
        return format('%d', ceil(sec))
    else
        return format('%.1f', sec)
    end
end


--[[
################################################################
#################        Number & Round        #################
################################################################
]] --
function RP:AbbreviateNumber(num)
    if num >= 1000000000 then
        return format("%.2fB", num / 1000000000)
    elseif num >= 1000000 then
        return format("%.2fM", num / 1000000)
    elseif num >= 1000 then
        return format("%.2fK", num / 1000)
    else
        return num
    end
end

function RP:Abbreviate(number, eachk)
    local sign = number < 0 and -1 or 1
    number = abs(number)
    if number > 1000000 then
        return RP:Round(number / 1000000 * sign, 2) .. "m"
    elseif not eachk and number > 10000 then
        return RP:Round(number / 1000 * sign, 2) .. "k"
    elseif eachk and number > 1000 then
        return RP:Round(number / 1000 * sign, 2) .. "k"
    end

    return number
end

function RP:Round(input, places)
    if not places then
        places = 0
    end
    if type(input) == "number" and type(places) == "number" then
        local pow = 1
        for i = 1, places do
            pow = pow * 10
        end
        return floor(input * pow + 0.5) / pow
    end
end

--[[
################################################################
#################        Mixin                 #################
################################################################
]] --
RP.Mixin = function(object, ...)
	local mixins = {...};
	for _, mixin in pairs(mixins) do
		for k, v in next, mixin do
			object[k] = v;
		end
	end
	return object;
end

--[[
################################################################
#################        Stop Frame            #################
################################################################
]] --
RP.Noop = function()
    return
end
function RP:Kill(frame)
    if frame and frame.SetScript then
        frame:UnregisterAllEvents()
        frame:SetScript("OnEvent", nil)
        frame:SetScript("OnUpdate", nil)
        frame:SetScript("OnHide", nil)
        frame:Hide()
        frame.SetScript = RP.Noop
        frame.RegisterEvent = RP.Noop
        frame.RegisterAllEvents = RP.Noop
        frame.Show = RP.Noop
    end
end

--[[
################################################################
#################        Weak Table            #################
################################################################
]] --
do

    local weaktable = {
        __mode = "v"
    }
    function RP.WeakTable(t)
        return setmetatable(wipe(t or {}), weaktable)
    end

    -- Shamelessly copied from Omen - thanks!
    local tablePool = RP.tablePool or setmetatable({}, {
        __mode = "kv"
    })
    RP.tablePool = tablePool

    -- get a new table
    function RP.newTable()
        local t = next(tablePool) or {}
        tablePool[t] = nil
        return t
    end

    -- delete table and return to pool
    function RP.delTable(t)
        if type(t) == "table" then
            wipe(t)
            t[true] = true
            t[true] = nil
            tablePool[t] = true
        end
        return nil
    end
end

--[[
################################################################
#################        C_Timer               #################
################################################################
]] --

do
    local TickerPrototype = {}
    local TickerMetatable = {
        __index = TickerPrototype
    }

    local WaitTable = {}

    local new, del
    do
        local list = {
            cache = {},
            trash = {}
        }
        setmetatable(list.trash, {
            __mode = "v"
        })

        function new()
            return table.remove(list.cache) or {}
        end

        function del(t)
            if t then
                setmetatable(t, nil)
                for k, v in pairs(t) do
                    t[k] = nil
                end
                tinsert(list.cache, 1, t)
                while #list.cache > 20 do
                    tinsert(list.trash, 1, tremove(list.cache))
                end
            end
        end
    end

    local function WaitFunc(self, elapsed)
        local total = #WaitTable
        local i = 1

        while i <= total do
            local ticker = WaitTable[i]

            if ticker._cancelled then
                del(tremove(WaitTable, i))
                total = total - 1
            elseif ticker._delay > elapsed then
                ticker._delay = ticker._delay - elapsed
                i = i + 1
            else
                ticker._callback(ticker)

                if ticker._iterations == -1 then
                    ticker._delay = ticker._duration
                    i = i + 1
                elseif ticker._iterations > 1 then
                    ticker._iterations = ticker._iterations - 1
                    ticker._delay = ticker._duration
                    i = i + 1
                elseif ticker._iterations == 1 then
                    del(tremove(WaitTable, i))
                    total = total - 1
                end
            end
        end

        if #WaitTable == 0 then
            self:Hide()
        end
    end

    local WaitFrame = _G.RPWaitFrame or CreateFrame("Frame", "RPWaitFrame", UIParent)
    WaitFrame:SetScript("OnUpdate", WaitFunc)

    local function AddDelayedCall(ticker, oldTicker)
        ticker = (oldTicker and type(oldTicker) == "table") and oldTicker or ticker
        tinsert(WaitTable, ticker)
        WaitFrame:Show()
    end

    local function ValidateArguments(duration, callback, callFunc)
        if type(duration) ~= "number" then
            error(format("Bad argument #1 to '" .. callFunc .. "' (number expected, got %s)",
                duration ~= nil and type(duration) or "no value"), 2)
        elseif type(callback) ~= "function" then
            error(format("Bad argument #2 to '" .. callFunc .. "' (function expected, got %s)",
                callback ~= nil and type(callback) or "no value"), 2)
        end
    end

    local function After(duration, callback, ...)
        ValidateArguments(duration, callback, "After")

        local ticker = new()

        ticker._iterations = 1
        ticker._delay = max(0.01, duration)
        ticker._callback = callback

        AddDelayedCall(ticker)
    end

    local function CreateTicker(duration, callback, iterations, ...)
        local ticker = new()
        setmetatable(ticker, TickerMetatable)

        ticker._iterations = iterations or -1
        ticker._delay = max(0.01, duration)
        ticker._duration = ticker._delay
        ticker._callback = callback

        AddDelayedCall(ticker)
        return ticker
    end

    local function NewTicker(duration, callback, iterations, ...)
        ValidateArguments(duration, callback, "NewTicker")
        return CreateTicker(duration, callback, iterations, ...)
    end

    local function NewTimer(duration, callback, ...)
        ValidateArguments(duration, callback, "NewTimer")
        return CreateTicker(duration, callback, 1, ...)
    end

    local function CancelTimer(ticker, silent)
        if ticker and ticker.Cancel then
            ticker:Cancel()
        elseif not silent then
            error("RP.CancelTimer(timer[, silent]): '" .. tostring(ticker) .. "' - no such timer registered")
        end
        return nil
    end

    function TickerPrototype:Cancel()
        self._cancelled = true
    end
    function TickerPrototype:IsCancelled()
        return self._cancelled
    end

    RP.After = After
    RP.NewTicker = NewTicker
    RP.NewTimer = NewTimer
    RP.CancelTimer = CancelTimer
end

--[[
################################################################
#################     Event Registration       #################
################################################################
]] --
function RP:RegisterForEvent(event, callback, ...)
    if not self.frame then
        self.frame = CreateFrame("Frame", "RasPortOptions")
        self.frame:SetScript("OnEvent", function(f, event, ...)
            for func, args in next, f.events[event] do
                func(unpack(args), ...)
            end
        end)
    end
    self.frame.events = self.frame.events or {}
    self.frame.events[event] = self.frame.events[event] or {}
    self.frame.events[event][callback] = {...}
    self.frame:RegisterEvent(event)
end

--[[
################################################################
#################          Reload UI           #################
################################################################
]] --
function RP:Reload()
    ReloadUI()
end

--[[
################################################################
#################      Initialize Config       #################
################################################################
]] --
function RP:OpenConfig(...)
    if ... then
        RP.UI.ACD:Open("RasPort")
        RP.UI.ACD:SelectGroup("RasPort", ...)
    elseif not RP.UI.ACD:Close("RasPort") then
        RP.UI.ACD:Open("RasPort")
    end
end

--[[
################################################################
#################           Modules            #################
################################################################
]] --

function RP:AddModule(name, desc, func)
    if type(desc) == "function" then
        func = desc
        desc = nil
    end

    self.modulesList = self.modulesList or {}
    self.modulesList[#self.modulesList + 1] = func

    local isConfigDisabled = (name == "Theme" or name == "Minimap")

    self.options.args.Modules.args.list.args[name] = {
        type = "toggle",
        name = RP.Color.TURQ_COLOR:WrapTextInColorCode(name),
        desc = desc,
        get = function()
            return RP.db.profile.disabledModules[name]
        end,
        set = function(_, val)
            RP.db.profile.disabledModules[name] = val
            RP.options.args.Modules.args.apply.disabled = false
        end,
        disabled = isConfigDisabled,
    }
end

function RP:IsDisabled(...)
    for i = 1, select("#", ...) do
        if RP.db.profile.disabledModules[select(i, ...)] == false then
            off = (off or 0) + 1
            return true
        end
    end
    return false
end

-- checks if addon(s) is (are) loaded
function RP:AddOnIsLoaded(...)
    for i = 1, select("#", ...) do
        local name = select(i, ...)
        if IsAddOnLoaded(name) then
            return true, name
        end
    end
    return false, nil
end

--[[
################################################################
#################           Masque Blizz       #################
################################################################
]] --

do
    local function msqDefaultbar()
        if not IsAddOnLoaded("Masque") then
            return
        else
            local MSQ = LibStub("Masque")

            local MasqueBlizzBars = {
                MasqueSkin = MasqueSkin or {},
                Groups = {}
            }

            local buttons = {
                ActionBar = {
                    ActionButton = NUM_ACTIONBAR_BUTTONS,
                    BonusActionButton = NUM_BONUS_ACTION_SLOTS
                },
                MultiBarBottomLeft = {
                    MultiBarBottomLeftButton = NUM_MULTIBAR_BUTTONS
                },
                MultiBarBottomRight = {
                    MultiBarBottomRightButton = NUM_MULTIBAR_BUTTONS
                },
                MultiBarLeft = {
                    MultiBarLeftButton = NUM_MULTIBAR_BUTTONS
                },
                MultiBarRight = {
                    MultiBarRightButton = NUM_MULTIBAR_BUTTONS
                },
                PetBar = {
                    PetActionButton = NUM_PET_ACTION_SLOTS
                },
                StanceBar = {
                    ShapeshiftButton = NUM_SHAPESHIFT_SLOTS,
                    PossessButton = NUM_POSSESS_SLOTS,
                    StanceButton = NUM_STANCE_SLOTS
                }
            }

            function MasqueBlizzBars:OnSkinChange(Group, Skin, SkinID, Gloss, Backdrop, Colors)
                if (Group == nil) then
                    for k, v in pairs(MasqueBlizzBars.Groups) do
                        MasqueBlizzBars:OnSkinChange(v, Skin, SkinID, Gloss, Backdrop, Colors)
                    end
                    return
                elseif (not MasqueBlizzBars.MasqueSkin[Group]) then
                    MasqueBlizzBars.MasqueSkin[Group] = {}
                end
                MasqueBlizzBars.MasqueSkin[Group].Skin = Skin
                MasqueBlizzBars.MasqueSkin[Group].SkinID = SkinID
                MasqueBlizzBars.MasqueSkin[Group].Gloss = Gloss
                MasqueBlizzBars.MasqueSkin[Group].Backdrop = Backdrop
                MasqueBlizzBars.MasqueSkin[Group].Colors = Colors
            end

            function MasqueBlizzBars:UIParent_ManageFramePositions()
                for k, v in pairs(MasqueBlizzBars.Groups) do
                    v:ReSkin()
                end
            end

            function MasqueBlizzBars:Init()
                hooksecurefunc("UIParent_ManageFramePositions", MasqueBlizzBars.UIParent_ManageFramePositions);
                MSQ:Register("Blizzard Action Bars", MasqueBlizzBars.OnSkinChange, MasqueBlizzBars)

                MasqueBlizzBars.Groups = {
                    ActionBar = MSQ:Group("Blizzard Action Bars", "Action Bar"),
                    MultiBarBottomLeft = MSQ:Group("Blizzard Action Bars", "MultiBar BottomLeft"),
                    MultiBarBottomRight = MSQ:Group("Blizzard Action Bars", "MultiBar BottomRight"),
                    MultiBarLeft = MSQ:Group("Blizzard Action Bars", "MultiBar Left"),
                    MultiBarRight = MSQ:Group("Blizzard Action Bars", "MultiBar Right"),
                    PetBar = MSQ:Group("Blizzard Action Bars", "PetBar"),
                    StanceBar = MSQ:Group("Blizzard Action Bars", "StanceBar")
                }

                if MasqueBlizzBars.MasqueSkin then
                    for k, v in pairs(MasqueBlizzBars.Groups) do
                        if (MasqueBlizzBars.MasqueSkin[v.Group]) then
                            v:SetOption('Group', MasqueBlizzBars.MasqueSkin[v.Group].Group)
                            v:SetOption('SkinID', MasqueBlizzBars.MasqueSkin[v.Group].SkinID)
                            v:SetOption('Gloss', MasqueBlizzBars.MasqueSkin[v.Group].Gloss)
                            v:SetOption('Backdrop', MasqueBlizzBars.MasqueSkin[v.Group].Backdrop)
                            v:SetOption('Colors', MasqueBlizzBars.MasqueSkin[v.Group].Colors)
                        end
                    end
                end

                MasqueBlizzBars:UpdateActionBars()
            end
            function MasqueBlizzBars:SkinButton(group, button, strata)
                local st = starta or "HIGH"
                if button then
                    group:AddButton(button)
                    button:SetFrameStrata(st)
                end
            end
            function MasqueBlizzBars:UpdateActionBars()
                for k, v in pairs(MasqueBlizzBars.Groups) do
                    for _k, _v in pairs(buttons[k]) do
                        for i = 1, _v do
                            MasqueBlizzBars:SkinButton(v, _G[_k .. i])
                        end
                    end
                end
            end
            MasqueBlizzBars:Init()
        end
    end

    msqDefaultbar()
end

--[[
################################################################
#################           Print              #################
################################################################
]] --

function RP:Print(...)
    print("|cffff6347RasPort|r:", ...)
end

local texture, fontstring;
local prototype = {CreateFrame("Frame"), CreateFrame("Button")};

local subinit = function()
	for _, data in pairs(prototype) do
		texture = getmetatable(data:CreateTexture());
		fontstring = getmetatable(data:CreateFontString());
	end
end
subinit();


-- method shown
local methodshown = function(self, data)
	if data and data ~= false then
		self:Show();
	else
		self:Hide();
	end
end

function texture.__index:SetShown(...)
	methodshown(self, ...);
end

function fontstring.__index:SetShown(...)
	methodshown(self, ...);
end


local GetNumBattlegroundTypes = GetNumBattlegroundTypes;
local GetBattlegroundInfo = GetBattlegroundInfo;
local GetRandomBGHonorCurrencyBonuses = GetRandomBGHonorCurrencyBonuses;
local GetHolidayBGHonorCurrencyBonuses = GetHolidayBGHonorCurrencyBonuses;

-- get info about battlefield rewards
RP.GetAmountBattlefieldBonus = function()
	-- @param [boolean] hasWon - whether player has won bonus BG
	-- @param [numbers] winHonorAmount - bonus honor points on current BG
	-- @param [numbers] winArenaAmount - bonus arena points on current BG
	local name, canEnter, isHoliday, isRandom;
	local hasWon, winHonorAmount, winArenaAmount;
	for i=1, GetNumBattlegroundTypes() do
		name, canEnter, isHoliday, isRandom = GetBattlegroundInfo(i);
		if isRandom and name then
			hasWon, winHonorAmount, winArenaAmount = GetRandomBGHonorCurrencyBonuses();
		elseif isHoliday and name then
			hasWon, winHonorAmount, winArenaAmount = GetHolidayBGHonorCurrencyBonuses();
		end
	end
	-- returns: info about battlefield rewards
	return hasWon, winHonorAmount, winArenaAmount;
end

-- sanitizes and convert patterns into gmatch compatible ones
local sanitize_cache = {};
local function SanitizePattern(pattern)
	assert(pattern, "bad argument #1 to \'SanitizePattern\' (string expected, got nil)");
	if not sanitize_cache[pattern] then
		-- @param [string] "pattern" - unformatted pattern
		local ret = pattern;
		-- remove '|3-formid(text)' grammar sequence (no need to handle this for this case)
		-- ret = ret:gsub("%|3%-1%((.-)%)", "%1")
		-- escape magic characters
		ret = ret:gsub("([%+%-%*%(%)%?%[%]%^])", "%%%1");
		-- remove capture indexes
		ret = ret:gsub("%d%$", "");
		-- catch all characters
		ret = ret:gsub("(%%%a)", "%(%1+%)");
		-- convert all %s to .+
		ret = ret:gsub("%%s%+", ".+");
		-- set priority to numbers over strings
		ret = ret:gsub("%(.%+%)%(%%d%+%)", "%(.-%)%(%%d%+%)");
		-- cache it
		sanitize_cache[pattern] = ret;
	end
	-- returns: [string] simplified gmatch compatible pattern
	return sanitize_cache[pattern];
end

local capture_cache = {};
local function GetCaptures(pat)
	-- returns the indexes of a given regex pattern
	-- @param [string] "pat" - unformatted pattern
	if not capture_cache[pat] then
		local result = {};
		for capture_index in pat:gmatch("%%(%d)%$") do
			capture_index = tonumber(capture_index);
			tinsert(result, capture_index);
		end
		capture_cache[pat] = #result > 0 and result;
	end
	-- returns: [numbers] capture indexes
	return capture_cache[pat];
end

-- same as string.match but aware of capture indexes
string.cmatch = function(str, pat)
	-- @param [string] "str" - input string that should be matched
	-- @param [string] "pat" - unformatted pattern
	
	-- read capture indexes:
	local capture_indexes = GetCaptures(pat);
	local sanitized_pat = SanitizePattern(pat);
	
	-- if no capture indexes then use original string.match
	if not capture_indexes then
		return str:match(sanitized_pat);
	end
	-- read captures
	local captures = {str:match(sanitized_pat)};
	if #captures == 0 then return; end
	
	-- put entries into the proper return values
	local result = {};
	for current_index, capture in pairs(captures) do
		local correct_index = capture_indexes[current_index];
		result[correct_index] = capture;
	end
	-- returns: [strings] matched string in capture order
	return unpack(result);
end