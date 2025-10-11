local DB = HDH_AT_ConfigDB

HDH_C_TRACKER = {}
------------------------------------
-- HDH_C_TRACKER class
------------------------------------
local super = HDH_TRACKER
setmetatable(HDH_C_TRACKER, super) -- 상속
HDH_C_TRACKER.__index = HDH_C_TRACKER
HDH_C_TRACKER.className = "HDH_C_TRACKER"
HDH_TRACKER.TYPE.COOLDOWN = 3
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.COOLDOWN, HDH_C_TRACKER)

-----------------------------------
-- OnUpdate icon
-----------------------------------

local function HDH_AT_CooldownIconTemplate_OnCooldownFinished(cooldown)
	local tracker = cooldown:GetParent():GetParent().parent
	tracker:Update(cooldown:GetParent().spell.no)
end

------- HDH_C_TRACKER member function -----------	


local function OnUpdate_CheckRange(frame, elapsed)
	frame.needUpdate = false
	if frame:IsShown() then
		for i= 1, #frame.icon do
			if frame.icon[i].spell.inRange ~= HDH_AT_UTIL.IsSpellInRange(frame.icon[i].spell.name, "target") then
				frame.needUpdate = true
			end
		end
		if frame.needUpdate and frame.parent then
			frame.parent:ACTION_RANGE_CHECK_UPDATE()
			print("Range Check Update")
		end
	end
end

function HDH_C_TRACKER:GetCooldownInfo(id, name, isItem, isToy)
	local startTime, duration, count, remaining
	local chargeCount, chargeCountMax, chargeStartTime, chargeDuration, chargeRemaining
	local inRange, isAble, isNotEnoughMana
	local curTime = GetTime()

	if isItem then
		startTime, duration = HDH_AT_UTIL.GetItemCooldown(id)
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
		isAble = isAble or isNotEnoughMana
	end

	if startTime ~= nil and duration ~= nil then
		remaining = startTime + duration - curTime
		remaining = math.max(remaining, 0)
	end

	if inRange == nil then
		inRange = true
	end

	local charges = HDH_AT_UTIL.GetSpellCharges(id)
	if charges then
		chargeCount = charges.currentCharges
		chargeCountMax = charges.maxCharges
		chargeStartTime = charges.cooldownStartTime
		chargeDuration = charges.cooldownDuration

		if chargeStartTime ~= nil and chargeDuration ~= nil then
			chargeRemaining = chargeStartTime + chargeDuration - curTime
			chargeRemaining = math.max(chargeRemaining, 0)
		else
			chargeRemaining = 0
			chargeStartTime = 0
			chargeDuration = 0
		end
	end

	if startTime ~= nil and startTime ~= 0 and (HDH_TRACKER.startTime > startTime) then
		duration = duration - (HDH_TRACKER.startTime - startTime)
		startTime = HDH_TRACKER.startTime
	end

	if chargeStartTime ~= nil and chargeStartTime~=0 and (HDH_TRACKER.startTime > chargeStartTime) then
		chargeDuration = chargeDuration - (HDH_TRACKER.startTime - chargeStartTime)
		chargeStartTime = HDH_TRACKER.startTime
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
		aura = HDH_AT_UTIL.GetAuraDataByIndex('player', i, 'HELPFUL')
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
					if f.spell.id ~= f.spell.base_id then
						f.spell.id = f.spell.base_id
						f.spell.slot = nil 
						f.icon:SetTexture(f.spell.icon)
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
				else
					f.icon:SetTexture(texture)
				end
			end
		else
			f.icon:SetTexture(f.spell.icon)
		end
	end
end

function HDH_C_TRACKER:GetSlot(id)
	return self.frame.pointer[id].slot;
end

-- function HDH_C_TRACKER:ReleaseIcon(idx) -- HDH_TRACKER override
-- 	local icon = self.frame.icon[idx]
-- 	super.ReleaseIcon(self, idx)
-- end

function HDH_C_TRACKER:IsSwitchByRemining(icon1, icon2, desc)
	if not icon1.spell and not icon2.spell then return end
	local s1 = icon1.spell
	local s2 = icon2.spell
	local ret = false
	if (s1.duration > HDH_C_TRACKER.GlobalCooldown and s2.duration > HDH_C_TRACKER.GlobalCooldown) and (s1.remaining < s2.remaining) then
		ret = true;
	elseif ((s1.isGlobalCooldown or s1.remaining == 0) and (s2.isGlobalCooldown or s2.remaining == 0)) and (((not desc) and s1.no < s2.no) or ((desc) and s1.no > s2.no)) then
		ret = true
	elseif (s1.duration < HDH_C_TRACKER.GlobalCooldown and s2.duration > HDH_C_TRACKER.GlobalCooldown) then
		ret = true;
	end
	return ret;
