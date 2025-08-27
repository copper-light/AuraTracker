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

CONFIG.GLOW_EFFECT_DEFAULT = 0
CONFIG.GLOW_EFFECT_COLOR_SPARK = 1

CONFIG.SPELL_ALWAYS_DISPLAY = 1
CONFIG.SPELL_HIDE_TIME_OFF = 2
CONFIG.SPELL_HIDE_TIME_OFF_AS_SPACE = 3
CONFIG.SPELL_HIDE_TIME_ON = 4
CONFIG.SPELL_HIDE_TIME_ON_AS_SPACE = 5
CONFIG.SPELL_HIDE_ALWAYS = 6

CONFIG.SPELL_HIDE_AS_SPACE = 1
CONFIG.SPELL_HIDE = 2

CONFIG.CONDITION_GT_OR_EQ = 1
CONFIG.CONDITION_LT_OR_EQ = 2
CONFIG.CONDITION_EQ = 3
CONFIG.CONDITION_GT = 4
CONFIG.CONDITION_LT = 5

CONFIG.INNER_CD_BUFF = 1

CONFIG.BAR_SPLIT_RATIO = 1
CONFIG.BAR_SPLIT_FIXED_VALUE = 2

CONFIG.BAR_TYPE_BY_TIME = 1
CONFIG.BAR_TYPE_BY_COUNT  = 2
CONFIG.BAR_TYPE_BY_VALUE = 3

CONFIG.BAR_MAX_TYPE_MANUAL = 1
CONFIG.BAR_MAX_TYPE_AUTO = 2

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
        name_location = CONFIG.FONT_LOCATION_BAR_C,
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

local EFFECT_DEFUALT_COLOR = {1, 0.8, 0., 1.}
local EFFECT_DEFUALT_PER_SEC = 2

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

