local DB = HDH_AT_ConfigDB
HDH_ENH_MAELSTROM_TRACKER = {}

if select(4, GetBuildInfo()) <= 59999 then -- 대격변
	HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID = 53817
	HDH_ENH_MAELSTROM_TRACKER.SPLIT_BAR_VALUES = {1,2,3,4}
else
	HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID = 344179
	HDH_ENH_MAELSTROM_TRACKER.SPLIT_BAR_VALUES = {5}
end

-- 거인의 힘 : 446738

------------------------------------------
 -- AURA TRACKER Class
--------------------------------------------
local super = HDH_AURA_TRACKER
setmetatable(HDH_ENH_MAELSTROM_TRACKER, super) -- 상속
HDH_ENH_MAELSTROM_TRACKER.__index = HDH_ENH_MAELSTROM_TRACKER
HDH_ENH_MAELSTROM_TRACKER.className = "HDH_ENH_MAELSTROM_TRACKER"

HDH_TRACKER.TYPE.POWER_ENH_MAELSTROM = 23
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_ENH_MAELSTROM, HDH_ENH_MAELSTROM_TRACKER)

do
	function HDH_ENH_MAELSTROM_TRACKER:UpdateBarValue(f, value)
		f.bar:SetValue(f.spell.v1, true)
	end

    function HDH_ENH_MAELSTROM_TRACKER:GetPower()
		local curTime = GetTime()
		local aura
		local ret = 0;
		local f
		local spell
		local power = 0
		for i = 1, 40 do 
			aura = C_UnitAuras.GetAuraDataByIndex('player', i, 'HELPFUL')
			if not aura then break end
			if aura.spellId == HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID then
				f = self.frame.pointer[aura.spellId]
				if f and f.spell then
					spell = f.spell
					
					if not spell.isUpdate then
						spell.count = aura.applications
					else
						spell.count = (spell.count or 0) + aura.applications
					end
					spell.id = aura.spellId
					spell.dispelType = aura.dispelName

					if spell.isUpdate then
						spell.overlay = (spell.overlay or 0) + 1
					else
						spell.overlay = 1
					end

					if spell.endTime ~= aura.expirationTime then spell.endTime = aura.expirationTime; spell.happenTime = GetTime(); end
					if aura.expirationTime > 0 then spell.remaining = spell.endTime - curTime
					else spell.remaining = 0; end
					spell.duration = aura.duration
					spell.startTime = aura.expirationTime - aura.duration
					spell.index = i; -- 툴팁을 위해, 순서
					ret = ret + 1;
					spell.isUpdate = true
				end
				power = aura.applications -- * 10
				break
			end
		end
		f = self.frame.icon[1]
		
		if f and not f.spell.isUpdate and f.spell.remaining > 0 then
			spell = f.spell
			spell.isUpdate = true
			spell.endTime = 0
			spell.remaining = 0
			spell.v1 = 0
			spell.duration = 0
			spell.startTime = 0
		end

		return power
    end
    
    function HDH_ENH_MAELSTROM_TRACKER:GetPowerMax()
        return self.powerMax
    end
    
    function HDH_ENH_MAELSTROM_TRACKER:CreateData()
		local name, rank, texture = HDH_AT_UTIL.GetInfo(HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID)
        local trackerId = self.id
        local key = HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID
        local id = HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID
        local display = DB.SPELL_ALWAYS_DISPLAY
        local isValue = true
        local isItem = false
    
        if DB:GetTrackerElementSize(trackerId) > 0 then
            DB:TrancateTrackerElements(trackerId)
        end
        local elemIdx = DB:AddTrackerElement(trackerId, key, id, name, texture, display, isValue, isItem)

		if select(4, GetBuildInfo()) <= 59999 then -- 대격변
			DB:SetTrackerElementSplitValues(trackerId, elemIdx, HDH_ENH_MAELSTROM_TRACKER.SPLIT_BAR_VALUES, DB.BAR_SPLIT_FIXED_VALUE)
		else
			DB:SetTrackerElementSplitValues(trackerId, elemIdx, HDH_ENH_MAELSTROM_TRACKER.SPLIT_BAR_VALUES, DB.BAR_SPLIT_FIXED_VALUE)
		end
        
		DB:UpdateTrackerElementGlow(trackerId, elemIdx, DB.GLOW_CONDITION_VALUE, DB.CONDITION_GT_OR_EQ, 5)
		DB:SetReadOnlyTrackerElement(trackerId, elemIdx) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다
		
        local maxValue = self:GetPowerMax()
    
        DB:CopyGlobelToTracker(trackerId)
        DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON_AND_BAR)
        DB:SetTrackerValue(trackerId, 'ui.%s.common.reverse_h', false)
        DB:SetTrackerValue(trackerId, 'ui.%s.common.column_count', 6)
        DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', {0.25, 0.5, 1, 1})
        DB:SetTrackerValue(trackerId, 'ui.%s.bar.use_full_color', true)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.full_color', {1, 0, 0, 1})
        DB:SetTrackerValue(trackerId, 'ui.%s.bar.location', DB.BAR_LOCATION_R)
        DB:SetTrackerValue(trackerId, 'ui.%s.bar.width', 200)
        DB:SetTrackerValue(trackerId, 'ui.%s.bar.height', 20)
        DB:SetTrackerValue(trackerId, 'ui.%s.bar.to_fill', true)
        DB:SetTrackerValue(trackerId, 'ui.%s.bar.cooldown_progress', DB.COOLDOWN_RIGHT)
        DB:SetTrackerValue(trackerId, 'ui.%s.bar.texture', 3)
		
		DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_size', 20)
		DB:SetTrackerValue(trackerId, 'ui.%s.font.name_location', DB.FONT_LOCATION_HIDE)
		DB:SetTrackerValue(trackerId, 'ui.%s.font.cd_location', DB.FONT_LOCATION_HIDE)
        DB:SetTrackerValue(trackerId, 'ui.%s.font.count_location', DB.FONT_LOCATION_HIDE)
        DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_C)
        DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_abbreviate', false)
    
		DB:SetTrackerValue(trackerId, 'ui.%s.icon.cooldown', DB.COOLDOWN_CIRCLE)
        DB:SetTrackerValue(trackerId, 'ui.%s.icon.size', 35)
        DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', {0.25, 0.5, 1, 1})
        self:UpdateSetting();
    end


	function HDH_ENH_MAELSTROM_TRACKER:CreateDummySpell(count)
		local icons =  self.frame.icon
		local ui = self.ui
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
		spell.duration = 50
		spell.happenTime = 0;
		spell.glow = false
		spell.endTime = 0
		spell.startTime = GetTime()
		spell.remaining = 0
		spell.showValue = f.spell.showValue
		spell.v1 = power_max
		spell.max = power_max;
		spell.splitValues = f.spell.splitValues

		f.icon:SetCooldown(spell.startTime, spell.duration)
		f.icon:UpdateCooldowning()

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
    
    function HDH_ENH_MAELSTROM_TRACKER:GetElementCount()
        local key = DB:GetTrackerElement(self.id, 1)
        if HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID == key then
            return 1
        else
            return 0
        end
    end

	function HDH_ENH_MAELSTROM_TRACKER:UpdateAllIcons()  -- HDH_TRACKER override
		-- local cooldown_type = self.ui.icon.cooldown
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local f = self.frame.icon[1]
		if f == nil or f.spell == nil then return end
		if f.spell.v1 > 0 then
			ret = 1
			self:UpdateGlow(f, true)
			f:Show()
			f.icon:UpdateCooldowning()
			f.icon:SetCooldown(f.spell.startTime, f.spell.duration)
			if f.spell.count == 100 and f.spell.v1 ~= f.spell.maxValue then f.spell.count = 99 end
			f.counttext:SetText(f.spell.count .. "%")
			f.v1:SetText(f.spell.v1)
		else
			if f.spell.display == DB.SPELL_ALWAYS_DISPLAY then
				f.v1:SetText("")
				f.counttext:SetText("")
				f.icon:Stop()
				f.icon:UpdateCooldowning(false)
				self:UpdateGlow(f, false)
				f:Show();
			else
				f:Hide();
			end
		end
		if f.bar then
			self:UpdateBarMinMaxValue(f, 0, f.spell.max, f.spell.v1)
		end
		f.spell.isUpdate = false
		f:SetPoint('RIGHT');
		return ret
	end

	function HDH_ENH_MAELSTROM_TRACKER:Update() -- HDH_TRACKER override
		if not self.frame or not self.frame.icon or HDH_TRACKER.ENABLE_MOVE then return end
		local f = self.frame.icon[1]
		local show = false
		if f and f.spell then
			-- f.spell.type = UnitPowerType('player');
			f.spell.v1 = self:GetPower()
			f.spell.max = self:GetPowerMax()
			f.spell.count = (f.spell.v1/f.spell.max * 100);
			if self:UpdateAllIcons() > 0 then
				show = true 
			end
		end
	
		if (not (self.ui.common.hide_in_raid and IsInRaid())) 
				and (HDH_TRACKER.ENABLE_MOVE or UnitAffectingCombat("player") or show or self.ui.common.always_show) then
			self:ShowTracker();
		else
			self:HideTracker();
		end
	end

	function HDH_ENH_MAELSTROM_TRACKER:InitIcons()
		local trackerId = self.id
		local id, name, _, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
		self.unit = "player"
		self.aura_filter = aura_filter
		self.aura_caster = aura_caster
		if not id then 
			return 
		end

		if select(4, GetBuildInfo()) <= 59999 then -- 대격변
			self.powerMax = 5
		else
			self.powerMax = ((263 == select(1,  HDH_AT_UTIL.GetSpecializationInfo(HDH_AT_UTIL.GetSpecialization()))) and 10) or 5
		end
		local elemKey, elemId, elemName, texture, display, glowType, isValue, isItem, glowCondition, glowValue, splitValues, glowEffectType, glowEffectColor, glowEffectPerSec, splitType
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
				splitValues, splitType = DB:GetTrackerElementSplitValues(trackerId, i)
				
				iconIdx = iconIdx + 1
				f = self.frame.icon[iconIdx]
				if f:GetParent() == nil then f:SetParent(self.frame) end
				self.frame.pointer[elemKey or tostring(elemId)] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
				spell = {}
				spell.glow = glowType
				spell.glowCondtion = glowCondition
				spell.glowValue = (glowValue and tonumber(glowValue)) or 0
				spell.glowEffectType = glowEffectType
				spell.glowEffectColor = glowEffectColor
				spell.glowEffectPerSec = glowEffectPerSec
				spell.showValue = isValue
				spell.display = display
				spell.v1 = 0 -- 수치를 저장할 변수
				spell.no = i
				spell.name = elemName
				spell.icon = texture
				spell.power_index = 1
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
				spell.splitPoints = splitValues or {}
				spell.splitPointType = splitType
				f.spell = spell
				f.icon:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
				self:UpdateGlow(f, false)
				self:UpdateBarSettings(f)
				-- f:SetScript("OnUpdate", HDH_ENH_MAELSTROM_OnUpdate)
				f:Hide();
				self:ActionButton_HideOverlayGlow(f)
			end
			self.frame:SetScript("OnEvent", self.OnEvent)
			self.frame:RegisterUnitEvent('UNIT_AURA')
			self:Update()
		else
			self.frame:UnregisterAllEvents()
		end
		
		for i = #self.frame.icon, iconIdx+1 , -1 do
			self:ReleaseIcon(i)
		end
		return iconIdx
	end

------------------------------------------
end -- TRACKER class
------------------------------------------


-------------------------------------------
-- 이벤트 메세지 function
-------------------------------------------
function HDH_ENH_MAELSTROM_TRACKER:UNIT_AURA()
	self:Update()
end

function HDH_ENH_MAELSTROM_TRACKER:OnEvent(event, ...)
	local self = self.parent
	if not self then return end
	if event == 'UNIT_AURA' then
		if select(1, ...) == self.unit then self:UNIT_AURA() end
	elseif event == "ENCOUNTER_START" then
		self:UNIT_AURA()
	elseif event == "ENCOUNTER_END" then
		self:UNIT_AURA()
	end
end

