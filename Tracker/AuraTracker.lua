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
	
	function HDH_AURA_TRACKER.GetAuras(self)
		local curTime = GetTime()
		local name, count, duration, endTime, source, id, v1, v2, v3, dispelType
		local ret = 0;
		local f
		local spell

		for i = 1, 40 do 
			-- name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod
			name, _, count, dispelType, duration, endTime, source, _, _, id, _, _, _, _, _, v1, v2, v3 = UnitAura(self.unit, i, self.filter)
			if not id then break end

			if self.aura_caster == DB.AURA_CASTER_ONLY_MINE then
				if source == 'player' then
					f = self.frame.pointer[tostring(id)] or self.frame.pointer[name]
				else
					f = nil
				end
			else
				f = self.frame.pointer[tostring(id)] or self.frame.pointer[name]
			end
			if f and f.spell then

				spell = f.spell
				
				if not StaggerID[id] then -- 시간차가 아니면
					spell.v1 = (v1 ~= 0) and v1 or nil
				else -- 시간차
					spell.v1 = v2; 
				end
				
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
		end
		return ret;
	end
	
	function HDH_AURA_TRACKER.GetAurasAll(self)
		local name, icon, count, dispelType, duration, endTime, source, id, canApplyAura, isBossDebuff, castByPlayer 
		local curTime = GetTime()
		local ret = 1;
		local f
		for i = 1, 40 do 
			name, icon, count, dispelType, duration, endTime, source, _, _, id, canApplyAura, isBossDebuff, castByPlayer = UnitAura(self.unit, i, self.filter)
			if not id then break end
			if self.aura_filter == DB.AURA_FILTER_ONLY_BOSS then
				if not castByPlayer and (self.isRaiding or (isBossDebuff)) then
					f = self.frame.icon[ret];
				else
					f = nil;
				end
			elseif self.aura_caster == DB.AURA_CASTER_ONLY_MINE then
				if source == 'player' then
					f = self.frame.icon[ret];
				else
					f = nil;
				end
			else
				f = self.frame.icon[ret];
			end
			
			if f then
				if not f.spell then f.spell = {} end
				spell = f.spell
				spell.no = i;
				spell.isUpdate = true
				spell.count = count
				spell.id = id
				spell.overlay = 0
				spell.endTime = endTime
				spell.name = name;
				spell.dispelType = dispelType
				spell.remaining = spell.endTime - curTime
				spell.duration = duration 	
				spell.startTime = endTime - duration
				spell.icon = icon
				spell.index = i; -- 툴팁을 위해, 순서
				spell.happenTime = GetTime();
				f.icon:SetTexture(icon)
				f.iconSatCooldown:SetTexture(icon)
				ret = ret + 1;
			end
		end
		for i = ret, #(self.frame.icon) do
			self.frame.icon[i]:Hide()
		end
	end

	function HDH_AURA_TRACKER:IsRaiding()
		local boss_unit, boss_guid
		for i = 1, MAX_BOSS_FRAMES do
			boss_unit = "boss"..i;
			boss_guid = UnitGUID(boss_unit);
			if boss_guid then
				return true
			end
		end
		return false
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
	
	function HDH_AURA_TRACKER:UpdateIcons()
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local column_count = self.ui.common.column_count or 10-- 한줄에 몇개의 아이콘 표시
		local margin_h = self.ui.common.margin_h
		local margin_v = self.ui.common.margin_v
		-- local size = self.ui.icon.size -- 아이콘 간격 띄우는 기본값
		local reverse_v = self.ui.common.reverse_v -- 상하반전
		local reverse_h = self.ui.common.reverse_h -- 좌우반전
		local icons = self.frame.icon
		local aura_filter = self.aura_filter
		local aura_caster = self.aura_caster
		local display_mode = self.ui.common.display_mode
		local cooldown_type = self.ui.icon.cooldown
		local i = 0 -- 몇번째로 아이콘을 출력했는가?
		local col = 0  -- 열에 대한 위치 좌표값 = x
		local row = 0  -- 행에 대한 위치 좌표값 = y
		if self.OrderFunc then self.OrderFunc(self) end 

		local size_w, size_h
		if self.ui.common.display_mode == DB.DISPLAY_BAR then
			size_w = self.ui.bar.width
			size_h = self.ui.bar.height
		elseif self.ui.common.display_mode == DB.DISPLAY_ICON_AND_BAR then
			if self.ui.bar.location == DB.BAR_LOCATION_R or self.ui.bar.location == DB.BAR_LOCATION_L then
				size_w = self.ui.bar.width + self.ui.icon.size
				size_h = max(self.ui.bar.height, self.ui.icon.size)
			else
				size_h = self.ui.bar.height + self.ui.icon.size
				size_w = max(self.ui.bar.width, self.ui.icon.size)
			end
			
		else
			size_w = self.ui.icon.size -- 아이콘 간격 띄우는 기본값
			size_h = self.ui.icon.size
		end
		
		for k,f in ipairs(icons) do
			if not f.spell then break end
			if f.spell.isUpdate then
				if not HDH_TRACKER.ENABLE_MOVE then
					f.spell.isUpdate = false
				end
				if aura_caster == DB.AURA_CASTER_ONLY_MINE then
					if f.spell.count < 2 then f.counttext:SetText(nil)
										 else f.counttext:SetText(f.spell.count) end
				else
					if f.spell.count < 2 then if f.spell.overlay <= 1 then f.counttext:SetText(nil)
																      else f.counttext:SetText(f.spell.overlay) end
										 else f.counttext:SetText(f.spell.count)  end
				end
				
				if f.spell.showValue and f.spell.v1 then 
					f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(f.spell.v1, self.ui.font.v1_abbreviate)) 
				else 
					f.v1:SetText(nil) 
				end
				
				if f.spell.duration == 0 then 
					f.cd:Hide() f.timetext:SetText("");
					f.icon:SetDesaturated(nil)
			    	f.icon:SetAlpha(self.ui.icon.on_alpha)
			    	f.border:SetAlpha(self.ui.icon.on_alpha)
					f.iconSatCooldown:Hide()
					f.iconSatCooldown.spark:Hide()
				else 
					f.cd:Show()
					
					self:UpdateTimeText(f.timetext, f.spell.remaining)
					
					if cooldown_type ~= DB.COOLDOWN_CIRCLE and  cooldown_type ~= DB.COOLDOWN_NONE then
						f.icon:SetAlpha(self.ui.icon.off_alpha)
						f.border:SetAlpha(self.ui.icon.off_alpha)
						f.icon:SetDesaturated(1)
						f.iconSatCooldown:SetAlpha(self.ui.icon.on_alpha)
						f.iconSatCooldown:Show()
					else
						f.icon:SetAlpha(self.ui.icon.on_alpha)
						f.border:SetAlpha(self.ui.icon.on_alpha)
						f.icon:SetDesaturated(nil)
					end
				end
				if not self.ui.common.default_color or f.spell.dispelType == nil then 
					f.border:SetVertexColor(unpack(self.ui.icon.active_border_color))
				else 
					f.border:SetVertexColor(
						DebuffTypeColor[f.spell.dispelType or ""].r, 
						DebuffTypeColor[f.spell.dispelType or ""].g, 
						DebuffTypeColor[f.spell.dispelType or ""].b,
						1
					)
				end
				if cooldown_type == DB.COOLDOWN_CIRCLE or cooldown_type == DB.COOLDOWN_NONE then
					if HDH_TRACKER.startTime < f.spell.startTime or (f.spell.duration == 0) then
						f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
					else
						f.cd:SetCooldown(HDH_TRACKER.startTime, f.spell.duration - (f.spell.startTime - HDH_TRACKER.startTime));
					end
				else
					f.cd:SetMinMaxValues(f.spell.startTime, f.spell.endTime);
					f.cd:SetValue(GetTime());
				end
				if display_mode ~= DB.DISPLAY_ICON and f.bar then
					if not f.bar:IsShown() then f.bar:Show(); end
					f.name:SetText(f.spell.name);
					if f.spell.duration == 0 then
						f.spell.remaining = 1;
						f.spell.endTime = 1;
						f.spell.startTime = 0;
					else
						-- f.bar:SetMinMaxValues(f.spell.startTime, f.spell.endTime);
						-- f.bar:SetValue(f.spell.startTime+ f.spell.remaining);
						-- self:UpdateBarValue(f);
					end
					f.iconSatCooldown.spark:Hide()
					self:UpdateBarValue(f);
				end
				f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
				i = i + 1
				if i % column_count == 0 then row = row + size_h + margin_v; col = 0
								         else col = col + size_w + margin_h end
				ret = ret + 1
				f:Show()
				self:SetGlow(f, true)
			else
				f.timetext:SetText(nil);
				if f.spell.display == DB.SPELL_ALWAYS_DISPLAY then 
					f.icon:SetDesaturated(1)
					f.icon:SetAlpha(self.ui.icon.off_alpha)
					f.border:SetAlpha(self.ui.icon.off_alpha)
					f.border:SetVertexColor(0,0,0) 
					f.v1:SetText(nil)
					f.counttext:SetText(nil)
					f.cd:Hide()
					f.iconSatCooldown.spark:Hide() 
					f.iconSatCooldown:Hide() 
					if display_mode ~= DB.DISPLAY_ICON and f.bar then 
						if not f.bar:IsShown() then f.bar:Show(); end
						f.name:SetText(f.spell.name);
						self:UpdateBarValue(f, true);
					end--f.bar:Hide();
					f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
					i = i + 1
					if i % column_count == 0 then 
						row = row + size_h + margin_v; col = 0
					else 
						col = col + size_w + margin_h 
					end
					f:Show()
					
					self:SetGlow(f, f.spell.glow == DB.GLOW_CONDITION_TIME)
				else
					if f.spell.display == DB.SPELL_HIDE_AS_SPACE and self.ui.common.order_by == DB.ORDERBY_REG then
						i = i + 1
						if i % column_count == 0 then row = row + size_h + margin_v; col = 0
										 else col = col + size_w + margin_h end
					end
					f:Hide()
				end
				f.spell.endTime = nil;
				f.spell.duration = 0;
				f.spell.duration = 0;
				f.spell.remaining = 0;
				f.spell.happenTime = nil;
				f.spell.overlay = 0
				f.spell.count = 0
			end
		end
		return ret
	end

	-- 버프, 디버프의 상태가 변경 되었을때 마다 실행되어, 데이터 리스트를 업데이트 하는 함수
	function HDH_AURA_TRACKER:Update()
		if not self.frame or HDH_TRACKER.ENABLE_MOVE then return end
		if not UnitExists(self.unit) or not self.frame.pointer or not self.ui then 
			self.frame:Hide() return 
		end
		self.GetAurasFunc(self)

		if (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
				and ((self:UpdateIcons() > 0) or UnitAffectingCombat("player") or self.ui.common.always_show) then 
			self:ShowTracker();
		else
			self:HideTracker();
		end
	end

	function HDH_AURA_TRACKER:InitIcons()
		-- if HDH_TRACKER.ENABLE_MOVE then return end
		local trackerId = self.id
		local id, name, type, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
		self.aura_filter = aura_filter
		self.aura_caster = aura_caster
		if not id then return end
		local elemKey, elemId, elemName, texture, display, glowType, isValue, isItem, glowCondition, glowValue, hideMode
		local elemSize = DB:GetTrackerElementSize(trackerId)
		local spell 
		local f
		local iconIdx = 0;
		self.frame.pointer = {}

		if self.type == HDH_TRACKER.TYPE.BUFF then 
			self.filter = "HELPFUL"
		else 
			self.filter = "HARMFUL"
		end

		if aura_filter == DB.AURA_FILTER_ALL or aura_filter == DB.AURA_FILTER_ONLY_BOSS then
			self.GetAurasFunc = HDH_AURA_TRACKER.GetAurasAll
			if #(self.frame.icon) > 0 then self:ReleaseIcons() end
		else
			for i = 1, elemSize do
				elemKey, elemId, elemName, texture, display, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
				display, hideMode = DB:GetTrackerElementDisplay(trackerId, i)
				glowType, glowCondition, glowValue = DB:GetTrackerElementGlow(trackerId, i)
				iconIdx = iconIdx + 1
				f = self.frame.icon[iconIdx]
				if f:GetParent() == nil then f:SetParent(self.frame) end
				self.frame.pointer[elemKey] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
				spell = {}
				spell.glow = glowType
				spell.glowCondtion = glowCondition
				spell.glowValue = (glowValue and tonumber(glowValue)) or 0
				spell.showValue = isValue
				spell.display = display
				spell.hideMode = hideMode
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
				-- spell.is_buff = isBuff;
				spell.isUpdate = false
				spell.isItem =  isItem
				f.spell = spell
				f.icon:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
				f.iconSatCooldown:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
				f.iconSatCooldown:SetDesaturated(nil)
				self:ChangeCooldownType(f, self.ui.icon.cooldown)
				self:SetGlow(f, false)
			end
			self.GetAurasFunc = HDH_AURA_TRACKER.GetAuras
			for i = #(self.frame.icon) , iconIdx+1, -1  do
				self:ReleaseIcon(i)
			end
		end
		self:LoadOrderFunc();
		
		self.frame:SetScript("OnEvent", OnEventTracker)
		self.frame:UnregisterAllEvents()

		if aura_filter == DB.AURA_FILTER_ONLY_BOSS then
			self.frame:RegisterEvent('UNIT_AURA')
			self.frame:RegisterEvent("ENCOUNTER_START");
			self.frame:RegisterEvent("ENCOUNTER_END");
		end
		if #(self.frame.icon) > 0 or aura_filter == DB.AURA_FILTER_ALL then
			self.frame:RegisterEvent('UNIT_AURA')
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
		else
			return 
		end
		
		self:Update()
		return iconIdx;
	end

	function HDH_AURA_TRACKER:PLAYER_ENTERING_WORLD()
		self.isRaiding = self:IsRaiding()
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

