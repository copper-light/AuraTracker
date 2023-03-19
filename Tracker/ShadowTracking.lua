HDH_SHADOWY_APPARITION_TRACKER = {}
local UTIL = HDH_AT_UTIL
local DB = HDH_AT_ConfigDB
local L = HDH_AT_L
local ShadowID = { }
local SHADOW_KEY = "Shadowy_Apparition"
ShadowID[147193] = true
ShadowID[148859] = true 
ShadowID[78203] = true 
ShadowID[155271] = true 
ShadowID[341263] = true 

local VAMPIRIC_TOUCH_ID = 34914
local SHADOWY_APPARITION_CASTED_SPELL_ID = 341263
local SHADOWY_APPARITION_DAMEGED_SPELL_ID = 148859

local super = HDH_AURA_TRACKER;
setmetatable(HDH_SHADOWY_APPARITION_TRACKER, super) -- 상속
HDH_SHADOWY_APPARITION_TRACKER.__index = HDH_SHADOWY_APPARITION_TRACKER;
HDH_SHADOWY_APPARITION_TRACKER.className = 'HDH_SHADOWY_APPARITION_TRACKER';

HDH_TRACKER.TYPE.PRIEST_SHADOWY_APPARITION = 23
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.PRIEST_SHADOWY_APPARITION, HDH_SHADOWY_APPARITION_TRACKER)

