HDH_ESSENCE_TRACKER = {}
local DB = HDH_AT_ConfigDB
local POWRE_BAR_SPLIT_MARGIN = 5;
local MyClassKor, MyClass = UnitClass("player");
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

function OnUpdate(self)
	self.spell.curTime = GetTime()
	
	if self.spell.curTime - (self.spell.delay or 0) < HDH_TRACKER.ONUPDATE_FRAME_TERM then return end 
	self.spell.delay = self.spell.curTime
	-- self.spell.count = math.ceil(self.spell.v1 / maxValue * 100);
	-- if self.spell.count == 100 and self.spell.v1 ~= maxValue then self.spell.count = 99 end
	-- self.counttext:SetText(format("%d%", self.spell.count)); 
	-- else self.counttext:SetText(nil) end
	-- if self.spell.showValue then self.v1:SetText(string.format('%.1f', self.spell.v1)); else self.v1:SetText(nil) end
	
	if self.spell.v1 <= 1.0 and self.spell.no == 1 then
		self:GetParent().parent:Update();
	end
	
	self:GetParent().parent:SetGlow(self, true);
	self:GetParent().parent:UpdateBarValue(self);
	
	if self.spell.remaining > 0 then
		-- self.timetext:SetText(string.format('%.1f', self.spell.remaining));
		self:GetParent().parent:UpdateTimeText(self.timetext, self.spell.remaining)
	else
		self.timetext:SetText("");
	end
end

function HDH_ESSENCE_TRACKER:OnUpdateBarValue()
	-- empty
end

function HDH_ESSENCE_TRACKER:UpdateBarValue(f)
	if f.bar then
		f.bar:SetValue(f:GetParent().parent:GetAnimatedValue(f.bar, not f:GetParent().parent.ui.bar.to_fill and 1 - f.spell.v1 or f.spell.v1))
		f:GetParent().parent:MoveSpark(f.bar)
		if f:GetParent().parent.ui.bar.use_full_color then 
			if f.bar:GetValue() == 1 then
				f.bar:SetStatusBarColor(unpack(f:GetParent().parent.ui.bar.full_color))
			else
				f.bar:SetStatusBarColor(unpack(f:GetParent().parent.ui.bar.color))
			end
		end
	end
end

function HDH_ESSENCE_TRACKER:CreateData()
	local trackerId = self.id
	local key = self.POWER_INFO[self.type].power_type
	local id = 0
	local name = self.POWER_INFO[self.type].power_type
	local texture = self.POWER_INFO[self.type].texture;
	local isAlways = true
	local isValue = false
	local isItem = false
	local r,g,b,a = unpack(self.POWER_INFO[self.type].color)
	local max_power = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)

	if DB:GetTrackerElementSize(trackerId) > max_power then
		DB:TrancateTrackerElements(trackerId)
	end

	for i = 1 , max_power do
		local elemIdx = DB:AddTrackerElement(trackerId, key .. i, id, name .. i, texture, isAlways, isValue, isItem)
		DB:SetReadOnlyTrackerElement(trackerId, elemIdx) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다
	end 

	DB:CopyGlobelToTracker(trackerId)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.column_count', 6)
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
	DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_BAR_R)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.cd_color_5s', {1,1,0, 1})
	DB:SetTrackerValue(trackerId, 'ui.%s.font.cd_color', {1,1,0, 1})
	DB:SetTrackerValue(trackerId, 'ui.%s.icon.size', 40)
	DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', self.POWER_INFO[self.type].color)
	DB:SetTrackerValue(trackerId, 'ui.%s.icon.cooldown', DB.COOLDOWN_RIGHT)

	self:UpdateSetting();
end

function HDH_ESSENCE_TRACKER:IsHaveData()
	for i = 1 , UnitPowerMax('player', self.POWER_INFO[self.type].power_index) do
		local key = DB:GetTrackerElement(self.id, i)
		if (self.POWER_INFO[self.type].power_type .. i) ~= key then
			return false
		end
	end 

	return true
end

function HDH_ESSENCE_TRACKER:Update() -- HDH_TRACKER override
	if not self.frame or not self.frame.icon or HDH_TRACKER.ENABLE_MOVE then return end
	local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
	local power =  UnitPower('player', self.POWER_INFO[self.type].power_index)
	local v1 = UnitPartialPower('player', self.POWER_INFO[self.type].power_index)
	local duration, interrupted  = GetPowerRegenForPowerType(self.POWER_INFO[self.type].power_index)
	local spell
	local curTime = GetTime() 
	self.pre_power = self.pre_power or -1
	if (duration == nil or duration == 0) then
		duration = 0.2;
	end
	self.v1 = v1 / 1000.0
	self.duration =  (1 / duration)
	self.new_startTime = (curTime - (self.v1 * self.duration))
	self.gap = math.abs((self.startTime or 0) - self.new_startTime)
	if self.gap >= 0.05 then
		self.startTime = self.new_startTime
		self.endTime = self.startTime + self.duration	
	end
	self.remaining = (self.endTime or 0) - curTime

	for i = 1, power_max do
		spell = self.frame.icon[i].spell
		if power < i then
			if spell then
				if (power + 1) == i then
					spell.duration = self.duration
					spell.startTime = self.startTime 
					spell.endTime = self.endTime
					spell.remaining = self.remaining
					spell.v1 = self.v1-- 1 - (spell.remaining / spell.duration)
					spell.isUpdate = true
					spell.count = 0
				else
					spell.duration = 0
					spell.v1 = 0
					spell.remaining = 0
					spell.count = 0
					spell.startTime = 0
					spell.isUpdate = false
				end
			end
			
		else
			spell.isUpdate = true
			spell.duration = 0
			spell.v1 = 1
			spell.count = i
			spell.remaining = 0
			spell.startTime = 0
		end
	end

	self:UpdateIcons();
	if UnitAffectingCombat("player") or power < power_max or self.ui.common.always_show then
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
	return ret;
end

function HDH_ESSENCE_TRACKER:InitIcons()
	super.InitIcons(self)
	local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
	for i = 1, power_max do
		self.frame.icon[i]:SetScript("OnUpdate", OnUpdate)
	end
end

function HDH_ESSENCE_TRACKER:PLAYER_ENTERING_WORLD()
end

function HDH_ESSENCE_TRACKER:OnEvent(event, unit, powerType)
	if self == nil or self.parent == nil then return end
	if ((event == 'UNIT_POWER_UPDATE')) and (self.parent.POWER_INFO[self.parent.type].power_type == powerType) then  -- (event == "UNIT_POWER")
		if not HDH_TRACKER.ENABLE_MOVE then
			-- self.parent:Update()
			-- print("e")
			-- self.parent:UpdateBar(self.parent.frame.icon[1]);
		end
	end
end
------------------------------------
-- HDH_ESSENCE_TRACKER class
------------------------------------
