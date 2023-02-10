HDH_AT_ConfigFrameMixin = {}
HDH_AT_ConfigFrameMixin.FRAME = {}

local L = HDH_AT_L
local DB = HDH_AT_ConfigDB
local UTIL = HDH_AT_UTIL

local UI_COMP_LIST = {}
local UI_CONFIG_TAB_LIST

local COMP_TYPE = {}
COMP_TYPE.CHECK_BOX = 1
COMP_TYPE.EDIT_BOX = 2
COMP_TYPE.BUTTON = 3
COMP_TYPE.COLOR_PICKER = 4
COMP_TYPE.SLIDER = 5
COMP_TYPE.DROPDOWN = 6
COMP_TYPE.MULTI_SELECTOR = 7
COMP_TYPE.PREV_NEXT_BUTTON = 8
COMP_TYPE.IMAGE_CHECKBUTTON = 9
COMP_TYPE.EDITBOX_ADD_DEL = 10
COMP_TYPE.SWITCH = 11
COMP_TYPE.SPLIT_LINE = 12
COMP_TYPE.MULTILINE_EDITBOX = 13
          
local FRAME_WIDTH = 404
local FRAME_MAX_H = 1000
local FRAME_MIN_H = 260

local STR_TRANSIT_FORMAT = "|cffffc800%s\r\n|cffaaaaaa%s"
local STR_TRACKER_FORMAT = "%s\r\n|cffaaaaaa%s%s"

local MAX_TALENT_TABS = 4

local GRID_SIZE = 30;
local FRAME_W = 400
local FRAME_H = 500
local MAX_H = 1000
local MIN_H = 260
local MAX_SPLIT_ADDFRAME = 5;
local ROW_HEIGHT = 26 -- 오라 row 높이
local EDIT_WIDTH_L = 145
local EDIT_WIDTH_S = 0
local FLAG_ROW_CREATE = 1 -- row 생성 모드
local ANI_MOVE_UP = 1
local ANI_MOVE_DOWN = 0


local DDM_TRACKER_ALL = 0
local DDM_TRACKER_UNUSED = -1

local UI_CONFIG_TAB_LIST= {
	{name=L.TEXT, type="LABEL"},
	{name=L.TIME, type="BUTTON"}, --1
	{name=L.COUNT, type="BUTTON"}, --2
	{name=L.VALUE, type="BUTTON"}, --3
	{name=L.BAR_NAME, type="BUTTON"}, --4

	{name=L.ICON_AND_BAR, type="LABEL"},
	{name=L.ORDER_AND_LOCATION, type="BUTTON"}, --5
	{name=L.ICON, type="BUTTON"},               --6
	{name=L.BAR, type="BUTTON"}, 		        --7

	{name=L.PROFILE, type="LABEL"},
	{name=L.RESET, type="BUTTON"},         -- 8
	{name=L.SHARE, type="BUTTON"},         -- 9
}

local DETAIL_ETC_CONFIG_TAB_LIST= {
	{name=L.DETAIL_CONIFG, type="LABEL"}, 
	{name=L.CHANGE_ICON, type="BUTTON"}, --1
	{name=L.SPLIT_POWER_BAR, type="BUTTON"}, --2
}

local MyClassKor, MyClass = UnitClass("player");
local DDP_TRACKER_LIST = {
	{HDH_TRACKER.TYPE.BUFF, L.BUFF},
	{HDH_TRACKER.TYPE.DEBUFF, L.DEBUFF},
	{HDH_TRACKER.TYPE.COOLDOWN, L.SKILL_COOLDOWN}
}


-- local TrackerTypeName;
-- if MyClass == "MAGE" then TrackerTypeName = L_POWRE_ARCANE_CHARGES;
-- elseif MyClass == "PALADIN" then TrackerTypeName = L_POWRE_HOLY_POWER;
-- elseif MyClass == "WARRIOR" then
-- elseif MyClass == "DRUID" then TrackerTypeName = L_POWRE_COMBO_POINTS;
-- elseif MyClass == "DEATHKNIGHT" then
-- elseif MyClass == "HUNTER" then
-- elseif MyClass == "PRIEST" then
-- elseif MyClass == "ROGUE" then TrackerTypeName = L_POWRE_COMBO_POINTS;
-- elseif MyClass == "SHAMAN" then
-- elseif MyClass == "WARLOCK" then TrackerTypeName = L_POWRE_SOUL_SHARDS;
-- elseif MyClass == "MONK" then TrackerTypeName = L_POWRE_CHI;
-- elseif MyClass == "DEMONHUNTER" then
-- else TrackerTypeName = "2차 자원(콤보)"; end

local powerList = {}
local totemName = L.TOTEM
if MyClass == "MAGE" then 
	totemName = L.MAGE_TOTEM
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_ARCANE_CHARGES, L.POWER_ARCANE_CHARGES})
elseif MyClass == "PALADIN" then 
	totemName = L.PALADIN_TOTEM
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_HOLY_POWER, L.POWER_HOLY_POWER})
elseif MyClass == "WARRIOR" then 
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_RAGE, L.POWER_RAGE})
elseif MyClass == "DRUID" then 
	totemName = L.DRUID_TOTEM
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_ENERGY, L.POWER_ENERGY})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_LUNAR, L.POWER_LUNAR})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_RAGE, L.POWER_RAGE})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_COMBO_POINTS, L.POWER_COMBO_POINTS})
elseif MyClass == "DEATHKNIGHT" then 
	totemName = L.DK_TOTEM
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_RUNIC, L.POWER_RUNIC})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_RUNE, L.POWER_RUNE})
elseif MyClass == "HUNTER" then 
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_FOCUS, L.POWER_FOCUS})
elseif MyClass == "PRIEST" then 
	totemName = L.PRIEST_TOTEM
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_INSANITY, L.POWER_INSANITY})
elseif MyClass == "ROGUE" then
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_ENERGY, L.POWER_ENERGY})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_COMBO_POINTS, L.POWER_COMBO_POINTS})
elseif MyClass == "SHAMAN" then 
	totemName = L.SHAMAN_TOTEM
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_MAELSTROM, L.POWER_MAELSTROM})
elseif MyClass == "WARLOCK" then 
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_SOUL_SHARDS, L.POWER_SOUL_SHARDS})
elseif MyClass == "MONK" then 
	totemName = L.MONK_TOTEM
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_ENERGY, L.POWER_ENERGY})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_CHI, L.POWER_CHI})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.STAGGER, L.STAGGER})
elseif MyClass == "DEMONHUNTER" then 
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_FURY, L.POWER_FURY})
	-- table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_PAIN, L.POWER_PAIN}) -- 삭제됨
elseif MyClass == "EVOKER" then
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA})
	table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.POWER_ESSENCE, L.POWER_ESSENCE})
end

table.insert(DDP_TRACKER_LIST, {HDH_TRACKER.TYPE.TOTEM, totemName})

local UNIT_TO_LABEL = {
	player = L.UNIT_PLAYER,
	target = L.UNIT_TARGET,
	focus = L.UNIT_FOCUS,
	pet = L.UNIT_PET,
	party1 = L.PARTY1,
	party2 = L.PARTY2,
	party3 = L.PARTY3,
	party4 = L.PARTY4,
	boss1 = L.BOSS1,
	boss2 = L.BOSS2,
	boss3 = L.BOSS3,
	boss4 = L.BOSS4,
	arena1 = L.ARENA1,
	arena2 = L.ARENA2,
	arena3 = L.ARENA3,
	arena4 = L.ARENA4,
	arena5 = L.ARENA5
}

local DDP_AURA_UNIT_LIST = {
	{'player', L.UNIT_PLAYER},
	{'target', L.UNIT_TARGET},
	{'focus', L.UNIT_FOCUS},
	{'pet', L.UNIT_PET},
	{'party1', L.PARTY1},
	{'party2', L.PARTY2},
	{'party3', L.PARTY3},
	{'party4', L.PARTY4},
	{'boss1', L.BOSS1},
	{'boss2', L.BOSS2},
	{'boss3', L.BOSS3},
	{'boss4', L.BOSS4},
	{'arena1', L.ARENA1},
	{'arena2', L.ARENA2},
	{'arena3', L.ARENA3},
	{'arena4', L.ARENA4},
	{'arena5', L.ARENA5},
}

local DDP_COOLDOWN_UNIT_LIST = {
	{'player', L.UNIT_PLAYER},
	-- {'pet', L.UNIT_PET}
}

local DDP_AURA_LIST = {
	{1, L.ONLY_MINE_AURA},
	{2, L.ALL_AURA},
	{3, L.ONLY_BOSS_AURA}
}

local DDP_FONT_CD_FORMAT_LIST = {
	{DB.TIME_TYPE_CEIL, L.TIME_TYPE_CEIL},
	{DB.TIME_TYPE_FLOOR, L.TIME_TYPE_FLOOR},
	{DB.TIME_TYPE_FLOAT, L.TIME_TYPE_FLOAT}
}

local DDP_FONT_CD_LOC_LIST = {
	{DB.FONT_LOCATION_HIDE, L.HIDE},
	{DB.FONT_LOCATION_TL, L.FONT_LOCATION_TL},
	{DB.FONT_LOCATION_BL, L.FONT_LOCATION_BL},
	{DB.FONT_LOCATION_TR, L.FONT_LOCATION_TR},
	{DB.FONT_LOCATION_BR, L.FONT_LOCATION_BR},
	{DB.FONT_LOCATION_C, L.FONT_LOCATION_C},
	{DB.FONT_LOCATION_OT, L.FONT_LOCATION_OT},
	{DB.FONT_LOCATION_OB, L.FONT_LOCATION_OB},
	{DB.FONT_LOCATION_OL, L.FONT_LOCATION_OL},
	{DB.FONT_LOCATION_OR, L.FONT_LOCATION_OR},
	{DB.FONT_LOCATION_BAR_L, L.FONT_LOCATION_BAR_L},
	{DB.FONT_LOCATION_BAR_C, L.FONT_LOCATION_BAR_C},	
	{DB.FONT_LOCATION_BAR_R, L.FONT_LOCATION_BAR_R},
}

local DDP_FONT_NAME_ALIGN_LIST = {
	{DB.NAME_ALIGN_LEFT, L.LEFT},
	{DB.NAME_ALIGN_RIGHT, L.RIGHT},
	{DB.NAME_ALIGN_CENTER, L.CENTER},
	{DB.NAME_ALIGN_TOP, L.TOP},
	{DB.NAME_ALIGN_BOTTOM, L.BOTTOM}
}

local DDP_ICON_COOLDOWN_LIST = {
	{DB.COOLDOWN_NONE, L.NONE},
	{DB.COOLDOWN_UP, L.UPWARD},
	{DB.COOLDOWN_DOWN, L.DOWNWARD},
	{DB.COOLDOWN_LEFT, L.TO_THE_LEFT},
	{DB.COOLDOWN_RIGHT, L.TO_THE_RIGHT},
	{DB.COOLDOWN_CIRCLE, L.CIRCLE}
}

local DDP_ICON_ORDER_LIST = {
	{DB.ORDERBY_REG, L.ORDERBY_REG},
	{DB.ORDERBY_CD_ASC, L.ORDERBY_CD_ASC},
	{DB.ORDERBY_CD_DESC, L.ORDERBY_CD_DESC},
	{DB.ORDERBY_CAST_ASC, L.ORDERBY_CAST_ASC},
	{DB.ORDERBY_CAST_DESC, L.ORDERBY_CAST_DESC}
}

local DDP_BAR_LOC_LIST = {
	{DB.BAR_LOCATION_T, L.TOP_AND_UPWARD},
	{DB.BAR_LOCATION_B, L.BOTTOM_AND_DOWNWARD},
	{DB.BAR_LOCATION_L, L.LEFT_AND_TORIGHT},
	{DB.BAR_LOCATION_R, L.RIGHT_AND_TOLEFT}
}

local DDP_CONFIG_MODE_LIST = {
	{DB.USE_GLOBAL_CONFIG, L.USE_GLOBAL_CONFIG},
	{DB.USE_SEVERAL_CONFIG, L.USE_SEVERAL_CONFIG}
}

local DDP_DISPLAY_MODE_LIST = {
	{DB.DISPLAY_ICON, L.USE_DISPLAY_ICON},
	{DB.DISPLAY_BAR, L.USE_DISPLAY_BAR},
	{DB.DISPLAY_ICON_AND_BAR, L.USE_DISPLAY_ICON_AND_BAR}
}

local DDP_AURA_FILTER_LIST = {
	{DB.AURA_FILTER_REG , L.REG_AURA},
	{DB.AURA_FILTER_ALL, L.ALL_AURA},
	{DB.AURA_FILTER_ONLY_BOSS, L.ONLY_BOSS_AURA},
}

local DDP_AURA_CASTER_LIST = {
	{DB.AURA_CASTER_ONLY_MINE, L.ONLY_MINE_AURA},
	{DB.AURA_CASTER_ALL , L.ALL_UNIT},
}

local DDP_BAR_TEXTURE_LIST = {}
do
	for idx, bar in ipairs(DB.BAR_TEXTURE) do
		DDP_BAR_TEXTURE_LIST[idx] = {idx, bar.name, bar.texture}
	end
end

local DDP_CONDITION_LIST = {
	{DB.CONDITION_GT, L.CONDITION_GT},
	{DB.CONDITION_LT, L.CONDITION_LT},
	{DB.CONDITION_EQ, L.CONDITION_EQ},
}

local SPEC_TEXTURE_FORMAT = "spec-thumbnail-%s";
local SPEC_FORMAT_STRINGS = {
	[62] = "mage-arcane",
	[63] = "mage-fire",
	[64] = "mage-frost",
	[65] = "paladin-holy",
	[66] = "paladin-protection",
	[70] = "paladin-retribution",
	[71] = "warrior-arms",
	[72] = "warrior-fury",
	[73] = "warrior-protection",
	[102] = "druid-balance",
	[103] = "druid-feral",
	[104] = "druid-guardian",
	[105] = "druid-restoration",
	[250] = "deathknight-blood",
	[251] = "deathknight-frost",
	[252] = "deathknight-unholy",
	[253] = "hunter-beastmastery",
	[254] = "hunter-marksmanship",
	[255] = "hunter-survival",
	[256] = "priest-discipline",
	[257] = "priest-holy",
	[258] = "priest-shadow",
	[259] = "rogue-assassination",
	[260] = "rogue-outlaw",
	[261] = "rogue-subtlety",
	[262] = "shaman-elemental",
	[263] = "shaman-enhancement",
	[264] = "shaman-restoration",
	[265] = "warlock-affliction",
	[266] = "warlock-demonology",
	[267] = "warlock-destruction",
	[268] = "monk-brewmaster",
	[269] = "monk-windwalker",
	[270] = "monk-mistweaver",
	[577] = "demonhunter-havoc",
	[581] = "demonhunter-vengeance",
	[1467] = "evoker-devastation",
	[1468] = "evoker-preservation",
}

