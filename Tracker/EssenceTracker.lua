if select(4, GetBuildInfo()) <= 100205 then return end

HDH_ESSENCE_TRACKER = {}
local DB = HDH_AT_ConfigDB
local POWER_INFO = {}

------------------------------------
-- HDH_ESSENCE_TRACKER class
------------------------------------

local super = HDH_COMBO_POINT_TRACKER
setmetatable(HDH_ESSENCE_TRACKER, super) -- 상속
HDH_ESSENCE_TRACKER.__index = HDH_ESSENCE_TRACKER
HDH_ESSENCE_TRACKER.className = "HDH_ESSENCE_TRACKER"

HDH_TRACKER.TYPE.POWER_ESSENCE = 21
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_ESSENCE, HDH_ESSENCE_TRACKER)

POWER_INFO[HDH_TRACKER.TYPE.POWER_ESSENCE] 	= {power_type="ESSENCE", 	power_index = 19,	color={5/255, 189/255, 194/255, 1}, texture = "Interface/Icons/ability_evoker_powernexus"};

HDH_ESSENCE_TRACKER.POWER_INFO = POWER_INFO;

local function OnUpdate(self)
	self.spell.curTime = GetTime()
	
	if self.spell.curTime - (self.spell.delay or 0) < HDH_TRACKER.ONUPDATE_FRAME_TERM then return end 
	self.spell.delay = self.spell.curTime
	
	if self.spell.count <= 1.0 and self.spell.no == 1 then
		self:GetParent().parent:Update();
	end
	
	self:GetParent().parent:UpdateGlow(self, true);

	if self.bar then
		self.bar:SetMinMaxValues(0, 1)
		self.bar:SetValue(self.spell.count)
	end
	
	if self.spell.remaining > 0 then
		self:GetParent().parent:UpdateTimeText(self.timetext, self.spell.remaining)
	else
		self.timetext:SetText("");
	end
end

-- function HDH_ESSENCE_TRACKER:OnUpdateBarValue()
-- 	-- empty
-- end

-- function HDH_ESSENCE_TRACKER:UpdateBarValue(f)
-- 	if f.bar then
-- 		f.bar:SetValue(f:GetParent().parent:GetAnimatedValue(f.bar, not f:GetParent().parent.ui.bar.to_fill and 1 - f.spell.v1 or f.spell.v1))
-- 		f:GetParent().parent:MoveSpark(f.bar)
-- 		if f:GetParent().parent.ui.bar.use_full_color then 
-- 			if f.bar:GetValue() == 1 then
-- 				f.bar:SetStatusBarColor(unpack(f:GetParent().parent.ui.bar.full_color))
-- 			else
-- 				f.bar:SetStatusBarColor(unpack(f:GetParent().parent.ui.bar.color))
-- 			end
-- 		end
-- 	end
-- end

function HDH_ESSENCE_TRACKER:GetEssenceFillingProgress(index)
	if EssencePlayerFrame.classResourceButtonTable[index] then 
		return EssencePlayerFrame.classResourceButtonTable[index].EssenceFilling.FillingAnim:GetProgress()
	else
		return 0
	end
end

function HDH_ESSENCE_TRACKER:IsEssenceFull(index)
	local f = EssencePlayerFrame.classResourceButtonTable[index]
	if f then
		return f.EssenceFull:IsShown()
	else
		return false
	end
end

function HDH_ESSENCE_TRACKER:IsEssenceFilling(index)
	local f = EssencePlayerFrame.classResourceButtonTable[index]
	if f then
		return f.EssenceFilling.FillingAnim:IsPlaying() or f.EssenceDepleting.AnimIn:IsPlaying()
	else
		return false
	end
end


