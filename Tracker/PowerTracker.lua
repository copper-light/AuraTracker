HDH_POWER_TRACKER = {}
local DB = HDH_AT_ConfigDB
------------------------------------
-- HDH_POWER_TRACKER class
------------------------------------

local super = HDH_AURA_TRACKER
setmetatable(HDH_POWER_TRACKER, super) -- 상속
HDH_POWER_TRACKER.__index = HDH_POWER_TRACKER
HDH_POWER_TRACKER.className = "HDH_POWER_TRACKER"

HDH_TRACKER.TYPE.POWER_MANA = 5
HDH_TRACKER.TYPE.POWER_RAGE = 6
HDH_TRACKER.TYPE.POWER_FOCUS = 7
HDH_TRACKER.TYPE.POWER_ENERGY = 8
HDH_TRACKER.TYPE.POWER_RUNIC = 9
HDH_TRACKER.TYPE.POWER_FURY = 13
HDH_TRACKER.TYPE.POWER_PAIN = 14  -- 용군단에서 삭제됨

HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_MANA,      HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_RAGE,      HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_FOCUS,     HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_ENERGY,    HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_RUNIC, 	   HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_FURY,      HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_PAIN,	   HDH_POWER_TRACKER)

local POWER_INFO = {}
POWER_INFO[HDH_TRACKER.TYPE.POWER_MANA]		 	= {power_type="MANA",		 	power_index =0,		color={0.25, 0.78, 0.92, 1}, 	regen=true,  texture = "Interface/Icons/INV_Misc_Rune_03"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_RAGE]			= {power_type="RAGE", 			power_index =1,		color={0.77, 0.12, 0.23, 1}, 	regen=false, texture = "Interface/Icons/Ability_Warrior_Rampage"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_FOCUS] 		= {power_type="FOCUS", 			power_index =2,		color={1.00, 0.50, 0.25, 1}, 	regen=true,  texture = "Interface/Icons/Ability_Fixated_State_Orange"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_ENERGY]		= {power_type="ENERGY",			power_index =3, 	color={1, 0.96, 0.41, 1}, 	  	regen=true,  texture = "Interface/Icons/Spell_Holy_PowerInfusion"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_RUNIC]    	= {power_type="RUNIC_POWER", 	power_index =6,		color={0, 0.82, 1, 1}, 			regen=false,  texture = "Interface/Icons/Spell_DeathKnight_FrozenRuneWeapon"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_FURY] 		= {power_type="FURY",			power_index =17, 	color={0.788, 0.259, 0.992, 1},	regen=false,  texture = "Interface/Icons/Spell_Shadow_SummonVoidWalker"};-- 17
POWER_INFO[HDH_TRACKER.TYPE.POWER_PAIN] 		= {power_type="PAIN",			power_index =18,	color={1, 156/255, 0, 1}, 		regen=false,  texture = "Interface/Icons/Ability_Warlock_FireandBrimstone"}; -- 18

if select(4, GetBuildInfo()) >= 100000 then -- 용군단
	HDH_TRACKER.TYPE.POWER_LUNAR = 10
	HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_LUNAR,	   HDH_POWER_TRACKER)
	POWER_INFO[HDH_TRACKER.TYPE.POWER_LUNAR] 	    = {power_type="LUNAR_POWER",	power_index =8, 	color={0.30, 0.52, 0.90, 1},	regen=false,  texture = "Interface/Icons/Ability_Druid_Eclipse"};

	HDH_TRACKER.TYPE.POWER_MAELSTROM = 11
	HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_MAELSTROM, HDH_POWER_TRACKER)
	POWER_INFO[HDH_TRACKER.TYPE.POWER_MAELSTROM]	= {power_type="MAELSTROM", 		power_index =11,	color={0.25, 0.5, 1, 1},		regen=false,  texture = "Interface/Icons/Spell_Shaman_StaticShock"};

	HDH_TRACKER.TYPE.POWER_INSANITY = 12
	HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_INSANITY,  HDH_POWER_TRACKER)
	POWER_INFO[HDH_TRACKER.TYPE.POWER_INSANITY] 	= {power_type="INSANITY", 		power_index =13,	color={0.70, 0.4, 0.90, 1},	  	regen=false,  texture = "Interface/Icons/SPELL_SHADOW_TWISTEDFAITH"};
