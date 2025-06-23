HDH_AT_ConfigDB = {}
local L = HDH_AT_L
local CONFIG = HDH_AT_ConfigDB
local UTIL = HDH_AT_UTIL

CONFIG.VERSION = 2.9

CONFIG.ANI_HIDE = 1
CONFIG.ANI_SHOW = 2

CONFIG.COOLDOWN_UP     = 1
CONFIG.COOLDOWN_DOWN   = 2
CONFIG.COOLDOWN_LEFT   = 3
CONFIG.COOLDOWN_RIGHT  = 4
CONFIG.COOLDOWN_CIRCLE = 5
CONFIG.COOLDOWN_NONE = 6

CONFIG.FONT_LOCATION_TL = 1
CONFIG.FONT_LOCATION_BL = 2
CONFIG.FONT_LOCATION_TR = 3
CONFIG.FONT_LOCATION_BR = 4
CONFIG.FONT_LOCATION_C  = 5
CONFIG.FONT_LOCATION_OT = 6
CONFIG.FONT_LOCATION_OB = 7
CONFIG.FONT_LOCATION_OL = 8
CONFIG.FONT_LOCATION_OR = 9
CONFIG.FONT_LOCATION_BAR_L = 10
CONFIG.FONT_LOCATION_BAR_C = 11
CONFIG.FONT_LOCATION_BAR_R = 12
CONFIG.FONT_LOCATION_HIDE = 13
CONFIG.FONT_LOCATION_BAR_T = 14
CONFIG.FONT_LOCATION_BAR_B = 15

--HDH_AT_DB.FONT_LOCATION_OT2 = 7
--HDH_AT_DB.FONT_LOCATION_OB2 = 9

CONFIG.BAR_LOCATION_T = 1
CONFIG.BAR_LOCATION_B = 2
CONFIG.BAR_LOCATION_L = 3
CONFIG.BAR_LOCATION_R = 4

CONFIG.ORDERBY_REG       = 1 
CONFIG.ORDERBY_CD_ASC    = 2
CONFIG.ORDERBY_CD_DESC   = 3
CONFIG.ORDERBY_CAST_ASC  = 4
CONFIG.ORDERBY_CAST_DESC = 5

CONFIG.TIME_TYPE_FLOOR = 1
CONFIG.TIME_TYPE_CEIL  = 2
CONFIG.TIME_TYPE_FLOAT = 3

CONFIG.DISPLAY_ICON = 1
CONFIG.DISPLAY_BAR = 2
CONFIG.DISPLAY_ICON_AND_BAR = 3

CONFIG.USE_GLOBAL_CONFIG = 1
CONFIG.USE_SEVERAL_CONFIG = 2

CONFIG.BAR_TEXTURE = {
    {name ="BantoBar", texture = "Interface/AddOns/HDH_AuraTracker/Texture/BantoBar", texture_r = "Interface/AddOns/HDH_AuraTracker/Texture/BantoBar_r"},
    {name ="Minimalist", texture = "Interface/AddOns/HDH_AuraTracker/Texture/Minimalist", texture_r = "Interface/AddOns/HDH_AuraTracker/Texture/Minimalist"},
    {name ="NormTex", texture = "Interface/AddOns/HDH_AuraTracker/Texture/normTex", texture_r = "Interface/AddOns/HDH_AuraTracker/Texture/normTex"},
    {name ="Smooth", texture = "Interface/AddOns/HDH_AuraTracker/Texture/Smooth", texture_r = "Interface/AddOns/HDH_AuraTracker/Texture/Smooth"},
    {name ="Blizzard", texture = "Interface/TARGETINGFRAME/UI-StatusBar", texture_r = "Interface/TARGETINGFRAME/UI-StatusBar"},
    -- {name ="Blizzard", texture = "Interface/Vehicles/Vehicle_Target_Base_01", texture_r = "Interface/Vehicles/Vehicle_Target_Base_01"},
    {name = L.NONE, texture = "Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg", texture_r = "Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg"}
}

CONFIG.ALIGN_LIST = {"left","center","right","TOP","BOTTOM"}

CONFIG.AURA_FILTER_REG = 1
CONFIG.AURA_FILTER_ALL = 2
CONFIG.AURA_FILTER_ONLY_BOSS = 3