end

function HDH_C_TRACKER:UpdateIconSettings(f)
	super.UpdateIconSettings(self, f)
	local op_icon = self.ui.icon
	f.icon:Setup(op_icon.size, op_icon.size, op_icon.cooldown, true, true, op_icon.spark_color, op_icon.cooldown_bg_color, op_icon.on_alpha, op_icon.off_alpha, op_icon.border_size)
	f.icon:SetHandler(nil, HDH_AT_CooldownIconTemplate_OnCooldownFinished)
end

function HDH_C_TRACKER:CreateDummySpell(count)
	local icons =  self.frame.icon
	local ui = self.ui
	local curTime = GetTime()
	local f, spell

	if icons then
		if #icons > 0 then count = #icons end
	end
	--local limit = 
	for i=1, count do
		f = icons[i]
		if not f:GetParent() then f:SetParent(self.frame) end
		if not f.icon:GetTexture() then
			f.icon:SetTexture("Interface/ICONS/TEMP")
		end
		spell = f.spell
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
		spell.charges = {}
		spell.charges.duration = 0
		spell.charges.endTime = 0
		spell.charges.remaining = 0
		spell.endTime = curTime + spell.duration
		spell.startTime = curTime
		spell.castCount = 0
		spell.inRange = true
		spell.isAble = true
		spell.isNotEnoughMana = false
		-- spell.isLearned = true
		spell.isUpdate = true

		self:SetGameTooltip(f,  false)
		f.spell = spell
		f.counttext:SetText(i)
		f.timetext:Show()
		spell.isCharging = false;
		spell.isAble = true
		f.icon:SetCooldown(spell.startTime, spell.duration)
		f.icon:UpdateCooldowning()

		if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
			self:UpdateBarMinMaxValue(f)
		end
		f:Show()
	end
	return count;
end

function HDH_C_TRACKER:UpdateSpellInfo(index)
	local show_global_cooldown = self.ui.cooldown.show_global_cooldown
	local use_not_enough_mana_color = self.ui.cooldown.use_not_enough_mana_color
	local use_out_range_color = self.ui.cooldown.use_out_range_color

	local startTime, duration, remaining, count
	local chargeStartTime, chargeDuration, chargeRemaining, chargeCount, chargeMax
	local inRange, isAble, isNotEnoughMana, isGlobalCooldown
	local spell
	local startIndex = index or 1
	local endIndex = index or #self.frame.icon

	for i = startIndex, endIndex do
		spell = self.frame.icon[i].spell
		if spell and not HDH_TRACKER.ENABLE_MOVE and not spell.isInnerCDItem then
			startTime, duration, remaining, count, chargeStartTime, chargeDuration, chargeRemaining, chargeCount, chargeMax, inRange, isAble, isNotEnoughMana = self:GetCooldownInfo(spell.id, spell.name, spell.isItem, spell.isToy)
			isGlobalCooldown = (duration > 0 and duration < HDH_C_TRACKER.GlobalCooldown)

			if spell.isGlobalCooldown then
				spell.isGlobalCooldown = isGlobalCooldown
				if show_global_cooldown or not spell.isGlobalCooldown then
					spell.startTime = startTime
					spell.endTime = startTime + duration
					spell.duration = duration
					spell.remaining = remaining
				end
			else
				-- 와우 기본 쿨다운 시스템의 경우, 스킬 쿨다운 끝자락에서 글로벌 쿨다운이 들어오면 글쿨을 우선 표시하도록 구현됨.
				-- 하지만, 쿨다운 여부를 흑백으로 처리하는 입장에서 보면 글쿨 때문에 의도치 않게 흑백으로 표시되는 문제를 야기함. 
				-- 그래서 스킬 쿨다운 종료 전에 모든 글쿨은 무시하도록 구현함 (글쿨이 들어왔을때, startTime > spell.endTime 인 경우만 글쿨로 인식)
				-- 이로 인하여, 쿨다운이 끝나고 스킬을 사용 가능한 것으로 보이지만 글쿨로 인해서 스킬을 바로 사용하지 못하는 텀이 발생할 수 있음
				-- 그러나,
				-- 글쿨보다 적은 시간임과 동시에 쿨이 끝나가는 스킬은 사용이 될때까지 연타하는 것이 사용자들의 일반적인 패턴이기 때문에,
				-- 해당 문제로 인한 텀은 용인 가능한 수준으로 판단됨
				if isGlobalCooldown then
					if show_global_cooldown and (startTime >= spell.endTime or spell.endTime > (startTime + duration)) then
						spell.startTime = startTime
						spell.endTime = startTime + duration
						spell.duration = duration
						spell.remaining = remaining
						spell.isGlobalCooldown = true
					else
						if (spell.endTime or 0) > (startTime + duration) then
							spell.endTime = GetTime()
							spell.duration = spell.endTime - (spell.startTime or startTime)
							spell.remaining = 0
						else
							spell.remaining = math.max(spell.endTime - GetTime(), 0)
						end
					end
				else
					spell.startTime = startTime
					spell.endTime = startTime + duration
					spell.duration = duration
					spell.remaining = remaining

					if spell.duration > 0 then
						spell.latestDuration = spell.duration
					end
					spell.countMax = math.max(spell.count or 0, spell.countMax or 0)
					spell.valueMax = math.max(spell.v1 or 0, spell.valueMax or 0)
					spell.durationMax = math.max(spell.duration or 0, spell.durationMax or 0)
					if spell.durationMax > 0 then
						spell.durationMax = math.ceil(spell.durationMax * 10) / 10
					end
				end
			end

			if not show_global_cooldown then
				spell.isGlobalCooldown = false
			end

			if count >= 2 and spell.isItem then
				spell.stackable = true
			end
			spell.count = count
			if not spell.charges then spell.charges = {} end 
			spell.charges.count = chargeCount
			spell.charges.remaining = chargeRemaining
			spell.charges.startTime = chargeStartTime
			spell.charges.endTime = chargeStartTime + chargeDuration
			spell.charges.duration = chargeDuration
			spell.charges.max = chargeMax

			spell.isCharging = (chargeRemaining > 0 and chargeCount >= 1) and true or false
			spell.isAble = isAble
			spell.inRange = not use_out_range_color and true or inRange
			spell.isNotEnoughMana = use_not_enough_mana_color and isNotEnoughMana or false

			if spell.charges.remaining > 0 and spell.isGlobalCooldown then
				spell.remaining = 0
			end

			if (not spell.isGlobalCooldown) and (spell.remaining > HDH_C_TRACKER.EndCooldown) then
				spell.isUpdate = true
			else
				spell.isUpdate = false
			end
			spell.countMax = math.max(spell.countMax or 0, count or 0, spell.charges.max or 0)
			spell.valueMax = 0
		end
	end
