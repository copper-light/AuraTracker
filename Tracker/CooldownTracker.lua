local DB = HDH_AT_ConfigDB

HDH_C_TRACKER = {}
HDH_C_TRACKER.GlobalCooldown = 1.9; -- default GC: 1.332
HDH_C_TRACKER.EndCooldown = 0.09;

------------------------------------
-- HDH_C_TRACKER class
------------------------------------
local super = HDH_AURA_TRACKER
setmetatable(HDH_C_TRACKER, super) -- 상속
HDH_C_TRACKER.__index = HDH_C_TRACKER
HDH_C_TRACKER.className = "HDH_C_TRACKER"
HDH_TRACKER.TYPE.COOLDOWN = 3
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.COOLDOWN, HDH_C_TRACKER)

-----------------------------------
-- OnUpdate icon
-----------------------------------

-- local function CT_UpdateCooldownSatIcon(tracker, f, spell)
-- 	if spell.per < 0.99 and spell.per >= 0.01  then
-- 		if not f.iconSatCooldown.spark:IsShown() then
-- 			f.iconSatCooldown.spark:Show()
-- 		end
-- 	else
-- 		if f.iconSatCooldown.spark:IsShown() then
-- 			f.iconSatCooldown.spark:Hide()
-- 		end
-- 	end

-- 	if spell.per > 0 then 
-- 		f.iconSatCooldown.curSize = math.ceil(f.icon:GetHeight() * spell.per * 10) /10
-- 		f.iconSatCooldown.curSize = f.iconSatCooldown.curSize - (f.iconSatCooldown.curSize % 0.5)
-- 		f.iconSatCooldown.curSize = math.max(f.iconSatCooldown.curSize, 0.1)
-- 		f.iconSatCooldown:Show()
-- 	else
-- 		spell.per = 0.1
-- 		f.iconSatCooldown.curSize = 1
-- 		f.iconSatCooldown:Hide()
-- 	end

-- 	if (f.iconSatCooldown.curSize ~= f.iconSatCooldown.preSize) then
-- 		if (f.iconSatCooldown.curSize == 0) then f.iconSatCooldown:Hide() end
-- 		if tracker.ui.icon.cooldown == DB.COOLDOWN_LEFT then
-- 			spell.texcoord = 0.93 - (0.86 * spell.per)
-- 			f.iconSatCooldown:SetWidth(f.iconSatCooldown.curSize)
-- 			f.iconSatCooldown:SetTexCoord(spell.texcoord, 0.93, 0.07, 0.93)

-- 		elseif tracker.ui.icon.cooldown == DB.COOLDOWN_RIGHT then
-- 			spell.texcoord = 0.07 + (0.86 * spell.per)
-- 			f.iconSatCooldown:SetWidth(f.iconSatCooldown.curSize)
-- 			f.iconSatCooldown:SetTexCoord(0.07, spell.texcoord, 0.07, 0.93)

-- 		elseif tracker.ui.icon.cooldown == DB.COOLDOWN_UP then
-- 			spell.texcoord = 0.93 - (0.86 * spell.per)
-- 			f.iconSatCooldown:SetHeight(f.iconSatCooldown.curSize)
-- 			f.iconSatCooldown:SetTexCoord(0.07, 0.93, spell.texcoord, 0.93)
-- 		else
-- 			spell.texcoord = 0.07 + (0.86 * spell.per)
-- 			f.iconSatCooldown:SetHeight(f.iconSatCooldown.curSize)
-- 			f.iconSatCooldown:SetTexCoord(0.07, 0.93, 0.07, spell.texcoord)
-- 		end
-- 		f.iconSatCooldown.preSize = f.iconSatCooldown.curSize
-- 	end
-- end

local function CT_UpdateCooldown(tracker, f, elapsed)
	if not f.spell then return end
	f.spell.remaining = f.spell.endTime - f.spell.curTime

	if f.spell.remaining > HDH_C_TRACKER.EndCooldown and f.spell.duration > 0 then
		if (not f.spell.isCharging or f.spell.remaining > 0) and f.spell.duration > HDH_C_TRACKER.GlobalCooldown then
			tracker:UpdateTimeText(f.timetext, f.spell.remaining)
		end
		if tracker.ui.icon.cooldown ~= DB.COOLDOWN_CIRCLE and tracker.ui.icon.cooldown ~= DB.COOLDOWN_NONE then
			if not f.spell.isCharging or f.spell.remaining > 0 then
				HDH_AT_UpdateCooldownSatIcon(f, (1 - (f.spell.remaining / f.spell.duration)), tracker.ui.icon.cooldown, true)
			end
		end
		if tracker.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar and f.spell.duration > HDH_C_TRACKER.GlobalCooldown then
			f.bar:SetValue(f.spell.curTime)
		end
	elseif f.spell.isCharging and f.spell.remaining <= 0 then
		f.spell.charges.remaining = f.spell.charges.endTime - f.spell.curTime
		tracker:UpdateTimeText(f.timetext, f.spell.charges.remaining)
		if tracker.ui.icon.cooldown ~= DB.COOLDOWN_CIRCLE and tracker.ui.icon.cooldown ~= DB.COOLDOWN_NONE then
			HDH_AT_UpdateCooldownSatIcon(f, (1 - (f.spell.charges.remaining / f.spell.charges.duration)), tracker.ui.icon.cooldown, true)
		end
	elseif tracker.type == HDH_TRACKER.TYPE.COOLDOWN then
		if( tracker:UpdateIcon(f)) or (not tracker.ui.common.always_show and not UnitAffectingCombat("player")) then
			tracker:UpdateLayout()
		end
	end

	if f.spell.glow == DB.GLOW_CONDITION_TIME and f.spell.duration > HDH_C_TRACKER.GlobalCooldown then
		tracker:UpdateGlow(f, true)
	end
end

local function CT_OnUpdateIcon(self, elapsed) -- 거리 체크는 onUpdate 에서 처리해야함
	if not self.spell then return end
	self.spell.curTime = GetTime();
	if self.spell.curTime - (self.spell.delay or 0) < 0.05  then return end -- 10프레임
	self.spell.delay = self.spell.curTime;
	
	if self.spell.slot then
		self.spell.newRange = IsActionInRange(self.spell.slot) 
	else
		if UnitExists('target') then
			if not self.spell.isItem then
				self.spell.newRange = HDH_AT_UTIL.IsSpellInRange(self.spell.name, "target"); -- 1 true, 0 false, nil not target
			else
				self.spell.newRange = C_Item.IsItemInRange(self.spell.id, "target")
			end
		elseif UnitExists('mouseover') then
			if not self.spell.isItem then
				self.spell.newRange = HDH_AT_UTIL.IsSpellInRange(self.spell.name, "mouseover"); -- 1 true, 0 false, nil not target
			else
				self.spell.newRange = C_Item.IsItemInRange(self.spell.id, "mouseover")
			end
		else
			self.spell.newRange = nil
		end
	end

	if self.spell.preInRage ~= self.spell.newRange then
		self:GetParent().parent:UpdateIcon(self);
		self.spell.preInRage = self.spell.newRange;
	end
	CT_UpdateCooldown(self:GetParent().parent, self, elapsed)
