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

	function HDH_TT_TRACKER:Update(...) -- HDH_TRACKER override
		if not self.frame or HDH_TRACKER.ENABLE_MOVE then return end
		local haveTotem, name, startTime, duration, icon, endTime
		-- local slot = ... or MAX_TOTEMS
		local ui = self.ui
		local f
		local key
		local ret = 1

		if not self.frame.pointer or not ui then return end
		for i =1, MAX_TOTEMS do
			haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
			if haveTotem then
				if self.aura_filter == DB.AURA_FILTER_ALL then
					f = self.frame.icon[ret]
					f.spell = {}
					f.spell.icon = icon
					f.icon:SetTexture(icon)
					f.no = i
					ret = ret +1
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
					f.spell.slot = i
				end
			end
		end
		if (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
				and ((self:UpdateAllIcons() > 0) or self.ui.common.always_show or UnitAffectingCombat("player")) then
			self:ShowTracker()
		else
			self:HideTracker()
		end
	end

	function HDH_TT_TRACKER:InitIcons()
		local trackerId = self.id
		local id, name, type, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
		if not id then return 0 end

		local barValueType, barMaxValueType, barMaxValue, splitPoints, splitPointType
		local f
		local ret = 0

		self.filter = (self.type == HDH_TRACKER.TYPE.BUFF) and "HELPFUL" or "HARMFUL"
		self.aura_filter = aura_filter
		self.aura_caster = aura_caster
		self.frame.pointer = {}

		if aura_filter == DB.AURA_FILTER_ALL then
			for i = 1 , MAX_TOTEMS do
				barValueType, barMaxValueType, barMaxValue, splitPoints, splitPointType = DB:GetTrackerElementBarInfo(trackerId, i)
				f = self.frame.icon[i]
				if f:GetParent() == nil then f:SetParent(self.frame) end

				f.spell = {}
				f.spell.barSplitPoints = splitPoints
				f.spell.barSplitPointType = splitPointType
				f.spell.barValueType = barValueType
				f.spell.barMaxValueType = barMaxValueType
				f.spell.barMaxValue = barMaxValue
				-- f:Hide()
				if f.bar then
					f.bar:SetSplitPoints(spell.barSplitPoints, spell.barSplitPointType)
				end
			end
			
			self.frame:UnregisterAllEvents()
			self.frame:SetScript("OnEvent", self.OnEvent)
			self:LoadOrderFunc()
		else
			ret = super.InitIcons(self)
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
		if not HDH_TRACKER.ENABLE_MOVE then
			tracker:Update(...)
		end
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		tracker:InitIcons()
	end
end

-------------------------------------------
-------------------------------------------