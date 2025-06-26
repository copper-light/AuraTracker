HDH_AT_ConfigFrameMixin = {}
HDH_AT_ConfigFrameMixin.F = {}
HDH_AT_ConfigFrameMixin.cacheCastSpell = {}
HDH_AT_ConfigFrameMixin.cacheUesdItem = {}

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
COMP_TYPE.BLANK_LINE = 14
          
local FRAME_WIDTH = 404
local FRAME_MAX_H = 1000
local FRAME_MIN_H = 260

local STR_TRAIT_FORMAT = "|cffffc800%s\r\n|cffaaaaaa%s"
local STR_TRACKER_FORMAT = "%s%s"

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

local EQUIPMENT_SLOT = {
	"AMMOSLOT",
	"HEADSLOT",
	"NECKSLOT",
	"SHOULDERSLOT",
	"CHESTSLOT",
	"WAISTSLOT",
	"LEGSSLOT",
	"FEETSLOT",
	"WRISTSLOT",
	"HANDSSLOT",
	"FINGER0SLOT",
	"FINGER1SLOT",
	"TRINKET0SLOT",
	"TRINKET1SLOT",
	"BACKSLOT",
	"MAINHANDSLOT",
	"SECONDARYHANDSLOT",
	"TABARDSLOT",
}

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
	{name=L.IMPORT_PROFILE, type="BUTTON"},         -- 9
	{name=L.EXPORT_PROFILE, type="BUTTON"},         -- 10
	{name=L.RESET, type="BUTTON"},         -- 8
}

local DETAIL_ETC_CONFIG_TAB_LIST= {
	{name=L.DETAIL_CONIFG, type="LABEL"}, 
	{name=L.CHANGE_ICON, type="BUTTON"}, --1
	{name=L.SPLIT_POWER_BAR, type="BUTTON"}, --2
	{name=L.INNER_COOLDOWN_ITEM, type="BUTTON"}, --3
}

local MyClassKor, MyClass = UnitClass("player");
local DDP_TRACKER_LIST = {
	{HDH_TRACKER.TYPE.BUFF, L.BUFF},
	{HDH_TRACKER.TYPE.DEBUFF, L.DEBUFF},
	{HDH_TRACKER.TYPE.COOLDOWN, L.SKILL_COOLDOWN},
	{HDH_TRACKER.TYPE.HEALTH, L.HEALTH}
}

local powerList = {}
local totemName = L.TOTEM

local function HDH_AT_AddTrackerList(power_type, name)
	if power_type then
		table.insert(DDP_TRACKER_LIST, {power_type, name})
	end
end

if MyClass == "MAGE" then 
	-- totemName = L.MAGE_TOTEM
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_ARCANE_CHARGES, L.POWER_ARCANE_CHARGES)
elseif MyClass == "PALADIN" then 
	totemName = L.PALADIN_TOTEM
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_HOLY_POWER, L.POWER_HOLY_POWER)
elseif MyClass == "WARRIOR" then 
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_RAGE, L.POWER_RAGE)
elseif MyClass == "DRUID" then 
	-- totemName = L.DRUID_TOTEM
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_ENERGY, L.POWER_ENERGY)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_LUNAR, L.POWER_LUNAR)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_RAGE, L.POWER_RAGE)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_COMBO_POINTS, L.POWER_COMBO_POINTS)
elseif MyClass == "DEATHKNIGHT" then 
	totemName = L.DK_TOTEM
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_RUNIC, L.POWER_RUNIC)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_RUNE, L.POWER_RUNE)
elseif MyClass == "HUNTER" then 
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_FOCUS, L.POWER_FOCUS)
elseif MyClass == "PRIEST" then 
	totemName = L.PRIEST_TOTEM
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_INSANITY, L.POWER_INSANITY)
	-- addTrackerList(HDH_TRACKER.TYPE.PRIEST_SHADOWY_APPARITION, L.PRIEST_SHADOWY_APPARITION})
elseif MyClass == "ROGUE" then
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_ENERGY, L.POWER_ENERGY)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_COMBO_POINTS, L.POWER_COMBO_POINTS)
elseif MyClass == "SHAMAN" then 
	totemName = L.SHAMAN_TOTEM
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_MAELSTROM, L.POWER_ELE_MAELSTROM)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_ENH_MAELSTROM, L.POWER_ENH_MAELSTROM)
elseif MyClass == "WARLOCK" then 
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_SOUL_SHARDS, L.POWER_SOUL_SHARDS)
elseif MyClass == "MONK" then 
	totemName = L.MONK_TOTEM
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_ENERGY, L.POWER_ENERGY)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_CHI, L.POWER_CHI)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.STAGGER, L.STAGGER)
elseif MyClass == "DEMONHUNTER" then 
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_FURY, L.POWER_FURY)
	-- addTrackerList(HDH_TRACKER.TYPE.POWER_PAIN, L.POWER_PAIN}) -- 삭제됨
elseif MyClass == "EVOKER" then
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_MANA, L.POWER_MANA)
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.POWER_ESSENCE, L.POWER_ESSENCE)
end

if select(4, GetBuildInfo()) >= 100000 or MyClass == "SHAMAN" then
	HDH_AT_AddTrackerList(HDH_TRACKER.TYPE.TOTEM, totemName)
end

GET_TRACKER_TYPE_NAME = {}
for _, v in ipairs(DDP_TRACKER_LIST) do
	if v[1] ~= nil then
		GET_TRACKER_TYPE_NAME[v[1]] = v[2]
	end
end

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

local DDP_FONT_NAME_LOC_LIST = {
	{DB.FONT_LOCATION_HIDE, L.HIDE},
	{DB.FONT_LOCATION_BAR_L, L.FONT_LOCATION_BAR_L},
	{DB.FONT_LOCATION_BAR_R, L.FONT_LOCATION_BAR_R},
	{DB.FONT_LOCATION_BAR_C, L.FONT_LOCATION_BAR_C},
	{DB.FONT_LOCATION_BAR_T, L.FONT_LOCATION_BAR_T},
	{DB.FONT_LOCATION_BAR_B, L.FONT_LOCATION_BAR_B}
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
	{DB.BAR_LOCATION_T, L.TOP_TO_ICON},
	{DB.BAR_LOCATION_B, L.BOTTOM_TO_ICON},
	{DB.BAR_LOCATION_L, L.LEFT_TO_ICON},
	{DB.BAR_LOCATION_R, L.RIGHT_TO_ICON}
}

