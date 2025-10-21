local DB = HDH_AT_ConfigDB
HDH_ENH_MAELSTROM_TRACKER = {}

if select(4, GetBuildInfo()) <= 59999 then -- 대격변
	HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID = "53817"
	HDH_ENH_MAELSTROM_TRACKER.SPLIT_BAR_VALUES = {1,2,3,4}
else
	HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID = "344179"
	HDH_ENH_MAELSTROM_TRACKER.TALENT_EXTEND_10 = 384143
	HDH_ENH_MAELSTROM_TRACKER.SPLIT_BAR_VALUES = {4,5,9}
end

-- 거인의 힘 : 446738
HDH_ENH_MAELSTROM_TRACKER.power_info = {power_type="MAELSTROM", 		power_index =11,	color={0.25, 0.5, 1, 1},		regen=false,  texture = "Interface/Icons/Spell_Shaman_StaticShock"};

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
	-- function HDH_ENH_MAELSTROM_TRACKER:GetBarMinMax(f)
	-- 	return 0, f.spell.barMaxValue
	-- end

	-- function HDH_ENH_MAELSTROM_TRACKER:GetBarValue(f)
	-- 	return f.spell.count
	-- end
    
    function HDH_ENH_MAELSTROM_TRACKER:CreateData()
		local name, rank, texture = HDH_AT_UTIL.GetInfo(HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID)
        local trackerId = self.id
        local key = HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID
        local id = HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID
        local display = DB.SPELL_ALWAYS_DISPLAY
        local isValue = false
        local isItem = false
    
        if DB:GetTrackerElementSize(trackerId) > 0 then
            DB:TrancateTrackerElements(trackerId)
        end
        local elemIdx = DB:AddTrackerElement(trackerId, key, id, name, texture, display, isValue, isItem)

		DB:SetTrackerElementBarInfo(trackerId, elemIdx, DB.BAR_TYPE_BY_COUNT , DB.BAR_MAX_TYPE_AUTO, nil, HDH_ENH_MAELSTROM_TRACKER.SPLIT_BAR_VALUES, DB.BAR_SPLIT_FIXED_VALUE)
		DB:UpdateTrackerElementGlow(trackerId, elemIdx, DB.GLOW_CONDITION_COUNT, DB.CONDITION_GT_OR_EQ, 5)
		DB:SetReadOnlyTrackerElement(trackerId, elemIdx) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다
		
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
        DB:SetTrackerValue(trackerId, 'ui.%s.font.count_location', DB.FONT_LOCATION_C)
        DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_HIDE)
        DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_abbreviate', false)
    
		DB:SetTrackerValue(trackerId, 'ui.%s.icon.cooldown', DB.COOLDOWN_CIRCLE)
        DB:SetTrackerValue(trackerId, 'ui.%s.icon.size', 35)
        DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', {0.25, 0.5, 1, 1})
        self:UpdateSetting();
    end
    
    function HDH_ENH_MAELSTROM_TRACKER:GetElementCount()
        local key = DB:GetTrackerElement(self.id, 1)
        if HDH_ENH_MAELSTROM_TRACKER.TRACKING_SPELL_ID == key then
            return 1
        else
            return 0
        end
    end

	function HDH_ENH_MAELSTROM_TRACKER:UpdateIconAndBar(index)
		-- local cooldown_type = self.ui.icon.cooldown
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local f = self.frame.icon[1]
		if f == nil or f.spell == nil then return end
		if f.spell.count > 0 and f.spell.isUpdate then
			f.spell.v1 = f.spell.count -- 이전 버전 호환성을 위해서 일단 남겨둠
			self:UpdateGlow(f, true)
			f.icon:UpdateCooldowning()
			f.icon:SetCooldown(f.spell.startTime, f.spell.duration)
			f.counttext:SetText(f.spell.count)
		else
			f.counttext:SetText("")
			f.icon:Stop()
			f.icon:UpdateCooldowning(false)
			self:UpdateGlow(f, false)
		end

		if f.bar then
			if f.spell.isUpdate then
				self:UpdateBarMinMaxValue(f)
			else
				if f.spell.barValueType == DB.BAR_TYPE_BY_TIME then
					self:UpdateBarMinMaxValue(f, 0, 1, 1)
				else
					self:UpdateBarMinMaxValue(f, nil, nil, 0)
				end
			end
		end
		
		return ret
	end

	function HDH_ENH_MAELSTROM_TRACKER:InitIcons() -- HDH_TRACKER override
		local ret = super.InitIcons(self)
		if ret > 0 then
			self.filter = "HELPFUL"
			local f = self.frame.icon[1]
			if f.spell.barMaxValueType == DB.BAR_MAXVALUE_TYPE_COUNT then -- 호환성 코드
				if HDH_AT.LE <= HDH_AT.LE_MISTS then -- 대격변
					f.spell.countMax = 5
				else
					if HDH_AT_UTIL.IsLearnedSpellOrEquippedItem(HDH_ENH_MAELSTROM_TRACKER.TALENT_EXTEND_10, nil) then
						f.spell.countMax = 10
					else
						f.spell.countMax = 5
					end
				end
			end
			self:SetupBarValue(f)
			self:Update()
		end
		return ret
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

