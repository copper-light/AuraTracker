HDH_AT_UTIL.ClassicDurations = LibStub("LibClassicDurations")
HDH_AT_UTIL.MAX_TALENT_TABS = 1

HDH_AT_UTIL.GetSpecialization = function()
	return 1
end

HDH_AT_UTIL.GetContainerNumSlots = GetContainerNumSlots
HDH_AT_UTIL.GetItemCooldown = GetItemCooldown


HDH_AT_UTIL.GetContainerItemInfo = function(bag, slot)
	local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID, isBound = GetContainerItemInfo(bag, slot)
	if icon then
		return {
			iconFileID = icon,
			stackCount = itemCount,
			isLocked = locked,
			quality = quality,
			isReadable = readable,
			hasLoot = lootable,
			hyperlink = itemLink,
			isFiltered = isFiltered,
			hasNoValue = noValue,
			itemID = itemID,
			isBound = isBound
		}
	else
		return nil
	end
end

HDH_AT_UTIL.GetAuraDataByIndex = function(unit, i, filter)
	local name, icon, count, dispelType, duration, endTime, caster, _, _, id, canApplyAura, isBossDebuff, castByPlayer, _, _, v1, v2, v3 = UnitAura(unit, i, filter)
	if name then
		if endTime == 0 then
			local libDuration, libEndTime = HDH_AT_UTIL.ClassicDurations:GetAuraDurationByUnit(unit, id)
			if libDuration and libEndTime then
				endTime = libEndTime
				duration = libDuration
			end
		end

		return {
			applications = count,
			caster = caster,
			name = name,
			spellId = id,
			icon = icon,
			dispelName = dispelType,
			isBossAura = isBossDebuff,
			expirationTime = endTime,
			duration = duration,
			sourceUnit = caster,
			isFromPlayerOrPlayerPet = castByPlayer,
			points = {v1, v2, v3}
		}
	else
		return nil
	end
end

HDH_AT_UTIL.GetSpecializationInfo = function(tabIndex)
	local className, classFilename, classId = UnitClass("player")
	local icon = "Interface/Icons/ClassIcon_" .. className
	return classId, className, _, icon
end

HDH_AT_UTIL.GetLastSelectedSavedConfigID = function(talentID)
	return nil
end

HDH_AT_UTIL.MAX_TALENT_TIERS = 1
HDH_AT_UTIL.NUM_TALENT_COLUMNS = 30

HDH_AT_UTIL.GetTalentInfoBySpecialization = function(spec, tier, column)
	local name, id, row, col, learn_point, max  = GetTalentInfo(tier, column)
	
	return id, name, _,_,_,_,_,_,_,(learn_point > 0)
end

HDH_AT_UTIL.TALENTS_GROUP_LIST = {}
HDH_AT_UTIL.GetConfigInfo = function(transitID)
	return nil
end

HDH_AT_UTIL.GetSpecializationInfoByID = function(talentID)
	local id, name, _, ico
	for i = 1, HDH_AT_UTIL.MAX_TALENT_TABS do
		local id, name, _, icon = HDH_AT_UTIL.GetSpecializationInfo(i)
		if id == talentID then
			return id, name, _, icon
		end
	end
end

HDH_AT_UTIL.GetConfigIDsBySpecID = function(search_specID)
	local ret = {}
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