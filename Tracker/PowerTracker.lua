CT_VERSION = 0.1
HDH_POWER_TRACKER = {}

local DB = HDH_AT_ConfigDB

local POWRE_BAR_SPLIT_MARGIN = 4;

local MyClassKor, MyClass = UnitClass("player");

-- local POWRE_NAME = {}
-- local L_POWER_MANA = "자원:마나";
-- local L_POWER_RAGE = "자원:분노"
-- local L_POWER_FOCUS = "자원:집중"
-- local L_POWER_ENERGY = "자원:기력"
-- local L_POWER_RUNIC_POWER = "자원:룬마력"
-- local L_POWER_LUNAR_POWER = "자원:천공의힘"
-- local L_POWER_MAELSTROM = "자원:소용돌이"
-- local L_POWER_INSANITY = "자원:광기"
-- local L_POWER_FURY = "자원:격노"
-- local L_POWER_PAIN = "자원:고통"

local POWER_INFO = {}
local IS_REGEN_POWER = {} -- 자동으로 리젠되는 자원인가? 비전투중일때 자원바를 보이게 할것인가 판단하는 기준이됨
IS_REGEN_POWER[0] = true; -- 마나
IS_REGEN_POWER[2] = true; -- 집중
IS_REGEN_POWER[3] = true; -- 기력

-- HDH_POWER["MANA"]		 = {tracker_name="자원:마나", 	color={0.25, 0.78, 0.92}, 	texture = "Interface/Icons/INV_Misc_Rune_03"};
-- HDH_POWER["RAGE"]		 = {tracker_name="자원:분노", 	color={0.77, 0.12, 0.23}, 	texture = "Interface/Icons/Ability_Warrior_Rampage"};
-- HDH_POWER["FOCUS"] 		 = {tracker_name="자원:집중", 	color={1.00, 0.50, 0.25}, 	texture = "Interface/Icons/Ability_Fixated_State_Orange"};
-- HDH_POWER["ENERGY"]		 = {tracker_name="자원:기력", 	color={1, 0.96, 0.41}, 	  	texture = "Interface/Icons/Ability_Priest_SpiritOfTheRedeemer"};
-- HDH_POWER["RUNIC_POWER"] = {tracker_name="자원:룬마력", 	color={0.77, 0.12, 0.23}, 	texture = "Interface/Icons/Spell_DeathKnight_FrozenRuneWeapon"};
-- HDH_POWER["LUNAR_POWER"] = {tracker_name="자원:천공의힘", 	color={0.30, 0.52, 0.90},	texture = "Interface/Icons/Spell_Nature_AbolishMagic"};
-- HDH_POWER["MAELSTROM"]	 = {tracker_name="자원:소용돌이", 	color={0.25, 0.78, 0.92},	texture = "Interface/Icons/Spell_Lightning_LightningBolt01"};
-- HDH_POWER["INSANITY"] 	 = {tracker_name="자원:광기", 	color={0.40, 0, 0.80},	  	texture = "Interface/Icons/Ability_Rogue_EnvelopingShadows"};
-- HDH_POWER["FURY"] 		 = {tracker_name="자원:격노", 	color={0.788, 0.259, 0.992},texture = "Interface/Icons/Ability_BossFelOrcs_Necromancer_Purple"};-- 17
-- HDH_POWER["PAIN"] 		 = {tracker_name="자원:고통",		color={1, 156/255, 0}, 		texture = "Interface/Icons/Ability_BossFelOrcs_Necromancer_Purple"}; -- 18


-- else TrackerTypeName[1] = "2차 자원(콤보)"; end