end

HDH_POWER_TRACKER.POWER_INFO = POWER_INFO;

local function HDH_POWER_OnUpdate(f, elapsed)
	local self = f:GetParent().parent
	f.spell.curTime = GetTime()
	if f.spell.curTime - (f.spell.delay or 0) < 0.02  then return end 
	f.spell.delay = f.spell.curTime
	f.spell.powerMax = self:GetPowerMax()
	f.spell.v1 = self:GetPower()
	f.spell.count = math.ceil(f.spell.v1 / f.spell.powerMax  * 100);
	if f.spell.count == 100 and f.spell.v1 ~= f.spell.powerMax  then f.spell.count = 99 end
	f.counttext:SetText(f.spell.count .. "%")
	if f.spell.showValue then
		f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(f.spell.v1, self.ui.font.v1_abbreviate))
	else
		f.v1:SetText(nil)
	end

	if self.power_info.regen then
		if f.spell.v1 < f.spell.powerMax  then
			if f.spell.isOn ~= true then
				self:Update()
				f.spell.isOn = true;
			end
		else 
			if f.spell.isOn ~= false then
				self:Update()
				f.spell.isOn = false;
			end
			self:Update()
		end
	else
		if f.spell.v1 > 0 then
			if f.spell.isOn ~= true then
				self:Update()
				f.spell.isOn = true;
			end
		else
			if f.spell.isOn ~= false then
				self:Update()
				f.spell.isOn = false;
			end
		end
	end

	self:UpdateGlow(f, true)
	if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
		if f.bar:GetMaxValue() == f.spell.powerMax then -- UpdateBar 함수안에 UpdateAbsorb 를 포함한다.
			f.bar:SetValue(f.spell.v1, true)
		else
			f.bar:SetMinMaxValues(0, f.spell.powerMax)
			f.bar:SetValue(f.spell.v1, false)
		end
	end
end

function HDH_POWER_TRACKER:GetPower()
	return UnitPower('player', self.power_info.power_index)
end

function HDH_POWER_TRACKER:GetPowerMax()
	return UnitPowerMax('player', self.power_info.power_index)
end

function HDH_POWER_TRACKER:CreateData()
	local trackerId = self.id
	local key = self.power_info.power_type .. '1'
	local id = 0
	local name = self.power_info.power_type
	local texture = self.power_info.texture;
	local display = DB.SPELL_ALWAYS_DISPLAY
	local isValue = true
	local isItem = false

	if DB:GetTrackerElementSize(trackerId) > 0 then
		DB:TrancateTrackerElements(trackerId)
	end
	local elemIdx = DB:AddTrackerElement(trackerId, key, id, name, texture, display, isValue, isItem)
	DB:SetReadOnlyTrackerElement(trackerId, elemIdx) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다

	local maxValue = self:GetPowerMax()

	DB:CopyGlobelToTracker(trackerId)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON_AND_BAR)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.reverse_h', false)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.column_count', 6)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', self.power_info.color)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.use_full_color', false)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.location', DB.BAR_LOCATION_R)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.width', 200)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.height', 20)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.to_fill', true)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.cooldown_progress', DB.COOLDOWN_RIGHT)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.texture', 3)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.name_location', DB.FONT_LOCATION_HIDE)

	if maxValue >= 200 then
		DB:SetTrackerValue(trackerId, 'ui.%s.font.count_location', DB.FONT_LOCATION_BAR_L)
	else
		DB:SetTrackerValue(trackerId, 'ui.%s.font.count_location', DB.FONT_LOCATION_HIDE)
	end

	DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_BAR_R)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_abbreviate', false)

	DB:SetTrackerValue(trackerId, 'ui.%s.icon.size', 20)
	DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', self.power_info.color)
	self:UpdateSetting();
end