end

local function OnUpdateCheckRange(frame, elapsed)
	frame.curTime = GetTime()
	if frame.curTime - (frame.delay or 0) < 0.1 then return end -- 10프레임
	frame.delay = frame.curTime
	-- print("check")

	if not UnitExists('target') and not UnitExists('mouseover') then
		frame:SetScript('OnUpdate', nil)
	end
end

-- 매 프레임마다 bar frame 그려줌, 콜백 함수
-- function CT_OnUpdateCooldown(self, elapsed)
-- 	CT_UpdateCooldown(self:GetParent():GetParent(), elapsed)
-- end 

-- 아이콘이 보이지 않도록 설정되면, 바에서 업데이트 처리를 한다
-- function HDH_C_TRACKER:OnUpdateBarValue(elapsed)
-- 	CT_UpdateCooldown(self:GetParent(), elapsed)
-- end


------- HDH_C_TRACKER member function -----------	

function HDH_C_TRACKER:UpdateState(id, name, isItem, isToy)
	local inRange, isAble, isNotEnoughMana
	if isItem then
		inRange = C_Item.IsItemInRange(id, "target")
		if not isToy then
			isAble = C_Item.IsUsableItem(id)
		else
			isAble = true
		end
		isNotEnoughMana = false
	else
		inRange = HDH_AT_UTIL.IsSpellInRange(name, "target")
		isAble, isNotEnoughMana = HDH_AT_UTIL.IsSpellUsable(id)
		isAble = isAble or isNotEnoughManas
	end
end

function HDH_C_TRACKER:UpdateCount(id, name, isItem, isToy)

end

function HDH_C_TRACKER:UpdateCooldown(id, name, isItem, isToy)

end

function HDH_C_TRACKER:UpdateSpellInfo(id, name, isItem, isToy)
	local startTime, duration, count, remaining
	local chargeCount, chargeCountMax, chargeStartTime, chargeDuration, chargeRemaining, castCount
	local inRange, isAble, isNotEnoughMana
	local curTime = GetTime()

	if isItem then
		startTime, duration = C_Container.GetItemCooldown(id)
		count = C_Item.GetItemCount(id, false, true) or 0
		inRange = C_Item.IsItemInRange(id, "target")
		if not isToy then
			isAble = C_Item.IsUsableItem(id)
		else
			isAble = true
		end
		isNotEnoughMana = false
	else
		local spellCooldownInfo = HDH_AT_UTIL.GetSpellCooldown(id)
		if spellCooldownInfo then
			startTime = spellCooldownInfo.startTime
			duration = spellCooldownInfo.duration
		end
		count = HDH_AT_UTIL.GetSpellCastCount(id) or 0
		inRange = HDH_AT_UTIL.IsSpellInRange(name, "target")
		isAble, isNotEnoughMana = HDH_AT_UTIL.IsSpellUsable(id)
		isAble = isAble or isNotEnoughManas
	end

	if startTime and duration then
		remaining = startTime + duration - curTime
		remaining = math.max(remaining, 0)
	end

	if inRange == nil then
		inRange = true
	end

	local charges = HDH_AT_UTIL.GetSpellCharges(id) -- 스킬의 중첩count과 충전charge은 다른 개념이다. 
	if charges then
		chargeCount = charges.currentCharges
		chargeCountMax = charges.maxCharges
		chargeStartTime = charges.cooldownStartTime
		chargeDuration = charges.cooldownDuration
	end
	if chargeStartTime and chargeDuration then
		chargeRemaining = chargeStartTime + chargeDuration - curTime
		chargeRemaining = math.max(chargeRemaining, 0)
	end

	if (HDH_TRACKER.startTime > startTime) then
		startTime = HDH_TRACKER.startTime
		duration = duration - (HDH_TRACKER.startTime - startTime)
	end
	if chargeStartTime ~= nil and (HDH_TRACKER.startTime > chargeStartTime) then
		chargeStartTime = HDH_TRACKER.startTime
		chargeDuration = chargeDuration - (HDH_TRACKER.startTime - chargeStartTime)
	end

	return startTime or 0, 
			duration or 0, 
			remaining or 0, 
			count or 0, 
			chargeStartTime or 0, 
			chargeDuration or 0, 
			chargeRemaining or 0, 
			chargeCount or 0, 
			chargeCountMax or 0, 
			inRange or false, 
			isAble or false, 
			isNotEnoughMana or false
end

function HDH_C_TRACKER:UpdateCombatSpellInfo(f, id)
	if f.spell and f.spell.innerSpellId == id then
		f.spell.startTime = GetTime()
		f.spell.duration = f.spell.innerCooldown
	end
end

function HDH_C_TRACKER:UpdateAuras(f)
	local curTime = GetTime()
	local aura
	local spell = f.spell

	for i = 1, 40 do 
		aura = C_UnitAuras.GetAuraDataByIndex('player', i, 'HELPFUL')
		if not aura then break end
		if f.spell.innerSpellId == aura.spellId then
			if spell.innerSpellEndtime ~= aura.expirationTime or aura.expirationTime == 0 then
				spell.startTime = curTime
				spell.duration = spell.innerCooldown
				spell.innerSpellEndtime = aura.expirationTime
			end
			break
		end
	end
	return spell.startTime, spell.duration
end