-- local POWER_MANA	 	= {power_type="MANA",		 	power_index =0,		color={0.25, 0.78, 0.92}, 		texture = "Interface/Icons/INV_Misc_Rune_03"};
-- local POWER_RAGE		= {power_type="RAGE", 			power_index =1,		color={0.77, 0.12, 0.23}, 		texture = "Interface/Icons/Ability_Warrior_Rampage"};
-- local POWER_FOCUS 		= {power_type="FOCUS", 			power_index =2,		color={1.00, 0.50, 0.25}, 		texture = "Interface/Icons/Ability_Fixated_State_Orange"};
-- local POWER_ENERGY		= {power_type="ENERGY",			power_index =3, 	color={1, 0.96, 0.41}, 	  		texture = "Interface/Icons/Spell_Holy_PowerInfusion"};
-- local POWER_RUNIC_POWER	= {power_type="RUNIC_POWER", 	power_index =6,		color={0, 0.82, 1}, 			texture = "Interface/Icons/Spell_DeathKnight_FrozenRuneWeapon"};
-- local POWER_LUNAR_POWER = {power_type="LUNAR_POWER",	power_index =8, 	color={0.30, 0.52, 0.90},		texture = "Interface/Icons/Ability_Druid_Eclipse"};
-- local POWER_MAELSTROM	= {power_type="MAELSTROM", 		power_index =11,	color={0.25, 0.5, 1},			texture = "Interface/Icons/Spell_Shaman_StaticShock"};
-- local POWER_INSANITY 	= {power_type="INSANITY", 		power_index =13,	color={0.70, 0.4, 0.90},	  	texture = "Interface/Icons/SPELL_SHADOW_TWISTEDFAITH"};
-- local POWER_FURY  		= {power_type="FURY",			power_index =17, 	color={0.788, 0.259, 0.992},	texture = "Interface/Icons/Spell_Shadow_SummonVoidWalker"};-- 17
-- local POWER_PAIN 		= {power_type="PAIN",			power_index =18,	color={1, 156/255, 0}, 			texture = "Interface/Icons/Ability_Warlock_FireandBrimstone"}; -- 18

-- local SPEC_INFO = {}
-- HDH_POWER_TRACKER.SPEC_INFO[62] = POWER_MANA-- Mage: Arcane
-- HDH_POWER_TRACKER.SPEC_INFO[63] = POWER_MANA -- Mage: Fire
-- HDH_POWER_TRACKER.SPEC_INFO[64] = POWER_MANA-- Mage: Frost

-- HDH_POWER_TRACKER.SPEC_INFO[65] = POWER_MANA-- Paladin: Holy
-- HDH_POWER_TRACKER.SPEC_INFO[66] = POWER_MANA-- Paladin: Protection
-- HDH_POWER_TRACKER.SPEC_INFO[70] = POWER_MANA-- Paladin: Retribution

-- HDH_POWER_TRACKER.SPEC_INFO[71] = POWER_RAGE-- Warrior: Arms
-- HDH_POWER_TRACKER.SPEC_INFO[72] = POWER_RAGE-- Warrior: Fury
-- HDH_POWER_TRACKER.SPEC_INFO[73] = POWER_RAGE-- Warrior: Protection

-- HDH_POWER_TRACKER.SPEC_INFO[102] = POWER_LUNAR_POWER -- Druid: Balance
-- HDH_POWER_TRACKER.SPEC_INFO[103] = POWER_ENERGY -- Druid: Feral
-- HDH_POWER_TRACKER.SPEC_INFO[104] = {TYPE = "RAGE", INDEX=1, TEXTURE="" } -- Druid: Guardian
-- HDH_POWER_TRACKER.SPEC_INFO[105] = {TYPE = "MANA", INDEX=0, TEXTURE="" } -- Druid: Restoration

-- HDH_POWER_TRACKER.SPEC_INFO[250] = {TYPE = "RUNIC_POWER", INDEX=6, TEXTURE="" }-- Death Knight: Blood
-- HDH_POWER_TRACKER.SPEC_INFO[251] = {TYPE = "RUNIC_POWER", INDEX=6, TEXTURE="" }-- Death Knight: Frost
-- HDH_POWER_TRACKER.SPEC_INFO[252] = {TYPE = "RUNIC_POWER", INDEX=6, TEXTURE="" }-- Death Knight: Unholy

