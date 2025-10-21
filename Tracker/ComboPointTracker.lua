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
-- else
-- 	POWER_INFO[HDH_TRACKER.TYPE.POWER_COMBO_POINTS] 	= {power_type="COMBO_POINTS", 	power_index = 14,	color={0.77, 0.12, 0.23, 1}, texture = "Interface/Icons/INV_Misc_Gem_Pearl_05"};
end

HDH_COMBO_POINT_TRACKER.POWER_INFO = POWER_INFO

if HDH_AT.LE <= HDH_AT.LE_MISTS then
	-- UnitPower를 사용해서 정보를 불러올때, 도적 콤보 포인트가 오리지날에서는 딜레이가 있음
	-- GetComboPoints 는 즉시 값을 가져오기 때문에 도적 콤보 포인트는 이 함수를 사용하도록 함
	function HDH_COMBO_POINT_TRACKER:GetPower()
		if self.POWER_INFO[self.type].power_index == 4 then
			return GetComboPoints("player", "target")
		else
			return UnitPower('player', self.POWER_INFO[self.type].power_index, true)
		end
	end
else
	function HDH_COMBO_POINT_TRACKER:GetPower()
		return UnitPower('player', self.POWER_INFO[self.type].power_index, true)
	end
end


function HDH_COMBO_POINT_TRACKER:GetPowerMax()
	return UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
end

function HDH_COMBO_POINT_TRACKER:CreateData()
	local power_max = self:GetPowerMax()
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
			DB:UpdateTrackerElementGlow(trackerId, elemIdx, DB.GLOW_CONDITION_VALUE, DB.CONDITION_GT_OR_EQ, power_max, DB.GLOW_EFFECT_COLOR_SPARK, 
				{
					self.POWER_INFO[self.type].color[1],
					self.POWER_INFO[self.type].color[2],
					self.POWER_INFO[self.type].color[3],
					0.25
				}, 
				2)
			DB:SetTrackerElementBarInfo(trackerId, elemIdx, DB.BAR_TYPE_BY_COUNT , DB.BAR_MAX_TYPE_MANUAL, 1, {}, DB.BAR_SPLIT_RATIO)
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
		for i = 1 , self:GetPowerMax() do
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

function HDH_COMBO_POINT_TRACKER:CreateDummySpell(count)
	local iconf
	local power_max = self:GetPowerMax()
	local power = power_max - 1
	local key = self.POWER_INFO[self.type].power_type

	for i = 1, power_max do
		iconf = self.frame.pointer[key .. i]
		
		if iconf then 
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
			
			iconf.spell.v1 = power

			if (power_max) == i then
				if HDH_TRACKER.TYPE.POWER_SOUL_SHARDS ~= self.type and HDH_TRACKER.TYPE.POWER_ESSENCE ~= self.type then
					iconf.spell.isUpdate = true
				else
					iconf.spell.isUpdate = false
					iconf.spell.count = 0.5
				end
				iconf.spell.v1 = 0
			else
				iconf.spell.isUpdate = false;
			end
		end
	end

	for i = 1, power_max do
		iconf = self.frame.pointer[key .. i]
		if iconf then 
			if not iconf.spell then
				iconf.spell = {}
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

-- isUpdate 에 관하여
-- isUpdate의 개념은 아이콘이 쿨다운이 도는 중을 의미함
-- 콤보에서는 콤보 포인트가 채워졌을때, 쿨다운이 돌지 않는 상황임
-- 즉, 콤보를 포인트가 있는 아이콘이 isUpdate == false 인 상황인 것임
-- coolodwn tracker 와 동일한 의미이므로 혼동하지 말것
function HDH_COMBO_POINT_TRACKER:UpdateSpellInfo(index)
	local iconf;
	local ret = 0;
	local power = self:GetPower()
	local power_max = self:GetPowerMax()
	local key = self.POWER_INFO[self.type].power_type

	if HDH_TRACKER.TYPE.POWER_SOUL_SHARDS == self.type then
		power = power / 10
	end
	
	for i = 1, power_max do
		iconf = self.frame.pointer[key .. i]
		if iconf then 
			if math.ceil(power) >= i then
				iconf.spell.isUpdate = false
				if (power + 1 - i) < 1 then
					iconf.spell.count = power + 1 - i 
				else
					iconf.spell.count = 1
					iconf.spell.v1 = power
				end
			else
				iconf.spell.isUpdate = true
				iconf.spell.v1 = 0
				iconf.spell.count = 0
			end
			iconf.spell.countMax = 1
			iconf.spell.valueMax = power_max
			ret = ret + 1
		end
	end
end

