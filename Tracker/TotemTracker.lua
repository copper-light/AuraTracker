local DB = HDH_AT_ConfigDB
local L = HDH_AT_L
HDH_TT_TRACKER = {}

HDH_TT_TRACKER.AdjustSpell = {}

HDH_TT_TRACKER.AdjustSpell[L.GREATER_EARTH_ELEMENTAL] = "198103"

HDH_TT_TRACKER.AdjustSpell[L.GREATER_STORM_ELEMENTAL] = "192249"
HDH_TT_TRACKER.AdjustSpell[L.LESSER_STORM_ELEMENTAL] = "192249"

HDH_TT_TRACKER.AdjustSpell[L.GREATER_FIRE_ELEMENTAL] = "198067"
HDH_TT_TRACKER.AdjustSpell[L.LESSER_FIRE_ELEMENTAL] = "198067"

HDH_TT_TRACKER.AdjustSpell[L.XUEN] = "123904"
HDH_TT_TRACKER.AdjustSpell[L.YU_LON] = "322118"
HDH_TT_TRACKER.AdjustSpell[L.NIUZAO] = "132578"
HDH_TT_TRACKER.AdjustSpell[L.JADE_SERPENT_STATUE] = "115313"

HDH_TT_TRACKER.AdjustSpell[L.RAISE_DEAD] = "46585"

------------------------------------
-- HDH_T_TRACKER class
------------------------------------
do
	local super = HDH_AURA_TRACKER
	setmetatable(HDH_TT_TRACKER, HDH_AURA_TRACKER) -- 상속
	HDH_TT_TRACKER.__index = HDH_TT_TRACKER
	HDH_TT_TRACKER.className = "HDH_TT_TRACKER"
	HDH_TRACKER.TYPE.TOTEM = 4
	HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.TOTEM, HDH_TT_TRACKER)

	-- 판다리아까지는 주술사 토템을 유형별로 1개씩 설치할 수 있음
	if select(4, GetBuildInfo()) <= 59999 then
		function HDH_TT_TRACKER:UpdateSpellInfo(index)
			local haveTotem, name, startTime, duration, icon, endTime, key, f
			if self.aura_filter ~= DB.AURA_FILTER_ALL then
				for i = 1, #self.frame.icon do
					self.frame.icon[i].spell.isUpdate = false
					self.frame.icon[i].spell.duration = 0
				end
			end

			for i =1, MAX_TOTEMS do
				haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
				if haveTotem then
					if self.aura_filter == DB.AURA_FILTER_ALL then
						f = self.frame.icon[i]
						f.spell = {}
						f.spell.icon = icon
						f.spell.isLearned = true
						f.icon:SetTexture(icon)
						f.spell.no = i
					else
						key = HDH_TT_TRACKER.AdjustSpell[name] or name
						f = self.frame.pointer[key]
					end
					if f and f.spell then
						f.spell.duration = duration
						f.spell.count = 0
						f.spell.overlay = 0
						f.spell.startTime = startTime
						f.spell.isUpdate = true
						f.spell.name = name
						endTime = startTime + duration
						f.spell.remaining = endTime - GetTime()
						if f.spell.endTime ~= endTime then
							f.spell.endTime = endTime;
							f.spell.happenTime = GetTime()
						end
					end
				else
					if self.aura_filter == DB.AURA_FILTER_ALL then
						f = self.frame.icon[i]
						f.spell.isLearned = false
						f.spell.isUpdate = false
					end
				end
			end
		end
	else 
		-- 드레노어 부터는 구분없이 총 4개 설치할 수 있도록 구성됨
		-- 하지만 토템 기본 인덱스는 순차적으로 오지 않음.
	    -- 따라서 토템 기본 인덱스 대신 별도의 순차적인 인덱스 사용 필요 : self.updateCount
		-- ???? 오더링 순서를 잘 모르겠음
		function HDH_TT_TRACKER:UpdateSpellInfo(index)
			local haveTotem, name, startTime, duration, icon, endTime, key, f
			if self.aura_filter ~= DB.AURA_FILTER_ALL then
				for i = 1, #self.frame.icon do
					self.frame.icon[i].spell.isUpdate = false
					self.frame.icon[i].spell.duration = 0
				end
			end
			self.prevUpdateCount = self.updateCount or 0
			self.updateCount = 0

			for i =1, MAX_TOTEMS do
				haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
				if haveTotem then
					if self.aura_filter == DB.AURA_FILTER_ALL then
						self.updateCount = self.updateCount + 1
						f = self.frame.icon[self.updateCount]
						f.spell = {}
						f.spell.icon = icon
						f.spell.isLearned = true
						f.icon:SetTexture(icon)
						f.spell.no = self.updateCount
					else
						key = HDH_TT_TRACKER.AdjustSpell[name] or name
						f = self.frame.pointer[key]
					end
					if f and f.spell then
						f.spell.duration = duration
						f.spell.count = 0
						f.spell.overlay = 0
						f.spell.startTime = startTime
						f.spell.isUpdate = true
						f.spell.name = name
						endTime = startTime + duration
						f.spell.remaining = endTime - GetTime()
						if f.spell.endTime ~= endTime then
							f.spell.endTime = endTime;
							f.spell.happenTime = GetTime()
						end
					end
				end
			end
			if self.aura_filter == DB.AURA_FILTER_ALL then
				for i = self.updateCount + 1, self.prevUpdateCount do
					self.frame.icon[i].spell.isLearned = false
					self.frame.icon[i].spell.isUpdate = false
				end
			end
		end
	end

	function HDH_TT_TRACKER:InitIcons()
		local trackerId = self.id
		local id, name, type, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
		if not id then return 0 end

		local barValueType, barMaxValueType, barMaxValue
		local f
		local ret = 0
		if aura_filter == DB.AURA_FILTER_ALL then
			self.aura_filter = aura_filter
			self.aura_caster = aura_caster
			self.unit = "player"
			self.frame.pointer = {}
			for i = 1 , MAX_TOTEMS do
				f = self:CreateBaseIcon(i)
				f.spell = {}
				f.spell.barSplitPoints = {}
				f.spell.barValueType = DB.BAR_TYPE_BY_TIME
				f.spell.barMaxValueType = DB.BAR_MAXVALUE_TYPE_TIME
				f.spell.barMaxValue = nil
				self:UpdateIconSettings(f)
			end
			
			self.frame:UnregisterAllEvents()
			self.frame:SetScript("OnEvent", self.OnEvent)
			self:LoadOrderFunc()
		else
			ret = HDH_TRACKER.InitIcons(self)
			for i = 1, ret do
				local spell = self.frame.icon[i].spell
				self.frame.pointer[spell.name] = self.frame.icon[i]
			end
		end

		if #(self.frame.icon) > 0 then
			self.frame:RegisterEvent("PLAYER_TOTEM_UPDATE")
		end

		self:Update()
		return ret
	end

end


-----------------------------------------------------------------------------
-- icon 정보 업데이트 
-----------------------------------------------------------------------------

function HDH_TT_TRACKER:OnEvent(event, ...)
	if not self.parent then return end
	local tracker = self.parent
	
	if event == "PLAYER_TOTEM_UPDATE" then
		tracker:Update()

	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		tracker:InitIcons()
	end
end

-------------------------------------------
-------------------------------------------