local DB = HDH_AT_ConfigDB
HDH_AURA_TRACKER = {}
HDH_AURA_TRACKER.BOSS_DEBUFF = {}
local PLAY_SOUND = false

------------------------------------------
 -- AURA TRACKER Class
--------------------------------------------
local super = HDH_TRACKER
setmetatable(HDH_AURA_TRACKER, super) -- 상속
HDH_AURA_TRACKER.__index = HDH_AURA_TRACKER
HDH_AURA_TRACKER.className = "HDH_AURA_TRACKER"

HDH_TRACKER.TYPE.BUFF = 1
HDH_TRACKER.TYPE.DEBUFF = 2
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.BUFF, HDH_AURA_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.DEBUFF, HDH_AURA_TRACKER)

do
	local StaggerID = { }
	StaggerID[124275] = true
	StaggerID[124274] = true
	StaggerID[124273] = true

	function HDH_AURA_TRACKER:GetPowerMax()
		return 1
	end
	
	function HDH_AURA_TRACKER:GetAuras()
		local aura, f, spell
		local curTime = GetTime()
		local ret = 0

		for i = 1, #self.frame.icon do
			self.frame.icon[i].spell.isUpdate = false
		end
		
		for i = 1, 40 do 
			aura = C_UnitAuras.GetAuraDataByIndex(self.unit, i, self.filter)
			if not aura then break end

			if self.aura_caster == DB.AURA_CASTER_ONLY_MINE then
				if aura.sourceUnit == 'player' then
					f = self.frame.pointer[aura.spellId] or self.frame.pointer[aura.name]
				else
					f = nil
				end
			else
				f = self.frame.pointer[aura.spellId] or self.frame.pointer[aura.name]
			end
			if f and f.spell then
				spell = f.spell
				if not StaggerID[aura.spellId] then -- 시간차가 아니면
					spell.v1 = (aura.points[1] ~= 0) and aura.points[1] or nil
				else -- 시간차
					spell.v1 = aura.points[2]
				end

				if not spell.isUpdate then
					spell.count = aura.applications
				else
					spell.count = (spell.count or 0) + aura.applications
				end
				spell.id = aura.spellId
				spell.dispelType = aura.dispelName or ""

				if spell.isUpdate then
					spell.overlay = (spell.overlay or 0) + 1
				else
					spell.overlay = 1
				end

				if spell.endTime ~= aura.expirationTime then spell.endTime = aura.expirationTime ; spell.happenTime = curTime end
				if aura.expirationTime  > 0 then spell.remaining = spell.endTime - curTime
				else spell.remaining = 0; end
				spell.duration = aura.duration
				spell.startTime = aura.expirationTime - aura.duration

				if HDH_TRACKER.startTime > spell.startTime then
					spell.duration = spell.duration - (HDH_TRACKER.startTime - spell.startTime)
					spell.startTime = HDH_TRACKER.startTime
				end

				spell.countMax = math.max(spell.count or 0, spell.countMax or 0)
				spell.valueMax = math.max(spell.v1 or 0, spell.valueMax or 0)
				spell.durationMax = math.max(spell.duration or 0, spell.durationMax or 0)

				spell.index = i -- 툴팁을 위해, 순서
				spell.isUpdate = true
				ret = ret + 1
			end
		end
		for i = 1, #self.frame.icon do
			if not self.frame.icon[i].spell.isUpdate then
				if self.frame.icon[i].spell.duration ~= 0 then
					self.frame.icon[i].spell.latestDuration = self.frame.icon[i].spell.duration
				end
				self.frame.icon[i].spell.duration = 0
				self.frame.icon[i].spell.count = 0
				self.frame.icon[i].spell.v1 = 0
				self.frame.icon[i].spell.overlay = 0
				self.frame.icon[i].spell.startTime = 0
				self.frame.icon[i].spell.endTime = 1
			end
		end

		return ret;
	end

	function HDH_AURA_TRACKER:GetAurasAll()
		local aura, spell
		local curTime = GetTime()
		local f
		self.prevUpdateCount = self.updateCount
		for i = 1, 40 do 
			aura = C_UnitAuras.GetAuraDataByIndex(self.unit, i, self.filter)
			if not aura then
				break
			end
			if self.aura_filter == DB.AURA_FILTER_ONLY_BOSS then
				if not aura.isFromPlayerOrPlayerPet and (self.isRaiding or (aura.isBossAura)) then
					f = self.frame.icon[i]
				else
					f = nil
				end
			elseif self.aura_caster == DB.AURA_CASTER_ONLY_MINE then
				if aura.sourceUnit == 'player' then
					f = self.frame.icon[i]
				else
					f = nil
				end
			else
				f = self.frame.icon[i]
			end
			
			if f then
				if not f.spell then f.spell = {} end
				spell = f.spell
				spell.no = i;
				spell.isUpdate = true
				spell.count = aura.applications
				spell.id = aura.spellId
				spell.overlay = 0
				spell.endTime = aura.expirationTime
				spell.name = aura.name;
				spell.dispelType = aura.dispelName
				spell.remaining = spell.endTime - curTime
				spell.duration = aura.duration
				spell.startTime = aura.expirationTime - aura.duration
				spell.icon = aura.icon
				spell.index = i; -- 툴팁을 위해, 순서
				spell.happenTime = curTime
				spell.isLearned = true
				if spell.duration == 0 then
					spell.latestDuration = 1
				end

				if HDH_TRACKER.startTime > spell.startTime then
					spell.startTime = HDH_TRACKER.startTime
					spell.duration = spell.duration - (HDH_TRACKER.startTime - spell.startTime)
				end

				f.icon:SetTexture(aura.icon)
				
				self.updateCount = i
			end
		end
		for i = (self.updateCount or 0) + 1, self.prevUpdateCount or 0 do
			self.frame.icon[i].spell.isLearned = false
			self.frame.icon[i].spell.isUpdate = false
		end
	end
	
	function HDH_AURA_TRACKER:MatchBossUnit(target_unit)
		local ret = false;
		if self.boss_guid and target_unit then
			for i = 1, MAX_BOSS_FRAMES do
			local boss_unit = "boss"..i;
				if ExstisUnit(boss_unit) then
					local boss_guid = UnitGUID(boss_unit);
					if Uboss_guid and boss_guid == UnitGUID(target_unit) then
						return true;
					end
				end
			end
		end
		return ret;
	end

	function HDH_AURA_TRACKER:UpdateIconAndBar(index)
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local icons = self.frame.icon
		local aura_caster = self.aura_caster
		local display_mode = self.ui.common.display_mode

		for _, f in ipairs(icons) do
			if not f.spell then break end
			if f.spell.isUpdate then
				if aura_caster == DB.AURA_CASTER_ONLY_MINE then
					f.counttext:SetText(f.spell.count >= 2 and f.spell.count or "")
				else
					if f.spell.count < 2 then f.counttext:SetText(f.spell.overlay >= 2 and f.spell.overlay or "")
										 else f.counttext:SetText(f.spell.count) end
				end

				f.icon:UpdateCooldowning()
				f.v1:SetText((f.spell.showValue and f.spell.v1) and HDH_AT_UTIL.AbbreviateValue(f.spell.v1, self.ui.font.v1_abbreviate) or nil)
				if f.spell.duration == 0 then
					f.timetext:SetText("")
					f.icon:SetCooldown(0, 1, false)
					f.icon:SetValue(0)
				else
					self:UpdateTimeText(f.timetext, f.spell.remaining)
					f.icon:SetCooldown(f.spell.startTime, f.spell.duration)
				end

				if self.ui.common.default_color then
					if f.spell.dispelType == nil then
						f.icon:SetBorderColor(unpack(self.ui.icon.active_border_color))
						if f.bar then
							f.bar:SetStatusBarColor(unpack(self.ui.icon.active_border_color))
						end
					else
						f.icon:SetBorderColor(DebuffTypeColor[f.spell.dispelType].r, DebuffTypeColor[f.spell.dispelType].g, DebuffTypeColor[f.spell.dispelType].b, 1)
						if f.bar then
							f.bar:SetStatusBarColor(DebuffTypeColor[f.spell.dispelType].r, DebuffTypeColor[f.spell.dispelType].g, DebuffTypeColor[f.spell.dispelType].b, 1)
						end
					end
				end

				if display_mode ~= DB.DISPLAY_ICON and f.bar then
					f.bar:SetText(f.spell.name)
					if f.spell.duration == 0 and f.spell.barValueType == DB.BAR_TYPE_BY_TIME then
						self:UpdateBarMinMaxValue(f, 0, 1, 0)
					else
						self:UpdateBarMinMaxValue(f)
					end
				end
				self:UpdateGlow(f, true)
			else
				if f.spell.isLearned then
					f.timetext:SetText(nil)
					f.icon:Stop()
					f.icon:UpdateCooldowning(false)
					f.v1:SetText(nil)
					f.counttext:SetText(nil)
					self:UpdateGlow(f, f.spell.glow == DB.GLOW_CONDITION_TIME)
					if display_mode ~= DB.DISPLAY_ICON and f.bar then 
						f.bar:SetText(f.spell.name)
						if self.ui.common.default_color and f.spell.dispelType then
							f.bar:SetStatusBarColor(DebuffTypeColor[f.spell.dispelType].r, DebuffTypeColor[f.spell.dispelType].g, DebuffTypeColor[f.spell.dispelType].b, 1)
						end
						if f.spell.barValueType == DB.BAR_TYPE_BY_TIME then
							-- self:UpdateBarMinMaxValue(f, 0, f.spell.latestDuration, f.spell.latestDuration)
							-- self:UpdateBarValue()
							self:UpdateBarFull(f)
						else
							self:UpdateBarMinMaxValue(f, nil, nil, 0)
						end
					end
				end
			end
		end

		if self.UpdateOrder then self:UpdateOrder() end
		return ret
	end

	function HDH_AURA_TRACKER:UpdateSpellInfo(index)
		self:GetAurasFunc()
	end

	function HDH_AURA_TRACKER:InitIcons()
		local trackerId = self.id
		local id, name, type, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
		if not id then return 0 end
		local f
		local ret = 0

		self.filter = (self.type == HDH_TRACKER.TYPE.BUFF) and "HELPFUL" or "HARMFUL"
		self.aura_filter = aura_filter
		self.aura_caster = aura_caster
		self.frame.pointer = {}

		if aura_filter == DB.AURA_FILTER_ALL or aura_filter == DB.AURA_FILTER_ONLY_BOSS then
			for i = 1 , 40 do
				f = self:CreateBaseIcon(i)
				f.spell = {}
				f.spell.barSplitPoints = {}
				f.spell.barValueType = DB.BAR_TYPE_BY_TIME
				f.spell.barMaxValueType = DB.BAR_MAXVALUE_TYPE_TIME
				f.spell.barMaxValue = nil
				self:UpdateIconSettings(f)
			end
			self.GetAurasFunc = HDH_AURA_TRACKER.GetAurasAll
			self.frame:UnregisterAllEvents()
			self.frame:SetScript("OnEvent", self.OnEvent)
			self:LoadOrderFunc()
			ret = 40
		else
			self.GetAurasFunc = HDH_AURA_TRACKER.GetAuras
			ret = super.InitIcons(self)
		end

		if aura_filter == DB.AURA_FILTER_ONLY_BOSS then
			self.frame:RegisterUnitEvent('UNIT_AURA', self.unit)
			self.frame:RegisterEvent("ENCOUNTER_START");
			self.frame:RegisterEvent("ENCOUNTER_END");
		end
		if #(self.frame.icon) > 0 or aura_filter == DB.AURA_FILTER_ALL then
			self.frame:RegisterUnitEvent('UNIT_AURA', self.unit)
			if self.unit == 'target' then
				self.frame:RegisterEvent('PLAYER_TARGET_CHANGED')
			elseif self.unit == 'focus' then
				self.frame:RegisterEvent('PLAYER_FOCUS_CHANGED')
			elseif string.find(self.unit, "boss") then 
				self.frame:RegisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT')
			elseif string.find(self.unit, "party") then
				self.frame:RegisterEvent('GROUP_ROSTER_UPDATE')
			elseif self.unit == 'pet' then
				self.frame:RegisterEvent('UNIT_PET')
			elseif string.find(self.unit, 'arena') then
				self.frame:RegisterEvent('ARENA_OPPONENT_UPDATE')
			end
			-- self.frame:RegisterUnitEvent('WEAPON_ENCHANT_CHANGED')
		else
			return 0
		end

		self:Update()
		return ret
	end