-- f.v1:SetText((f.spell.showValue and f.spell.v1 >= 1) and k or "")
-- 수치 표시 시 활성화된 아이콘의 순서 번호가 표시되도록 수정
-- 합계로 표시하는 것이 더 직관적이지만, 기존 사용자들의 혼란을 막기 위해 순서 번호로 표시하도록 함
-- 내부적으로는 합계로 반짝임 처리함
function HDH_COMBO_POINT_TRACKER:UpdateIconAndBar(index)
	local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
	local icons = self.frame.icon

	for k,f in ipairs(icons) do
		if not f.spell then break end
		if f.spell.isUpdate then
			if k <= self:GetPowerMax() then
				if self.ui.common.display_mode ~= DB.DISPLAY_BAR then
					f.icon:UpdateCooldowning()
					f.icon:Stop()
				end
				f.v1:SetText("")
				f.counttext:SetText("")
				self:UpdateGlow(f, false)
				if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
					self:UpdateBarValue(f)
				end
			else
				self:ReleaseIcon(k);
			end
		else
			if HDH_TRACKER.TYPE.POWER_SOUL_SHARDS ~= self.type and HDH_TRACKER.TYPE.POWER_ESSENCE ~= self.type then
				f.icon:UpdateCooldowning(false)
				f.v1:SetText((f.spell.showValue and f.spell.v1 >= 1) and f.spell.v1 or "")
				if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
					-- f.bar:SetValue(1)
					self:UpdateBarValue(f)
				end
				self:UpdateGlow(f, true)
				f.counttext:SetText(nil)

				f.v1:SetText((f.spell.showValue and f.spell.v1 >= 1) and k or "")
			else
				if f.spell.count < 1.0  then
					if self.ui.common.display_mode ~= DB.DISPLAY_BAR then
						f.icon:SetValue(f.spell.count)
						f.icon:UpdateCooldowning()
						self:UpdateGlow(f, false)
					end
				else
					if self.ui.common.display_mode ~= DB.DISPLAY_BAR then
						f.icon:UpdateCooldowning(false)
						f.icon:Stop()
						self:UpdateGlow(f, true)
					end
				end
				if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
					self:UpdateBarValue(f)
				end

				if f.counttext:IsShown() and f.spell.count < 1 then
					f.counttext:SetText(string.format('%.1f', f.spell.count))
				else
					f.counttext:SetText("")
				end

				f.v1:SetText((f.spell.showValue and f.spell.count == 1 and f.spell.v1 >= 1) and k or "")
			end
		end
	end
	return ret
end

-- 콤보 포인트가 2~3 이 기본으로 충전되는 것들이 있어서 최종 확인 하고 기본값이 트래커 사라짐 옵션 활성화 필요
-- 단, 판다리아 버전과 호환될수 있도록 구현할 필요 있음
function HDH_COMBO_POINT_TRACKER:UpdateLayout()
	super.UpdateLayout(self)
	return 0
end

function HDH_COMBO_POINT_TRACKER:InitIcons() -- HDH_TRACKER override
	local ret = HDH_TRACKER.InitIcons(self)
	if ret > 0 then
		for i = 1, ret do
			if self.frame.icon[i] then
				self.frame.icon[i].spell.countMax = 1
				self.frame.icon[i].spell.valueMax = self:GetPowerMax()
			end
		end
		self.frame:RegisterUnitEvent('UNIT_POWER_UPDATE', "player")
		self.frame:RegisterUnitEvent('UNIT_MAXPOWER', "player")

		if HDH_AT.LE <= HDH_AT.LE_MISTS then
			self.frame:RegisterEvent('PLAYER_TARGET_CHANGED')
		end

		self:Update()
	end
	return ret
end

-------------------------------------------
-- 이벤트 메세지 function
-------------------------------------------

function HDH_COMBO_POINT_TRACKER:UNIT_POWER_UPDATE()
	self:Update()
end

function HDH_COMBO_POINT_TRACKER:UNIT_MAXPOWER()
	self:InitIcons()
end

function HDH_COMBO_POINT_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
	self:InitIcons()
end

function HDH_COMBO_POINT_TRACKER:PLAYER_ENTERING_WORLD()
	if UnitAffectingCombat("player") then
		self:Update()
	end
end

function HDH_COMBO_POINT_TRACKER:OnEvent(event, unit, powerType)
	local self = self.parent
	
	if ((event == "UNIT_POWER_UPDATE") and (self.POWER_INFO[self.type].power_type == powerType)) or (event == "PLAYER_TARGET_CHANGED" ) then
		self:UNIT_POWER_UPDATE()
	elseif (event == 'UNIT_MAXPOWER') and (self.POWER_INFO[self.type].power_type == powerType) then
		self:UNIT_MAXPOWER()
	end
end
------------------------------------
-- HDH_COMBO_POINT_TRACKER class
------------------------------------