-- HDH_POWER_TRACKER.SPEC_INFO[253] = {TYPE = "FOCUS", INDEX=2, TEXTURE="" }-- Hunter: Beast Mastery
-- HDH_POWER_TRACKER.SPEC_INFO[254] = {TYPE = "FOCUS", INDEX=2, TEXTURE="" }-- Hunter: Marksmanship
-- HDH_POWER_TRACKER.SPEC_INFO[255] = {TYPE = "FOCUS", INDEX=2, TEXTURE="" }-- Hunter: Survival

-- HDH_POWER_TRACKER.SPEC_INFO[256] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Priest: Discipline
-- HDH_POWER_TRACKER.SPEC_INFO[257] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Priest: Holy
-- HDH_POWER_TRACKER.SPEC_INFO[258] = {TYPE = "INSANITY", INDEX=13, TEXTURE="" }-- Priest: Shadow

-- HDH_POWER_TRACKER.SPEC_INFO[259] = {TYPE = "ENERGY", INDEX=3, TEXTURE="" }-- Rogue: Assassination
-- HDH_POWER_TRACKER.SPEC_INFO[260] = {TYPE = "ENERGY", INDEX=3, TEXTURE="" }-- Rogue: Combat
-- HDH_POWER_TRACKER.SPEC_INFO[261] = {TYPE = "ENERGY", INDEX=3, TEXTURE="" }-- Rogue: Subtlety

-- HDH_POWER_TRACKER.SPEC_INFO[262] = {TYPE = "MAELSTROM", INDEX=11, TEXTURE="" }-- Shaman: Elemental
-- HDH_POWER_TRACKER.SPEC_INFO[263] = {TYPE = "MAELSTROM", INDEX=11, TEXTURE="" }-- Shaman: Enhancement
-- HDH_POWER_TRACKER.SPEC_INFO[264] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Shaman: Restoration

-- HDH_POWER_TRACKER.SPEC_INFO[265] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Warlock: Affliction
-- HDH_POWER_TRACKER.SPEC_INFO[266] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Warlock: Demonology
-- HDH_POWER_TRACKER.SPEC_INFO[267] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Warlock: Destruction

-- HDH_POWER_TRACKER.SPEC_INFO[268] = {TYPE = "ENERGY", INDEX=3, TEXTURE="" }-- Monk: Brewmaster
-- HDH_POWER_TRACKER.SPEC_INFO[269] = {TYPE = "ENERGY", INDEX=3, TEXTURE="" }-- Monk: Windwalker
-- HDH_POWER_TRACKER.SPEC_INFO[270] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Monk: Mistweaver

-- HDH_POWER_TRACKER.SPEC_INFO[577] = {TYPE = "FURY", INDEX=17, TEXTURE="" }-- Demon Hunter: Havoc
-- HDH_POWER_TRACKER.SPEC_INFO[581] = {TYPE = "PAIN", INDEX=18, TEXTURE="" }-- Demon Hunter: Vengeance

-- HDH_POWER_TRACKER.HDH_POWER_INDEX, HDH_POWER_TRACKER.HDH_POWER_NAME

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
HDH_TRACKER.TYPE.POWER_LUNAR = 10
HDH_TRACKER.TYPE.POWER_MAELSTROM = 11
HDH_TRACKER.TYPE.POWER_INSANITY = 12
HDH_TRACKER.TYPE.POWER_FURY = 13
HDH_TRACKER.TYPE.POWER_PAIN = 14  -- 용군단에서 삭제됨

HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_MANA,      HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_RAGE,      HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_FOCUS,     HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_ENERGY,    HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_RUNIC, 	   HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_LUNAR,	   HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_MAELSTROM, HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_INSANITY,  HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_FURY,      HDH_POWER_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_PAIN,	   HDH_POWER_TRACKER)

