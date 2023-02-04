HDH_STAGGER_TRACKER = {}
local DB = HDH_AT_ConfigDB
local STAGGER_KEY = "STAGGER"
local STAGGER_RED_TRANSITION = _G.STAGGER_RED_TRANSITION   -- wow global var : 0.6
local STAGGER_YELLOW_TRANSITION = _G.STAGGER_YELLOW_TRANSITION -- wow global var : 0.3
local info = PowerBarColor[STAGGER_KEY]
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

local function STAGGER_TRACKER_OnUpdate(self)
	self.spell.curTime = GetTime()
	
	if self.spell.curTime - (self.spell.delay or 0) < HDH_TRACKER.BAR_UP_ANI_TERM then return end 
	self.spell.delay = self.spell.curTime
	local curValue = UnitStagger('player') or 0;
	local health_max = UnitHealthMax("player");
	local per = curValue/health_max;
	-- print(self.spell.v1 ,curValue)
	-- if (tonumber(self.v1:GetText()) or 0) == curValue then return; end
	self.spell.v1 = curValue;
	self.spell.count = (per * 100)
	self.counttext:SetText(format("%d%%", math.ceil(self.spell.count or 0))); 
	
	if per > STAGGER_RED_TRANSITION then
		self.icon:SetTexture(HDH_STAGGER_TRACKER.POWER_INFO[3].texture);
	elseif per > STAGGER_YELLOW_TRANSITION then
		self.icon:SetTexture(HDH_STAGGER_TRACKER.POWER_INFO[2].texture);
	else
		self.icon:SetTexture(HDH_STAGGER_TRACKER.POWER_INFO[1].texture);
	end
	
	if self.spell.showValue then self.v1:SetText(HDH_AT_UTIL.AbbreviateValue(self.spell.v1, self:GetParent().parent.ui.font.v1_abbreviate)); else self.v1:SetText(nil) end
	
	-- if self.bar then self.bar:SetValue(self.spell.v1); end
	
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
			-- local gap = self.bar.bar[i].mpMax - self.bar.bar[i].mpMin;
			self.bar.bar[i]:SetMinMaxValues(self.bar.bar[i].mpMin, self.bar.bar[i].mpMax);
		end
		self:GetParent().parent:UpdateBarValue(self, true);	
	else
		self:GetParent().parent:UpdateBarValue(self, false);
	end
	self:GetParent().parent:SetGlow(self, true);
end

-- STAGGER_YELLOW_TRANSITION = .30
-- STAGGER_RED_TRANSITION = .60
-- function HDH_STAGGER_TRACKER:UpdateBarValue(f)
	-- if f.bar and #f.bar.bar > 0 then
		-- local bar;
		-- for i = 1, #f.bar.bar do 
			-- bar = f.bar.bar[i];
			-- if bar then 
				-- bar:SetValue(self:GetAnimatedValue(bar,f.spell.v1,i)); 
				-- if f:GetParent().parent.option.bar.use_full_color then
					-- if f.spell.v1 >= (bar.mpMax) then
						-- bar:SetStatusBarColor(unpack(f:GetParent().parent.option.bar.full_color));
					-- else
						-- bar:SetStatusBarColor(unpack(f:GetParent().parent.option.bar.color));
					-- end
				-- end
				-- if self.option.bar.show_spark then
					-- if bar:GetValue() >= bar.mpMax then value = 1; if bar.spark:IsShown() then bar.spark:Hide(); end
					-- elseif bar:GetValue()<= bar.mpMin then value = 0; if bar.spark:IsShown() then bar.spark:Hide(); end
					-- else
						-- value = (bar:GetValue()-bar.mpMin)/(bar.mpMax - bar.mpMin);
						-- if not bar.spark:IsShown() then bar.spark:Show(); end
					-- end
					-- if bar:GetOrientation() == "HORIZONTAL" then
						-- if self.option.bar.reverse_progress then
							-- bar.spark:SetPoint("CENTER", bar,"RIGHT", -bar:GetWidth() * value, 0);
						-- else
							-- bar.spark:SetPoint("CENTER", bar,"LEFT", bar:GetWidth() * value, 0);
						-- end
					-- else
						-- if self.option.bar.reverse_progress then
							-- bar.spark:SetPoint("CENTER", bar,"TOP", 0, -bar:GetHeight() * value);
						-- else
							-- bar.spark:SetPoint("CENTER", bar,"BOTTOM", 0, bar:GetHeight() * value);
						-- end
					-- end
				-- end
			-- end
		-- end
	-- end