function HDH_AT_ConfigDB:VersionUpdateDB()
    local DB = self
	if DB:GetVersion() == 2.0 then
		local id, name, type, unit, aura_filter, aura_caster, trait
		for _, id in ipairs(DB:GetTrackerIds()) do
			id, name, type, unit, aura_filter, aura_caster, trait = DB:GetTrackerInfo(id)
			if unit == 1 then
				unit = 'player'
			elseif unit == 2 then
				unit = 'target'
			elseif unit == 3 then
				unit = 'focus'
			end
			DB:UpdateTracker(id, name, type, unit, aura_filter, aura_caster, trait)
		end
		DB:SetVersion(2.1)
	end
	-- reverse_fill -> reverse_fill
	if DB:GetVersion() == 2.1 then
		local ui = DB:GetTrackerUI()
		ui.bar.reverse_fill = ui.bar.reverse_fill
		ui.bar.reverse_fill = nil
		local ui
		for _, id in ipairs(DB:GetTrackerIds()) do
			if DB:hasTrackerUI(id) then
				ui = DB:GetTrackerUI(id)
				ui.bar.reverse_fill = ui.bar.reverse_fill
				ui.bar.reverse_fill = nil
			end
		end
		DB:SetVersion(2.2)
	end

	-- ADD defaultTexture
	if DB:GetVersion() == 2.2 then
		local elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem
		for _, trackerId in ipairs(DB:GetTrackerIds()) do
			for elemIdx = 1, DB:GetTrackerElementSize(trackerId) or 0 do
				elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, elemIdx)
				DB:SetTrackerElement(trackerId, elemIdx, elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem)
			end
		end
		DB:SetVersion(2.3)
	end

	if DB:GetVersion() == 2.3 then
		local id, name, type, unit, aura_filter, aura_caster, trait
		for _, id in ipairs(DB:GetTrackerIds()) do
			HDH_AT_DB.tracker[id].trait = HDH_AT_DB.tracker[id].transit
			HDH_AT_DB.tracker[id].transit = nil
		end
		DB:SetVersion(2.4)
	end

	if DB:GetVersion() == 2.4 then
		local ui = DB:GetTrackerUI()
		if ui.cooldown == nil then ui.cooldown = {} end
		ui.cooldown.not_enough_mana_color = {0.35, 0.35, 0.78, 1}
		ui.cooldown.out_range_color =  {0.53, 0.1, 0.1, 1}
		ui.cooldown.use_not_enough_mana_color = true
		ui.cooldown.use_out_range_color = true
		local ui
		for _, id in ipairs(DB:GetTrackerIds()) do
			if DB:hasTrackerUI(id) then
				ui = DB:GetTrackerUI(id)
				if ui.cooldown == nil then ui.cooldown = {} end
				ui.cooldown.not_enough_mana_color = {0.35, 0.35, 0.78, 1}
				ui.cooldown.out_range_color =  {0.53, 0.1, 0.1, 1}
				ui.cooldown.use_not_enough_mana_color = true
				ui.cooldown.use_out_range_color = true
			end
		end
		DB:SetVersion(2.5)
	end

	if DB:GetVersion() == 2.5 then
		local ui = DB:GetTrackerUI()
		
		if ui.bar.location == DB.BAR_LOCATION_R and ui.bar.reverse_progress == false then
			ui.bar.cooldown_progress = DB.COOLDOWN_LEFT
		elseif ui.bar.location == DB.BAR_LOCATION_R and ui.bar.reverse_progress == true then
			ui.bar.cooldown_progress = DB.COOLDOWN_RIGHT
		elseif ui.bar.location == DB.BAR_LOCATION_BOTTOM and ui.bar.reverse_progress == false then
			ui.bar.cooldown_progress = DB.COOLDOWN_DOWN
		else
			ui.bar.cooldown_progress = DB.COOLDOWN_UP
		end
		ui.bar.reverse_progress = nil
		ui.bar.to_fill = ui.bar.reverse_fill
		ui.bar.reverse_fill = nil

		if ui.font.show_name then
			if ui.font.name_align == "LEFT" then
				ui.text.name_location = DB.FONT_LOCATION_BAR_L
			elseif ui.font.name_align == "RIGHT" then
				ui.font.name_location = DB.FONT_LOCATION_BAR_R
			elseif ui.font.name_align == "CENTER" then
				ui.font.name_location = DB.FONT_LOCATION_BAR_C
			elseif ui.font.name_align == "TOP" then
				ui.font.name_location = DB.FONT_LOCATION_BAR_T
			else -- BOTTOM
				ui.font.name_location = DB.FONT_LOCATION_BAR_B
			end
		else
			ui.font.name_location = DB.FONT_LOCATION_HIDE
		end

		local ui
		for _, id in ipairs(DB:GetTrackerIds()) do
			if DB:hasTrackerUI(id) then
				ui = DB:GetTrackerUI(id)
				if ui.bar.location == DB.BAR_LOCATION_R and ui.bar.reverse_progress == false then
					ui.bar.cooldown_progress = DB.COOLDOWN_LEFT
				elseif ui.bar.location == DB.BAR_LOCATION_R and ui.bar.reverse_progress == true then
					ui.bar.cooldown_progress = DB.COOLDOWN_RIGHT
				elseif ui.bar.location == DB.BAR_LOCATION_BOTTOM and ui.bar.reverse_progress == false then
					ui.bar.cooldown_progress = DB.COOLDOWN_DOWN
				else
					ui.bar.cooldown_progress = DB.COOLDOWN_UP
				end
				ui.bar.reverse_progress = nil
				ui.bar.to_fill = ui.bar.reverse_fill
				ui.bar.reverse_fill = nil

				if ui.font.show_name then
					if ui.font.name_align == "LEFT" then
						ui.text.name_location = DB.FONT_LOCATION_BAR_L
					elseif ui.font.name_align == "RIGHT" then
						ui.font.name_location = DB.FONT_LOCATION_BAR_R
					elseif ui.font.name_align == "CENTER" then
						ui.font.name_location = DB.FONT_LOCATION_BAR_C
					elseif ui.font.name_align == "TOP" then
						ui.font.name_location = DB.FONT_LOCATION_BAR_T
					else -- BOTTOM
						ui.font.name_location = DB.FONT_LOCATION_BAR_B
					end
				else
					ui.font.name_location = DB.FONT_LOCATION_HIDE
				end
			end
		end
		DB:SetVersion(2.6)
	end

	if DB:GetVersion() == 2.6 then
		local ui = DB:GetTrackerUI()
		local location
		local x, y 

		ui.common.hide_in_raid = false
		for _, id in ipairs(DB:GetTrackerIds()) do
			location = DB:GetLocation(id)
			ui = DB:GetTrackerUI(id) or DB:GetTrackerUI()

			ui.common.hide_in_raid = false
			
			location.x = location.x + (ui.icon.size /2)
			location.y = location.y + (ui.icon.size /2)
			x, y = UTIL.AdjustLocation(location.x, location.y)
			location.x = x
			location.y = y
		end
		DB:SetVersion(2.7)
	end

	if DB:GetVersion() == 2.7 then
		local ui = DB:GetTrackerUI()
		ui.icon.border_size = 2
		local element
		for _, trackerId in ipairs(DB:GetTrackerIds()) do
			if DB:hasTrackerUI(trackerId) then
				ui = DB:GetTrackerUI(trackerId)
				ui.icon.border_size = 2
			end

			for elemIdx = 1, DB:GetTrackerElementSize(trackerId) or 0 do
				if HDH_AT_DB.tracker and HDH_AT_DB.tracker[trackerId] and HDH_AT_DB.tracker[trackerId].element[elemIdx] then
					element = HDH_AT_DB.tracker[trackerId].element[elemIdx]
					if element.isAlways then
						element.display = DB.SPELL_ALWAYS_DISPLAY
					else
						element.display = DB.SPELL_HIDE
					end
				end
			end
		end
		HDH_AT_DB.show_latest_spell = true
		DB:SetVersion(2.8)
	end

	if DB:GetVersion() == 2.8 then
		local ui = DB:GetTrackerUI()
		ui.cooldown.show_global_cooldown = true
		for _, id in ipairs(DB:GetTrackerIds()) do
			if DB:hasTrackerUI(id) then
				ui = DB:GetTrackerUI(id)
				ui.cooldown.show_global_cooldown = true
			end
		end
		DB:SetVersion(2.9)
	end

	if DB:GetVersion() == 2.9 then
		local element
		local reg = false
		for _, trackerId in ipairs(DB:GetTrackerIds()) do
			for elemIdx = 1, DB:GetTrackerElementSize(trackerId) or 0 do
				if HDH_AT_DB.tracker and HDH_AT_DB.tracker[trackerId] and HDH_AT_DB.tracker[trackerId].element[elemIdx] then
					element = HDH_AT_DB.tracker[trackerId].element[elemIdx]
					if HDH_AT_DB.tracker[trackerId].type == HDH_TRACKER.TYPE.COOLDOWN or HDH_AT_DB.tracker[trackerId].type == HDH_TRACKER.TYPE.TOTEM then
						if element.isItem then
							if C_Item.IsEquippableItem(element.id) then 
								reg = true
							else
								reg = false
							end
						end
						if reg then
							element.connectedSpellId = element.id
							element.unlearnedHideMode = DB.SPELL_HIDE
							element.connectedSpellIsItem = element.isItem
						end
					end
					
				end
			end
		end
		DB:SetVersion(3.0)
	end
    DB:SetVersion(3.0)

	-- if DB:GetVersion() == 3.0 then
	-- 	for _, trackerId in ipairs(DB:GetTrackerIds()) do
	-- 		local id, name, type, unit, aura_filter, aura_caster, trait = DB:GetTrackerInfo(id)
	-- 		if HDH_TRACKER.TYPE.POWER_ENH_MAELSTROM == type then
	-- 			for elemIdx = 1, DB:GetTrackerElementSize(trackerId) or 0 do
	-- 				if HDH_AT_DB.tracker and HDH_AT_DB.tracker[trackerId] and HDH_AT_DB.tracker[trackerId].element[elemIdx] then
	-- 					local _, _, _, _, values = DB:GetTrackerElementBarInfo(trackerId, elemIdx)
	-- 					local newValues = {}
	-- 					if values and #values > 0 then
	-- 						for _, v in ipairs(values) do 
	-- 							v = math.floor(v / 10)
	-- 							table.insert(newValues, v)
	-- 						end
	-- 						DB:SetTrackerElementBarInfo(trackerId, elemIdx, nil, nil, nil, nil, values)
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- 	DB:SetVersion(3.1)
	-- end


    -- if DB:GetVersion() == 3.1 then
	-- 	for _, trackerId in ipairs(DB:GetTrackerIds()) do
	-- 		local id, name, trackerType, unit, aura_filter, aura_caster, trait = DB:GetTrackerInfo(id)
    --         for elemIdx = 1, DB:GetTrackerElementSize(trackerId) or 0 do
    --             if HDH_AT_DB.tracker and HDH_AT_DB.tracker[trackerId] and HDH_AT_DB.tracker[trackerId].element[elemIdx] then
    --                 local barValueType, barMaxValueType, barMaxValue, splitValues, splitType = DB:GetTrackerElementBarInfo(trackerId, elemIdx)
                    
    --                 local className = HDH_TRACKER.GetClass(trackerType):GetClassName()

    --                 if className =="HDH_AURA_TRACKER" or className =="HDH_C_TRACKER" or className =="HDH_TT_TRACKER" then
    --                     barValueType = CONFIG.BAR_TYPE_BY_TIME
    --                     barMaxValueType = CONFIG.BAR_MAXVALUE_TYPE_TIME

    --                 elseif className =="HDH_COMBO_POINT_TRACKER" or className=="HDH_ESSENCE_TRACKER" then
    --                     barValueType = CONFIG.BAR_TYPE_BY_VALUE
    --                     barMaxValueType = CONFIG.BAR_MAXVALUE_TYPE_COMBO

    --                 elseif className =="HDH_HEALTH_TRACKER" then
    --                     barValueType = CONFIG.BAR_TYPE_BY_TIME
    --                     barMaxValueType = CONFIG.BAR_MAXVALUE_TYPE_HEALTH

    --                 elseif className =="HDH_DK_RUNE_TRACKER" then
    --                     barValueType = CONFIG.BAR_TYPE_BY_TIME
    --                     barMaxValueType = CONFIG.BAR_MAXVALUE_TYPE_TIME

    --                 elseif className =="HDH_ENH_MAELSTROM_TRACKER" then
    --                     barValueType = CONFIG.BAR_TYPE_BY_TIME
    --                     barMaxValueType = CONFIG.BAR_MAXVALUE_TYPE_TIME
                        
    --                 elseif className =="HDH_POWER_TRACKER" then
    --                     barValueType = CONFIG.BAR_TYPE_BY_TIME
    --                     barMaxValueType = CONFIG.BAR_MAXVALUE_TYPE_TIME

    --                 elseif className == "HDH_STAGGER_TRACKER" then
                        
    --                 end

    --                 DB:SetTrackerElementBarInfo(trackerId, elemIdx, barValueType, barMaxValueType, barMaxValue, splitValues, splitType)
    --             end
	-- 		end
	-- 	end
	-- 	DB:SetVersion(3.2)
	-- end