local CHANGE_ICON_CB_LIST = {}
local ICON_PRESET_LIST = {
	"Interface/Icons/INV_Misc_Gem_Pearl_04",
	"Interface/Icons/INV_Misc_Gem_Pearl_05",
	"Interface/Icons/INV_Misc_Gem_Pearl_06",
	"Interface/Icons/Ability_Priest_SpiritOfTheRedeemer",
	"Interface/Icons/INV_Elemental_Primal_Life",
	"Interface/Icons/INV_Elemental_Primal_Mana",
	"Interface/Icons/INV_Elemental_Primal_Nether",
	"Interface/Icons/Spell_Shadow_SoulGem",
	"Interface/Icons/spell_Shaman_Measuredinsight",
	"Interface/Icons/INV_Jewelcrafting_DragonsEye03",
	"Interface/Icons/INV_Jewelcrafting_DragonsEye04",
	"Interface/Icons/INV_Jewelcrafting_DragonsEye05",
	"Interface/Icons/Spell_Nature_WispSplode",
	"Interface/Icons/Ability_Skyreach_Flash_Bang",
	"Interface/Icons/INV_Jewelcrafting_70_SabersEye",
	"Interface/Icons/inv_misc_enchantedpearlE",
	"Interface/Icons/Spell_Shadow_MindTwisting",
	"Interface/Icons/Spell_Holy_SealOfWrath",
	"Interface/Icons/Spell_AnimaRevendreth_Orb",
	"Interface/Icons/INV_chaos_orb",
	"Interface/Icons/Spell_Deathknight_UnholyPresence",
	"Interface/Icons/Spell_Deathknight_BloodPresence",
	"Interface/Icons/Spell_Deathknight_FrostPresence",
	"Interface/Icons/UI_AllianceIcon",
	"Interface/Icons/UI_HordeIcon",
	"Interface/Icons/Spell_Holy_SealOfValor",
	"Interface/Icons/Achievement_PVP_O_10",
	"Interface/Icons/Achievement_PVP_A_10",
	"Interface/Icons/Achievement_PVP_G_10",
	"Interface/Icons/Achievement_PVP_P_10",
	"Interface/Icons/INV_Alchemy_80_AlchemistStone02",
	"Interface/Icons/INV_Alchemist_81_EternalAlchemistStone",
	"Interface/Icons/INV_Alchemist_81_TidalAlchemistStone",
	"Interface/Icons/INV_Alchemy_80_AlchemistStone01",
	"Interface/Icons/INV_Misc_Orb_05",
	"Interface/Icons/INV_Misc_QirajiCrystal_05",
	"Interface/Icons/SPELL_AZERITE_ESSENCE08",
	"Interface/Icons/INV_RadientAzeriteHeart",
	"Interface/Icons/inv_misc_enchantedpearlF",
	"Interface/Icons/inv_misc_enchantedpearlD",
	"Interface/Icons/inv_misc_enchantedpearl",
	"Interface/Icons/inv_misc_enchantedpearlA",
	"Interface/Icons/inv_misc_enchantedpearlB",
	"Interface/Icons/ability_evoker_powernexus"
}

local BODY_TRACKER_NEW = 1
local BODY_TRACKER_EDIT = 2
local BODY_ELEMENTS = 3
local BODY_UI = 4
local BODY_DETAIL_GLOW = 5
local BODY_DETAIL_ETC = 6

local DETAIL_ETC_CHANGE_ICON = 1
local DETAIL_ETC_SPLIT_BAR = 2

---------------------------------------------------------
-- local functions
---------------------------------------------------------

local function GetMainFrame()
	return HDH_AT_ConfigFrame
end

local function GetTalentIdByTraits(searchTraitsId)
	local ret = {}
	local traitIds
	if not searchTraitsId then return nil end
	for i = 1, MAX_TALENT_TABS do
		talentId, _, _, _ = GetSpecializationInfo(i)
		if talentId == nil then
			break
		end
		if searchTraitsId == talentId then
			return talentId
		end
		traitIds = C_ClassTalents.GetConfigIDsBySpecID(talentId)
		for _, v in pairs(traitIds) do
			if v == searchTraitsId then
				return talentId
			end
		end
	end
	return nil
end

local function ChangeTab(list, idx)
	-- if idx == list.selectedIndex then
	-- 	return
	-- end
	if list.activateButton then
		list.activateButton:SetActivate(false)
		if list.activateButton.content then
			list.activateButton.content:Hide()
		end
	end
	list.selectedIndex = idx
	if idx then
		list.activateButton = list[list.selectedIndex]
		if list.activateButton then
			list.activateButton:SetActivate(true)
			if list.activateButton.content then
				list.activateButton.content:Show()
			end
		end
	end
end

local function GetTabIdx(tabs)
	return tabs.tabIdx
end