POWER_INFO[HDH_TRACKER.TYPE.POWER_MANA]		 	= {power_type="MANA",		 	power_index =0,		color={0.25, 0.78, 0.92, 1}, 	texture = "Interface/Icons/INV_Misc_Rune_03"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_RAGE]			= {power_type="RAGE", 			power_index =1,		color={0.77, 0.12, 0.23, 1}, 	texture = "Interface/Icons/Ability_Warrior_Rampage"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_FOCUS] 		= {power_type="FOCUS", 			power_index =2,		color={1.00, 0.50, 0.25, 1}, 	texture = "Interface/Icons/Ability_Fixated_State_Orange"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_ENERGY]		= {power_type="ENERGY",			power_index =3, 	color={1, 0.96, 0.41, 1}, 	  	texture = "Interface/Icons/Spell_Holy_PowerInfusion"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_RUNIC]    	= {power_type="RUNIC_POWER", 	power_index =6,		color={0, 0.82, 1, 1}, 			texture = "Interface/Icons/Spell_DeathKnight_FrozenRuneWeapon"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_LUNAR] 	    = {power_type="LUNAR_POWER",	power_index =8, 	color={0.30, 0.52, 0.90, 1},	texture = "Interface/Icons/Ability_Druid_Eclipse"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_MAELSTROM]	= {power_type="MAELSTROM", 		power_index =11,	color={0.25, 0.5, 1, 1},		texture = "Interface/Icons/Spell_Shaman_StaticShock"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_INSANITY] 	= {power_type="INSANITY", 		power_index =13,	color={0.70, 0.4, 0.90, 1},	  	texture = "Interface/Icons/SPELL_SHADOW_TWISTEDFAITH"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_FURY] 		= {power_type="FURY",			power_index =17, 	color={0.788, 0.259, 0.992, 1},	texture = "Interface/Icons/Spell_Shadow_SummonVoidWalker"};-- 17
POWER_INFO[HDH_TRACKER.TYPE.POWER_PAIN] 		= {power_type="PAIN",			power_index =18,	color={1, 156/255, 0, 1}, 		texture = "Interface/Icons/Ability_Warlock_FireandBrimstone"}; -- 18
HDH_POWER_TRACKER.POWER_INFO = POWER_INFO;

local function HDH_POWER_OnUpdate(self)
	self.spell.curTime = GetTime()
	
	if self.spell.curTime - (self.spell.delay or 0) < 0.02  then return end 
	self.spell.delay = self.spell.curTime
	local curValue = UnitPower('player', self.spell.power_index);
	local maxValue = UnitPowerMax('player', self.spell.power_index);
	self.spell.v1 = curValue;
	self.spell.count = math.ceil(self.spell.v1 / maxValue * 100);
	-- if self.spell.count == 100 and self.spell.v1 ~= maxValue then self.spell.count = 99 end
	self.counttext:SetText(self.spell.count .. "%"); 
	-- else self.counttext:SetText(nil) end
	if self.spell.showValue then 
		self.v1:SetText(HDH_AT_UTIL.AbbreviateValue(self.spell.v1, self:GetParent().parent.ui.font.v1_abbreviate)); 
	else 
		self.v1:SetText(nil) 
	end
	
	if IS_REGEN_POWER[self.spell.power_index] then
		if self.spell.v1 < maxValue then
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
	else
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
	end
	
	self:GetParent().parent:SetGlow(self, true);
	self:GetParent().parent:UpdateBarValue(self);
end

