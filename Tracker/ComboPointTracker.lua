HDH_COMBO_POINT_TRACKER = {}
local DB = HDH_AT_ConfigDB
local POWER_INFO = {}

------------------------------------
-- HDH_COMBO_POINT_TRACKER class
------------------------------------
local super = HDH_AURA_TRACKER
setmetatable(HDH_COMBO_POINT_TRACKER, super) -- 상속
HDH_COMBO_POINT_TRACKER.__index = HDH_COMBO_POINT_TRACKER
HDH_COMBO_POINT_TRACKER.className = "HDH_COMBO_POINT_TRACKER"

HDH_TRACKER.TYPE.POWER_COMBO_POINTS = 15
HDH_TRACKER.TYPE.POWER_SOUL_SHARDS = 16
HDH_TRACKER.TYPE.POWER_HOLY_POWER = 17
HDH_TRACKER.TYPE.POWER_CHI = 18

HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_COMBO_POINTS,   HDH_COMBO_POINT_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_SOUL_SHARDS,    HDH_COMBO_POINT_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_HOLY_POWER,     HDH_COMBO_POINT_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_CHI,      		HDH_COMBO_POINT_TRACKER)

POWER_INFO[HDH_TRACKER.TYPE.POWER_COMBO_POINTS] 	= {power_type="COMBO_POINTS", 	power_index = 4,	color={0.77, 0.12, 0.23, 1}, texture = "Interface/Icons/INV_Misc_Gem_Pearl_05"}; -- INV_Misc_Gem_Pearl_04 INV_chaos_orb INV_Misc_Gem_Pearl_04 Spell_AnimaRevendreth_Orb
POWER_INFO[HDH_TRACKER.TYPE.POWER_SOUL_SHARDS]		= {power_type="SOUL_SHARDS",	power_index = 7, 	color={201/255, 34/255, 1, 	 1}, texture = "Interface/Icons/inv_misc_enchantedpearlE"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_HOLY_POWER]		= {power_type="HOLY_POWER", 	power_index = 9,	color={1, 216/255, 47/255, 1}, texture = "Interface/Icons/Spell_Holy_SealOfWrath"}; -- Ability_Priest_SpiritOfTheRedeemer
POWER_INFO[HDH_TRACKER.TYPE.POWER_CHI]				= {power_type="CHI", 			power_index = 12,	color={0, 196/255, 117/255, 1}, texture = "Interface/Icons/INV_Misc_Gem_Pearl_06"};

if select(4, GetBuildInfo()) >= 100000 then
	HDH_TRACKER.TYPE.POWER_ARCANE_CHARGES = 19
	HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_ARCANE_CHARGES, HDH_COMBO_POINT_TRACKER)
	POWER_INFO[HDH_TRACKER.TYPE.POWER_ARCANE_CHARGES]	= {power_type="ARCANE_CHARGES",	power_index = 16,	color={2/255, 60/255, 189/255, 1}, texture = "Interface/Icons/Spell_Nature_WispSplode"};
else
	POWER_INFO[HDH_TRACKER.TYPE.POWER_COMBO_POINTS] 	= {power_type="COMBO_POINTS", 	power_index = 14,	color={0.77, 0.12, 0.23, 1}, texture = "Interface/Icons/INV_Misc_Gem_Pearl_05"};
end

HDH_COMBO_POINT_TRACKER.POWER_INFO = POWER_INFO;