function HDH_AT_ConfigFrameMixin:ChangeBody(bodyType, trackerIndex, elemIndex, subType, ...)
	local args = ...
	local ui_list = self.UI_TAB 
	local bottom_list = self.BODY_TAB
	self.BODY_TAB.selectedIndex = self.BODY_TAB.selectedIndex or 1
	local bottomIndex = self.BODY_TAB.selectedIndex
	local tracker_list = self.F.TRACKER.list
	self.bodyType = bodyType or self.bodyType or BODY_TRACKER_NEW
	self.trackerIndex = trackerIndex or self.trackerIndex or 1
	if self.F.TRACKER.list 
			and self.trackerIndex 
			and self.F.TRACKER.list[self.trackerIndex] then
		self.trackerId = self.F.TRACKER.list[self.trackerIndex].id
	end
	self.elemIndex = elemIndex or self.elemIndex
	self.subType = subType or self.subType or 1

	if (self.bodyType == BODY_ELEMENTS or self.bodyType == BODY_UI) and self:GetTrackerListSize() < 1 then
		self.bodyType = BODY_TRACKER_NEW
	end

	if self.bodyType == BODY_TRACKER_NEW and trackerIndex and self:GetTrackerListSize() > 0 then
		if bottomIndex == 1 then
			self.bodyType = BODY_ELEMENTS
		else
			self.bodyType = BODY_UI
		end
	end

	if self.bodyType == BODY_TRACKER_EDIT and not bodyType then
		self.bodyType = BODY_ELEMENTS
	end

	if (self.bodyType == BODY_DETAIL_GLOW or self.bodyType == BODY_DETAIL_ETC) and trackerIndex then
		self.bodyType = BODY_ELEMENTS
	end

	if bodyType == BODY_ELEMENTS and tracker_list.selectedIndex == nil then
		self.bodyType = BODY_TRACKER_NEW
	end

	if self.bodyType == BODY_TRACKER_NEW then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		self.F.BODY.CONFIG_TRACKER:Show()
		self.F.BODY.CONFIG_UI:Hide()
		self.F.BODY.CONFIG_DETAIL:Hide()
		-- self.F.BODY.CONFIG_DETAIL.ETC:Hide()
		-- self.F.BODY.CONFIG_UI.DD_CONFIG_MODE:Disable()
		-- self:LoadTrackerList()
		self:LoadTrackerConfig()
		bottom_list[2]:Hide()
		ChangeTab(bottom_list, 1)
		ChangeTab(tracker_list, #tracker_list)

	elseif self.bodyType == BODY_TRACKER_EDIT then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		self.F.BODY.CONFIG_TRACKER:Show()
		self.F.BODY.CONFIG_UI:Hide()
		self.F.BODY.CONFIG_DETAIL:Hide()
		-- self.F.BODY.CONFIG_DETAIL.ETC:Hide()
		bottom_list[2]:Show()
		self:LoadTrackerConfig(self.trackerId)
		-- self.F.BODY.CONFIG_UI.DD_CONFIG_MODE:Eanble()
		ChangeTab(tracker_list, self.trackerIndex)
		ChangeTab(bottom_list, 1)

	elseif self.bodyType == BODY_ELEMENTS then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS:Show()
		self.F.BODY.CONFIG_TRACKER:Hide()
		self.F.BODY.CONFIG_UI:Hide()
		self.F.BODY.CONFIG_DETAIL:Hide()
		-- self.F.BODY.CONFIG_DETAIL.ETC:Hide()
		self:LoadTrackerElementConfig(self.trackerId)
		bottom_list[2]:Show()
		ChangeTab(bottom_list, 1)
		ChangeTab(tracker_list, self.trackerIndex)
		
	elseif self.bodyType == BODY_UI then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		self.F.BODY.CONFIG_TRACKER:Hide()
		self.F.BODY.CONFIG_UI:Show()
		self.F.BODY.CONFIG_DETAIL:Hide()
		-- self.F.BODY.CONFIG_DETAIL.ETC:Hide()
		-- self.F.BODY.CONFIG_UI.DD_CONFIG_MODE:Enable()
		self:LoadUIConfig(self.trackerId)
		self:UpdateAbleConfigs(self.F.BODY.CONFIG_UI.SW_DISPLAY_MODE:GetSelectedValue())
		ChangeTab(bottom_list, 2)
		ChangeTab(tracker_list, self.trackerIndex)
		ChangeTab(ui_list, self.subType)

	elseif self.bodyType == BODY_DETAIL_GLOW then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		self.F.BODY.CONFIG_TRACKER:Hide()
		self.F.BODY.CONFIG_UI:Hide()
		self.F.BODY.CONFIG_DETAIL:Show()
		self.F.BODY.CONFIG_DETAIL.GLOW:Show()
		self.F.BODY.CONFIG_DETAIL.ETC:Hide()
		self:LoadDetailFrame(BODY_DETAIL_GLOW, self.trackerId, self.elemIndex, args)

	elseif self.bodyType == BODY_DETAIL_ETC then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		self.F.BODY.CONFIG_TRACKER:Hide()
		self.F.BODY.CONFIG_UI:Hide()
		self.F.BODY.CONFIG_DETAIL:Show()
		self.F.BODY.CONFIG_DETAIL.GLOW:Hide()
		self.F.BODY.CONFIG_DETAIL.ETC:Show()
		self:LoadDetailFrame(BODY_DETAIL_ETC, self.trackerId, self.elemIndex, args)
		
		local trackerType = select(3, DB:GetTrackerInfo(self.trackerId))
		local CLASS = HDH_TRACKER.GetClass(trackerType)
		if trackerType == HDH_TRACKER.TYPE.STAGGER then
			self.DETAIL_ETC_TAB[1]:Disable()
			self.DETAIL_ETC_TAB[2]:Disable()
			ChangeTab(self.DETAIL_ETC_TAB, -1)
		elseif CLASS:GetClassName() == "HDH_POWER_TRACKER" then
			self.DETAIL_ETC_TAB[1]:Enable()
			self.DETAIL_ETC_TAB[2]:Enable()
			ChangeTab(self.DETAIL_ETC_TAB, self.subType)
		else
			self.DETAIL_ETC_TAB[1]:Enable()
			self.DETAIL_ETC_TAB[2]:Disable()
			ChangeTab(self.DETAIL_ETC_TAB, 1)
		end

	end
end

local function LoadDB(trackerId, comp)
	-- local trackerId = GetMainFrame():GetCurTrackerIdx()
	local dbValue = DB:GetTrackerValue(trackerId, comp.dbKey)
	if comp.type == COMP_TYPE.CHECK_BOX then
		comp:SetChecked(dbValue)
	elseif comp.type == COMP_TYPE.SLIDER then
		comp:UpdateValue(tonumber(dbValue))
	elseif comp.type == COMP_TYPE.COLOR_PICKER then
		comp:SetColorRGBA(unpack(dbValue or {1,1,1,1}))
	elseif comp.type == COMP_TYPE.DROPDOWN or comp.type == COMP_TYPE.SWITCH then
		comp:SetSelectedValue(dbValue)
	end
end

local function isHasTraits(id)
	for _, tracker in ipairs(HDH_AT_DB.tracker) do
		if tracker.trait and UTIL.HasValue(tracker.trait, id) then
			return true
		end
	end
	return false
end

local function DrawLine(frame, x, y, total, point1, point2)
	local i = 1;
	local size = math.abs(x) > math.abs(y) and x or y;
	size = math.abs(size);
	local t;
	while (total / 2) > (size * i) do
		t = frame:CreateTexture(nil, "BACKGROUND");
		t:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg.blp");
		t:SetVertexColor(0,0,0, 0.45);
		if i % 5 == 0 then
			t:SetSize(3,3);
		else
			t:SetSize(1,1);
		end
		t:SetPoint(point1,UIParent,point1, x*i, y*i);
		t:SetPoint(point2,UIParent,point2,0,0);
		i = i+1;
	end
end

local function ShowGrid(frame, show)
	local size = GRID_SIZE;
	if show then 
		if not frame.GridFrame then
			frame.GridFrame = CreateFrame("Frame",nil,UIParent);
			local t;
			local displayX, displayY = UIParent:GetSize();
			
			DrawLine(frame.GridFrame,size,0,displayX,"TOP","BOTTOM");
			DrawLine(frame.GridFrame,-size,0,displayX, "TOP","BOTTOM");
			DrawLine(frame.GridFrame,0,size,displayY,"LEFT","RIGHT");
			DrawLine(frame.GridFrame,0,-size,displayY,"LEFT","RIGHT");
			
			t = frame.GridFrame:CreateTexture(nil, "BACKGROUND");
			t:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg.blp");
			t:SetVertexColor(1,0,0, 0.5);
			t:SetSize(3,3);
			t:SetPoint("LEFT",UIParent,"LEFT",0,0);
			t:SetPoint("RIGHT",UIParent,"RIGHT",0,0);
			
			t = frame.GridFrame:CreateTexture(nil, "BACKGROUND");
			t:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg.blp");
			t:SetVertexColor(1,0,0, 0.5);
			t:SetSize(3,3);
			t:SetPoint("TOP",UIParent,"TOP",0,0);
			t:SetPoint("BOTTOM",UIParent,"BOTTOM",0,0);
		end
		frame.GridFrame:Show();
	else
		if frame.GridFrame then frame.GridFrame:Hide(); end
	end
end

---------------------------------------------------------
-- OnScript
---------------------------------------------------------

local function HDH_AT_OnChangedSlider(self, value)
	local trackerId = GetMainFrame():GetCurTrackerId()
	if value ~= nil and self.dbKey ~= nil then
		DB:SetTrackerValue(trackerId, self.dbKey, value)	
		HDH_TRACKER.UpdateSettings(trackerId)
	end
end

local function HDH_AT_OnSeletedColor(self, r, g, b, a)
	local trackerId = GetMainFrame():GetCurTrackerId()
	
	if r ~= nil and g ~=nil and b ~= nil and a ~=nil and self.dbKey ~= nil then
		DB:SetTrackerValue(trackerId, self.dbKey, {r, g, b, a})		
		HDH_TRACKER.UpdateSettings(trackerId)
	end
end

function HDH_AT_UI_OnCheck(self)
	local F = GetMainFrame().F
	local value = self:GetChecked()
	local trackerId = GetMainFrame():GetCurTrackerId()

	if value ~= nil and self.dbKey ~= nil then
		DB:SetTrackerValue(trackerId, self.dbKey, value)
		HDH_TRACKER.UpdateSettings(trackerId)
	end
	
	if self == F.BODY.CONFIG_UI.CB_MOVE then
		HDH_TRACKER.ENABLE_MOVE = value
		HDH_TRACKER.SetMoveAll(value)
		ShowGrid(GetMainFrame(), value)
	
	elseif self == F.BODY.CONFIG_UI.CB_DISPLAY_WHEN_NONCOMBAT then
		HDH_TRACKER.InitVaribles(DB:HasUI(trackerId) and trackerId)

	elseif UTIL.HasValue(CHANGE_ICON_CB_LIST, self) then
		for _, cb in pairs(CHANGE_ICON_CB_LIST) do
			cb:SetChecked(cb == self)
		end
		local trackerId = F.BODY.CONFIG_DETAIL.trackerId
		local elemIdx = F.BODY.CONFIG_DETAIL.elemIdx
		local texture = self.Icon:GetTexture()
		local searchChecked = F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON:GetChecked()
		local key = nil
		local isItem = false

		if self == F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON and searchChecked then
			key = F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON.Icon.key
			isItem = F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON.Icon.isItem
		end
		if (searchChecked and not key) then
			GetMainFrame().Dialog:AlertShow(L.PLASE_SEARCH_ICON) return 
		end

		DB:SetTrackerElementImage(trackerId, elemIdx, texture, key, isItem)
		HDH_TRACKER.InitVaribles(trackerId)

	elseif self == F.BODY.CONFIG_DETAIL.GLOW.CD1 or 
		   self == F.BODY.CONFIG_DETAIL.GLOW.CD2 or
		   self == F.BODY.CONFIG_DETAIL.GLOW.CD3 or
		   self == F.BODY.CONFIG_DETAIL.GLOW.CD4 then
		for _, cd in ipairs(F.BODY.CONFIG_DETAIL.GLOW.CD_LIST) do
			if cd[1] ~= self then
				cd[1]:SetChecked(false)
			end
		end
		
	end
end

local function HDH_AT_OP_SwapRowData(rowList, i1, i2)
	local tmp;
	tmp = rowList[i1];
	rowList[i1] = rowList[i2];
	rowList[i2] = tmp;
	
	tmp = rowList[i1].index;
	rowList[i1].index = rowList[i2].index;
	rowList[i2].index = tmp;

	tmp = rowList[i1].id;
	rowList[i1].id = rowList[i2].id;
	rowList[i2].id = tmp;
end

local function HDH_AT_OP_OnDragRow(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed;
	if self.elapsed < 0.2 then return end
	self.elapsed = 0;
	-- local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	-- local name = db.name
	-- local aura = db.spell_list
	local main = GetMainFrame()
	local x, y = self:GetCenter();
	local selfIdx = self.index;
	local rowFrame;
	local rowList = self:GetParent().list
	local trackerId = main:GetCurTrackerId()
	local left, bottom, w, h
	local len = self.mode and #rowList-1 or #rowList
	for i =1, len do
		rowFrame = rowList[i];
		if i ~= selfIdx and rowFrame.mode ~= HDH_AT_AuraRowMixin.MODE.EMPTY then 
			left, bottom, w, h = rowFrame:GetBoundsRect();
			if x >= left and x <= (left+w) and y >= bottom and y<=(bottom+h) then
				if i > selfIdx then 
					for j = selfIdx+1, i do
						rowList[j]:SetPoint("TOPLEFT", 0, -self:GetHeight()*(j-2));
						if rowFrame:GetParent() == main.F.BODY.CONFIG_TRACKER_ELEMENTS.CONTENTS then
							DB:SwapTrackerElement(trackerId, j-1, j)
						else
							DB:SwapTracker(rowList[j-1].id, rowList[j].id)
						end
						HDH_AT_OP_SwapRowData(rowList, j-1, j)
					end	
				else
					for j = selfIdx-1, i, -1 do
						rowList[j]:SetPoint("TOPLEFT", 0, -self:GetHeight()*(j));
						if rowFrame:GetParent() == main.F.BODY.CONFIG_TRACKER_ELEMENTS.CONTENTS then
							DB:SwapTrackerElement(trackerId, j+1, j)
						else
							DB:SwapTracker(rowList[j+1].id, rowList[j].id)
						end
						HDH_AT_OP_SwapRowData(rowList, j+1, j)
					end
				end
				break;
			end
		end
	end
end

local function HDH_AT_OP_OnDragStartRow(self)
	if self.mode ~= HDH_AT_AuraRowMixin.MODE.EMPTY then 
		self:StartMoving()
		self:SetToplevel(true);
		self:SetScript('OnUpdate', HDH_AT_OP_OnDragRow)
	end
end

local function HDH_AT_OP_OnDragStopRow(self)
	-- local idx = GetTrackerIndex()
	self:StopMovingOrSizing();
	self:SetScript('OnUpdate', nil);
	-- HDH_LoadAuraListFrame(idx);
	-- HDH_AT_OP_GetTracker(idx):InitIcons();
	local main = GetMainFrame()
	local trackerId = GetMainFrame():GetCurTrackerId()
	if self:GetParent() == main.F.BODY.CONFIG_TRACKER_ELEMENTS.CONTENTS 
			and self.mode 
			and self.mode ~= HDH_AT_AuraRowMixin.MODE.EMPTY then 
		main:LoadTrackerElementConfig(trackerId)
		HDH_TRACKER.InitIcons(trackerId)
	else
		main:LoadTrackerList(main:GetCurTraits())
		main:ChangeBody(nil, self.index)
		-- main:SetCurTrackerIdx(self.idx)
		HDH_TRACKER.InitVaribles()
		if main.F.BODY.CONFIG_TRACKER:IsShown() then
			main:LoadTrackerConfig(main:GetCurTrackerId())
		end
	end
end

local function HDH_AT_OnEventTrackerElement(self, elemIdx)
	local name = self:GetName()
	local main = GetMainFrame()
	local F = main.F
	local trackerId = main:GetCurTrackerId()

	if string.find(name, "ButtonSet") then
		main:ChangeBody(BODY_DETAIL_ETC, nil, elemIdx, nil, self)

	elseif string.find(name, "CheckButtonAlways") then
		local value = self:GetChecked()
		DB:UpdateTrackerElementAlways(trackerId, elemIdx, value)
		HDH_TRACKER.InitIcons(trackerId)

	elseif string.find(name, "CheckButtonGlow") then
		local value = self:GetChecked()
		main:ChangeBody(BODY_DETAIL_GLOW, nil, elemIdx, nil, self)

	elseif string.find(name, "CheckButtonValue") then
		local value = self:GetChecked()
		DB:UpdateTrackerElementValue(trackerId, elemIdx, value)
		HDH_TRACKER.InitIcons(trackerId)

	elseif string.find(name, "ButtonDel") then
		main:DeleteTrackerElement(self:GetParent(), trackerId, elemIdx)
		self:GetParent():ChangeReadMode()

	elseif string.find(name, "ButtonAdd") or string.find(name, "EditBoxID") then
		main:AddTrackerElement(self:GetParent(), trackerId, elemIdx)
		self:GetParent():ChangeReadMode()

	elseif string.find(name, "ButtonCancel") then
		self:GetParent():ChangeReadMode()
	end
end

local function HDH_AT_OnSelected_Dropdown(self, itemFrame, idx, value)
	local main = GetMainFrame()
	local F = GetMainFrame().F

	if self == F.DD_TRANSIT then
		main:LoadTrackerList(value)
		main:ChangeBody(nil, 1)

	elseif self == F.BODY.CONFIG_UI.SW_CONFIG_MODE then
		if main:GetCurTrackerId() then
			if value == DB.USE_SEVERAL_CONFIG then
				main.Dialog:AlertShow(L.ALERT_CONFIRM_CHANGE_TO_ONLY_THIS_TRACKER_CONFIGURATION, main.Dialog.DLG_TYPE.YES_NO,
					function()
						local main = GetMainFrame()
						local trackerId = main:GetCurTrackerId()
						DB:CopyGlobelToTracker(trackerId)
						main:LoadUIConfig(trackerId)
						main:UpdateAbleConfigs(main.F.BODY.CONFIG_UI.SW_DISPLAY_MODE:GetSelectedValue())
						HDH_TRACKER.InitVaribles(trackerId)
					end,
					function()
						F.BODY.CONFIG_UI.SW_CONFIG_MODE:SetSelectedIndex(DB.USE_GLOBAL_CONFIG)
					end
				)
			else
				main.Dialog:AlertShow(L.ALERT_CONFIRM_CHANGE_TO_GLOBAL_CONFIGURATION, main.Dialog.DLG_TYPE.YES_NO,
					function()
						local main = GetMainFrame()
						local trackerId = main:GetCurTrackerId()
						DB:ClearTracker(trackerId)
						main:LoadUIConfig(trackerId)
						main:UpdateAbleConfigs(main.F.BODY.CONFIG_UI.SW_DISPLAY_MODE:GetSelectedValue())
						HDH_TRACKER.InitVaribles(trackerId)
					end,
					function()
						F.BODY.CONFIG_UI.SW_CONFIG_MODE:SetSelectedIndex(DB.USE_SEVERAL_CONFIG)
					end
				)
			end
		end

	elseif self == F.BODY.CONFIG_UI.SW_DISPLAY_MODE then
		main:UpdateAbleConfigs(value)
		HDH_TRACKER.UpdateSettings(main:GetCurTrackerId())

	elseif self == F.DD_TRACKER_TRANSIT then
		main:UpdateTraitsSelector(idx)

	elseif self == F.DD_TRACKER_TYPE then
		F.DD_TRACKER_UNIT:SelectClear()
		F.DD_TRACKER_AURA_CASTER:SelectClear()
		F.DD_TRACKER_AURA_FILTER:SelectClear()

		F.DD_TRACKER_AURA_CASTER:Enable()
		F.DD_TRACKER_AURA_FILTER:Enable()
		F.DD_TRACKER_UNIT:Enable()

		if value == HDH_TRACKER.TYPE.BUFF or value == HDH_TRACKER.TYPE.DEBUFF then
			
		elseif value == HDH_TRACKER.TYPE.TOTEM then
			F.DD_TRACKER_UNIT:Disable()
			F.DD_TRACKER_AURA_CASTER:Disable()
			F.DD_TRACKER_AURA_FILTER:Enable()
		else
			F.DD_TRACKER_UNIT:Disable()
			F.DD_TRACKER_AURA_CASTER:Disable()
			F.DD_TRACKER_AURA_FILTER:Disable()
		end
	end

	if self.dbKey then
		local trackerId = GetMainFrame():GetCurTrackerId()
		local seletedTraitsValue = self:GetSelectedValue()
		if seletedTraitsValue ~= nil and  self.dbKey ~= nil then
			DB:SetTrackerValue(trackerId, self.dbKey, seletedTraitsValue)
			HDH_TRACKER.UpdateSettings(trackerId)
		end
	end
end

local function HDH_AT_OnChangeTabUI(self)
	if self:GetParent() == GetMainFrame().F.BODY.CONFIG_UI.MEMU then
		GetMainFrame():ChangeBody(nil, nil, nil, self.index)
	elseif self:GetParent() == GetMainFrame().F.BODY.CONFIG_DETAIL.ETC.MENU then
		GetMainFrame():ChangeBody(nil, nil, nil, self.index)
	end
	
end

local function HDH_AT_OnClick_TrackerConfigButton(self)
	GetMainFrame():ChangeBody(BODY_TRACKER_EDIT, self.index, nil, nil)
end 

local function HDH_AT_OnClick_TrackerTapButton(self, button)
	if self == GetMainFrame().F.BTN_SHOW_ADD_TRACKER_CONFIG then
		GetMainFrame():ChangeBody(BODY_TRACKER_NEW, nil, nil, nil)
	else
		if button == 'LeftButton' then
			GetMainFrame():ChangeBody(nil, self.index, nil, nil)
		else
			HDH_AT_OnClick_TrackerConfigButton(self)
		end
	end
end

function HDH_AT_OnClick_Button(self, button)
	local main = GetMainFrame()
	local F = main.F

	if self == F.BODY.CONFIG_TRACKER.BTN_SAVE then
		local info = nil
		local name = F.ED_TRACKER_NAME:GetText()
		local type = F.DD_TRACKER_TYPE:GetSelectedValue()
		local unit = F.DD_TRACKER_UNIT:GetSelectedValue()
		local traitList = F.DD_TRACKER_TRANSIT:GetSelectedValue()
		local caster = F.DD_TRACKER_AURA_CASTER:GetSelectedValue()
		local filter = F.DD_TRACKER_AURA_FILTER:GetSelectedValue()
		local trackerObj
		local id

		name = UTIL.Trim(name)
		if not name or string.len(name) <= 0 then
			main.Dialog:AlertShow(L.PLASE_INPUT_NAME) return 
		end
		if not type then
			main.Dialog:AlertShow(L.PLASE_SELECT_TYPE) return 
		end

		if F.DD_TRACKER_UNIT:IsEnabled() and not unit then
			main.Dialog:AlertShow(L.PLASE_SELECT_UNIT) return 
		end

		if F.DD_TRACKER_AURA_FILTER:IsEnabled() and not filter then
			main.Dialog:AlertShow(L.PLASE_SELECT_AURA_FILTER) return 
		end

		if F.DD_TRACKER_AURA_CASTER:IsEnabled() and not caster then
			main.Dialog:AlertShow(L.PLASE_SELECT_AURA_CASTER) return 
		end

		if not traitList or #traitList == 0 then
			main.Dialog:AlertShow(L.PLASE_SELECT_TRAIT) return 
		end

		local perType
		if F.BODY.CONFIG_TRACKER.is_creation then
			id = DB:InsertTracker(name, type, unit, filter, caster, traitList)
			trackerObj = HDH_TRACKER.New(id, name, type, unit)
		else
			id = main:GetCurTrackerId()
			perType = select(3, DB:GetTrackerInfo(id))
			if perType ~= type then
				perType = nil
			end
			DB:UpdateTracker(id, name, type, unit, filter, caster, traitList)
			trackerObj = HDH_TRACKER.Get(id)
			if trackerObj then
				trackerObj:Modify(name, type, unit)
				trackerObj:InitIcons()
			else
				trackerObj = HDH_TRACKER.New(id, name, type, unit)
			end
		end

		local className = trackerObj:GetClassName()
		local curTraits = main:GetCurTraits()
		local index = main:GetTrackerIndex(id)
		main:LoadTraits()
		main:LoadTrackerList(curTraits)
		if not index then
			main:LoadTrackerList()
			index = main:GetTrackerIndex(id)
			F.DD_TRANSIT:SetSelectedIndex(1)
		else
			F.DD_TRANSIT:SetSelectedValue(curTraits)
		end
		main:ChangeBody(BODY_ELEMENTS, index)
		 
		if not perType and (className == "HDH_COMBO_POINT_TRACKER" or className == "HDH_ESSENCE_TRACKER" or className == "HDH_DK_RUNE_TRACKER") then
			if not main.DIALOG_SELECT_DISPLAY_TYPE then
				main.DIALOG_SELECT_DISPLAY_TYPE = CreateFrame("Frame", main:GetName().."DialogSelectDisplayType", main, "HDH_AT_DialogSelectDisplayTypeTemplate")
				main.DIALOG_SELECT_DISPLAY_TYPE.Button:SetScript("OnClick", function(self)
					local trackerId = self:GetParent().trackerId
					if self:GetParent().CheckButton1:GetChecked() then
						DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON)
					else
						DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_BAR)
					end
					
					HDH_TRACKER.InitVaribles()
					self:GetParent():Hide()
				end)

				main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton1:SetScript("OnClick", function(self) 
					self:GetParent().CheckButton2:SetChecked(false)
				end)

				main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton2:SetScript("OnClick", function(self) 
					self:GetParent().CheckButton1:SetChecked(false)
				end)
			end
			main.DIALOG_SELECT_DISPLAY_TYPE.trackerId = id
			local color = trackerObj.POWER_INFO[type].color
			local texture = trackerObj.POWER_INFO[type].texture
			for i = 1, 5 do
				_G[ (main.DIALOG_SELECT_DISPLAY_TYPE:GetName() .. "Texture".. i) ]:SetTexture(texture)
				if i >= 3 then
					_G[ (main.DIALOG_SELECT_DISPLAY_TYPE:GetName() .. "TextureBorder".. i) ]:SetVertexColor(unpack(color))
					_G[ (main.DIALOG_SELECT_DISPLAY_TYPE:GetName() .. "Bar".. i) ]:SetVertexColor(unpack(color))
				end
			end
			main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton1:SetChecked(true)
			main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton2:SetChecked(false)
			main.DIALOG_SELECT_DISPLAY_TYPE:Show()
		else
			HDH_TRACKER.InitVaribles()
		end
		
	elseif self == F.BODY.CONFIG_TRACKER.BTN_DELETE then
		local id = main:GetCurTrackerId()
		local name = select(2, DB:GetTrackerInfo(id))
		main.Dialog:AlertShow(L.DO_YOU_WANT_TO_DELETE_THIS_ITEM:format(name), main.Dialog.DLG_TYPE.YES_NO, function() 
			local main = GetMainFrame()
			local id = main:GetCurTrackerId()
			local trait = main:GetCurTraits()
			main.F.BODY.CONFIG_TRACKER:Hide()
			DB:DeleteTracker(id)
			-- HDH_TRACKER.Delete(idx)
			-- HDH_TRACKER.Reload(idx)
			main:UpdateFrame()
			-- main:LoadTrackerList(trait)
			main:ChangeBody(BODY_TRACKER_NEW)
			HDH_TRACKER.InitVaribles()
		end)

	elseif self == F.BODY.CONFIG_TRACKER.BTN_CANCEL then
		F.BODY.CONFIG_TRACKER:Hide()
		F.BODY.CONFIG_TRACKER_ELEMENTS:Show()

	elseif self == F.BODY.CONFIG_TRACKER.BTN_COPY then
		local id = main:GetCurTrackerId()
		local name = select(2, DB:GetTrackerInfo(id))
		main.Dialog:AlertShow(L.ALRET_CONFIRM_COPY_TRACKER:format(name), main.Dialog.DLG_TYPE.EDIT, function() 
			local copyName =  main.Dialog.EditBox:GetText()
			copyName = UTIL.Trim(copyName)
			if copyName and string.len(copyName) > 0 then
				local newId = DB:CopyTracker(id, copyName)

				F.BODY.CONFIG_TRACKER:Hide()
				GetMainFrame():UpdateFrame()
				-- GetMainFrame():ChangeTrackerTabByTrackerId(newId)
				HDH_TRACKER.InitVaribles()
				main.Dialog:AlertShow(L.ALRET_CONFIRM_COPY:format(copyName))
			else
				main.Dialog:AlertShow(L.PLASE_INPUT_NAME)

			end
		end)

	elseif self == F.BODY.CONFIG_UI.BTN_RESET then
		main.Dialog:AlertShow(L.ALERT_RESET, main.Dialog.DLG_TYPE.YES_NO, function() 
			DB:Reset()
			ReloadUI()
		end)

	elseif self == F.BTN_PREV_NEXT.BtnPrev then
		local value = tonumber(F.BTN_PREV_NEXT.Value:GetText())
		local newValue = max(value - 1, 1)
		local idx = main:GetCurTrackerIdx()
		if value ~= newValue then
			F.BTN_PREV_NEXT.Value:SetText(newValue)
			DB:SwapTracker(value, newValue)
			main:LoadTrackerList(main:GetCurTraits())
			main:ChangeTrackerTabByTrackerId(newValue)
		end

	elseif self == F.BTN_PREV_NEXT.BtnNext then
		local maxValue = #DB:GetTrackerIds()
		local value = tonumber(F.BTN_PREV_NEXT.Value:GetText())
		local newValue = min(value + 1, maxValue)
		local idx = main:GetCurTrackerIdx()
		if newValue ~= value then
			F.BTN_PREV_NEXT.Value:SetText(newValue)
			DB:SwapTracker(value, newValue)
			main:LoadTrackerList(main:GetCurTraits())
			main:ChangeTrackerTabByTrackerId(newValue)
		end

	elseif self == F.BODY.CONFIG_DETAIL.BTN_SAVE then
		local trackerId = F.BODY.CONFIG_DETAIL.trackerId
		local elemIdx = F.BODY.CONFIG_DETAIL.elemIdx
		local mode = F.BODY.CONFIG_DETAIL.mode

		if mode == BODY_DETAIL_GLOW then
			local checkbutton = F.BODY.CONFIG_DETAIL.GLOW.checkbutton
			local checkedIdx, condition, glowValue
			for idx, cd in ipairs(F.BODY.CONFIG_DETAIL.GLOW.CD_LIST) do
				if cd[1]:GetChecked() then
					checkedIdx = idx
					condition = cd[2] and cd[2]:GetSelectedValue()
					glowValue = cd[3] and UTIL.Trim(cd[3]:GetText())
				end
			end
			if checkedIdx then
				if checkedIdx > 1 and (not glowValue or string.len(glowValue) == 0) then
					main.Dialog:AlertShow(L.ALERT_PLASE_INPUT_GLOW_VALUE)
					return
				end
				DB:UpdateTrackerElementGlow(trackerId, elemIdx, checkedIdx, condition, glowValue)
			else
				DB:UpdateTrackerElementGlow(trackerId, elemIdx, DB.GLOW_CONDITION_NONE, nil, nil)
			end
			HDH_TRACKER.InitIcons(trackerId)
			if main:GetCurTrackerId() == trackerId then
				main:LoadTrackerElementConfig(trackerId, elemIdx, elemIdx)
			end
		end

		main.Dialog:AlertShow(L.SAVED_CONFIG)
		-- main:ChangeBody(BODY_ELEMENTS)

	elseif self == F.BODY.CONFIG_DETAIL.BTN_CLOSE then
		main:ChangeBody(BODY_ELEMENTS)

	elseif self == F.BODY.CONFIG_UI.BTN_EXPORT_STRING then
		local data = WeakAuraLib_TableToString(HDH_AT_DB, true)
		F.BODY.CONFIG_UI.ED_EXPORT_STRING:SetText(data)

		main.Dialog:AlertShow(L.CREATE_SHARE_STRING)

	elseif self == F.BODY.CONFIG_UI.BTN_IMPORT_STRING then
		local data = F.BODY.CONFIG_UI.ED_IMPORT_STRING:GetText()
		data = WeakAuraLib_StringToTable(data, true)
		
		if not data then
			main.Dialog:AlertShow(L.SHARE_STRING_IS_WRONG)
			return 
		end

		if not DB:VaildationProfile(data) then
			main.Dialog:AlertShow(L.SHARE_STRING_IS_WRONG)
			return 
		end

		main.Dialog:AlertShow(L.REPLACE_PROFILE, main.Dialog.DLG_TYPE.YES_NO, function() 	
			local data = F.BODY.CONFIG_UI.ED_IMPORT_STRING:GetText()
			HDH_AT_DB = WeakAuraLib_StringToTable(data, true)
			ReloadUI()
		end)

	elseif self == F.BODY.CONFIG_DETAIL.ETC.CUSTOM_BTN_SEARCH then
		local trackerId = F.BODY.CONFIG_DETAIL.trackerId
		local elemIdx = F.BODY.CONFIG_DETAIL.elemIdx
		local spell = F.BODY.CONFIG_DETAIL.ETC.CUSTOM_EB_SPELL:GetText()
		local isItem = F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CB_IS_ITEM:GetChecked()
		spell = UTIL.Trim(spell)

		if not spell or string.len(spell) == 0 then
			main.Dialog:AlertShow(L.PLASE_INPUT_ID) return 
		end
		local name, id, texture = UTIL.GetInfo(spell, isItem)
		if not id then
			main.Dialog:AlertShow(L.NOT_FOUND_ID:format(spell)) return 
		end
		F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON.Icon:SetTexture(texture)
		F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON.Icon.key = spell
		F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON.Icon.isItem = isItem

		if F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON:GetChecked() and spell then
			DB:SetTrackerElementImage(trackerId, elemIdx, texture, key, isItem)
			HDH_TRACKER.InitVaribles(trackerId)
		end
	
	elseif UTIL.HasValue(F.BODY.CONFIG_DETAIL.ETC.SPLIT_BAR.ED_LIST, self:GetParent()) then
		local index = self:GetParent().index
		local trackerId = F.BODY.CONFIG_DETAIL.trackerId
		local elemIdx = F.BODY.CONFIG_DETAIL.elemIdx
		local values = DB:GetTrackerElementSplitValues(trackerId, elemIdx) or {}
		local minValue, maxValue = F.BODY.CONFIG_DETAIL.ETC.SPLIT_BAR:GetMinMaxValues()

		if maxValue < 10 then
			main.Dialog:AlertShow(L.NEED_TO_MAXIMUM_VALUE)
			return 
		end

		if self:GetParent().ButtonAdd == self then
			local v = F.BODY.CONFIG_DETAIL.ETC.SPLIT_BAR.ED_LIST[index]:GetValue()
			if v == 0 then
				main.Dialog:AlertShow(L.PLASE_INPUT_VALUE)
				return
			end
			if minValue < v and maxValue > v then
				values[index] = v
				table.sort(values)

				if (maxValue - v) < 10 or (v - minValue) < 10 then
					main.Dialog:AlertShow(L.NEED_TO_INTER_VALUE)
					return 
				end
				for i = 1, #values-1 do
					if (values[i+1] - values[i] < 10 ) then
						main.Dialog:AlertShow(L.NEED_TO_INTER_VALUE)
						return 
					end
				end
			else
				main.Dialog:AlertShow(L.PLASE_INPUT_MINMAX_VALUE)
				return
			end
		elseif self:GetParent().ButtonDel == self then
			table.remove(values, index)
		end

		DB:SetTrackerElementSplitValues(trackerId, elemIdx, values)
		main:LoadDetailFrame(BODY_DETAIL_ETC, trackerId, elemIdx)
		HDH_TRACKER.InitVaribles(trackerId)
	end
	
