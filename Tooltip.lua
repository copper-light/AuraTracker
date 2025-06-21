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

local function OnTooltipSetId(tooltip, data)
    if not HDH_AT_DB.show_tooltip_id then return end
    if data and data.id then addLine(tooltip, data.id) end
end

do

    if select(4, GetBuildInfo()) <= 49999 then -- 대격변
        
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

        hooksecurefunc(GameTooltip, "SetAction", function(self, ...)
            if not HDH_AT_DB.show_tooltip_id then return end
            local id = select(2, self:GetSpell())
            if not id then
                id = select(3, self:GetItem())
            end

            if id then addLine(self, id) end
        end)

        -- spell tooltip
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
                if id then addLine(self, id) end
            end
        end)

         -- item tooltip
        GameTooltip:HookScript("OnTooltipSetItem", function(self)
            if not HDH_AT_DB.show_tooltip_id then return end
            local link = select(2,self:GetItem())
            if link then
                local id = tonumber(link:match("item:(%d*)"))
                if id then addLine(self, id) end
            end
        end)

        hooksecurefunc(GameTooltip, 'SetBagItem', function(self, ...)
            if not HDH_AT_DB.show_tooltip_id then return end
            local id = select(3, self:GetItem())
            if id then addLine(self, id) end
        end)

    else
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, OnTooltipSetId)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnTooltipSetId)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetId)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, OnTooltipSetId)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Talent, OnTooltipSetId)
    end
    
end

function PrintLearnedTalents()
    local configID = C_ClassTalents.GetActiveConfigID()
    if not configID then return end

    local configInfo = C_Traits.GetConfigInfo(configID)
    if not configInfo then return end

    -- 트리 ID 가져오기
    local treeID = configInfo.treeIDs[1] -- 보통 첫 번째 트리가 클래스/특성 트리입니다.
    if not treeID then return end

    -- 트리 정보 가져오기
    -- local treeInfo = C_Traits.GetTreeInfo(treeID)
    -- if not treeInfo then return end

    -- 트리의 모든 노드 정보 가져오기
    
    for _, treeID in ipairs(configInfo.treeIDs) do
        local nodes = C_Traits.GetTreeNodes(treeID)
        for _, nodeID in ipairs(nodes) do
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
            if nodeInfo and nodeInfo.ranksPurchased and nodeInfo.ranksPurchased > 0 then
                for _, e in ipairs(nodeInfo.entryIDs) do
                    local entryInfo = C_Traits.GetEntryInfo(configID, e)
                    if entryInfo then
                        print("특성 ID:", nodeInfo.ID, "| 이름:", entryInfo.name, "| 단계:", nodeInfo.ranksPurchased)
                    end
                end
            end
        end
    end
end