function HDH_COMBO_POINT_TRACKER:CreateData()
	local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
	local trackerId = self.id
	local id = 0
	local key
	local name
	local texture = self.POWER_INFO[self.type].texture;
	local display = DB.SPELL_ALWAYS_DISPLAY
	local isValue = false -- HDH_TRACKER.TYPE.POWER_SOUL_SHARDS == self.type
	local isItem = false
	local isFirstCreated = false
	for elemIdx = 1, power_max do
		if self:GetElementCount(elemIdx) == 0 then
			key = self.POWER_INFO[self.type].power_type .. elemIdx
			name = self.POWER_INFO[self.type].power_type .. elemIdx
			DB:SetTrackerElement(trackerId, elemIdx, key, id, name, texture, display, isValue, isItem)
			DB:UpdateTrackerElementGlow(trackerId, elemIdx, DB.GLOW_CONDITION_VALUE, DB.CONDITION_GT_OR_EQ, power_max, DB.GLOW_EFFECT_COLOR_SPARK, self.POWER_INFO[self.type].color, 2)
			DB:SetReadOnlyTrackerElement(trackerId, elemIdx) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다
			if elemIdx == 1 then
				isFirstCreated = true
			end
		end
	end 

	if isFirstCreated then
		DB:CopyGlobelToTracker(trackerId)
		DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON)
		DB:SetTrackerValue(trackerId, 'ui.%s.common.column_count', 10)
		DB:SetTrackerValue(trackerId, 'ui.%s.common.reverse_h', false)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.width', 40)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.height', 20)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.to_fill', true)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.cooldown_progress', DB.COOLDOWN_RIGHT)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.location', DB.BAR_LOCATION_R)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.texture', 3)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', self.POWER_INFO[self.type].color)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.show_spark', true)
		DB:SetTrackerValue(trackerId, 'ui.%s.font.name_location', DB.FONT_LOCATION_HIDE)
		DB:SetTrackerValue(trackerId, 'ui.%s.icon.size', 40)
		DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', self.POWER_INFO[self.type].color)

		if HDH_TRACKER.TYPE.POWER_SOUL_SHARDS == self.type then
			DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_C)
			DB:SetTrackerValue(trackerId, 'ui.%s.font.count_location', DB.FONT_LOCATION_BAR_R)
			DB:SetTrackerValue(trackerId, 'ui.%s.icon.cooldown', DB.COOLDOWN_RIGHT)
			DB:SetTrackerValue(trackerId, 'ui.%s.bar.use_full_color', true)
			local r,g,b = unpack(self.POWER_INFO[self.type].color)
			DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', {r,g,b, 0.35})
			DB:SetTrackerValue(trackerId, 'ui.%s.bar.full_color', self.POWER_INFO[self.type].color)
		else
			DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_C)
		end
		self:UpdateSetting();
	end
end

function HDH_COMBO_POINT_TRACKER:GetElementCount(index)
	if index then
		local key = DB:GetTrackerElement(self.id, index)
		if (self.POWER_INFO[self.type].power_type .. index) ~= key then
			return 0
		end
		return 1
	else
		for i = 1 , UnitPowerMax('player', self.POWER_INFO[self.type].power_index) do
			local key = DB:GetTrackerElement(self.id, i)
			if (self.POWER_INFO[self.type].power_type .. i) ~= key then
				return 0
			end
		end 
		return DB:GetTrackerElementSize(self.id)
	end
end

function HDH_COMBO_POINT_TRACKER:Release() -- HDH_TRACKER override
	if self and self.frame then
		self.frame:UnregisterAllEvents()
	end
	super.Release(self)
end

function HDH_COMBO_POINT_TRACKER:ReleaseIcon(idx) -- HDH_TRACKER override
	local icon = self.frame.icon[idx]
	icon:Hide()
	icon:SetParent(nil)
	icon.spell = nil
	self.frame.icon[idx] = nil
end

function HDH_COMBO_POINT_TRACKER:CreateDummySpell(count)
	local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
	local iconf
	for i = 1, power_max do
		iconf = self.frame.icon[i]
		if iconf then 
			if not iconf.spell then
				iconf.spell = {}
			end
			iconf:SetParent(self.frame) 
			iconf.spell.duration = 0
			iconf.spell.count = 1
			iconf.spell.remaining = 0
			iconf.spell.startTime = 0
			iconf.spell.endTime = 0
			iconf.spell.key = i
			iconf.spell.id = 0
			iconf.spell.happenTime = 0;
			iconf.spell.no = i
			iconf.spell.name = self.POWER_INFO[self.type].power_type .. i
			iconf.spell.icon = self.POWER_INFO[self.type].texture
			iconf.spell.glow = false
			iconf.spell.glowCount = 0
			iconf.spell.glowV1= 0
			iconf.spell.display = DB.SPELL_ALWAYS_DISPLAY
			iconf.icon:SetTexture(self.POWER_INFO[self.type].texture);
			
			iconf.spell.v1 = power_max - 1
			if (power_max) == i then
				if HDH_TRACKER.TYPE.POWER_SOUL_SHARDS ~= self.type and HDH_TRACKER.TYPE.POWER_ESSENCE ~= self.type then
					iconf.spell.isUpdate = false
				else
					iconf.spell.isUpdate = true
					iconf.spell.count = 0.5
				end
				iconf.spell.v1 = 0
			else
				iconf.spell.isUpdate = true;
			end
		end
	end
	return power_max;
end

