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

POWER_INFO[HDH_TRACKER.TYPE.POWER_ESSENCE] 	= {power_type="ESSENCE", 	power_index = 19,	color={1.00, 0.50, 0.25}, texture = "Interface\\Icons\\Spell_Deathknight_FrostPresence"};

HDH_ESSENCE_TRACKER.POWER_INFO = POWER_INFO;

local function OnUpdate(self)
	self.spell.curTime = GetTime()
	
	if self.spell.curTime - (self.spell.delay or 0) < 0.02  then return end 
	self.spell.delay = self.spell.curTime
	-- self.spell.count = math.ceil(self.spell.v1 / maxValue * 100);
	-- if self.spell.count == 100 and self.spell.v1 ~= maxValue then self.spell.count = 99 end
	-- self.counttext:SetText(format("%d%", self.spell.count)); 
	-- else self.counttext:SetText(nil) end
	if self.spell.showValue then self.v1:SetText(HDH_AT_UTIL.AbbreviateValue(self.spell.v1)); else self.v1:SetText(nil) end
	
	if self.spell.v1 <= 1.0 then
		self:GetParent().parent:Update();
	end
	
	self:GetParent().parent:SetGlow(self, true);
	self:GetParent().parent:UpdateBarValue(self);
end

function HDH_POWER_TRACKER:UpdateBarValue(f)
	if f.bar and f.bar.bar and #f.bar.bar > 0 then
		local bar;
		for i = 1, #f.bar.bar do 
			bar = f.bar.bar[i];
			-- bar:SetMinMaxValues(bar.mpMin, bar.mpMax);
			if bar then 
				bar:SetValue(self:GetAnimatedValue(bar, f.spell.v1, i)); 
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
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.height', 40)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.reverse_fill', false)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.reverse_progress', false)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.texture', 3)	
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.show_spark', true)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.use_full_color', true)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', {r,g,b, 0.35})
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.full_color', self.POWER_INFO[self.type].color)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.show_name', false)
	-- DB:SetTrackerValue(trackerId, 'ui.%s.font.count_location', DB.FONT_LOCATION_BAR_L)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_BAR_R)
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
	local f = self.frame.icon[1]
	local show = false
	local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
	local power =  UnitPower('player', self.POWER_INFO[self.type].power_index)
	local v1 = UnitPartialPower('player', self.POWER_INFO[self.type].power_index)
	local spell
	v1 = (v1 / 1000.0)
	for i = 1, power_max do
		spell = self.frame.icon[i].spell
		if power < i then
			if spell then
				if v1 ~= nil then
					spell.v1 = v1
					v1 = nil
					spell.isUpdate = true
				else
					spell.v1 = 0
					spell.isUpdate = false
				end
			end
			
		else
			spell.isUpdate = true
			spell.v1 = 1
		end
	end

	self:UpdateIcons();
	if UnitAffectingCombat("player") or power < power_max then
		self:ShowTracker();
	else
		self:HideTracker();
	end
	return ret;
end

function HDH_ESSENCE_TRACKER:InitIcons()
	super.InitIcons(self)
	local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
	for i = 1, power_max do
		spell = self.frame.icon[i]:SetScript("OnUpdate", OnUpdate)
	end
end

function HDH_ESSENCE_TRACKER:PLAYER_ENTERING_WORLD()
end

function HDH_ESSENCE_TRACKER:OnEvent(event, unit, powerType)
	if self == nil or self.parent == nil then return end
	if ((event == 'UNIT_POWER_UPDATE')) and (self.parent.POWER_INFO[self.parent.type].power_type == powerType) then  -- (event == "UNIT_POWER")
		if not HDH_TRACKER.ENABLE_MOVE then
			self.parent:Update()
			-- print("e")
			-- self.parent:UpdateBar(self.parent.frame.icon[1]);
		end
	end
end
------------------------------------
-- HDH_ESSENCE_TRACKER class
------------------------------------
