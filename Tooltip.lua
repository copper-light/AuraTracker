-- spell tooltip
local UTIL = HDH_AT_UTIL

local function addLine(tooltip, id)
    local found = false
	local idText = "ID: |cffffffff" .. id
	
    -- Check if we already added to this tooltip. Happens on the talent frame
    for i = 1,15 do
        local frame = _G[tooltip:GetName() .. "TextRight" .. i]
        local text
		
        if frame then text = frame:GetText() end
        if text and text == idText then found = true break end
    end

    if not found then
        tooltip:AddDoubleLine(" ", idText)
        tooltip:Show()
    end
end


hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...)
	if not HDH_AT_DB.show_tooltip_id then return end
    local aura = C_UnitAuras.GetBuffDataByIndex(...)
    if aura then addLine(self, aura.spellId) end
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
	if not HDH_AT_DB.show_tooltip_id then return end
    local aura = C_UnitAuras.GetDebuffDataByIndex(...)
    if aura then addLine(self, aura.spellId) end
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
	if not HDH_AT_DB.show_tooltip_id then return end
    local aura = C_UnitAuras.GetAuraDataByIndex(...)
    if aura then addLine(self, aura.spellId) end
end)

-- GameTooltip:HookScript("OnTooltipSetItem", function(self)
-- 	if not DB_OPTION.tooltip_id_show then return end
-- 	local link = select(2,self:GetItem())
-- 	if link then
-- 		local id = tonumber(link:match("item:(%d*)"))
-- 		if id then addLine(self, "아이템", id) end
-- 	end
-- end)

hooksecurefunc(GameTooltip, "SetAction", function(self, ...)
	if not HDH_AT_DB.show_tooltip_id then return end
    local id = select(2, self:GetSpell())
    if not id then
        id = select(3, self:GetItem())
    end

    if id then addLine(self, id) end
end)


hooksecurefunc(GameTooltip, "SetSpellByID", function(self,...)
	if not HDH_AT_DB.show_tooltip_id then return end
    local id = select(1, ...)
    if id then addLine(self, id) end
end)

hooksecurefunc(GameTooltip, "SetSpellBookItem", function(self,...)
	if not HDH_AT_DB.show_tooltip_id then return end
    local idx, t = ...
    local info = UTIL.GetSpellBookItemInfo(idx, t)
    if info then
        local id = info.spellID
        if t == "pet" then
            id = bit.band(0xFFFFFF, id)
        end
        -- local id = select(2, self:GetSpell())
        if id then addLine(self, id) end
    end
end)

-- hooksecurefunc(GameTooltip, "SetUnitDebuffByAuraInstanceID", function(self,...)
-- 	if not HDH_AT_DB.show_tooltip_id then return end
--     local id = C_UnitAuras.GetAuraDataByAuraInstanceID(...).spellId
--     if id then addLine(self, id) end
    
-- end)

-- hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", function(self,...)
-- 	if not HDH_AT_DB.show_tooltip_id then return end
--     local id = C_UnitAuras.GetAuraDataByAuraInstanceID(...).spellId
--     if id then addLine(self, id) end
-- end)

hooksecurefunc(GameTooltip, 'SetBagItem', function(self, ...)
    if not HDH_AT_DB.show_tooltip_id then return end
    local id = select(3, self:GetItem())
    if id then addLine(self, id) end
 end)

 