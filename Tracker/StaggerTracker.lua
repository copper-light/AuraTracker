if select(4, GetBuildInfo()) <= 50000 then return end


HDH_STAGGER_TRACKER = {}
local DB = HDH_AT_ConfigDB
local STAGGER_KEY = "STAGGER"

-- local STAGGER_STATES = {
-- 	RED 	= { key = "red", threshold = .60 },
-- 	YELLOW 	= { key = "yellow", threshold = .30 },
-- 	GREEN 	= { key = "green" }
-- }

local STAGGER_RED_TRANSITION = 0.6  -- wow global var : 0.6
local STAGGER_YELLOW_TRANSITION = 0.3-- wow global var : 0.3
local info = PowerBarColor[STAGGER_KEY]

local STAGGER_GREEN_INDEX = info[1] and 1 or "green"
local STAGGER_YELLOW_INDEX = info[2] and 2 or "yellow"
local STAGGER_RED_INDEX = info[3] and 3 or "red"
HDH_STAGGER_TRACKER.SPLIT_BAR_VALUES = {STAGGER_YELLOW_TRANSITION*100, STAGGER_RED_TRANSITION*100}
HDH_STAGGER_TRACKER.POWER_INFO = {
	{ texture = "Interface/Icons/Priest_icon_Chakra_green", color = {info[STAGGER_GREEN_INDEX].r, info[STAGGER_GREEN_INDEX].g, info[STAGGER_GREEN_INDEX].b, 1}},
	{ texture = "Interface/Icons/Priest_icon_Chakra", 	    color = {info[STAGGER_YELLOW_INDEX].r, info[STAGGER_YELLOW_INDEX].g, info[STAGGER_YELLOW_INDEX].b, 1}},
	{ texture = "Interface/Icons/Priest_icon_Chakra_red",   color = {info[STAGGER_RED_INDEX].r, info[STAGGER_RED_INDEX].g, info[STAGGER_RED_INDEX].b, 1},}
}

 
------------------------------------
-- HDH_STAGGER_TRACKER class
------------------------------------
local super = HDH_POWER_TRACKER;
setmetatable(HDH_STAGGER_TRACKER, super) -- 상속
HDH_STAGGER_TRACKER.__index = HDH_STAGGER_TRACKER;
HDH_STAGGER_TRACKER.className = 'HDH_STAGGER_TRACKER';

HDH_TRACKER.TYPE.STAGGER = 22
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.STAGGER, HDH_STAGGER_TRACKER)

local function STAGGER_TRACKER_OnUpdate(self, elapsed)
	self.spell.curTime = GetTime()
	if self.spell.curTime - (self.spell.delay or 0) < HDH_TRACKER.BAR_UP_ANI_TERM then return end 
	self.spell.delay = self.spell.curTime
	self.spell.valueMax = self:GetParent().parent:GetPowerMax()
	self.spell.v1 = self:GetParent().parent:GetPower()
	self.spell.per = self.spell.v1 / self.spell.valueMax
	self.spell.count = math.ceil(self.spell.per * 100)
	if self.spell.count == math.huge then self.spell.count = 0; end
	self.counttext:SetText(format("%d%%", math.ceil(self.spell.count or 0))); 
	
	if not self.spell.is_fixed_texture then
		if self.spell.per > STAGGER_RED_TRANSITION then
			self.icon:SetTexture(HDH_STAGGER_TRACKER.POWER_INFO[3].texture);
		elseif self.spell.per > STAGGER_YELLOW_TRANSITION then
			self.icon:SetTexture(HDH_STAGGER_TRACKER.POWER_INFO[2].texture);
		else
			self.icon:SetTexture(HDH_STAGGER_TRACKER.POWER_INFO[1].texture);
		end
	end
	
	if self.spell.showValue then self.v1:SetText(HDH_AT_UTIL.AbbreviateValue(self.spell.v1, self:GetParent().parent.ui.font.v1_abbreviate)); else self.v1:SetText(nil) end
	
	if self.spell.v1 > 0 then
		if self.spell.isOn ~= true then
			self:GetParent().parent:Update();
			self.spell.isOn = true;
		end
	else
		if self.spell.isOn ~= false then
			self:GetParent().parent:Update();
			self.spell.isOn = false;
		end
	end
	if self.bar then
		if self.spell.valueMax ~= self.spell.preValueMax then
			self:GetParent().parent:UpdateBarMinMaxValue(self)
			self.spell.preValueMax = self.spell.valueMax
		else
		-- self.bar:SetValue(self.spell.v1, true)
			self:GetParent().parent:UpdateBarValue(self, nil, true)
		end
	end
	self:GetParent().parent:UpdateGlow(self, true);