function HDH_POWER_TRACKER:GetElementCount()
	local key = DB:GetTrackerElement(self.id, 1)
	if (self.power_info.power_type .. '1') == key then
		return 1
	else
		return 0
	end
end

-- function HDH_POWER_TRACKER:ChangeCooldownType(f, cooldown_type) -- 호출되지 말라고 빈함수
-- end

function HDH_POWER_TRACKER:CreateDummySpell(count)
	local icons =  self.frame.icon
	local ui = self.ui
	local f, spell
	local power_max = self:GetPowerMax()
	f = icons[1];
	f:SetMouseClickEnabled(false);
	if not f:GetParent() then f:SetParent(self.frame) end
	if f.icon:GetTexture() == nil then
		f.icon:SetTexture(self.power_info.texture)
	end
	f:ClearAllPoints()
	spell = f.spell or {}
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
	spell.v1 = power_max
	spell.max = power_max;
	spell.splitValues = f.spell.splitValues
	if ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
		if spell.showValue then
			f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(spell.v1, self.ui.font.v1_abbreviate))
		else
			f.v1:SetText('')
		end
		f.bar:Show()
		self:UpdateBarMinMaxValue(f, 0, 1, 1)
	end
	f.spell = spell
	f.counttext:SetText("100%")
	self:SetGameTooltip(f, false)
	f:Show()
	return 1;
end

function HDH_POWER_TRACKER:Release() -- HDH_TRACKER override
	if self and self.frame then
		self.frame:UnregisterAllEvents()
		self.frame.namePointer = nil
	end
	super.Release(self)
end

function HDH_POWER_TRACKER:ReleaseIcon(idx) -- HDH_TRACKER override
	local icon = self.frame.icon[idx]
	--icon:SetScript("OnEvent", nil)
	icon:Hide()
	icon:SetParent(nil)
	icon.spell = nil
	icon:SetScript("OnUpdate",nil);
	self.frame.icon[idx] = nil
end