------------------------------------------
end -- TRACKER class
------------------------------------------


-------------------------------------------
-- 이벤트 메세지 function
-------------------------------------------

-- 차상위에서 호출됨
-- function HDH_AURA_TRACKER:PLAYER_ENTERING_WORLD()
-- end

function HDH_AURA_TRACKER:UNIT_AURA()
	self:Update()
end

-- function HDH_AURA_TRACKER:PLAYER_EQUIPMENT_CHANGED()
-- 	self:InitIcons()
-- end

function HDH_AURA_TRACKER:OnEvent(event, ...)
	local self = self.parent
	if not self then return end
	if event == 'UNIT_AURA' then
		local unit = select(1,...)
		if self and unit == self.unit then
			self:UNIT_AURA()
		end
	elseif event =="PLAYER_TARGET_CHANGED" then
		HDH_AT_UTIL.RunTimer(self, "PLAYER_TARGET_CHANGED", 0.005, self.UNIT_AURA, {self})
	elseif event == 'PLAYER_FOCUS_CHANGED' then
		self:UNIT_AURA()
	elseif event == 'INSTANCE_ENCOUNTER_ENGAGE_UNIT' then
		self:UNIT_AURA()
	elseif event == 'GROUP_ROSTER_UPDATE' then
		self:UNIT_AURA()
	elseif event == 'UNIT_PET' then
		HDH_AT_UTIL.RunTimer(self, "UNIT_PET", 0.5, self.UNIT_AURA, self) 
	elseif event == 'ARENA_OPPONENT_UPDATE' then
		HDH_AT_UTIL.RunTimer(self, "ARENA_OPPONENT_UPDATE", 0.5, self.UNIT_AURA, {self}) 
	elseif event == "ENCOUNTER_START" then
		self.isRaiding = true;
	elseif event == "ENCOUNTER_END" then
		self.isRaiding = false;
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		self:PLAYER_EQUIPMENT_CHANGED()
	end
end