end

function HDH_AT_OnClick_ButtomTapButton(self)
	if self.index == 1 then
		GetMainFrame():ChangeBody(BODY_ELEMENTS, nil, nil, nil)
	else
		GetMainFrame():ChangeBody(BODY_UI, nil, nil, nil)
	end
	
end

function HDH_AT_OnClick_TrackerButton(self)
    -- local list = self:GetParent().tabList
    -- local idx = self:GetID() or 0
    -- HDH_AT_OP_ChangeTapState(list, idx)
end

function HDH_AT_OnCancelColorPicker()
	local r,g,b,a = unpack(ColorPickerFrame.previousValues);
	a = (ColorPickerFrame.hasOpacity and a) or nil;
	-- UpdateFrameDB_CP(ColorPickerFrame.colorButton, r,g,b,a);
	-- UpdateFrameDB_CP(ColorPickerFrame.colorButton);
	-- ColorPickerFrame.colorButton = nil;
	-- if HDH_AT_OP_IsEachSetting() then
	-- 	local tracker = HDH_AT_OP_GetTracker(HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()))
	-- 	if not tracker then return end
	-- 	tracker:UpdateSetting()
	-- else
	-- 	HDH_TRACKER.UpdateSettingAll()
	-- end
end

---------------------------------------------------------
-- HDH_AT_ConfigFrame
---------------------------------------------------------

function HDH_AT_ConfigFrameMixin:AddTalentButton(name, type, unit, idx)

end

function HDH_AT_ConfigFrameMixin:GetTraits(talentId)
	local ret = {}
	talentId = talentId or GetSpecialization() --ClassTalentFrame.TalentsTab.LoadoutDropDown:GetSelectionID()
	local ids = C_ClassTalents.GetConfigIDsBySpecID(talentId)

	for i, v in pairs(ids) do
		id = v
		name = C_Traits.GetConfigInfo(v).name
		ret[i] = {id, name}
	end
	return ret
end

function HDH_AT_ConfigFrameMixin:GetTalentList(bigImage)
	local ret = {}
	bigImage = bigImage or false
	for i = 1, MAX_TALENT_TABS do
        id, name, desc, icon = GetSpecializationInfo(i)
		if id == nil then
			break
		end
		if bigImage then
			icon = SPEC_TEXTURE_FORMAT:format(SPEC_FORMAT_STRINGS[id])
		end
		ret[i] = {id, name, icon}
	end
	return ret
end

function HDH_AT_ConfigFrameMixin:GetCurTraits()
	return self.F.DD_TRANSIT:GetSelectedValue()
end

function HDH_AT_ConfigFrameMixin:GetCurTrackerId()
	return self.trackerId 
end

function HDH_AT_ConfigFrameMixin:DeleteTrackerElement(elem, trackerId, elemIdx)
	-- rowIdx = select(1, elem:Get())
	DB:DeleteTrackerElement(trackerId, elemIdx)
	local t = HDH_TRACKER.Get(trackerId)
	if t then
		t:InitIcons()
	end
	self:LoadTrackerElementConfig(trackerId, elemIdx)
end

function HDH_AT_ConfigFrameMixin:AddTrackerElement(elem, trackerId, elemIdx)
	local rowIdx, key, id, name, texture, isAlways, isGlow, isValue, isItem = elem:Get()

	key = UTIL.Trim(key)
	if not key or string.len(key) == 0 then
		self.Dialog:AlertShow(L.PLASE_INPUT_ID)
		return 
	end
	
	if tonumber(key) and string.len(key) > 7  then
		self.Dialog:AlertShow(L.NOT_FOUND_ID:format(tostring(key)))
		return 
	end
	
	name, id, texture, isItem = UTIL.GetInfo(key, isItem)

	if not id then
		self.Dialog:AlertShow(L.NOT_FOUND_ID:format(tostring(key)))
		return 
	end
	DB:SetTrackerElement(trackerId, elemIdx, key, id, name, texture, isAlways, isValue, isItem)
	self:LoadTrackerElementConfig(trackerId, elemIdx)

	trackerObj = HDH_TRACKER.Get(trackerId)
	if trackerObj then
		trackerObj:InitIcons()
	end
end