local DDP_BAR_COOLDOWN_LIST = {
	{DB.COOLDOWN_UP, L.UPWARD},
	{DB.COOLDOWN_DOWN, L.DOWNWARD},
	{DB.COOLDOWN_LEFT, L.TO_THE_LEFT},
	{DB.COOLDOWN_RIGHT, L.TO_THE_RIGHT},
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
	{DB.CONDITION_GT_OR_EQ, L.CONDITION_GT_OR_EQ},
	{DB.CONDITION_LT_OR_EQ, L.CONDITION_LT_OR_EQ},
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
	[1473] = "evoker-augmentation"
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
local BODY_DETAIL_DISPLAY = 7

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
		talentId, _, _, _ = HDH_AT_UTIL.GetSpecializationInfo(i)
		if talentId == nil then
			break
		end
		if searchTraitsId == talentId then
			return talentId
		end
		traitIds = HDH_AT_UTIL.GetConfigIDsBySpecID(talentId)
		for _, v in pairs(traitIds) do
			if v == searchTraitsId then
				return talentId
			end
		end
	end
	return nil
end

local function ChangeTab(list, idx)
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
			self.bodyType = BODY_TRACKER_EDIT
		elseif bottomIndex == 2 then
			self.bodyType = BODY_ELEMENTS
		else
			self.bodyType = BODY_UI
		end
	end

	if (self.bodyType == BODY_DETAIL_GLOW or self.bodyType == BODY_DETAIL_ETC or self.bodyType == BODY_DETAIL_DISPLAY) and trackerIndex then
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
		self:LoadTrackerConfig()
		bottom_list[2]:Hide()
		bottom_list[3]:Hide()
		ChangeTab(bottom_list, 1)
		ChangeTab(tracker_list, #tracker_list)

	elseif self.bodyType == BODY_TRACKER_EDIT then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		self.F.BODY.CONFIG_TRACKER:Show()
		self.F.BODY.CONFIG_UI:Hide()
		self.F.BODY.CONFIG_DETAIL:Hide()
		bottom_list[2]:Show()
		bottom_list[3]:Show()
		self:LoadTrackerConfig(self.trackerId)
		ChangeTab(bottom_list, 1)
		ChangeTab(tracker_list, self.trackerIndex)

	elseif self.bodyType == BODY_ELEMENTS then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS:Show()
		self.F.BODY.CONFIG_TRACKER:Hide()
		self.F.BODY.CONFIG_UI:Hide()
		self.F.BODY.CONFIG_DETAIL:Hide()
		self:LoadTrackerElementConfig(self.trackerId)
		bottom_list[2]:Show()
		bottom_list[3]:Show()
		ChangeTab(bottom_list, 2)
		ChangeTab(tracker_list, self.trackerIndex)
		
	elseif self.bodyType == BODY_UI then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		self.F.BODY.CONFIG_TRACKER:Hide()
		self.F.BODY.CONFIG_UI:Show()
		self.F.BODY.CONFIG_DETAIL:Hide()
		self:LoadUIConfig(self.trackerId)
		self:UpdateAbleConfigs(self.F.BODY.CONFIG_UI.SW_DISPLAY_MODE:GetSelectedValue())
		ChangeTab(bottom_list, 3)
		ChangeTab(tracker_list, self.trackerIndex)
		ChangeTab(ui_list, self.subType)

		if self.subType == 9 then
			self:LoadTrackerListForExport()
		end

	elseif self.bodyType == BODY_DETAIL_GLOW then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		self.F.BODY.CONFIG_TRACKER:Hide()
		self.F.BODY.CONFIG_UI:Hide()
		self.F.BODY.CONFIG_DETAIL:Show()
		self.F.BODY.CONFIG_DETAIL.GLOW:Show()
		self.F.BODY.CONFIG_DETAIL.ETC:Hide()
		self.F.BODY.CONFIG_DETAIL.DISPLAY:Hide()
		self:LoadDetailFrame(BODY_DETAIL_GLOW, self.trackerId, self.elemIndex, args)

	elseif self.bodyType == BODY_DETAIL_DISPLAY then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		self.F.BODY.CONFIG_TRACKER:Hide()
		self.F.BODY.CONFIG_UI:Hide()
		self.F.BODY.CONFIG_DETAIL:Show()
		self.F.BODY.CONFIG_DETAIL.GLOW:Hide()
		self.F.BODY.CONFIG_DETAIL.ETC:Hide()
		self.F.BODY.CONFIG_DETAIL.DISPLAY:Show()
		self:LoadDetailFrame(BODY_DETAIL_DISPLAY, self.trackerId, self.elemIndex, args)

	elseif self.bodyType == BODY_DETAIL_ETC then
		self.F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		self.F.BODY.CONFIG_TRACKER:Hide()
		self.F.BODY.CONFIG_UI:Hide()
		self.F.BODY.CONFIG_DETAIL:Show()
		self.F.BODY.CONFIG_DETAIL.GLOW:Hide()
		self.F.BODY.CONFIG_DETAIL.ETC:Show()
		self.F.BODY.CONFIG_DETAIL.DISPLAY:Hide()
		self:LoadDetailFrame(BODY_DETAIL_ETC, self.trackerId, self.elemIndex, args)
		
		local trackerType = select(3, DB:GetTrackerInfo(self.trackerId))
		local CLASS = HDH_TRACKER.GetClass(trackerType)
		if trackerType == HDH_TRACKER.TYPE.STAGGER then
			self.DETAIL_ETC_TAB[1]:Disable()
			self.DETAIL_ETC_TAB[2]:Disable()
			self.DETAIL_ETC_TAB[3]:Disable()
			ChangeTab(self.DETAIL_ETC_TAB, -1)
		elseif CLASS:GetClassName() == "HDH_POWER_TRACKER" or CLASS:GetClassName() == "HDH_ENH_MAELSTROM_TRACKER" then
			self.DETAIL_ETC_TAB[1]:Enable()
			self.DETAIL_ETC_TAB[2]:Enable()
			self.DETAIL_ETC_TAB[3]:Disable()
			if #self.DETAIL_ETC_TAB >= self.subType then
				ChangeTab(self.DETAIL_ETC_TAB, self.subType)
			else
				ChangeTab(self.DETAIL_ETC_TAB, 1)
			end
		elseif trackerType == HDH_TRACKER.TYPE.COOLDOWN then
			self.DETAIL_ETC_TAB[1]:Enable()
			self.DETAIL_ETC_TAB[2]:Disable()
			self.DETAIL_ETC_TAB[3]:Enable()
			if self.subType ~= 2 then 
				ChangeTab(self.DETAIL_ETC_TAB, self.subType)
			else
				ChangeTab(self.DETAIL_ETC_TAB, 1)
			end
		else
			self.DETAIL_ETC_TAB[1]:Enable()
			self.DETAIL_ETC_TAB[2]:Disable()
			self.DETAIL_ETC_TAB[3]:Disable()
			ChangeTab(self.DETAIL_ETC_TAB, 1)
		end
	end

	if HDH_TRACKER.ENABLE_MOVE then
		local selectedMode= false
		for _, t in pairs(HDH_TRACKER.GetList()) do
			if t.frame.moveFrame and t.frame.moveFrame.isSelected then
				selectedMode = true
				break
			end
		end

		if selectedMode then
			local tId = self.trackerId
			if self.bodyType == BODY_TRACKER_NEW then
				tId = nil
				for _, t in pairs(HDH_TRACKER.GetList()) do
					if t.frame.moveFrame then
						t.frame.moveFrame.isSelected = false
						t:UpdateMoveFrame()
					end
				end
			elseif trackerIndex then
				for _, t in pairs(HDH_TRACKER.GetList()) do
					if t.frame.moveFrame then
						if t.id == tId then
							t.frame.moveFrame.isSelected = true
							t:UpdateMoveFrame()
						else
							t.frame.moveFrame.isSelected = false
						end
					end
				end
			end
		end
	end

	if self.F.LATEST_SPELL_WINDOW:IsShown() then
		self:UpdateLatest()
	end
end

local function LoadDB(trackerId, comp)
	local dbValue = DB:GetTrackerValue(trackerId, comp.dbKey)
	if comp.type == COMP_TYPE.CHECK_BOX then
		comp:SetChecked(dbValue)
	elseif comp.type == COMP_TYPE.SLIDER then
		comp:SetValue(tonumber(dbValue))
	elseif comp.type == COMP_TYPE.COLOR_PICKER then
		comp:SetColorRGBA(unpack(dbValue or {1,1,1,1}))
	elseif comp.type == COMP_TYPE.DROPDOWN or comp.type == COMP_TYPE.SWITCH then
		if dbValue == nil then dbValue = false end
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
			t:SetSize(1,1);
			t:SetPoint("LEFT",UIParent,"LEFT",0,0);
			t:SetPoint("RIGHT",UIParent,"RIGHT",0,0);
			
			t = frame.GridFrame:CreateTexture(nil, "BACKGROUND");
			t:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg.blp");
			t:SetVertexColor(1,0,0, 0.5);
			t:SetSize(1,1);
			t:SetPoint("TOP",UIParent,"TOP",0,0);
			t:SetPoint("BOTTOM",UIParent,"BOTTOM",0,0);

			local text = frame.GridFrame:CreateFontString(nil, 'OVERLAY')
			text:ClearAllPoints()
			text:SetFontObject("Font_White_M")
			text:SetWidth(190)
			text:SetHeight(70)
			text:SetJustifyH("CENTER")
			-- text:SetJustifyV("CENTER")
			text:SetJustifyV("MIDDLE")
			text:SetPoint("CENTER",UIParent,"CENTER", 0, 10);
			text:SetText("(0,0)")
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

function HDH_AT_OnCheck(self)
	local main = GetMainFrame()
	local F = main.F
	local value = self:GetChecked()
	local trackerId = main:GetCurTrackerId()

	if value ~= nil and self.dbKey ~= nil then
		DB:SetTrackerValue(trackerId, self.dbKey, value)
		HDH_TRACKER.UpdateSettings(trackerId)
	end
	
	if self == F.BODY.CONFIG_UI.CB_MOVE then
		HDH_TRACKER.ENABLE_MOVE = value
		HDH_TRACKER.SetMoveAll(value)
		ShowGrid(main, value)
	
	elseif self == F.BODY.CONFIG_UI.CB_DISPLAY_WHEN_NONCOMBAT then
		HDH_TRACKER.InitVaribles(DB:HasUI(trackerId) and trackerId)

	elseif self == F.BODY.CONFIG_UI.SW_DISPLAY_WHEN_IN_RAID then
		HDH_TRACKER.Updates(DB:HasUI(trackerId) and trackerId)

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
			main.Dialog:AlertShow(L.PLEASE_SEARCH_ICON) return 
		end

		DB:SetTrackerElementImage(trackerId, elemIdx, texture, key, isItem)
		HDH_TRACKER.InitVaribles(trackerId)

	elseif self == F.BODY.CONFIG_DETAIL.GLOW.CB1 or 
		   self == F.BODY.CONFIG_DETAIL.GLOW.CB2 or
		   self == F.BODY.CONFIG_DETAIL.GLOW.CB3 or
		   self == F.BODY.CONFIG_DETAIL.GLOW.CB4 then
		for _, cd in ipairs(F.BODY.CONFIG_DETAIL.GLOW.CB_LIST) do
			cd[1]:SetChecked(cd[1] == self)
		end
		F.BODY.CONFIG_DETAIL.GLOW.CB5:SetChecked(false)
	elseif self == F.BODY.CONFIG_DETAIL.GLOW.CB5 then
		for _, cd in ipairs(F.BODY.CONFIG_DETAIL.GLOW.CB_LIST) do
			cd[1]:SetChecked(false)
		end
		F.BODY.CONFIG_DETAIL.GLOW.CB5:SetChecked(true)
	elseif self == F.BODY.CONFIG_DETAIL.DISPLAY.CB1 then
		self:SetChecked(true)
		F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:Hide()
		F.BODY.CONFIG_DETAIL.DISPLAY.CB2:SetChecked(false)
		F.BODY.CONFIG_DETAIL.DISPLAY.CB3:SetChecked(false)
	elseif self == F.BODY.CONFIG_DETAIL.DISPLAY.CB2 then
		self:SetChecked(true)
		F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:Show()
		F.BODY.CONFIG_DETAIL.DISPLAY.CB1:SetChecked(false)
		F.BODY.CONFIG_DETAIL.DISPLAY.CB3:SetChecked(false)
		F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:SetPoint("LEFT", self,"RIGHT", 2,0)
	elseif self == F.BODY.CONFIG_DETAIL.DISPLAY.CB3 then
		self:SetChecked(true)
		F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:Show()
		F.BODY.CONFIG_DETAIL.DISPLAY.CB1:SetChecked(false)
		F.BODY.CONFIG_DETAIL.DISPLAY.CB2:SetChecked(false)
		F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:SetPoint("LEFT", self,"RIGHT", 2,0)
	elseif self == F.BODY.CONFIG_DETAIL.DISPLAY.CB_LEARNED_TRAIT1 then
		self:SetChecked(true)
		F.BODY.CONFIG_DETAIL.DISPLAY.CB_LEARNED_TRAIT2:SetChecked(false)
		F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE_UNLEARNED_TRAIT:Hide()
		F.BODY.CONFIG_DETAIL.DISPLAY.LABEL_SW_HIDE_MODE_UNLEARNED_TRAIT:Hide()
		F.BODY.CONFIG_DETAIL.DISPLAY.EB_CONNECT_TRAIT:Hide()
	elseif self == F.BODY.CONFIG_DETAIL.DISPLAY.CB_LEARNED_TRAIT2 then
		local tracker = HDH_TRACKER.Get(trackerId)
		local className = (tracker and tracker:GetClassName()) or nil
		if className == "HDH_AURA_TRACKER" or className == "HDH_C_TRACKER" or className == "HDH_TT_TRACKER" then
			self:SetChecked(true)
			F.BODY.CONFIG_DETAIL.DISPLAY.CB_LEARNED_TRAIT1:SetChecked(false)
			F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE_UNLEARNED_TRAIT:Show()
			F.BODY.CONFIG_DETAIL.DISPLAY.LABEL_SW_HIDE_MODE_UNLEARNED_TRAIT:Show()
			F.BODY.CONFIG_DETAIL.DISPLAY.EB_CONNECT_TRAIT:Show()
		else
			main.Dialog:AlertShow(L.ONLY_FOR_AURA_CD_TOTEM);
		end
	elseif self == main.TalentButtonList[1] or self == main.TalentButtonList[2] or self == main.TalentButtonList[3] or self == main.TalentButtonList[4] or self == main.TalentButtonList[5] then
		for _, cb in ipairs(main.TalentButtonList) do
			cb:SetChecked(cb == self)
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
	self:StopMovingOrSizing();
	self:SetScript('OnUpdate', nil);
	local main = GetMainFrame()
	local trackerId = GetMainFrame():GetCurTrackerId()
	if self:GetParent() == main.F.BODY.CONFIG_TRACKER_ELEMENTS.CONTENTS 
			and self.mode 
			and self.mode ~= HDH_AT_AuraRowMixin.MODE.EMPTY then 
		main:LoadTrackerElementConfig(trackerId)
		HDH_TRACKER.InitIconFrame(trackerId)
	else
		main:LoadTrackerList(main:GetCurTraits())
		main:ChangeBody(nil, self.index)
		HDH_TRACKER.InitVaribles()
		if main.F.BODY.CONFIG_TRACKER:IsShown() then
			main:LoadTrackerConfig(main:GetCurTrackerId())
		end

		if HDH_TRACKER.ENABLE_MOVE then
			HDH_TRACKER.SetMoveAll(false)
			HDH_TRACKER.SetMoveAll(true)
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
		main:ChangeBody(BODY_DETAIL_DISPLAY, nil, elemIdx, nil, self)

	elseif string.find(name, "CheckButtonGlow") then
		local value = self:GetChecked()
		main:ChangeBody(BODY_DETAIL_GLOW, nil, elemIdx, nil, self)

	elseif string.find(name, "CheckButtonValue") then
		local value = self:GetChecked()
		DB:UpdateTrackerElementValue(trackerId, elemIdx, value)
		HDH_TRACKER.InitIconFrame(trackerId)

	elseif string.find(name, "ButtonDel") then
		main:DeleteTrackerElement(self:GetParent(), trackerId, elemIdx)
		self:GetParent():ChangeReadMode()

	elseif string.find(name, "ButtonAdd") or string.find(name, "EditBoxID") then
		main:AddTrackerElement(self:GetParent(), trackerId, elemIdx)
		self:GetParent():ChangeReadMode()

	elseif string.find(name, "ButtonCancel") then
		self:GetParent():ChangeReadMode()
	end

	if HDH_TRACKER.ENABLE_MOVE then
		local t= HDH_TRACKER.Get(trackerId)
		if t then
			t:SetMove(false)
			t:SetMove(true)
		end
	end
end

local function HDH_AT_OnSelected_Dropdown(self, itemFrame, idx, value)
	local main = GetMainFrame()
	local F = GetMainFrame().F

	if self == F.DD_TRAIT then
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

						if HDH_TRACKER.ENABLE_MOVE then
							HDH_TRACKER.SetMoveAll(false)
							HDH_TRACKER.SetMoveAll(true)
						end
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

						if HDH_TRACKER.ENABLE_MOVE then
							HDH_TRACKER.SetMoveAll(false)
							HDH_TRACKER.SetMoveAll(true)
						end
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

		if HDH_TRACKER.ENABLE_MOVE then
			HDH_TRACKER.SetMoveAll(false)
			HDH_TRACKER.SetMoveAll(true)
		end

	elseif self == F.DD_TRACKER_TRAIT then
		main:UpdateTraitsSelector(idx)

	elseif self == F.DD_TRACKER_TYPE then
		if value == HDH_TRACKER.TYPE.BUFF or value == HDH_TRACKER.TYPE.DEBUFF then
			F.DD_TRACKER_UNIT:SelectClear()
			F.DD_TRACKER_UNIT:Enable()
			F.DD_TRACKER_AURA_FILTER:SelectClear()
			F.DD_TRACKER_AURA_FILTER:Enable()
			F.DD_TRACKER_AURA_CASTER:Enable()
			F.DD_TRACKER_AURA_CASTER:SelectClear()
		elseif value == HDH_TRACKER.TYPE.HEALTH then
			F.DD_TRACKER_UNIT:Disable()
			F.DD_TRACKER_AURA_CASTER:Disable()
			F.DD_TRACKER_AURA_FILTER:Disable()
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
		local traitList = F.DD_TRACKER_TRAIT:GetSelectedValue()
		local caster = F.DD_TRACKER_AURA_CASTER:GetSelectedValue()
		local filter = F.DD_TRACKER_AURA_FILTER:GetSelectedValue()
		local trackerObj
		local id

		name = UTIL.Trim(name)
		if not name or string.len(name) <= 0 then
			main.Dialog:AlertShow(L.PLEASE_INPUT_NAME) return 
		end
		if not type then
			main.Dialog:AlertShow(L.PLEASE_SELECT_TYPE) return 
		end

		if F.DD_TRACKER_UNIT:IsEnabled() and not unit then
			main.Dialog:AlertShow(L.PLEASE_SELECT_UNIT) return 
		end

		if F.DD_TRACKER_AURA_FILTER:IsEnabled() and not filter then
			main.Dialog:AlertShow(L.PLEASE_SELECT_AURA_FILTER) return 
		end

		if F.DD_TRACKER_AURA_CASTER:IsEnabled() and not caster then
			main.Dialog:AlertShow(L.PLEASE_SELECT_AURA_CASTER) return 
		end

		if not traitList or #traitList == 0 then
			main.Dialog:AlertShow(L.PLEASE_SELECT_TRAIT) return 
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
		main:LoadTraits()
		main:LoadTrackerList(curTraits) 
		local index = main:GetTrackerIndex(id) -- LoadTrackerList 이후에 호출 되어야함 순서 중요 !
		if not index then
			main:LoadTrackerList()
			index = main:GetTrackerIndex(id)
			F.DD_TRAIT:SetSelectedIndex(1)
		else
			F.DD_TRAIT:SetSelectedValue(curTraits)
		end
		main:ChangeBody(BODY_ELEMENTS, index)

		if not main.DIALOG_SELECT_DISPLAY_TYPE then
			main.DIALOG_SELECT_DISPLAY_TYPE = CreateFrame("Frame", main:GetName().."DialogSelectDisplayType", main, "HDH_AT_DialogSelectDisplayTypeTemplate")

			main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton1:SetScript("OnClick", function(self) 
				self:GetParent().CheckButton2:SetChecked(false)
			end)

			main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton2:SetScript("OnClick", function(self) 
				self:GetParent().CheckButton1:SetChecked(false)
			end)
		end

		-- 트래커 고유 설정 변경해야하는 트래커 유형
		if not perType and (className == "HDH_COMBO_POINT_TRACKER" or className == "HDH_ESSENCE_TRACKER" or className == "HDH_DK_RUNE_TRACKER") then
			main.DIALOG_SELECT_DISPLAY_TYPE.HeaderText:SetText(L.PLEASE_SELECT_DISPLAY_TYPE)
			main.DIALOG_SELECT_DISPLAY_TYPE.DescIconText:SetText(L.DESC_CONFIG_ICON)
			main.DIALOG_SELECT_DISPLAY_TYPE.DescBarText:SetText(L.DESC_CONFIG_BAR)
			main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton1.Text:SetText(L.USE_DISPLAY_ICON) 
			main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton2.Text:SetText(L.USE_DISPLAY_BAR) 

			main.DIALOG_SELECT_DISPLAY_TYPE.Button:SetScript("OnClick", function(self)
				local trackerId = self:GetParent().trackerId
				if self:GetParent().CheckButton1:GetChecked() then
					DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON)
				else
					DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_BAR)
				end

				HDH_TRACKER.InitVaribles()
				self:GetParent():Hide()

				if HDH_TRACKER.ENABLE_MOVE then
					HDH_TRACKER.SetMoveAll(false)
					HDH_TRACKER.SetMoveAll(true)
				end
			end)

			main.DIALOG_SELECT_DISPLAY_TYPE.trackerId = id
			local color = trackerObj.POWER_INFO[type].color
			local texture = trackerObj.POWER_INFO[type].texture
			for i = 1, 5 do
				_G[ (main.DIALOG_SELECT_DISPLAY_TYPE:GetName() .. "Texture".. i) ]:SetTexture(texture)
				if i >= 3 then
					_G[ (main.DIALOG_SELECT_DISPLAY_TYPE:GetName() .. "TextureBorder".. i) ]:SetVertexColor(unpack(color))
					_G[ (main.DIALOG_SELECT_DISPLAY_TYPE:GetName() .. "Bar".. i) ]:SetVertexColor(unpack(color))
				end
				_G[main.DIALOG_SELECT_DISPLAY_TYPE:GetName().."Bar"..i]:Show()
				_G[main.DIALOG_SELECT_DISPLAY_TYPE:GetName().."Texture"..i]:Show()
				_G[ (main.DIALOG_SELECT_DISPLAY_TYPE:GetName() .. "TextureBorder".. i) ]:Show()
			end

			main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton1:SetChecked(true)
			main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton2:SetChecked(false)
			main.DIALOG_SELECT_DISPLAY_TYPE:Show()
		else
			if F.BODY.CONFIG_TRACKER.is_creation and className ~= "HDH_HEALTH_TRACKER" and className ~= "HDH_POWER_TRACKER" and className ~= "HDH_STAGGER_TRACKER" and className ~= "HDH_ENH_MAELSTROM_TRACKER" then
				main.DIALOG_SELECT_DISPLAY_TYPE.HeaderText:SetText(L.PLEASE_SELECT_CONFIG_TYPE)
				main.DIALOG_SELECT_DISPLAY_TYPE.DescIconText:SetText(L.DESC_USE_GLOBAL_CONFIG)
				main.DIALOG_SELECT_DISPLAY_TYPE.DescBarText:SetText(L.DESC_USE_SEVERAL_CONFIG)
				main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton1.Text:SetText(L.USE_GLOBAL_CONFIG) 
				main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton2.Text:SetText(L.USE_SEVERAL_CONFIG)
				main.DIALOG_SELECT_DISPLAY_TYPE.trackerId = id

				for i = 1, 5 do
					_G[main.DIALOG_SELECT_DISPLAY_TYPE:GetName().."Bar"..i]:Hide()
					_G[main.DIALOG_SELECT_DISPLAY_TYPE:GetName().."Texture"..i]:Hide()
					_G[ (main.DIALOG_SELECT_DISPLAY_TYPE:GetName() .. "TextureBorder".. i) ]:Hide()
				end

				main.DIALOG_SELECT_DISPLAY_TYPE.Button:SetScript("OnClick", function(self)
					local trackerId = self:GetParent().trackerId
					if self:GetParent().CheckButton2:GetChecked() then
						DB:CopyGlobelToTracker(trackerId)
					end

					HDH_TRACKER.InitVaribles()
					self:GetParent():Hide()

					if HDH_TRACKER.ENABLE_MOVE then
						HDH_TRACKER.SetMoveAll(false)
						HDH_TRACKER.SetMoveAll(true)
					end
				end)

				main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton1:SetChecked(true)
				main.DIALOG_SELECT_DISPLAY_TYPE.CheckButton2:SetChecked(false)
				main.DIALOG_SELECT_DISPLAY_TYPE:Show()
			else
				HDH_TRACKER.InitVaribles()
				if HDH_TRACKER.ENABLE_MOVE then
					HDH_TRACKER.SetMoveAll(false)
					HDH_TRACKER.SetMoveAll(true)
				end
			end
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
			main:LoadTrackerList(trait)
			main:ChangeBody(BODY_TRACKER_NEW)
			HDH_TRACKER.InitVaribles()

			if HDH_TRACKER.ENABLE_MOVE then
				HDH_TRACKER.SetMoveAll(false)
				HDH_TRACKER.SetMoveAll(true)
			end
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
				HDH_TRACKER.InitVaribles()
				main.Dialog:AlertShow(L.ALRET_CONFIRM_COPY:format(copyName))

				if HDH_TRACKER.ENABLE_MOVE then
					HDH_TRACKER.SetMoveAll(false)
					HDH_TRACKER.SetMoveAll(true)
				end
			else
				main.Dialog:AlertShow(L.PLEASE_INPUT_NAME)

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
		if value ~= newValue then
			F.BTN_PREV_NEXT.Value:SetText(newValue)
			DB:SwapTracker(value, newValue)
			HDH_TRACKER.InitVaribles()
			main:LoadTrackerList(main:GetCurTraits())
			main:ChangeBody(BODY_TRACKER_EDIT, main:GetTrackerIndex(newValue))
		end
		if HDH_TRACKER.ENABLE_MOVE then
			HDH_TRACKER.SetMoveAll(false)
			HDH_TRACKER.SetMoveAll(true)
		end

	elseif self == F.BTN_PREV_NEXT.BtnNext then
		local maxValue = #DB:GetTrackerIds()
		local value = tonumber(F.BTN_PREV_NEXT.Value:GetText())
		local newValue = min(value + 1, maxValue)
		if newValue ~= value then
			F.BTN_PREV_NEXT.Value:SetText(newValue)
			DB:SwapTracker(value, newValue)
			HDH_TRACKER.InitVaribles()
			main:LoadTrackerList(main:GetCurTraits())
			main:ChangeBody(BODY_TRACKER_EDIT, main:GetTrackerIndex(newValue))
		end

		if HDH_TRACKER.ENABLE_MOVE then
			HDH_TRACKER.SetMoveAll(false)
			HDH_TRACKER.SetMoveAll(true)
		end

	elseif self == F.BODY.CONFIG_DETAIL.BTN_SAVE then
		local trackerId = F.BODY.CONFIG_DETAIL.trackerId
		local elemIdx = F.BODY.CONFIG_DETAIL.elemIdx
		local mode = F.BODY.CONFIG_DETAIL.mode

		if mode == BODY_DETAIL_GLOW then
			local checkedIdx, condition, glowValue
			for idx, cd in ipairs(F.BODY.CONFIG_DETAIL.GLOW.CB_LIST) do
				if cd[1]:GetChecked() then
					checkedIdx = idx
					condition = cd[2] and cd[2]:GetSelectedValue()
					glowValue = cd[3] and UTIL.Trim(cd[3]:GetText())
				end
			end
			if checkedIdx then
				if checkedIdx > 1 and (not glowValue or string.len(glowValue) == 0) then
					main.Dialog:AlertShow(L.ALERT_PLEASE_INPUT_GLOW_VALUE)
					return
				end
				DB:UpdateTrackerElementGlow(trackerId, elemIdx, checkedIdx, condition, glowValue)
			else
				DB:UpdateTrackerElementGlow(trackerId, elemIdx, DB.GLOW_CONDITION_NONE, nil, nil)
			end
			HDH_TRACKER.InitIconFrame(trackerId)
			if main:GetCurTrackerId() == trackerId then
				main:LoadTrackerElementConfig(trackerId, elemIdx, elemIdx)
			end
			main.Dialog:AlertShow(L.SAVED_CONFIG)

		elseif mode == BODY_DETAIL_DISPLAY then
			local checkbutton = F.BODY.CONFIG_DETAIL.DISPLAY.checkbutton
			local value = DB.SPELL_ALWAYS_DISPLAY
			local spellId, isItem, traitIconHideMode
			if F.BODY.CONFIG_DETAIL.DISPLAY.CB1:GetChecked() then
				value = DB.SPELL_ALWAYS_DISPLAY
			elseif F.BODY.CONFIG_DETAIL.DISPLAY.CB2:GetChecked() then
				value = F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:GetSelectedValue()
			else
				value = F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:GetSelectedValue() + 2
			end

			isItem = F.BODY.CONFIG_DETAIL.DISPLAY.EB_CONNECT_TRAIT:GetIsItem()

			-- {DB.SPELL_HIDE_AS_SPACE, HDH_AT_L.USE_SPACE},
			-- {DB.SPELL_HIDE, HDH_AT_L.DONT_USE_SPACE}

			if F.BODY.CONFIG_DETAIL.DISPLAY.CB_LEARNED_TRAIT2:GetChecked() then
				spellId = F.BODY.CONFIG_DETAIL.DISPLAY.EB_CONNECT_TRAIT:GetValue()
				spellId, isItem = main:SetSearchEdit(F.BODY.CONFIG_DETAIL.DISPLAY.EB_CONNECT_TRAIT, spellId, isItem)
				if spellId == nil then
					return 
				end
				traitIconHideMode = F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE_UNLEARNED_TRAIT:GetSelectedValue()
			end

			DB:UpdateTrackerElementDisplay(trackerId, elemIdx, value, spellId, isItem, traitIconHideMode)
			HDH_TRACKER.InitIconFrame(trackerId)

			local ui = DB:GetTrackerUI((DB:hasTrackerUI(trackerId) and trackerId) or nil)
			if ui.common.order_by ~= DB.ORDERBY_REG and value == DB.SPELL_HIDE_AS_SPACE then
				main.Dialog:AlertShow(L.SAVED_CONFIG_WARN_DONT_REG_ORDER)
			else
				main.Dialog:AlertShow(L.SAVED_CONFIG)
			end
		end

	elseif self == F.BODY.CONFIG_DETAIL.BTN_CLOSE then
		main:ChangeBody(BODY_ELEMENTS)

	elseif self == F.BODY.CONFIG_UI.BTN_EXPORT_STRING then
		local list = main.UI_TAB[9].content.List
		local exportTracker = {}
		local tracker
		for _, item in ipairs(list) do
			if not item.id then break end

			if item:GetChecked() then
				tracker = DB:GetTracker(item.id)
				tracker = UTIL.Deepcopy(tracker)
				tracker.trait = item.trait
				table.insert(exportTracker, {
					tracker = tracker, 
					ui = UTIL.Deepcopy((DB:GetTrackerUI(item.id) or DB:GetTrackerUI()))
				})
			end
		end
		exportTracker.version = DB:GetVersion()
		exportTracker.adoon_version = C_AddOns.GetAddOnMetadata("HDH_AuraTracker", "Version")

		if #exportTracker > 0 then
			local data = WeakAuraLib_TableToString(exportTracker, true)
			F.BODY.CONFIG_UI.ED_EXPORT_STRING:SetText(data)
			main.Dialog:AlertShow(L.DIALOG_CREATE_SHARE_STRING)
		else
			main.Dialog:AlertShow(L.PLEASE_SELECT_TRACKER_FOR_EXPORT)
		end

	elseif self == F.BODY.CONFIG_UI.BTN_IMPORT_STRING then
		local data = F.BODY.CONFIG_UI.ED_IMPORT_STRING:GetText()
		data = WeakAuraLib_StringToTable(data, true)
		if not data then
			main.Dialog:AlertShow(L.SHARE_STRING_IS_WRONG)
			return 
		end

		if not DB:VaildationProfile(data) then
			local adoon_version = data.adoon_version or "Unknown"
			main.Dialog:AlertShow(L.NOT_COMPATIBLE_DB_VERSION:format(adoon_version))
			return 
		end

		main.Dialog:AlertShow(L.DO_YOU_WANT_IMPORT_PROFILE, main.Dialog.DLG_TYPE.YES_NO, function() 	
			local data = F.BODY.CONFIG_UI.ED_IMPORT_STRING:GetText()
			data = WeakAuraLib_StringToTable(data, true)
			DB:AppendProfile(GET_TRACKER_TYPE_NAME, data)
			ReloadUI()
		end)

	elseif self == F.BODY.CONFIG_DETAIL.ETC.CUSTOM_BTN_SEARCH then
		local trackerId = F.BODY.CONFIG_DETAIL.trackerId
		local elemIdx = F.BODY.CONFIG_DETAIL.elemIdx
		local spell = F.BODY.CONFIG_DETAIL.ETC.CUSTOM_EB_SPELL:GetText()
		local isItem = F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CB_IS_ITEM:GetChecked()
		spell = UTIL.Trim(spell)

		if not spell or string.len(spell) == 0 then
			main.Dialog:AlertShow(L.PLEASE_INPUT_ID) return 
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
				main.Dialog:AlertShow(L.PLEASE_INPUT_VALUE)
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
				main.Dialog:AlertShow(L.PLEASE_INPUT_MINMAX_VALUE)
				return
			end
		elseif self:GetParent().ButtonDel == self then
			table.remove(values, index)
		end

		DB:SetTrackerElementSplitValues(trackerId, elemIdx, values)
		main:LoadDetailFrame(BODY_DETAIL_ETC, trackerId, elemIdx)
		HDH_TRACKER.InitVaribles(trackerId)

		if HDH_TRACKER.ENABLE_MOVE then
			local t = HDH_TRACKER.Get(trackerId)
			if t then
				t:SetMove(false)
				t:SetMove(true)
			end
		end

	elseif self == F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_BTN_APPLY then
		local trackerId = F.BODY.CONFIG_DETAIL.trackerId
		local elemIdx = F.BODY.CONFIG_DETAIL.elemIdx
		local innerCooldown =  F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_CD:GetText()
		local innerSpellId = F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_SPELL_ID:GetText()

		F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_CD:ClearFocus()
		F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_SPELL_ID:ClearFocus()
		innerCooldown = UTIL.Trim(innerCooldown)
		if not innerCooldown or string.len(innerCooldown) == 0 then
			main.Dialog:AlertShow(L.PLEASE_INPUT_INNER_TIME)
			return
		end

		innerSpellId = UTIL.Trim(innerSpellId)
		if not innerSpellId or string.len(innerSpellId) == 0 then
			main.Dialog:AlertShow(L.PLEASE_INPUT_ID) 
			return 
		end

		local name, id, texture = UTIL.GetInfo(innerSpellId, false)
		if not id then
			main.Dialog:AlertShow(L.NOT_FOUND_ID:format(innerSpellId)) 
			return 
		end

		DB:UpdateTrackerElementInnerCooldown(trackerId, elemIdx, DB.INNER_CD_BUFF, innerSpellId, innerCooldown)
		HDH_TRACKER.InitVaribles(trackerId)
		main.Dialog:AlertShow(L.SAVED_CONFIG)
	
	elseif self == F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_BTN_DELETE then
		local trackerId = F.BODY.CONFIG_DETAIL.trackerId
		local elemIdx = F.BODY.CONFIG_DETAIL.elemIdx
		main.Dialog:AlertShow(L.DO_YOU_WANT_TO_DELETE_THIS_ITEM:format(L.INNER_COOLDOWN_ITEM_CONFIG), main.Dialog.DLG_TYPE.YES_NO,
			function()
				F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_CD:SetText("")
				F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_SPELL_ID:SetText("")
				F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_CD:ClearFocus()
				F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_SPELL_ID:ClearFocus()
				DB:UpdateTrackerElementInnerCooldown(trackerId, elemIdx, nil, nil, nil)
				HDH_TRACKER.InitVaribles(trackerId)

				if HDH_TRACKER.ENABLE_MOVE then
					HDH_TRACKER.SetMoveAll(false)
					HDH_TRACKER.SetMoveAll(true)
				end
			end,
			function()
				F.BODY.CONFIG_UI.SW_CONFIG_MODE:SetSelectedIndex(DB.USE_GLOBAL_CONFIG)
			end
		)
	end
	