CONFIG.AURA_CASTER_ALL = 1
CONFIG.AURA_CASTER_ONLY_MINE = 2

CONFIG.GLOW_CONDITION_NONE = 0
CONFIG.GLOW_CONDITION_ACTIVE = 1
CONFIG.GLOW_CONDITION_TIME = 2
CONFIG.GLOW_CONDITION_COUNT = 3
CONFIG.GLOW_CONDITION_VALUE = 4

CONFIG.SPELL_ALWAYS_DISPLAY = 1
CONFIG.SPELL_HIDE_TIME_OFF = 2
CONFIG.SPELL_HIDE_TIME_OFF_AS_SPACE = 3
CONFIG.SPELL_HIDE_TIME_ON = 4
CONFIG.SPELL_HIDE_TIME_ON_AS_SPACE = 5

CONFIG.SPELL_HIDE_AS_SPACE = 1
CONFIG.SPELL_HIDE = 2

CONFIG.CONDITION_GT_OR_EQ = 1
CONFIG.CONDITION_LT_OR_EQ = 2
CONFIG.CONDITION_EQ = 3

CONFIG.INNER_CD_BUFF = 1

local DEFAULT_DISPLAY = { 

    -- 기본 설정
    common = {
        always_show = false, 
        display_mode = CONFIG.DISPLAY_ICON,
        order_by = CONFIG.ORDERBY_REG,
        reverse_h = false, 
        reverse_v = false,
        show_tooltip = false,
        location_fix = false,

        column_count = 5,
        margin_v = 2, 
        margin_h = 2, 
        default_color = false,
    },

    cooldown = {
        maxtime = -1,
        use_not_enough_mana_color = true,
        not_enough_mana_color = {0.35, 0.35, 0.78, 1},
        use_out_range_color = true,
        out_range_color = {0.53, 0.1, 0.1, 1},
        show_global_cooldown = true
    },

    -- 아이콘 설정
    icon = { 
        able_buff_cancel = false, 
        cooldown = CONFIG.COOLDOWN_UP,
        size = 40, 
        on_alpha = 1, 
        off_alpha = 0.5,
        active_border_color = {0,1,0,1}, 
        border_size = 2, 
        cooldown_bg_color = {0,0,0,0.75},
        desaturation = true, 
        spark_color = {1,1,1,1},
    }, 

    -- 바 설정
    bar = { 
        to_fill = false, 
        show_spark = true,
        color = {0.3,1,0.3, 1}, 
        use_full_color = false, 
        full_color = {0.3,1,0.3, 1}, 
        bg_color = {0,0,0,0.5}, 
        texture = 1,
        spark_color = {1,1,1,0.7},
        location = CONFIG.BAR_LOCATION_R,
        cooldown_progress = CONFIG.COOLDOWN_LEFT,
        width = 150, 
        height= 40
    },

    -- 글자 설정
    font = { 
        cd_size= 15, 
        cd_location = CONFIG.FONT_LOCATION_TR, 
        cd_format = CONFIG.TIME_TYPE_CEIL, -- 쿨 다운
        cd_color={1,1,0, 1}, 
        cd_color_5s={1,0,0, 1}, 
        cd_abbreviate = true,
        
        count_size = 15, 
        count_location = CONFIG.FONT_LOCATION_BL, 
        count_color={1, 1, 1, 1}, -- 중첩

        v1_size = 15, 
        v1_location = CONFIG.FONT_LOCATION_BR, 
        v1_color = {1,1,1, 1}, 
        v1_abbreviate = true, -- 1차

        v2_size = 15, 
        v2_location = CONFIG.FONT_LOCATION_BR,
        v2_color = {1,1,1,1}, -- 2차
        
        show_name = true, 
        name_location = CONFIG.NAME_ALIGN_CENTER,
        name_size=15, 
        name_margin_left=5, 
        name_margin_right=5, 
        name_color = {1,1,1,1}, 
        name_color_off = {1,1,1,0.3}
    } -- 폰트 종류 FRIZQT__
}

HDH_AT_DB = {
    version = CONFIG.VERSION,
    show_tooltip_id = true,
    show_latest_spell = true,
    ui = {
        global_ui = DEFAULT_DISPLAY
    },
    tracker = {} -- [전문화][특성][추적]
}

