-- if select(4, GetBuildInfo()) <= 100205 then return end

local DB = HDH_AT_ConfigDB
HDH_ENH_MAELSTROM_TRACKER = {}

if select(4, GetBuildInfo()) <= 49999 then -- 대격변
	HDH_ENH_MAELSTROM_TRACKER.MAEL_SPELL_ID = 53817
else
	HDH_ENH_MAELSTROM_TRACKER.MAEL_SPELL_ID = 344179
end


------------------------------------------
 -- AURA TRACKER Class
--------------------------------------------
local super = HDH_POWER_TRACKER
setmetatable(HDH_ENH_MAELSTROM_TRACKER, super) -- 상속
HDH_ENH_MAELSTROM_TRACKER.__index = HDH_ENH_MAELSTROM_TRACKER
HDH_ENH_MAELSTROM_TRACKER.className = "HDH_ENH_MAELSTROM_TRACKER"

HDH_TRACKER.TYPE.POWER_ENH_MAELSTROM = 23
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_ENH_MAELSTROM, HDH_ENH_MAELSTROM_TRACKER)

do

	local function HDH_POWER_OnUpdate(self)
		self.spell.curTime = GetTime()
		
		if self.spell.curTime - (self.spell.delay or 0) < 0.02  then return end 
		self.spell.delay = self.spell.curTime
		local curValue = self:GetParent().parent:GetPower()
		local maxValue = self:GetParent().parent:GetPowerMax()
		local tracker = self:GetParent().parent		
		
		if self.spell.v1 ~= curValue  then 
			self.spell.v1 = curValue;
			self.spell.count = math.ceil(self.spell.v1 / maxValue * 100);
			if self.spell.count == 100 and self.spell.v1 ~= maxValue then self.spell.count = 99 end
			self.counttext:SetText(self.spell.count .. "%"); 
			-- else self.counttext:SetText(nil) end
			if self.spell.showValue and self.spell.v1 > 0 then 
				self.v1:SetText(HDH_AT_UTIL.AbbreviateValue(self.spell.v1 / 10, self:GetParent().parent.ui.font.v1_abbreviate)); 
			else 
				self.v1:SetText(nil) 
			end
			
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
		end

		-- if tracker.ui.common.display_mode ~= DB.DISPLAY_BAR then
		-- 	if tracker.ui.icon.cooldown ~= DB.COOLDOWN_CIRCLE and tracker.ui.icon.cooldown ~= DB.COOLDOWN_NONE then
		-- 		self.spell.per = math.max(0, self.spell.remaining / self.spell.duration)

		-- 		-- print(self.spell.per,  self.spell.remaining)
		-- 		if self.spell.per < 0.99 and self.spell.per > 0.01 then
		-- 			if not self.iconSatCooldown.spark:IsShown() then
		-- 				self.iconSatCooldown.spark:Show()
		-- 			end
		-- 		else
		-- 			if self.iconSatCooldown.spark:IsShown() then
		-- 				self.iconSatCooldown.spark:Hide()
		-- 			end
		-- 		end
		-- 		self.iconSatCooldown.curSize = math.ceil(self.icon:GetHeight() * self.spell.per * 10) / 10
		-- 		self.iconSatCooldown.curSize = self.iconSatCooldown.curSize - (self.iconSatCooldown.curSize % 0.5)
		-- 		self.iconSatCooldown.curSize = math.max(self.iconSatCooldown.curSize, 0.1)
		-- 		if (self.iconSatCooldown.curSize ~= self.iconSatCooldown.preSize) then
		-- 			self.tex = 0.86 * self.spell.per
		-- 			if (self.iconSatCooldown.curSize == 0) then self.iconSatCooldown:Hide() end
		-- 			if tracker.ui.icon.cooldown == DB.COOLDOWN_LEFT then
		-- 				self.spell.texcoord = 0.07 + (self.tex)
		-- 				self.iconSatCooldown:SetWidth(self.iconSatCooldown.curSize)
		-- 				-- spell.texcoord = math.ceil(spell.texcoord * 10) / 10
		-- 				self.iconSatCooldown:SetTexCoord(0.07, self.spell.texcoord, 0.07, 0.93)
		-- 			elseif tracker.ui.icon.cooldown == DB.COOLDOWN_RIGHT then
		-- 				self.spell.texcoord = (0.93 - self.tex)
		-- 				self.iconSatCooldown:SetWidth(self.iconSatCooldown.curSize)
		-- 				-- spell.texcoord = math.ceil(spell.texcoord * 10) /10
		-- 				self.iconSatCooldown:SetTexCoord(self.spell.texcoord, 0.93, 0.07, 0.93)
		-- 			elseif tracker.ui.icon.cooldown == DB.COOLDOWN_UP then
		-- 				self.spell.texcoord = (0.07 + self.tex)
		-- 				self.iconSatCooldown:SetHeight(self.iconSatCooldown.curSize)
		-- 				-- spell.texcoord = math.ceil(spell.texcoord * 10) /10
		-- 				self.iconSatCooldown:SetTexCoord(0.07, 0.93, 0.07, spell.texcoord)
		-- 			else
		-- 				self.spell.texcoord = (0.93 - self.tex)
		-- 				self.iconSatCooldown:SetHeight(self.iconSatCooldown.curSize)
		-- 				-- spell.texcoord = math.ceil(spell.texcoord * 10) /10
		-- 				self.iconSatCooldown:SetTexCoord(0.07, 0.93, self.spell.texcoord, 0.93)
		-- 			end
		-- 			-- print(spell.per, spell.texcoord, f.iconSatCooldown.curSize)
		-- 			self.iconSatCooldown.preSize = self.iconSatCooldown.curSize
		-- 		end
		-- 	end
		-- end

		self:GetParent().parent:SetGlow(self, true);
		self:GetParent().parent:UpdateBarValue(self);
	end

    function HDH_ENH_MAELSTROM_TRACKER:GetPower()
		local curTime = GetTime()
		local _, count, duration, endTime, id
		local ret = 0;
		local f
		local spell
		for i = 1, 40 do 
			-- name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod
			_, _, count, _, duration, endTime, _, _, _, id = UnitAura('player', i, 'HELPFUL')
			if id == HDH_ENH_MAELSTROM_TRACKER.MAEL_SPELL_ID then
				f = self.frame.pointer[id]
				if f and f.spell then
					spell = f.spell
					-- if not StaggerID[id] then -- 시간차가 아니면
					-- 	spell.v1 = (v1 ~= 0) and v1 or nil
					-- else -- 시간차
					-- 	spell.v1 = v2; 
					-- end
					
					if not spell.isUpdate then
						spell.count = count
					else
						spell.count = (spell.count or 0) + count
					end
					spell.id = id
					spell.dispelType = dispelType

					if spell.isUpdate then
						spell.overlay = (spell.overlay or 0) + 1
					else
						spell.overlay = 1
					end

					if spell.endTime ~= endTime then spell.endTime = endTime; spell.happenTime = GetTime(); end
					if endTime > 0 then spell.remaining = spell.endTime - curTime
					else spell.remaining = 0; end
					spell.duration = duration
					spell.startTime = endTime - duration
					spell.index = i; -- 툴팁을 위해, 순서
					ret = ret + 1;
					spell.isUpdate = true
				end
				-- break
				count = count * 10
				break
			end
		end
		return count or 0
    end
    
    function HDH_ENH_MAELSTROM_TRACKER:GetPowerMax()
        return self.powerMax
    end
    
    function HDH_ENH_MAELSTROM_TRACKER:CreateData()
		local name, rank, texture = HDH_AT_UTIL.GetInfo(HDH_ENH_MAELSTROM_TRACKER.MAEL_SPELL_ID)
        local trackerId = self.id
        local key = HDH_ENH_MAELSTROM_TRACKER.MAEL_SPELL_ID
        local id = HDH_ENH_MAELSTROM_TRACKER.MAEL_SPELL_ID
        local display = DB.SPELL_ALWAYS_DISPLAY
        local isValue = true
        local isItem = false
    
        if DB:GetTrackerElementSize(trackerId) > 0 then
            DB:TrancateTrackerElements(trackerId)
        end
        local elemIdx = DB:AddTrackerElement(trackerId, key, id, name, texture, display, isValue, isItem)


		if select(4, GetBuildInfo()) <= 49999 then -- 대격변
			DB:SetTrackerElementSplitValues(trackerId, elemIdx, {10,20,30,40})
		else
			DB:SetTrackerElementSplitValues(trackerId, elemIdx, {50})
		end
        
		DB:UpdateTrackerElementGlow(trackerId, elemIdx, DB.GLOW_CONDITION_VALUE, DB.CONDITION_GT_OR_EQ, 50)
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
    
    function HDH_ENH_MAELSTROM_TRACKER:IsHaveData()
        local key = DB:GetTrackerElement(self.id, 1)
        if HDH_ENH_MAELSTROM_TRACKER.MAEL_SPELL_ID == key then
            return true
        else
            return false
        end
    end

	function HDH_ENH_MAELSTROM_TRACKER:UpdateIcons()  -- HDH_TRACKER override
		local cooldown_type = self.ui.icon.cooldown
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local f = self.frame.icon[1]
		if f == nil or f.spell == nil then return end;
		if f.spell.v1 > 0 then 
			f.icon:SetDesaturated(nil)
			f.icon:SetAlpha(self.ui.icon.on_alpha)
			f.border:SetAlpha(self.ui.icon.on_alpha)
			f.border:SetVertexColor(unpack(self.ui.icon.active_border_color)) 
			ret = 1;
			self:SetGlow(f, true)
			f:Show();
			if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
				self:UpdateBarValue(f);
				f.bar:Show();
				-- f.name:SetText(f.spell.name);
			end
			if cooldown_type ~= DB.COOLDOWN_CIRCLE and  cooldown_type ~= DB.COOLDOWN_NONE then
				f.icon:SetAlpha(self.ui.icon.off_alpha)
				f.border:SetAlpha(self.ui.icon.off_alpha)
				f.icon:SetDesaturated(1)
				f.iconSatCooldown:SetAlpha(self.ui.icon.on_alpha)
				f.iconSatCooldown:Show()
				f.cd:Hide()
			else
				f.iconSatCooldown:Hide()
				f.icon:SetAlpha(self.ui.icon.on_alpha)
				f.border:SetAlpha(self.ui.icon.on_alpha)
				f.icon:SetDesaturated(nil)
				f.cd:Show()
				
				if HDH_TRACKER.startTime < f.spell.startTime or (f.spell.duration == 0) then
					f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
				end
			end
		else
			if f.spell.display == DB.SPELL_ALWAYS_DISPLAY then
				f.icon:SetDesaturated(1)
				f.icon:SetAlpha(self.ui.icon.off_alpha)
				f.border:SetAlpha(self.ui.icon.off_alpha)
				f.border:SetVertexColor(0,0,0)
				self:SetGlow(f, false)
				f:Show();
				f.cd:Hide();
			else
				f:Hide();
			end
		end
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
			
			if self:UpdateIcons() > 0 then
				show = true 
			end
		end
	
		if (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
				and (HDH_TRACKER.ENABLE_MOVE or UnitAffectingCombat("player") or show or self.ui.common.always_show) then
			self:ShowTracker();
		else
			self:HideTracker();
		end
	end

	function HDH_ENH_MAELSTROM_TRACKER:InitIcons()
		local trackerId = self.id
		local id, name, _, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
		self.aura_filter = aura_filter
		self.aura_caster = aura_caster
		if not id then 
			return 
		end

		if select(4, GetBuildInfo()) <= 49999 then -- 대격변
			self.powerMax = 50
		else
			self.powerMax = ((263 == select(1,  HDH_AT_UTIL.GetSpecializationInfo(HDH_AT_UTIL.GetSpecialization()))) and 100) or 50
		end
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
				spell.power_index = 1
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
				self:SetGlow(f, false)
				self:UpdateArtBar(f)
				f:SetScript("OnUpdate", HDH_POWER_OnUpdate);
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

	function HDH_ENH_MAELSTROM_TRACKER:PLAYER_ENTERING_WORLD()
		-- self.isRaiding = self:IsRaiding()
	end
	
------------------------------------------
end -- TRACKER class
------------------------------------------


-------------------------------------------
-- 이벤트 메세지 function
-------------------------------------------
function HDH_UNIT_AURA(self)
	if self then
		self:Update()
	end
end


function OnEventTracker(self, event, ...)
	if not self.parent then return end
	if event == 'UNIT_AURA' then
		local unit = select(1,...)
		if self.parent and unit == self.parent.unit then
			HDH_UNIT_AURA(self.parent)
		end
	elseif event =="PLAYER_TARGET_CHANGED" then
		local t = self.parent
		t:RunTimer("PLAYER_TARGET_CHANGED", 0.02, HDH_UNIT_AURA, self.parent) 
	elseif event == 'PLAYER_FOCUS_CHANGED' then
		HDH_UNIT_AURA(self.parent)
	elseif event == 'INSTANCE_ENCOUNTER_ENGAGE_UNIT' then
		HDH_UNIT_AURA(self.parent)
	elseif event == 'GROUP_ROSTER_UPDATE' then
		HDH_UNIT_AURA(self.parent)
	elseif event == 'UNIT_PET' then
		self.parent:RunTimer("UNIT_PET", 0.5, HDH_UNIT_AURA, self.parent) 
	elseif event == 'ARENA_OPPONENT_UPDATE' then
		self.parent:RunTimer("ARENA_OPPONENT_UPDATE", 0.5, HDH_UNIT_AURA, self.parent) 
	elseif event == "ENCOUNTER_START" then
		self.parent.isRaiding = true;
	elseif event == "ENCOUNTER_END" then
		self.parent.isRaiding = false;
	end
end