function HDH_AT_ConfigFrameMixin:LoadTraits()
	local ddm = self.F.DD_TRACKER_TRANSIT
	local itemValues = {}
	local itemTemplates = {}
	local id, name, icon
	local itemFrame, isTalent, check

	local F = self.F
	local ids = DB:GetTrackerIds()
	local traitList = {}
	local talentID, talentName, traitName, icon
	local cacheTraits = {}
	local unusedTracker = 0
	local traits
	local trackerId
	-- Tracker 목록 생성 및 트랜짓이 없는 않는 트래커 확인
	traitList[#traitList+1] = {DDM_TRACKER_ALL, L.ALL_LIST, nil}
	for _, id in ipairs(ids) do
		traits = select(7, DB:GetTrackerInfo(id))
		if #traits > 0 then
			for idx, traitID in ipairs(traits) do
				if not cacheTraits[traitID] then  
					talentID = GetTalentIdByTraits(traitID)
					if talentID then
						cacheTraits[traitID] = true
						talentName = select(2, GetSpecializationInfoByID(talentID))
						traitName = UTIL.GetTraitsName(traitID)
						icon = SPEC_TEXTURE_FORMAT:format(SPEC_FORMAT_STRINGS[talentID])
						traitList[#traitList+1] = {traitID, STR_TRANSIT_FORMAT:format(traitName, talentName), icon}
					else
						
						DB:ClearTraits(id)
						unusedTracker = unusedTracker + 1
					end
				end
			end
		else
			unusedTracker = unusedTracker + 1
		end
	end

	if unusedTracker > 0 then
		traitList[#traitList+1] = {DDM_TRACKER_UNUSED, L.UNUSED_LIST}
		self.Dialog:AlertShow(L.ALERT_UNUSED_LIST:format(unusedTracker))
	end

	F.DD_TRANSIT:UseAtlasSize(true)
	HDH_AT_DropDown_Init(F.DD_TRANSIT, traitList, HDH_AT_OnSelected_Dropdown , nil, "HDH_AT_DropDownTrackerItemTemplate") --	HDH_AT_DropDownTrackerItemTemplate")

	for _, item in ipairs(self:GetTalentList(true)) do
		id, name, icon = unpack(item)
		itemValues[#itemValues+1] = {-1, name, icon}
		itemTemplates[#itemTemplates+1] = "HDH_AT_SplitItemTemplate"
		itemValues[#itemValues+1] = {id, L.ALWAYS_USE, nil}
		itemTemplates[#itemTemplates+1] = "HDH_AT_CheckButtonItemTemplate"
		for _, trait in ipairs(self:GetTraits(id)) do
			itemValues[#itemValues+1] = trait
			itemTemplates[#itemTemplates+1] = "HDH_AT_CheckButtonItemTemplate"
		end
	end
	ddm:UseAtlasSize(true)
	HDH_AT_DropDown_Init(ddm, itemValues, HDH_AT_OnSelected_Dropdown, nil, itemTemplates, true, true)
end

function HDH_AT_ConfigFrameMixin:UpdateTraitsSelector(idx)
	local ddm = self.F.DD_TRACKER_TRANSIT
	local check
	for i = (idx or 1), #ddm.item do
		itemFrame = ddm.item[i]
		
		if (GetSpecializationInfoByID(itemFrame.value)) then
			check = itemFrame.CheckButton:GetChecked()
		else
			if itemFrame.value ~= -1 then
				if check then
					itemFrame.CheckButton:Disable()
					itemFrame.CheckButton:SetChecked(false)
					itemFrame.Text:SetFontObject("Font_Gray_S")
				else
					itemFrame.CheckButton:Enable()
					itemFrame.Text:SetFontObject("Font_White_S")
				end
			end
		end
	end
end

function HDH_AT_ConfigFrameMixin:GetElementFrame(listFrame, trackerId, index)
	local row = listFrame.list[index]
	index = tonumber(index)
	if not row then
		row = CreateFrame("Button",(listFrame:GetName().."Row"..index), listFrame, "HDH_AT_RowTemplate")
		row:SetParent(listFrame)
		if index == 1 then row:SetPoint("TOPLEFT",listFrame,"TOPLEFT") row:SetPoint("TOPLEFT",listFrame,"TOPLEFT")
					  else row:SetPoint("TOPLEFT",listFrame,"TOPLEFT",0,(-row:GetHeight()*(index-1))) end
		row:SetWidth(listFrame:GetParent():GetWidth())
		row:Hide() -- 기본이 hide 중요!
		row:SetScript('OnDragStart', HDH_AT_OP_OnDragStartRow)
		row:SetScript('OnDragStop', HDH_AT_OP_OnDragStopRow)
		row:RegisterForDrag('LeftButton')
		row:EnableMouse(true)
		row:SetMovable(true)
		row.idx  = index
		_G[row:GetName().."EditBoxID"]:SetScript("OnEnterPressed", function(self) HDH_AT_OnEventTrackerElement(self, self:GetParent().index) end)
		_G[row:GetName().."ButtonSet"]:SetScript("OnClick", function(self) HDH_AT_OnEventTrackerElement(self, self:GetParent().index) end)
		_G[row:GetName().."CheckButtonGlow"]:SetScript("OnClick", function(self) HDH_AT_OnEventTrackerElement(self, self:GetParent().index) end)
		_G[row:GetName().."CheckButtonValue"]:SetScript("OnClick", function(self) HDH_AT_OnEventTrackerElement(self, self:GetParent().index) end)
		_G[row:GetName().."CheckButtonAlways"]:SetScript("OnClick", function(self) HDH_AT_OnEventTrackerElement(self, self:GetParent().index) end)
		_G[row:GetName().."ButtonDel"]:SetScript("OnClick", function(self) HDH_AT_OnEventTrackerElement(self, self:GetParent().index) end)
		_G[row:GetName().."ButtonAdd"]:SetScript("OnClick", function(self) HDH_AT_OnEventTrackerElement(self, self:GetParent().index) end)
		_G[row:GetName().."ButtonCancel"]:SetScript("OnClick", function(self) HDH_AT_OnEventTrackerElement(self, self:GetParent().index) end)

		listFrame.list[index] = row
	end
	return row 
end

function HDH_AT_ConfigFrameMixin:LoadTrackerElementConfig(trackerId, startRowIdx, endRowIdx)
	local F = self.F
	local listFrame = F.BODY.CONFIG_TRACKER_ELEMENTS.CONTENTS
	if not listFrame.list then listFrame.list = {} end
	-- local itemDB = self:GetCurrentTrackerItemListDB()
	-- local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	-- local tracker_name = db.name
	-- local type = db.type
	-- local unit = db.unit
	-- local spec = HDH_GetSpec(tracker_name);
	-- if not DB_AURA.Talent[spec] then return end
	-- aura = db.spell_list
	if not trackerId then return end
	local rowFrame
	local i = startRowIdx or 1
	local id, name, type, unit, aura_filter, aura_caster, trait = DB:GetTrackerInfo(trackerId)
	local elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem, readOnly
	if (type ~= HDH_TRACKER.TYPE.BUFF and type ~= HDH_TRACKER.TYPE.DEBUFF and type ~= HDH_TRACKER.TYPE.TOTEM) or aura_filter == DB.AURA_FILTER_REG then
		if startRowIdx and endRowIdx and (startRowIdx > endRowIdx) then return end
		while true do
			rowFrame = self:GetElementFrame(listFrame, trackerId, i)-- row가 없으면 생성하고, 있으면 그거 재활용
			elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
			readOnly = DB:IsReadOnlyTrackerElement(trackerId, i)
			glowType = (((glowType and glowType ~= DB.GLOW_CONDITION_NONE) and true) or false)
			rowFrame.index = i
			if not rowFrame:IsShown() then rowFrame:Show() end
			rowFrame:ClearAllPoints();
			if i == 1 	then rowFrame:SetPoint("TOPLEFT",listFrame,"TOPLEFT") 
						else rowFrame:SetPoint("TOPLEFT",listFrame,"TOPLEFT", 0, (-rowFrame:GetHeight()*(i-1))) end
			
			if elemKey then
				rowFrame:Set(i, elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem, readOnly)
				rowFrame:ChangeReadMode()
			else-- add 를 위한 공백 row 지정
				rowFrame:Clear()
				listFrame:SetSize(listFrame:GetParent():GetWidth(), i * ROW_HEIGHT)
				if type == HDH_TRACKER.TYPE.BUFF 
						or type == HDH_TRACKER.TYPE.DEBUFF
						or type == HDH_TRACKER.TYPE.COOLDOWN
						or type == HDH_TRACKER.TYPE.TOTEM then
					rowFrame:Show()
				else
					rowFrame:Hide()
				end
				break
			end
			if endRowIdx and endRowIdx == i then return end
			i = i + 1
		end
		i = i + 1 -- add 를 위한인덱스

		self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_ALL_TRACKER:Hide()
		self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_BOSS_TRACKER:Hide()

	elseif aura_filter == DB.AURA_FILTER_ALL  then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_ALL_TRACKER:Show()
		self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_BOSS_TRACKER:Hide()
		i = 1

	elseif aura_filter == DB.AURA_FILTER_ONLY_BOSS then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_ALL_TRACKER:Hide()
		self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_BOSS_TRACKER:Show()
		i = 1
	end
		
	while true do -- 불필요한 row 안보이게 
		rowFrame = listFrame.list[i] -- 불필요한 row가 있다면
		if rowFrame then rowFrame:Clear()
						 rowFrame:Hide() 
					else break end
		i = i + 1
	end
	
end

function HDH_AT_ConfigFrameMixin:LoadDetailFrame(detailMode, trackerId, elemIdx, button)
	local F = self.F
	local key, id, name, texture, _, _, _, isItem = DB:GetTrackerElement(trackerId, elemIdx)
	F.BODY.CONFIG_DETAIL.elemIdx = elemIdx
	F.BODY.CONFIG_DETAIL.id = id
	F.BODY.CONFIG_DETAIL.texture = texture
	F.BODY.CONFIG_DETAIL.trackerId = trackerId
	
	F.BODY.CONFIG_DETAIL.ICON:SetTexture(texture)
	F.BODY.CONFIG_DETAIL.TEXT:SetText(name)
	F.BODY.CONFIG_DETAIL.mode = detailMode

	if detailMode == BODY_DETAIL_GLOW then
		F.BODY.CONFIG_DETAIL.GLOW.checkbutton = button
		F.BODY.CONFIG_DETAIL.GLOW.preCheck = not button:GetChecked()

		local glowType, glowCondition, glowValue = DB:GetTrackerElementGlow(trackerId, elemIdx)
		local match
		for idx, cd in ipairs(F.BODY.CONFIG_DETAIL.GLOW.CD_LIST) do
			match = idx == glowType
			F.BODY.CONFIG_DETAIL.GLOW.CD_LIST[idx][1]:SetChecked(match)
			if idx > 1 then
				F.BODY.CONFIG_DETAIL.GLOW.CD_LIST[idx][2]:SetSelectedIndex((match and glowCondition) or 1)
				F.BODY.CONFIG_DETAIL.GLOW.CD_LIST[idx][3]:SetText((match and glowValue) or "")
			end
		end
		button:SetChecked(F.BODY.CONFIG_DETAIL.GLOW.preCheck)
		F.BODY.CONFIG_DETAIL.BTN_SAVE:Show()
		F.BODY.CONFIG_DETAIL.BTN_CLOSE:ClearAllPoints()
		F.BODY.CONFIG_DETAIL.BTN_CLOSE:SetPoint("BOTTOMLEFT", F.BODY.CONFIG_DETAIL.BTN_CLOSE:GetParent() ,"BOTTOM", 5, 5)

	elseif detailMode == BODY_DETAIL_ETC then
		local trackerType = select(3, DB:GetTrackerInfo(trackerId))
		local texture, key, isItem = DB:GetTrackerElementImage(trackerId, elemIdx)
		local deFaultTexture = DB:GetTrackerElementDefaultImage(trackerId, elemIdx)
		local CLASS = HDH_TRACKER.GetClass(trackerType)

		F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CB_ION_DEFAULT.Icon:SetTexture(deFaultTexture)
		F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON.Icon.key = key
		F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON.Icon.isItem = isItem
		F.BODY.CONFIG_DETAIL.BTN_CLOSE:ClearAllPoints()
		F.BODY.CONFIG_DETAIL.BTN_CLOSE:SetPoint("BOTTOM", F.BODY.CONFIG_DETAIL.BTN_CLOSE:GetParent() ,"BOTTOM", 0, 5)
		F.BODY.CONFIG_DETAIL.BTN_SAVE:Hide()

		-- Load ChangeIcon
		if key then
			F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON.Icon:SetTexture(texture)
		else
			F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON.Icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
		end
		F.BODY.CONFIG_DETAIL.ETC.CUSTOM_EB_SPELL:SetText(key or "")
		F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CB_IS_ITEM:SetChecked(isItem)
		
		local tex = F.BODY:CreateTexture()
		if key then
			for _, cb in ipairs(CHANGE_ICON_CB_LIST) do
				cb:SetChecked(false)
			end
			F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON:SetChecked(true)
		else
			for _, cb in ipairs(CHANGE_ICON_CB_LIST) do
				cb:SetChecked(texture == cb.Icon:GetTexture())
			end
		end

		local values = DB:GetTrackerElementSplitValues(trackerId, elemIdx) or {}
		-- Load splitbar
		local splitbar = F.BODY.CONFIG_DETAIL.ETC.SPLIT_BAR
		splitbar.ED_LIST = splitbar.ED_LIST or {}
		local edList = splitbar.ED_LIST
		local v 
		local component
		local parent = self.DETAIL_ETC_TAB[2].content
		for i =1 , (#values + 1) do
			v = values[i]
			if not edList[i] then
				component = CreateFrame("Frame", (parent:GetName()..'AddDelEdtibox'..i), parent, "HDH_AT_AddDelEdtiboxTemplate")
				component:SetSize(115, 26)
				component.EditBox:SetAutoFocus(false)
				component.EditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
				component.EditBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() HDH_AT_OnClick_Button(self:GetParent().ButtonAdd) end)
				component.ButtonAdd:SetScript("OnClick", HDH_AT_OnClick_Button)
				component.ButtonDel:SetScript("OnClick", HDH_AT_OnClick_Button)
				component.Text:SetText(L.SPLIT_POINT:format(i))
				if i == 1 then
					component:SetPoint('TOPLEFT', splitbar, 'BOTTOMLEFT', 0, -40)
				else
					component:SetPoint('TOPLEFT', edList[i -1], 'BOTTOMLEFT', 0, -5)
				end
				edList[i] = component
			end
			edList[i].EditBox:SetText(v or "")
			edList[i]:Show()
			edList[i].index = i
			if v then
				splitbar:AddPointer(i, v)
			else
				splitbar:RemovePointer(i)
			end
		end
		for i = #values + 2, #edList do
			edList[i]:Hide()
			splitbar:RemovePointer(i)
		end
		

		if CLASS.POWER_INFO and trackerType ~= HDH_TRACKER.TYPE.STAGGER then
			local max = UnitPowerMax('player', CLASS.POWER_INFO[trackerType].power_index)
			if max then
				splitbar:SetMinMaxValues(0, max)
			end
		else
			splitbar:SetMinMaxValues(0, 1)
		end
	end
end

function HDH_AT_ConfigFrameMixin:LoadTrackerConfig(value)
	local F = self.F
	F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
	-- self:LoadTraits()
	if value then
		local id, name, type, unit, aura_filter, aura_caster, trait = DB:GetTrackerInfo(value)
		F.BODY.CONFIG_TRACKER.is_creation = false
		F.BODY.CONFIG_TRACKER.TITLE:SetText(L.EDIT_TRACKER)
		if id then
			F.ED_TRACKER_NAME:SetText(name)

			F.DD_TRACKER_AURA_CASTER:Enable()
			F.DD_TRACKER_AURA_FILTER:Enable()
			F.DD_TRACKER_UNIT:Enable()

			if type == HDH_TRACKER.TYPE.BUFF or type == HDH_TRACKER.TYPE.DEBUFF then
				F.DD_TRACKER_UNIT:SetSelectedValue(unit)
				F.DD_TRACKER_AURA_CASTER:SetSelectedValue(aura_caster)
				F.DD_TRACKER_AURA_FILTER:SetSelectedValue(aura_filter)
				F.DD_TRACKER_AURA_CASTER:Enable()
				F.DD_TRACKER_AURA_FILTER:Enable()
				F.DD_TRACKER_UNIT:Enable()
				-- HDH_AT_DropDown_Init(F.DD_TRACKER_UNIT, DDP_AURA_UNIT_LIST, HDH_AT_OnSelected_Dropdown)

			elseif type == HDH_TRACKER.TYPE.TOTEM then
				F.DD_TRACKER_UNIT:SelectClear()
				F.DD_TRACKER_AURA_CASTER:SelectClear()
				F.DD_TRACKER_AURA_FILTER:SetSelectedIndex(aura_filter)
				F.DD_TRACKER_UNIT:Disable()
				F.DD_TRACKER_AURA_CASTER:Disable()
				F.DD_TRACKER_AURA_FILTER:Enable()

			else
				F.DD_TRACKER_UNIT:SelectClear()
				F.DD_TRACKER_AURA_CASTER:SelectClear()
				F.DD_TRACKER_AURA_FILTER:SelectClear()
				F.DD_TRACKER_UNIT:Disable()
				F.DD_TRACKER_AURA_CASTER:Disable()
				F.DD_TRACKER_AURA_FILTER:Disable()

			end

			F.DD_TRACKER_TYPE:SetSelectedValue(type)
			F.DD_TRACKER_TRANSIT:SetSelectedValue(trait)
			F.BODY.CONFIG_TRACKER.BTN_DELETE:Enable()
			F.BODY.CONFIG_TRACKER.BTN_CANCEL:Enable()
			F.BODY.CONFIG_TRACKER.BTN_COPY:Enable()
			F.BTN_PREV_NEXT.Value:SetText(id)
			F.BTN_PREV_NEXT.BtnNext:Enable()
			F.BTN_PREV_NEXT.BtnPrev:Enable()

			self:UpdateTraitsSelector()
			return true
		else
			return false
		end
	else
		F.BODY.CONFIG_TRACKER.is_creation = true
		F.BODY.CONFIG_TRACKER.TITLE:SetText(L.CREATE_TRACKER)
		F.ED_TRACKER_NAME:SetText("")
		
		F.DD_TRACKER_TYPE:SelectClear()
		F.DD_TRACKER_UNIT:SelectClear()
		F.DD_TRACKER_AURA_CASTER:SelectClear()
		F.DD_TRACKER_AURA_FILTER:SelectClear()
		F.DD_TRACKER_TRANSIT:SelectClear()

		F.DD_TRACKER_AURA_CASTER:Enable()
		F.DD_TRACKER_AURA_FILTER:Enable()
		F.DD_TRACKER_UNIT:Enable()

		F.DD_TRACKER_AURA_CASTER:Disable()
		F.DD_TRACKER_AURA_FILTER:Disable()
		F.DD_TRACKER_UNIT:Disable()
		F.BODY.CONFIG_TRACKER.BTN_DELETE:Disable()
		F.BODY.CONFIG_TRACKER.BTN_CANCEL:Disable()
		F.BODY.CONFIG_TRACKER.BTN_COPY:Disable()
		F.BTN_PREV_NEXT.Value:SetText("-")
		F.BTN_PREV_NEXT.BtnNext:Disable()
		F.BTN_PREV_NEXT.BtnPrev:Disable()
		return false
	end
end

function HDH_AT_ConfigFrameMixin:GetTrackerData(id)
	local trackerData = {}
	for _, tracker in ipairs(HDH_AT_DB.tracker) do
		if tracker.trait then
			if UTIL.HasValue(tracker.trait, id) then
				-- values[#values+1] = { tracker.id, tracker.name }
				trackerData[#trackerData+1] = {
					id = tracker.id,
					name = tracker.name,
					unit = tracker.unit,
					type = tracker.type,
				}
			end
		end
	end

	return trackerData
end

-- function HDH_AT_ConfigFrameMixin:ChangeTrackerTabByTrackerId(id)
-- 	local parent = self.F.TRACKER
-- 	local selectIdx
-- 	parent.list = parent.list or {}

-- 	for idx, tab in pairs(parent.list) do
-- 		if tab.id and (tab.id == id) then
-- 			selectIdx = idx 
-- 			break
-- 		end
-- 	end

-- 	-- 현재 트래커 리스트에 있는거면 해당탭으로 이동
-- 	if selectIdx then
-- 		self:SetCurTrackerIdx(selectIdx)
-- 	else
-- 		self.F.DD_TRANSIT:SetSelectedValue(1)
-- 		self:LoadTrackerList()
-- 		self:ChangeTrackerTabByTrackerId(id)
-- 		-- self:LoadTrackerList(traitId)
-- 		-- local traitList = select(7, DB:GetTrackerInfo(id))
-- 		-- local curTalent = select(1, GetSpecializationInfo(GetSpecialization()))
-- 		-- local traitId
-- 		-- if #traitList > 0 then
-- 		-- 	for _, t in ipairs(traitList) do
-- 		-- 		if curTalent == GetTalentIdByTraits(t) then
-- 		-- 			traitId = t
-- 		-- 			break
-- 		-- 		end
-- 		-- 	end
-- 		-- 	if not traitId then
-- 		-- 		traitId = traitList[1]
-- 		-- 	end
-- 		-- 	self.F.DD_TRANSIT:SetSelectedValue(traitId)
-- 		-- 	self:LoadTrackerList(traitId)
-- 		-- 	self:ChangeTrackerTabByTrackerId(id)
-- 		-- else
-- 		-- 	-- self:SetCurTrackerIdx(0)
-- 		-- end
-- 	end
-- end

function HDH_AT_ConfigFrameMixin:GetTrackerIndex(value)
	local list = self.F.TRACKER.list
	for i, t in ipairs(list) do
		if t.id == value then
			return i
		end
	end
	return nil
end

function HDH_AT_ConfigFrameMixin:GetTrackerListSize()
	local list = self.F.TRACKER.list or {}
	for i, t in ipairs(list) do
		if not t.id then
			return i - 1
		end
	end
	return #list
end

function HDH_AT_ConfigFrameMixin:LoadTrackerList(traitId)
	local F = self.F
	local component
	local parent = self.F.TRACKER
	local MARGIN_Y = 0
	local trackerIds
	local id, name, type, unit
	local typeName

	if not traitId or traitId == DDM_TRACKER_ALL then
		trackerIds = DB:GetTrackerIds()
	elseif traitId == DDM_TRACKER_UNUSED then
		trackerIds = DB:GetUnusedTrackerIds()
	else
		local talentId = GetTalentIdByTraits(traitId)
		trackerIds = traitId and DB:GetTrackerIdsByTraits(traitId, talentId)
	end

	parent.list = parent.list or {}
	for idx=1, #trackerIds do
		id, name, type, unit = DB:GetTrackerInfo(trackerIds[idx])
		if F.BTN_SHOW_ADD_TRACKER_CONFIG == parent.list[idx] or not parent.list[idx] then 
			component = CreateFrame("Button", (parent:GetName()..'Tracker'..idx), parent, "HDH_AT_TrackerTapBtnTemplate")
			component:SetWidth(120)
			component.Text:SetJustifyH("RIGHT")
			component.ConfigBtn:SetScript("OnClick", HDH_AT_OnClick_TrackerConfigButton)
			component.ConfigBtn.index = idx
			component:SetScript("OnClick", HDH_AT_OnClick_TrackerTapButton)	
			component:SetScript('OnDragStart', HDH_AT_OP_OnDragStartRow)
			component:SetScript('OnDragStop', HDH_AT_OP_OnDragStopRow)
			component:RegisterForClicks("LeftButtonUp", "RightButtonUp");
			
			component:RegisterForDrag('LeftButton')
			component:EnableMouse(true)
			component:SetMovable(true)
			parent.list[idx] = component 
		else
			component = parent.list[idx]
			component:Show()
		end
		component.ConfigBtn.index = idx
		component.index = idx
		component.id = id
		component.type = type
		component.unit = unit
		component.mode = HDH_AT_AuraRowMixin.MODE.DATA
		component:ClearAllPoints()
		component:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', 2, -((component:GetHeight())  * (idx -1) + MARGIN_Y))

		local unitName = ""
		typeName = "Unknown Tracker"
		if type == HDH_TRACKER.TYPE.BUFF or type == HDH_TRACKER.TYPE.DEBUFF then
			unitName = ": " .. UNIT_TO_LABEL[unit]
		end

		for i, label in ipairs(DDP_TRACKER_LIST) do
			if label[1] == type then
				typeName = label[2]
			end
		end
		component:SetText(STR_TRACKER_FORMAT:format(name, typeName, unitName))
		component:SetActivate(false)
	end
	if parent.list[#parent.list] ~= F.BTN_SHOW_ADD_TRACKER_CONFIG then
		parent.list[#parent.list+1] = F.BTN_SHOW_ADD_TRACKER_CONFIG	
		F.BTN_SHOW_ADD_TRACKER_CONFIG.index = #parent.list
		F.BTN_SHOW_ADD_TRACKER_CONFIG.mode = HDH_AT_AuraRowMixin.MODE.EMPTY
	end
	
	if #trackerIds < #parent.list-1 then
		for i = #trackerIds+1, #parent.list-1 do
			parent.list[i]:Hide()
			parent.list[i].id = nil
			parent.list[i].type = nil
			parent.list[i].unit = nil
			parent.list[i].mode = HDH_AT_AuraRowMixin.MODE.EMPTY
			-- parent.list[i].name = nil
		end
	end

	parent:SetSize(120, (#trackerIds + 1) * F.BTN_SHOW_ADD_TRACKER_CONFIG:GetHeight())
	F.BTN_SHOW_ADD_TRACKER_CONFIG:Show()
	if #trackerIds == 0 then
		F.BTN_SHOW_ADD_TRACKER_CONFIG:ClearAllPoints()
		F.BTN_SHOW_ADD_TRACKER_CONFIG:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 2, -MARGIN_Y)
	else
		F.BTN_SHOW_ADD_TRACKER_CONFIG:ClearAllPoints()
		F.BTN_SHOW_ADD_TRACKER_CONFIG:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', 2, -((F.BTN_SHOW_ADD_TRACKER_CONFIG:GetHeight())  * (#trackerIds ) + MARGIN_Y))
	end
	-- self:SetCurTraits(traitId)
end

function HDH_AT_ConfigFrameMixin:AppendUITab(tabData, tabFrame, bodyFrame)
	local component, configFrame
	local ret = {}
	local tabButtonIdx = 0
	for idx, data in ipairs(tabData) do
		if data.type == "LABEL" then
			component = CreateFrame("Button", (tabFrame:GetName()..'Tab'..idx), tabFrame, "HDH_AT_UITabBtnLabelTemplate")
			component:Disable()
			_G[component:GetName().."Text"]:SetJustifyH("CENTER")
		else
			component = CreateFrame("Button", (tabFrame:GetName()..'Tab'..idx), tabFrame, "HDH_AT_UITabBtnTemplate")
			component:SetScript("OnClick", HDH_AT_OnChangeTabUI)

			tabButtonIdx = tabButtonIdx + 1
			component.index = tabButtonIdx
			configFrame = CreateFrame("Frame", (bodyFrame:GetName()..'Config'..tabButtonIdx), bodyFrame)
			configFrame:SetPoint('TOPLEFT', bodyFrame, 'TOPLEFT', 0, 0)
			configFrame:SetPoint('BOTTOMRIGHT', bodyFrame, 'BOTTOMRIGHT', 0, 0)
			configFrame:Hide()
			component.content = configFrame
			ret[tabButtonIdx] = component
		end
		component:SetPoint('TOPLEFT', tabFrame, 'TOPLEFT', 1, -(component:GetHeight() * (idx -1)))
		component:SetPoint('RIGHT', tabFrame, 'RIGHT', -20, 0)
		component:SetText(data.name)
	end
	
	tabFrame.tabs = ret
	return ret
end

function HDH_AT_ConfigFrameMixin:LoadUIConfig(tackerId)
	local F = self.F
	for _, comp in ipairs(UI_COMP_LIST) do
		LoadDB(tackerId, comp)
	end
	if DB:hasTrackerUI(tackerId) then
		F.BODY.CONFIG_UI.SW_CONFIG_MODE:SetSelectedIndex(DB.USE_SEVERAL_CONFIG)
	else
		F.BODY.CONFIG_UI.SW_CONFIG_MODE:SetSelectedIndex(DB.USE_GLOBAL_CONFIG)
	end
end

function HDH_AT_ConfigFrameMixin:UpdateFrame()
	local F = self.F
	local ddm = F.DD_TRANSIT
	local talentID = select(1, GetSpecializationInfo(GetSpecialization()))
	local traitID = talentID and C_ClassTalents.GetLastSelectedSavedConfigID(talentID)
	local traitName = traitID and UTIL.GetTraitsName(traitID)
	
	-- HDH_AT_ConfigFrame.Text:SetText((traitName or "none").. ":".. (traitID or 'none'))
	-- if not traitName then
		-- self.Dialog:AlertShow(L.NONACTIVATE_TRANSIT, nil, function() self:Hide() end)
	-- else
		-- HDH_AT_ConfigFrame.Text:SetText((traitName or "none").. ":".. (traitID or 'none'))
	-- end
	self:LoadTraits()
	if ddm:GetIndex(DDM_TRACKER_UNUSED) then
		ddm:SetSelectedValue(-1)
	end
	if ddm:GetSize() > 0 then	
		if not ddm:GetSelectedValue() then
			if ddm:GetIndex(traitID) then
				ddm:SetSelectedValue(traitID)
			elseif ddm:GetIndex(talentID) then
				traitID = talentID
				ddm:SetSelectedValue(talentID)
			else	
				ddm:SetSelectedIndex(1)
			end
		end
		self:LoadTrackerList(ddm:GetSelectedValue())
		self:ChangeBody(nil, nil, nil, nil)
	else
		ddm:SelectClear()
		self:ChangeBody(BODY_TRACKER_NEW)
	end
end

function HDH_AT_ConfigFrameMixin:UpdateAbleConfigs(mode)
	local F = self.F
	local idx = self.UI_TAB.selectedIndex or 1
	
	if mode == DB.DISPLAY_ICON then
		self.UI_TAB[4]:Disable()
		self.UI_TAB[6]:Enable()
		self.UI_TAB[7]:Disable()
	elseif mode == DB.DISPLAY_BAR then
		self.UI_TAB[4]:Enable()
		self.UI_TAB[6]:Disable()
		self.UI_TAB[7]:Enable()
	else
		self.UI_TAB[4]:Enable()
		self.UI_TAB[6]:Enable()
		self.UI_TAB[7]:Enable()
	end
	if not self.UI_TAB[idx]:IsEnabled() then
		idx = 1
	end
	-- ChangeTab(self.UI_TAB, idx)
end

local function DBSync(comp, comp_type, key)
	if key then
		local UI = UI_COMP_LIST
		UI[#UI+1] = comp
		comp.dbKey = key
		comp.type = comp_type
	end
end

function HDH_AT_ConfigFrameMixin:AddSplitPoint()

end

function HDH_AT_ConfigFrameMixin:InitFrame()
    self.F = {}
	local F = self.F
	local UI = UI_COMP_LIST
	local comp

	self.F.BTN_SHOW_MODIFY_TRACKER = _G[self:GetName().."DropDownTrackerBtnModifyTracker"]
	
	-- self.F.DD_TRANSIT = _G[self:GetName().."DropDownTalent"]
	self.F.DD_TRANSIT = _G[self:GetName().."DropDownTraits"]
	-- self.F.DROPDOWN_TRACKER = _G[self:GetName().."DropDownTracker"]

	self.F.TRACKER = _G[self:GetName().."TrackerSFContents"]
	self.F.BTN_SHOW_ADD_TRACKER_CONFIG = _G[self.F.TRACKER:GetName().."BtnAddTracker"]
	self.F.BTN_SHOW_ADD_TRACKER_CONFIG:SetScript("OnClick", HDH_AT_OnClick_TrackerTapButton)
	
	self.F.BODY = _G[self:GetName().."Body"]

	self.F.BODY.CONFIG_DETAIL = _G[self:GetName().."BodyDetailConfig"]
	self.F.BODY.CONFIG_DETAIL.ICON = _G[self:GetName().."BodyDetailConfigTopIcon"]
	self.F.BODY.CONFIG_DETAIL.TEXT = _G[self:GetName().."BodyDetailConfigTopText"]
	self.F.BODY.CONFIG_DETAIL.GLOW = _G[self:GetName().."BodyDetailConfigGlow"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CD1 = _G[self:GetName().."BodyDetailConfigGlowCBCondition1"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CD1.idx = 1
	self.F.BODY.CONFIG_DETAIL.GLOW.CD2 = _G[self:GetName().."BodyDetailConfigGlowCBCondition2"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CD2.idx = 2
	self.F.BODY.CONFIG_DETAIL.GLOW.CD3 = _G[self:GetName().."BodyDetailConfigGlowCBCondition3"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CD3.idx = 3
	self.F.BODY.CONFIG_DETAIL.GLOW.CD4 = _G[self:GetName().."BodyDetailConfigGlowCBCondition4"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CD4.idx = 4
	self.F.BODY.CONFIG_DETAIL.GLOW.CD_DD2 = _G[self:GetName().."BodyDetailConfigGlowDDCondition2"]
	HDH_AT_DropDown_Init(F.BODY.CONFIG_DETAIL.GLOW.CD_DD2, DDP_CONDITION_LIST, HDH_AT_OnSelected_Dropdown)
	F.BODY.CONFIG_DETAIL.GLOW.CD_DD2:SetSelectedIndex(3)
	self.F.BODY.CONFIG_DETAIL.GLOW.CD_DD3 = _G[self:GetName().."BodyDetailConfigGlowDDCondition3"]
	HDH_AT_DropDown_Init(F.BODY.CONFIG_DETAIL.GLOW.CD_DD3, DDP_CONDITION_LIST, HDH_AT_OnSelected_Dropdown)
	F.BODY.CONFIG_DETAIL.GLOW.CD_DD3:SetSelectedIndex(3)
	self.F.BODY.CONFIG_DETAIL.GLOW.CD_DD4 = _G[self:GetName().."BodyDetailConfigGlowDDCondition4"]
	HDH_AT_DropDown_Init(F.BODY.CONFIG_DETAIL.GLOW.CD_DD4, DDP_CONDITION_LIST, HDH_AT_OnSelected_Dropdown)
	F.BODY.CONFIG_DETAIL.GLOW.CD_DD4:SetSelectedIndex(3)
	self.F.BODY.CONFIG_DETAIL.GLOW.CD_EB2 = _G[self:GetName().."BodyDetailConfigGlowEBCondition2"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CD_EB3 = _G[self:GetName().."BodyDetailConfigGlowEBCondition3"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CD_EB4 = _G[self:GetName().."BodyDetailConfigGlowEBCondition4"]

	self.F.BODY.CONFIG_DETAIL.GLOW.CD_LIST = {
		{ self.F.BODY.CONFIG_DETAIL.GLOW.CD1 }, 
		{ self.F.BODY.CONFIG_DETAIL.GLOW.CD2, self.F.BODY.CONFIG_DETAIL.GLOW.CD_DD2, self.F.BODY.CONFIG_DETAIL.GLOW.CD_EB2 },
		{ self.F.BODY.CONFIG_DETAIL.GLOW.CD3, self.F.BODY.CONFIG_DETAIL.GLOW.CD_DD3, self.F.BODY.CONFIG_DETAIL.GLOW.CD_EB3 },
		{ self.F.BODY.CONFIG_DETAIL.GLOW.CD4, self.F.BODY.CONFIG_DETAIL.GLOW.CD_DD4, self.F.BODY.CONFIG_DETAIL.GLOW.CD_EB4 }
	}
	
	self.F.BODY.CONFIG_DETAIL.ETC = _G[self:GetName().."BodyDetailConfigETC"]
	self.F.BODY.CONFIG_DETAIL.ETC.MENU = _G[self:GetName().."BodyDetailConfigETCMenuSFContents"]
	self.F.BODY.CONFIG_DETAIL.ETC.CONTENTS = _G[self:GetName().."BodyDetailConfigETCSFContents"]

	self.DETAIL_ETC_TAB = self:AppendUITab(DETAIL_ETC_CONFIG_TAB_LIST, self.F.BODY.CONFIG_DETAIL.ETC.MENU, self.F.BODY.CONFIG_DETAIL.ETC.CONTENTS)
	
	comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[1].content, COMP_TYPE.IMAGE_CHECKBUTTON, L.USE_DEFAULT_ICON, nil, 1, 1)
	comp.Icon:SetTexture(nil)
	self.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CB_ION_DEFAULT = comp
	table.insert(CHANGE_ICON_CB_LIST, comp)

	comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[1].content, COMP_TYPE.IMAGE_CHECKBUTTON, L.USE_SEARCH_ICON, nil, 2, 1)
	comp.Icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
	self.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON = comp
	table.insert(CHANGE_ICON_CB_LIST, comp)
	local component1 = CreateFrame("EditBox", (comp:GetName()..'EditBox'), comp, "InputBoxTemplate")
	component1:SetSize(130, 26)
	component1:SetPoint('TOPLEFT', comp, 'BOTTOMLEFT', 10, 0)
	component1:SetText(value or "")
	component1:SetAutoFocus(false)
	self.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_EB_SPELL = component1

	local component2 = CreateFrame("CheckButton", (comp:GetName()..'CheckButtonIsItem'), comp, "HDH_AT_CheckButtonTemplate")
	component2:SetSize(26, 26)
	component2:SetPoint('TOPLEFT', component1, 'BOTTOMLEFT', -8, 0)
	component2.Text:SetText(L.ITEM_TOOLTIP)
	self.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CB_IS_ITEM = component2

	local component3 = CreateFrame("Button", (comp:GetName()..'BUTTOM'), comp, "HDH_AT_ButtonTemplate")
	component3:SetSize(50, 26)
	component3:SetPoint('LEFT', component2, 'RIGHT', 63, 0)
	component3:SetText(L.SEARCH)
	component3:SetScript("OnClick", HDH_AT_OnClick_Button)
	self.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_BTN_SEARCH = component3

	self.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_EB_SPELL:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		HDH_AT_OnClick_Button(GetMainFrame().F.BODY.CONFIG_DETAIL.ETC.CUSTOM_BTN_SEARCH) 
	end)

	comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[1].content, nil,  L.ICON_LIST,   nil, 4, 1)

	local col_idx = 0
	local row_idx = 5
	for _, texture in ipairs(ICON_PRESET_LIST) do
		col_idx = (col_idx % 3)
		col_idx = col_idx + 1
		comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[1].content, COMP_TYPE.IMAGE_CHECKBUTTON,     nil, nil, row_idx, col_idx)
		comp.Icon:SetTexture(texture)
		table.insert(CHANGE_ICON_CB_LIST, comp)
		if col_idx == 3 then
			row_idx = row_idx + 1
		end
	end

	-- self.DETAIL_ETC_TAB[2].content
	comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[2].content, nil, L.THIS_IS_ONLY_SPLIT_POWER_BAR)
	local comp = CreateFrame("Frame", (self.DETAIL_ETC_TAB[2].content:GetName()..'SplitBar'), self.DETAIL_ETC_TAB[2].content, "HDH_AT_SplitBarTemplate")
	comp:SetSize(200, 30)
	comp:SetPoint('TOPLEFT', self.DETAIL_ETC_TAB[2].content, 'TOPLEFT', 20, -70)
	comp:SetMinMaxValues(0, 1)
	self.F.BODY.CONFIG_DETAIL.ETC.SPLIT_BAR = comp
	-- INV_Jewelcrafting_DragonsEye03 INV_Jewelcrafting_DragonsEye04 INV_Jewelcrafting_DragonsEye05

	self.F.BODY.CONFIG_DETAIL.BTN_SAVE = _G[self:GetName().."BodyDetailConfigBottomButtonApply"]
	self.F.BODY.CONFIG_DETAIL.BTN_CLOSE = _G[self:GetName().."BodyDetailConfigBottomButtonClose"]

	self.F.BODY.CONFIG_TRACKER = _G[self.F.BODY:GetName().."Tracker"]
	self.F.BODY.CONFIG_TRACKER.TITLE = _G[self.F.BODY:GetName().."TrackerTopText"]
	self.F.BODY.CONFIG_TRACKER.CONTENTS = _G[self.F.BODY:GetName().."TrackerConfigSFContents"]
	self.F.BODY.CONFIG_TRACKER.TRANSIT = _G[self.F.BODY:GetName().."TrackerTraitsSFContents"]
	self.F.BODY.CONFIG_TRACKER.BTN_SAVE = _G[self.F.BODY:GetName().."TrackerBottomBtnSaveTracker"]
	self.F.BODY.CONFIG_TRACKER.BTN_DELETE = _G[self.F.BODY:GetName().."TrackerBottomBtnDelete"]
	self.F.BODY.CONFIG_TRACKER.BTN_CANCEL = _G[self.F.BODY:GetName().."TrackerBottomBtnCancel"]
	self.F.BODY.CONFIG_TRACKER.BTN_COPY = _G[self.F.BODY:GetName().."TrackerBottomBtnCopy"]

	self.F.DD_TRACKER_TRANSIT = _G[self.F.BODY.CONFIG_TRACKER.TRANSIT:GetName().."Traits"]

	self.F.BODY.CONFIG_TRACKER_ELEMENTS = _G[self.F.BODY:GetName().."TrackerElements"]
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.CONTENTS = _G[self.F.BODY:GetName().."TrackerElementsSFContents"]
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_ALL_TRACKER = _G[self.F.BODY:GetName().."TrackerElementsSFNoticeAllTracker"]
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_ALL_TRACKER:SetText(L.TRACKING_ALL_AURA)
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_BOSS_TRACKER = _G[self.F.BODY:GetName().."TrackerElementsSFNoticeBossTracker"]
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_BOSS_TRACKER:SetText(L.TRACKING_BOSS_AURA)
	-- self.F.BODY.CONFIG_TRACKER.BTN_SAVE = _G[self.F.BODY:GetName().."TrackerBottomBtnSaveTracker"]

	self.F.BODY.CONFIG_UI = _G[self.F.BODY:GetName().."UI"]
	-- self.F.BODY.CONFIG_UI.DD_DISPLAY_MODE = _G[self.F.BODY:GetName().."UITopDDLDisplayType"]
	-- self.F.BODY.CONFIG_UI.DD_CONFIG_MODE = _G[self.F.BODY:GetName().."UITopDDLConfigMode"]

	self.F.BODY.CONFIG_UI.SW_DISPLAY_MODE = _G[self.F.BODY:GetName().."UITopSwithDisplayMode"]
	self.F.BODY.CONFIG_UI.SW_DISPLAY_MODE:Init({HDH_AT_L.USE_DISPLAY_ICON, HDH_AT_L.USE_DISPLAY_BAR, HDH_AT_L.USE_DISPLAY_ICON_AND_BAR}, HDH_AT_OnSelected_Dropdown)
	DBSync(F.BODY.CONFIG_UI.SW_DISPLAY_MODE, COMP_TYPE.SWITCH, "ui.%s.common.display_mode")

	self.F.BODY.CONFIG_UI.SW_CONFIG_MODE = _G[self.F.BODY:GetName().."UITopSwithConfigMode"]
	self.F.BODY.CONFIG_UI.SW_CONFIG_MODE:Init({HDH_AT_L.USE_GLOBAL_CONFIG, HDH_AT_L.USE_SEVERAL_CONFIG}, HDH_AT_OnSelected_Dropdown)
	-- DBSync(F.BODY.CONFIG_UI.DD_DISPLAY_MODE, COMP_TYPE.DROPDOWN, "ui.%s.common.display_mode")

	self.F.BODY.CONFIG_UI.CB_MOVE = _G[self.F.BODY:GetName().."UIBottomCBMove"]
	self.F.BODY.CONFIG_UI.CB_SHOW_ID_TOOPTIP = _G[self.F.BODY:GetName().."UIBottomCBShowIdInTooltip"]
	DBSync(F.BODY.CONFIG_UI.CB_SHOW_ID_TOOPTIP, COMP_TYPE.CHECK_BOX, "show_tooltip_id")

	-- HDH_AT_DropDown_Init(F.BODY.CONFIG_UI.DD_DISPLAY_MODE, DDP_DISPLAY_MODE_LIST, HDH_AT_OnSelected_Dropdown)
	-- DBSync(F.BODY.CONFIG_UI.DD_DISPLAY_MODE, COMP_TYPE.DROPDOWN, "ui.%s.common.display_mode")

	-- HDH_AT_DropDown_Init(F.BODY.CONFIG_UI.DD_CONFIG_MODE, DDP_CONFIG_MODE_LIST, HDH_AT_OnSelected_Dropdown)
	

	-- self.F.BODY.CONFIG_UI.CONTENTS = _G[self.F.BODY:GetName().."UISFContents"]
	-- self.F.BODY.CONFIG_TRACKER.BTN_SAVE = _G[self.F.BODY:GetName().."TrackerBottomBtnSaveTracker"]

	-- self.F.BODY.CONFIG_UI.CONTENTS = _G[self.F.BODY:GetName().."UISFContents"]
	self.F.BODY.CONFIG_UI.MEMU = _G[self.F.BODY:GetName().."UIMenuSFContents"]
	self.F.BODY.CONFIG_UI.CONTENTS = _G[self.F.BODY:GetName().."UIConfigSFContents"]
	
	self.F.BODY_TAB_ELEMENTS = _G[self:GetName().."TabElements"]
	self.F.BODY_TAB_UI = _G[self:GetName().."TabUI"]

	-- self.F.BODY_TAB_ELEMENTS.content = self.F.BODY.CONFIG_TRACKER_ELEMENTS
	self.F.BODY_TAB_ELEMENTS.index = 1
	-- self.F.BODY_TAB_UI.content = self.F.BODY.CONFIG_UI
	self.F.BODY_TAB_UI.index = 2

	self.BODY_TAB = {
		self.F.BODY_TAB_ELEMENTS, 
		self.F.BODY_TAB_UI
	}
	
	F.ED_TRACKER_NAME = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS,      COMP_TYPE.EDIT_BOX, 	  L.TRACKER_NAME)
	F.DD_TRACKER_TYPE = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, 	  COMP_TYPE.DROPDOWN, 	  L.TRACKER_TYPE)
	F.DD_TRACKER_UNIT = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, 	  COMP_TYPE.DROPDOWN, 	  L.TRACKER_UNIT)
	F.DD_TRACKER_AURA_FILTER = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, COMP_TYPE.DROPDOWN, 	  L.AURA_FILTER_TYPE)
	F.DD_TRACKER_AURA_CASTER = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, COMP_TYPE.DROPDOWN, 	  L.AURA_CASTER_TYPE)
	-- F.DD_TRACKER_TRANSIT = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS,   COMP_TYPE.DROPDOWN, 	  L.USE_TRAIT)

	F.BTN_PREV_NEXT = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, COMP_TYPE.PREV_NEXT_BUTTON, 	  L.DISPLAY_LEVEL)
	F.BTN_PREV_NEXT.BtnPrev:SetScript("OnClick", HDH_AT_OnClick_Button)
	F.BTN_PREV_NEXT.BtnNext:SetScript("OnClick", HDH_AT_OnClick_Button)
	

	HDH_AT_DropDown_Init(F.DD_TRACKER_TYPE, DDP_TRACKER_LIST, HDH_AT_OnSelected_Dropdown)
	HDH_AT_DropDown_Init(F.DD_TRACKER_UNIT, DDP_AURA_UNIT_LIST, HDH_AT_OnSelected_Dropdown)
	HDH_AT_DropDown_Init(F.DD_TRACKER_AURA_FILTER, DDP_AURA_FILTER_LIST, HDH_AT_OnSelected_Dropdown)
	HDH_AT_DropDown_Init(F.DD_TRACKER_AURA_CASTER, DDP_AURA_CASTER_LIST, HDH_AT_OnSelected_Dropdown)

	local tabUIList = self:AppendUITab(UI_CONFIG_TAB_LIST, self.F.BODY.CONFIG_UI.MEMU, self.F.BODY.CONFIG_UI.CONTENTS)
	self.UI_TAB = tabUIList
	ChangeTab(tabUIList, 1)

	-- FONT COOLDOWN 
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.DROPDOWN,     L.TIME_FORMAT,  		  "ui.%s.font.cd_format")
	HDH_AT_DropDown_Init(comp, DDP_FONT_CD_FORMAT_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.DROPDOWN,     L.TIME_LOCATION,       "ui.%s.font.cd_location")
	HDH_AT_DropDown_Init(comp, DDP_FONT_CD_LOC_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.COLOR_PICKER, L.FONT_COLOR,          "ui.%s.font.cd_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.COLOR_PICKER, L.UNDER_5S_FONT_COLOR, "ui.%s.font.cd_color_5s")
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.SLIDER,       L.FONT_SIZE,           "ui.%s.font.cd_size")
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.CHECK_BOX,       L.SHORT_TIME,      "ui.%s.font.cd_abbreviate")

	-- FONT COUNT
	comp = HDH_AT_CreateOptionComponent(tabUIList[2].content, COMP_TYPE.DROPDOWN,     L.TIME_LOCATION,       "ui.%s.font.count_location")
	HDH_AT_DropDown_Init(comp, DDP_FONT_CD_LOC_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[2].content, COMP_TYPE.COLOR_PICKER, L.FONT_COLOR,          "ui.%s.font.count_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[2].content, COMP_TYPE.SLIDER,       L.FONT_SIZE,           "ui.%s.font.count_size")

	-- FONT VALUE
	comp = HDH_AT_CreateOptionComponent(tabUIList[3].content, COMP_TYPE.DROPDOWN,     L.TIME_LOCATION,       "ui.%s.font.v1_location")
	HDH_AT_DropDown_Init(comp, DDP_FONT_CD_LOC_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[3].content, COMP_TYPE.COLOR_PICKER, L.FONT_COLOR,          "ui.%s.font.v1_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[3].content, COMP_TYPE.SLIDER,       L.FONT_SIZE,           "ui.%s.font.v1_size")
	comp = HDH_AT_CreateOptionComponent(tabUIList[3].content, COMP_TYPE.CHECK_BOX,       L.SHORT_VALUE,      "ui.%s.font.v1_abbreviate")

	-- FONT NAME
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.DROPDOWN,       L.NAME_ALIGN,         "ui.%s.font.name_align")
	HDH_AT_DropDown_Init(comp, DDP_FONT_NAME_ALIGN_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.CHECK_BOX,     L.DISPLAY_NAME,       "ui.%s.font.show_name")
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.COLOR_PICKER, L.FONT_ON_COLOR,          "ui.%s.font.name_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.COLOR_PICKER, L.FONT_OFF_COLOR,      "ui.%s.font.name_color_off")
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.SLIDER,       L.FONT_SIZE,           "ui.%s.font.name_size")
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.SLIDER,       L.MARGIN_LEFT,           "ui.%s.font.name_margin_left")
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.SLIDER,       L.MARGIN_RIGHT,           "ui.%s.font.name_margin_right")

	-- ICON DEFAULT

	-- ICON SIZE
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.DROPDOWN,       L.ICON_ORDER,         "ui.%s.common.order_by")
	HDH_AT_DropDown_Init(comp, DDP_ICON_ORDER_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.SLIDER, 	L.ICON_MARGIN_VERTICAL,          "ui.%s.common.margin_v")
	comp:Init(1, 0, 500, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.SLIDER,       L.ICON_MARGIN_HORIZONTAL,           "ui.%s.common.margin_h")
	comp:Init(1, 0, 500, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.SLIDER,       L.ICON_NUMBER_OF_HORIZONTAL,           "ui.%s.common.column_count")
	comp:Init(1, 1, 20, true, false, nil, L.ROW_N_COL_N)
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.CHECK_BOX,       L.ICON_REVERSE_DISPLAY_V,           "ui.%s.common.reverse_v")
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.CHECK_BOX,       L.ICON_REVERSE_DISPLAY_H,           "ui.%s.common.reverse_h")
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.CHECK_BOX,       L.DISPLAY_GAME_TOOPTIP,           "ui.%s.common.show_tooltip")
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.CHECK_BOX,       L.DISPLAY_WHEN_NONCOMBAT,           "ui.%s.common.always_show")
	self.F.BODY.CONFIG_UI.CB_DISPLAY_WHEN_NONCOMBAT = comp
	-- ICON COLOR
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.DROPDOWN,       L.COOLDOWN_ANIMATION_DIDRECTION,         "ui.%s.icon.cooldown")
	HDH_AT_DropDown_Init(comp, DDP_ICON_COOLDOWN_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SLIDER,     L.ICON_SIZE,       "ui.%s.icon.size")
	comp:Init(0, 10, 100, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SLIDER,     L.ACTIVED_ICON_ALPHA,       "ui.%s.icon.on_alpha")
	comp:Init(0, 0, 1)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SLIDER,     L.INACTIVED_ICON_ALPHA,       "ui.%s.icon.off_alpha")
	comp:Init(0, 0, 1)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.COLOR_PICKER,     L.ACTIVED_ICON_BORDER_COLOR,       "ui.%s.icon.active_border_color")
	-- comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.COLOR_PICKER, L.COOLDOWN_COLOR,      "ui.%s.icon.cooldown_bg_color")
	-- UI[#UI+1] = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.CHECK_BOX,       L.ICON_REVERSE_DISPLAY_V,           "ui.%s.icon.desaturation")
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.CHECK_BOX,       L.USE_DEFAULT_BORDER_COLOR,           "ui.%s.common.default_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.COLOR_PICKER,       L.ICON_SPARK_COLOR,         "ui.%s.icon.spark_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.CHECK_BOX,       L.CANCEL_BUFF,         "ui.%s.icon.able_buff_cancel")

	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.CHECK_BOX,       L.ICON_USE_NOT_ENOUGH_MANA_COLOR,         "ui.%s.cooldown.use_not_enough_mana_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.COLOR_PICKER,       L.ICON_NOT_ENOUGH_MANA_COLOR,         "ui.%s.cooldown.not_enough_mana_color")
	comp:SetEnableAlpha(false)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.CHECK_BOX,       L.ICON_USE_OUT_RAGNE_COLOR,         "ui.%s.cooldown.use_out_range_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.COLOR_PICKER,       L.ICON_OUT_RAGNE_COLOR,         "ui.%s.cooldown.out_range_color")
	comp:SetEnableAlpha(false)

	-- BAR 
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.SLIDER, 	L.WIDTH_SIZE,          "ui.%s.bar.width")
	comp:Init(0, 10, 500, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.SLIDER,       L.HEIGHT_SIZE,           "ui.%s.bar.height")
	comp:Init(0, 10, 500, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.DROPDOWN,       L.BAR_TEXTURE,         "ui.%s.bar.texture")
	HDH_AT_DropDown_Init(comp, DDP_BAR_TEXTURE_LIST, HDH_AT_OnSelected_Dropdown, nil, "HDH_AT_DropDownOptionTextureItemTemplate")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.DROPDOWN,       L.LOCATION_BAR,         "ui.%s.bar.location")
	HDH_AT_DropDown_Init(comp, DDP_BAR_LOC_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.CHECK_BOX,       L.FILL_BAR,         "ui.%s.bar.reverse_fill")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.CHECK_BOX,       L.REVERSE_PROGRESS,         "ui.%s.bar.reverse_progress")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.CHECK_BOX,       L.DISPLAY_SPARK,         "ui.%s.bar.show_spark")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.COLOR_PICKER,     L.BG_COLOR,       "ui.%s.bar.bg_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.COLOR_PICKER,     L.BAR_COLOR,       "ui.%s.bar.color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.CHECK_BOX,       L.DISPLAY_FILL_BAR,         "ui.%s.bar.use_full_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.COLOR_PICKER,     L.FILL_COLOR,       "ui.%s.bar.full_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.CHECK_BOX,       L.USE_DEFAULT_BORDER_COLOR,           "ui.%s.common.default_color")
	
	comp = HDH_AT_CreateOptionComponent(tabUIList[8].content, COMP_TYPE.BUTTON,       L.RESET_ADDON)
	comp:SetText(L.RESET)
	self.F.BODY.CONFIG_UI.BTN_RESET = comp

	comp = HDH_AT_CreateOptionComponent(tabUIList[9].content, COMP_TYPE.BUTTON,       L.EXPORT_SHARE_STRING, nil, 1)
	comp:SetText(L.EXPORT_SHARE_STRING)
	self.F.BODY.CONFIG_UI.BTN_EXPORT_STRING = comp
	comp = HDH_AT_CreateOptionComponent(tabUIList[9].content, COMP_TYPE.EDIT_BOX,       nil, nil, 2)
	comp:SetSize(200,26)
	comp:SetMaxLetters(0)
	comp:SetFontObject("Font_White_XS")
	self.F.BODY.CONFIG_UI.ED_EXPORT_STRING = comp
	comp = HDH_AT_CreateOptionComponent(tabUIList[9].content, COMP_TYPE.SPLIT_LINE,       nil, nil, 3)

	comp = HDH_AT_CreateOptionComponent(tabUIList[9].content, COMP_TYPE.BUTTON,       L.IMPORT_SHARE_STRING, nil, 4)
	comp:SetText(L.IMPORT_SHARE_STRING)
	self.F.BODY.CONFIG_UI.BTN_IMPORT_STRING = comp
	comp = HDH_AT_CreateOptionComponent(tabUIList[9].content, COMP_TYPE.EDIT_BOX,       nil, nil, 5)
	comp:SetSize(200,26)
	comp:SetFontObject("Font_White_XS")
	comp:SetMaxLetters(0)
	self.F.BODY.CONFIG_UI.ED_IMPORT_STRING = comp