--[[
    tracker.
    id
    name
    type
    unit
    aura_caster
    aura_filter
    trait 
]]--

function HDH_AT_ConfigDB:GetVersion()
    return HDH_AT_DB.version
end

function HDH_AT_ConfigDB:SetVersion(version)
    HDH_AT_DB.version = version
end

function HDH_AT_ConfigDB:HasUI(trackerId)
    if HDH_AT_DB.ui[trackerId] then
        return true
    else
        return false
    end
end

function HDH_AT_ConfigDB:GetUI(trackerId)
    if HDH_AT_DB.ui[trackerId] == nil then
        return HDH_AT_DB.ui.global_ui
    else
        return HDH_AT_DB.ui[trackerId]
    end
end

function HDH_AT_ConfigDB:DeleteTracker(deleteId)
    for idx = deleteId, #(HDH_AT_DB.tracker)  do
        HDH_AT_DB.tracker[idx].id = HDH_AT_DB.tracker[idx].id -1
        HDH_AT_DB.tracker[idx] = HDH_AT_DB.tracker[idx+1]
        HDH_AT_DB.ui[idx] = HDH_AT_DB.ui[idx+1]
    end
end

function HDH_AT_ConfigDB:IsExistsTracker(id)
    return HDH_AT_DB.tracker[id] and true or false
end

function HDH_AT_ConfigDB:HasTraits(traitId)
    for i, tracker in ipairs(HDH_AT_DB.tracker) do
        if UTIL.HasValue(tracker.trait, traitId) then
            return true
        end
    end
    return false
end