function HDH_ESSENCE_TRACKER:CreateData()
	local trackerId = self.id
	local key = self.POWER_INFO[self.type].power_type
	local id = 0
	local name = self.POWER_INFO[self.type].power_type
	local texture = self.POWER_INFO[self.type].texture;
	local display = DB.SPELL_ALWAYS_DISPLAY
	local isValue = false
	local isItem = false
	local r,g,b,a = unpack(self.POWER_INFO[self.type].color)
	local max_power = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
	local isFirstCreated = false
	if DB:GetTrackerElementSize(trackerId) > max_power then
		DB:TrancateTrackerElements(trackerId)
	end

	for i = 1 , max_power do
		if self:GetElementCount(i) == 0 then
			DB:AddTrackerElement(trackerId, key .. i, id, name .. i, texture, display, isValue, isItem)
			DB:UpdateTrackerElementGlow(trackerId, i, DB.GLOW_CONDITION_VALUE, DB.CONDITION_GT_OR_EQ, max_power, DB.GLOW_EFFECT_COLOR_SPARK, self.POWER_INFO[self.type].color, 2)
			DB:SetReadOnlyTrackerElement(trackerId, i) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다
			if i == i then
				isFirstCreated = true
			end
		end
	end 

	if isFirstCreated then
		DB:CopyGlobelToTracker(trackerId)
		DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON)
		DB:SetTrackerValue(trackerId, 'ui.%s.common.column_count', 6)
		DB:SetTrackerValue(trackerId, 'ui.%s.common.reverse_h', false)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.width', 40)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.height', 20)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.to_fill', true)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.cooldown_progress', DB.COOLDOWN_RIGHT)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.texture', 3)	
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.show_spark', true)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.use_full_color', true)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', {r,g,b, 0.35})
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.full_color', self.POWER_INFO[self.type].color)
		DB:SetTrackerValue(trackerId, 'ui.%s.font.name_location', DB.FONT_LOCATION_HIDE)
		DB:SetTrackerValue(trackerId, 'ui.%s.font.cd_location', DB.FONT_LOCATION_TR)
		DB:SetTrackerValue(trackerId, 'ui.%s.font.cd_format', DB.TIME_TYPE_CEIL)
		DB:SetTrackerValue(trackerId, 'ui.%s.font.count_location', DB.FONT_LOCATION_HIDE)
		DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_C)
		DB:SetTrackerValue(trackerId, 'ui.%s.font.cd_color_5s', {1,1,0, 1})
		DB:SetTrackerValue(trackerId, 'ui.%s.font.cd_color', {1,1,0, 1})
		DB:SetTrackerValue(trackerId, 'ui.%s.icon.size', 40)
		DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', self.POWER_INFO[self.type].color)
		DB:SetTrackerValue(trackerId, 'ui.%s.icon.cooldown', DB.COOLDOWN_RIGHT)
		self:UpdateSetting();
	end
end

function HDH_ESSENCE_TRACKER:GetElementCount(index)
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

function HDH_ESSENCE_TRACKER:Update() -- HDH_TRACKER override
	if not self.frame or not self.frame.icon or HDH_TRACKER.ENABLE_MOVE then return end
	local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
	local power =  UnitPower('player', self.POWER_INFO[self.type].power_index)
	local partPower = UnitPartialPower('player', self.POWER_INFO[self.type].power_index)
	local powerTick, _  = GetPowerRegenForPowerType(self.POWER_INFO[self.type].power_index)
	local progress = self:GetEssenceFillingProgress(power + 1) 
	local spell
	local curTime = GetTime() 
	if (powerTick == nil or powerTick == 0) then
		powerTick = 0.2;
	end
	if not self:IsEssenceFilling(power + 1) and progress == 0 then
		self.remaining = 0
	else
		self.remaining = (1 - progress) / powerTick
	end
	powerTick = powerTick * ((curTime - (self.curTime or (curTime - 0.01))) / 1)
	
	for i = 1, power_max do
		spell = self.frame.icon[i].spell
		if not spell then break end
		if power >= i then
			spell.isUpdate = true
			spell.duration = 0
			spell.count = 1
			spell.v1 = power
			spell.remaining = 0
			spell.startTime = 0
			spell.endTime = 0
		else
			if (power + 1) == i then
				spell.duration = self.duration
				spell.startTime = self.startTime 
				spell.endTime = self.endTime
				spell.remaining = self.remaining
				if self.power ~= power then
					spell.count = progress
				else
					spell.count = spell.count + powerTick
				end
				spell.isUpdate = true
				spell.v1 = 0
			else
				spell.duration = 0
				spell.count = 0
				spell.remaining = 0
				spell.v1 = 0
				spell.startTime = 0
				spell.endTime = 0
				spell.isUpdate = false
			end
		end
	end
	self.power = power
	self.curTime = curTime

	self:UpdateAllIcons()
	if (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
			and (UnitAffectingCombat("player") or power < power_max or self.ui.common.always_show) then
		self:ShowTracker();
		local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
		for i = 1, power_max do
			self.frame.icon[i]:SetScript("OnUpdate", OnUpdate)
		end
	else
		self:HideTracker();
		local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
		for i = 1, power_max do
			self.frame.icon[i]:SetScript("OnUpdate", nil)
		end
	end

	return power
end

function HDH_ESSENCE_TRACKER:InitIcons()
	local ret = HDH_TRACKER.InitIcons(self)
	for i = 1, ret do
		self.frame.icon[i]:SetScript("OnUpdate", OnUpdate)
	end
end

------------------------------------
-- HDH_ESSENCE_TRACKER class
------------------------------------

function HDH_ESSENCE_TRACKER:UNIT_POWER_UPDATE()
	if not HDH_TRACKER.ENABLE_MOVE then
		self.power = nil
		self:Update()
	end
end
