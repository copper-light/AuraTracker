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
	setmetatable(HDH_TT_TRACKER, HDH_AURA_TRACKER) -- 상속
	HDH_TT_TRACKER.__index = HDH_TT_TRACKER
	HDH_TT_TRACKER.className = "HDH_TT_TRACKER"
	HDH_TRACKER.TYPE.TOTEM = 4
	HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.TOTEM, HDH_TT_TRACKER)
	
	function HDH_TT_TRACKER:Update(...) -- HDH_TRACKER override
		if not self.frame or HDH_TRACKER.ENABLE_MOVE then return end
		local haveTotem, name, startTime, duration, icon, endTime
		local slot = ... or MAX_TOTEMS
		local ui = self.ui
		local f
		local ret = 1;
		if not self.frame.pointer or not ui then return end
		if ( slot <= MAX_TOTEMS ) then
			for i =1, MAX_TOTEMS do
				haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
				if haveTotem then
					if self.aura_filter == DB.AURA_FILTER_ALL then
						f = self.frame.icon[ret];
						f.spell = {};
						f.spell.icon = icon;
						f.icon:SetTexture(icon);
						f.iconSatCooldown:SetTexture(icon)
						f.no = i;
						ret = ret +1;
					else
						if HDH_TT_TRACKER.AdjustSpell[name] then
							name = HDH_TT_TRACKER.AdjustSpell[name]
						end
						f = self.frame.pointer[name];
					end
					if f and f.spell then
						f.spell.duration = duration
						f.spell.count = 0
						f.spell.overlay = 0
						f.spell.startTime = startTime
						f.spell.isUpdate = true
						f.spell.name = name
						endTime = startTime + duration;
						f.spell.remaining = endTime-GetTime();
						if f.spell.endTime ~= endTime then
							f.spell.endTime = endTime;
							f.spell.happenTime = GetTime();
						end
						f.spell.slot = i;
						f.spell.isUpdate = true;
					end
				end
			end
		end
		if (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
				and ((self:UpdateAllIcons() > 0) or self.ui.common.always_show or UnitAffectingCombat("player")) then
			self:ShowTracker();
		else
			self:HideTracker();
		end
	end

	
	function HDH_TT_TRACKER:InitIcons() -- HDH_TRACKER override
		-- if HDH_TRACKER.ENABLE_MOVE then return end
		local trackerId = self.id
		local id, name, type, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
		self.aura_filter = aura_filter
		self.aura_caster = aura_caster
		if not id then return end
		local elemKey, elemId, elemName, texture, display, glowType, isValue, isItem, glowCondition, glowValue, glowEffectType, glowEffectColor, glowEffectPerSec
		local connectedId, connectedIsItem, unlearnedHideMode
		local elemSize = DB:GetTrackerElementSize(trackerId)
		local spell 
		local f
		local iconIdx = 0;
		local isLearned = false
		local needEquipmentEvent = false
		self.frame.pointer = {}

		if aura_filter == DB.AURA_FILTER_ALL then
			if #(self.frame.icon) > 0 then self:ReleaseIcons() end
		else
			for i = 1, elemSize do
				elemKey, elemId, elemName, texture, display, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
				display, connectedId, connectedIsItem, unlearnedHideMode = DB:GetTrackerElementDisplay(trackerId, i)
				glowType, glowCondition, glowValue, glowEffectType, glowEffectColor, glowEffectPerSec = DB:GetTrackerElementGlow(trackerId, i)
				if connectedId then
					isLearned = HDH_AT_UTIL.IsLearnedSpellOrEquippedItem(connectedId, nil, connectedIsItem)
					if connectedIsItem then
						needEquipmentEvent = true
					end
				else
					isLearned = true
				end
				if unlearnedHideMode ~= DB.SPELL_HIDE or isLearned then
					iconIdx = iconIdx + 1
					f = self.frame.icon[iconIdx]
					if f:GetParent() == nil then f:SetParent(self.frame) end
					spell = {}

					if isLearned then
						self.frame.pointer[elemKey or tostring(elemId)] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
					else
						spell.blankDisplay = true
						f:Hide()
					end

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
					spell.id = tonumber(elemId)
					spell.count = 0
					spell.duration = 0
					spell.remaining = 0
					spell.overlay = 0
					spell.endTime = 0
					spell.is_buff = isBuff;
					spell.isUpdate = false
					spell.isItem =  isItem
					f.spell = spell
					f.icon:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
					f.iconSatCooldown:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
					f.iconSatCooldown:SetDesaturated(nil)
					self:ChangeCooldownType(f, self.ui.icon.cooldown)
					self:UpdateGlow(f, false)
					self.frame.pointer[spell.name] = f;
				end
			end
			for i = #(self.frame.icon) , iconIdx+1, -1  do
				self:ReleaseIcon(i)
			end
		end
		self:LoadOrderFunc();
		self.frame:UnregisterAllEvents()
		if #(self.frame.icon) > 0 or aura_filter == DB.AURA_FILTER_ALL then
			self.frame:SetScript("OnEvent", HDH_TT_OnEvent)
			self.frame:RegisterEvent("PLAYER_TOTEM_UPDATE");
			--self.frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
			if needEquipmentEvent then
				self.frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
			end
		end
		self:Update()
	end
	
end


-----------------------------------------------------------------------------
-- icon 정보 업데이트 
-----------------------------------------------------------------------------

function HDH_TT_OnEvent(self, event, ...)
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