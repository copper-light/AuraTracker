
HDH_AT_UTIL.MAX_TALENT_TABS = 4

HDH_AT_UTIL.GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
HDH_AT_UTIL.GetContainerNumSlots = C_Container.GetContainerNumSlots
HDH_AT_UTIL.GetContainerItemInfo = C_Container.GetContainerItemInfo
HDH_AT_UTIL.GetItemCooldown = C_Container.GetItemCooldown

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
HDH_AT_UTIL.TALENTS_GROUP_LIST[1] = HDH_AT_L.PRIMARY_SPEC
HDH_AT_UTIL.TALENTS_GROUP_LIST[2] = HDH_AT_L.SECONDARY_SPEC
HDH_AT_UTIL.GetConfigInfo = function(transitID)
	if transitID > #HDH_AT_UTIL.TALENTS_GROUP_LIST then
		return nil
	end
		
	return {id = transitID, name = HDH_AT_UTIL.TALENTS_GROUP_LIST[transitID]}
end

HDH_AT_UTIL.GetSpecializationInfoByID = function(talentID)
	for i = 1, HDH_AT_UTIL.MAX_TALENT_TABS do
		id, name, _, icon = HDH_AT_UTIL.GetSpecializationInfo(i)
		if id == talentID then
			return id, name, _, icon
		end
	end
end

HDH_AT_UTIL.GetConfigIDsBySpecID = function(search_specID)
	local ret = {}
	local search_index = nil
	local specIndex, id, name 
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
	if not id then return nil end
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
HDH_AT_UTIL.GetSpellCastCount = function(spell) 
	return 0
end

HDH_AT_UTIL.GetItemCooldown = C_Container.GetItemCooldown
HDH_AT_UTIL.GetItemCount = C_Item.GetItemCount
HDH_AT_UTIL.IsItemInRange = C_Item.IsItemInRange
HDH_AT_UTIL.IsUsableItem = C_Item.IsUsableItem