end

function HDH_C_TRACKER:UpdateIconAndBar(index) -- HDH_TRACKER override
	local f, spell
	local not_enough_mana_color = (self.ui.cooldown.not_enough_mana_color or {0.35, 0.35, 0.78})
	local out_range_color = (self.ui.cooldown.out_range_color or {0.53, 0.1, 0.1})

	local startIndex = index or 1
	local endIndex = index or #self.frame.icon
	for i = startIndex, endIndex do
		f = self.frame.icon[i]
		spell = f.spell

		-- 쿨다운 중인 스킬의 발동으로 쿨이 사라지면 쿨다운, 차징 멈춤 
		if spell.charges.remaining == 0  then
			f.icon:StopCharge()
		end

		if spell.remaining == 0 then
			f.icon:Stop()
		end

		-- 쿨다운 상태 업데이트
		if (spell.remaining > HDH_C_TRACKER.EndCooldown and not spell.isGlobalCooldown) then
			f.icon:UpdateCooldowning()
		else -- 스킬 쿨 아닌 상태
			f.icon:UpdateCooldowning(false)
		end

		-- 색상 상태 업데이트
		if not spell.inRange then
			f.icon:SetOverlayColor(out_range_color[1], out_range_color[2], out_range_color[3], out_range_color[4])
		elseif spell.isNotEnoughMana then
			f.icon:SetOverlayColor(not_enough_mana_color[1], not_enough_mana_color[2], not_enough_mana_color[3], not_enough_mana_color[4])
		else
			f.icon:SetOverlayColor(nil)
		end

		-- 사용 가능 상태 업데이트
		if not spell.isAble then
			f.icon:SetDesaturated()
		end

		-- 쿨다운 업데이트
		if not spell.isGlobalCooldown and spell.remaining > HDH_C_TRACKER.EndCooldown then
			f.icon:SetCooldown(spell.startTime, spell.duration)
		elseif spell.isCharging then
			f.icon:SetCharge(spell.charges.startTime, spell.charges.duration)
		elseif spell.isGlobalCooldown then
			f.icon:SetCooldown(spell.startTime, spell.duration)
		end

		if (spell.charges.max and (spell.charges.max >= 2)) then
			f.counttext:SetText(spell.charges.count)
		elseif spell.stackable or spell.count > 0 then
			f.counttext:SetText(spell.count)
		else
			f.counttext:SetText(nil)
		end

		if f.bar then
			f.bar:SetText(spell.name)
			if spell.remaining > HDH_C_TRACKER.EndCooldown and not spell.isGlobalCooldown then
				self:UpdateBarMinMaxValue(f)
			else
				if f.spell.barValueType == DB.BAR_TYPE_BY_TIME then
					self:UpdateBarFull(f)
				else
					self:UpdateBarMinMaxValue(f)
				end
			end
		end
		self:UpdateGlow(f, true)
	end