end

function HDH_AT_OnClick_ButtomTapButton(self)
	if self.index == 1 then
		GetMainFrame():ChangeBody(BODY_TRACKER_EDIT, nil, nil, nil)
	elseif self.index == 2 then
		GetMainFrame():ChangeBody(BODY_ELEMENTS, nil, nil, nil)
	else
		GetMainFrame():ChangeBody(BODY_UI, nil, nil, nil)
	end
	
end

function HDH_AT_OnCancelColorPicker()
	local r,g,b,a = unpack(ColorPickerFrame.previousValues);
	a = (ColorPickerFrame.hasOpacity and a) or nil;
end

---------------------------------------------------------
-- HDH_AT_ConfigFrame
---------------------------------------------------------

function HDH_AT_ConfigFrameMixin:AddTalentButton(name, type, unit, idx)

end

function HDH_AT_ConfigFrameMixin:GetTraits(talentId)
	local ret = {}
	local id, name
	talentId = talentId or HDH_AT_UTIL.GetSpecialization() --ClassTalentFrame.TalentsTab.LoadoutDropDown:GetSelectionID()
	local ids = HDH_AT_UTIL.GetConfigIDsBySpecID(talentId)
	for i, v in pairs(ids) do
		id = v
		name = HDH_AT_UTIL.GetConfigInfo(v).name
		ret[i] = {id, name}
	end
	return ret
end

function HDH_AT_ConfigFrameMixin:GetTalentList(bigImage)
	local ret = {}
	local id, name, icon, texture
	if bigImage == nil then
		bigImage = false
	end
	for i = 1, MAX_TALENT_TABS do
        id, name, _, icon = HDH_AT_UTIL.GetSpecializationInfo(i)
		if id == nil then
			break
		end
		if bigImage then
			texture = SPEC_FORMAT_STRINGS[id]
			if texture then
				icon = SPEC_TEXTURE_FORMAT:format(texture)
			end
		end
		ret[i] = {id, name, icon}
	end
	return ret
end

function HDH_AT_ConfigFrameMixin:GetCurTraits()
	return self.F.DD_TRAIT:GetSelectedValue()
end

function HDH_AT_ConfigFrameMixin:GetCurTrackerId()
	return self.trackerId 
end

function HDH_AT_ConfigFrameMixin:DeleteTrackerElement(elem, trackerId, elemIdx)
	DB:DeleteTrackerElement(trackerId, elemIdx)
	local t = HDH_TRACKER.Get(trackerId)
	if t then
		t:InitIcons()
	end
	self:LoadTrackerElementConfig(trackerId, elemIdx)
end

function HDH_AT_ConfigFrameMixin:AddTrackerElement(elem, trackerId, elemIdx)
	local trackerObj
	local rowIdx, key, id, name, texture, display, isGlow, isValue, isItem = elem:Get()
	display = (DB:GetTrackerElement(trackerId, elemIdx) and DB:GetTrackerElementDisplay(trackerId, elemIdx)) or nil
	if not display then
		display = DB.SPELL_ALWAYS_DISPLAY
	end
	
	key = UTIL.Trim(key)
	if not key or string.len(key) == 0 then
		self.Dialog:AlertShow(L.PLEASE_INPUT_ID)
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
	DB:SetTrackerElement(trackerId, elemIdx, key, id, name, texture, display, isValue, isItem)
	self:LoadTrackerElementConfig(trackerId, elemIdx)

	if HDH_TRACKER.Get(trackerId).type == HDH_TRACKER.TYPE.COOLDOWN or HDH_TRACKER.Get(trackerId).type == HDH_TRACKER.TYPE.TOTEM then
		local equipSlot
		local reg = false
		if isItem then
			equipSlot = select(9, GetItemInfo(id))
			if equipSlot and equipSlot ~= "" and equipSlot ~= "INVTYPE_NON_EQUIP_IGNORE" then 
				reg = true
			end
		else
			reg = true
		end
		if reg then
			DB:UpdateTrackerElementDisplay(trackerId, elemIdx, display, id, isItem,  DB.SPELL_HIDE)
		end
	end

	trackerObj = HDH_TRACKER.Get(trackerId)
	if trackerObj then
		trackerObj:InitIcons()
	end