end

function HDH_AT_ConfigFrameMixin:SetupCommend()
    SLASH_AURATRACKER1 = '/at'
    SLASH_AURATRACKER2 = '/auratracker'
    SLASH_AURATRACKER3 = '/ㅁㅅ'
    SlashCmdList["AURATRACKER"] = function (msg, editbox)
        if self:IsShown() then 
            self:Hide()
        else
            self:Show()
        end
    end
end

function HDH_AT_ConfigFrame_OnShow(self)
	local IsLoaded = select(1, GetSpecializationInfo(GetSpecialization()))
	if IsLoaded then
		if GetSpecialization() == 5 then
			self.Dialog:AlertShow(L.NOT_FOUND_TALENT)
		end
		self:SetClampedToScreen(true)
		local x = self:GetLeft()
		local y = self:GetBottom()
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", x, y)
		self:SetClampedToScreen(false)
		self:SetWidth(FRAME_WIDTH)
		self:UpdateFrame()
	else
		self:Hide()
	end
end

function HDH_AT_ConfigFrame_OnLoad(self)
    self:SetResizeBounds(FRAME_WIDTH, FRAME_MIN_H, FRAME_WIDTH, FRAME_MAX_H) 
    self:SetupCommend()
    self:InitFrame()
end

-------------------------------
--------- UI component --------
-------------------------------

