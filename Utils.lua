HDH_AT_UTIL = {}

----------------------------------
do -- 애드온 버전 호환성
----------------------------------
    ------------------------------------------------------
	if select(4, GetBuildInfo()) <= 49999 then -- 대격변
	------------------------------------------------------
		HDH_AT_UTIL.GetSpecialization = function()
			return GetPrimaryTalentTree() or 5
		end

		HDH_AT_UTIL.GetSpecializationInfo = GetTalentTabInfo


		HDH_AT_UTIL.GetLastSelectedSavedConfigID = function(talentID)
			return GetActiveTalentGroup()
		end

		HDH_AT_UTIL.MAX_TALENT_TIERS = 4
		HDH_AT_UTIL.NUM_TALENT_COLUMNS = 30

		HDH_AT_UTIL.GetTalentInfoBySpecialization = function(spec, tier, column)
			local name, id, row, col, learn_point, max  = GetTalentInfo(tier, column)
			
			return id, name, _,_,_,_,_,_,_,(learn_point > 0)
		end

		HDH_AT_UTIL.TALENTS_GROUP_LIST = {}
		HDH_AT_UTIL.TALENTS_GROUP_LIST[1] = 'Primary Talents'
		HDH_AT_UTIL.TALENTS_GROUP_LIST[2] = 'Secondary Talents'
		HDH_AT_UTIL.GetConfigInfo = function(transitID)
			if transitID > #HDH_AT_UTIL.TALENTS_GROUP_LIST then
				return nil
			end
				
			return {id = transitID, name = HDH_AT_UTIL.TALENTS_GROUP_LIST[transitID]}
		end

		HDH_AT_UTIL.GetSpecializationInfoByID = function(talentID)
			for i = 1, MAX_TALENT_TABS do
				id, name, _, icon = HDH_AT_UTIL.GetSpecializationInfo(i)
				if id == talentID then
					return id, name, _, icon
				end
			end
		end

		HDH_AT_UTIL.GetConfigIDsBySpecID = function(search_specID)
			ret = {}
			search_index = nil
			for i = 1, HDH_AT_UTIL.MAX_TALENT_TIERS do
				id, name = HDH_AT_UTIL.GetSpecializationInfo(i)
				if id and id == search_specID then
					search_index = i
					break
				end
			end

			for i = 1, 2 do
				specIndex = GetPrimaryTalentTree(false, false, i)
				if search_index == specIndex then
					table.insert(ret, i)
				end
			end
			return ret
		end

		HDH_AT_UTIL.GetSpellCooldown = function(id) 
			local start, duration, enabled, modRate = GetSpellCooldown(id)
			if start then
				local info = { 
					startTime = start,
					duration = duration
				}
				return info
			else
				return nil
			end
		end

		HDH_AT_UTIL.IsSpellUsable = IsUsableSpell
	
		HDH_AT_UTIL.GetSpellCharges = function(id)
			local currentCharges, maxCharges, cooldownStart, cooldownDuration, chargeModRate = GetSpellCharges(spell)
			if currentCharges then
				local info = { 
					currentCharges = currentCharges,
					maxCharges = maxCharges,
					cooldownStartTime = cooldownStart,
					cooldownDuration = cooldownDuration
				}
				return info
			else
				return nil
			end
		end

		HDH_AT_UTIL.GetSpellCastCount = GetSpellCount
		HDH_AT_UTIL.IsSpellInRange = function(name) 
			local inRange = IsSpellInRange(name)
			if inRange and inRange == 0 then
				return false
			else
				return true
			end
		end

		HDH_AT_UTIL.GetSpellInfo = function(spell)
			local name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(spell)
			if name then
				local info = {
					name= name,
					iconID = icon,
					originalIconID = originalIcon,
					castTime = castTime,
					minRange = minRange,
					maxRange = maxRange,
					spellID = spellID
				}
				return info
			else
				return nil
			end
		end

		HDH_AT_UTIL.GetSpellBookItemInfo = function(index, bookType)
			local spellType, id = GetSpellBookItemInfo(index, bookType)
			if spellType then
				local info = {
					spellID = id 
				}
				return info
			else
				return nil
			end
		end 

		HDH_AT_UTIL.GetSpellLink = GetSpellLink
	-------------------------------------------
	else -- 용군단 이상
    -------------------------------------------
		HDH_AT_UTIL.GetSpellLink = C_Spell.GetSpellLink
		HDH_AT_UTIL.GetSpecialization = GetSpecialization
		HDH_AT_UTIL.GetSpecializationInfo = GetSpecializationInfo
		HDH_AT_UTIL.GetLastSelectedSavedConfigID = C_ClassTalents.GetLastSelectedSavedConfigID
		HDH_AT_UTIL.GetConfigInfo = C_Traits.GetConfigInfo
		HDH_AT_UTIL.GetSpecializationInfoByID = GetSpecializationInfoByID
		HDH_AT_UTIL.GetConfigIDsBySpecID = C_ClassTalents.GetConfigIDsBySpecID
		HDH_AT_UTIL.GetTalentInfoBySpecialization = GetTalentInfoBySpecialization
		HDH_AT_UTIL.NUM_TALENT_COLUMNS = NUM_TALENT_COLUMNS
		HDH_AT_UTIL.MAX_TALENT_TIERS =  MAX_TALENT_TIERS
		HDH_AT_UTIL.GetSpellCooldown = C_Spell.GetSpellCooldown
		HDH_AT_UTIL.GetSpellCharges = C_Spell.GetSpellCharges
		HDH_AT_UTIL.GetSpellCastCount = C_Spell.GetSpellCastCount
		HDH_AT_UTIL.IsSpellInRange = C_Spell.IsSpellInRange
		HDH_AT_UTIL.IsSpellUsable = C_Spell.IsSpellUsable
		HDH_AT_UTIL.GetSpellInfo = C_Spell.GetSpellInfo
		HDH_AT_UTIL.GetSpellBookItemInfo = C_SpellBook.GetSpellBookItemInfo
	end 