function HDH_COMBO_POINT_TRACKER:UpdateBarSettings(f) -- HDH_TRACKER override
	super.UpdateBarSettings(self,f)
	if f.bar then
		f.bar:SetScript("OnUpdate",nil);
	end
end

function HDH_COMBO_POINT_TRACKER:UpdateIconSettings(f)
	super.UpdateIconSettings(self, f)
	local op_icon = self.ui.icon
	f.icon:Setup(op_icon.size, op_icon.size, op_icon.cooldown, true, true, op_icon.spark_color, op_icon.cooldown_bg_color, op_icon.on_alpha, op_icon.off_alpha, op_icon.border_size)
	f.icon:SetHandler(nil, nil)
	f.icon:SetCooldown(0, 1, false)
	f.icon:SetValue(0)
end

function HDH_COMBO_POINT_TRACKER:UpdateAllIcons()  -- HDH_TRACKER override
	local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
	local num_col = self.ui.common.column_count or 10-- 한줄에 몇개의 아이콘 표시
	local reverse_v = self.ui.common.reverse_v -- 상하반전
	local reverse_h = self.ui.common.reverse_h -- 좌우반전
	local margin_h = self.ui.common.margin_h
	local margin_v = self.ui.common.margin_v
	local icons = self.frame.icon
	local i = 0 -- 몇번째로 아이콘을 출력했는가?
	local col = 0  -- 열에 대한 위치 좌표값 = x
	local row = 0  -- 행에 대한 위치 좌표값 = y
	local size_w, size_h

	if self.ui.common.display_mode == DB.DISPLAY_BAR then
		size_w = self.ui.bar.width
		size_h = self.ui.bar.height
	elseif self.ui.common.display_mode == DB.DISPLAY_ICON_AND_BAR then
		if self.ui.bar.location == DB.BAR_LOCATION_R or self.ui.bar.location == DB.BAR_LOCATION_L then
			size_w = self.ui.bar.width + self.ui.icon.size
			size_h = math.max(self.ui.bar.height, self.ui.icon.size)
		else
			size_h = self.ui.bar.height + self.ui.icon.size
			size_w = math.max(self.ui.bar.width, self.ui.icon.size)
		end
		
	else
		size_w = self.ui.icon.size -- 아이콘 간격 띄우는 기본값
		size_h = self.ui.icon.size
	end
	
	for k,f in ipairs(icons) do
		if not f.spell then break end
		f.counttext:SetText(nil)
		if f.spell.isUpdate then
			f.spell.isUpdate = false

			if HDH_TRACKER.TYPE.POWER_SOUL_SHARDS ~= self.type and HDH_TRACKER.TYPE.POWER_ESSENCE ~= self.type then
				f.icon:UpdateCooldowning(false)
				f.v1:SetText((f.spell.showValue and f.spell.v1 >= 1) and f.spell.v1 or "")
				if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
					f.bar:SetValue(1)
				end
				self:UpdateGlow(f, true)
			else
				if f.spell.count < 1.0  then
					if f.counttext:IsShown() and f.spell.count < 1 then
						f.counttext:SetText(string.format('%.1f', f.spell.count))
					else
						f.counttext:SetText("")
					end

					if self.ui.common.display_mode ~= DB.DISPLAY_BAR then
						f.icon:SetValue(f.spell.count)
						-- if f.spell.count > 0 then
						-- 	f.icon:UpdateCooldowning()
						-- else
						-- 	f.icon:UpdateCooldowning(false)
						-- end
						f.icon:UpdateCooldowning()
					end

					if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
						f.bar:SetValue(f.spell.count)
					end
					self:UpdateGlow(f, false)
				else
					if f.counttext:IsShown() and f.spell.count < 1 then
						f.counttext:SetText(string.format('%.1f', f.spell.count))
					else
						f.counttext:SetText("")
					end
					f.icon:UpdateCooldowning(false)
					f.icon:Stop()
					self:UpdateGlow(f, true)

					if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
						f.bar:SetValue(1)
					end
				end

				f.v1:SetText((f.spell.showValue and f.spell.v1 >= 1) and f.spell.v1 or "")
			end
			
			f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
			f:Show()

			i = i + 1
			if i % num_col == 0 then 
				row = row + size_h + margin_v; 
				col = 0
			else 
				col = col + size_w + margin_h 
			end
			ret = ret + 1

		else
			if k <= UnitPowerMax('player', self.POWER_INFO[self.type].power_index) then 
				if f.spell.display == DB.SPELL_ALWAYS_DISPLAY then 
					f.icon:UpdateCooldowning()
					f.icon:Stop()
					f.v1:SetText("")
					f.counttext:SetText("")
					self:UpdateGlow(f, false)
					f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
					f:Show()
					if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
						f.bar:SetValue(0)
					end

					i = i + 1
					if i % num_col == 0 then 
						row = row + size_h + margin_v; 
						col = 0
					else 
						col = col + size_w + margin_h 
					end
				else
					if (f.spell.display == DB.SPELL_HIDE_TIME_OFF_AS_SPACE or f.spell.display == DB.SPELL_HIDE_TIME_ON_AS_SPACE) and self.ui.common.order_by == DB.ORDERBY_REG then
						i = i + 1
						if i % num_col == 0 then 
							row = row + size_h + margin_v
							col = 0
						else 
							col = col + size_w + margin_h
						end
					end
					f:Hide();
				end
			else
				self:ReleaseIcon(k);
			end
		end
	end
	return ret
