HDH_STAGGER_TRACKER = {}
local DB = HDH_AT_ConfigDB
local STAGGER_KEY = "STAGGER"

local STAGGER_STATES = {
	RED 	= { key = "red", threshold = .60 },
	YELLOW 	= { key = "yellow", threshold = .30 },
	GREEN 	= { key = "green" }
}

local STAGGER_RED_TRANSITION = _G.STAGGER_RED_TRANSITION or 0.60  -- wow global var : 0.6
local STAGGER_YELLOW_TRANSITION = _G.STAGGER_YELLOW_TRANSITION  or 0.30-- wow global var : 0.3
local info = PowerBarColor[STAGGER_KEY]

local STAGGER_GREEN_INDEX = _G.STAGGER_GREEN_INDEX or "green"
local STAGGER_YELLOW_INDEX = _G.STAGGER_YELLOW_INDEX or "yellow"
local STAGGER_RED_INDEX = _G.STAGGER_RED_INDEX or "red"



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
	-- local curValue = UnitStagger('player') or 0;
	
	curValue = (curValue or 0) + 1000
	local health_max = UnitHealthMax("player");
	local per = curValue/health_max;
	self.spell.v1 = curValue;
	self.spell.count = (per * 100)
	if self.spell.count == math.huge then self.spell.count = 0; end
	self.counttext:SetText(format("%d%%", math.ceil(self.spell.count or 0))); 
	
	if per > STAGGER_RED_TRANSITION then
		self.icon:SetTexture(HDH_STAGGER_TRACKER.POWER_INFO[3].texture);
	elseif per > STAGGER_YELLOW_TRANSITION then
		self.icon:SetTexture(HDH_STAGGER_TRACKER.POWER_INFO[2].texture);
	else
		self.icon:SetTexture(HDH_STAGGER_TRACKER.POWER_INFO[1].texture);
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
	if self.bar and self.bar.max ~= health_max then
		for i = 1, #self.spell.splitValues do
			self.bar.bar[i].mpMax = self.spell.splitValues[i] or health_max;
			self.bar.bar[i].mpMin = self.spell.splitValues[i-1] or 0;
			self.bar.bar[i]:SetMinMaxValues(self.bar.bar[i].mpMin, self.bar.bar[i].mpMax);
		end
		self:GetParent().parent:UpdateBarValue(self, true);	
	else
		self:GetParent().parent:UpdateBarValue(self, false);
	end
	self:GetParent().parent:SetGlow(self, true);
end

function HDH_STAGGER_TRACKER:UpdateBar(f, barMax)
	if f.spell then
		local value = math.floor((barMax or UnitHealthMax("player")) * 0.3);
		f.spell.split_bar = {value, value*2};
		super.UpdateBar(self, f, UnitHealthMax("player"));
	end
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
	DB:UpdateTrackerElementGlow(trackerId, elemIdx, DB.GLOW_CONDITION_COUNT, DB.CONDITION_GT_OR_EQ, 60)

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

function HDH_STAGGER_TRACKER:IsHaveData(spec)
	local key = DB:GetTrackerElement(self.id, 1)
	if (STAGGER_KEY) == key then
		return true
	else
		return false
	end
end

function HDH_STAGGER_TRACKER:CreateDummySpell(count)
	local icons =  self.frame.icon
	local ui = self.ui
	local curTime = GetTime()
	local f, spell
	local health_max = UnitHealthMax("player");
	f = icons[1];
	f:SetMouseClickEnabled(false);
	if not f:GetParent() then f:SetParent(self.frame) end
	if f.icon:GetTexture() == nil then
		f.icon:SetTexture(STAGGER_INFO[1].green_texture);
	end
	f:ClearAllPoints()
	spell = {}
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

	f.cd:Hide();
	if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
		f:SetScript("OnUpdate",nil);
		if spell.showValue then
			f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(spell.v1,true));
		else
			f.v1:SetText('')
		end
		local bar
		for i = 1, #f.bar.bar do
			bar = f.bar.bar[i];
			if bar then
				bar:SetMinMaxValues(0,1);
				bar:SetValue(1);
			end
		end
	end
	f.spell = spell
	f.counttext:SetText("100%")
	f.icon:SetAlpha(ui.icon.on_alpha)
	f.border:SetAlpha(ui.icon.on_alpha)
	self:SetGameTooltip(f, false)
	f:Show()
	return 1;