end

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
        local name = element.name
        if element.id then
            name = HDH_AT_UTIL.GetInfo(element.id, element.isItem) or name
        end

        return element.key, element.id, name, element.texture, element.display, element.glowType, element.isValue, element.isItem
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
    if HDH_AT_DB.tracker[trackerId] then
        local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
        return element.defaultTexture
    else
        return nil
    end
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

function HDH_AT_ConfigDB:UpdateTrackerElementGlow(trackerId, elementIndex, glowType, condition, value, effectType, effectColor, effectPerSec)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    element.glowType = glowType
    element.glowCondition = condition
    element.glowValue = value or 0
    element.glowEffectType = effectType or CONFIG.GLOW_EFFECT_DEFAULT
    element.glowEffectColor = effectColor or {1., 0., 0., 1.}
    element.glowEffectPerSec = effectPerSec or EFFECT_DEFUALT_PER_SEC
end

function HDH_AT_ConfigDB:GetTrackerElementGlow(trackerId, elementIndex)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    if element then
        return element.glowType or CONFIG.GLOW_CONDITION_NONE,
               element.glowCondition,
               element.glowValue,
               element.glowEffectType or CONFIG.GLOW_EFFECT_DEFAULT,
               element.glowEffectColor or EFFECT_DEFUALT_COLOR,
               element.glowEffectPerSec or EFFECT_DEFUALT_PER_SEC
    else
        return CONFIG.GLOW_CONDITION_NONE, nil, nil, CONFIG.GLOW_EFFECT_DEFAULT, EFFECT_DEFUALT_COLOR, EFFECT_DEFUALT_PER_SEC
    end
