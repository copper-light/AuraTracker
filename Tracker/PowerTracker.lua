CT_VERSION = 0.1
HDH_POWER_TRACKER = {}

local DB = HDH_AT_ConfigDB

local POWRE_BAR_SPLIT_MARGIN = 4;

local MyClassKor, MyClass = UnitClass("player");



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
	self = f:GetParent().parent
	f.spell.curTime = GetTime()
	
	if f.spell.curTime - (f.spell.delay or 0) < 0.02  then return end 
	f.spell.delay = f.spell.curTime
	local curValue = self:GetPower()
	local maxValue = self:GetPowerMax()
	f.spell.v1 = curValue;
	f.spell.count = math.ceil(f.spell.v1 / maxValue * 100);
	if f.spell.count == 100 and f.spell.v1 ~= maxValue then f.spell.count = 99 end
	f.counttext:SetText(f.spell.count .. "%"); 
	-- else self.counttext:SetText(nil) end
	if f.spell.showValue then 
		f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(f.spell.v1, self.ui.font.v1_abbreviate)); 
	else 
		f.v1:SetText(nil) 
	end

	if self.power_info.regen then
		if f.spell.v1 < maxValue then
			if f.spell.isOn ~= true then
				self:Update();
				f.spell.isOn = true;
			end
		else 
			if f.spell.isOn ~= false then
				self:Update();
				f.spell.isOn = false;
			end
			self:Update();
		end
	else
		if f.spell.v1 > 0 then
			if f.spell.isOn ~= true then
				self:Update();
				f.spell.isOn = true;
			end
		else
			if f.spell.isOn ~= false then
				self:Update();
				f.spell.isOn = false;
			end
		end
	end

	if self.max == maxValue then -- UpdateBar 함수안에 UpdateAbsorb 를 포함한다.
		self:UpdateGlow(f, true);
		self:UpdateBarValue(f, elapsed);
	else
		self:UpdateBar(f, maxValue);
		self:UpdateGlow(f, true);
		self:UpdateBarValue(f, elapsed, true);
	end
end

function HDH_POWER_TRACKER:UpdateBarValue(f, elapsed, non_animate)
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

function HDH_POWER_TRACKER:GetPower()
	return UnitPower('player', self.power_info.power_index);
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

function HDH_POWER_TRACKER:IsHaveData()
	local key = DB:GetTrackerElement(self.id, 1)
	if (self.power_info.power_type .. '1') == key then
		return true
	else
		return false
	end
end

-- function HDH_POWER_TRACKER:ChangeCooldownType(f, cooldown_type) -- 호출되지 말라고 빈함수
-- end

function HDH_POWER_TRACKER:CreateDummySpell(count)
	local icons =  self.frame.icon
	local ui = self.ui
	local curTime = GetTime()
	local f, spell
	local power_max = self:GetPowerMax()
	f = icons[1];
	f:SetMouseClickEnabled(false);
	if not f:GetParent() then f:SetParent(self.frame) end
	if f.icon:GetTexture() == nil then
		f.icon:SetTexture(self.power_info.texture);
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
		if self.power_info.regen then
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
	bf.max = barMax or self:GetPowerMax()
	self.max = bf.max;
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
			local newBar = CreateFrame("StatusBar", nil, bf);
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
			bar.spark:SetSize(9, bar_op.height);
			
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
			bar.spark:SetSize(9, bar_op.height);
			
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
			bar.spark:SetSize(bar_op.width, 9);
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
			bar.spark:SetSize(bar_op.width, 9);
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
		bar:SetStatusBarColor(unpack(bar_op.color));
	end
	
	for i = cnt+1, #bf.bar do
		bf.bar[i]:Hide();
		bf.bar[i]:SetParent(nil);
		bf.bar[i] = nil;
	end
	bf.cnt = cnt;
	bf:Show();
end

function HDH_POWER_TRACKER:UpdateAllIcons()  -- HDH_TRACKER override
	local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
	local f = self.frame.icon[1]
	if f == nil or f.spell == nil then return end;
	if f.spell.v1 > 0 then 
		f.icon:SetDesaturated(nil)
		f.icon:SetAlpha(self.ui.icon.on_alpha)
		f.border:SetAlpha(self.ui.icon.on_alpha)
		f.border:SetVertexColor(unpack(self.ui.icon.active_border_color)) 
		ret = 1;
		self:UpdateGlow(f, true)
		f:Show();
		if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
			self:UpdateBarValue(f);
			f.bar:Show();
			-- f.name:SetText(f.spell.name);
		end
	else
		if f.spell.display == DB.SPELL_ALWAYS_DISPLAY then
			f.icon:SetDesaturated(1)
			f.icon:SetAlpha(self.ui.icon.off_alpha)
			f.border:SetAlpha(self.ui.icon.off_alpha)
			f.border:SetVertexColor(0,0,0)
			self:UpdateGlow(f, false)
			f:Show();
		else
			f:Hide();
		end
	end
	f:SetPoint('RIGHT');
	return ret
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

	local elemKey, elemId, elemName, texture, display, glowType, isValue, isItem, glowCondition, glowValue, splitValues
	local elemSize = DB:GetTrackerElementSize(trackerId)
	local spell 
	local f
	local iconIdx = 0
	local hasEquipItem = false

	self.frame.pointer = {}
	self.frame:UnregisterAllEvents()
	
	self.talentId = HDH_AT_UTIL.GetSpecialization()

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
			spell.power_index = self.power_info.power_index
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
			self:UpdateGlow(f, false)
			
			f:SetScript("OnUpdate", HDH_POWER_OnUpdate);
			f:Hide();
			self:ActionButton_HideOverlayGlow(f)
			self:UpdateArtBar(f)
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