-- end

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
	local isAlways = true
	local isValue = true
	local isItem = false

	if DB:GetTrackerElementSize(trackerId) > 0 then
		DB:TrancateTrackerElements(trackerId)
	end
	local elemIdx = DB:AddTrackerElement(trackerId, key, id, name, texture, isAlways, isValue, isItem)
	DB:SetReadOnlyTrackerElement(trackerId, elemIdx) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다
	DB:UpdateTrackerElementGlow(trackerId, elemIdx, DB.GLOW_CONDITION_COUNT, DB.CONDITION_GT, 59)

	DB:CopyGlobelToTracker(trackerId)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON_AND_BAR)
	-- DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', HDH_STAGGER_TRACKER.POWER_INFO[self.type].color)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.use_full_color', true)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.location', DB.BAR_LOCATION_R)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.width', 200)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.height', 20)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.reverse_fill', false)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.reverse_progress', false)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.texture', 3)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', HDH_STAGGER_TRACKER.POWER_INFO[1].color)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.full_color', HDH_STAGGER_TRACKER.POWER_INFO[3].color)

	DB:SetTrackerValue(trackerId, 'ui.%s.font.show_name', false)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.count_location', DB.FONT_LOCATION_BAR_L)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_BAR_R)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_abbreviate', false)

	DB:SetTrackerValue(trackerId, 'ui.%s.icon.size', 30)
	DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', {0, 0, 0, 1})
	-- DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', HDH_STAGGER_TRACKER.POWER_INFO[self.type].color)
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
	spell.always = true
	spell.id = 0
	spell.count = 100
	spell.duration = 0
	spell.happenTime = 0;
	spell.glow = false
	spell.endTime = 0
	spell.startTime = 0
	spell.remaining = 0
	spell.showValue = true
	spell.v1 = health_max
	spell.max = health_max;
	spell.splitValues = f.spell.splitValues

	f.cd:Hide();
	if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
		f:SetScript("OnUpdate",nil);
		-- f.bar:SetMinMaxValues(0, power_max);
		-- f.bar:SetValue(spell.v1);
		f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(spell.v1,true));
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

-- function HDH_STAGGER_TRACKER:UpdateIcons()  -- HDH_TRACKER override
	-- local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
	-- local f = self.frame.icon[1]
	-- if f == nil or f.spell == nil then return end;
	-- if f.spell.v1 > 0 then 
		-- f.icon:SetDesaturated(nil)
		-- f.icon:SetAlpha(self.option.icon.on_alpha)
		-- f.border:SetAlpha(self.option.icon.on_alpha)
		-- f.border:SetVertexColor(unpack(self.option.icon.buff_color)) 
		-- ret = 1;
		-- self:SetGlow(f, true)
		-- f:Show();
		-- if self.option.bar.enable and f.bar then
			-- self:UpdateBarValue(f);
			-- f.bar:Show();
		-- end
	-- else
		-- if f.spell.always then
			-- f.icon:SetDesaturated(1)
			-- f.icon:SetAlpha(self.option.icon.off_alpha)
			-- f.border:SetAlpha(self.option.icon.off_alpha)
			-- f.border:SetVertexColor(0,0,0)
			-- self:SetGlow(f, false)
			-- f:Show();
		-- else
			-- f:Hide();
		-- end
	-- end
	-- f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', 0, 0);
	-- return ret
-- end

function HDH_STAGGER_TRACKER:Update() -- HDH_TRACKER override
	if not self.frame or not self.frame.icon or HDH_TRACKER.ENABLE_MOVE then return end
	local f = self.frame.icon[1]
	local show
	if f and f.spell then
		-- f.spell.type = UnitPowerType('player');
		f.spell.v1 = UnitStagger('player') or 0;
		f.spell.max = UnitHealthMax('player');
		f.spell.count = (f.spell.v1/f.spell.max * 100);
		self:UpdateIcons()
		if f.spell.v1 > 0 then show = true end
	end
	if HDH_TRACKER.ENABLE_MOVE or UnitAffectingCombat("player") or show or self.ui.common.always_show then
		self:ShowTracker();
	else
		self:HideTracker();
	end
end

function HDH_STAGGER_TRACKER:InitIcons() -- HDH_TRACKER override
	if HDH_TRACKER.ENABLE_MOVE then return end
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
			-- spell.power_index = POWER_INFO[self.type].power_index
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
		
		-- self.frame:SetScript("OnEvent", self.OnEvent)
		-- self.frame:RegisterUnitEvent('UNIT_DISPLAYPOWER',"player")
		-- self.frame:RegisterUnitEvent('UNIT_MAXPOWER',"player")
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

-- function HDH_STAGGER_TRACKER:OnEvent(event, unit, powerType)
-- 	if self == nil or self.parent == nil then return end
-- 	if ((event == 'UNIT_DISPLAYPOWER') or (event == 'UNIT_MAXPOWER')) then  -- (event == "UNIT_POWER")
-- 		if not HDH_TRACKER.ENABLE_MOVE then
-- 			self.parent:Update()
-- 			self.parent:UpdateBar(self.parent.frame.icon[1]);
-- 		end
-- 	end
-- end
------------------------------------
-- HDH_STAGGER_TRACKER class
------------------------------------