function HDH_C_TRACKER:UpdateIcon(f)
	f.t = f.t or GetTime()
	f.c = (f.c or 0) + 1
	if (GetTime() - f.t) >= 1 then
		f.c = 0
		f.t = nil
		return
	end

	if not f or not f.spell or not self or not self.ui or f.spell.blankDisplay then return false end
	local startTime, duration, remaining, count, chargeStartTime, chargeDuration, chargeRemaining, chargeCount, chargeCountMax, inRange, isAble, isNotEnoughMana 
	local isUpdate = false
	local spell = f.spell
	local ui = self.ui
	local maxtime = ui.icon.max_time or -1
	local show_global_cooldown = ui.cooldown.show_global_cooldown
	local cooldown_type = ui.icon.cooldown
	local display_mode = ui.common.display_mode
	local not_enough_mana_color = (self.ui.cooldown.not_enough_mana_color or {0.35, 0.35, 0.78})
	local out_range_color = (self.ui.cooldown.out_range_color or {0.53, 0.1, 0.1})
	local use_not_enough_mana_color = self.ui.cooldown.use_not_enough_mana_color
	local use_out_range_color = self.ui.cooldown.use_out_range_color

	if not HDH_TRACKER.ENABLE_MOVE and not spell.isInnerCDItem then
		startTime, duration, remaining, count, chargeStartTime, chargeDuration, chargeRemaining, chargeCount, chargeCountMax, inRange, isAble, isNotEnoughMana = self:UpdateSpellInfo(f.spell.id, f.spell.name, f.spell.isItem, f.spell.isToy)
		
		spell.isGlobalCooldown = (duration < HDH_C_TRACKER.GlobalCooldown)
		if show_global_cooldown or not spell.isGlobalCooldown then
			spell.startTime = startTime
			spell.endTime = startTime + duration
			spell.remaining = remaining
			spell.duration = duration
		end

		if not show_global_cooldown then
			spell.isGlobalCooldown = false
		end

		if count >= 2 and f.spell.isItem then
			spell.stackable = true
		end
		spell.count = count
		spell.charges.count = chargeCount
		spell.charges.remaining = chargeRemaining
		spell.charges.endTime = chargeStartTime + chargeDuration
		spell.charges.duration = chargeDuration
		spell.isCharging = (chargeRemaining > 0 and chargeCount >= 1) and true or false
		spell.isAble = isAble
		spell.inRange = not use_out_range_color and true or inRange
		spell.isNotEnoughMana = use_not_enough_mana_color and isNotEnoughMana or false
	end

	-- 상태 업데이트
	if not spell.isAble then
		f.icon:SetDesaturated()

	elseif not spell.inRange then
		f.icon:SetOverlayColor(out_range_color[1], out_range_color[2], out_range_color[3], out_range_color[4])
		
	elseif spell.isNotEnoughMana then
		f.icon:SetOverlayColor(not_enough_mana_color[1], not_enough_mana_color[2], not_enough_mana_color[3], not_enough_mana_color[4])

	elseif spell.isGlobalCooldown then
		f.icon:SetOverlayColor(nil)
		f.icon:UpdateCooldowning()

	elseif spell.remaining > 0 then
		f.icon:SetOverlayColor(nil)
		f.icon:UpdateCooldowning()
		
	elseif spell.isCharging then
		f.icon:SetOverlayColor(nil)
		f.icon:UpdateCooldowning()

	else -- 쿨 아닌 상태
		f.icon:UpdateCooldowning(false)
		print("hi")
	end

	-- 쿨다운 업데이트
	if spell.remaining > 0 then
		f.icon:SetCooldown(spell.startTime, spell.duration)

	elseif spell.isCharging then
		f.icon:SetCharge(spell.startTime, spell.duration)

	else -- 쿨 아닌 상태
		-- f.icon:
	
	end








	-- if display_mode ~= DB.DISPLAY_ICON then
	-- 	f.bar:SetText(spell.name)
	-- end
	
	-- if spell.remaining <= HDH_C_TRACKER.EndCooldown then
	-- 	-- f.cd:Hide()
	-- 	if display_mode ~= DB.DISPLAY_ICON and f.bar then
	-- 		self:UpdateBarValue(f, 0, 1, 1)
	-- 	end--f.bar:Hide() 
	-- else
	-- 	if (HDH_TRACKER.startTime < spell.startTime) or (spell.duration == 0) then
	-- 		f.icon:SetCooldown(spell.startTime, spell.duration or 0)
	-- 	else
	-- 		f.icon:SetCooldown(HDH_TRACKER.startTime, spell.duration - (spell.startTime - HDH_TRACKER.startTime))
	-- 	end
	-- 	-- if not f.cd:IsShown() then f.cd:Show() end
	-- 	-- if (cooldown_type == DB.COOLDOWN_CIRCLE) or (cooldown_type == DB.COOLDOWN_NONE)  then
	-- 	-- 	if HDH_TRACKER.startTime < f.spell.startTime or (spell.duration == 0) then
	-- 	-- 		f.cd:SetCooldown(spell.startTime, spell.duration or 0)
	-- 	-- 	else
	-- 	-- 		f.cd:SetCooldown(HDH_TRACKER.startTime, f.spell.duration - (HDH_TRACKER.startTime-f.spell.startTime))
	-- 	-- 	end
	-- 	-- else
	-- 	-- 	f.cd:SetMinMaxValues(spell.startTime, spell.endTime)
	-- 	-- 	f.cd:SetValue(GetTime())
	-- 	-- end
	-- 	f.icon:UpdateCooldowning()

	-- 	if display_mode ~= DB.DISPLAY_ICON and f.spell.duration > HDH_C_TRACKER.GlobalCooldown and f.bar then
	-- 		self:UpdateBarValue(f, f.spell.startTime, f.spell.endTime, GetTime())
	-- 	else
	-- 		self:UpdateBarValue(f, 0, 1, 1)
	-- 	end
	-- end

	-- if (spell.remaining > HDH_C_TRACKER.EndCooldown) or (spell.charges.remaining > 0) then -- 글로버 쿨다운 2초 포함
	-- 	if spell.isGlobalCooldown and (not spell.isCharging) then -- 글로벌 쿨다운
	-- 		-- if f:IsShown() then HDH_AT_UTIL.CT_StartTimer(f, maxtime) end
	-- 		if spell.isAble then
	-- 			self:UpdateGlow(f,  true)
	-- 			-- f.icon:SetDesaturated(nil)
	-- 			-- f.iconSatCooldown:SetDesaturated(nil)
	-- 			-- f.iconSatCooldown:SetAlpha(self.ui.icon.on_alpha)
	-- 			if spell.inRange then
	-- 				if spell.isNotEnoughMana and use_not_enough_mana_color then
	-- 					-- f.icon:SetVertexColor(unpack(not_enough_mana_color))
	-- 					-- f.iconSatCooldown:SetVertexColor(unpack(not_enough_mana_color))
	-- 				else
	-- 					-- f.iconSatCooldown:SetVertexColor(1,1,1)
	-- 				end
	-- 			elseif use_out_range_color then
	-- 				-- f.iconSatCooldown:SetVertexColor(unpack(out_range_color))
	-- 				-- f.icon:SetVertexColor(unpack(out_range_color))
	-- 			end
	-- 		else
	-- 			-- f.icon:SetDesaturated(1)
	-- 			-- f.iconSatCooldown:SetAlpha(0)
	-- 		end
	-- 		f.timetext:SetText(nil)

	-- 		f.icon:SetGlobal(spell.startTime, spell.duration)
	-- 	else
	-- 		if spell.display == DB.SPELL_ALWAYS_DISPLAY or spell.display == DB.SPELL_HIDE_TIME_OFF or spell.display == DB.SPELL_HIDE_TIME_OFF_AS_SPACE or spell.isCharging or HDH_TRACKER.ENABLE_MOVE then 	
	-- 			if HDH_TRACKER.ENABLE_MOVE or (maxtime == -1) or (maxtime > spell.remaining) then -- 쿨다운 중
	-- 				-- HDH_AT_UTIL.CT_StartTimer(f, -1)
	-- 				if not f:IsShown() then f:Show() isUpdate = true end
	-- 				self:UpdateGlow(f, true)
	-- 			else
	-- 				self:UpdateGlow(f, false)
	-- 				-- HDH_AT_UTIL.CT_StartTimer(f, -1)
	-- 				if f:IsShown() then f:Hide() isUpdate = true end
	-- 			end

	-- 			if spell.isAble then
	-- 				-- f.iconSatCooldown:SetDesaturated(nil)
	-- 				-- f.iconSatCooldown:SetAlpha(self.ui.icon.on_alpha)
	-- 				if spell.inRange then
	-- 					if spell.isNotEnoughMana and use_not_enough_mana_color then
	-- 						-- f.icon:SetVertexColor(unpack(not_enough_mana_color))
	-- 						-- f.iconSatCooldown:SetVertexColor(unpack(not_enough_mana_color))
	-- 						-- f.icon:SetDesaturated(nil)
	-- 					else
	-- 						-- f.icon:SetDesaturated((not spell.isCharging or spell.remaining > 0) and 1 or nil)
	-- 						-- f.iconSatCooldown:SetVertexColor(1,1,1)
	-- 					end
	-- 				elseif use_out_range_color then
	-- 					-- f.iconSatCooldown:SetVertexColor(unpack(out_range_color))
	-- 					-- f.icon:SetVertexColor(unpack(out_range_color))
	-- 					-- f.icon:SetDesaturated(nil)
	-- 				else
	-- 					-- f.icon:SetDesaturated((not spell.isCharging or spell.remaining > 0) and 1 or nil)
	-- 				end
	-- 			else
	-- 				-- f.icon:SetDesaturated(1)
	-- 				-- f.iconSatCooldown:SetAlpha(0)
	-- 				-- f.iconSatCooldown:SetDesaturated(1)
	-- 			end
	-- 		else
	-- 			if f:IsShown() then f:Hide() self:UpdateGlow(f, false); isUpdate = true end
	-- 			-- HDH_AT_UTIL.CT_StartTimer(f, -1)
	-- 		end
	-- 	end

	-- 	-- if (cooldown_type == DB.COOLDOWN_CIRCLE) or (cooldown_type == DB.COOLDOWN_NONE)  then
	-- 	-- 	if f.iconSatCooldown:GetAlpha() ~= 0 then
	-- 	-- 		f.iconSatCooldown:SetAlpha(0)
	-- 	-- 	end
	-- 	-- 	if HDH_TRACKER.startTime < spell.startTime or (spell.duration == 0) then
	-- 	-- 		f.cd:SetCooldown(spell.startTime, spell.duration)
	-- 	-- 	else
	-- 	-- 		f.cd:SetCooldown(HDH_TRACKER.startTime, spell.duration - (HDH_TRACKER.startTime-spell.startTime))
	-- 	-- 	end
	-- 	-- else 
	-- 	-- 	f.cd:SetMinMaxValues(spell.startTime, spell.startTime + spell.duration)
	-- 	-- 	f.cd:SetValue(GetTime())
	-- 	-- end

	-- 	-- if not f.iconSatCooldown:IsShown() then
	-- 	-- 	f.iconSatCooldown:Show()
	-- 	-- end

		

	-- else  -- 쿨다운 아닐때
	-- 	f.timetext:SetText(nil)
	-- 	-- if f.cd:IsShown() then f.cd:Hide() end
	-- 	if spell.display == DB.SPELL_ALWAYS_DISPLAY or f.spell.display == DB.SPELL_HIDE_TIME_ON or f.spell.display == DB.SPELL_HIDE_TIME_ON_AS_SPACE then 	
	-- 		if not f:IsShown() then f:Show() isUpdate = true end
	-- 		self:UpdateGlow(f, true)
	-- 	else
	-- 		if f:IsShown() then f:Hide() self:UpdateGlow(f, false); isUpdate = true end
	-- 	end
	-- 	-- f.iconSatCooldown:Hide()
	-- 	-- f.iconSatCooldown.spark:Hide()

	-- 	if spell.isAble then
	-- 		if spell.inRange then
	-- 			if spell.isNotEnoughMana and use_not_enough_mana_color then
	-- 				-- f.icon:SetVertexColor(unpack(not_enough_mana_color))
	-- 				-- f.iconSatCooldown:SetVertexColor(unpack(not_enough_mana_color))
	-- 				-- f.icon:SetDesaturated(nil)
	-- 			else
	-- 				-- f.icon:SetDesaturated(nil)
	-- 				-- f.iconSatCooldown:SetVertexColor(1,1,1)
	-- 				-- f.icon:SetVertexColor(1,1,1)
	-- 			end
	-- 		elseif use_out_range_color then
	-- 			-- f.iconSatCooldown:SetVertexColor(unpack(out_range_color))
	-- 			-- f.icon:SetVertexColor(unpack(out_range_color))
	-- 			-- f.icon:SetDesaturated(nil)
	-- 		else
	-- 			-- f.icon:SetDesaturated(1)
	-- 		end
	-- 	else
	-- 		-- f.icon:SetDesaturated(1)
	-- 	end
	-- end

	-- if f.icon:IsDesaturated() then
	-- 	f.icon:SetVertexColor(1,1,1)
	-- 	f.icon:SetAlpha(self.ui.icon.off_alpha)
	-- 	f.border:SetAlpha(self.ui.icon.off_alpha)
	-- 	f.border:SetVertexColor(0,0,0)
	-- else
	-- 	if spell.duration < HDH_C_TRACKER.GlobalCooldown or (spell.inRange and not spell.isNotEnoughMana)  then
	-- 		f.icon:SetAlpha(self.ui.icon.on_alpha)
	-- 		f.border:SetAlpha(self.ui.icon.on_alpha)
	-- 		f.border:SetVertexColor(unpack(self.ui.icon.active_border_color))
	-- 	else
	-- 		f.icon:SetAlpha(self.ui.icon.off_alpha)
	-- 		f.border:SetAlpha(self.ui.icon.off_alpha)
	-- 	end
	-- end

	-- if (chargeCountMax and (chargeCountMax >= 2))  then  -- or (f.charges:GetCooldownDuration() > 0)
	-- 	spell.isCharging = chargeCount ~= chargeCountMax
	-- 	f.counttext:SetText(chargeCount);
	-- 	-- if (cooldown_type == DB.COOLDOWN_CIRCLE) or (cooldown_type == DB.COOLDOWN_NONE) then
	-- 	-- 	f.charges:SetCooldown(chargeStartTime, chargeDuration or 0);
	-- 	-- end
	-- elseif spell.stackable or spell.count > 0 then
	-- 	f.counttext:SetText(spell.count)
	-- else
	-- 	f.counttext:SetText(nil)
	-- end

	if self.OrderFunc then self:OrderFunc(self) end
	self:UpdateLayout()
	return isUpdate