function HDH_AT_ConfigDB:InsertTracker(name, type, unit, aura_filter, aura_caster, trait)
    table.insert(HDH_AT_DB.tracker, {
        id = #HDH_AT_DB.tracker + 1,
        element = {},
        location = {
            x = 0, 
            y = 0
        }
    })
    self:UpdateTracker(#HDH_AT_DB.tracker, name, type, unit, aura_filter, aura_caster, trait)
    return #HDH_AT_DB.tracker
end

function HDH_AT_ConfigDB:GetLocation(trackerId)
    return HDH_AT_DB.tracker[trackerId].location
end

function HDH_AT_ConfigDB:UpdateTracker(id, name, type, unit, aura_filter, aura_caster, trait)
    HDH_AT_DB.tracker[id].name = name
    HDH_AT_DB.tracker[id].type = type
    HDH_AT_DB.tracker[id].unit = unit
    HDH_AT_DB.tracker[id].aura_caster = aura_caster
    HDH_AT_DB.tracker[id].aura_filter = aura_filter
    HDH_AT_DB.tracker[id].trait = trait
end

function HDH_AT_ConfigDB:SwapTracker(id_1, id_2)
    local tmp = HDH_AT_DB.tracker[id_1]
    HDH_AT_DB.tracker[id_1] = HDH_AT_DB.tracker[id_2]
    HDH_AT_DB.tracker[id_2] = tmp
    tmp = HDH_AT_DB.tracker[id_1].id
    HDH_AT_DB.tracker[id_1].id = HDH_AT_DB.tracker[id_2].id
    HDH_AT_DB.tracker[id_2].id = tmp


    tmp = HDH_AT_DB.ui[id_1]
    HDH_AT_DB.ui[id_1] = HDH_AT_DB.ui[id_2]
    HDH_AT_DB.ui[id_2] = tmp
end

function HDH_AT_ConfigDB:GetTrackerIds()
    local ret = {}
    for _, tracker in ipairs(HDH_AT_DB.tracker) do
        ret[#ret+1] = tracker.id
    end

    return ret --tracker.id, tracker.name, tracker.type, tracker.unit, tracker.aura_type
end

function HDH_AT_ConfigDB:ClearTraits(trackerId)
    local tmp = HDH_AT_DB.tracker[trackerId]
    tmp.trait ={}
end

function HDH_AT_ConfigDB:GetUnusedTrackerIds()
    local ret = {}
    for _, tracker in ipairs(HDH_AT_DB.tracker) do
        if not tracker.trait or #tracker.trait == 0 then
            ret[#ret+1] = tracker.id
        end
    end

    return ret --tracker.id, tracker.name, tracker.type, tracker.unit, tracker.aura_type
end

function HDH_AT_ConfigDB:GetTrackerIdsByTraits(talentId, traitId)
    local ret = {}
    for i, tracker in ipairs(HDH_AT_DB.tracker) do
        if UTIL.HasValue(tracker.trait, talentId) or UTIL.HasValue(tracker.trait, traitId) then
            ret[#ret+1] = tracker.id
        end
    end

    return ret --tracker.id, tracker.name, tracker.type, tracker.unit, tracker.aura_type
end

function HDH_AT_ConfigDB:GetTracker(trackerId)
    return HDH_AT_DB.tracker[trackerId]
end

function HDH_AT_ConfigDB:GetTrackerInfo(trackerId)
    if HDH_AT_DB.tracker[trackerId] then
        local tracker = HDH_AT_DB.tracker[trackerId]
        return tracker.id, tracker.name, tracker.type, tracker.unit, tracker.aura_filter, tracker.aura_caster, tracker.trait
    else
        return nil
    end
end

function HDH_AT_ConfigDB:GetTrackerElementSize(trackerId)
    if HDH_AT_DB.tracker[trackerId] then
        return #(HDH_AT_DB.tracker[trackerId].element or {})
    else
        return nil
    end
end

function HDH_AT_ConfigDB:GetTrackerElement(trackerId, elementIndex)
    if HDH_AT_DB.tracker and HDH_AT_DB.tracker[trackerId] and HDH_AT_DB.tracker[trackerId].element[elementIndex] then
        local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
        return element.key, element.id, element.name, element.texture, element.display, element.glowType, element.isValue, element.isItem
    else
        return nil
    end
end

function HDH_AT_ConfigDB:SwapTrackerElement(trackerId, eidx_1, eidx_2)
    if HDH_AT_DB.tracker and HDH_AT_DB.tracker[trackerId] then
        local e1 = HDH_AT_DB.tracker[trackerId].element[eidx_1]
        local e2 = HDH_AT_DB.tracker[trackerId].element[eidx_2]
        local tmp
        tmp = e1
        HDH_AT_DB.tracker[trackerId].element[eidx_1] = e2
        HDH_AT_DB.tracker[trackerId].element[eidx_2] = tmp
    end
end

function HDH_AT_ConfigDB:TrancateTrackerElements(trackerId)
    HDH_AT_DB.tracker[trackerId].element = {}
end

function HDH_AT_ConfigDB:DeleteTrackerElement(trackerId, elementIndex)
    if not HDH_AT_DB.tracker[trackerId].element[elementIndex] then
        return false
    end
    for i = elementIndex, (#(HDH_AT_DB.tracker[trackerId].element)-1) do
        HDH_AT_DB.tracker[trackerId].element[i] = HDH_AT_DB.tracker[trackerId].element[i+1]
    end
    local size = #HDH_AT_DB.tracker[trackerId].element
    HDH_AT_DB.tracker[trackerId].element[size] = nil
end

function HDH_AT_ConfigDB:SetReadOnlyTrackerElement(trackerId, elementIndex, readOnly)
    if HDH_AT_DB.tracker[trackerId].element[elementIndex] then
        HDH_AT_DB.tracker[trackerId].element[elementIndex].readOnly = readOnly or true
    end
end

function HDH_AT_ConfigDB:IsReadOnlyTrackerElement(trackerId, elementIndex)
    if HDH_AT_DB.tracker[trackerId].element[elementIndex] then
        return HDH_AT_DB.tracker[trackerId].element[elementIndex].readOnly or false
    end
    return false
end

function HDH_AT_ConfigDB:AddTrackerElement(trackerId, key, id, name, texture, display, isValue, isItem)
    if not HDH_AT_DB.tracker[trackerId].element then
        HDH_AT_DB.tracker[trackerId].element = {}
    end
    local elementIndex = #HDH_AT_DB.tracker[trackerId].element + 1
    HDH_AT_DB.tracker[trackerId].element[elementIndex] = {}
    HDH_AT_ConfigDB:SetTrackerElement(trackerId, elementIndex, key, id, name, texture, display, isValue, isItem)
    return elementIndex
end

function HDH_AT_ConfigDB:SetTrackerElement(trackerId, elementIndex, key, id, name, texture, display, isValue, isItem)
    if not HDH_AT_DB.tracker[trackerId].element[elementIndex] then
        HDH_AT_DB.tracker[trackerId].element[elementIndex] = {}
    end
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
	element.key = key
	element.id = id
	element.name = name
	element.display = display
	element.texture = texture
    if not element.defaultTexture then element.defaultTexture = texture end
	element.isItem = isItem
    element.isValue = isValue

    local glowType = HDH_AT_ConfigDB:GetTrackerElementGlow(trackerId, elementIndex)
    if not glowType then
        element.glowType = CONFIG.GLOW_CONDITION_NONE
    end
end

function HDH_AT_ConfigDB:SetTrackerElementImage(trackerId, elementIndex, texture, key, isItem)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    if element then
        element.texture = texture
        element.textureKey = key
        element.textureIsItem = isItem
    end
end

function HDH_AT_ConfigDB:GetTrackerElementImage(trackerId, elementIndex)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    if element then
        return element.texture, element.textureKey, element.textureIsItem
    else
        return nil
    end
end

function HDH_AT_ConfigDB:GetTrackerElementDefaultImage(trackerId, elementIndex)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    return element.defaultTexture
end

function HDH_AT_ConfigDB:GetTrackerElementDisplay(trackerId, elementIndex)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    return element.display or CONFIG.SPELL_ALWAYS_DISPLAY, element.connectedSpellId, element.connectedSpellIsItem, element.unlearnedHideMode
end

function HDH_AT_ConfigDB:UpdateTrackerElementDisplay(trackerId, elementIndex, value, connectedSpellId, connectedSpellIsItem, unlearnedHideMode)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    element.display = value
    element.connectedSpellId = connectedSpellId
    element.unlearnedHideMode = unlearnedHideMode
    element.connectedSpellIsItem = connectedSpellIsItem
end

function HDH_AT_ConfigDB:UpdateTrackerElementGlow(trackerId, elementIndex, glowType, condition, value)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    element.glowType = glowType
    element.glowCondition = condition
    element.glowValue = value or 0
end

function HDH_AT_ConfigDB:GetTrackerElementGlow(trackerId, elementIndex)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    if element then
        return element.glowType or CONFIG.GLOW_CONDITION_NONE,  element.glowCondition, element.glowValue
    else
        return CONFIG.GLOW_CONDITION_NONE, nil, nil
    end
end

function HDH_AT_ConfigDB:UpdateTrackerElementValue(trackerId, elementIndex, bool)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    element.isValue = bool
end

function HDH_AT_ConfigDB:SetTrackerElementSplitValues(trackerId, elementIndex, splitValues)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    element.splitValues = splitValues
end

function HDH_AT_ConfigDB:GetTrackerElementSplitValues(trackerId, elementIndex)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    if element then
        return UTIL.Deepcopy(element.splitValues)
    else
        return nil
    end
end

function HDH_AT_ConfigDB:UpdateTrackerElementInnerCooldown(trackerId, elementIndex, innerTrackingType, innerSpellId, innerCooldown)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    element.innerTrackingType = innerTrackingType
    element.innerSpellId = innerSpellId
    element.innerCooldown = innerCooldown
end

function HDH_AT_ConfigDB:GetTrackerElementInnerCooldown(trackerId, elementIndex)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    if element then
        return element.innerTrackingType, element.innerSpellId, element.innerCooldown
    else
        return nil
    end
end

function HDH_AT_ConfigDB:hasTrackerUI(id)
    return HDH_AT_DB.ui[id] and true or false
end

function HDH_AT_ConfigDB:GetTrackerUI(id)
    local id = id or "global_ui"
    return HDH_AT_DB.ui[id]
end

function HDH_AT_ConfigDB:GetTrackerUIKey(trackerId)
    if HDH_AT_DB.ui[trackerId] then
        return trackerId
    else
        return "global_ui"
    end
end

-- function HDH_AT_ConfigDB:GetGlobalKey()
--     return "global"
-- end

function HDH_AT_ConfigDB:GetKey(trackerId, key)
    if (string.find(key, "%%s")) then
        if (string.find(key, "ui")) then
            if HDH_AT_DB.ui[trackerId] then
                return string.format(key, trackerId)
            else
                return string.format(key, "global_ui")
            end
        else
            if trackerId then
                return string.format(key, trackerId)
            else
                return nil
            end
        end
    else
        return key
    end
end

function HDH_AT_ConfigDB:SetValue(key, value)
    local variable = HDH_AT_DB
    local pre_variable = variable
    local last_key
    for token in string.gmatch(key, "[a-z0-9_]+") do
        pre_variable = variable
        n_token = tonumber(token)
        variable = variable[n_token or token]
        last_key = token
    end
    pre_variable[last_key] = value
end

function HDH_AT_ConfigDB:SetTrackerValue(trackerId, key, value)
    key = self:GetKey(trackerId, key)
    if key then
        self:SetValue(key, value)
    end
end

function HDH_AT_ConfigDB:GetTrackerValue(trackerId, key)
    key = self:GetKey(trackerId, key)
    return self:GetValue(key)
end

function HDH_AT_ConfigDB:GetValue(key)
    local variable = HDH_AT_DB
    for token in string.gmatch(key, "[a-z0-9_]+") do
        n_token = tonumber(token)
        variable = variable[n_token or token]
    end
    return variable
end

function HDH_AT_ConfigDB:CopyGlobelToTracker(trackerId)
    HDH_AT_DB.ui[trackerId] = UTIL.Deepcopy(HDH_AT_DB.ui["global_ui"]) 
end

function HDH_AT_ConfigDB:ClearTracker(trackerId)
    HDH_AT_DB.ui[trackerId] = nil
end

function HDH_AT_ConfigDB:CheckTraitsDB()
    local idx, transitId
    local ids = self:GetTrackerIds()
    for _, id in ipairs(ids) do
        traits = select(7, self:GetTrackerInfo(id))
        for idx=#traits, 1, -1 do
            transitId = traits[idx]
            if not C_Traits.GetConfigInfo(transitId) and not HDH_AT_UTIL.GetSpecializationInfoByID(transitId) then
                table.remove(traits, idx)
            end
        end
    end
end

function HDH_AT_ConfigDB:Reset()
    HDH_AT_DB = nil
end

function HDH_AT_ConfigDB:CopyTracker(trackerId, copyName)
    local copyTracker = UTIL.Deepcopy(HDH_AT_DB.tracker[trackerId]) 
    local newId = #HDH_AT_DB.tracker + 1
    copyTracker.name = copyName
    copyTracker.id = newId
    HDH_AT_DB.tracker[newId] = copyTracker
    if self:hasTrackerUI(trackerId) then
        local ui = UTIL.Deepcopy(HDH_AT_DB.ui[trackerId])
        HDH_AT_DB.ui[newId] = ui
    end

    return newId
end

function HDH_AT_ConfigDB:AppendProfile(supportTrackerList, data)
    local ids = self:GetTrackerIds()
    local id = #ids
    local match = false
    local talentID
    for _, config in ipairs(data) do
        id = id + 1
        match = false
        for _, trait in ipairs(config.tracker.trait) do
            for i = 1, MAX_TALENT_TABS do
                talentId, _, _, _ = HDH_AT_UTIL.GetSpecializationInfo(i)
                if talentId == nil then
                    break
                end
                if trait == talentId then
                    match = true
                    break
                end
            end
            if match then
                break
            end
        end
        if not match then
            talentID = select(1,HDH_AT_UTIL.GetSpecializationInfo(HDH_AT_UTIL.GetSpecialization()))
            config.tracker.trait = {talentID}
        end
        if supportTrackerList[config.tracker.type] then
            config.tracker.id = id
            HDH_AT_DB.tracker[id] = config.tracker
            HDH_AT_DB.ui[id] = config.ui
        end
    end
end

function HDH_AT_ConfigDB:VaildationProfile(data)
    if not data.version then
        return false
    end

    if HDH_AT_DB.version ~= data.version then
        return false
    end
    for _, config in ipairs(data) do
        if not config.ui or not config.tracker then
            return false
        end
    end

    return true
end