do 

	function HDH_SHADOWY_APPARITION_TRACKER:CreateData()
		local name, _, texture = UTIL.GetInfo(SHADOWY_APPARITION_CASTED_SPELL_ID)
		local trackerId = self.id
		local key = SHADOW_KEY 
		local id = 0
		local display = DB.SPELL_ALWAYS_DISPLAY
		local isValue = true
		local isItem = false
	
		if DB:GetTrackerElementSize(trackerId) > 0 then
			DB:TrancateTrackerElements(trackerId)
		end
		local elemIdx = DB:AddTrackerElement(trackerId, key, id, name, texture, display, isValue, isItem)
		DB:SetReadOnlyTrackerElement(trackerId, elemIdx) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다
		-- DB:UpdateTrackerElementGlow(trackerId, elemIdx, DB.GLOW_CONDITION_COUNT, DB.CONDITION_GT_OR_EQ, 60)
	
		DB:CopyGlobelToTracker(trackerId)
		DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON)
		-- DB:SetTrackerValue(trackerId, 'ui.%s.font.name_location', DB.FONT_LOCATION_HIDE)
		-- DB:SetTrackerValue(trackerId, 'ui.%s.font.count_location', DB.FONT_LOCATION_BAR_L)
		-- DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_BAR_R)
		-- DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_abbreviate', false)
		-- DB:SetTrackerValue(trackerId, 'ui.%s.icon.size', 40)
		DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', {0, 0, 0, 1})
		-- DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', HDH_STAGGER_TRACKER.POWER_INFO[self.type].color)
		self:UpdateSetting();
	end
	
	function HDH_SHADOWY_APPARITION_TRACKER:IsHaveData(spec)
		local key = DB:GetTrackerElement(self.id, 1)
		if (SHADOW_KEY) == key then
			return 1
		else
			return 0
		end
	end
	
	function HDH_SHADOWY_APPARITION_TRACKER:GetTotalShadowCount()
		return self.shadowCount
	end

	function HDH_SHADOWY_APPARITION_TRACKER:Release() -- HDH_TRACKER override
		if self and self.frame then
			self.frame:SetScript("OnEvent",nil)
			self.frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
		super.Release(self)
	end
	
	-- function HDH_SHADOWY_APPARITION_TRACKER:UpdateIcons()
	-- 	local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
	-- 	local line = self.ui.common.column_count or 10-- 한줄에 몇개의 아이콘 표시
	-- 	local reverse_v = self.ui.common.reverse_v -- 상하반전
	-- 	local reverse_h = self.ui.common.reverse_h -- 좌우반전
	-- 	local margin_h = self.ui.common.margin_h
	-- 	local margin_v = self.ui.common.margin_v
	-- 	local icons = self.frame.icon
	-- 	local i = 0 -- 몇번째로 아이콘을 출력했는가?
	-- 	local col = 0  -- 열에 대한 위치 좌표값 = x
	-- 	local row = 0  -- 행에 대한 위치 좌표값 = y
	-- 	local to_fill = self.ui.bar.to_fill
	-- 	local value
		
	-- 	local i = 0 -- 몇번째로 아이콘을 출력했는가?
	-- 	local col = 0  -- 열에 대한 위치 좌표값 = x
	-- 	local row = 0  -- 행에 대한 위치 좌표값 = y
		
	-- 	for k,f in ipairs(icons) do
	-- 		if not f.spell then break end
	-- 		if f.spell.isUpdate then
	-- 			f.spell.isUpdate = false
				
	-- 			if f.spell.count == 0 then f.counttext:SetText(nil)
	-- 								 else f.counttext:SetText(f.spell.count) end
	-- 			if f.spell.duration == 0 then f.cd:Hide() 
	-- 									 else f.cd:Show() end
	-- 			if f.icon:IsDesaturated() then f.icon:SetDesaturated(nil)
	-- 										   f.icon:SetAlpha(self.option.icon.on_alpha)
	-- 										   f.border:SetAlpha(self.option.icon.on_alpha)end
	-- 			f.border:SetVertexColor(unpack(self.option.icon.buff_color)) 
	-- 			if self.option.base.cooldown == COOLDOWN_CIRCLE then
	-- 				f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
	-- 			else
	-- 				f.cd:SetMinMaxValues(f.spell.startTime, f.spell.endTime)
	-- 			end
	-- 			f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
	-- 			i = i + 1
	-- 			if i % line == 0 then row = row + size + margin_v; col = 0
	-- 							 else col = col + size + margin_h end
	-- 			ret = ret + 1
	-- 			self:SetGlow(f, true)
	-- 			f:Show()
	-- 		else
	-- 			if f.spell.always then 
	-- 				if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1)
	-- 												   f.icon:SetAlpha(self.option.icon.off_alpha)
	-- 												   f.border:SetAlpha(self.option.icon.off_alpha)
	-- 												   f.border:SetVertexColor(0,0,0) end
	-- 				f.counttext:SetText(nil)
	-- 				f.cd:Hide() self:SetGlow(f, false)
	-- 				--f:ClearAllPoints()
	-- 				f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
	-- 				i = i + 1
	-- 				if i % line == 0 then row = row + size + margin_v; col = 0
	-- 							 else col = col + size + margin_h end
	-- 				f:Show()
	-- 			else
	-- 				if self.option.base.fix then
	-- 					i = i + 1
	-- 					if i % line == 0 then row = row + size + margin_v; col = 0
	-- 							 else col = col + size + margin_h end
	-- 				end
	-- 				f:Hide()
	-- 			end
	-- 		end
	-- 	end
	-- 	return ret
	-- end

	function HDH_SHADOWY_APPARITION_TRACKER:Update() -- HDH_TRACKER override
		if not self.frame or not self.frame.icon or HDH_TRACKER.ENABLE_MOVE then return end
		local f = self.frame.icon[1]
		f.spell.count = self:GetTotalShadowCount()
		if f.spell.count > 0 then
			f.spell.isUpdate = true
			f.spell.duration = 0
			f.spell.startTime = 0
			f.spell.endTime = 0
			f.spell.v1 = nil
		end
		self:UpdateIcons()
		if (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
				and ((f.spell.count > 0) or UnitAffectingCombat("player") or self.ui.common.always_show) then 
			self:ShowTracker();
		else
			self:HideTracker();
		end
	end
	
	local CombatLogEventList = {
		["SPELL_CAST_SUCCESS"] 	    = HDH_SHADOWY_APPARITION_TRACKER.CombatLog_UpCounting,       --흡혈 시작
		["SPELL_DAMAGE"] 			= HDH_SHADOWY_APPARITION_TRACKER.CombatLog_DownCounting,     --그림자 종료 확인
		["SPELL_AURA_REMOVED"] 			= HDH_SHADOWY_APPARITION_TRACKER.CombatLog_DownCounting, --주문 삭제
		["UNIT_DIED"]				= HDH_SHADOWY_APPARITION_TRACKER.CombatLog_ClearCounting,    -- 
	}

	-- 흡혈이 종료되지 않았는데, 3초 이상 로그가 없으면 삭제 시킴
	-- 그림자가 실행됐는데, 10초 이상 없어지는 로그가 발생하지 않으면 삭제 시킴
	-- 대상이 죽는것도 확인할 것
	-- 흡혈 도트뎀 있을때 흡혈 객체 있는지도 확인

	function HDH_SHADOWY_APPARITION_TRACKER:COMBAT_LOG_EVENT_UNFILTERED(...)
		--        1           2       3      4      5 6 7   8         9           10        11            12       13    14     15      16           
		local timestamp, combatevent, _, sourceGUID, _, _, _, destGUID, destName, destFlags, destRaidFlag, spellid, spellname, _, auraType, stackCount = ...
		
		if combatevent == "UNIT_DIED" then
			if self.vampiricTarget[destGUID] then
				self.vampiricTouchCount = math.max(self.vampiricTouchCount - 1, 0)
				self.vampiricTarget[destGUID] = nil
			end
		elseif combatevent == "SPELL_CAST_SUCCESS" then
			if UnitGUID('player') == sourceGUID then
				if spellid == VAMPIRIC_TOUCH_ID and not self.vampiricTarget[destGUID] then
					self.vampiricTarget[destGUID] = true
					self.vampiricTouchCount = self.vampiricTouchCount + 1
				end
	
				if spellid == SHADOWY_APPARITION_CASTED_SPELL_ID then
					self.shadowCount = self.shadowCount + self.vampiricTouchCount
				end
				self:Update()
			end
			
		elseif combatevent == "SPELL_AURA_REMOVED" then
			if (UnitGUID('player') == sourceGUID) and (spellid == VAMPIRIC_TOUCH_ID) then
				if self.vampiricTarget[destGUID] then
					self.vampiricTouchCount = math.max(self.vampiricTouchCount - 1, 0)
					self.vampiricTarget[destGUID] = nil
				end
			end
		elseif combatevent == "SPELL_DAMAGE" then
			if UnitGUID('player') == sourceGUID and spellid == SHADOWY_APPARITION_DAMEGED_SPELL_ID then
				self.shadowCount = math.max(self.shadowCount - 1, 0)
				self:Update()
			end
		else

		end

		print(self.shadowCount.."/"..self.vampiricTouchCount)
	end

	function HDH_SHADOWY_APPARITION_TRACKER.OnEvent(self, e, ...)
		if self.parent then
			self.parent:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
		end
	end

	function HDH_SHADOWY_APPARITION_TRACKER:InitIcons() -- HDH_TRACKER override
			-- if HDH_TRACKER.ENABLE_MOVE then return end
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
		local hasEquipItem = false

		self.vampiricTarget = {}
		self.shadowTarget = {}
		self.frame.pointer = {}
		self.frame:UnregisterAllEvents()
		
		self.talentId = GetSpecialization()

		self.vampiricTouchCount = 0
		self.shadowCount = 0

		if self:IsHaveData() == 0 then
			self:CreateData()
		end
		if self:IsHaveData() > 0 then
			elemKey, elemId, elemName, texture, display, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, 1)
			glowType, glowCondition, glowValue = DB:GetTrackerElementGlow(trackerId, 1)
			splitValues = DB:GetTrackerElementSplitValues(trackerId, 1)

			f = self.frame.icon[1]
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
			spell.isUpdate = false
			spell.isItem =  isItem
			spell.showPer = true;
			f.cooldown1:Hide()
			f.cooldown2:Hide()
			f.icon:SetTexture(texture)
			f.spell = spell
			f:Hide();
			self:SetGlow(f, false)
			self:UpdateArtBar(f)
			self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self.frame:SetScript("OnEvent", self.OnEvent)
		else
			self.frame:UnregisterAllEvents()
		end
		for i = #self.frame.icon, self:IsHaveData()+1 , -1 do
			self:ReleaseIcon(i)
		end
		self:Update()
		return self:IsHaveData()
	end
	
	function HDH_SHADOWY_APPARITION_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:InitIcons()
	end
end

-------------------------------------------------------------------
-------------------------------------------------------------------