end

function HDH_C_TRACKER:InitIcons() -- HDH_TRACKER override
	local ret = super.InitIcons(self)
	local spell
	local needCombatEvent = false
	local needEquipmentEvent = false;
	local needBagEvent = false

	for i= 1, #self.frame.icon do
		spell = self.frame.icon[i].spell
		spell.charges = {}
		spell.charges.duration = 0;
		spell.charges.count = 0
		spell.charges.remaining = 0
		spell.charges.startTime = 0
		spell.charges.endTime = 0
		spell.castCount = 0
		spell.inRange = true
		spell.isAble = true
		spell.isNotEnoughMana = false
		spell.slot = nil 

		if spell.isInnerCDItem then
			needCombatEvent = true
		end

		if spell.isItem then
			local _, _, _, _, _, _, _, itemStackCount, _, _, _, _, _ = GetItemInfo(spell.key)
			if itemStackCount and itemStackCount > 2 then
				spell.stackable = true
			else
				spell.stackable = false
			end
			if C_ToyBox.GetToyInfo(spell.id) then
				spell.isToy = true
			end

			needEquipmentEvent = needEquipmentEvent or spell.isItem
		else
			local chargeInfo = HDH_AT_UTIL.GetSpellCharges(spell.key)
			if chargeInfo and chargeInfo.maxCharges and chargeInfo.maxCharges  > 2 then
				spell.stackable = true 
			else
				spell.stackable = false
			end
		end

		if not spell.blankDisplay then
			if not spell.isInnerCDItem then
				if spell.isItem then
					needBagEvent = true
				end
			end
		end
	end

	if ret > 0 then
		if HDH_AT.LE == HDH_AT.LE_CLASSIC then
			self.frame:RegisterEvent('CHARACTER_POINTS_CHANGED')
		else
			self.frame:RegisterEvent('PLAYER_TALENT_UPDATE')
			self.frame:RegisterEvent('COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED')
			self.frame:RegisterEvent("ACTION_RANGE_CHECK_UPDATE")
		end
		self.frame:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
		self.frame:RegisterEvent('ACTIONBAR_UPDATE_STATE')

		if HDH_AT.LE >= HDH_AT.LE_SHADOWLANDS then
			self.frame:RegisterEvent('CURSOR_CHANGED')
		end
		
		self.frame:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
		self.frame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
		self.frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
		self.frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
		self.frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
		self.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
		
		self.frame:RegisterEvent('UNIT_PET')
		
		if needEquipmentEvent then
			self.frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
		end

		if needBagEvent then
			self.frame:RegisterEvent("BAG_UPDATE")
			self.frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
		end

		if needCombatEvent then
			self.frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
		end
	end

	self.isManualChange = false
	self.unmatch_slot_count = 0
	self.unmatch_slot_spell = {}
	self.slot_pointer = {}
	self:UpdateAllSlot()
	self:Update()

	return ret
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


function HDH_C_TRACKER:ACTIVATION_OVERLAY_GLOW_SHOW(id)
	local f = self.frame.pointer[id]
	if not f or not f.spell then return end
	if f.spell.id == id then
		f.spell.ableGlow = true
		if not f:IsShown() then
			self:Update(f.spell.no)
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
		self:Update(f.spell.no)
	elseif f.spell.base_id == id then
		f.spell.base_ableGlow = false
	end
end

function HDH_C_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
	-- self:RunTimer("PLAYER_TALENT_UPDATE", 0.2, HDH_C_TRACKER.InitIcons, self)
end