function HDH_AT_CreateOptionComponent(parent, component_type, option_name, db_key, row, col)
	local MARGIN_X = 10
	local MARGIN_Y = -10
	local COMP_HEIGHT = 25
	local COMP_WIDTH = 95
	local COMP_MARGIN = 5

	local start_x = 0

	parent.row = parent.row or 0
	parent.col = col or parent.col or 1

	if col then
		if col == 2 then
			start_x = 80
		elseif col == 3 then
			start_x = 160
		end
	end
	
	if row and (row > parent.row) then
		parent.row = row
	else
		parent.row = parent.row + 1
	end
	
	local x = start_x -- + COMP_MARGIN
	local y = -(COMP_HEIGHT + COMP_MARGIN) * ((row and row-1) or (parent.row-1))
	local component = nil
	local frame = CreateFrame("Frame", (parent:GetName()..'Label'..parent.row), parent)

	if option_name then
		frame:SetSize(COMP_WIDTH, COMP_HEIGHT)
		frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', MARGIN_X + x, MARGIN_Y + y)
		frame.text = frame:CreateFontString(nil, 'OVERLAY', "Font_Yellow_M")
		frame.text:SetPoint('LEFT', frame, 'LEFT', COMP_MARGIN, 0)
		frame.text:SetPoint('RIGHT', frame, 'RIGHT', 15, 0)
		frame.text:SetNonSpaceWrap(false)
		frame.text:SetJustifyH('LEFT')
		frame.text:SetJustifyV('CENTER')
		frame.text:SetFontObject("Font_Yellow_S")
		frame.text:SetText(option_name)
	else
		frame:SetSize(1, COMP_HEIGHT)
		frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', MARGIN_X + x, MARGIN_Y + y)
	end

	if component_type == COMP_TYPE.CHECK_BOX then
		component = CreateFrame("CheckButton", (parent:GetName()..'CheckButton'..parent.row.."_"..parent.col), parent, "OptionsBaseCheckButtonTemplate")
		component:SetPoint('LEFT', frame, 'RIGHT', 18, 0)
		component:SetScript("OnClick", HDH_AT_UI_OnCheck)

	elseif component_type == COMP_TYPE.BUTTON then
		component = CreateFrame("Button", (parent:GetName()..'Button'..parent.row.."_"..parent.col), parent, "HDH_AT_ButtonTemplate")
		component:SetSize(110, 26)
		component:SetPoint('LEFT', frame, 'RIGHT', 25, 0)
		component:SetText(value or 'None')
		component:SetScript("OnClick", HDH_AT_OnClick_Button)
	
	elseif component_type == COMP_TYPE.EDIT_BOX then
		component = CreateFrame("EditBox", (parent:GetName()..'EditBox'..parent.row.."_"..parent.col), parent, "InputBoxTemplate")
		component:SetSize(110, 26)
		component:SetPoint('LEFT', frame, 'RIGHT', 25, 0)
		component:SetText(value or "")
		component:SetAutoFocus(false) 
		component:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
		component:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
		component:SetMaxLetters(15)

	elseif component_type == COMP_TYPE.DROPDOWN then
		component = CreateFrame("Button", (parent:GetName()..'DropDown'..parent.row.."_"..parent.col), parent, "HDH_AT_DropDownOptionTemplate")
		component:SetSize(115, 22)
		component:SetPoint('LEFT', frame, 'RIGHT', 20, 0)

	elseif component_type == COMP_TYPE.SLIDER then
		component = CreateFrame("Slider", (parent:GetName()..'Slider'..parent.row.."_"..parent.col), parent, "HDH_AT_SliderTemplate")
		component:SetSize(115, 17)
		component:SetPoint('LEFT', frame, 'RIGHT', 20, -4)
		component:SetHandler(HDH_AT_OnChangedSlider)
		component:Init(10, 0, 100, true, true, 10)

	elseif component_type == COMP_TYPE.COLOR_PICKER then
		component = CreateFrame("Button", (parent:GetName()..'ColorPicker'..parent.row.."_"..parent.col), parent, "HDH_AT_ColorPickerTemplate")
		component:SetSize(26, 26)
		component:SetPoint('LEFT', frame, 'RIGHT', 22, 0)
		component:SetHandler(HDH_AT_OnSeletedColor)

	elseif component_type == COMP_TYPE.PREV_NEXT_BUTTON then
		component = CreateFrame("Button", (parent:GetName()..'PrevNextButton'..parent.row.."_"..parent.col), parent, "HDH_AT_PrevNextButtonTemplate")
		component:SetSize(115, 26)
		component:SetPoint('LEFT', frame, 'RIGHT', 20, 0)
		-- component:SetHandler(HDH_AT_OnSeletedColor)
	
	elseif component_type == COMP_TYPE.IMAGE_CHECKBUTTON then
		component = CreateFrame("CheckButton", (parent:GetName()..'ImageCheckButton'..parent.row.."_"..parent.col), parent, "HDH_AT_CheckButtonImageTemplate")
		component:SetSize(26, 26)
		component:SetPoint('LEFT', frame, 'RIGHT', 0, 0)
		component:SetScript("OnClick", HDH_AT_UI_OnCheck)
		-- component:SetHandler(HDH_AT_OnSeletedColor)

	elseif component_type == COMP_TYPE.EDITBOX_ADD_DEL then
		component = CreateFrame("Frame", (parent:GetName()..'AddDelEdtibox'..parent.row.."_"..parent.col), parent, "HDH_AT_AddDelEdtiboxTemplate")
		component:SetSize(115, 26)
		component:SetPoint('LEFT', frame, 'RIGHT', 0, 0)
		component.EditBox:SetText(value or "")
		component.EditBox:SetAutoFocus(false) 
		component.EditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
		component.EditBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
		-- component:SetHandler(HDH_AT_OnSeletedColor)
	
	elseif component_type == COMP_TYPE.SPLIT_LINE then
		component = CreateFrame("Frame", (parent:GetName()..'Line'..parent.row.."_"..parent.col), parent, "HDH_AT_LineFrameTemplate")
		component:SetSize(230, 26)
		component:SetPoint('LEFT', frame, 'LEFT', 0, 0)
		-- component:SetPoint('RIGHT', parent, 'RIGHT', -10, 0)
		-- component:SetHandler(HDH_AT_OnSeletedColor)
	end

	if component_type then
		DBSync(component, component_type, db_key)
	end
	local w, h = parent:GetParent():GetSize()
	parent:ClearAllPoints()
	parent:SetSize(w, -(y - COMP_HEIGHT))
	parent:SetPoint('TOPLEFT', parent:GetParent(), 'TOPLEFT', 0, 0)
	-- parent:SetPoint('BOTTOMRIGHT', parent:GetParent(), 'BOTTOMRIGHT', 0, 30)
	return component, label
end