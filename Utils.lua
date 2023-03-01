HDH_AT_UTIL = {}

do 
	HDH_AT_UTIL.SpellCache = setmetatable({}, {
		__index=function(t,v) 
			local a = {GetSpellInfo(v)} 
			if GetSpellInfo(v) then t[v] = a end 
			return a 
		end})

	function HDH_AT_UTIL.GetCacheSpellInfo(a)
		return unpack(HDH_AT_UTIL.SpellCache[a])
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
			local info = C_Traits.GetConfigInfo(id)
			if not info then
				if GetSpecializationInfoByID(id) then
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
			local name, rank, icon, castingTime, minRange, maxRange, spellID = HDH_AT_UTIL.GetCacheSpellInfo(value) 
			return name, spellID, icon
		elseif GetItemInfo(value) then
			local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(value)
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

	function HDH_AT_UTIL.IsTalentSpell(talent_name, spec, isReload)
		spec = spec or GetSpecialization();
		if isReload or cashTalentSpell == nil then cashTalentSpell = {} end
		if cashTalentSpell[spec] == nil or #(cashTalentSpell[spec]) == 0 then
			cashTalentSpell[spec] = {};
			for tier = 1, MAX_TALENT_TIERS do
				for column = 1, NUM_TALENT_COLUMNS do
					local id, name,_,_,_,_,_,_,_,selected = GetTalentInfoBySpecialization(spec,tier,column)
					if name then
						cashTalentSpell[spec][name] = selected
					end
				end
			end
		end
		
		return cashTalentSpell[spec][talent_name] -- nil: not found talent
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

		-- if x > 0 then
		-- 	x = math.floor(x + 0.1)
		-- else
		-- 	x = math.ceil(x - 0.1)
		-- end

		-- if y > 0 then
		-- 	y = math.floor(y + 0.1)
		-- else
		-- 	y = math.ceil(y - 0.1)
		-- end

		return x, y
	end
end