function HDH_C_TRACKER:PLAYER_ENTERING_WORLD()
	-- 2025.09.01
	-- 항상 표시 옵션일때, 시작하자마자 ShowTracker 애니메이션(alpha 0 -> 1)이 동작하는데,
	-- 이 때, 바 이름 알파값 관련 초기화가 동시에 이뤄지면서 애니메이션의 알파값에 영향을 받아서 제대로 설정이 적용되지 않는 문제 발생
	-- 그래서 애니메이션이 끝나는 지점에서 다시한번 세팅값을 로딩함
	-- 다른 추적에서는 발생하지 않는데, 쿨다운 추적이 무거워서 그런듯
	if self.ui.common.always_show then
		HDH_AT_UTIL.RunTimer(self, "UpdateSetting", 0.5, function(self) 
			HDH_C_TRACKER.UpdateSetting(self)
			HDH_C_TRACKER.Update(self)
		end, {self})
	end

	if (HDH_AT.LE == HDH_AT.LE_CLASSIC) and self.frame then
		if not self.frame:GetScript("OnUpdate") then
			self.frame:SetScript("Onupdate", OnUpdate_CheckRange)
		end
	end
end

function HDH_C_TRACKER:ACTION_RANGE_CHECK_UPDATE(slot, isInRange, checksRange)
	if not HDH_TRACKER.ENABLE_MOVE then
		self:Update()
	end
end

function HDH_C_TRACKER:ACTIONBAR_UPDATE_STATE()

end

function HDH_C_TRACKER:COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED(base, override)
	if override ~= base and self.frame.pointer[base] then
		local f = self.frame.pointer[base]
		f.spell.id = override or base
		f.spell.overrideId = override
		f.spell.startTime = 0
		f.spell.endTime = 0
		f.spell.duration = 0
		f.spell.remaining = 0
		local info = HDH_AT_UTIL.GetCacheSpellInfo(f.spell.id)
		if info and info.iconID and info.iconID ~= f.icon:GetTexture() then
			if f.spell.defaultImg == info.iconID then
				f.icon:SetTexture(f.spell.icon)
			else
				f.icon:SetTexture(info.iconID)
			end
		end
		if base then
			if override then
				self.frame.pointer[override] = f
			else
				f.spell.ableGlow = f.spell.base_ableGlow
				f.spell.base_ableGlow = false
				if f.spell.overrideId then
					self.frame.pointer[f.spell.overrideId] = nil
				end
			end
		end
		self:Update(f.spell.no)
	end
end

function HDH_C_TRACKER:COMBAT_LOG_EVENT_UNFILTERED(subEvent, srcGUID, spellID)
	if srcGUID == UnitGUID('player') then
		if subEvent == "SPELL_DAMAGE" or subEvent == "SPELL_HEAL" or subEvent == "SPELL_CAST_SUCCESS" or subEvent == "SPELL_SUMMON" or subEvent == "SPELL_CREATE" or subEvent == "SPELL_AURA_APPLIED" then
			for i = 1, #self.frame.icon do
				if self.frame.icon[i].spell.isInnerCDItem then
					self:UpdateCombatSpellInfo(self.frame.icon[i], spellID)
					self:Update(i)
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

function HDH_C_TRACKER:OnEvent(event, ...)
	local tracker = self.parent
	if not tracker then return end

	if event == "ACTIONBAR_UPDATE_COOLDOWN" or event =="BAG_UPDATE_COOLDOWN" or event =="BAG_UPDATE" or event == "ACTIONBAR_UPDATE_USABLE"  then
		if not HDH_TRACKER.ENABLE_MOVE then
			HDH_AT_UTIL.RunTimer(tracker, "ACTIONBAR_UPDATE_COOLDOWN", 0.05, HDH_C_TRACKER.Update, {tracker})
		end

	elseif event == "ACTION_RANGE_CHECK_UPDATE" then
		tracker:ACTION_RANGE_CHECK_UPDATE(...)

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
		HDH_AT_UTIL.RunTimer(tracker, "UNIT_PET", 0.5, HDH_C_TRACKER.Update, {tracker}) 

	elseif event == 'ARENA_OPPONENT_UPDATE' then
		HDH_AT_UTIL.RunTimer(tracker, "ARENA_OPPONENT_UPDATE", 0.5, HDH_C_TRACKER.Update, {tracker})

	elseif event == 'PLAYER_TALENT_UPDATE' or event == 'CHARACTER_POINTS_CHANGED' then
		HDH_AT_UTIL.RunTimer(tracker, "PLAYER_TALENT_UPDATE", 0.5, HDH_C_TRACKER.InitIcons, {tracker})

	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		HDH_AT_UTIL.RunTimer(tracker, "PLAYER_EQUIPMENT_CHANGED", 0.5, HDH_C_TRACKER.InitIcons, {tracker})

	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		tracker:ACTIONBAR_SLOT_CHANGED(...)

	elseif event == 'UNIT_AURA' then
		if select(1, ...) == "player" then 
			HDH_AT_UTIL.RunTimer(tracker, "ACTIONBAR_UPDATE_COOLDOWN", 0.05, HDH_C_TRACKER.Update, {tracker})	
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