end

function HDH_STAGGER_TRACKER:CreateData()
	local trackerId = self.id
	local key = STAGGER_KEY 
	local id = 0
	local name = STAGGER_KEY
	local texture = HDH_STAGGER_TRACKER.POWER_INFO[1].texture;
	local display = DB.SPELL_ALWAYS_DISPLAY
	local isValue = true
	local isItem = false

	if DB:GetTrackerElementSize(trackerId) > 0 then
		DB:TrancateTrackerElements(trackerId)
	end
	local elemIdx = DB:AddTrackerElement(trackerId, key, id, name, texture, display, isValue, isItem)
	DB:SetReadOnlyTrackerElement(trackerId, elemIdx) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다
	DB:UpdateTrackerElementGlow(trackerId, elemIdx, DB.GLOW_CONDITION_COUNT, DB.CONDITION_GT_OR_EQ, STAGGER_RED_TRANSITION*100)
	DB:SetTrackerElementBarInfo(trackerId, elemIdx, DB.BAR_TYPE_BY_VALUE, DB.BAR_MAX_TYPE_AUTO, nil, HDH_STAGGER_TRACKER.SPLIT_BAR_VALUES, DB.BAR_SPLIT_RATIO)

	DB:CopyGlobelToTracker(trackerId)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON_AND_BAR)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.use_full_color', true)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.location', DB.BAR_LOCATION_R)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.width', 200)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.height', 20)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.to_fill', true)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.cooldown_progress', DB.COOLDOWN_RIGHT)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.texture', 3)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', HDH_STAGGER_TRACKER.POWER_INFO[1].color)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.full_color', HDH_STAGGER_TRACKER.POWER_INFO[3].color)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.name_location', DB.FONT_LOCATION_HIDE)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.count_location', DB.FONT_LOCATION_BAR_L)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_BAR_R)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_abbreviate', false)

	DB:SetTrackerValue(trackerId, 'ui.%s.icon.size', 30)
	DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', {0, 0, 0, 1})
	self:UpdateSetting();
end

function HDH_STAGGER_TRACKER:GetPower()
	return UnitStagger('player') or 0;
end

function HDH_STAGGER_TRACKER:GetPowerMax()
	return UnitHealthMax('player');
end

function HDH_STAGGER_TRACKER:GetElementCount(spec)
	local key = DB:GetTrackerElement(self.id, 1)
	if (STAGGER_KEY) == key then
		return 1
	else
		return 0
	end
end

function HDH_STAGGER_TRACKER:CreateDummySpell(count)
	local icons =  self.frame.icon
	local ui = self.ui
	local f
	local health_max = UnitHealthMax("player");
	f = icons[1];
	f:SetMouseClickEnabled(false);
	if not f:GetParent() then f:SetParent(self.frame) end
	if f.icon:GetTexture() == nil then
		f.icon:SetTexture(HDH_STAGGER_TRACKER.POWER_INFO[1].texture);
	end
	local spell = f.spell
	if not spell then spell = {} f.spell = spell end
	spell.display = DB.SPELL_ALWAYS_DISPLAY
	spell.id = 0
	spell.count = 100
	spell.duration = 0
	spell.happenTime = 0;
	spell.glow = false
	spell.endTime = 0
	spell.startTime = 0
	spell.remaining = 0
	spell.showValue = f.spell.showValue
	spell.v1 = health_max
	spell.max = health_max;
	spell.splitValues = f.spell.splitValues

	if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
		f:SetScript("OnUpdate",nil);
		if spell.showValue then
			f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(spell.v1,true));
		else
			f.v1:SetText('')
		end
		if f.bar then
			f.bar:SetMinMaxValues(0,1);
			f.bar:SetValue(1);
		end
	end
	f.spell = spell
	f.counttext:SetText("100%")
	self:SetGameTooltip(f, false)
	f:Show()
	return 1;
end

function HDH_STAGGER_TRACKER:InitIcons()
	local ret = super.InitIcons(self)
	if ret then
		for i = 1 , ret do
			if self.frame.icon[i].spell.icon ~= 463281 then -- 463281 = Interface/Icons/ability_monk_stagger_green
				self.frame.icon[i].spell.is_fixed_texture = true
			else
				self.frame.icon[i].spell.is_fixed_texture = false
			end
			self.frame.icon[i]:SetScript("OnUpdate", STAGGER_TRACKER_OnUpdate)
		end

		self.frame:UnregisterAllEvents()
		self:Update()
	end
	return ret
end

-- function HDH_STAGGER_TRACKER:PLAYER_ENTERING_WORLD()
-- end

------------------------------------
-- HDH_STAGGER_TRACKER class
------------------------------------