--------------------------
end ----------------------
--------------------------

do
	HDH_AT_UTIL.SpellCache = setmetatable({}, {
		__index=function(t,v) 
			local spell = HDH_AT_UTIL.GetSpellInfo(v)
			if spell then
				t[v] = spell
			end 
			return spell
		end})

	function HDH_AT_UTIL.GetCacheSpellInfo(a)
		return HDH_AT_UTIL.SpellCache[a]
	end	

	function HDH_AT_UTIL.HasValue(tab, val)
		for index, value in ipairs(tab) do
			if value == val then
				return true
			end
		end
	
		return false
	end

	function HDH_AT_UTIL.GetTraitsName(id)
		local traitName = nil
		if id then
			local info = HDH_AT_UTIL.GetConfigInfo(id)
			if not info then
				if HDH_AT_UTIL.GetSpecializationInfoByID(id) then
					traitName = HDH_AT_L.ALWAYS_USE
				end
			else
				traitName = info.name
			end
		end
		return traitName
	end

	function HDH_AT_UTIL.GetInfo(value, isItem)
		if not value then return nil end
		if not isItem and HDH_AT_UTIL.GetCacheSpellInfo(value) then
			local spell = HDH_AT_UTIL.GetCacheSpellInfo(value) 
			return spell.name, spell.spellID, spell.iconID
		elseif C_Item.GetItemInfo(value) then
			local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = C_Item.GetItemInfo(value)
			if name then
				-- linkType, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId
				local linkType, itemId = strsplit(":", link)
				return name, itemId, texture, true, maxStack -- 마지막 인자 아이템 이냐?
			end
		end
		return nil
	end

	function HDH_AT_UTIL.Trim(str)
		if not str then return nil end
		str = str:gsub('|[r|R]', '')
		str = str:gsub('|[c|C][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]', '')
		local front, near
		for i =1, str:len() do
			if str:sub(i,i) ~= " " then
				front = i
				break
			end
		end
		for i =str:len(), 1, -1 do
			if str:sub(i,i) ~= " " then
				near = i
				break
			end
		end
		if front and near and front <= near then
			return str:sub(front, near)
		else
			return nil
		end
	end

	local cashTalentSpell
	function HDH_AT_UTIL.IsTalentSpell(spellId, spellName, spec, isReload)
		spec = spec or HDH_AT_UTIL.GetSpecialization();
		if not spec then return nil end
		if isReload or cashTalentSpell == nil then cashTalentSpell = {} end
		if cashTalentSpell[spec] == nil or #(cashTalentSpell[spec]) == 0 then
			cashTalentSpell[spec] = {};
			if select(4, GetBuildInfo()) <= 49999 then -- 대격변
				for tier = 1, HDH_AT_UTIL.MAX_TALENT_TIERS do
					for column = 1, HDH_AT_UTIL.NUM_TALENT_COLUMNS do
						local id, name,_,selected = HDH_AT_UTIL.GetTalentInfoBySpecialization(spec,tier,column)
						if name then
							cashTalentSpell[spec][name] = selected
							cashTalentSpell[spec][spellId] = selected
						else
							-- break
						end
					end
				end
			else
				HDH_AT_UTIL.UpdateLearnedSpells(spellId, spellName)
			end
		end
		if cashTalentSpell[spec][spellName] or cashTalentSpell[spec][spellId] then
			return true
		else
			return false
		end
	end

	function HDH_AT_UTIL.UpdateLearnedSpells(searchId, searchName) -- this could be made to be a lot more efficient, if you already know the relevant nodeID and entryID
		local spec = HDH_AT_UTIL.GetSpecialization();
		if not spec then return nil end
		for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
			local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
			local offset, numSlots = skillLineInfo.itemIndexOffset, skillLineInfo.numSpellBookItems
			for j = offset+1, offset+numSlots do
				local name, subName = C_SpellBook.GetSpellBookItemName(j, Enum.SpellBookSpellBank.Player)
				local spellID = select(2,C_SpellBook.GetSpellBookItemType(j, Enum.SpellBookSpellBank.Player))
				if searchName == name or searchId == spellID then
					cashTalentSpell[spec][name] = true
					cashTalentSpell[spec][searchId] = true
				end 
			end
		end

		local numSpells, petToken = C_SpellBook.HasPetSpells()  -- nil if pet does not have spellbook, 'petToken' will usually be "PET"
		if numSpells then
			for i=1, numSpells do
				local petSpellName, petSubType = C_SpellBook.GetSpellBookItemName(i, Enum.SpellBookSpellBank.Pet)
				local spellID = select(2,C_SpellBook.GetSpellBookItemType(i, Enum.SpellBookSpellBank.Pet))
				if searchName == name or searchId == spellID then
					cashTalentSpell[spec][petSpellName] = true
					cashTalentSpell[spec][spellID] = true
				end 
			end
		end
	end

	function HDH_AT_UTIL.Deepcopy(orig) -- cpy table
		local orig_type = type(orig)
		local copy
		if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in next, orig, nil do
				copy[HDH_AT_UTIL.Deepcopy(orig_key)] = HDH_AT_UTIL.Deepcopy(orig_value)
			end
			setmetatable(copy, HDH_AT_UTIL.Deepcopy(getmetatable(orig)))
		else -- number, string, boolean, etc
			copy = orig
		end
		return copy
	end

	function HDH_AT_UTIL.CheckToUpdateDB(srcData, dstData)
		local orig_type = type(srcData)
		if dstData == nil then dstData = {}; end
		if orig_type == 'table' then
			if type(dstData) == 'table' then
				for orig_key, orig_value in next, srcData, nil do
					if dstData[orig_key] ~= nil and type(orig_value) == type(dstData[orig_key]) then
						dstData[orig_key] = HDH_AT_UTIL.CheckToUpdateDB(srcData[orig_key], dstData[orig_key]);
					else
						dstData[orig_key] = HDH_AT_UTIL.Deepcopy(orig_value);
					end
				end
			end
		end
		return dstData;
	end
	
		
	function HDH_AT_UTIL.CommaValue(amount)
		if amount == nil then return nil end
		local formatted = amount
		while true do  
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if (k==0) then
				break
			end
		end
		return formatted
	end
	
	function HDH_AT_UTIL.AbbreviateValue(amount, isShort, lengType)
		lengType = lengType or HDH_TRACKER.LOCALE;
		if amount == nil then return nil end
		if lengType == "koKR" then
			if isShort then
				if amount < 10000 then
					return HDH_AT_UTIL.CommaValue(amount);
				elseif amount < 100000 then
					return format("%.1f만",amount/10000);
				elseif  amount <= 100000000 then
					return format("%d만",amount/10000);
				elseif amount <= 1000000000 then
					return format("%.1f억",amount/1000000000);
				else
					return format("%d억",amount/100000000);
				end
			else
				return HDH_AT_UTIL.CommaValue(amount);
			end
		else
			if isShort then
				if amount < 1000 then
					return amount
				elseif amount < 10000 then
					return format("%.1fK", amount/1000);
				elseif amount < 1000000 then
					return format("%dK", amount/1000);
				elseif amount <= 10000000 then
					return format("%.1fM",amount/1000000);
				elseif amount <= 100000000 then
					return format("%dM",amount/1000000);
				elseif amount <= 10000000000 then
					return format("%.1fB",amount/1000000000);
				else
					return format("%dB",amount/1000000000);
				end
			else
				return HDH_AT_UTIL.CommaValue(amount);
			end
		end
	end

	

	function HDH_AT_UTIL.AbbreviateTime(time, isShort, lengType)
		local lengType = lengType or HDH_TRACKER.LOCALE;
		if lengType == "koKR" then
			if isShort then
				if time < 60 then 
					return ('%d'):format(time)
				else
					return ('%d분'):format(math.ceil((time)/60))
				end
			else
				if time < 60 then 
					return ('%d'):format(time)
				else
					return ('%d:%02d'):format((time)/60, (time)%60) 
				end
			end
		else
			if isShort then
				if time < 60 then 
					return ('%d'):format(time)
				else
					return ('%dm'):format(math.ceil((time)/60))
				end
			else
				if time < 60 then 
					return ('%d'):format(time)
				else
					return ('%d:%02d'):format((time)/60, (time)%60) 
				end
			end
		end
	end

	local COLOR_RGB_CODE_STR = "#|cffff9999%02x|cff99ff99%02x|cff9999ff%02x"
	local COLOR_RGBA_CODE_STR = "#|cffff9999%02x|r|cff99ff99%02x|r|cff9999ff%02x|r%02x"
	function HDH_AT_UTIL.ColorToString(r, g, b, a)
		if a then
			return string.upper(COLOR_RGBA_CODE_STR:format(r * 255, g *255, b*255, a*255))
		else
			return string.upper(COLOR_RGB_CODE_STR:format(r * 255, g *255, b*255))
		end
	end

	function HDH_AT_UTIL.StringToColor(text)
		if text == nil then return nil end
		text = HDH_AT_UTIL.Trim(text)
		if string.len(text) == 0 then return nil end
		if string.sub(text, 1, 1) == "#" then
			text = string.sub(text, 2)
		end
		if string.len(text) ~= 6 and string.len(text) ~= 8 then return nil end
		local code
		local ret = {}
		for i = 1 , string.len(text) - 1, 2 do
			code = string.sub(text, i, i+1)
			code = tonumber("0x"..code)
			if code == nil then
				return nil
			end
			code = code / 255
			table.insert(ret, code)
		end

		return ret[1], ret[2], ret[3], ret[4] or 1
	end

	function HDH_AT_UTIL.AdjustLocation(x, y)
		local w, h = UIParent:GetSize()
		x = math.floor(x + 0.1 - (w / 2))
		y = math.floor(y + 0.1 - (h / 2))

		return x, y
	end

	function HDH_AT_UTIL.RunTimer(obj, timerName, time, func, ...)
		if not obj.timer then obj.timer = {} end
		if obj.timer[timerName] then
			obj.timer[timerName]:Cancel()
		end
		obj.timer[timerName] = C_Timer.NewTimer(time, function(timer) 
			if timer.parent then 
				timer.func(timer.args) 
				timer.parent[timer.timerName] = nil
				timer.timerName = nil
				timer.args = nil
			end 
		end)
		obj.timer[timerName].tracker = obj
		obj.timer[timerName].parent = obj.timer
		obj.timer[timerName].timerName = timerName
		obj.timer[timerName].func = func
		obj.timer[timerName].args = ...
	end

	function HDH_AT_UTIL.CT_Timer_Func(self)
		if self and self.arg then
			local tracker = self.arg:GetParent() and self.arg:GetParent().parent or nil;
			if tracker then
				if( tracker:UpdateIcon(self.arg)) or (not tracker.ui.common.always_show and not UnitAffectingCombat("player")) then
					tracker:UpdateLayout()
				end
			end
			self.arg.timer = nil
		end
	end
	
	function HDH_AT_UTIL.CT_HasTImer(f)
		return f.timer and true or false
	end	
	
	function HDH_AT_UTIL.CT_StartTimer(f, maxtime)
		maxtime = math.max(maxtime or 0, 0)
		if f and f.spell and f.spell.remaining > 0 then
			if f.spell.remaining > maxtime then
				f.timerDuration = f.spell.remaining - maxtime
			else
				f.timerDuration = f.spell.remaining
			end

			if f.timer then
				HDH_AT_UTIL.CT_StopTimer(f)
			end

			f.timer = C_Timer.NewTimer(f.timerDuration, HDH_AT_UTIL.CT_Timer_Func)
			f.timer.arg = f
		end
	end
	
	function HDH_AT_UTIL.CT_StopTimer(f)
		if f and f.timer then
			f.timer:Cancel()
			f.timer = nil
		end
	end


	local Queue = {first = 0, last = -1, size = 0, capacity = 0}
	Queue.__index = Queue

	function Queue:Push(value)
		local last = self.last + 1
		self.last = last
		self[last] = value
		local gap = self.last - self.first
		if gap >= self.capacity then
			self[self.first] = nil;
			self.first = self.first + 1;
		end
		self.size = math.min(self.capacity, self.size + 1)
	end

	function Queue:Pop(idx)
		local first = self.first;
		local last = self.last;
		local value

		if idx then
			idx = first + idx - 1;
			if idx > last or not self[idx] then return end
			local value = self[idx];
			
			for i = idx, last do
				self[i] = self[i+1]
			end
			self.last = last -1

			self.size = math.max(self.size -1, 0)
			return value;
		else
			if first > last then return end
			self.last = last -1
			value = self[first];
			first = first + 1;
			self[first] = nil;
			self.size = math.max(self.size -1, 0)
			return value;
		end
	end

	function Queue:Get(idx)
		idx = self.first + idx - 1;
		if idx > self.last or not self[idx] then return end
		local value = self[idx];
		return value;
	end

	function Queue:GetSize()
		return self.size;
	end

	function Queue:Print()
		if self.first > self.last then error("list is empty") end
		local idx = self.first;
		local str = "";
		while idx <= self.last do
			if not self[idx] then break end
			str = str .. "@@"..self[idx]
			idx = idx + 1;
		end
		return str;
	end
	
	function HDH_AT_UTIL.CreateQueue(capacity)
		local newQ = {}
		setmetatable(newQ, Queue)
		newQ.capacity = capacity
		return newQ
	end

end