function HDH_POWER_TRACKER:UpdateBarValue(f, non_animate)
	if f.bar and f.bar.bar and #f.bar.bar > 0 then
		local bar;
		for i = 1, #f.bar.bar do 
			bar = f.bar.bar[i];
			-- bar:SetMinMaxValues(bar.mpMin, bar.mpMax);
			if bar then
				if self.ui.bar.to_fill then
					bar.v1 = f.spell.v1
				else
					bar.v1 = bar.mpMax - f.spell.v1 + bar.mpMin
				end
				if non_animate then
					bar:SetValue(bar.v1); 
				else
					bar:SetValue(self:GetAnimatedValue(bar, bar.v1, i)); 
				end
				-- bar:SetValue(f.spell.v1); 
				if f:GetParent().parent.ui.bar.use_full_color then
					if f.spell.v1 >= (bar.mpMax) then
						bar:SetStatusBarColor(unpack(f:GetParent().parent.ui.bar.full_color));
					else
						bar:SetStatusBarColor(unpack(f:GetParent().parent.ui.bar.color));
					end
				end
				self:MoveSpark(bar)
			end
		end
	end
end


function HDH_POWER_TRACKER:CreateData()
	local trackerId = self.id
	local key = POWER_INFO[self.type].power_type .. '1'
	local id = 0
	local name = POWER_INFO[self.type].power_type
	local texture = POWER_INFO[self.type].texture;
	local isAlways = true
	local isValue = true
	local isItem = false

	if DB:GetTrackerElementSize(trackerId) > 0 then
		DB:TrancateTrackerElements(trackerId)
	end
	local elemIdx = DB:AddTrackerElement(trackerId, key, id, name, texture, isAlways, isValue, isItem)
	DB:SetReadOnlyTrackerElement(trackerId, elemIdx) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다

	local maxValue = UnitPowerMax('player', POWER_INFO[self.type].power_index)

	DB:CopyGlobelToTracker(trackerId)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON_AND_BAR)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.reverse_h', false)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.column_count', 6)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', POWER_INFO[self.type].color)
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
	DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', POWER_INFO[self.type].color)
	self:UpdateSetting();
end

function HDH_POWER_TRACKER:IsHaveData()
	local key = DB:GetTrackerElement(self.id, 1)
	if (POWER_INFO[self.type].power_type .. '1') == key then
		return true
	else
		return false
	end
end

function HDH_POWER_TRACKER:ChangeCooldownType(f, cooldown_type) -- 호출되지 말라고 빈함수
end

function HDH_POWER_TRACKER:CreateDummySpell(count)
	local icons =  self.frame.icon
	local ui = self.ui
	local curTime = GetTime()
	local f, spell
	local power_max = UnitPowerMax("player", POWER_INFO[self.type].power_index);
	f = icons[1];
	f:SetMouseClickEnabled(false);
	if not f:GetParent() then f:SetParent(self.frame) end
	if f.icon:GetTexture() == nil then
		f.icon:SetTexture(POWER_INFO[self.type].texture);
	end
	f:ClearAllPoints()
	spell = {}
	spell.always = true
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
	f.cd:Hide();
	if ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
		f:SetScript("OnUpdate",nil);
		-- f.bar:SetMinMaxValues(0, power_max);
		-- f.bar:SetValue(spell.v1);
		if spell.showValue then
			f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(spell.v1, self.ui.font.v1_abbreviate))
		else
			f.v1:SetText('')
		end
		-- f.bar:Show();
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

-- function HDH_POWER_TRACKER:UpdateSetting() -- HDH_TRACKER override
-- 	super.UpdateSetting(self)
-- end

function HDH_POWER_TRACKER:UpdateArtBar(f) -- HDH_TRACKER override
	local ui = self.ui
	local hide_icon = ui.common.display_mode == DB.DISPLAY_BAR
	if ui.common.display_mode ~= DB.DISPLAY_ICON then
		if (f.bar and f.bar:GetObjectType() ~= "Frame") then
			f.bar:Hide();
			f.bar:SetParent(nil);
			f.bar = nil;
		end
		if not f.bar then
			f.bar = CreateFrame("Frame", nil, f);
			f.bar.bg = f.bar
			f.bar.margin = POWRE_BAR_SPLIT_MARGIN;--------------------------------------------- margin
		end
		if hide_icon then f.iconframe:Hide();
		else f.iconframe:Show(); end
		self:UpdateBar(f);
	else
		if f.bar then f.bar:Hide(); end
		f.iconframe:Show();
	end