end

function HDH_AT_ConfigFrameMixin:LoadTraits()
	local ddm = self.F.DD_TRACKER_TRAIT
	local itemValues = {}
	local itemTemplates = {}
	local id, name, texture
	local F = self.F
	local ids = DB:GetTrackerIds()
	local traitList = {}
	local talentID, talentName, traitName, icon
	local cacheTraits = {}
	local unusedTracker = 0
	local traits
	local useAtlas = select(4, GetBuildInfo()) >= 100000

	-- Tracker 목록 생성 및 트랜짓이 없는 않는 트래커 확인
	traitList[#traitList+1] = {DDM_TRACKER_ALL, L.ALL_LIST, nil, 0}
	for _, id in ipairs(ids) do
		traits = select(7, DB:GetTrackerInfo(id))
		if #traits > 0 then
			for idx, traitID in ipairs(traits) do
				if not cacheTraits[traitID] then  
					talentID = GetTalentIdByTraits(traitID)
					if talentID then
						cacheTraits[traitID] = true
						talentName, _, icon = select(2, HDH_AT_UTIL.GetSpecializationInfoByID(talentID))
						traitName = UTIL.GetTraitsName(traitID)
						texture = SPEC_FORMAT_STRINGS[talentID]
						if useAtlas and texture then
							icon = SPEC_TEXTURE_FORMAT:format(texture)
						end	
						traitList[#traitList+1] = {traitID, STR_TRAIT_FORMAT:format(traitName or "", talentName or ""), icon, talentID}
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
		traitList[#traitList+1] = {DDM_TRACKER_UNUSED, L.UNUSED_LIST, 0 , 0}
		self.Dialog:AlertShow(L.ALERT_UNUSED_LIST:format(unusedTracker))
	end

	F.DD_TRAIT:UseAtlasSize(useAtlas)
	table.sort(traitList, function(a, b) 
		if (a[4] < b[4]) then
			return true
		elseif (a[4] > b[4]) then
			return false
		else
			return (a[1] < b[1]) 
		end
	end)

	HDH_AT_DropDown_Init(F.DD_TRAIT, traitList, HDH_AT_OnSelected_Dropdown , nil, "HDH_AT_DropDownTrackerItemTemplate") --	HDH_AT_DropDownTrackerItemTemplate")

	for _, item in ipairs(self:GetTalentList(useAtlas)) do
		id, name, icon = unpack(item)
		if name == nil then break end
		itemValues[#itemValues+1] = {-1, name, icon}
		itemTemplates[#itemTemplates+1] = "HDH_AT_SplitItemTemplate"
		itemValues[#itemValues+1] = {id, L.ALWAYS_USE, nil}
		itemTemplates[#itemTemplates+1] = "HDH_AT_CheckButtonItemTemplate"
		for _, trait in ipairs(self:GetTraits(id)) do
			itemValues[#itemValues+1] = trait
			itemTemplates[#itemTemplates+1] = "HDH_AT_CheckButtonItemTemplate"
		end
	end
	ddm:UseAtlasSize(useAtlas)
	HDH_AT_DropDown_Init(ddm, itemValues, HDH_AT_OnSelected_Dropdown, nil, itemTemplates, true, true)
end

function HDH_AT_ConfigFrameMixin:UpdateTraitsSelector(idx)
	local ddm = self.F.DD_TRACKER_TRAIT
	local itemFrame
	local startIndex = 1
	local endIndex = #ddm.item
	local isAlwaysChecked = false
	if idx then
		for i = idx, 1, -1 do
			if ddm.item[i].value == -1 then
				startIndex = i + 1
				break
			end
		end

		for i = idx, endIndex do
			if ddm.item[i].value == -1 then
				endIndex = i - 1
				break
			end
		end

		if startIndex ~= idx then
			ddm.item[startIndex].CheckButton:SetChecked(false)
		end
	end
	
	for i = startIndex, endIndex do
		itemFrame = ddm.item[i]
		if itemFrame.value then
			if (HDH_AT_UTIL.GetSpecializationInfoByID(itemFrame.value)) then
				isAlwaysChecked = itemFrame.CheckButton:GetChecked()
			else
				if itemFrame.value ~= -1 then
					if isAlwaysChecked then
						itemFrame.CheckButton:SetChecked(false)
					end
				end
			end
			itemFrame:Show()
		else
			itemFrame:Hide()
		end
	end
end

function HDH_AT_ConfigFrameMixin:GetElementFrame(listFrame, trackerId, index)
	local row = listFrame.list[index]
	index = tonumber(index)
	if not row then
		row = CreateFrame("Button",(listFrame:GetName().."Row"..index), listFrame, "HDH_AT_RowTemplate")
		row:SetParent(listFrame)
		row:SetOnClickHandler(function(self)
			if HDH_AT_DB.show_latest_spell and not GetMainFrame().F.LATEST_SPELL_WINDOW:IsShown() then
				GetMainFrame().F.LATEST_SPELL_WINDOW:Show()
			end
		end)
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

function HDH_AT_ConfigFrameMixin:SetSearchEdit(element, searchValue, searchisItem, backup)
	local name, id, texture, isItem
	local main = GetMainFrame()
	searchValue = HDH_AT_UTIL.Trim(searchValue) or ""
	if string.len(searchValue) == 0 then
		main.Dialog:AlertShow(L.PLEASE_INPUT_ID)
		element:SetName("")
		element:SetDefaultIcon()
		return nil
	else
		name, id, texture, isItem = HDH_AT_UTIL.GetInfo(searchValue, searchisItem)
		if name then
			element:SetValue(id)
			element:SetName(name)
			element:SetIcon(texture)
			element:SetIsItem(isItem)

			if backup then
				element:SetBackup(id, name, texture, isItem)
			end
		else
			main.Dialog:AlertShow(L.NOT_FOUND_ID:format(searchValue))
			element:SetName(searchValue or "")
			element:SetDefaultIcon()
			return nil
		end
	end
	return id, isItem
end

function HDH_AT_ConfigFrameMixin:LoadTrackerElementConfig(trackerId, startRowIdx, endRowIdx)
	local F = self.F
	local listFrame = F.BODY.CONFIG_TRACKER_ELEMENTS.CONTENTS
	if not listFrame.list then listFrame.list = {} end
	if not trackerId then return end
	local rowFrame
	local i = startRowIdx or 1
	local id, name, type, unit, aura_filter, aura_caster, trait = DB:GetTrackerInfo(trackerId)
	local elemKey, elemId, elemName, texture, display, glowType, isValue, isItem, readOnly
	if (type ~= HDH_TRACKER.TYPE.BUFF and type ~= HDH_TRACKER.TYPE.DEBUFF and type ~= HDH_TRACKER.TYPE.TOTEM) or aura_filter == DB.AURA_FILTER_REG then
		if startRowIdx and endRowIdx and (startRowIdx > endRowIdx) then return end
		while true do
			rowFrame = self:GetElementFrame(listFrame, trackerId, i)-- row가 없으면 생성하고, 있으면 그거 재활용
			elemKey, elemId, elemName, texture, display, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
			readOnly = DB:IsReadOnlyTrackerElement(trackerId, i)
			display = (display == DB.SPELL_ALWAYS_DISPLAY)
			glowType = (((glowType and glowType ~= DB.GLOW_CONDITION_NONE) and true) or false)
			rowFrame.index = i
			if not rowFrame:IsShown() then rowFrame:Show() end
			rowFrame:ClearAllPoints();
			if i == 1 	then rowFrame:SetPoint("TOPLEFT",listFrame,"TOPLEFT") 
						else rowFrame:SetPoint("TOPLEFT",listFrame,"TOPLEFT", 0, (-rowFrame:GetHeight()*(i-1))) end
			
			if elemKey then
				rowFrame:Set(i, elemKey, elemId, elemName, texture, display, glowType, isValue, isItem, readOnly)
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

-- function HDH_AT_ConfigFrameMixin:GetSpell()
-- 	HDH_AT_UTIL.GetCacheSpellInfo(spellName)
-- end

function HDH_AT_ConfigFrameMixin:LoadTrackerListForExport()
	local content = self.UI_TAB[9].content
	local ids = DB:GetTrackerIds()
	local item, iconIndex
	local id, name, type, trait, icon
	local talentCache = {}
	local talentList = {}
	local talentID

	content.List = content.List or {}

	local label = self.F.BODY.CONFIG_UI.LABEL_EXPORT

	if not content.SelectAll then
		content.SelectAll = CreateFrame("Button", nil, label, "HDH_AT_CheckButton2Template")
		content.SelectAll:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -1)
		content.SelectAll:SetPoint("RIGHT", label, "RIGHT", 0, 0)
		content.SelectAll:SetHeight(20)
		content.SelectAll.Text:SetText(L.SELECT_ALL)
		content.SelectAll:SetScript("OnClick", function(self)
			local list = GetMainFrame().UI_TAB[9].content.List
			for _, comp in ipairs(list) do
				comp:SetChecked(self:GetChecked())
			end
		end)
	end

	content.SelectAll:SetChecked(false)

	for index, id in ipairs(ids) do
		if not content.List[index] then
			item = CreateFrame("Button", "HDH_AT_CheckButtonForExport"..index, content.SelectAll, "HDH_AT_CheckButtonForExportTemplate")
			item:SetPoint("TOPLEFT", content.SelectAll, "TOPLEFT", 0, -((index) * 22))
			item:SetPoint("RIGHT", content.SelectAll,"RIGHT", 0, 0)
			item:SetHeight(20)
			item:SetScript("OnClick", function(self)
				local list = GetMainFrame().UI_TAB[9].content.List
				local selectAll = GetMainFrame().UI_TAB[9].content.SelectAll
				local count = 0
				for _, comp in ipairs(list) do
					if comp:GetChecked() then count = count + 1 end
				end
				selectAll:SetChecked(count == #list)
			end)
			item.IconList = {item.Icon1, item.Icon2, item.Icon3, item.Icon4}
			content.List[index] = item
		end
		item = content.List[index]
		id, name, type, _, _, _, trait = DB:GetTrackerInfo(id)
		talentCache = {}
		talentList = {}
		for _, t in ipairs(trait) do
			talentID = GetTalentIdByTraits(t)
			icon = select(4, HDH_AT_UTIL.GetSpecializationInfoByID(talentID))
			if icon and not talentCache[talentID] then
				talentCache[talentID] = icon
				table.insert(talentList, icon)
			end
		end

		iconIndex = 0
		table.sort(talentList, function(a,b) return a > b end)
		for _, t in ipairs(talentList) do
			iconIndex = iconIndex + 1
			item.IconList[iconIndex]:SetTexture(t)
			item.IconList[iconIndex]:Show()
		end
		
		for i = iconIndex + 1 , 4 do
			item.IconList[i]:Hide()
		end
		
		item.Text:SetText(name.." ("..GET_TRACKER_TYPE_NAME[type]..")")
		item:SetChecked(false)
		item.id = id
		item.trait = talentList
		item:Show()
	end

	for i = #ids+1, #content.List do
		content.List[i]:Hide()
		item.id = nil
		item.trait = nil
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
	if id then
		F.BODY.CONFIG_DETAIL.TEXT:SetText(string.format('%s (ID: %s)',name, id))
	else
		F.BODY.CONFIG_DETAIL.TEXT:SetText(name)
	end
	F.BODY.CONFIG_DETAIL.mode = detailMode

	if detailMode == BODY_DETAIL_GLOW then
		if button ~= nil then
			F.BODY.CONFIG_DETAIL.GLOW.checkbutton = button
			F.BODY.CONFIG_DETAIL.GLOW.preCheck = not button:GetChecked()

			local glowType, glowCondition, glowValue = DB:GetTrackerElementGlow(trackerId, elemIdx)
			local match
			for idx, cd in ipairs(F.BODY.CONFIG_DETAIL.GLOW.CB_LIST) do
				match = idx == glowType
				F.BODY.CONFIG_DETAIL.GLOW.CB_LIST[idx][1]:SetChecked(match)
				if idx > 1 then
					F.BODY.CONFIG_DETAIL.GLOW.CB_LIST[idx][2]:SetSelectedIndex((match and glowCondition) or 1)
					F.BODY.CONFIG_DETAIL.GLOW.CB_LIST[idx][3]:SetText((match and glowValue) or "")
				end
			end
			F.BODY.CONFIG_DETAIL.GLOW.CB5:SetChecked(glowType == DB.GLOW_CONDITION_NONE)
			button:SetChecked(F.BODY.CONFIG_DETAIL.GLOW.preCheck)
			F.BODY.CONFIG_DETAIL.BTN_SAVE:Show()
			F.BODY.CONFIG_DETAIL.BTN_CLOSE:ClearAllPoints()
			F.BODY.CONFIG_DETAIL.BTN_CLOSE:SetPoint("BOTTOMLEFT", F.BODY.CONFIG_DETAIL.BTN_CLOSE:GetParent() ,"BOTTOM", 5, 5)
		end

	elseif detailMode == BODY_DETAIL_DISPLAY then
		if button ~= nil then
			F.BODY.CONFIG_DETAIL.DISPLAY.checkbutton = button
			F.BODY.CONFIG_DETAIL.DISPLAY.preCheck = not button:GetChecked()
			local display, connectSpellId, connectSpellIsItem, unlearnedHideMode = DB:GetTrackerElementDisplay(trackerId, elemIdx)
			if display == DB.SPELL_ALWAYS_DISPLAY then
				F.BODY.CONFIG_DETAIL.DISPLAY.CB1:SetChecked(true)
				F.BODY.CONFIG_DETAIL.DISPLAY.CB2:SetChecked(false)
				F.BODY.CONFIG_DETAIL.DISPLAY.CB3:SetChecked(false)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:SetSelectedIndex(2)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:Hide()
			elseif display == DB.SPELL_HIDE_TIME_OFF then
				F.BODY.CONFIG_DETAIL.DISPLAY.CB1:SetChecked(false)
				F.BODY.CONFIG_DETAIL.DISPLAY.CB2:SetChecked(true)
				F.BODY.CONFIG_DETAIL.DISPLAY.CB3:SetChecked(false)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:SetSelectedIndex(2)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:SetPoint("LEFT", F.BODY.CONFIG_DETAIL.DISPLAY.CB2,"RIGHT", 2,0)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:Show()
			elseif display == DB.SPELL_HIDE_TIME_OFF_AS_SPACE then
				F.BODY.CONFIG_DETAIL.DISPLAY.CB1:SetChecked(false)
				F.BODY.CONFIG_DETAIL.DISPLAY.CB2:SetChecked(true)
				F.BODY.CONFIG_DETAIL.DISPLAY.CB3:SetChecked(false)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:SetSelectedIndex(2)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:SetPoint("LEFT", F.BODY.CONFIG_DETAIL.DISPLAY.CB2,"RIGHT", 2,0)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:Show()
			elseif display == DB.SPELL_HIDE_TIME_ON then
				F.BODY.CONFIG_DETAIL.DISPLAY.CB1:SetChecked(false)
				F.BODY.CONFIG_DETAIL.DISPLAY.CB2:SetChecked(false)
				F.BODY.CONFIG_DETAIL.DISPLAY.CB3:SetChecked(true)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:SetSelectedIndex(2)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:SetPoint("LEFT", F.BODY.CONFIG_DETAIL.DISPLAY.CB3,"RIGHT", 2,0)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:Show()
			else -- display == DB.SPELL_HIDE_AS_SPACE
				F.BODY.CONFIG_DETAIL.DISPLAY.CB1:SetChecked(false)
				F.BODY.CONFIG_DETAIL.DISPLAY.CB2:SetChecked(false)
				F.BODY.CONFIG_DETAIL.DISPLAY.CB3:SetChecked(true)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:SetSelectedIndex(2)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:SetPoint("LEFT", F.BODY.CONFIG_DETAIL.DISPLAY.CB3,"RIGHT", 2,0)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:Show()
			end

			if connectSpellId then
				F.BODY.CONFIG_DETAIL.DISPLAY.CB_LEARNED_TRAIT1:SetChecked(false)
				F.BODY.CONFIG_DETAIL.DISPLAY.CB_LEARNED_TRAIT2:SetChecked(true)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE_UNLEARNED_TRAIT:Show()
				F.BODY.CONFIG_DETAIL.DISPLAY.LABEL_SW_HIDE_MODE_UNLEARNED_TRAIT:Show()
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE_UNLEARNED_TRAIT:SetSelectedIndex(unlearnedHideMode)
				F.BODY.CONFIG_DETAIL.DISPLAY.EB_CONNECT_TRAIT:Show()

				local spellID = self:SetSearchEdit(F.BODY.CONFIG_DETAIL.DISPLAY.EB_CONNECT_TRAIT, connectSpellId, connectSpellIsItem, true)
				if not spellID then
					F.BODY.CONFIG_DETAIL.DISPLAY.EB_CONNECT_TRAIT:Reset()
				end
			else
				F.BODY.CONFIG_DETAIL.DISPLAY.CB_LEARNED_TRAIT1:SetChecked(true)
				F.BODY.CONFIG_DETAIL.DISPLAY.CB_LEARNED_TRAIT2:SetChecked(false)
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE_UNLEARNED_TRAIT:Hide()
				F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE_UNLEARNED_TRAIT:SetSelectedIndex(2)
				F.BODY.CONFIG_DETAIL.DISPLAY.LABEL_SW_HIDE_MODE_UNLEARNED_TRAIT:Hide()
				F.BODY.CONFIG_DETAIL.DISPLAY.EB_CONNECT_TRAIT:Hide()
				F.BODY.CONFIG_DETAIL.DISPLAY.EB_CONNECT_TRAIT:Reset()
			end

			button:SetChecked(F.BODY.CONFIG_DETAIL.DISPLAY.preCheck)
			F.BODY.CONFIG_DETAIL.BTN_SAVE:Show()
			F.BODY.CONFIG_DETAIL.BTN_CLOSE:ClearAllPoints()
			F.BODY.CONFIG_DETAIL.BTN_CLOSE:SetPoint("BOTTOMLEFT", F.BODY.CONFIG_DETAIL.BTN_CLOSE:GetParent() ,"BOTTOM", 5, 5)
		end
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
		local obj = HDH_TRACKER.Get(trackerId)
		if obj.GetPowerMax and trackerType ~= HDH_TRACKER.TYPE.STAGGER then
			local max = obj:GetPowerMax()
			if max then
				splitbar:SetMinMaxValues(0, max)
			end
		else
			splitbar:SetMinMaxValues(0, 1)
		end

		-- Load Inner CD
		local innerType, innerSpellId, innerCooldown = DB:GetTrackerElementInnerCooldown(trackerId, elemIdx)
		F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_CD:SetText(innerCooldown or "")
		F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_SPELL_ID:SetText(innerSpellId or "")
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

			elseif type == HDH_TRACKER.TYPE.HEALTH then
				-- F.DD_TRACKER_UNIT:SetSelectedValue(unit)
				-- F.DD_TRACKER_UNIT:Enable()
				F.DD_TRACKER_UNIT:SelectClear()
				F.DD_TRACKER_UNIT:Disable()
				F.DD_TRACKER_AURA_CASTER:SelectClear()
				F.DD_TRACKER_AURA_FILTER:SelectClear()
				F.DD_TRACKER_AURA_CASTER:Disable()
				F.DD_TRACKER_AURA_FILTER:Disable()

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
			F.DD_TRACKER_TRAIT:SetSelectedValue(trait)
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
		F.DD_TRACKER_TRAIT:SelectClear()

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
			component.Text:SetPoint("TOPLEFT", 5, 0)
			component.Text:SetPoint("BOTTOMRIGHT", -10, 11)
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
		component:SetText(name) --STR_TRACKER_FORMAT:format(name, typeName, unitName)
		component.Tracker:SetText(STR_TRACKER_FORMAT:format(typeName, unitName))
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

local function OnMouseDown_LatestSpellItem(self)
	local main = GetMainFrame()
	main.draggingLatestSpell = true
	self:SetActive(true)
	self:SetMovable(true)
	self:StartMoving()
	-- self:SetScript("OnUpdate", OnUpdate_LatestSpellItem)
	self:SetParent(UIParent)
	self:SetFrameStrata("DIALOG")
	GameTooltip:Hide()
end

local function OnMouseUp_LatestSpellItem(self) -- here
	local main = GetMainFrame()
	local trackerId = main:GetCurTrackerId()
	local tracker = HDH_TRACKER.Get(trackerId)
	local className = (tracker and tracker:GetClassName()) or nil
	main.draggingLatestSpell = false
	self:SetMovable(false)
	self:StopMovingOrSizing()
	self:SetScript("OnUpdate", nil)

	if (className == "HDH_AURA_TRACKER" or className == "HDH_C_TRACKER" or className == "HDH_TT_TRACKER") then
		local left, bottom, w, h = main.F.BODY.CONFIG_TRACKER_ELEMENTS:GetBoundsRect()
		local curX, curY = self:GetCenter()

		if left <= curX and curX <= (left + w) and bottom <= curY and curY <= (bottom + h) then
			if main.F.BODY.CONFIG_TRACKER_ELEMENTS:IsShown() then
				local listFrame = main.F.BODY.CONFIG_TRACKER_ELEMENTS.CONTENTS
				local elemIdx = (DB:GetTrackerElementSize(trackerId) or 0) + 1
				local elem = listFrame.list[elemIdx]
				if elem then
					_G[elem:GetName().."EditBoxID"]:SetText(self.ID:GetText())
					_G[elem:GetName().."CheckButtonIsItem"]:SetChecked(self.isItem or false)
					main:AddTrackerElement(elem, trackerId, elemIdx)

					if HDH_TRACKER.ENABLE_MOVE then
						if tracker then
							tracker:SetMove(false)
							tracker:SetMove(true)
						end
					end
				end
			elseif main.bodyType == BODY_DETAIL_ETC then
				if main.DETAIL_ETC_TAB[3].content:IsShown() then -- inner cooldown
					main.F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_SPELL_ID:SetText(self.ID:GetText())
				elseif main.DETAIL_ETC_TAB[1].content:IsShown() then -- change texture
					main.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_EB_SPELL:SetText(self.ID:GetText())
					main.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_EB_SPELL:ClearFocus()
					HDH_AT_OnClick_Button(main.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_BTN_SEARCH) 
				end
			end
		end
	end
	main:UpdateLatest()
end

function HDH_AT_OnShow_LatestSpell(self)
	if self:GetParent():GetScript("OnEvent") == nil then
		self:GetParent():SetScript("OnEvent", self:GetParent().OnEvent)
		self:GetParent():RegisterEvent('UNIT_SPELLCAST_SENT')
		self:GetParent():RegisterEvent('BAG_UPDATE_COOLDOWN')
		self:GetParent():RegisterEvent('UNIT_AURA')
		self:GetParent():RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	end
	self:GetParent():UpdateLatest()
end

function HDH_AT_OnHide_LatestSpell(self)
	if not self:GetParent().F.LATEST_SPELL.CB_AUTO_POPUP:GetChecked() then
		self:GetParent():SetScript("OnEvent", nil)
		self:GetParent():UnregisterAllEvents()
	end
end

function HDH_AT_ConfigFrameMixin:UpdateLatest()
	if self.draggingLatestSpell then return end
	local f = self.F.LATEST_SPELL
	f.list = f.list or {}
	f.buffQueue = f.buffQueue or UTIL.CreateQueue(50)
	f.buffQueue.cache = f.buffQueue.cache or {}
	f.buffQueue.activeSpell = f.buffQueue.activeSpell or {}

	f.debuffQueue = f.debuffQueue or UTIL.CreateQueue(50)
	f.debuffQueue.cache = f.debuffQueue.cache or {}
	f.debuffQueue.activeSpell = f.debuffQueue.activeSpell or {}

	f.skillQueue = f.skillQueue or UTIL.CreateQueue(50)
	f.skillQueue.cache = f.skillQueue.cache or {}
	f.skillQueue.activeSpell = f.skillQueue.activeSpell or {}

	f.totemQueue = f.totemQueue or UTIL.CreateQueue(50)
	f.totemQueue.cache = f.totemQueue.cache or {}
	f.totemQueue.activeSpell = f.totemQueue.activeSpell or {}

	local item
	local height = 25
	local list = f.list
	local trackerId = self:GetCurTrackerId()
	local tracker = HDH_TRACKER.Get(trackerId)
	local className = (tracker and tracker:GetClassName()) or nil
	local unitList = {"player", "target", "focus", "pet"}
	local filterList= {"HELPFUL","HARMFUL"}
	local aura

	if tracker == nil then return end

	for _, unit in pairs(unitList) do
		if UnitExists(unit) then
			for i = 1, 40 do 
				aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
				if not aura then break end
				if f.buffQueue.activeSpell[aura.spellId] == nil then
					if f.buffQueue.cache[aura.spellId] then
						local size = f.buffQueue:GetSize()
						for j = 1, size do
							if f.buffQueue:Get(j)[3] == aura.spellId then
								f.buffQueue:Pop(j)
								break
							end
						end
					end
					f.buffQueue:Push({aura.icon, aura.name, aura.spellId, "|cff55ff55"..L.BUFF.."|r", false, unit, i, "HELPFUL"})
					f.buffQueue.cache[aura.spellId] = true
				end
				f.buffQueue.activeSpell[aura.spellId] = true
			end
		end
	end

	for _, unit in pairs(unitList) do
		if UnitExists(unit) then
			for i = 1, 40 do 
				aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
				if not aura then break end
				if f.debuffQueue.activeSpell[aura.spellId] == nil then
					if f.debuffQueue.cache[aura.spellId] then
						local size = f.debuffQueue:GetSize()
						for j = 1, size do
							if f.debuffQueue:Get(j)[3] == aura.spellId then
								f.debuffQueue:Pop(j)
								break
							end
						end
					end
					f.debuffQueue:Push({aura.icon, aura.name, aura.spellId, "|cffff5555"..L.DEBUFF.."|r", false, unit, i, "HARMFUL"})
					f.debuffQueue.cache[aura.spellId] = true
				end
				f.debuffQueue.activeSpell[aura.spellId] = true
			end
		end
	end

	local name, id, icon, isItem
	for _, id in pairs(self.cacheCastSpell) do
		name, _, icon = HDH_AT_UTIL.GetInfo(id)
		if f.skillQueue.activeSpell[id] == nil then
			if f.skillQueue.cache[id] then
				local size = f.skillQueue:GetSize()
				for i = 1, size do
					if f.skillQueue:Get(i)[3] == id then
						f.skillQueue:Pop(i)
						break
					end
				end
			end
			f.skillQueue:Push({icon, name, id, "|cffffaa00"..L.SKILL.."|r"})
			f.skillQueue.cache[id] = true
		end
		f.skillQueue.activeSpell[id] = true
	end
	self.cacheCastSpell = {}

	for _, id in pairs(self.cacheUesdItem) do
		isItem = not tracker:IsLearnedSpellOrEquippedItem(id)
		name, _, icon = HDH_AT_UTIL.GetInfo(id, true)
		if f.skillQueue.activeSpell[id] == nil then
			if f.skillQueue.cache[id] then
				local size = f.skillQueue:GetSize()
				for i = 1, size do
					if f.skillQueue:Get(i)[3] == id then
						f.skillQueue:Pop(i)
						break
					end
				end
			end
			f.skillQueue:Push({icon, name, id, "|cffB231FF"..L.ITEM.."|r", true})
			f.skillQueue.cache[id] = true
		end
		f.skillQueue.activeSpell[id] = true
	end
	self.cacheUesdItem = {}

	local haveTotem, name, startTime, duration, icon, id, dbName
	for i =1, MAX_TOTEMS do
		haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
		if haveTotem then
			if name ~= L.UNKNOWN_TOTEM then 
				dbName, id, _ = HDH_AT_UTIL.GetInfo(name)
				if dbName then 
					name = dbName
				else
					id = HDH_TT_TRACKER.AdjustSpell[name]
					name, id, _ = HDH_AT_UTIL.GetInfo(id)
				end
				if not id then 
					if string.len(UTIL.Trim(name) or "") > 0 then
						id = name
					end
				end

				if id then 
					if f.totemQueue.activeSpell[id] == nil then
						if f.totemQueue.cache[id] then
							local size = f.totemQueue:GetSize()
							for j = 1, size do
								if f.totemQueue:Get(j)[3] == id then
									f.totemQueue:Pop(j)
									break
								end
							end
						end
						f.totemQueue:Push({icon, name, id, "|cff5555ff"..L.TOTEM.."|r"})
						f.totemQueue.cache[id] = true
					end
					f.totemQueue.activeSpell[id] = true
				end
			end
		end
	end

	if className == "HDH_AURA_TRACKER" then
		if tracker.type == HDH_TRACKER.TYPE.BUFF then
			f.queue = f.buffQueue 
		else
			f.queue = f.debuffQueue 
		end
	elseif className == "HDH_C_TRACKER" then
		f.queue = f.skillQueue 
		if self.bodyType == BODY_DETAIL_ETC and self.DETAIL_ETC_TAB[3].content:IsShown() then
			for i=1, #f.buffQueue do
				id = f.buffQueue:Get(i)[3] 
				if f.buffQueue.activeSpell[id] then
					if f.queue.cache[id] then
						local size = f.queue:GetSize()
						for j = 1, size do
							if f.queue:Get(j)[3] == id then
								f.queue:Pop(j)
								break
							end
						end
					end
					f.queue:Push(f.buffQueue:Get(i))
					f.queue.cache[id] = true
				end
			end
		end
	elseif className == "HDH_TT_TRACKER" then
		f.queue = f.totemQueue 
	else
		f.queue = nil
	end
	
	if self.F.LATEST_SPELL_WINDOW:IsShown() then
		local size = (f.queue and f.queue:GetSize()) or 0
		local value
		local idx = 1
		local isActiveAura = false
		while idx <= size do
			value = f.queue:Get(size - (idx -1))
			if not list[idx] then
				item = CreateFrame("Frame", "nil"..idx, f, "HDH_AT_LatestSpellItemTemplate")
				list[idx] = item

				item:SetScript("OnMouseDown", OnMouseDown_LatestSpellItem)
				item:SetScript("OnMouseUp", OnMouseUp_LatestSpellItem)
				-- item:SetScript("OnUpdate", OnUpdate_LatestSpellItem)
				item:EnableMouse(true);
				item:SetScript("OnEnter",function(self) 
					local id = self.ID:GetText()
					if id then
						local isItem = self.isItem or false
						local link = isItem and select(2,GetItemInfo(id)) or UTIL.GetSpellLink(id)
						if not link then return end
						GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
						if self.unit then
							GameTooltip:SetUnitAura(self.unit, self.auraIndex, self.filter);
						else
							GameTooltip:SetHyperlink(link)
						end
					end
				end)
				item:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
			end
			item = list[idx]
			if not item:IsShown() then item:Show() end
			item:ClearAllPoints()
			item:SetParent(f)
			item:SetHeight(height)
			item:SetPoint("RIGHT", f, "RIGHT", -20, 0)
			item:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -(idx-1) * height)
			item:SetActive(false)
			item.Icon:SetTexture(value[1])
			item.Name:SetText(value[2])
			item.ID:SetText(value[3])
			item.Type:SetText(value[4])
			item.isItem = value[5] or false

			if value[8] == "HELPFUL" or value[8] == "HARMFUL" then
				if f.queue.activeSpell[value[3]] then
					isActiveAura = true
				else
					isActiveAura = false
				end
			else
				isActiveAura = false
			end
			if isActiveAura then
				item.unit = value[6]
				item.auraIndex = value[7]
				item.filter = value[8]
			else
				item.unit = nil
				item.auraIndex = nil
				item.filter = nil
			end
			idx = idx + 1
			
		end

		while size < #list do
			size = size + 1
			if list[size] and list[size]:IsShown() then list[size]:Hide() end
		end
		f:SetHeight((idx -1) * height + 5)
	end

	
	for k, v in pairs(f.buffQueue.activeSpell) do
		if not v then
			f.buffQueue.activeSpell[k] = nil
		else
			f.buffQueue.activeSpell[k] = false
		end
	end

	for k, v in pairs(f.debuffQueue.activeSpell) do
		if not v then
			f.debuffQueue.activeSpell[k] = nil
		else
			f.debuffQueue.activeSpell[k] = false
		end
	end

	for k, v in pairs(f.skillQueue.activeSpell) do
		if not v then
			f.skillQueue.activeSpell[k] = nil
		else
			f.skillQueue.activeSpell[k] = false
		end
	end

	for k, v in pairs(f.totemQueue.activeSpell) do
		if not v then
			f.totemQueue.activeSpell[k] = nil
		else
			f.totemQueue.activeSpell[k] = false
		end
	end
end

function HDH_AT_ConfigFrameMixin:UpdateFrame()
	local F = self.F
	local ddm = F.DD_TRAIT
	local currentSpec = HDH_AT_UTIL.GetSpecialization()
	local talentID = select(1, HDH_AT_UTIL.GetSpecializationInfo(HDH_AT_UTIL.GetSpecialization()))
	local traitID = talentID and HDH_AT_UTIL.GetLastSelectedSavedConfigID(talentID)
	local traitName = traitID and UTIL.GetTraitsName(traitID)
	
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
		
		if self.bodyType == nil then 
			self.bodyType = BODY_ELEMENTS
		end

		self:ChangeBody(nil, nil, nil, nil)
	else
		ddm:SelectClear()
		self:ChangeBody(BODY_TRACKER_NEW)
	end
	LoadDB(nil, self.F.LATEST_SPELL.CB_AUTO_POPUP)

	local id, name, _, icon, lastIdx
	for i=1, #self.TalentButtonList do
		id, name, _, icon = HDH_AT_UTIL.GetSpecializationInfo(i)
		if string.len(name or "") > 0 then
			self.TalentButtonList[i].Name:SetText(name)
			self.TalentButtonList[i].Icon:SetTexture(icon)
			self.TalentButtonList[i]:Show()
			self.TalentButtonList[i]:SetValue(id)
			lastIdx = i
		else
			if lastIdx then
				self.TalentButtonList[i]:SetUnassigned()
				lastIdx = nil
				self.TalentButtonList[i]:Show()
			else
				self.TalentButtonList[i]:Hide()
			end
		end
		self.TalentButtonList[i]:SetChecked(i == currentSpec)
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
end

local function DBSync(comp, comp_type, key)
	if key then
		local UI = UI_COMP_LIST
		UI[#UI+1] = comp
		comp.dbKey = key
		comp.type = comp_type
	end
end

function HDH_AT_ConfigFrameMixin:InitFrame()
	local F = HDH_AT_ConfigFrameMixin.F
	local UI = UI_COMP_LIST
	local comp

	self.F.BTN_SHOW_MODIFY_TRACKER = _G[self:GetName().."DropDownTrackerBtnModifyTracker"]
	self.F.DD_TRAIT = _G[self:GetName().."DropDownTraits"]

	self.F.DD_TRAIT:SetHookOnClick(function (self)
		HDH_AT_ConfigFrameMixin.F.TRACKER:Hide()
	end)

	local list = _G[self.F.DD_TRAIT:GetName().."List"]
	list:SetScript("OnHide", function() 
		HDH_AT_ConfigFrameMixin.F.TRACKER:Show()
	end)

	self.F.TRACKER = _G[self:GetName().."TrackerSFContents"]
	self.F.BTN_SHOW_ADD_TRACKER_CONFIG = _G[self.F.TRACKER:GetName().."BtnAddTracker"]
	self.F.BTN_SHOW_ADD_TRACKER_CONFIG:SetScript("OnClick", HDH_AT_OnClick_TrackerTapButton)

	self.F.BODY = _G[self:GetName().."Body"]
	self.F.BODY.CONFIG_DETAIL = _G[self:GetName().."BodyDetailConfig"]
	self.F.BODY.CONFIG_DETAIL.ICON = _G[self:GetName().."BodyDetailConfigTopIcon"]
	self.F.BODY.CONFIG_DETAIL.TEXT = _G[self:GetName().."BodyDetailConfigTopText"]
	self.F.BODY.CONFIG_DETAIL.GLOW = _G[self:GetName().."BodyDetailConfigGlow"]
	self.F.BODY.CONFIG_DETAIL.GLOW.Text:SetText(L.DETAIL_GLOW)
	self.F.BODY.CONFIG_DETAIL.GLOW.CB1 = _G[self:GetName().."BodyDetailConfigGlowCBCondition1"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CB1.idx = 1
	self.F.BODY.CONFIG_DETAIL.GLOW.CB2 = _G[self:GetName().."BodyDetailConfigGlowCBCondition2"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CB2.idx = 2
	self.F.BODY.CONFIG_DETAIL.GLOW.CB3 = _G[self:GetName().."BodyDetailConfigGlowCBCondition3"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CB3.idx = 3
	self.F.BODY.CONFIG_DETAIL.GLOW.CB4 = _G[self:GetName().."BodyDetailConfigGlowCBCondition4"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CB4.idx = 4
	self.F.BODY.CONFIG_DETAIL.GLOW.CB5 = _G[self:GetName().."BodyDetailConfigGlowCBCondition5"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CB_DD2 = _G[self:GetName().."BodyDetailConfigGlowDDCondition2"]
	HDH_AT_DropDown_Init(F.BODY.CONFIG_DETAIL.GLOW.CB_DD2, DDP_CONDITION_LIST, HDH_AT_OnSelected_Dropdown)
	F.BODY.CONFIG_DETAIL.GLOW.CB_DD2:SetSelectedIndex(3)
	self.F.BODY.CONFIG_DETAIL.GLOW.CB_DD3 = _G[self:GetName().."BodyDetailConfigGlowDDCondition3"]
	HDH_AT_DropDown_Init(F.BODY.CONFIG_DETAIL.GLOW.CB_DD3, DDP_CONDITION_LIST, HDH_AT_OnSelected_Dropdown)
	F.BODY.CONFIG_DETAIL.GLOW.CB_DD3:SetSelectedIndex(3)
	self.F.BODY.CONFIG_DETAIL.GLOW.CB_DD4 = _G[self:GetName().."BodyDetailConfigGlowDDCondition4"]
	HDH_AT_DropDown_Init(F.BODY.CONFIG_DETAIL.GLOW.CB_DD4, DDP_CONDITION_LIST, HDH_AT_OnSelected_Dropdown)
	F.BODY.CONFIG_DETAIL.GLOW.CB_DD4:SetSelectedIndex(3)
	self.F.BODY.CONFIG_DETAIL.GLOW.CB_EB2 = _G[self:GetName().."BodyDetailConfigGlowEBCondition2"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CB_EB3 = _G[self:GetName().."BodyDetailConfigGlowEBCondition3"]
	self.F.BODY.CONFIG_DETAIL.GLOW.CB_EB4 = _G[self:GetName().."BodyDetailConfigGlowEBCondition4"]

	self.F.BODY.CONFIG_DETAIL.GLOW.CB_LIST = {
		{ self.F.BODY.CONFIG_DETAIL.GLOW.CB1 }, 
		{ self.F.BODY.CONFIG_DETAIL.GLOW.CB2, self.F.BODY.CONFIG_DETAIL.GLOW.CB_DD2, self.F.BODY.CONFIG_DETAIL.GLOW.CB_EB2 },
		{ self.F.BODY.CONFIG_DETAIL.GLOW.CB3, self.F.BODY.CONFIG_DETAIL.GLOW.CB_DD3, self.F.BODY.CONFIG_DETAIL.GLOW.CB_EB3 },
		{ self.F.BODY.CONFIG_DETAIL.GLOW.CB4, self.F.BODY.CONFIG_DETAIL.GLOW.CB_DD4, self.F.BODY.CONFIG_DETAIL.GLOW.CB_EB4 }
	}

	self.F.BODY.CONFIG_DETAIL.DISPLAY = _G[self:GetName().."BodyDetailConfigDisplay"]
	self.F.BODY.CONFIG_DETAIL.DISPLAY.CONTENTS = _G[self:GetName().."BodyDetailConfigDisplayConfigSFContents"]
	
	self.F.BODY.CONFIG_DETAIL.DISPLAY.CONTENTS.Title1:SetText(L.DETAIL_DISPLAY)
	self.F.BODY.CONFIG_DETAIL.DISPLAY.CB1 = _G[self:GetName().."BodyDetailConfigDisplayConfigSFContentsCBCondition1"]
	self.F.BODY.CONFIG_DETAIL.DISPLAY.CB2 = _G[self:GetName().."BodyDetailConfigDisplayConfigSFContentsCBCondition2"]
	self.F.BODY.CONFIG_DETAIL.DISPLAY.CB3 = _G[self:GetName().."BodyDetailConfigDisplayConfigSFContentsCBCondition3"]
	self.F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE = _G[self:GetName().."BodyDetailConfigDisplayConfigSFContentsSwitchHideMode"]
	self.F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE:Init({
		{DB.SPELL_HIDE_TIME_OFF_AS_SPACE, HDH_AT_L.USE_SPACE},
		{DB.SPELL_HIDE_TIME_OFF, HDH_AT_L.DONT_USE_SPACE}
	}, HDH_AT_OnSelected_Dropdown)

	self.F.BODY.CONFIG_DETAIL.DISPLAY.CONTENTS.Title2:SetText(L.DETAIL_DISPLAY_LEARNED_TRAIT)
	self.F.BODY.CONFIG_DETAIL.DISPLAY.CB_LEARNED_TRAIT1 = _G[self:GetName().."BodyDetailConfigDisplayConfigSFContents".."CBConditionTrait1"]
	self.F.BODY.CONFIG_DETAIL.DISPLAY.CB_LEARNED_TRAIT2 = _G[self:GetName().."BodyDetailConfigDisplayConfigSFContents".."CBConditionTrait2"]
	self.F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE_UNLEARNED_TRAIT = _G[self:GetName().."BodyDetailConfigDisplayConfigSFContents".."SwitchHideModeUnlearnedTrait"]
	self.F.BODY.CONFIG_DETAIL.DISPLAY.SW_HIDE_MODE_UNLEARNED_TRAIT:Init({
		{DB.SPELL_HIDE_AS_SPACE, HDH_AT_L.USE_SPACE},
		{DB.SPELL_HIDE, HDH_AT_L.DONT_USE_SPACE}
	}, HDH_AT_OnSelected_Dropdown)
	self.F.BODY.CONFIG_DETAIL.DISPLAY.EB_CONNECT_TRAIT = _G[self:GetName().."BodyDetailConfigDisplayConfigSFContents".."SpellSearchEditBox"]
	self.F.BODY.CONFIG_DETAIL.DISPLAY.EB_CONNECT_TRAIT:SetOnClickHandler(
		function(element)
			return self:SetSearchEdit(element, element:GetValue(), element:GetIsItem())
		end
	)

	self.F.BODY.CONFIG_DETAIL.DISPLAY.LABEL_SW_HIDE_MODE_UNLEARNED_TRAIT = _G[self:GetName().."BodyDetailConfigDisplayConfigSFContents".."LabelSwitchHideModeLearnedTrait"]

	self.F.BODY.CONFIG_DETAIL.ETC = _G[self:GetName().."BodyDetailConfigETC"]
	self.F.BODY.CONFIG_DETAIL.ETC.MENU = _G[self:GetName().."BodyDetailConfigETCMenuSFContents"]
	self.F.BODY.CONFIG_DETAIL.ETC.CONTENTS = _G[self:GetName().."BodyDetailConfigETCSFContents"]

	--------------------------------------------------------------------------------------------------------------------------------------------------
	-- START: DETAIL_ETC_TAB
	--------------------------------------------------------------------------------------------------------------------------------------------------
	self.DETAIL_ETC_TAB = self:AppendUITab(DETAIL_ETC_CONFIG_TAB_LIST, self.F.BODY.CONFIG_DETAIL.ETC.MENU, self.F.BODY.CONFIG_DETAIL.ETC.CONTENTS)
	
	-- Change icon texture layer
	comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[1].content, COMP_TYPE.IMAGE_CHECKBUTTON, L.USE_DEFAULT_ICON, nil, 1, 1)
	comp:HiddenBackground(true)
	comp.Icon:SetTexture(nil)
	self.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CB_ION_DEFAULT = comp
	table.insert(CHANGE_ICON_CB_LIST, comp)

	comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[1].content, COMP_TYPE.IMAGE_CHECKBUTTON, L.USE_SEARCH_ICON, nil, 2, 1)
	comp:HiddenBackground(true)
	comp.Icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
	self.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CBICON = comp
	table.insert(CHANGE_ICON_CB_LIST, comp)
	local component1 = CreateFrame("EditBox", (comp:GetName()..'EditBox'), comp, "HDH_AT_EditBoxTemplate")
	component1:SetSize(132, 20)
	component1:SetPoint('TOPLEFT', comp, 'BOTTOMLEFT', 2, -7)
	component1:SetText(value or "")
	component1:SetAutoFocus(false)
	self.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_EB_SPELL = component1
	component1:SetScript("OnEditFocusGained", function() 
		GetMainFrame().F.LATEST_SPELL_WINDOW:Show()
	end)

	local component2 = CreateFrame("CheckButton", (comp:GetName()..'CheckButtonIsItem'), comp, "HDH_AT_CheckButton2Template")
	component2:SetPoint('TOPLEFT', component1, 'BOTTOMLEFT', -2, -3)
	component2.Text:SetText(L.ITEM_TOOLTIP)
	component2:SetSize(82,20)
	component2:HiddenBackground(true)
	self.F.BODY.CONFIG_DETAIL.ETC.CUSTOM_CB_IS_ITEM = component2

	local component3 = CreateFrame("Button", (comp:GetName()..'BUTTOM'), comp, "HDH_AT_ButtonTemplate")
	component3:SetSize(52, 24)
	component3:SetPoint('LEFT', component2, 'RIGHT', 2, 0)
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
		if comp == nil or comp.Icon:GetTexture() ~= nil then
			col_idx = (col_idx % 3) + 1
			comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[1].content, COMP_TYPE.IMAGE_CHECKBUTTON,     nil, nil, row_idx, col_idx)
			comp:HiddenBackground(true)
			comp.Icon:SetTexture(texture)
			table.insert(CHANGE_ICON_CB_LIST, comp)
			if col_idx == 3 then
				row_idx = row_idx + 1
			end
		else
			comp.Icon:SetTexture(texture)
		end
	end

	if comp ~= nil and comp.Icon:GetTexture() == nil then
		comp:Hide()
	end

	-- Split power bar layer
	comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[2].content, COMP_TYPE.SPLIT_LINE, L.THIS_IS_ONLY_SPLIT_POWER_BAR)
	comp = CreateFrame("Frame", (self.DETAIL_ETC_TAB[2].content:GetName()..'SplitBar'), self.DETAIL_ETC_TAB[2].content, "HDH_AT_SplitBarTemplate")
	comp:SetSize(230, 30)
	comp:SetPoint('TOPLEFT', self.DETAIL_ETC_TAB[2].content, 'TOPLEFT', 20, -70)
	comp:SetMinMaxValues(0, 1)
	self.F.BODY.CONFIG_DETAIL.ETC.SPLIT_BAR = comp

	-- inner cooldown item layer
	HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[3].content, COMP_TYPE.SPLIT_LINE, L.COOLDOWN_ITEM_DESC)
	self.F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_SWITCH = comp
	comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[3].content, COMP_TYPE.EDIT_BOX, L.INNER_COOLDOWN)
	comp:SetNumeric(true)
	self.F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_CD = comp
	comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[3].content, COMP_TYPE.EDIT_BOX, L.TRACKING_BUFF)
	self.F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_EB_SPELL_ID = comp
	comp:SetScript("OnEditFocusGained", function() 
		GetMainFrame().F.LATEST_SPELL_WINDOW:Show()
	end)
	comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[3].content, COMP_TYPE.BUTTON, " ")
	comp:SetText(L.APPLY)
	comp:SetSize(55, 22)
	self.F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_BTN_APPLY = comp
	comp = HDH_AT_CreateOptionComponent(self.DETAIL_ETC_TAB[3].content, COMP_TYPE.BUTTON, " ")
	comp:SetText(L.DELETE)
	comp:SetSize(55, 22)
	comp:SetPoint("LEFT", self.F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_BTN_APPLY, "RIGHT", 5, 0)
	self.F.BODY.CONFIG_DETAIL.ETC.INNER_CD_ITEM_BTN_DELETE = comp

	--------------------------------------------------------------------------------------------------------------------------------------------------
	-- END : DETAIL_ETC_TAB
	--------------------------------------------------------------------------------------------------------------------------------------------------
	self.F.BODY.CONFIG_DETAIL.BTN_SAVE = _G[self:GetName().."BodyDetailConfigBottomButtonApply"]
	self.F.BODY.CONFIG_DETAIL.BTN_CLOSE = _G[self:GetName().."BodyDetailConfigBottomButtonClose"]

	self.F.BODY.CONFIG_TRACKER = _G[self.F.BODY:GetName().."Tracker"]
	self.F.BODY.CONFIG_TRACKER.TITLE = _G[self.F.BODY:GetName().."TrackerTopText"]
	self.F.BODY.CONFIG_TRACKER.CONTENTS = _G[self.F.BODY:GetName().."TrackerConfigSFContents"]
	self.F.BODY.CONFIG_TRACKER.TRAIT = _G[self.F.BODY:GetName().."TrackerTraitsSFContents"]
	self.F.BODY.CONFIG_TRACKER.BTN_SAVE = _G[self.F.BODY:GetName().."TrackerBottomBtnSaveTracker"]
	self.F.BODY.CONFIG_TRACKER.BTN_DELETE = _G[self.F.BODY:GetName().."TrackerBottomBtnDelete"]
	self.F.BODY.CONFIG_TRACKER.BTN_CANCEL = _G[self.F.BODY:GetName().."TrackerBottomBtnCancel"]
	self.F.BODY.CONFIG_TRACKER.BTN_COPY = _G[self.F.BODY:GetName().."TrackerBottomBtnCopy"]

	self.F.DD_TRACKER_TRAIT = _G[self.F.BODY.CONFIG_TRACKER.TRAIT:GetName().."Traits"]

	self.F.BODY.CONFIG_TRACKER_ELEMENTS = _G[self.F.BODY:GetName().."TrackerElements"]
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.CONTENTS = _G[self.F.BODY:GetName().."TrackerElementsSFContents"]
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_ALL_TRACKER = _G[self.F.BODY:GetName().."TrackerElementsSFNoticeAllTracker"]
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_ALL_TRACKER:SetText(L.TRACKING_ALL_AURA)
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_BOSS_TRACKER = _G[self.F.BODY:GetName().."TrackerElementsSFNoticeBossTracker"]
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_BOSS_TRACKER:SetText(L.TRACKING_BOSS_AURA)

	self.F.BODY.CONFIG_UI = _G[self.F.BODY:GetName().."UI"]
	self.F.BODY.CONFIG_UI.SW_DISPLAY_MODE = _G[self.F.BODY:GetName().."UITopSwithDisplayMode"]
	self.F.BODY.CONFIG_UI.SW_DISPLAY_MODE:Init({
		{1, HDH_AT_L.USE_DISPLAY_ICON},
		{2, HDH_AT_L.USE_DISPLAY_BAR}, 
		{3, HDH_AT_L.USE_DISPLAY_ICON_AND_BAR}
	}, HDH_AT_OnSelected_Dropdown)
	DBSync(F.BODY.CONFIG_UI.SW_DISPLAY_MODE, COMP_TYPE.SWITCH, "ui.%s.common.display_mode")

	self.F.BODY.CONFIG_UI.SW_CONFIG_MODE = _G[self.F.BODY:GetName().."UITopSwithConfigMode"]
	self.F.BODY.CONFIG_UI.SW_CONFIG_MODE:Init({
		{1, HDH_AT_L.USE_GLOBAL_CONFIG}, 
		{2, HDH_AT_L.USE_SEVERAL_CONFIG}
	}, HDH_AT_OnSelected_Dropdown)

	self.F.BODY.CONFIG_UI.CB_MOVE = _G[self.F.BODY:GetName().."UIBottomCBMove"]
	self.F.BODY.CONFIG_UI.CB_SHOW_ID_TOOPTIP = _G[self.F.BODY:GetName().."UIBottomCBShowIdInTooltip"]
	DBSync(F.BODY.CONFIG_UI.CB_SHOW_ID_TOOPTIP, COMP_TYPE.CHECK_BOX, "show_tooltip_id")

	self.F.BODY.CONFIG_UI.MEMU = _G[self.F.BODY:GetName().."UIMenuSFContents"]
	self.F.BODY.CONFIG_UI.CONTENTS = _G[self.F.BODY:GetName().."UIConfigSFContents"]
	
	self.F.BODY_TAB_INFO = _G[self:GetName().."TabInfo"]
	self.F.BODY_TAB_ELEMENTS = _G[self:GetName().."TabElements"]
	self.F.BODY_TAB_UI = _G[self:GetName().."TabUI"]

	self.F.BODY_TAB_INFO.index = 1
	self.F.BODY_TAB_ELEMENTS.index = 2
	self.F.BODY_TAB_UI.index = 3

	self.BODY_TAB = {
		self.F.BODY_TAB_INFO, 
		self.F.BODY_TAB_ELEMENTS, 
		self.F.BODY_TAB_UI
	}
	ChangeTab(self.BODY_TAB, 1)

	self.F.LATEST_SPELL_WINDOW = _G[self:GetName().."LatestSpell"]
	self.F.LATEST_SPELL = _G[self:GetName().."LatestSpellBodySFContents"]
	self.F.LATEST_SPELL.CB_AUTO_POPUP = _G[self:GetName().."LatestSpellBodyCBAutoPopup"]
	DBSync(F.LATEST_SPELL.CB_AUTO_POPUP, COMP_TYPE.CHECK_BOX, "show_latest_spell")
	
	F.ED_TRACKER_NAME = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS,      COMP_TYPE.EDIT_BOX, 	  L.TRACKER_NAME)
	F.DD_TRACKER_TYPE = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, 	  COMP_TYPE.DROPDOWN, 	  L.TRACKER_TYPE)
	F.DD_TRACKER_UNIT = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, 	  COMP_TYPE.DROPDOWN, 	  L.TRACKER_UNIT)
	F.DD_TRACKER_AURA_FILTER = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, COMP_TYPE.DROPDOWN, 	  L.AURA_FILTER_TYPE)
	F.DD_TRACKER_AURA_CASTER = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, COMP_TYPE.DROPDOWN, 	  L.AURA_CASTER_TYPE)
	-- F.DD_TRACKER_TRAIT = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS,   COMP_TYPE.DROPDOWN, 	  L.USE_TRAIT)

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
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.DROPDOWN,     L.FONT_LOCATION,       "ui.%s.font.cd_location")
	HDH_AT_DropDown_Init(comp, DDP_FONT_CD_LOC_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.DROPDOWN,     L.TIME_FORMAT,  		  "ui.%s.font.cd_format")
	HDH_AT_DropDown_Init(comp, DDP_FONT_CD_FORMAT_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.COLOR_PICKER, L.FONT_COLOR,          "ui.%s.font.cd_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.COLOR_PICKER, L.UNDER_5S_FONT_COLOR, "ui.%s.font.cd_color_5s")
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.SLIDER,       L.FONT_SIZE,           "ui.%s.font.cd_size")
	comp:Init(1, 1, 50)
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.SWITCH,       L.SHORT_TIME,      "ui.%s.font.cd_abbreviate")
	comp:Init(nil, HDH_AT_OnSelected_Dropdown)

	-- FONT COUNT
	comp = HDH_AT_CreateOptionComponent(tabUIList[2].content, COMP_TYPE.DROPDOWN,     L.FONT_LOCATION,       "ui.%s.font.count_location")
	HDH_AT_DropDown_Init(comp, DDP_FONT_CD_LOC_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[2].content, COMP_TYPE.COLOR_PICKER, L.FONT_COLOR,          "ui.%s.font.count_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[2].content, COMP_TYPE.SLIDER,       L.FONT_SIZE,           "ui.%s.font.count_size")
	comp:Init(1, 1, 50)

	-- FONT VALUE
	comp = HDH_AT_CreateOptionComponent(tabUIList[3].content, COMP_TYPE.DROPDOWN,     L.FONT_LOCATION,       "ui.%s.font.v1_location")
	HDH_AT_DropDown_Init(comp, DDP_FONT_CD_LOC_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[3].content, COMP_TYPE.COLOR_PICKER, L.FONT_COLOR,          "ui.%s.font.v1_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[3].content, COMP_TYPE.SLIDER,       L.FONT_SIZE,           "ui.%s.font.v1_size")
	comp:Init(1, 1, 50)
	comp = HDH_AT_CreateOptionComponent(tabUIList[3].content, COMP_TYPE.SWITCH,       L.SHORT_VALUE,      "ui.%s.font.v1_abbreviate")
	comp:Init(nil, HDH_AT_OnSelected_Dropdown)

	-- FONT NAME
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.DROPDOWN,       L.FONT_LOCATION,         "ui.%s.font.name_location")
	HDH_AT_DropDown_Init(comp, DDP_FONT_NAME_LOC_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.COLOR_PICKER, L.FONT_ON_COLOR,          "ui.%s.font.name_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.COLOR_PICKER, L.FONT_OFF_COLOR,      "ui.%s.font.name_color_off")
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.SLIDER,       L.FONT_SIZE,           "ui.%s.font.name_size")
	comp:Init(1, 1, 50)
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.SLIDER,       L.MARGIN_LEFT,           "ui.%s.font.name_margin_left")
	comp:Init(1, 1, 50)
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.SLIDER,       L.MARGIN_RIGHT,           "ui.%s.font.name_margin_right")
	comp:Init(1, 1, 50)

	-- DEFAULT
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.DROPDOWN,       L.ICON_ORDER,         "ui.%s.common.order_by")
	HDH_AT_DropDown_Init(comp, DDP_ICON_ORDER_LIST, HDH_AT_OnSelected_Dropdown)

	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.SLIDER,       L.ICON_NUMBER_OF_HORIZONTAL,           "ui.%s.common.column_count")
	comp:Init(1, 1, 20, true, false, nil, L.ROW_N_COL_N)
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.SWITCH,       L.ICON_ORDER_DISPLAY_V,           "ui.%s.common.reverse_v")
	comp:Init({
		{true, L.UPWARD},
		{false, L.DOWNWARD}
	}, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.SWITCH,       L.ICON_ORDER_DISPLAY_H,           "ui.%s.common.reverse_h")
	comp:Init({
		{true, L.TO_THE_LEFT},
		{false, L.TO_THE_RIGHT}
	}, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.SLIDER, 	L.ICON_MARGIN_VERTICAL,          "ui.%s.common.margin_v")
	comp:Init(1, 0, 50, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.SLIDER,       L.ICON_MARGIN_HORIZONTAL,           "ui.%s.common.margin_h")
	comp:Init(1, 0, 50, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.SWITCH,       L.DISPLAY_GAME_TOOPTIP,           "ui.%s.common.show_tooltip")
	comp:Init(nil, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.SWITCH,       L.DISPLAY_WHEN_NONCOMBAT,           "ui.%s.common.always_show")
	comp:Init({
		{true, L.ALWAYS},
		{false, L.IN_COMBAT}
	}, HDH_AT_OnSelected_Dropdown)
	self.F.BODY.CONFIG_UI.CB_DISPLAY_WHEN_NONCOMBAT = comp

	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.SWITCH,       L.DISPLAY_WHEN_IN_RAID,           "ui.%s.common.hide_in_raid")
	comp:Init({
		{false, L.ALWAYS},
		{true, L.HIDE}
	}, HDH_AT_OnSelected_Dropdown)
	self.F.BODY.CONFIG_UI.SW_DISPLAY_WHEN_IN_RAID = comp

	-------------------------------------------------------------------------------------
	-- ICON
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.DROPDOWN,       L.COOLDOWN_ANIMATION_DIDRECTION,         "ui.%s.icon.cooldown")
	HDH_AT_DropDown_Init(comp, DDP_ICON_COOLDOWN_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SLIDER,     L.ICON_SIZE,       "ui.%s.icon.size")
	comp:Init(0, 10, 100, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SLIDER,     L.ICON_BORDER_SIZE,       "ui.%s.icon.border_size")
	comp:Init(0, 0, 10, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SLIDER,     L.ACTIVED_ICON_ALPHA,       "ui.%s.icon.on_alpha")
	comp:Init(0, 0, 1)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SLIDER,     L.INACTIVED_ICON_ALPHA,       "ui.%s.icon.off_alpha")
	comp:Init(0, 0, 1)

	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.COLOR_PICKER,     L.ACTIVED_ICON_BORDER_COLOR,       "ui.%s.icon.active_border_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.COLOR_PICKER,       L.ICON_SPARK_COLOR,         "ui.%s.icon.spark_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.COLOR_PICKER, L.COOLDOWN_COLOR,      "ui.%s.icon.cooldown_bg_color")

	HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.BLANK_LINE, ' ')
	HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SPLIT_LINE, L.ONLY_FOR_CONFIG_OF_AURA_TRACKER)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SWITCH,       L.USE_DEFAULT_BORDER_COLOR,           "ui.%s.common.default_color")
	comp:Init(nil, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SWITCH,       L.CANCEL_BUFF,         "ui.%s.icon.able_buff_cancel")
	comp:Init(nil, HDH_AT_OnSelected_Dropdown)
 
	HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.BLANK_LINE, ' ')
	HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SPLIT_LINE, L.ONLY_FOR_CONFIG_OF_COOLDOWN_TRACKER)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SWITCH,       L.DISPLAY_GLOBAL_COOLDOWN,         "ui.%s.cooldown.show_global_cooldown")
	comp:Init(nil, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SWITCH,       L.ICON_USE_NOT_ENOUGH_MANA_COLOR,         "ui.%s.cooldown.use_not_enough_mana_color")
	comp:Init(nil, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.COLOR_PICKER,       L.ICON_NOT_ENOUGH_MANA_COLOR,         "ui.%s.cooldown.not_enough_mana_color")
	comp:SetEnableAlpha(false)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SWITCH,       L.ICON_USE_OUT_RAGNE_COLOR,         "ui.%s.cooldown.use_out_range_color")
	comp:Init(nil, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.COLOR_PICKER,       L.ICON_OUT_RAGNE_COLOR,         "ui.%s.cooldown.out_range_color")
	comp:SetEnableAlpha(false)

	-------------------------------------------------------------------------------------
	-- BAR 
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.SLIDER, 	L.WIDTH_SIZE,          "ui.%s.bar.width")
	comp:Init(0, 10, 300, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.SLIDER,       L.HEIGHT_SIZE,           "ui.%s.bar.height")
	comp:Init(0, 10, 300, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.DROPDOWN,       L.BAR_TEXTURE,         "ui.%s.bar.texture")
	HDH_AT_DropDown_Init(comp, DDP_BAR_TEXTURE_LIST, HDH_AT_OnSelected_Dropdown, nil, "HDH_AT_DropDownOptionTextureItemTemplate")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.DROPDOWN,       L.LOCATION_BAR,         "ui.%s.bar.location")
	HDH_AT_DropDown_Init(comp, DDP_BAR_LOC_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.DROPDOWN,       L.ANIMATION_DIDRECTION,         "ui.%s.bar.cooldown_progress")
	HDH_AT_DropDown_Init(comp, DDP_BAR_COOLDOWN_LIST, HDH_AT_OnSelected_Dropdown)

	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.SWITCH,       L.FILL_BAR,         "ui.%s.bar.to_fill")
	comp:Init({
		{true, L.TO_FILL },
		{false, L.TO_EMPTY}
	}, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.SWITCH,       L.DISPLAY_SPARK,         "ui.%s.bar.show_spark")
	comp:Init(nil, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.COLOR_PICKER,       L.BAR_SPARK_COLOR,         "ui.%s.bar.spark_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.COLOR_PICKER,     L.BG_COLOR,       "ui.%s.bar.bg_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.COLOR_PICKER,     L.BAR_COLOR,       "ui.%s.bar.color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.SWITCH,       L.DISPLAY_FILL_BAR,         "ui.%s.bar.use_full_color")
	comp:Init(nil, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.COLOR_PICKER,     L.FILL_COLOR,       "ui.%s.bar.full_color")
	HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.SPLIT_LINE, L.ONLY_FOR_CONFIG_OF_AURA_TRACKER)
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.SWITCH,       L.USE_DEFAULT_BORDER_COLOR,           "ui.%s.common.default_color")
	comp:Init(nil, HDH_AT_OnSelected_Dropdown)
	
	------------------------------------------------------- import
	-- comp = HDH_AT_CreateOptionComponent(tabUIList[8].content, COMP_TYPE.SPLIT_LINE, L.IMPORT_SHARE_STRING)
	comp = HDH_AT_CreateOptionComponent(tabUIList[8].content, COMP_TYPE.BUTTON,       L.IMPORT_SHARE_STRING)
	comp:SetText(L.APPLY_SHARE_STRING)
	self.F.BODY.CONFIG_UI.BTN_IMPORT_STRING = comp
	comp = HDH_AT_CreateOptionComponent(tabUIList[8].content, COMP_TYPE.EDIT_BOX)
	comp:SetSize(250,26)
	comp:SetFontObject("Font_White_XS")
	comp:SetMaxLetters(0)
	self.F.BODY.CONFIG_UI.ED_IMPORT_STRING = comp

	------------------------------------------------------- export
	-- comp = HDH_AT_CreateOptionComponent(tabUIList[9].content, COMP_TYPE.SPLIT_LINE,       L.EXPORT_SHARE_STRING)
	comp = HDH_AT_CreateOptionComponent(tabUIList[9].content, COMP_TYPE.BUTTON,       L.EXPORT_SHARE_STRING)
	comp:SetText(L.CREATE_SHARE_STRING)
	self.F.BODY.CONFIG_UI.BTN_EXPORT_STRING = comp
	comp = HDH_AT_CreateOptionComponent(tabUIList[9].content, COMP_TYPE.EDIT_BOX)
	comp:SetSize(250,26)
	comp:SetMaxLetters(0)
	comp:SetFontObject("Font_White_XS")
	self.F.BODY.CONFIG_UI.ED_EXPORT_STRING = comp
	comp = HDH_AT_CreateOptionComponent(tabUIList[9].content, COMP_TYPE.SPLIT_LINE,       L.PLEASE_SELECT_TRACKER_FOR_EXPORT)
	self.F.BODY.CONFIG_UI.LABEL_EXPORT = comp

	------------------------------------------------------- reset
	comp = HDH_AT_CreateOptionComponent(tabUIList[10].content, COMP_TYPE.BUTTON,       L.RESET_ADDON)
	comp:SetText(L.RESET)
	self.F.BODY.CONFIG_UI.BTN_RESET = comp

	--- load talent button 
	self.TalentButtonList = {}
	-- self.TalentButtonList = {self.Talent1, self.Talent2, self.Talent3, self.Talent4, self.Talent5}
	for _, btn in ipairs(self.TalentButtonList) do
		btn:SetScript("OnClick", HDH_AT_OnCheck)
	end
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

