
local GetSpellBookItemInfo = GetSpellBookItemInfo or C_SpellBook.GetSpellBookItemInfo

-- spell tooltip
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
    local id = select(10, UnitBuff(...))
    if id then addLine(self, id) end
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
	if not HDH_AT_DB.show_tooltip_id then return end
    local id = select(10, UnitDebuff(...))
    if id then addLine(self, id) end
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
	if not HDH_AT_DB.show_tooltip_id then return end
    local id = select(10, UnitAura(...))
    if id then addLine(self, id) end
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
    local id 
    if select(4, GetBuildInfo()) >= 110000 then --내부전쟁
        id = GetSpellBookItemInfo(idx, t).spellID
    else
        id = select(2, GetSpellBookItemInfo(idx, t))
    end

    if t == "pet" then
        id = bit.band(0xFFFFFF, id)
    end
    -- local id = select(2, self:GetSpell())
    if id then addLine(self, id) end
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

 