end

-- barMax: 다른 클래스에서 호환성을 위해서 추가 파워트래킹에서는 사용안함
function HDH_POWER_TRACKER:UpdateBar(f, barMax, value) 
	local bar_op = self.ui.bar;
	local hide_icon = self.ui.common.display_mode == DB.DISPLAY_BAR
	if not self:IsHaveData() or not f.bar then return end
	local bf = f.bar;
	local split = (f.spell and f.spell.splitValues) or {}
	local nextIsNill = false;
	bf.max = barMax or UnitPowerMax("player", POWER_INFO[self.type].power_index);
	self.max = bf.max;
	-- print(self.max)
	-- 무결성 체크
	for i = 1, #split do
		if nextIsNill then 
			split[i] = nil 
		else
			if not split[i] or  split[i] > bf.max then
				split[i] = nil;
				nextIsNill = true;
			end
			if split[i] and (split[i] > (split[i+1] or bf.max)) then
				split[i+1] = nil;
				nextIsNill = true;
			end
		end
	end
	
	if bf.bar == nil then bf.bar = {} end
	bf:ClearAllPoints();
	if bar_op.location == DB.BAR_LOCATION_T then
		bf:SetPoint("BOTTOM",f, hide_icon and "BOTTOM" or "TOP",0, 0); 
	elseif bar_op.location == DB.BAR_LOCATION_B then 
		bf:SetPoint("TOP",f, hide_icon and "TOP" or "BOTTOM",0, 0); 
	elseif bar_op.location == DB.BAR_LOCATION_L then 
		bf:SetPoint("RIGHT",f, hide_icon and "RIGHT" or "LEFT", 0, 0); 
	else
		bf:SetPoint("LEFT",f, hide_icon and "LEFT" or "RIGHT", 0, 0); 
	end
	bf:SetSize(bar_op.width, bar_op.height);
	
	local cnt = (#split == 0) and 1 or (#split +1);
	local bar
	for i = 1, cnt do
		if bf.bar[i] == nil then
			local newBar = CreateFrame("StatusBar",nil,bf);
			newBar.background = newBar:CreateTexture(nil,"BACKGROUND");
			newBar.background:SetPoint('TOPLEFT', newBar, 'TOPLEFT', -1, 1)
			newBar.background:SetPoint('BOTTOMRIGHT', newBar, 'BOTTOMRIGHT', 1, -1)
			newBar.background:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg");
			newBar.spark = newBar:CreateTexture(nil, "OVERLAY");
			newBar.spark:SetBlendMode("ADD");
			bf.bar[i] = newBar;
			if i== 1 and not f.name then f.name = newBar:CreateFontString(nil,"OVERLAY"); end
		end 
		bar = bf.bar[i]
		
		local powerMax = bf.max
		bar.mpMax = split[i] or powerMax;
		bar.mpMin = split[i-1] or 0;
		
		local gap = bar.mpMax - bar.mpMin;
		-- bar:SetValue(value or 0)
		bar:SetMinMaxValues(bar.mpMin, bar.mpMax);
		bar:SetStatusBarColor(unpack(bar_op.color));
		bar.spark:SetVertexColor(unpack(bar_op.spark_color or {1,1,1,1}))
		bar.background:SetVertexColor(unpack(bar_op.bg_color));
		
		bar:ClearAllPoints();
		if bar_op.cooldown_progress == DB.COOLDOWN_LEFT then
			local w = ( bf:GetWidth() - (self.ui.common.margin_h * #split) ) * (gap/powerMax);
			bar:SetSize(w - 2, bf:GetHeight() - 2);
			if i == 1 then 
				bar:SetPoint("RIGHT", -1, 0)
			elseif i == cnt then
				bar:SetPoint("LEFT", 1, 0)
				bar:SetPoint("RIGHT", bf.bar[i-1], "LEFT", -self.ui.common.margin_h - 2, 0)
			else
				bar:SetPoint("RIGHT", bf.bar[i-1], "LEFT", -self.ui.common.margin_h - 2, 0)
			end
			bar:SetStatusBarTexture(DB.BAR_TEXTURE[bar_op.texture].texture); 
			bar:SetOrientation("Horizontal"); 
			bar:SetRotatesTexture(false);
			bar.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark");
			bar.spark:SetSize(19, bar_op.height*1.15);
			
			if bar_op.to_fill then
				bar:SetReverseFill(true)
			else
				bar:SetReverseFill(false)
			end
			
		elseif bar_op.cooldown_progress == DB.COOLDOWN_RIGHT then
			local w = ( bf:GetWidth() - (self.ui.common.margin_h * #split) ) * (gap/powerMax);
			bar:SetSize(w - 2, bf:GetHeight() - 2);

			if i == 1 then 
				bar:SetPoint("LEFT", 1, 0)
			elseif i == cnt then
				bar:SetPoint("RIGHT", -1, 0)
				bar:SetPoint("LEFT", bf.bar[i-1], "RIGHT", self.ui.common.margin_h + 2, 0)
			else
				bar:SetPoint("LEFT", bf.bar[i-1], "RIGHT", self.ui.common.margin_h + 2, 0)
			end
			bar:SetStatusBarTexture(DB.BAR_TEXTURE[bar_op.texture].texture); 
			bar:SetOrientation("Horizontal"); 
			bar:SetRotatesTexture(false);
			bar.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark");
			bar.spark:SetSize(19, bar_op.height*1.15);
			
			if bar_op.to_fill then
				bar:SetReverseFill(false)
			else
				bar:SetReverseFill(true)
			end

		elseif bar_op.cooldown_progress == DB.COOLDOWN_UP then
			local h = ( bf:GetHeight() - (self.ui.common.margin_v * #split) ) * (gap/powerMax);
			bar:SetSize(bf:GetWidth() - 2, h - 2);
			if i == 1 then 
				bar:SetPoint("BOTTOM", 0, 1)
			elseif i == cnt then
				bar:SetPoint("TOP", 0, -1)
				bar:SetPoint("BOTTOM", bf.bar[i-1], "TOP", 0, self.ui.common.margin_v + 2)
			else
				bar:SetPoint("BOTTOM", bf.bar[i-1], "TOP", 0, self.ui.common.margin_v + 2)
			end
			bar:SetStatusBarTexture(DB.BAR_TEXTURE[bar_op.texture].texture_r); 
			bar:SetOrientation("Vertical"); 
			bar:SetRotatesTexture(true);
			bar.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v");
			bar.spark:SetSize(bar_op.width*1.15, 19);
			if bar_op.to_fill then
				bar:SetReverseFill(false)
			else
				bar:SetReverseFill(true)
			end
			

		else -- bottom
			local h = ( bf:GetHeight() - (self.ui.common.margin_v * #split) ) * (gap/powerMax);
			bar:SetSize(bf:GetWidth() - 2, h - 2);
			if i == 1 then 
				bar:SetPoint("TOP", 0, -1)
			elseif i == cnt then
				bar:SetPoint("BOTTOM", 0, 1)
				bar:SetPoint("TOP", bf.bar[i-1], "BOTTOM", 0, -self.ui.common.margin_v - 2)
			else
				bar:SetPoint("TOP", bf.bar[i-1], "BOTTOM", 0, -self.ui.common.margin_v - 2)
			end
			bar:SetStatusBarTexture(DB.BAR_TEXTURE[bar_op.texture].texture_r); 
			bar:SetOrientation("Vertical"); 
			bar:SetRotatesTexture(true);
			bar.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v");
			bar.spark:SetSize(bar_op.width*1.15, 19);
			if bar_op.to_fill then
				bar:SetReverseFill(true)
			else
				bar:SetReverseFill(false)
			end
		end

		if bar_op.show_spark then
			bar.spark:Show();
		else
			bar.spark:Hide();
		end
		
		bar:Show();
	end
	
	for i = cnt+1, #bf.bar do
		bf.bar[i]:Hide();
		bf.bar[i]:SetParent(nil);
		bf.bar[i] = nil;
	end
	bf.cnt = cnt;
	bf:Show();
end

function HDH_POWER_TRACKER:UpdateIcons()  -- HDH_TRACKER override
	local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
	local f = self.frame.icon[1]
	if f == nil or f.spell == nil then return end;
	if f.spell.v1 > 0 then 
		f.icon:SetDesaturated(nil)
		f.icon:SetAlpha(self.ui.icon.on_alpha)
		f.border:SetAlpha(self.ui.icon.on_alpha)
		f.border:SetVertexColor(unpack(self.ui.icon.active_border_color)) 
		ret = 1;
		self:SetGlow(f, true)
		f:Show();
		if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
			self:UpdateBarValue(f);
			f.bar:Show();
			-- f.name:SetText(f.spell.name);
		end
	else
		if f.spell.always then
			f.icon:SetDesaturated(1)
			f.icon:SetAlpha(self.ui.icon.off_alpha)
			f.border:SetAlpha(self.ui.icon.off_alpha)
			f.border:SetVertexColor(0,0,0)
			self:SetGlow(f, false)
			f:Show();
		else
			f:Hide();
		end
	end
	f:SetPoint('RIGHT');
	return ret
end

function HDH_POWER_TRACKER:Update() -- HDH_TRACKER override
	if not self.frame or not self.frame.icon or HDH_TRACKER.ENABLE_MOVE then return end
	local f = self.frame.icon[1]
	local show = false
	if f and f.spell then
		-- f.spell.type = UnitPowerType('player');
		f.spell.v1 = UnitPower('player', f.spell.power_index);
		f.spell.max = UnitPowerMax('player', f.spell.power_index);
		f.spell.count = (f.spell.v1/f.spell.max * 100);
		self:UpdateIcons()
		if IS_REGEN_POWER[f.spell.power_index] then
			if f.spell.max ~= f.spell.v1 then show = true end
		elseif f.spell.v1 > 0 then show = true end
	end

	if (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
			and (HDH_TRACKER.ENABLE_MOVE or UnitAffectingCombat("player") or show or self.ui.common.always_show) then
		self:ShowTracker();
	else
		self:HideTracker();
	end
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
	
	local elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem, glowCondition, glowValue, splitValues
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
			elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
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
			spell.always = isAlways
			spell.v1 = 0 -- 수치를 저장할 변수
			spell.aniEnable = true;
			spell.aniTime = 8;
			spell.aniOverSec = false;
			spell.no = i
			spell.name = elemName
			spell.icon = texture
			spell.power_index = POWER_INFO[self.type].power_index
			-- if not auraList[i].defaultImg then auraList[i].defaultImg = texture; 
			-- elseif auraList[i].defaultImg ~= auraList[i].texture then spell.fix_icon = true end
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
			spell.splitValues = splitValues or {}
			f.spell = spell
			f.icon:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
			f.iconSatCooldown:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
			f.iconSatCooldown:SetDesaturated(nil)
			self:ChangeCooldownType(f, self.ui.icon.cooldown)
			self:SetGlow(f, false)
			self:UpdateArtBar(f)
			f:SetScript("OnUpdate", HDH_POWER_OnUpdate);
			f:Hide();
			self:ActionButton_HideOverlayGlow(f)
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
	if ((event == 'UNIT_POWER_UPDATE')) and (POWER_INFO[self.parent.type].power_type == powerType) then  -- (event == "UNIT_POWER")
		if not HDH_TRACKER.ENABLE_MOVE then
			self.parent:Update(powerType)
		end
	end
end
------------------------------------
-- HDH_POWER_TRACKER class
------------------------------------