function HDH_AT_ConfigFrameMixin:OnEvent(event, ...)
	if event == "UNIT_SPELLCAST_SENT" then
		table.insert(self.cacheCastSpell, select(4, ...))
		UTIL.RunTimer(self, "UPDATE_LATEST", 0.5, HDH_AT_ConfigFrameMixin.UpdateLatest, self)
	elseif event == "BAG_UPDATE_COOLDOWN" then
		local info, startTime, duration, enable, itemId
		for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS or 0 do
			for slot = 1, C_Container.GetContainerNumSlots(bag) do
				info = C_Container.GetContainerItemInfo(bag, slot)
				if info then
					startTime, duration = C_Container.GetItemCooldown(info.itemID)
					if duration > 1.5 and (GetTime() - startTime) < 1 then
						table.insert(self.cacheUesdItem, info.itemID)
					end
				end
			end
		end
		for index = 1, INVSLOT_LAST_EQUIPPED do
			startTime, duration, enable = GetInventoryItemCooldown("player", index)
			if enable then
				itemId, _ = GetInventoryItemID("player", index)
				if duration > 1.5 and (GetTime() - startTime) < 1 then
					table.insert(self.cacheUesdItem, itemId)
				end
			end
		end
		UTIL.RunTimer(self, "UPDATE_LATEST", 0.5, HDH_AT_ConfigFrameMixin.UpdateLatest, self)
	elseif event == "UNIT_AURA" then
		UTIL.RunTimer(self, "UPDATE_LATEST", 0.5, HDH_AT_ConfigFrameMixin.UpdateLatest, self)
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, event, _, srcGUID, srcName, _, _, _, _, _, _, spellID, spellName =  CombatLogGetCurrentEventInfo()
		if srcGUID == UnitGUID('player') then
			if event == "SPELL_DAMAGE" or event == "SPELL_HEAL" or event == "SPELL_CAST_SUCCESS" or event == "SPELL_SUMMON" or event == "SPELL_CREATE" then -- event == "SPELL_AURA_APPLIED" or 
				name, _, icon = HDH_AT_UTIL.GetInfo(spellID, false)
				table.insert(self.cacheCastSpell, spellID)
				UTIL.RunTimer(self, "UPDATE_LATEST", 0.5, HDH_AT_ConfigFrameMixin.UpdateLatest, self)
			end
		end
	end
