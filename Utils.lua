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
			if amount < 1000000 then
				if isShort then
					if amount < 10000 then
						return HDH_AT_UTIL.CommaValue(amount);
					elseif amount < 100000 then
						return format("%.1f만",amount/10000);
					else
						return format("%d만",amount/10000);
					end
				else
					return HDH_AT_UTIL.CommaValue(amount);
				end
			elseif  amount <= 100000000 then
				return format("%d만",amount/10000);
			elseif amount <= 100000000 then
				return format("%.1f억",amount/100000000);
			else
				return format("%d억",amount/100000000);
			end
		else
			if amount < 1000000 then
				if isShort and amount >= 1000 then
					return format("%.1fk",amount/1000);
				else
					return HDH_AT_UTIL.CommaValue(amount);
				end
			elseif  amount <= 100000000 then
				return format("%.1fm",amount/1000000);
			else
				return format("%.1fg",amount/1000000000);
			end
		end
	end

	

	function HDH_AT_UTIL.GetTimef()
		local cur = math.floor(GetTime())
		local s= cur%60;
		local m= (cur/60) % 60;
		local h= cur/360;
		
		return string.format("%d:%d %s", h, m, s)
	end
    
end