end

function HDH_AT_ConfigDB:UpdateTrackerElementValue(trackerId, elementIndex, bool)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    element.isValue = bool
end

function HDH_AT_ConfigDB:SetTrackerElementBarInfo(trackerId, elementIndex, barValueType, barMaxValueType, barMaxValue, splitValues, splitType)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    element.barValueType = barValueType
    element.barMaxValueType = barMaxValueType
    element.barMaxValue = barMaxValue
    element.splitValues = splitValues
    element.splitType = splitType or CONFIG.BAR_SPLIT_RATIO
end

function HDH_AT_ConfigDB:GetTrackerElementBarInfo(trackerId, elementIndex)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    local barValueType, barMaxValueType, barMaxValue, splitValues, splitType 
    if element then
        if not element.barValueType then
            barValueType, barMaxValueType, barMaxValue, splitValues, splitType = self:GetDefaultBarInfo(HDH_AT_DB.tracker[trackerId].type)
            element.barValueType = barValueType
            element.barMaxValueType = barMaxValueType
            element.barMaxValue =  barMaxValue
            element.splitValues = splitValues
            element.splitType = splitType
        end

        return element.barValueType , 
                element.barMaxValueType , 
                element.barMaxValue , 
                UTIL.Deepcopy(element.splitValues or {}), 
                element.splitType or CONFIG.BAR_SPLIT_RATIO
    else
        return nil
    end