end

function HDH_AT_ConfigFrame_OnHide(self)
	if not HDH_AT_MinimumFrame:IsShown() then
		self:SetScript("OnEvent", nil)
		self:UnregisterAllEvents()
	end
end

function HDH_AT_ConfigFrame_OnShow(self)
	self.ErrorReset:Show()
	local IsLoaded = select(1, HDH_AT_UTIL.GetSpecializationInfo(HDH_AT_UTIL.GetSpecialization()))
	
	if HDH_AT_UTIL.GetSpecialization() == 5 then
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

	self.ErrorReset:Hide()

	if self.F.LATEST_SPELL.CB_AUTO_POPUP:GetChecked() then
		self:SetScript("OnEvent", self.OnEvent)
		self:RegisterEvent('UNIT_SPELLCAST_SENT')
		self:RegisterEvent('BAG_UPDATE_COOLDOWN')
		self:RegisterEvent('UNIT_AURA')
		self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	end
end

function HDH_AT_ConfigFrame_OnLoad(self)
	if select(4, GetBuildInfo()) <= 49999 then -- 대격변
		self.maxTabWidth = 18
	end

    self:SetResizeBounds(FRAME_WIDTH, FRAME_MIN_H, FRAME_WIDTH, FRAME_MAX_H) 
    self:SetupCommend()
    self:InitFrame()
