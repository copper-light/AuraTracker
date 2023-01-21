HDH_AT_ConfigFrameMixin = {}
HDH_AT_ConfigFrameMixin.FRAME = {}

local L = HDH_AT_L
local DB = HDH_AT_ConfigDB
local UTIL = HDH_AT_UTIL

local UI_COMP_LIST = {}
local UI_TAB_LIST

local COMP_TYPE = {}
COMP_TYPE.CHECK_BOX = 1
COMP_TYPE.EDIT_BOX = 2
COMP_TYPE.BUTTON = 3
COMP_TYPE.COLOR_PICKER = 4
COMP_TYPE.SLIDER = 5
COMP_TYPE.DROPDOWN = 6
COMP_TYPE.MULTI_SELECTOR = 7
COMP_TYPE.PREV_NEXT_BUTTON = 8

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

local UI_TabData= {
	{name=L.TEXT, type="LABEL"},
	{name=L.TIME, type="BUTTON"}, --1
	{name=L.COUNT, type="BUTTON"}, --2
	{name=L.VALUE, type="BUTTON"}, --3
	{name=L.BAR_NAME, type="BUTTON"}, --4

	{name=L.ICON, type="LABEL"},
	{name=L.DEFAULT, type="BUTTON"},        --5
	{name=L.SIZE_AND_ORDER, type="BUTTON"}, --6
	{name=L.COLOR, type="BUTTON"}, 		 --7

	{name=L.BAR, type="LABEL"},
	{name=L.DEFAULT, type="BUTTON"},         --8
	{name=L.SIZE_AND_ORDER, type="BUTTON"}, --9
	{name=L.COLOR, type="BUTTON"},        --10

	{name=L.PROFILE, type="LABEL"},
	{name=L.RESET, type="BUTTON"},       --11
	{name=L.SHARE, type="BUTTON"},         --12
}



local MyClassKor, MyClass = UnitClass("player");
local totemName = L.TOTEM

if MyClass == "MAGE" then totemName = L.MAGE_TOTEM
-- elseif MyClass == "PALADIN" then TrackerTypeName = "자원:마나";
-- elseif MyClass == "WARRIOR" then TrackerTypeName = "자원:분노";
elseif MyClass == "DRUID" then totemName = L.DRUID_TOTEM
elseif MyClass == "DEATHKNIGHT" then totemName = L.DK_TOTEM
-- elseif MyClass == "HUNTER" then TrackerTypeName = "자원:집중";
-- elseif MyClass == "PRIEST" then TrackerTypeName = "자원:마나";
-- elseif MyClass == "ROGUE" then TrackerTypeName = "자원:기력";
-- elseif MyClass == "SHAMAN" then TrackerTypeName = "자원:마나,소용돌이";
-- elseif MyClass == "WARLOCK" then TrackerTypeName = "자원:마나";
elseif MyClass == "MONK" then totemName = L.MONK_TOTEM
-- elseif MyClass == "DEMONHUNTER" then TrackerTypeName = "자원:격노,고통";
end

local DDP_TRACKER_LIST = {
	{HDH_TRACKER.TYPE.BUFF, L.BUFF},
	{HDH_TRACKER.TYPE.DEBUFF, L.DEBUFF},
	{HDH_TRACKER.TYPE.COOLDOWN, L.SKILL_COOLDOWN},
	{HDH_TRACKER.TYPE.TOTEM, totemName}
}

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
	{DB.FONT_LOCATION_BAR_R, L.FONT_LOCATION_BAR_R}
}

local DDP_FONT_NAME_ALIGN_LIST = {
	{DB.NAME_ALIGN_LEFT, L.LEFT},
	{DB.NAME_ALIGN_RIGHT, L.RIGHT},
	{DB.NAME_ALIGN_CENTER, L.CENTER},
	{DB.NAME_ALIGN_TOP, L.TOP},
	{DB.NAME_ALIGN_BOTTOM, L.BOTTOM}
}