end

function HDH_COMBO_POINT_TRACKER:Update() -- HDH_TRACKER override
	if not self.frame or not self.frame.icon then return end
	local iconf;
	local spell;
	local ret = 0;
	local power = UnitPower('player', self.POWER_INFO[self.type].power_index, true);
	local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index);

	if not HDH_TRACKER.ENABLE_MOVE then
		if HDH_TRACKER.TYPE.POWER_SOUL_SHARDS == self.type then
			power = power / 10
		end
			
		for i = 1, power_max do
			iconf = self.frame.icon[i]
			if iconf then 
				if not iconf.spell then
					iconf.spell = {}
				end
				if math.ceil(power) >= i then
					iconf.spell.isUpdate = true
					if (power + 1 - i) < 1 then
						iconf.spell.count = power + 1 - i 
					else
						iconf.spell.count = 1
						iconf.spell.v1 = power
					end
				else
					iconf.spell.isUpdate = false
					iconf.spell.v1 = 0
					iconf.spell.count = 0
				end
				ret = ret + 1
			end
		end
	else
		power = power_max - 1
		for i = 1, power_max do
			iconf = self.frame.icon[i]
			if iconf then 
				if not iconf.spell then
					iconf.spell = {}
				end
				if math.ceil(power) >= i then
					iconf.spell.isUpdate = true
				else
					iconf.spell.isUpdate = false
				end
			end
		end
	end
	self:UpdateAllIcons();

	if (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
			and (UnitAffectingCombat("player") or self.ui.common.always_show) then
		self:ShowTracker();
	else
		self:HideTracker();
	end
	return ret;
end

function HDH_COMBO_POINT_TRACKER:InitIcons() -- HDH_TRACKER override
	local ret = super.InitIcons(self)
	local f
	if ret then
		self.power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
		for i = 1, ret do
			f = self.frame.icon[i]
			if f.bar then
				f.bar:SetMinMaxValues(0, 1)
			end
		end
		self.frame:RegisterUnitEvent('UNIT_POWER_UPDATE',"player")
		self.frame:RegisterUnitEvent('UNIT_MAXPOWER',"player")
	end
	return ret
end

-------------------------------------------
-- 이벤트 메세지 function
-------------------------------------------

function HDH_COMBO_POINT_TRACKER:UNIT_POWER_UPDATE()
	if not HDH_TRACKER.ENABLE_MOVE then
		self:Update()
	end
end

function HDH_COMBO_POINT_TRACKER:UNIT_MAXPOWER()
	if not HDH_TRACKER.ENABLE_MOVE then
		self:InitIcons()
	end
end

function HDH_COMBO_POINT_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
	self:InitIcons()
end

function HDH_COMBO_POINT_TRACKER:PLAYER_ENTERING_WORLD()
	if  UnitAffectingCombat("player") then
		self:Update()
	end
end

function HDH_COMBO_POINT_TRACKER:OnEvent(event, unit, powerType)
	local self = self.parent
	if self == nil then return end
	if (event == "UNIT_POWER_UPDATE" ) and (self.POWER_INFO[self.type].power_type == powerType) then 
		self:UNIT_POWER_UPDATE()
	elseif (event == 'UNIT_MAXPOWER') and (self.POWER_INFO[self.type].power_type == powerType) then
		self:UNIT_MAXPOWER()
	end
end
------------------------------------
-- HDH_COMBO_POINT_TRACKER class
------------------------------------