function HDH_POWER_TRACKER:Update() -- HDH_TRACKER override
	if not self.frame or not self.frame.icon or HDH_TRACKER.ENABLE_MOVE then return end
	local f = self.frame.icon[1]
	local show = false
	if f and f.spell then
		-- f.spell.type = UnitPowerType('player');
		f.spell.v1 = self:GetPower()
		f.spell.max = self:GetPowerMax()
		f.spell.count = (f.spell.v1/f.spell.max * 100);
		self:UpdateAllIcons()
		if self.power_info and self.power_info.regen then
			if f.spell.max ~= f.spell.v1 and not UnitIsDead("player") then show = true end
		elseif f.spell.v1 > 0 then show = true end
	end

	if (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
			and (HDH_TRACKER.ENABLE_MOVE or UnitAffectingCombat("player") or show or self.ui.common.always_show) then
		self:ShowTracker();
	else
		self:HideTracker();
	end
end

function HDH_POWER_TRACKER:UpdateAllIcons()  -- HDH_TRACKER override
	local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
	local f = self.frame.icon[1]
	if f == nil or f.spell == nil then return end;
	if f.spell.v1 > 0 then 
		-- f.icon:SetDesaturated(nil)
		-- f.icon:SetAlpha(self.ui.icon.on_alpha)
		-- f.border:SetAlpha(self.ui.icon.on_alpha)
		-- f.border:SetVertexColor(unpack(self.ui.icon.active_border_color))
		f.icon:UpdateCooldowning(false)
		ret = 1;
		self:UpdateGlow(f, true)
		f:Show();
	else
		f.icon:UpdateCooldowning(true)
		if f.spell.display == DB.SPELL_ALWAYS_DISPLAY then
			self:UpdateGlow(f, false)
			f:Show();
		else
			f:Hide();
		end
	end
	-- f.icon:SetCooldown(0, f.spell.max, false)
	f:SetPoint('RIGHT');
	return ret
end

function HDH_POWER_TRACKER:UpdateIconSettings(f)
	super.UpdateIconSettings(self, f)
	local op_icon = self.ui.icon
	f.icon:Setup(op_icon.size, op_icon.size, op_icon.cooldown, true, true, op_icon.spark_color, op_icon.cooldown_bg_color, op_icon.on_alpha, op_icon.off_alpha, op_icon.border_size)
	f.icon:SetHandler(nil, nil)
end

function HDH_POWER_TRACKER:InitIcons() -- HDH_TRACKER override
	-- if HDH_TRACKER.ENABLE_MOVE then return end
	local trackerId = self.id
	local id, name, _, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
	self.aura_filter = aura_filter
	self.aura_caster = aura_caster
	if not id then 
		return 
	end
	
 	self.power_info = self.POWER_INFO[self.type]

	local elemKey, elemId, elemName, texture, display, glowType, isValue, isItem, glowCondition, glowValue, splitPoints, splitPointType, glowEffectType, glowEffectColor, glowEffectPerSec
	local elemSize = DB:GetTrackerElementSize(trackerId)
	local spell 
	local f
	local iconIdx = 0
	local hasEquipItem = false

	self.frame.pointer = {}
	self.frame:UnregisterAllEvents()
	self.talentId = HDH_AT_UTIL.GetSpecialization()

	if self:GetElementCount() == 0 then
		self:CreateData()
	end
	if self:GetElementCount() > 0 then
		for i = 1 , elemSize do
			elemKey, elemId, elemName, texture, display, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
			glowType, glowCondition, glowValue, glowEffectType, glowEffectColor, glowEffectPerSec = DB:GetTrackerElementGlow(trackerId, i)
			splitPoints, splitPointType = DB:GetTrackerElementSplitValues(trackerId, i)
			
			iconIdx = iconIdx + 1
			f = self.frame.icon[iconIdx]
			if f:GetParent() == nil then f:SetParent(self.frame) end
			self.frame.pointer[elemKey or tostring(elemId)] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
			spell = {}
			spell.glow = glowType
			spell.glowCondtion = glowCondition
			spell.glowValue = (glowValue and tonumber(glowValue)) or 0
			spell.showValue = isValue
			spell.glowEffectType = glowEffectType
			spell.glowEffectColor = glowEffectColor
			spell.glowEffectPerSec = glowEffectPerSec
			spell.display = display
			spell.v1 = 0 -- 수치를 저장할 변수
			spell.no = i
			spell.name = elemName
			spell.icon = texture
			spell.power_index = self.power_info.power_index
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
			spell.splitPoints = splitPoints or {}
			spell.splitPointType = splitPointType or DB.BAR_SPLIT_RATIO
			f.spell = spell
			f.icon:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")

			f.icon:UpdateCooldowning(false)
			-- f.iconSatCooldown:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
			-- f.iconSatCooldown:SetDesaturated(nil)
			-- f.iconSatCooldown:Hide()
			self:UpdateGlow(f, false)
			
			f:SetScript("OnUpdate", HDH_POWER_OnUpdate);
			f:Hide();
			self:ActionButton_HideOverlayGlow(f)
			if f.bar then
				f.bar:SetSplitPoints(spell.splitPoints, spell.splitPointType)
			end
		end
		self.frame:SetScript("OnEvent", self.OnEvent)
		self.frame:RegisterUnitEvent('UNIT_POWER_UPDATE',"player")
		self:Update()
		
	else
		self.frame:UnregisterAllEvents()
	end
	
	for i = #self.frame.icon, iconIdx+1 , -1 do
		self:ReleaseIcon(i)
	end
	return iconIdx
end

-- function HDH_POWER_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
-- 	self:InitIcons()
-- 	-- self:UpdateBar(self.frame.icon[1]);
-- end

function HDH_POWER_TRACKER:PLAYER_ENTERING_WORLD()
end

function HDH_POWER_TRACKER:OnEvent(event, unit, powerType)
	if self == nil or self.parent == nil then return end
	if ((event == 'UNIT_POWER_UPDATE')) and (self.parent.power_info.power_type == powerType) then  -- (event == "UNIT_POWER")
		if not HDH_TRACKER.ENABLE_MOVE then
			self.parent:Update(powerType)
		end
	end
end
------------------------------------
-- HDH_POWER_TRACKER class
------------------------------------