local DDP_ICON_COOLDOWN_LIST = {
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
	{DB.BAR_LOCATION_T, L.TOP},
	{DB.BAR_LOCATION_B, L.BOTTOM},
	{DB.BAR_LOCATION_L, L.LEFT},
	{DB.BAR_LOCATION_R, L.RIGHT}
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
	{DB.AURA_CASTER_ALL , L.ALL_UNIT},
	{DB.AURA_CASTER_ONLY_MINE, L.ONLY_MINE_AURA},
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

---------------------------------------------------------
-- local functions
---------------------------------------------------------

local function GetMainFrame()
	return HDH_AT_ConfigFrame
end

local function GetTalentIdByTransit(searchTransitId)
	local ret = {}
	local transitIds
	if not searchTransitId then return nil end
	for i = 1, MAX_TALENT_TABS do
		talentId, _, _, _ = GetSpecializationInfo(i)
		if talentId == nil then
			break
		end
		if searchTransitId == talentId then
			return talentId
		end
		transitIds = C_ClassTalents.GetConfigIDsBySpecID(talentId)
		for _, v in pairs(transitIds) do
			if v == searchTransitId then
				return talentId
			end
		end
	end
	return nil
end

local function ChangeTab(tabs, idx)
	for i, tab in ipairs(tabs) do
		if i == idx then
			tab.btn:SetActivate(true)
			tab.content:Show()
		else
			tab.btn:SetActivate(false)
			tab.content:Hide()
		end
	end
	tabs.tabIdx = idx
end

local function GetTabIdx(tabs)
	return tabs.tabIdx
end

-- local function SetDB(key, value)
-- 	local trackerId = GetMainFrame().F.DROPDOWN_TRACKER:GetSelectedValue()
-- 	local value
-- 	if value ~= nil then
-- 		DB:SetTrackerUIValue(comp.dbKey, value)
-- 	end
-- end

-- local function GetDB(comp)
-- 	local trackerId = GetMainFrame().F.DROPDOWN_TRACKER:GetSelectedValue()
-- 	return DB:GetTrackerUIValue(trackerId, comp.dbKey)
-- end

-- local function CreateKeyValue(values)
-- 	local ret = {}
-- 	for i, name in ipairs(values) do
-- 		ret[i] = {i , name}
-- 	end
-- 	return ret
-- end

local function LoadDB(trackerId, comp)
	-- local trackerId = GetMainFrame():GetCurTrackerIdx()
	local dbValue = DB:GetTrackerValue(trackerId, comp.dbKey)
	if comp.type == COMP_TYPE.CHECK_BOX then
		comp:SetChecked(dbValue)
	elseif comp.type == COMP_TYPE.SLIDER then
		comp:UpdateValue(tonumber(dbValue))
	elseif comp.type == COMP_TYPE.COLOR_PICKER then
		comp:SetColorRGBA(unpack(dbValue))
	elseif comp.type == COMP_TYPE.DROPDOWN then
		comp:SetSelectValue(dbValue)
	end
end

local function isHasTransit(id)
	for _, tracker in ipairs(HDH_AT_DB.tracker) do
		if tracker.transit and UTIL.HasValue(tracker.transit, id) then
			return true
		end
	end
	return false
end

function GetTransitName(id)
	local transitName
	local info = C_Traits.GetConfigInfo(id)
	if not info then
		if GetSpecializationInfoByID(id) then
			transitName = L.ALWAYS_USE
		end
	else
		transitName = info.name
	end
	return transitName
end

local function DrawLine(frame, x, y, total, point1, point2)
	local i = 1;
	local size = math.abs(x) > math.abs(y) and x or y;
	size = math.abs(size);
	local t;
	while (total / 2) > (size * i) do
		t = frame:CreateTexture(nil, "BACKGROUND");
		t:SetTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\cooldown_bg.blp");
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
			-- local space = 0;
			
			DrawLine(frame.GridFrame,size,0,displayX,"TOP","BOTTOM");
			DrawLine(frame.GridFrame,-size,0,displayX, "TOP","BOTTOM");
			DrawLine(frame.GridFrame,0,size,displayY,"LEFT","RIGHT");
			DrawLine(frame.GridFrame,0,-size,displayY,"LEFT","RIGHT");
			
			t = frame.GridFrame:CreateTexture(nil, "BACKGROUND");
			t:SetTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\cooldown_bg.blp");
			t:SetVertexColor(1,0,0, 0.5);
			t:SetSize(3,3);
			t:SetPoint("LEFT",UIParent,"LEFT",0,0);
			t:SetPoint("RIGHT",UIParent,"RIGHT",0,0);
			
			t = frame.GridFrame:CreateTexture(nil, "BACKGROUND");
			t:SetTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\cooldown_bg.blp");
			t:SetVertexColor(1,0,0, 0.5);
			t:SetSize(3,3);
			t:SetPoint("TOP",UIParent,"TOP",0,0);
			t:SetPoint("BOTTOM",UIParent,"BOTTOM",0,0);
		
		-- frame.hdh_at_option_move_line = t;
		end
		frame.GridFrame:Show();
	else
		if frame.GridFrame then frame.GridFrame:Hide(); end
	end
end

---------------------------------------------------------
-- OnScript
---------------------------------------------------------

local function HDH_AT_OnChangedTracker(self)	
	local main = GetMainFrame()
	local idx = self.idx
	local id = self.id
	main:SetCurTrackerIdx(idx)
	if idx and idx > 0 then
		main:LoadTrackerElementConfig(id)
		if GetTabIdx(main.BODY_TAB) == 1 then
			main.F.BODY.CONFIG_TRACKER_ELEMENTS:Show()	
		else
			main.F.BODY.CONFIG_UI:Show()
		end

		main.F.BODY.CONFIG_TRACKER:Hide()
		main.F.BODY.CONFIG_UI.DD_CONFIG_MODE:Enable()
	else
		main.F.BODY.CONFIG_UI.DD_CONFIG_MODE:Disable()
	end

	main:LoadUIConfig(id)
	main:UpdateAbleConfigs(main.F.BODY.CONFIG_UI.DD_DISPLAY_MODE:GetSelectedValue())
	main:UpdateTransitInTrackerConfig()
end

local function HDH_AT_OnChangedSlider(self, value)
	local trackerId = GetMainFrame():GetCurTrackerId()
	if value ~= nil and self.dbKey ~= nil then
		DB:SetTrackerValue(trackerId, self.dbKey, value)
		HDH_TRACKER.UpdateSetting(trackerId)
	end
end

local function HDH_AT_OnSeletedColor(self, r, g, b, a)
	local trackerId = GetMainFrame():GetCurTrackerId()
	
	if r ~= nil and g ~=nil and b ~= nil and a ~=nil and self.dbKey ~= nil then
		DB:SetTrackerValue(trackerId, self.dbKey, {r, g, b, a})		
		HDH_TRACKER.UpdateSetting(trackerId)
	end
end

function HDH_AT_UI_OnCheck(self)
	local F = GetMainFrame().F
	local value = self:GetChecked()
	local trackerId = GetMainFrame():GetCurTrackerId()

	if self == F.BODY.CONFIG_UI.CB_MOVE then
		HDH_TRACKER.ENABLE_MOVE = value
		HDH_TRACKER.SetMoveAll(value)
		ShowGrid(GetMainFrame(), value)

	elseif self == F.DETAIL_CONFIG.CD1 or 
		   self == F.DETAIL_CONFIG.CD2 or
		   self == F.DETAIL_CONFIG.CD3 or
		   self == F.DETAIL_CONFIG.CD4 then
		for _, cd in ipairs(F.DETAIL_CONFIG.CD_LIST) do
			if cd[1] ~= self then
				cd[1]:SetChecked(false)
			end
		end

	else
		if value ~= nil and self.dbKey ~= nil then
			DB:SetTrackerValue(trackerId, self.dbKey, value)
			HDH_TRACKER.UpdateSetting(trackerId)
		end
	end
end

local function HDH_AT_OP_SwapRowData(rowList, i1, i2)
	local tmp;
	tmp = rowList[i1];
	rowList[i1] = rowList[i2];
	rowList[i2] = tmp;
	
	tmp = rowList[i1].idx;
	rowList[i1].idx = rowList[i2].idx;
	rowList[i2].idx = tmp;

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
	local selfIdx = self.idx;
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
						if rowFrame.mode == HDH_AT_AuraRowMixin.MODE.DATA then
							DB:SwapTrackerElement(trackerId, j-1, j)
						else
							DB:SwapTracker(rowList[j-1].id, rowList[j].id)
						end
						HDH_AT_OP_SwapRowData(rowList, j-1, j)
					end	
				else
					for j = selfIdx-1, i, -1 do
						rowList[j]:SetPoint("TOPLEFT", 0, -self:GetHeight()*(j));
						if rowFrame.mode == HDH_AT_AuraRowMixin.MODE.DATA then
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
	if self.mode and self.mode ~= HDH_AT_AuraRowMixin.MODE.EMPTY then 
		main:LoadTrackerElementConfig(trackerId)
		HDH_TRACKER.InitIcons(trackerId)
	else
		main:LoadTrackerList(main:GetCurTransit())
		main:SetCurTrackerIdx(self.idx)
		HDH_TRACKER.InitVaribles()
		if main.F.BODY.CONFIG_TRACKER:IsShown() then
			main:LoadTrackerConfig(main:GetCurTrackerId())
		end
	end
end

local function LoadGlowDetail(trackerId, elemIdx, checkbutton)
	local main = GetMainFrame()
	local F = main.F
	
	F.DETAIL_CONFIG:SetShown(not F.DETAIL_CONFIG:IsShown())
	F.DETAIL_CONFIG.elemIdx = elemIdx
	F.DETAIL_CONFIG.trackerId = trackerId
	F.DETAIL_CONFIG.checkbutton = checkbutton
	F.DETAIL_CONFIG.preCheck = not checkbutton:GetChecked()

	local glowType, glowCondition, glowValue = DB:GetTrackerElementGlow(trackerId, elemIdx)

	local match
	for idx, cd in ipairs(F.DETAIL_CONFIG.CD_LIST) do
		match = idx == glowType
		F.DETAIL_CONFIG.CD_LIST[idx][1]:SetChecked(match)
		if idx > 1 then
			F.DETAIL_CONFIG.CD_LIST[idx][2]:SetSelectIdx((match and glowCondition) or 1)
			F.DETAIL_CONFIG.CD_LIST[idx][3]:SetText((match and glowValue) or "")
		end
	end
	checkbutton:SetChecked(F.DETAIL_CONFIG.preCheck)
end

local function OnEventTrackerElement(self, elemIdx)
	local name = self:GetName()
	local main = GetMainFrame()
	local F = main.F
	local trackerId = main:GetCurTrackerId()

	if string.find(name, "ButtonSet") then
		print("아직 미구현된 기능")

	elseif string.find(name, "CheckButtonAlways") then
		local value = self:GetChecked()
		DB:UpdateTrackerElementAlways(trackerId, elemIdx, value)
		HDH_TRACKER.InitIcons(trackerId)

	elseif string.find(name, "CheckButtonGlow") then
		local value = self:GetChecked()
		LoadGlowDetail(trackerId, elemIdx, self)

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
	end
end

local function HDH_AT_OnSelected_Dropdown(self, itemFrame, idx, value)
	local main = GetMainFrame()
	local F = GetMainFrame().F

	if self == F.DROPDOWN_TALENT then
		main:LoadTrackerList(value)
		main:SetCurTrackerIdx(1)

	elseif self == F.BODY.CONFIG_UI.DD_CONFIG_MODE then
		if main:GetCurTrackerId() then
			if value == DB.USE_SEVERAL_CONFIG then
				main.Dialog:AlertShow(L.ALERT_CONFIRM_CHANGE_TO_ONLY_THIS_TRACKER_CONFIGURATION, main.Dialog.DLG_TYPE.YES_NO,
					function()
						local main = GetMainFrame()
						local trackerId = main:GetCurTrackerId()
						DB:CopyGlobelToTracker(trackerId)
						main:LoadUIConfig(trackerId)
						main:UpdateAbleConfigs(main.F.BODY.CONFIG_UI.DD_DISPLAY_MODE:GetSelectedValue())
						HDH_TRACKER.InitVaribles(trackerId)
					end,
					function()
						F.BODY.CONFIG_UI.DD_CONFIG_MODE:SetSelectIdx(DB.USE_GLOBAL_CONFIG)
					end
				)
			else
				main.Dialog:AlertShow(L.ALERT_CONFIRM_CHANGE_TO_GLOBAL_CONFIGURATION, main.Dialog.DLG_TYPE.YES_NO,
					function()
						local main = GetMainFrame()
						local trackerId = main:GetCurTrackerId()
						DB:ClearTracker(trackerId)
						main:LoadUIConfig(trackerId)
						main:UpdateAbleConfigs(main.F.BODY.CONFIG_UI.DD_DISPLAY_MODE:GetSelectedValue())
						HDH_TRACKER.InitVaribles(trackerId)
					end,
					function()
						F.BODY.CONFIG_UI.DD_CONFIG_MODE:SetSelectIdx(DB.USE_SEVERAL_CONFIG)
					end
				)
			end
		end

	elseif self == F.BODY.CONFIG_UI.DD_DISPLAY_MODE then
		main:UpdateAbleConfigs(value)
		HDH_TRACKER.UpdateSetting(main:GetCurTrackerId())

	elseif self == F.DD_TRACKER_TRANSIT then
		main:UpdateTransitInTrackerConfig(idx)

	elseif self == F.DD_TRACKER_TYPE then
		-- if value == HDH_TRACKER.TYPE.BUFF or value == HDH_TRACKER.TYPE.DEBUFF then
		-- 	HDH_AT_DropDown_Init(F.DD_TRACKER_UNIT, DDP_AURA_UNIT_LIST, HDH_AT_OnSelected_Dropdown)

		-- elseif value == HDH_TRACKER.TYPE.COOLDOWN then
		-- 	HDH_AT_DropDown_Init(F.DD_TRACKER_UNIT, DDP_COOLDOWN_UNIT_LIST, HDH_AT_OnSelected_Dropdown)
		-- end

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
		local seletedTransitValue = self:GetSelectedValue()
		if seletedTransitValue ~= nil and  self.dbKey ~= nil then
			DB:SetTrackerValue(trackerId, self.dbKey, seletedTransitValue)
			HDH_TRACKER.UpdateSetting(trackerId)
		end
	end
end

local function HDH_AT_OnChangeTabUI(self)
	local id = self.id
	ChangeTab(GetMainFrame().UI_TAB, id)
end

local function HDH_AT_OnClick_TrackerConfigButton(self)
	local main = GetMainFrame()
	local F = main.F
	local value = self:GetParent().id
	local ret = main:LoadTrackerConfig(value)

	HDH_AT_OnChangedTracker(self:GetParent())
	ChangeTab(main.BODY_TAB, 1)
	F.BODY.CONFIG_UI:Hide()
	F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()

	if ret and not F.BODY.CONFIG_TRACKER:IsShown() then 
		F.BODY.CONFIG_TRACKER:Show()
	end
end 

function HDH_AT_OnClick_Button(self)
	local main = GetMainFrame()
	local F = main.F

	if self == F.BTN_SHOW_ADD_TRACKER_CONFIG then
		if not F.BODY.CONFIG_TRACKER:IsShown() then
			F.BODY.CONFIG_TRACKER:Show()
		end
		main:LoadTrackerConfig()
		ChangeTab(main.BODY_TAB, 1)
		F.BODY.CONFIG_UI:Hide()
		F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		HDH_AT_OnChangedTracker(self)
		main:LoadUIConfig()

	elseif self == F.BTN_SHOW_MODIFY_TRACKER then
		local value = main:GetCurTrackerId()
		local ret = main:LoadTrackerConfig(value)

		if ret and not F.BODY.CONFIG_TRACKER:IsShown() then 	
			F.BODY.CONFIG_TRACKER:Show()
		end
		F.BODY.CONFIG_UI:Hide()
		F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		ChangeTab(main.BODY_TAB, -1)

	elseif self == F.BODY.CONFIG_TRACKER.BTN_SAVE then
		local info = nil
		local name = F.ED_TRACKER_NAME:GetText()
		local type = F.DD_TRACKER_TYPE:GetSelectedValue()
		local unit = F.DD_TRACKER_UNIT:GetSelectedValue()
		local transitList = F.DD_TRACKER_TRANSIT:GetSelectedValue()
		local caster = F.DD_TRACKER_AURA_CASTER:GetSelectedValue()
		local filter = F.DD_TRACKER_AURA_FILTER:GetSelectedValue()
		local trackerObj
		local id

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


		if not transitList or #transitList == 0 then
			main.Dialog:AlertShow(L.PLASE_SELECT_TRANSIT) return 
		end

		if F.BODY.CONFIG_TRACKER.is_creation then
			id = DB:InsertTracker(name, type, unit, filter, caster, transitList)
			trackerObj = HDH_TRACKER.New(id, name, type, unit)
		else
			id = main:GetCurTrackerId()
			DB:UpdateTracker(id, name, type, unit, filter, caster, transitList)
			trackerObj = HDH_TRACKER.Get(id)
			if trackerObj then
				trackerObj:Modify(name, type, unit)
				trackerObj:InitIcons()
			end
		end
		F.BODY.CONFIG_TRACKER:Hide()
		F.BODY.CONFIG_UI.DD_CONFIG_MODE:Enable()
		main:UpdateFrame()
		main:ChangeTrackerTabByTrackerId(id)
		HDH_TRACKER.InitVaribles()
		
	elseif self == F.BODY.CONFIG_TRACKER.BTN_DELETE then
		local id = main:GetCurTrackerId()
		local name = select(2, DB:GetTrackerInfo(id))
		main.Dialog:AlertShow(L.DO_YOU_WANT_TO_DELETE_THIS_ITEM:format(name), main.Dialog.DLG_TYPE.YES_NO, function() 
			local main = GetMainFrame()
			local id = main:GetCurTrackerId()
			main.F.BODY.CONFIG_TRACKER:Hide()
			DB:DeleteTracker(id)
			-- HDH_TRACKER.Delete(idx)
			-- HDH_TRACKER.Reload(idx)
			main:UpdateFrame()
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
			copyName = HDH_AT_UTIL.Trim(copyName)

			if copyName and string.len(copyName) > 0 then
				local newId = DB:CopyTracker(id, copyName)
				F.BODY.CONFIG_TRACKER:Hide()
				GetMainFrame():UpdateFrame()
				GetMainFrame():ChangeTrackerTabByTrackerId(newId)
				HDH_TRACKER.InitVaribles()
				main.Dialog:AlertShow(L.ALRET_CONFIRM_COPY)
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
			main:LoadTrackerList(main:GetCurTransit())
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
			main:LoadTrackerList(main:GetCurTransit())
			main:ChangeTrackerTabByTrackerId(newValue)
		end

	elseif self == F.DETAIL_CONFIG.BTN_SAVE then
		local trackerId = F.DETAIL_CONFIG.trackerId
		local elemIdx = F.DETAIL_CONFIG.elemIdx
		local checkbutton = F.DETAIL_CONFIG.checkbutton
		local checkedIdx, condition, glowValue
		for idx, cd in ipairs(F.DETAIL_CONFIG.CD_LIST) do
			if cd[1]:GetChecked() then
				checkedIdx = idx
				condition = cd[2] and cd[2]:GetSelectedValue()
				glowValue = cd[3] and HDH_AT_UTIL.Trim(cd[3]:GetText())
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

		self:GetParent():Hide()
		HDH_TRACKER.InitIcons(trackerId)
		if main:GetCurTrackerId() == trackerId then
			main:LoadTrackerElementConfig(trackerId, elemIdx, elemIdx)
		end
	elseif self == F.DETAIL_CONFIG.BTN_CLOSE then
		self:GetParent():Hide()
	end
end

function HDH_AT_OnClick_TapButton(self)
	local main = GetMainFrame()
	local F = main.F
	if self == main.BODY_TAB[1].btn then
		ChangeTab(main.BODY_TAB, 1)
		if main:GetCurTrackerIdx() and main:GetCurTrackerIdx() > 0 then
			F.BODY.CONFIG_TRACKER:Hide()	
		else
			main.BODY_TAB[1].content:Hide()
			F.BODY.CONFIG_TRACKER:Show()
		end
	elseif self == main.BODY_TAB[2].btn then
		ChangeTab(main.BODY_TAB, 2)
		F.BODY.CONFIG_TRACKER:Hide()
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

function HDH_AT_ConfigFrameMixin:GetTransit(talentId)
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

function HDH_AT_ConfigFrameMixin:SetCurTalent(value)
	self.curTalent = value
end

function HDH_AT_ConfigFrameMixin:SetCurTransit(value)
	self.curTransit = value
end

function HDH_AT_ConfigFrameMixin:GetCurTalent()
	return self.curTalent
end

function HDH_AT_ConfigFrameMixin:GetCurTransit()
	return self.curTransit
end

function HDH_AT_ConfigFrameMixin:SetCurTrackerIdx(idx)
	idx = idx or 0
	local list = self.F.TRACKER.list or {}
	local activeBtn 

	if idx == -1 then
		idx = #list
	end

	if idx > #list then
		idx = 1
	end
	for i, btn in ipairs(list) do
		if i == idx then
			activeBtn = btn 
		end
		btn:SetActivate(i == idx)
	end
	if #list == 0 or idx == 0 then
		self.F.BTN_SHOW_ADD_TRACKER_CONFIG:SetActivate(true)
		activeBtn = self.F.BTN_SHOW_ADD_TRACKER_CONFIG
		idx = -1
	else
		self.F.BTN_SHOW_ADD_TRACKER_CONFIG:SetActivate(false)
	end
	-- self.LeftBorder1:SetPoint("BOTTOMLEFT", activeBtn, "TOPRIGHT", -6, 0)
	-- self.LeftBorder2:SetPoint("TOPLEFT", activeBtn, "BOTTOMRIGHT", -7, 0)

	self.curTrackerIdx = idx
	self.curTrackerId = list[idx] and list[idx].id or nil

	self:LoadTrackerElementConfig(self.curTrackerId)

	return idx
end

function HDH_AT_ConfigFrameMixin:GetCurTrackerId()
	return self.F.TRACKER.list[self:GetCurTrackerIdx()] and self.F.TRACKER.list[self:GetCurTrackerIdx()].id or nil
end

function HDH_AT_ConfigFrameMixin:GetCurTrackerIdx()
	return self.curTrackerIdx
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

	key = HDH_AT_UTIL.Trim(key)
	if not key or string.len(key) == 0 then
		self.Dialog:AlertShow(L.PLASE_INPUT_ID)
		return 
	end
	
	if tonumber(key) and string.len(key) > 7  then
		self.Dialog:AlertShow(L.NOT_FOUND_ID:format(tostring(key)))
		return 
	end
	
	name, id, texture, isItem = HDH_AT_UTIL.GetInfo(key, isItem)

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

function HDH_AT_ConfigFrameMixin:UpdateTransitInTrackerConfig(idx)
	ddm = self.F.DD_TRACKER_TRANSIT
	local itemFrame, isTalent, check
	for i = (idx or 1), #ddm.item do
		itemFrame = ddm.item[i]
		if(GetSpecializationInfoByID(itemFrame.value)) then
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
			elseif i > 1 and idx then
				break
			end
		end
	end
end

function HDH_AT_ConfigFrameMixin:GetElementFrame(listFrame, trackerId, index)
	local row = listFrame.list[index]
	index = tonumber(index)
	if not row then
		row = CreateFrame("Button",(listFrame:GetName().."Row"..index), listFrame, "HDH_AT_RowTemplate")
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
		_G[row:GetName().."EditBoxID"]:SetScript("OnEnterPressed", function(self) OnEventTrackerElement(self, self:GetParent().idx) end)
		_G[row:GetName().."ButtonSet"]:SetScript("OnClick", function(self) OnEventTrackerElement(self, self:GetParent().idx) end)
		_G[row:GetName().."CheckButtonGlow"]:SetScript("OnClick", function(self) OnEventTrackerElement(self, self:GetParent().idx) end)
		_G[row:GetName().."CheckButtonValue"]:SetScript("OnClick", function(self) OnEventTrackerElement(self, self:GetParent().idx) end)
		_G[row:GetName().."CheckButtonAlways"]:SetScript("OnClick", function(self) OnEventTrackerElement(self, self:GetParent().idx) end)
		_G[row:GetName().."ButtonDel"]:SetScript("OnClick", function(self) OnEventTrackerElement(self, self:GetParent().idx) end)
		_G[row:GetName().."ButtonAdd"]:SetScript("OnClick", function(self) OnEventTrackerElement(self, self:GetParent().idx) end)

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
	local id, name, type, unit, aura_filter, aura_caster, transit = DB:GetTrackerInfo(trackerId)

	if (type ~= HDH_TRACKER.TYPE.BUFF and type ~= HDH_TRACKER.TYPE.DEBUFF and type ~= HDH_TRACKER.TYPE.TOTEM) or aura_filter == DB.AURA_FILTER_REG then
		if startRowIdx and endRowIdx and (startRowIdx > endRowIdx) then return end
		while true do
			rowFrame = self:GetElementFrame(listFrame, trackerId, i)-- row가 없으면 생성하고, 있으면 그거 재활용
			elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
			glowType = (((glowType and glowType ~= DB.GLOW_CONDITION_NONE) and true) or false)
			rowFrame.idx = i
			if not rowFrame:IsShown() then rowFrame:Show() end
			rowFrame:ClearAllPoints();
			if i == 1 	then rowFrame:SetPoint("TOPLEFT",listFrame,"TOPLEFT") 
						else rowFrame:SetPoint("TOPLEFT",listFrame,"TOPLEFT", 0, (-rowFrame:GetHeight()*(i-1))) end
			
			if elemKey then
				rowFrame:Set(i, elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem)
			else-- add 를 위한 공백 row 지정
				rowFrame:Clear()
				listFrame:SetSize(listFrame:GetParent():GetWidth(), i * ROW_HEIGHT)
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

function HDH_AT_ConfigFrameMixin:LoadTrackerConfig(value)
	local F = self.F
	
	F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()

	if value then
		local id, name, type, unit, aura_filter, aura_caster, transit = DB:GetTrackerInfo(value)
		F.BODY.CONFIG_TRACKER.is_creation = false
		F.BODY.CONFIG_TRACKER.TITLE:SetText(L.EDIT_TRACKER)
		if id then
			F.ED_TRACKER_NAME:SetText(name)

			F.DD_TRACKER_AURA_CASTER:Enable()
			F.DD_TRACKER_AURA_FILTER:Enable()
			F.DD_TRACKER_UNIT:Enable()

			if type == HDH_TRACKER.TYPE.BUFF or type == HDH_TRACKER.TYPE.DEBUFF then
				F.DD_TRACKER_UNIT:SetSelectValue(unit)
				F.DD_TRACKER_AURA_CASTER:SetSelectIdx(aura_caster)
				F.DD_TRACKER_AURA_FILTER:SetSelectIdx(aura_filter)
				F.DD_TRACKER_AURA_CASTER:Enable()
				F.DD_TRACKER_AURA_FILTER:Enable()
				F.DD_TRACKER_UNIT:Enable()
				-- HDH_AT_DropDown_Init(F.DD_TRACKER_UNIT, DDP_AURA_UNIT_LIST, HDH_AT_OnSelected_Dropdown)

			elseif type == HDH_TRACKER.TYPE.TOTEM then
				F.DD_TRACKER_UNIT:SelectClear()
				F.DD_TRACKER_AURA_CASTER:SelectClear()
				F.DD_TRACKER_AURA_FILTER:SetSelectIdx(aura_filter)
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

			F.DD_TRACKER_TYPE:SetSelectIdx(type)
			-- F.DD_TRACKER_UNIT:SetSelectValue(unit)
			
			F.DD_TRACKER_TRANSIT:SetSelectValue(transit)
			F.BODY.CONFIG_TRACKER.BTN_DELETE:Enable()
			F.BODY.CONFIG_TRACKER.BTN_CANCEL:Enable()
			F.BODY.CONFIG_TRACKER.BTN_COPY:Enable()
			F.BTN_PREV_NEXT.Value:SetText(id)
			F.BTN_PREV_NEXT.BtnNext:Enable()
			F.BTN_PREV_NEXT.BtnPrev:Enable()
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
		if tracker.transit then
			if UTIL.HasValue(tracker.transit, id) then
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

function HDH_AT_ConfigFrameMixin:ChangeTrackerTabByTrackerId(id)
	local parent = self.F.TRACKER
	local selectIdx
	parent.list = parent.list or {}

	for idx, tab in pairs(parent.list) do
		if (tab.id == id) then
			selectIdx = idx 
			break
		end
	end

	-- 현재 트래커 리스트에 있는거면 해당탭으로 이동
	if selectIdx then
		self:SetCurTrackerIdx(selectIdx)
	else
		local transitList = select(7, DB:GetTrackerInfo(id))
		local curTalent = select(1, GetSpecializationInfo(GetSpecialization()))
		local transitId
		if #transitList > 0 then
			for _, t in ipairs(transitList) do
				if curTalent == GetTalentIdByTransit(t) then
					transitId = t
					break
				end
			end
			if not transitId then
				transitId = transitList[1]
			end
			self.F.DROPDOWN_TALENT:SetSelectValue(transitId)
			self:LoadTrackerList(transitId)
			self:ChangeTrackerTabByTrackerId(id)
		else
			self:SetCurTrackerIdx(0)
		end
	end
end

function HDH_AT_ConfigFrameMixin:LoadTrackerList(transitId)
	local F = self.F
	local component
	local parent = self.F.TRACKER
	local MARGIN_Y = 0
	local trackerIds
	local id, name, type, unit

	if not transitId or transitId == DDM_TRACKER_ALL then
		trackerIds = DB:GetTrackerIds()
	elseif transitId == DDM_TRACKER_UNUSED then
		trackerIds = DB:GetUnusedTrackerIds()
	else
		local talentId = GetTalentIdByTransit(transitId)
		trackerIds = transitId and DB:GetTrackerIdsByTransits(transitId, talentId)
	end

	parent.list = parent.list or {}
	for idx=1, #trackerIds do
		id, name, type, unit = DB:GetTrackerInfo(trackerIds[idx])
		if not parent.list[idx] then 
			component = CreateFrame("Button", (parent:GetName()..'Tracker'..idx), parent, "HDH_AT_TrackerTapBtnTemplate")
			component:SetWidth(120)
			component.Text:SetJustifyH("RIGHT")
			component.ConfigBtn:SetScript("OnClick", HDH_AT_OnClick_TrackerConfigButton)
			component:SetScript("OnClick", HDH_AT_OnChangedTracker)	
			component:SetScript('OnDragStart', HDH_AT_OP_OnDragStartRow)
			component:SetScript('OnDragStop', HDH_AT_OP_OnDragStopRow)
			component:RegisterForDrag('LeftButton')
			component:EnableMouse(true)
			component:SetMovable(true)
			parent.list[idx] = component 
		else
			component = parent.list[idx]
			component:Show()
		end
		component.idx = idx
		component.id = id
		component.type = type
		component.unit = unit
		component:ClearAllPoints()
		component:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', 2, -((component:GetHeight())  * (idx -1) + MARGIN_Y))

		local unitName = ""
		if type == HDH_TRACKER.TYPE.BUFF or type == HDH_TRACKER.TYPE.DEBUFF then
			unitName = ":" .. UNIT_TO_LABEL[unit]
		end

		component:SetText(STR_TRACKER_FORMAT:format(name, DDP_TRACKER_LIST[type][2], unitName))
		component:SetActivate(false)
	end

	if #trackerIds < #parent.list then
		for i = #trackerIds + 1, #parent.list do
			parent.list[i]:Hide()
			parent.list[i].id = nil
			parent.list[i].idx = nil
			parent.list[i].type = nil
			parent.list[i].unit = nil
			parent.list[i].name = nil
		end
	end

	parent:SetSize(120, (#trackerIds + 1) * F.BTN_SHOW_ADD_TRACKER_CONFIG:GetHeight())

	if #trackerIds == 0 then
		F.BTN_SHOW_ADD_TRACKER_CONFIG:ClearAllPoints()
		F.BTN_SHOW_ADD_TRACKER_CONFIG:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 2, -MARGIN_Y)
	else
		F.BTN_SHOW_ADD_TRACKER_CONFIG:ClearAllPoints()
		F.BTN_SHOW_ADD_TRACKER_CONFIG:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', 2, -((F.BTN_SHOW_ADD_TRACKER_CONFIG:GetHeight())  * (#trackerIds ) + MARGIN_Y))
	end
	self:SetCurTransit(transitId)
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
			component.id = tabButtonIdx
			configFrame = CreateFrame("Frame", (bodyFrame:GetName()..'Config'..tabButtonIdx), bodyFrame)
			configFrame:SetPoint('TOPLEFT', bodyFrame, 'TOPLEFT', 0, 0)
			configFrame:SetPoint('BOTTOMRIGHT', bodyFrame, 'BOTTOMRIGHT', 0, 0)
			ret[tabButtonIdx] = { btn = component,  content= configFrame }
		end

		component:SetPoint('TOPLEFT', tabFrame, 'TOPLEFT', 1, -(component:GetHeight() * (idx -1)))
		component:SetPoint('RIGHT', tabFrame, 'RIGHT', -20, 0)
		component:SetText(data.name)
	end

	-- if not tabFrame.emptyFrame then
	-- 	tabFrame.emptyFrame = CreateFrame("Button", (tabFrame:GetName()..'TabEmpty'), tabFrame, "HDH_AT_BackgroundTemplate")
	-- end
	-- tabFrame.emptyFrame:ClearAllPoints()
	-- tabFrame.emptyFrame:SetPoint('TOPLEFT', component, 'BOTTOMLEFT', 0, 1)
	-- tabFrame.emptyFrame:SetPoint('BOTTOMRIGHT', tabFrame:GetParent(), 'BOTTOMRIGHT', -20, 0)
	
	tabFrame.tabs = ret
	return ret
end

function HDH_AT_ConfigFrameMixin:LoadUIConfig(tackerId)
	local F = self.F
	for _, comp in ipairs(UI_COMP_LIST) do
		LoadDB(tackerId, comp)
	end
	if DB:hasTrackerUI(tackerId) then
		F.BODY.CONFIG_UI.DD_CONFIG_MODE:SetSelectIdx(DB.USE_SEVERAL_CONFIG)
	else
		F.BODY.CONFIG_UI.DD_CONFIG_MODE:SetSelectIdx(DB.USE_GLOBAL_CONFIG)
	end
end

function HDH_AT_ConfigFrameMixin:UpdateFrame()
	local F = self.F
	local ids = DB:GetTrackerIds()
	local transitList = {}
	local talentID, talentName, transitName, icon
	local cacheTransit = {}
	transitList[#transitList+1] = {DDM_TRACKER_ALL, L.ALL_LIST, nil}
	local unusedTracker = 0
	local transits
	local errorTrackerIds = {}
	for _, id in ipairs(ids) do
		transits = select(7, DB:GetTrackerInfo(id))
		if #transits > 0 then
			for idx, transitID in ipairs(transits) do
				if not cacheTransit[transitID] then  
					talentID = GetTalentIdByTransit(transitID)
					if talentID then
						cacheTransit[transitID] = true
						talentName = select(2, GetSpecializationInfoByID(talentID))
						transitName = GetTransitName(transitID)
						icon = SPEC_TEXTURE_FORMAT:format(SPEC_FORMAT_STRINGS[talentID])
						transitList[#transitList+1] = {transitID, STR_TRANSIT_FORMAT:format(transitName, talentName), icon}
					else
						errorTrackerIds[#errorTrackerIds+1] = id
					end
				end
			end
		else
			unusedTracker = unusedTracker + 1
		end
	end

	if unusedTracker > 0 then
		transitList[#transitList+1] = {DDM_TRACKER_UNUSED, L.UNUSED_LIST}
		self.Dialog:AlertShow(L.ALERT_UNUSED_LIST:format(unusedTracker))
	end

	F.DROPDOWN_TALENT:UseAtlasSize(true)
	HDH_AT_DropDown_Init(F.DROPDOWN_TALENT, transitList, HDH_AT_OnSelected_Dropdown , nil, "HDH_AT_DropDownTrackerItemTemplate") --	HDH_AT_DropDownTrackerItemTemplate")

	if #transitList > 0 and not self:GetCurTransit() then
		local talentID = select(1, GetSpecializationInfo(GetSpecialization()))
		local transit = C_ClassTalents.GetLastSelectedSavedConfigID(talentID)
		if DB:HasTransit(transit) then
			self:SetCurTransit(transit)
		elseif cacheTransit[talentID] then
			self:SetCurTransit(talentID)
		else
			self:SetCurTransit(transitList[1][1])
		end
	end

	local itemValues = {}
	local itemTemplates = {}
	local id, name, icon
	for _, item in ipairs(self:GetTalentList(true)) do
		id, name, icon = unpack(item)
		itemValues[#itemValues+1] = {-1, name, icon}
		itemTemplates[#itemTemplates+1] = "HDH_AT_SplitItemTemplate"
		itemValues[#itemValues+1] = {id, L.ALWAYS_USE, nil}
		itemTemplates[#itemTemplates+1] = "HDH_AT_CheckButtonItemTemplate"
		for _, transit in ipairs(self:GetTransit(id)) do
			itemValues[#itemValues+1] = transit
			itemTemplates[#itemTemplates+1] = "HDH_AT_CheckButtonItemTemplate"
		end
	end
	F.DD_TRACKER_TRANSIT:UseAtlasSize(true)

	HDH_AT_DropDown_Init(F.DD_TRACKER_TRANSIT, itemValues, HDH_AT_OnSelected_Dropdown, nil, itemTemplates, true, true)

	if #transitList > 1 then
		F.DROPDOWN_TALENT:SetSelectValue(self:GetCurTransit())
		self:LoadTrackerList(self:GetCurTransit())
		-- self:LoadTrackerElementConfig(self:GetCurTalent())
		if not self.F.BODY.CONFIG_TRACKER:IsShown() 
			and not self.F.BODY.CONFIG_UI:IsShown() 
			and not self.F.BODY.CONFIG_TRACKER_ELEMENTS:IsShown() then
			ChangeTab(self.BODY_TAB, GetTabIdx(self.BODY_TAB) or 1)
		elseif self.F.BODY.CONFIG_TRACKER_ELEMENTS:IsShown() or not GetTabIdx(self.BODY_TAB) then
			ChangeTab(self.BODY_TAB, GetTabIdx(self.BODY_TAB) or 1)
		end

		self:SetCurTrackerIdx(1)
	else
		F.DROPDOWN_TALENT:Reset()
		F.DROPDOWN_TRANSIT:Reset()
		-- F.BTN_SHOW_MODIFY_TRACKER:Hide()
		F.BODY.CONFIG_TRACKER:Show()
		F.BODY.CONFIG_TRACKER_ELEMENTS:Hide()
		F.BODY.CONFIG_UI:Hide()
		self:LoadTrackerList()
		self:LoadTrackerConfig()
		self:SetCurTrackerIdx(0)
	end

	self:LoadUIConfig(self:GetCurTrackerId())
	local mode = F.BODY.CONFIG_UI.DD_DISPLAY_MODE:GetSelectedValue()
	self:UpdateAbleConfigs(mode)
	self:UpdateTransitInTrackerConfig()
end

function HDH_AT_ConfigFrameMixin:UpdateAbleConfigs(mode)
	local F = self.F
	local idx = self.UI_TAB.tabIdx or 1
	
	if mode == DB.DISPLAY_ICON then
		self.UI_TAB[4].btn:Disable()
		self.UI_TAB[5].btn:Enable()
		self.UI_TAB[6].btn:Enable()
		self.UI_TAB[7].btn:Enable()
		self.UI_TAB[8].btn:Disable()
		self.UI_TAB[9].btn:Disable()
		self.UI_TAB[10].btn:Disable()
	elseif mode == DB.DISPLAY_BAR then
		self.UI_TAB[4].btn:Enable()
		self.UI_TAB[5].btn:Disable()
		self.UI_TAB[6].btn:Disable()
		self.UI_TAB[7].btn:Disable()
		self.UI_TAB[8].btn:Enable()
		self.UI_TAB[9].btn:Enable()
		self.UI_TAB[10].btn:Enable()
	else
		self.UI_TAB[4].btn:Enable()
		self.UI_TAB[5].btn:Enable()
		self.UI_TAB[6].btn:Enable()
		self.UI_TAB[7].btn:Enable()
		self.UI_TAB[8].btn:Enable()
		self.UI_TAB[9].btn:Enable()
		self.UI_TAB[10].btn:Enable()
	end
	if not self.UI_TAB[idx].btn:IsEnabled() then
		idx = 1
	end
	ChangeTab(self.UI_TAB, idx)
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
    self.F = {}
	local F = self.F
	local UI = UI_COMP_LIST
	local comp

	self.F.BTN_SHOW_MODIFY_TRACKER = _G[self:GetName().."DropDownTrackerBtnModifyTracker"]
	
	self.F.DROPDOWN_TALENT = _G[self:GetName().."DropDownTalent"]
	self.F.DROPDOWN_TRANSIT = _G[self:GetName().."DropDownTransit"]
	-- self.F.DROPDOWN_TRACKER = _G[self:GetName().."DropDownTracker"]

	self.F.TRACKER = _G[self:GetName().."TrackerSFContents"]
	self.F.BTN_SHOW_ADD_TRACKER_CONFIG = _G[self.F.TRACKER:GetName().."BtnAddTracker"]

	self.F.BODY = _G[self:GetName().."Body"]

	self.F.DETAIL_CONFIG = _G[self:GetName().."DetailConfig"]
	self.F.DETAIL_CONFIG.CD1 = _G[self:GetName().."DetailConfigCBCondition1"]
	self.F.DETAIL_CONFIG.CD1.idx = 1
	self.F.DETAIL_CONFIG.CD2 = _G[self:GetName().."DetailConfigCBCondition2"]
	self.F.DETAIL_CONFIG.CD2.idx = 2
	self.F.DETAIL_CONFIG.CD3 = _G[self:GetName().."DetailConfigCBCondition3"]
	self.F.DETAIL_CONFIG.CD3.idx = 3
	self.F.DETAIL_CONFIG.CD4 = _G[self:GetName().."DetailConfigCBCondition4"]
	self.F.DETAIL_CONFIG.CD4.idx = 4

	self.F.DETAIL_CONFIG.CD_DD2 = _G[self:GetName().."DetailConfigDDCondition2"]
	HDH_AT_DropDown_Init(F.DETAIL_CONFIG.CD_DD2, DDP_CONDITION_LIST, HDH_AT_OnSelected_Dropdown)
	F.DETAIL_CONFIG.CD_DD2:SetSelectIdx(3)
	self.F.DETAIL_CONFIG.CD_DD3 = _G[self:GetName().."DetailConfigDDCondition3"]
	HDH_AT_DropDown_Init(F.DETAIL_CONFIG.CD_DD3, DDP_CONDITION_LIST, HDH_AT_OnSelected_Dropdown)
	F.DETAIL_CONFIG.CD_DD3:SetSelectIdx(3)
	self.F.DETAIL_CONFIG.CD_DD4 = _G[self:GetName().."DetailConfigDDCondition4"]
	HDH_AT_DropDown_Init(F.DETAIL_CONFIG.CD_DD4, DDP_CONDITION_LIST, HDH_AT_OnSelected_Dropdown)
	F.DETAIL_CONFIG.CD_DD4:SetSelectIdx(3)

	self.F.DETAIL_CONFIG.CD_EB2 = _G[self:GetName().."DetailConfigEBCondition2"]
	self.F.DETAIL_CONFIG.CD_EB3 = _G[self:GetName().."DetailConfigEBCondition3"]
	self.F.DETAIL_CONFIG.CD_EB4 = _G[self:GetName().."DetailConfigEBCondition4"]
	
	self.F.DETAIL_CONFIG.CD_LIST = {
		{ self.F.DETAIL_CONFIG.CD1 }, 
		{ self.F.DETAIL_CONFIG.CD2, self.F.DETAIL_CONFIG.CD_DD2, self.F.DETAIL_CONFIG.CD_EB2 },
		{ self.F.DETAIL_CONFIG.CD3, self.F.DETAIL_CONFIG.CD_DD3, self.F.DETAIL_CONFIG.CD_EB3 },
		{ self.F.DETAIL_CONFIG.CD4, self.F.DETAIL_CONFIG.CD_DD4, self.F.DETAIL_CONFIG.CD_EB4 }
	}
	
	self.F.DETAIL_CONFIG.BTN_SAVE = _G[self:GetName().."DetailConfigButtonApply"]
	self.F.DETAIL_CONFIG.BTN_CLOSE = _G[self:GetName().."DetailConfigButtonClose"]


	self.F.BODY.CONFIG_TRACKER = _G[self.F.BODY:GetName().."Tracker"]
	self.F.BODY.CONFIG_TRACKER.TITLE = _G[self.F.BODY:GetName().."TrackerTopText"]
	self.F.BODY.CONFIG_TRACKER.CONTENTS = _G[self.F.BODY:GetName().."TrackerConfigSFContents"]
	self.F.BODY.CONFIG_TRACKER.TRANSIT = _G[self.F.BODY:GetName().."TrackerTransitSFContents"]
	self.F.BODY.CONFIG_TRACKER.BTN_SAVE = _G[self.F.BODY:GetName().."TrackerBottomBtnSaveTracker"]
	self.F.BODY.CONFIG_TRACKER.BTN_DELETE = _G[self.F.BODY:GetName().."TrackerBottomBtnDelete"]
	self.F.BODY.CONFIG_TRACKER.BTN_CANCEL = _G[self.F.BODY:GetName().."TrackerBottomBtnCancel"]
	self.F.BODY.CONFIG_TRACKER.BTN_COPY = _G[self.F.BODY:GetName().."TrackerBottomBtnCopy"]

	self.F.DD_TRACKER_TRANSIT = _G[self.F.BODY.CONFIG_TRACKER.TRANSIT:GetName().."Transit"]

	self.F.BODY.CONFIG_TRACKER_ELEMENTS = _G[self.F.BODY:GetName().."TrackerElements"]
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.CONTENTS = _G[self.F.BODY:GetName().."TrackerElementsSFContents"]
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_ALL_TRACKER = _G[self.F.BODY:GetName().."TrackerElementsSFNoticeAllTracker"]
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_ALL_TRACKER:SetText(L.TRACKING_ALL_AURA)
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_BOSS_TRACKER = _G[self.F.BODY:GetName().."TrackerElementsSFNoticeBossTracker"]
	self.F.BODY.CONFIG_TRACKER_ELEMENTS.NOTICE_BOSS_TRACKER:SetText(L.TRACKING_BOSS_AURA)
	
	-- self.F.BODY.CONFIG_TRACKER.BTN_SAVE = _G[self.F.BODY:GetName().."TrackerBottomBtnSaveTracker"]

	self.F.BODY.CONFIG_UI = _G[self.F.BODY:GetName().."UI"]
	self.F.BODY.CONFIG_UI.DD_DISPLAY_MODE = _G[self.F.BODY:GetName().."UITopDDLDisplayType"]
	self.F.BODY.CONFIG_UI.DD_CONFIG_MODE = _G[self.F.BODY:GetName().."UITopDDLConfigMode"]
	self.F.BODY.CONFIG_UI.CB_MOVE = _G[self.F.BODY:GetName().."UIBottomCBMove"]
	self.F.BODY.CONFIG_UI.CB_SHOW_ID_TOOPTIP = _G[self.F.BODY:GetName().."UIBottomCBShowIdInTooltip"]

	HDH_AT_DropDown_Init(F.BODY.CONFIG_UI.DD_DISPLAY_MODE, DDP_DISPLAY_MODE_LIST, HDH_AT_OnSelected_Dropdown)
	DBSync(F.BODY.CONFIG_UI.DD_DISPLAY_MODE, COMP_TYPE.DROPDOWN, "ui.%s.common.display_mode")

	HDH_AT_DropDown_Init(F.BODY.CONFIG_UI.DD_CONFIG_MODE, DDP_CONFIG_MODE_LIST, HDH_AT_OnSelected_Dropdown)
	

	-- self.F.BODY.CONFIG_UI.CONTENTS = _G[self.F.BODY:GetName().."UISFContents"]
	-- self.F.BODY.CONFIG_TRACKER.BTN_SAVE = _G[self.F.BODY:GetName().."TrackerBottomBtnSaveTracker"]

	-- self.F.BODY.CONFIG_UI.CONTENTS = _G[self.F.BODY:GetName().."UISFContents"]
	self.F.BODY.CONFIG_UI.MEMU = _G[self.F.BODY:GetName().."UIMenuSFContents"]
	self.F.BODY.CONFIG_UI.CONTENTS = _G[self.F.BODY:GetName().."UIConfigSFContents"]
	
	self.F.BODY_TAB_ELEMENTS = _G[self:GetName().."TabElements"]
	self.F.BODY_TAB_UI = _G[self:GetName().."TabUI"]

	self.BODY_TAB = {
		{ btn = self.F.BODY_TAB_ELEMENTS, content = self.F.BODY.CONFIG_TRACKER_ELEMENTS },
		{ btn = self.F.BODY_TAB_UI, content = self.F.BODY.CONFIG_UI }
	}
	
	F.ED_TRACKER_NAME = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS,      COMP_TYPE.EDIT_BOX, 	  L.TRACKER_NAME)
	F.DD_TRACKER_TYPE = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, 	  COMP_TYPE.DROPDOWN, 	  L.TRACKER_TYPE)
	F.DD_TRACKER_UNIT = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, 	  COMP_TYPE.DROPDOWN, 	  L.TRACKER_UNIT)
	F.DD_TRACKER_AURA_FILTER = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, COMP_TYPE.DROPDOWN, 	  L.AURA_FILTER_TYPE)
	F.DD_TRACKER_AURA_CASTER = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, COMP_TYPE.DROPDOWN, 	  L.AURA_CASTER_TYPE)
	-- F.DD_TRACKER_TRANSIT = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS,   COMP_TYPE.DROPDOWN, 	  L.USE_TANSIT)

	F.BTN_PREV_NEXT = HDH_AT_CreateOptionComponent(F.BODY.CONFIG_TRACKER.CONTENTS, COMP_TYPE.PREV_NEXT_BUTTON, 	  L.DISPLAY_LEVEL)
	F.BTN_PREV_NEXT.BtnPrev:SetScript("OnClick", HDH_AT_OnClick_Button)
	F.BTN_PREV_NEXT.BtnNext:SetScript("OnClick", HDH_AT_OnClick_Button)
	

	HDH_AT_DropDown_Init(F.DD_TRACKER_TYPE, DDP_TRACKER_LIST, HDH_AT_OnSelected_Dropdown)
	HDH_AT_DropDown_Init(F.DD_TRACKER_UNIT, DDP_AURA_UNIT_LIST, HDH_AT_OnSelected_Dropdown)
	HDH_AT_DropDown_Init(F.DD_TRACKER_AURA_FILTER, DDP_AURA_FILTER_LIST, HDH_AT_OnSelected_Dropdown)
	HDH_AT_DropDown_Init(F.DD_TRACKER_AURA_CASTER, DDP_AURA_CASTER_LIST, HDH_AT_OnSelected_Dropdown)

	local tabUIList = self:AppendUITab(UI_TabData, self.F.BODY.CONFIG_UI.MEMU, self.F.BODY.CONFIG_UI.CONTENTS)
	self.UI_TAB = tabUIList
	ChangeTab(tabUIList, 1)

	DBSync(F.BODY.CONFIG_UI.CB_SHOW_ID_TOOPTIP, COMP_TYPE.CHECK_BOX, "show_tooltip_id")

	-- FONT COOLDOWN 
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.DROPDOWN,     L.TIME_FORMAT,  		  "ui.%s.font.cd_format")
	HDH_AT_DropDown_Init(comp, DDP_FONT_CD_FORMAT_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.DROPDOWN,     L.TIME_LOCATION,       "ui.%s.font.cd_location")
	HDH_AT_DropDown_Init(comp, DDP_FONT_CD_LOC_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.COLOR_PICKER, L.FONT_COLOR,          "ui.%s.font.cd_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.COLOR_PICKER, L.UNDER_5S_FONT_COLOR, "ui.%s.font.cd_color_5s")
	comp = HDH_AT_CreateOptionComponent(tabUIList[1].content, COMP_TYPE.SLIDER,       L.FONT_SIZE,           "ui.%s.font.cd_size")

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

	-- FONT NAME
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.DROPDOWN,       L.NAME_ALIGN,         "ui.%s.font.name_align")
	HDH_AT_DropDown_Init(comp, DDP_FONT_NAME_ALIGN_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.CHECK_BOX,     L.DISPLAY_NAME,       "ui.%s.font.show_name")
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.COLOR_PICKER, L.FONT_COLOR,          "ui.%s.font.name_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.COLOR_PICKER, L.FONT_OFF_COLOR,      "ui.%s.font.name_color_off")
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.SLIDER,       L.FONT_SIZE,           "ui.%s.font.name_size")
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.SLIDER,       L.MARGIN_LEFT,           "ui.%s.font.name_margin_left")
	comp = HDH_AT_CreateOptionComponent(tabUIList[4].content, COMP_TYPE.SLIDER,       L.MARGIN_RIGHT,           "ui.%s.font.name_margin_right")

	-- ICON DEFAULT
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.DROPDOWN,       L.COOLDOWN_ANIMATION_DIDRECTION,         "ui.%s.icon.cooldown")
	HDH_AT_DropDown_Init(comp, DDP_ICON_COOLDOWN_LIST, HDH_AT_OnSelected_Dropdown)
	comp = HDH_AT_CreateOptionComponent(tabUIList[5].content, COMP_TYPE.CHECK_BOX,       L.CANCEL_BUFF,         "ui.%s.icon.able_buff_cancel")

	-- ICON SIZE
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.DROPDOWN,       L.ICON_ORDER,         "ui.%s.common.order_by")
	HDH_AT_DropDown_Init(comp, DDP_ICON_ORDER_LIST, HDH_AT_OnSelected_Dropdown)

	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SLIDER,     L.ICON_SIZE,       "ui.%s.icon.size")
	comp:Init(0, 10, 100, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SLIDER, 	L.ICON_MARGIN_VERTICAL,          "ui.%s.common.margin_v")
	comp:Init(1, 0, 500, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SLIDER,       L.ICON_MARGIN_HORIZONTAL,           "ui.%s.common.margin_h")
	comp:Init(1, 0, 500, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.SLIDER,       L.ICON_NUMBER_OF_HORIZONTAL,           "ui.%s.common.column_count")
	comp:Init(1, 1, 20, true, false, nil, L.ROW_N_COL_N)
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.CHECK_BOX,       L.ICON_REVERSE_DISPLAY_V,           "ui.%s.common.reverse_v")
	comp = HDH_AT_CreateOptionComponent(tabUIList[6].content, COMP_TYPE.CHECK_BOX,       L.ICON_REVERSE_DISPLAY_H,           "ui.%s.common.reverse_h")
	
	

	-- ICON COLOR
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.SLIDER,     L.ACTIVED_ICON_ALPHA,       "ui.%s.icon.on_alpha")
	comp:Init(0, 0, 1)
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.SLIDER,     L.INACTIVED_ICON_ALPHA,       "ui.%s.icon.off_alpha")
	comp:Init(0, 0, 1)
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.COLOR_PICKER,     L.ACTIVED_ICON_BORDER_COLOR,       "ui.%s.icon.active_border_color")
	-- comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.COLOR_PICKER, L.COOLDOWN_COLOR,      "ui.%s.icon.cooldown_bg_color")
	-- UI[#UI+1] = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.CHECK_BOX,       L.ICON_REVERSE_DISPLAY_V,           "ui.%s.icon.desaturation")
	comp = HDH_AT_CreateOptionComponent(tabUIList[7].content, COMP_TYPE.CHECK_BOX,       L.USE_DEFAULT_BORDER_COLOR,           "ui.%s.common.default_color")

	-- BAR DEFAULT
	comp = HDH_AT_CreateOptionComponent(tabUIList[8].content, COMP_TYPE.CHECK_BOX,       L.FILL_BAR,         "ui.%s.bar.fill_bar")
	comp = HDH_AT_CreateOptionComponent(tabUIList[8].content, COMP_TYPE.CHECK_BOX,       L.REVERSE_PROGRESS,         "ui.%s.bar.reverse_progress")
	comp = HDH_AT_CreateOptionComponent(tabUIList[8].content, COMP_TYPE.CHECK_BOX,       L.DISPLAY_SPARK,         "ui.%s.bar.show_spark")

	-- BAR SIZE
	comp = HDH_AT_CreateOptionComponent(tabUIList[9].content, COMP_TYPE.DROPDOWN,       L.LOCATION_BAR,         "ui.%s.bar.location")
	HDH_AT_DropDown_Init(comp, DDP_BAR_LOC_LIST, HDH_AT_OnSelected_Dropdown)

	comp = HDH_AT_CreateOptionComponent(tabUIList[9].content, COMP_TYPE.SLIDER, 	L.WIDTH_SIZE,          "ui.%s.bar.width")
	comp:Init(0, 10, 500, true, true, 20)
	comp = HDH_AT_CreateOptionComponent(tabUIList[9].content, COMP_TYPE.SLIDER,       L.HEIGHT_SIZE,           "ui.%s.bar.height")
	comp:Init(0, 10, 500, true, true, 20)
	

	-- BAR COLOR
	comp = HDH_AT_CreateOptionComponent(tabUIList[10].content, COMP_TYPE.DROPDOWN,       L.BAR_TEXTURE,         "ui.%s.bar.texture")
	HDH_AT_DropDown_Init(comp, DDP_BAR_TEXTURE_LIST, HDH_AT_OnSelected_Dropdown, nil, "HDH_AT_DropDownOptionTextureItemTemplate")

	comp = HDH_AT_CreateOptionComponent(tabUIList[10].content, COMP_TYPE.COLOR_PICKER,     L.BG_COLOR,       "ui.%s.bar.bg_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[10].content, COMP_TYPE.COLOR_PICKER,     L.BAR_COLOR,       "ui.%s.bar.color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[10].content, COMP_TYPE.CHECK_BOX,       L.DISPLAY_FILL_BAR,         "ui.%s.bar.use_full_color")
	comp = HDH_AT_CreateOptionComponent(tabUIList[10].content, COMP_TYPE.COLOR_PICKER,     L.FILL_COLOR,       "ui.%s.bar.full_color")
	
	comp = HDH_AT_CreateOptionComponent(tabUIList[11].content, COMP_TYPE.BUTTON,       L.RESET_ADDON)
	comp:SetText(L.RESET)
	self.F.BODY.CONFIG_UI.BTN_RESET = comp
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
	self:SetClampedToScreen(true)
	local x = self:GetLeft()
	local y = self:GetBottom()
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", x, y)
	self:SetClampedToScreen(false)
	self:SetWidth(FRAME_WIDTH)
    self:UpdateFrame()
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
	local COMP_MARGIN = 8
	parent.row = parent.row or 0
	parent.col = parent.col or 0
	
	local x = COMP_WIDTH * parent.col -- + COMP_MARGIN
	local y = -(COMP_HEIGHT + COMP_MARGIN) * (parent.row)
	local component = nil
	local frame = CreateFrame("Frame", (parent:GetName()..'Label'..parent.row), parent)
	frame:SetSize(COMP_WIDTH, COMP_HEIGHT)
	frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', MARGIN_X + x, MARGIN_Y + y)
	frame.text = frame:CreateFontString(nil, 'OVERLAY', "Font_Yellow_M")
	frame.text:SetPoint('LEFT', frame, 'LEFT', COMP_MARGIN, 0)
	frame.text:SetNonSpaceWrap(false)
	frame.text:SetJustifyH('LEFT')
	frame.text:SetJustifyV('CENTER')
	frame.text:SetFontObject("Font_Yellow_S")
	frame.text:SetText(option_name)

	if component_type == COMP_TYPE.CHECK_BOX then
		component = CreateFrame("CheckButton", (parent:GetName()..'CheckButton'..parent.row), parent, "OptionsBaseCheckButtonTemplate")
		component:SetPoint('LEFT', frame, 'RIGHT', 18, 0)
		component:SetScript("OnClick", HDH_AT_UI_OnCheck)

	elseif component_type == COMP_TYPE.BUTTON then
		component = CreateFrame("Button", (parent:GetName()..'Button'..parent.row), parent, "HDH_AT_ButtonTemplate")
		component:SetSize(110, 26)
		component:SetPoint('LEFT', frame, 'RIGHT', 25, 0)
		component:SetText(value or 'None')
		component:SetScript("OnClick", HDH_AT_OnClick_Button)
	
	elseif component_type == COMP_TYPE.EDIT_BOX then
		component = CreateFrame("EditBox", (parent:GetName()..'EditBox'..parent.row), parent, "InputBoxTemplate")
		component:SetSize(110, 26)
		component:SetPoint('LEFT', frame, 'RIGHT', 25, 0)
		component:SetText(value or "")
		component:SetAutoFocus(false) 
		component:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
		component:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
		component:SetMaxLetters(15)

	elseif component_type == COMP_TYPE.DROPDOWN then
		component = CreateFrame("Button", (parent:GetName()..'DropDown'..parent.row), parent, "HDH_AT_DropDownOptionTemplate")
		component:SetSize(115, 22)
		component:SetPoint('LEFT', frame, 'RIGHT', 20, 0)

	elseif component_type == COMP_TYPE.MULTI_SELECTOR then
		component = CreateFrame("FRAME", (parent:GetName()..'MultiSelector'..parent.row), parent, "HDH_AT_MultiSelectorTemplate")
		component:SetSize(115, 200)
		component:SetPoint('TOPLEFT', frame, 'TOPRIGHT', 15, -2)
	-- elseif then

	elseif component_type == COMP_TYPE.SLIDER then
		component = CreateFrame("Slider", (parent:GetName()..'Slider'..parent.row), parent, "HDH_AT_SliderTemplate")
		component:SetSize(115, 17)
		component:SetPoint('LEFT', frame, 'RIGHT', 20, -4)
		component:SetHandler(HDH_AT_OnChangedSlider)
		component:Init(10, 0, 100, true, true, 10)

	elseif component_type == COMP_TYPE.COLOR_PICKER then
		component = CreateFrame("Button", (parent:GetName()..'ColorPicker'..parent.row), parent, "HDH_AT_ColorPickerTemplate")
		component:SetSize(115, 26)
		component:SetPoint('LEFT', frame, 'RIGHT', 22, 0)
		component:SetHandler(HDH_AT_OnSeletedColor)

	elseif component_type == COMP_TYPE.PREV_NEXT_BUTTON then
		component = CreateFrame("Button", (parent:GetName()..'PrevNextButton'..parent.row), parent, "HDH_AT_PrevNextButtonTemplate")
		component:SetSize(115, 26)
		component:SetPoint('LEFT', frame, 'RIGHT', 20, 0)
		-- component:SetHandler(HDH_AT_OnSeletedColor)
	end

	parent.row = parent.row + 1
	DBSync(component, component_type, db_key)
	local w, h = parent:GetParent():GetSize()
	parent:ClearAllPoints()
	parent:SetSize(w, -(y - COMP_HEIGHT))
	parent:SetPoint('TOPLEFT', parent:GetParent(), 'TOPLEFT', 0, 0)
	-- parent:SetPoint('BOTTOMRIGHT', parent:GetParent(), 'BOTTOMRIGHT', 0, 30)
	return component
end


-- function HDH_AT_OnSelectedColor(self)
-- 	if ColorPickerFrame:IsShown() then return end
-- 	local r,g,b,a = self:GetColorRGBA();
-- 	print("call HDH_AT_OnSelectedColor", r,g,b,a)
-- 	-- UpdateFrameDB_CP(ColorPickerFrame.colorButton, r,g,b, ColorPickerFrame.hasOpacity and OpacitySliderFrame:GetValue());
-- 	-- UpdateFrameDB_CP(ColorPickerFrame.colorButton);
-- 	-- -- ColorPickerFrame.colorButton = nil;
-- 	-- if HDH_AT_OP_IsEachSetting() then
-- 	-- 	local tracker = HDH_AT_OP_GetTracker(HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()))
-- 	-- 	if not tracker then return end
-- 	-- 	tracker:UpdateSetting()
-- 	-- 	if UI_LOCK then
-- 	-- 		tracker:SetMove(UI_LOCK)
-- 	-- 	else
-- 	-- 		tracker:Update()
-- 	-- 	end
-- 	-- else
-- 	-- 	HDH_TRACKER.UpdateSettingAll()
-- 	-- 	if UI_LOCK then
-- 	-- 		HDH_TRACKER.SetMoveAll(UI_LOCK)
-- 	-- 	else
-- 	-- 		for k,tracker in pairs(HDH_TRACKER.GetList()) do
-- 	-- 			tracker:Update()
-- 	-- 		end
-- 	-- 	end
-- 	-- end
-- end