end

function HDH_STAGGER_TRACKER:Update() -- HDH_TRACKER override
	if not self.frame or not self.frame.icon or HDH_TRACKER.ENABLE_MOVE then return end
	local f = self.frame.icon[1]
	local show
	if f and f.spell then
		f.spell.v1 = UnitStagger('player') or 0;
		f.spell.max = UnitHealthMax('player');
		f.spell.count = (f.spell.v1/f.spell.max * 100);
		self:UpdateIcons()
		if f.spell.v1 > 0 then show = true end
	end

	if (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
			and (UnitAffectingCombat("player") or show or self.ui.common.always_show) then
		self:ShowTracker();
	else
		self:HideTracker();
	end
end

function HDH_STAGGER_TRACKER:InitIcons() -- HDH_TRACKER override
	local trackerId = self.id
	local id, name, _, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
	self.aura_filter = aura_filter
	self.aura_caster = aura_caster
	if not id then 
		return 
	end

	local elemKey, elemId, elemName, texture, display, glowType, isValue, isItem, glowCondition, glowValue, splitValues
	local elemSize = DB:GetTrackerElementSize(trackerId)
	local spell 
	local f
	local iconIdx = 0
	local hasEquipItem = false

	self.frame.pointer = {}
	self.frame:UnregisterAllEvents()
	
	self.talentId = GetSpecialization()

	if not self:IsHaveData() then
		self:CreateData()
	end
	if self:IsHaveData() then
		for i = 1 , elemSize do
			elemKey, elemId, elemName, texture, display, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
			glowType, glowCondition, glowValue = DB:GetTrackerElementGlow(trackerId, i)
			splitValues = DB:GetTrackerElementSplitValues(trackerId, i)

			iconIdx = iconIdx + 1
			f = self.frame.icon[iconIdx]
			if f:GetParent() == nil then f:SetParent(self.frame) end
			self.frame.pointer[elemKey or tostring(elemId)] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
			spell = {}
			spell.glow = glowType
			spell.glowCondtion = glowCondition
			spell.glowValue = (glowValue and tonumber(glowValue)) or 0
			spell.showValue = isValue
			spell.display = display
			spell.v1 = 0 -- 수치를 저장할 변수
			spell.aniEnable = true;
			spell.aniTime = 8;
			spell.aniOverSec = false;
			spell.no = i
			spell.name = elemName
			spell.icon = texture
			spell.id = tonumber(elemId)
			spell.count = 0
			spell.duration = 0
			spell.remaining = 0
			spell.overlay = 0
			spell.endTime = 0
			spell.startTime = 0
			spell.is_buff = isBuff;
			spell.isUpdate = false
			spell.isItem =  isItem
			spell.showPer = true;
			spell.max = UnitHealthMax("player");
			if f.bar then
				f.bar.max = UnitHealthMax("player");
				self:UpdateBar(f, f.bar.max);
			end

			spell.splitValues = { spell.max * STAGGER_YELLOW_TRANSITION, spell.max * STAGGER_RED_TRANSITION }
		
			f.cooldown1:Hide()
			f.cooldown2:Hide()
			f.icon:SetTexture(texture)
		
			f.spell = spell
			f:SetScript("OnUpdate", STAGGER_TRACKER_OnUpdate)
			f:Hide();
			self:SetGlow(f, false)
			self:UpdateArtBar(f)
		end
	else
		self.frame:UnregisterAllEvents()
	end
	
	for i = #self.frame.icon, iconIdx+1 , -1 do
		self:ReleaseIcon(i)
	end
	self:Update()
	return iconIdx
end

function HDH_STAGGER_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
	self:InitIcons()
end

function HDH_STAGGER_TRACKER:PLAYER_ENTERING_WORLD()
end

------------------------------------
-- HDH_STAGGER_TRACKER class
------------------------------------