end

-------------------------------
--------- UI component --------
-------------------------------

function HDH_AT_CreateOptionComponent(parent, component_type, option_name, db_key, row, col)
	local MARGIN_X = 5
	local MARGIN_Y = -10
	local COMP_HEIGHT = 25
	local COMP_WIDTH = parent:GetParent():GetWidth() - 180
	local COMP_MARGIN = 10
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
		frame.text = frame:CreateFontString(nil, 'OVERLAY', "Font_Yellow_S")
		frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', MARGIN_X + x, MARGIN_Y + y)
		frame.text:SetPoint('LEFT', frame, 'LEFT', COMP_MARGIN, 0)
		frame.text:SetNonSpaceWrap(false)
		-- frame.text:SetJustifyV('CENTER')
		frame.text:SetJustifyV('MIDDLE')
		frame.text:SetText(option_name)
		frame:SetSize(COMP_WIDTH, COMP_HEIGHT)
		frame.text:SetPoint('RIGHT', frame, 'RIGHT', 15, 0)
		frame.text:SetJustifyH('LEFT')
	else
		frame:SetSize(1, COMP_HEIGHT)
		frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', MARGIN_X + x, MARGIN_Y + y)
	end

	if component_type == COMP_TYPE.CHECK_BOX then
		component = CreateFrame("Button", (parent:GetName()..'Button'..parent.row.."_"..parent.col), parent, "HDH_AT_CheckButton2Template")
		component:SetPoint('LEFT', frame, 'RIGHT', option_name and 18 or 0, 0)
		component:SetScript("OnClick", HDH_AT_OnCheck)

	elseif component_type == COMP_TYPE.BUTTON then
		component = CreateFrame("Button", (parent:GetName()..'Button'..parent.row.."_"..parent.col), parent, "HDH_AT_ButtonTemplate")
		component:SetSize(115, 22)
		component:SetPoint('LEFT', frame, 'RIGHT', option_name and 20 or 0, 0)
		component:SetText(value or 'None')
		component:SetScript("OnClick", HDH_AT_OnClick_Button)
	
	elseif component_type == COMP_TYPE.EDIT_BOX then
		component = CreateFrame("EditBox", (parent:GetName()..'EditBox'..parent.row.."_"..parent.col), parent, "HDH_AT_EditBoxTemplate")
		component:SetSize(115, 20)
		component:SetPoint('LEFT', frame, 'RIGHT', option_name and 20 or 5, 0)
		component:SetText(value or "")
		component:SetAutoFocus(false) 
		component:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
		component:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
		component:SetMaxLetters(15)

	elseif component_type == COMP_TYPE.DROPDOWN then
		component = CreateFrame("Button", (parent:GetName()..'DropDown'..parent.row.."_"..parent.col), parent, "HDH_AT_DropDownOptionTemplate")
		component:SetSize(115, 20)
		component:SetPoint('LEFT', frame, 'RIGHT', option_name and 20 or 0, 0)

	elseif component_type == COMP_TYPE.SLIDER then
		component = CreateFrame("Slider", (parent:GetName()..'Slider'..parent.row.."_"..parent.col), parent, "HDH_AT_SliderTemplate")
		component:SetSize(115, 20)
		component:SetPoint('LEFT', frame, 'RIGHT', option_name and 20 or 0, 0)
		component:SetHandler(HDH_AT_OnChangedSlider)
		component:Init(10, 0, 100, true, true, 10)

	elseif component_type == COMP_TYPE.COLOR_PICKER then
		component = CreateFrame("Button", (parent:GetName()..'ColorPicker'..parent.row.."_"..parent.col), parent, "HDH_AT_ColorPickerTemplate")
		component:SetSize(115, 20)
		component:SetPoint('LEFT', frame, 'RIGHT', option_name and 20 or 0, 0)
		component:SetHandler(HDH_AT_OnSeletedColor, function(self, text)
			GetMainFrame().Dialog:AlertShow(L.ERROR_COLOR_CODE:format(UTIL.Trim(text) or " "))
		end)

	elseif component_type == COMP_TYPE.PREV_NEXT_BUTTON then
		component = CreateFrame("Button", (parent:GetName()..'PrevNextButton'..parent.row.."_"..parent.col), parent, "HDH_AT_PrevNextButtonTemplate")
		component:SetSize(115, 26)
		component:SetPoint('LEFT', frame, 'RIGHT', option_name and 20 or 0, 0)
		-- component:SetHandler(HDH_AT_OnSeletedColor)
	
	elseif component_type == COMP_TYPE.IMAGE_CHECKBUTTON then
		component = CreateFrame("Button", (parent:GetName()..'ImageCheckButton'..parent.row.."_"..parent.col), parent, "HDH_AT_CheckButtonImageTemplate")
		component:SetSize(20, 20)
		component:SetPoint('LEFT', frame, 'RIGHT', 10, 0)
		component:SetScript("OnClick", HDH_AT_OnCheck)
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

	elseif component_type == COMP_TYPE.BLANK_LINE then
		component = CreateFrame("Frame", (parent:GetName()..'Line'..parent.row.."_"..parent.col), parent, "HDH_AT_BlankLineFrameTemplate")
		component:SetSize(255, 26)
		component:SetPoint('LEFT', frame, 'LEFT', 5, 0)
		-- component:SetPoint('RIGHT', parent, 'RIGHT', -10, 0)
		-- component:SetHandler(HDH_AT_OnSeletedColor)
	
	elseif component_type == COMP_TYPE.SPLIT_LINE then
		component = CreateFrame("Frame", (parent:GetName()..'Line'..parent.row.."_"..parent.col), parent, "HDH_AT_LineFrameTemplate")
		component:SetSize(255, 26)
		component:SetPoint('LEFT', frame, 'LEFT', 5, 0)
		-- component:SetPoint('RIGHT', parent, 'RIGHT', -10, 0)
		-- component:SetHandler(HDH_AT_OnSeletedColor)
		
		frame.text:ClearAllPoints()
		frame.text:SetPoint('LEFT', component, 'LEFT', 5, 0)
		frame.text:SetPoint('RIGHT', component, 'RIGHT', -5, 0)
		frame.text:SetJustifyH('CENTER')
		
	elseif component_type == COMP_TYPE.SWITCH then
		component = CreateFrame("Frame", (parent:GetName()..'Line'..parent.row.."_"..parent.col), parent, "HDH_AT_SwitchFrameTemplate")
		component:SetSize(115, 20)
		component:SetPoint('LEFT', frame, 'RIGHT', 20, 0)
	end

	if component_type then
		DBSync(component, component_type, db_key)
	end
	local w, h = parent:GetParent():GetSize()
	parent:ClearAllPoints()
	parent:SetSize(w, -(y - COMP_HEIGHT -20) )
	parent:SetPoint('TOPLEFT', parent:GetParent(), 'TOPLEFT', 0, 0)
	-- parent:SetPoint('BOTTOMRIGHT', parent:GetParent(), 'BOTTOMRIGHT', 0, 30)
	return component, label
end