end

function HDH_AT_ConfigDB:SetTrackerElementBarMaxValues(trackerId, elementIndex, durationMax, countMax, valueMax)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    if element then
        element.durationMax = durationMax
        element.countMax = countMax
        element.valueMax = valueMax
    end
end

function HDH_AT_ConfigDB:GetTrackerElementBarMaxValues(trackerId, elementIndex)
    local element = HDH_AT_DB.tracker[trackerId].element[elementIndex]
    if element then
        return element.durationMax or 0, element.countMax or 0, element.valueMax or 0
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

function HDH_AT_ConfigDB:AppendProfile(data)
    local _, MyClass = UnitClass("player")
    local ids = self:GetTrackerIds()
    local id
    local match = false
    local talentID
    local tmp, newArray
    for index, config in ipairs(data) do
        match = false
        id = #ids + index

        if data.class == MyClass and #config.tracker.trait > 0 then
            -- trait 이 있으면 그대로 쓰고 없으면 talentId 로 치환함
            for j, trait in ipairs(config.tracker.trait) do
                if not HDH_AT_UTIL.GetTraitsName(trait) then
                    config.tracker.trait[j] = config.tracker.talentList[j]
                end
            end
            config.tracker.talentList = nil
            
            -- 중복 제거
            tmp = {}
            newArray = {}
            for _, trait in ipairs(config.tracker.trait) do
                if not tmp[trait] then
                    tmp[trait] = true
                    table.insert(newArray, trait)
                end
            end
            config.tracker.trait = newArray
        else
            -- talentId는 애초에 중복 체크하지 않고 저장 했기 때문에, 여기서 중복 처리한 후에 반영해야함
            talentID = select(1,HDH_AT_UTIL.GetSpecializationInfo(HDH_AT_UTIL.GetSpecialization()))
            config.tracker.trait = {talentID}
        end

        config.tracker.id = id
        HDH_AT_DB.tracker[id] = config.tracker
        HDH_AT_DB.ui[id] = config.ui
    end
end

function HDH_AT_ConfigDB:VaildationProfile(data)
    if not data.version then
        return -1
    end

    if HDH_AT_DB.version ~= data.version then
        return -1
    end
    for _, config in ipairs(data) do
        if not config.ui or not config.tracker then
            return -1
        end
    end
    return #data
end

function HDH_AT_ConfigDB:GetDefaultBarInfo(trackerType)
    local className = HDH_TRACKER.GetClass(trackerType):GetClassName()
    local barValueType, barMaxValueType, barMaxValue, splitType 
    if className =="HDH_AURA_TRACKER" or className =="HDH_C_TRACKER" or className =="HDH_TT_TRACKER" then
        barValueType = CONFIG.BAR_TYPE_BY_TIME
        barMaxValueType = CONFIG.BAR_MAX_TYPE_AUTO

    elseif className =="HDH_COMBO_POINT_TRACKER" or className=="HDH_ESSENCE_TRACKER" then
        barValueType = CONFIG.BAR_TYPE_BY_VALUE
        barMaxValueType = CONFIG.BAR_MAX_TYPE_AUTO
        barMaxValue = 1
        splitType = CONFIG.BAR_SPLIT_FIXED_VALUE

    elseif className =="HDH_HEALTH_TRACKER" then
        barValueType = CONFIG.BAR_TYPE_BY_VALUE
        barMaxValueType = CONFIG.BAR_MAX_TYPE_AUTO

    elseif className =="HDH_DK_RUNE_TRACKER" then
        barValueType = CONFIG.BAR_TYPE_BY_TIME
        barMaxValueType = CONFIG.BAR_MAX_TYPE_AUTO

    elseif className =="HDH_ENH_MAELSTROM_TRACKER" then
        barValueType = CONFIG.BAR_TYPE_BY_COUNT 
        barMaxValueType = CONFIG.BAR_MAX_TYPE_AUTO
        
    elseif className =="HDH_POWER_TRACKER" then
        barValueType = CONFIG.BAR_TYPE_BY_VALUE
        barMaxValueType = CONFIG.BAR_MAX_TYPE_AUTO

    elseif className == "HDH_STAGGER_TRACKER" then
        barValueType = CONFIG.BAR_TYPE_BY_VALUE
        barMaxValueType = CONFIG.BAR_MAX_TYPE_AUTO
    end

    return barValueType, barMaxValueType, barMaxValue, {}, splitType or CONFIG.BAR_SPLIT_RATIO
end