end

function HDH_C_TRACKER:UpdateLayout()
	if not self.ui or not self.frame.icon then return end
	local f
	local line = self.ui.common.column_count or 10-- 한줄에 몇개의 아이콘 표시
	local margin_h = self.ui.common.margin_h
	local margin_v = self.ui.common.margin_v
	local reverse_v = self.ui.common.reverse_v -- 상하반전
	local reverse_h = self.ui.common.reverse_h -- 좌우반전
	local show_index = 0 -- 몇번째로 아이콘을 출력했는가?
	local display_index = 0 -- 몇번째로 아이콘을 출력했는가?
	local col = 0  -- 열에 대한 위치 좌표값 = x
	local row = 0  -- 행에 대한 위치 좌표값 = y
	local always_show = self.ui.common.always_show
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

	for i = 1 , #self.frame.icon do
		f = self.frame.icon[i]
		if f and f.spell then
			if not f.spell.blankDisplay then
				if HDH_TRACKER.ENABLE_MOVE or f:IsShown() then
					f:ClearAllPoints()
					f:SetPoint('RIGHT', self.frame, 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
					display_index = display_index + 1
					if display_index % line == 0 then 
						row = row + size_h + margin_v
						col = 0			
					else 
						col = col + size_w + margin_h 
					end
					if (f.spell.duration > HDH_C_TRACKER.GlobalCooldown and f.spell.remaining > 0.5) 
							or (f.spell.charges and f.spell.charges.remaining and f.spell.charges.remaining > 0) then 
						show_index = show_index + 1
					end -- 비전투라도 쿨이 돌고 잇는 스킬이 있으면 화면에 출력하기 위해서 체크함
				else
					if (f.spell.display == DB.SPELL_HIDE_TIME_OFF_AS_SPACE or f.spell.display == DB.SPELL_HIDE_TIME_ON_AS_SPACE) and self.ui.common.order_by == DB.ORDERBY_REG then
						display_index = display_index + 1
						f:ClearAllPoints()
						f:SetPoint('RIGHT', self.frame, 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
						if display_index % line == 0 then
							row = row + size_h + margin_v
							col = 0
						else 
							col = col + size_w + margin_h
						end
					end
				end
			else
				if self.ui.common.order_by == DB.ORDERBY_REG then
					display_index = display_index + 1
					if display_index % line == 0 then
						row = row + size_h + margin_v
						col = 0
					else 
						col = col + size_w + margin_h
					end
					if f:IsShown() then
						f:Hide()
					end
				end
			end
		end
	end

	if (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
			and (HDH_TRACKER.ENABLE_MOVE or show_index > 0 or always_show or UnitAffectingCombat("player")) then
		self:ShowTracker();
	else
		self:HideTracker();
	end
end

function HDH_C_TRACKER:UpdateAllSlot(onlyNotMappingSpell)
	local id, f
	if onlyNotMappingSpell and self.unmatch_slot_count == 0 then 
		return
	end
	for i = 1, 120 do
		_, id, _ = GetActionInfo(i)

		if onlyNotMappingSpell then
			if id and self.unmatch_slot_spell[id] and self.frame.pointer[id] then
				self.frame.pointer[id].spell.slot = i;
				self.slot_pointer[i] = self.frame.pointer[id];
			end
		else
			if id and self.frame.pointer[id] then
				self.frame.pointer[id].spell.slot = i;
				self.slot_pointer[i] = self.frame.pointer[id];
			else
				f = self.slot_pointer[i]
				if f then
					if f.spell.id ~= f.spell.id_original then
						f.spell.id = f.spell.id_original
						f.spell.slot = nil 
						f.icon:SetTexture(f.spell.icon)
						-- f.iconSatCooldown:SetTexture(f.spell.icon)
						self:UpdateIcon(f)
					end
					self.slot_pointer[i] = nil
				end
			end
		end
	end

	self.unmatch_slot_count = 0
	self.unmatch_slot_spell = {}
	for _, v in pairs(self.frame.pointer) do
		if not v.spell.slot and not v.spell.isItem then
			self.unmatch_slot_spell[v.spell.id] = v
			self.unmatch_slot_count  = self.unmatch_slot_count  + 1
		end
	end
end

function HDH_C_TRACKER:UpdateSlotIcon(slot)
	if not slot then return false end
	local f = self.slot_pointer[slot]
	if f then
		local texture = GetActionTexture(slot)
		if (texture) then
			if f.icon:GetTexture() ~= texture then
				if f.spell.defaultImg == texture then
					f.icon:SetTexture(f.spell.icon)
					-- f.iconSatCooldown:SetTexture(f.spell.icon)
				else
					f.icon:SetTexture(texture)
					-- f.iconSatCooldown:SetTexture(texture)
				end
			end
		else
			f.icon:SetTexture(f.spell.icon)
			-- f.iconSatCooldown:SetTexture(f.spell.icon)
		end
	end
end

function HDH_C_TRACKER:GetSlot(id)
	return self.frame.pointer[id].slot;
end

function HDH_C_TRACKER:ACTIVATION_OVERLAY_GLOW_SHOW(id)
	local f = self.frame.pointer[id]
	if not f or not f.spell then return end

	if f.spell.id == id then
		f.spell.ableGlow = true
		if not f:IsShown() then
			if self:UpdateIcon(f) then
				self:UpdateLayout(f)
			end
		else
			if f.spell.glowEffectType == DB.GLOW_EFFECT_DEFAULT then
				self:ActionButton_ShowOverlayGlow(f)
				if f.icon.spark:IsShown() then
					f.icon.spark:Hide() 
					f.spell.glowColorOn = false
				end
			else
				if not f.icon.spark:IsShown() then
					f.icon.spark.playing = 0
					f.icon.spark:Show() 
					f.spell.glowColorOn = true
				end
			end
		end

	elseif f.spell.base_id == id then
		f.spell.base_ableGlow = true
	end
end

function HDH_C_TRACKER:ACTIVATION_OVERLAY_GLOW_HIDE(id)
	local f = self.frame.pointer[id]
	if not f or not f.spell then return end

	if f.spell.id == id then
		f.spell.ableGlow = false
		self:UpdateIcon(f)

	elseif f.spell.base_id == id then
		f.spell.base_ableGlow = false
	end
end

-- function HDH_C_TRACKER:InitVariblesOption() -- HDH_TRACKER override
-- 	super.InitVariblesOption(self)
	
-- 	HDH_AT_UTIL.CheckToUpdateDB(DefaultCooldownDB, DB_OPTION);
-- 	if DB_OPTION[self.name].use_each then
-- 		HDH_AT_UTIL.CheckToUpdateDB(DefaultCooldownDB, DB_OPTION[self.name]);
-- 	end
-- end

function HDH_C_TRACKER:Release() -- HDH_TRACKER override
	super.Release(self)
end

function HDH_C_TRACKER:ReleaseIcon(idx) -- HDH_TRACKER override
	local icon = self.frame.icon[idx]
	icon:UnregisterAllEvents()
	icon:Hide()
	HDH_AT_UTIL.CT_StopTimer(icon)
	icon:SetParent(nil)
	icon.spell = nil
	self.frame.icon[idx] = nil
end

function HDH_C_TRACKER:UpdateIconSettings(f)
	super.UpdateIconSettings(self, f)
	local op_icon = self.ui.icon
	f.icon:Setup(op_icon.size, op_icon.size, op_icon.cooldown, true, true, op_icon.spark_color, op_icon.cooldown_bg_color, op_icon.on_alpha, op_icon.off_alpha, op_icon.border_size)
end

function HDH_C_TRACKER:CreateDummySpell(count)
	local icons =  self.frame.icon
	local ui = self.ui
	local curTime = GetTime()
	local f
	
	if icons then
		if #icons > 0 then count = #icons end
	end
	--local limit = 
	for i=1, count do
		f = icons[i]
		if not f:GetParent() then f:SetParent(self.frame) end
		if not f.icon:GetTexture() then
			f.icon:SetTexture("Interface/ICONS/TEMP")
			f.iconSatCooldown:SetTexture("Interface/ICONS/TEMP")
		end
		f:ClearAllPoints()
		local spell = {}
		spell.name = f.spell.name
		spell.icon = nil
		spell.display = DB.SPELL_ALWAYS_DISPLAY
		spell.id = 0
		spell.no = i
		spell.glow = false
		spell.count = 3+i
		spell.duration = 50*i
		spell.happenTime = 0
		spell.remaining = spell.duration
		spell.charges = {};
		spell.charges.duration = 0;
		spell.charges.endTime = 0;
		spell.charges.remaining = 0;
		spell.endTime = curTime + spell.duration
		spell.startTime = curTime
		spell.castCount = 0
		spell.inRange = true
		spell.isAble = true
		spell.isNotEnoughMana = false

		self:SetGameTooltip(f,  false)
		-- self:ChangeCooldownType(f, ui.icon.cooldown)
		f.spell = spell
		f.counttext:SetText(i)
		f.timetext:Show();
		f.icon:SetVertexColor(1,1,1);
		spell.isCharging = false;
		spell.isAble = true
		-- if not f.cd:IsShown() then f.cd:Show(); end	
		-- if (ui.icon.cooldown == DB.COOLDOWN_CIRCLE) or (ui.icon.cooldown == DB.COOLDOWN_NONE) then 
		-- 	f.cd:SetCooldown(spell.startTime, spell.duration or 0); 
		-- 	f.cd:SetDrawSwipe(spell.isCharging == false); 
		-- end
		
		if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
			f.bar:SetMinMaxValues(spell.startTime, spell.endTime);
			f.bar:SetValue(spell.startTime);
		end
		f:Show()
	end
	return count;
end

-- function HDH_C_TRACKER:UpdateIconSettings(f) -- HDH_TRACKER override
-- 	-- if f.cooldown1:GetScript("OnUpdate") ~= CT_OnUpdateCooldown or 
-- 	-- 	f.cooldown2:GetScript("OnUpdate") ~= CT_OnUpdateCooldown then
-- 	-- 	f.cooldown1:SetScript("OnUpdate", CT_OnUpdateCooldown)
-- 	-- 	f.cooldown2:SetScript("OnUpdate", CT_OnUpdateCooldown)
-- 	-- end
-- 	--if f.cg.cd1
-- 	super.UpdateIconSettings(self, f)
-- end

function HDH_C_TRACKER:UpdateAllIcons() -- HDH_TRACKER override
	local isUpdateLayout = false
	if not self.frame or not self.frame.icon then return end
	for i = 1 , #self.frame.icon do
		isUpdateLayout = self:UpdateIcon(self.frame.icon[i]) -- icon frame
	end
	if self.OrderFunc then self:OrderFunc(self); self:UpdateLayout(); end 

	return isUpdateLayout
end

function HDH_C_TRACKER:Update() -- HDH_TRACKER override
	if not self.ui then return end

	self:UpdateAllIcons();
end

function HDH_C_TRACKER:IsSwitchByHappenTime(icon1, icon2) 
	if not icon1.spell and not icon2.spell then return end
	local s1 = icon1.spell
	local s2 = icon2.spell
	local ret = false;
	if (not s1.isUpdate and s2.isUpdate) then
		ret = true;
	elseif (s1.isUpdate and s2.isUpdate) then
		if (s1.happenTime < s2.happenTime) then
			ret = true;
		end
	elseif (not s1.isUpdate and not s2.isUpdate) and (s1.no < s2.no) then
		ret = true;
	end
	return ret;
end

function HDH_C_TRACKER:IsSwitchByRemining(icon1, icon2) 
	if not icon1.spell and not icon2.spell then return end
	local s1 = icon1.spell
	local s2 = icon2.spell
	local ret = false;
	if (s1.duration > HDH_C_TRACKER.GlobalCooldown and s2.duration > HDH_C_TRACKER.GlobalCooldown) and (s1.remaining < s2.remaining) then
		ret = true;
	elseif (s1.remaining == 0 and s2.remaining == 0) and (s1.no <s2.no) then
		ret = true;
	elseif (s1.duration < HDH_C_TRACKER.GlobalCooldown and s2.duration > HDH_C_TRACKER.GlobalCooldown) then
		ret = true;
	end
	return ret;
end

function HDH_C_TRACKER:InitIcons() -- HDH_TRACKER override
	-- if HDH_TRACKER.ENABLE_MOVE then return end
	local trackerId = self.id
	local id, name, _, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
	self.aura_filter = aura_filter
	self.aura_caster = aura_caster
	if not id then 
		return 
	end

	local elemKey, elemId, elemName, texture, defaultImg, glowType, isValue, isItem, glowCondition, glowValue, glowEffectType, glowEffectColor, glowEffectPerSec
	local display, connectedId, connectedIsItem, unlearnedHideMode
	local innerTrackingType, innerSpellId, innerCooldown
	local elemSize = DB:GetTrackerElementSize(trackerId)
	local spell
	local f
	local iconIdx = 0
	local hasEquipItem = false
	local hasInnerCDItem = false
	local needEquipmentEvent = false;
	local isLearned = false
	local hasItem = false

	self.frame.pointer = {};
	self.frame:UnregisterAllEvents()
	
	for i = 1 , elemSize do
		elemKey, elemId, elemName, texture, display, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
		display, connectedId, connectedIsItem, unlearnedHideMode = DB:GetTrackerElementDisplay(trackerId, i)
		glowType, glowCondition, glowValue, glowEffectType, glowEffectColor, glowEffectPerSec = DB:GetTrackerElementGlow(trackerId, i)
		defaultImg = DB:GetTrackerElementDefaultImage(trackerId, i)
		innerTrackingType, innerSpellId, innerCooldown =  DB:GetTrackerElementInnerCooldown(trackerId, i)
		if innerSpellId then
			hasInnerCDItem = true
		end

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
			id = elemId -- ADJUST_ID[elemId] or
			
			spell = {}
			if isLearned then
				self.frame.pointer[id] = f
			else
				spell.blankDisplay = true
				f:Hide()
			end
			
			if type(elemKey) == "number" then
				spell.key = tonumber(elemKey)
			else
				spell.key = elemKey
			end
			spell.id = tonumber(id)
			spell.base_id = spell.id
			spell.no = iconIdx
			spell.name = elemName
			spell.icon = texture
			spell.defaultImg = defaultImg
			spell.glow = glowType
			spell.glowCondtion = glowCondition
			spell.glowValue = (glowValue and tonumber(glowValue)) or 0
			spell.glowEffectType = glowEffectType
			spell.glowEffectColor = glowEffectColor
			spell.glowEffectPerSec = glowEffectPerSec
			spell.showValue = isValue
			spell.display = display
			spell.isItem = (isItem or false)
			if isItem then
				local _, _, _, _, _, _, _, itemStackCount, _, _, _, _, _ = GetItemInfo(spell.key)
				if itemStackCount and itemStackCount > 2 then
					spell.stackable = true 
				else
					spell.stackable = false
				end
				if C_ToyBox.GetToyInfo(spell.id) then
					spell.isToy = true
				end

				needEquipmentEvent = needEquipmentEvent or isItem
			else
				local chargeInfo = HDH_AT_UTIL.GetSpellCharges(spell.key)
				if chargeInfo and chargeInfo.maxCharges and chargeInfo.maxCharges  > 2 then
					spell.stackable = true 
				else
					spell.stackable = false
				end
			end
			spell.duration = 0
			spell.count = 0
			spell.remaining = 0
			spell.startTime = 0
			spell.endTime = 0
			spell.happenTime = 0
			spell.charges = {};
			spell.charges.duration = 0;
			spell.charges.count = 0
			spell.charges.remaining = 0
			spell.charges.startTime = 0
			spell.charges.endTime = 0
			spell.castCount = 0
			spell.inRange = true
			spell.isAble = true
			spell.isNotEnoughMana = false

			spell.slot = nil --self:GetSlot(spell.id);
			-- if not auraList[i].defaultImg then auraList[i].defaultImg = auraList[i].Texture; 
			-- if auraList[i].defaultImg ~= auraList[i].Texture then spell.fix_icon = true end
			if innerSpellId then
				spell.isInnerCDItem = true
				spell.innerSpellId = tonumber(innerSpellId)
				spell.innerCooldown = tonumber(innerCooldown)
				spell.innerTrackingType = innerTrackingType
			end

			f.spell = spell
			f.icon:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
			-- f.iconSatCooldown:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
			-- f.iconSatCooldown:SetDesaturated(nil)
			-- f.border:SetVertexColor(unpack(self.ui.icon.active_border_color))

			-- self:ChangeCooldownType(f, self.ui.icon.cooldown)
			self:UpdateGlow(f, false)
			
			if not spell.blankDisplay then
				-- f:SetScript("OnUpdate", CT_OnUpdateIcon)
				if not spell.isInnerCDItem then
					if spell.isItem then
						hasItem = true
					end
				end
			else
				f:UnregisterAllEvents()
			end
		end
	end

	if iconIdx > 0 then
		self:LoadOrderFunc();
		self.frame:SetScript("OnEvent", CT_OnEvent_Frame)
		self.frame:RegisterEvent('PLAYER_TALENT_UPDATE')
		self.frame:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
		self.frame:RegisterEvent('ACTIONBAR_UPDATE_STATE')
		self.frame:RegisterEvent('CURSOR_CHANGED')
		self.frame:RegisterEvent('COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED')
		self.frame:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
		self.frame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
		self.frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
		self.frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
		self.frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
		self.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
		self.frame:RegisterEvent("ACTION_RANGE_CHECK_UPDATE")
		
		if needEquipmentEvent then
			self.frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
		end

		if #(self.frame.icon) > 0 then
			self.frame:RegisterEvent('UNIT_PET');
		end

		if hasItem then
			self.frame:RegisterEvent("BAG_UPDATE")
			self.frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
		end

		if hasInnerCDItem then
			self.frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
		end
	end

	for i = #self.frame.icon, iconIdx+1 , -1 do
		self:ReleaseIcon(i)
	end

	self.isManualChange = false
	self.unmatch_slot_count = 0
	self.unmatch_slot_spell = {}
	self.slot_pointer = {}
	self:UpdateAllSlot()
	self:Update()
end

function HDH_C_TRACKER:UpdateGlow(f, bool)
	if f.spell.ableGlow then -- 블리자드 기본 반짝임 효과면 무조건 적용
		if f.spell.glowEffectType == DB.GLOW_EFFECT_DEFAULT then
			self:ActionButton_ShowOverlayGlow(f)
			if f.icon.spark:IsShown() then
				f.icon.spark:Hide() 
				f.spell.glowColorOn = false
			end
		else
			if not f.icon.spark:IsShown() then
				f.icon.spark.playing = 0
				f.icon.spark:Show() 
				f.spell.glowColorOn = true
			end
		end
		return
	end
	if bool and (f.spell and f.spell.glow ~= DB.GLOW_CONDITION_NONE) and self.ui.common.display_mode ~= DB.DISPLAY_BAR then
		local value = 0
		local active = false

		if f.spell.glow == DB.GLOW_CONDITION_ACTIVE 
			and (f.spell.duration < HDH_C_TRACKER.GlobalCooldown or f.spell.remaining < HDH_C_TRACKER.EndCooldown) 
			and f.spell.isAble then
			active = true
		else
			if f.spell.glow == DB.GLOW_CONDITION_TIME then
				if f.spell.duration < HDH_C_TRACKER.GlobalCooldown then
					value = 0
				else
					value = f.spell.remaining
				end
			elseif f.spell.glow == DB.GLOW_CONDITION_COUNT then
				if f.spell.charges and f.spell.charges.count > 0 then
					value = f.spell.charges.count
				else
					value = f.spell.count or 0
				end
			elseif f.spell.glow == DB.GLOW_CONDITION_VALUE then
				value = f.spell.v1
			end
			value = value or 0
			if f.spell.glowCondtion == DB.CONDITION_GT_OR_EQ then
				active = (value >= f.spell.glowValue)
			elseif f.spell.glowCondtion == DB.CONDITION_LT_OR_EQ then
				active =  (value <= f.spell.glowValue)
			elseif f.spell.glowCondtion == DB.CONDITION_EQ then
				active =  (value == f.spell.glowValue) 
			elseif f.spell.glowCondtion == DB.CONDITION_GT then
				active =  (value > f.spell.glowValue) 
			elseif f.spell.glowCondtion == DB.CONDITION_LT then
				active =  (value < f.spell.glowValue) 
			end
		end
		if active then
			if f.spell.glowEffectType == DB.GLOW_EFFECT_DEFAULT then
				self:ActionButton_ShowOverlayGlow(f)
				if f.icon.spark:IsShown() then
					f.icon.spark:Hide() 
					f.spell.glowColorOn = false
				end
			else
				if not f.icon.spark:IsShown() then
					f.icon.spark.playing = 0
					f.icon.spark:Show() 
					f.spell.glowColorOn = true
				end
			end
		else
			self:ActionButton_HideOverlayGlow(f)
			if f.icon.spark:IsShown() then
				f.icon.spark:Hide() 
				f.spell.glowColorOn = false
			end
		end
	else
		self:ActionButton_HideOverlayGlow(f)
		if f.icon.spark:IsShown() then
			f.icon.spark:Hide() 
			f.spell.glowColorOn = false
		end
	end
end

function HDH_C_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
	-- self:RunTimer("PLAYER_TALENT_UPDATE", 0.2, HDH_C_TRACKER.InitIcons, self)
end

function HDH_C_TRACKER:PLAYER_ENTERING_WORLD()
	-- 항상 표시 옵션일때, 시작하자마자 ShowTracker 애니메이션(alpha 0 -> 1)이 동작하는데,
	-- 이 때, 바 이름 알파값 관련 초기화가 동시에 이뤄지면서 애니메이션의 알파값에 영향을 받아서 제대로 설정이 적용되지 않는 문제 발생
	-- 그래서 애니메이션이 끝나는 지점에서 다시한번 세팅값을 로딩함
	-- 다른 추적에서는 발생하지 않는데, 쿨다운 추적이 무거워서 그런듯
	if self.ui.common.always_show then
		HDH_AT_UTIL.RunTimer(self, "UpdateSetting", 0.5, HDH_C_TRACKER.UpdateSetting, self) 
	end	
end

function HDH_C_TRACKER:ACTION_RANGE_CHECK_UPDATE(slot, isInRange, checksRange)

end

function HDH_C_TRACKER:ACTIONBAR_UPDATE_STATE()

end

function HDH_C_TRACKER:COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED(base, override)
	if override ~= base and self.frame.pointer[base] then
		local f = self.frame.pointer[base]
		f.spell.id = override or base
		local info = HDH_AT_UTIL.GetCacheSpellInfo(f.spell.id)
		if info and info.iconID and info.iconID ~= f.icon:GetTexture() then
			if f.spell.defaultImg == info.iconID then
				f.icon:SetTexture(f.spell.icon)
				-- f.iconSatCooldown:SetTexture(f.spell.icon)
			else
				f.icon:SetTexture(info.iconID)
				-- f.iconSatCooldown:SetTexture(info.iconID)
			end
		end
		if base and not override then
			f.spell.ableGlow = f.spell.base_ableGlow
			f.spell.base_ableGlow = false
		end
		self:UpdateIcon(f)
	end
end

function HDH_C_TRACKER:COMBAT_LOG_EVENT_UNFILTERED(subEvent, srcGUID, spellID)
	if srcGUID == UnitGUID('player') then
		if subEvent == "SPELL_DAMAGE" or subEvent == "SPELL_HEAL" or subEvent == "SPELL_CAST_SUCCESS" or subEvent == "SPELL_SUMMON" or subEvent == "SPELL_CREATE" or subEvent == "SPELL_AURA_APPLIED" then
			for i = 1, #self.frame.icon do
				if self.frame.icon[i].spell.isInnerCDItem then
					self:UpdateCombatSpellInfo(self.frame.icon[i], spellID);
					self:UpdateIcon(self.frame.icon[i])
				end
			end
		end
	end
end

function HDH_C_TRACKER:ACTIONBAR_SLOT_CHANGED(slot)
	if self.isManualChange and self.prevEvent == 'CURSOR_CHANGED' then
		self.isManualChange = false
		self:UpdateAllSlot()
	else
		if self.unmatch_slot_count > 0 then
			self:UpdateAllSlot(true)
		end
		self:UpdateSlotIcon(slot)
	end
end

function HDH_C_TRACKER:CURSOR_CHANGED(isDefault, curType, preType)
	self.isManualChange = false
	if preType == 1 or preType == 3 or preType == 6 then
		if isDefault then
			self.isManualChange = true
		end
	end
end

-- SPELL_UPDATE_CHARGES - charge count 
-- SPELL_UPDATE_USES - count id, id
-- ITEM_COUNT_CHANGED - id 

-- ACTION_USABLE_CHANGED - changes {slot, usable, noMana}

-- BAG_UPDATE -- 

function CT_OnEvent_Frame(self, event, ...)
	local tracker = self.parent 
	if not tracker then return end

	if event == "ACTIONBAR_UPDATE_COOLDOWN" or event =="BAG_UPDATE_COOLDOWN" or event =="BAG_UPDATE" or event == "ACTIONBAR_UPDATE_USABLE"  then
		if not HDH_TRACKER.ENABLE_MOVE then
			HDH_AT_UTIL.RunTimer(tracker, "ACTIONBAR_UPDATE_COOLDOWN", 0.05, HDH_C_TRACKER.Update, tracker)
		end

	elseif event == "ACTION_RANGE_CHECK_UPDATE" then
		tracker:ACTION_RANGE_CHECK_UPDATE(...)
		if not HDH_TRACKER.ENABLE_MOVE then
			-- HDH_AT_UTIL.RunTimer(tracker, "ACTIONBAR_UPDATE_COOLDOWN", 0.05, HDH_C_TRACKER.Update, tracker)
			HDH_C_TRACKER.Update(tracker)
		end

	elseif event == "ACTIONBAR_UPDATE_STATE" then
		tracker:ACTIONBAR_UPDATE_STATE()

	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
		tracker:ACTIVATION_OVERLAY_GLOW_SHOW(...)

	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
		tracker:ACTIVATION_OVERLAY_GLOW_HIDE(...)

	elseif event =="PLAYER_TARGET_CHANGED" then
		if  tracker:IsShown() then
			tracker:Update()
		end

	elseif event =="UPDATE_MOUSEOVER_UNIT" then
		if not tracker:IsShown() then return end
		tracker:Update()

	elseif event == 'PLAYER_FOCUS_CHANGED' then
		tracker:Update()

	elseif event == 'INSTANCE_ENCOUNTER_ENGAGE_UNIT' then
		tracker:Update()

	elseif event == 'GROUP_ROSTER_UPDATE' then
		tracker:Update()

	elseif event == 'UNIT_PET' then
		HDH_AT_UTIL.RunTimer(tracker, "UNIT_PET", 0.5, HDH_C_TRACKER.Update, tracker) 

	elseif event == 'ARENA_OPPONENT_UPDATE' then
		HDH_AT_UTIL.RunTimer(tracker, "ARENA_OPPONENT_UPDATE", 0.5, HDH_C_TRACKER.Update, tracker)

	elseif event == 'PLAYER_TALENT_UPDATE' then
		HDH_AT_UTIL.RunTimer(tracker, "PLAYER_TALENT_UPDATE", 0.5, HDH_C_TRACKER.InitIcons, tracker)

	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		HDH_AT_UTIL.RunTimer(tracker, "PLAYER_EQUIPMENT_CHANGED", 0.5, HDH_C_TRACKER.InitIcons, tracker)

	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		tracker:ACTIONBAR_SLOT_CHANGED(...)

	elseif event == 'UNIT_AURA' then
		if select(1, ...) == "player" then 
			HDH_AT_UTIL.RunTimer(tracker, "ACTIONBAR_UPDATE_COOLDOWN", 0.05, HDH_C_TRACKER.Update, tracker)	
		end

	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, subEvent, _, srcGUID, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		tracker:COMBAT_LOG_EVENT_UNFILTERED(subEvent, srcGUID, spellID)

	elseif event == 'COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED' then
		tracker:COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED(...)

	elseif event == 'CURSOR_CHANGED' then
		tracker:CURSOR_CHANGED(...)
	end

	tracker.prevEvent = event
end

-------------------------------------------
-------------------------------------------
