HDH_AT_UTIL = {}

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

	function HDH_AT_UTIL.IsLearnedSpellOrEquippedItem(id, name, isItem) -- 특성 스킬의 변경에 따른 스킬 표시 여부를 결정하기 위함
		if not id or id == 0 then return false end
		if isItem then 
			if C_Item.IsEquippableItem(id) then 
				return IsEquippedItem(id) -- 착용중인가요?
			else
				return true
			end
		else
			if not id and name then
				id = HDH_AT_UTIL.GetInfo(name)
			end
			-- if IsPlayerSpell(id) then return true end
			-- local selected = HDH_AT_UTIL.IsTalentSpell(id, name); -- true / false / nil: not found talent
			-- if selected == nil then
			-- 	return true;
			-- else
			-- 	return selected;
			-- end
			return IsPlayerSpell(id)
		end
	end

	function HDH_AT_UTIL.GetTraitsName(id)
		local traitName = nil
		if id then
			local info = HDH_AT_UTIL.GetConfigInfo(id)
			if not info then
				if HDH_AT_UTIL.GetSpecializationInfoByID(id) then
					traitName = HDH_AT_L.COMMON_SPEC
				end
			else
				traitName = info.name
			end
		end
		return traitName
	end

	function HDH_AT_UTIL.GetInfo(value, isItem) -- name, id, texture, isItem
		if not value then return nil end
		if not isItem and HDH_AT_UTIL.GetCacheSpellInfo(value) then
			local spell = HDH_AT_UTIL.GetCacheSpellInfo(value)
			return spell.name, spell.spellID, spell.iconID, false
		elseif GetItemInfo(value) then
			local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(value)
			local itemId = GetItemInfoInstant(value)
			if name then
				-- linkType, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId
				-- local linkType, itemId = strsplit(":", link)
				return name, itemId, texture, true, maxStack
			end
		end
		return nil
	end

	-- local WeaponIndex = {
	-- 	[1] = 16,	--Main hand
	-- 	[2] = 17,	--Off-hand
	-- 	[3] = 18,	--Ranged
	-- }
	-- function HDH_AT_UTIL.GetWeaponEnchantInfo()
	-- 	if not HDH_AT_UTIL.TmpGameToolTip then
	-- 		HDH_AT_UTIL.TmpGameToolTip =  CreateFrame("GameTooltip", "MyScanningTooltip", nil, "GameTooltipTemplate")
	-- 		HDH_AT_UTIL.TmpGameToolTip:SetOwner(WorldFrame, "ANCHOR_NONE")
	-- 	end

	-- 	-- 사용 예시
	-- 	-- local link = GetInventoryItemLink("player", 16)

	-- 	HDH_AT_UTIL.TmpGameToolTip:SetInventoryItem("player", 16)

	-- 	for i = HDH_AT_UTIL.TmpGameToolTip:NumLines(), 1, -1 do
	-- 		local text = _G[HDH_AT_UTIL.TmpGameToolTip:GetName() .. "TextLeft" .. i]
	-- 		if string.find(text:GetText(), "질풍의 무기") then
	-- 			print(string.find(text:GetText(), "질풍의 무기"))
	-- 		else
	-- 			print("none")
	-- 		end
	-- 	end


	-- 	-- HDH_AT_UTIL.TmpGameToolTip:SetSpellBookItem(33757)
	-- 	-- for i = HDH_AT_UTIL.TmpGameToolTip:NumLines(), 1, -1 do
	-- 	-- 	local text = _G[HDH_AT_UTIL.TmpGameToolTip:GetName() .. "TextLeft" .. i]
	-- 	-- 	print(text:GetText())
	-- 	-- 	text = _G[HDH_AT_UTIL.TmpGameToolTip:GetName() .. "TextRight" .. i]
	-- 	-- 	print(text:GetText())
	-- 	-- end
	-- end

	function HDH_AT_UTIL.Trim(str)
		if not str then return nil end
		if type(str) ~= "string" then
			str = tostring(str)
		end
		if string.len(str) == 0 then return "" end
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

	local COLOR_RGB_CODE_STR = "|cffff9999%02x|cff99ff99%02x|cff9999ff%02x"
	local COLOR_RGBA_CODE_STR = "|cffff9999%02x|r|cff99ff99%02x|r|cff9999ff%02x|r%02x"
	function HDH_AT_UTIL.ColorToString(r, g, b, a)
		if a then
			return string.upper(COLOR_RGBA_CODE_STR:format(r * 255, g *255, b*255, a*255))
		else
			return string.upper(COLOR_RGB_CODE_STR:format(r * 255, g *255, b*255))
		end
	end

	function HDH_AT_UTIL.StringToColor(text)
		if text == nil then return nil end
		text = HDH_AT_UTIL.Trim(text) or ""
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

	function HDH_AT_UTIL.RunTimer(obj, timerName, time, func, args)
		if not obj.timer then obj.timer = {} end
		if obj.timer[timerName] then
			obj.timer[timerName].args = args
			if (GetTime() - obj.timer[timerName].startTime) <= time then
				return
			end
		end
		obj.timer[timerName] = C_Timer.NewTimer(time, function(timer)
			if timer.parent then
				if timer.args and #timer.args >= 1 then
					timer.func(unpack(timer.args)) 
				else
					timer.func() 
				end
				timer.parent[timer.timerName] = nil
				timer.timerName = nil
				timer.args = nil
			end 
		end)
		obj.timer[timerName].startTime = GetTime()
		obj.timer[timerName].tracker = obj
		obj.timer[timerName].parent = obj.timer
		obj.timer[timerName].timerName = timerName
		obj.timer[timerName].func = func
		obj.timer[timerName].args = args
	end

	function HDH_AT_UTIL.StopTimer(obj, timerName)
		if obj.timer and obj.timer[timerName] then
			obj.timer[timerName]:Cancel()
			obj.timer[timerName] = nil
		end
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

	function HDH_AT_UTIL.LogScale(value)
		-- return ((math.log(value* 0.85 + 0.15) - math.log(0.15)) / (math.log(1) - math.log(0.15)))
		return	 (1 - math.min(1, (math.log(value or 0.01)) / (math.log(.01))))	
		-- return value
	end

	function HDH_AT_UTIL.GetDecimalPlaces(num)
		local s = tostring(num)
		local dot = string.find(s, "%.")
		if dot then
			return #s - dot
		else
			return 0
		end
	end

	function HDH_AT_UTIL.GetLocalizedClassName(englishClass)
		local gender = UnitSex("player")
		local localizedClass
		if gender == 3 then -- FEMALE
			localizedClass = LOCALIZED_CLASS_NAMES_FEMALE[englishClass]
		else
			localizedClass = LOCALIZED_CLASS_NAMES_MALE[englishClass]
		end
		return localizedClass
	end

	function HDH_AT_UTIL.ObjectToString(object)
		local ok, v  = pcall(C_EncodingUtil.SerializeCBOR, object)
		if not ok then return nil end

		ok, v = pcall(C_EncodingUtil.CompressString, v, 0, 2)
		if not ok then return nil end

		ok, v = pcall(C_EncodingUtil.EncodeBase64, v, 1)
		if not ok then return nil end
		
		return v
	end

	function HDH_AT_UTIL.StringToObject(str)
		local ok, v  = pcall(C_EncodingUtil.DecodeBase64, str, 1)
		if not ok then return nil end

		ok, v = pcall(C_EncodingUtil.DecompressString, v, 0, 2)
		if not ok then return nil end

		ok, v = pcall(C_EncodingUtil.DeserializeCBOR, v)
		if not ok then return nil end

		return v
	end
end