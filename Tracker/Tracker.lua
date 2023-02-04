
local DB = HDH_AT_ConfigDB
local UTIL = HDH_AT_UTIL
local L = HDH_AT_L
--------------------------------------------
-- TRACKER Class 
--------------------------------------------
HDH_TRACKER = {}
HDH_TRACKER.objList = {}
HDH_TRACKER.__index = HDH_TRACKER
HDH_TRACKER.className = "HDH_TRACKER"
HDH_TRACKER.LOCALE = GetLocale()
HDH_TRACKER.CLASSLIST = {}
HDH_TRACKER.TYPE = {}

--------------------------------------------
-- Properties
--------------------------------------------
HDH_TRACKER.ENABLE_MOVE = false
HDH_TRACKER.ONUPDATE_FRAME_TERM = 0.016;
HDH_TRACKER.ANI_SHOW = 1
HDH_TRACKER.ANI_HIDE = 2
HDH_TRACKER.FONT_STYLE = "fonts/2002.ttf";
HDH_TRACKER.MAX_ICONS_COUNT = 10
HDH_TRACKER.BAR_UP_ANI_TERM = 0.1 -- second
HDH_TRACKER.BAR_DOWN_ANI_TERM = 0.05


-------------------------------------------
-- EVENT SCRIPT
-------------------------------------------

local function UpdateCooldown(f, elapsed)
	local spell = f.spell;
	local tracker = f:GetParent().parent;
	if not spell and not tracker then return end
	
	f.elapsed = (f.elapsed or 0) + elapsed;
	if f.elapsed < HDH_TRACKER.ONUPDATE_FRAME_TERM then  return end  -- 30프레임
	f.elapsed = 0
	spell.curTime = GetTime();
	spell.remaining = (spell.endTime or 0) - spell.curTime
	if spell.remaining > 0.0 and spell.duration > 0 then
		tracker:UpdateTimeText(f.timetext, spell.remaining)
		if tracker.ui.common.cooldown ~= DB.COOLDOWN_CIRCLE then
			if f.cd:GetObjectType() == "StatusBar" then 
				f.cd:SetValue(spell.curTime) 
			end
		end
		if tracker.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
			local minV, maxV = f.bar:GetMinMaxValues();
			f.bar:SetValue(tracker.ui.bar.reverse_fill and (maxV-spell.remaining) or (spell.remaining));
			--spell.per = max((spell.remaining/(spell.endTime-spell.startTime)), 0)
			tracker:MoveSpark(f.bar);
		end

		if tracker.ui.common.display_mode ~= DB.DISPLAY_BAR then
			if tracker.ui.icon.cooldown ~= DB.COOLDOWN_CIRCLE then
				spell.per = spell.remaining / spell.duration

				if spell.per < 0.99 and spell.per > 0.01 then
					if not f.iconSatCooldown.spark:IsShown() then
						f.iconSatCooldown.spark:Show()
					end
				else
					if f.iconSatCooldown.spark:IsShown() then
						f.iconSatCooldown.spark:Hide()
					end
				end
				f.iconSatCooldown.curSize = math.ceil(f.icon:GetHeight() * spell.per * 10) /10 
				if (f.iconSatCooldown.curSize ~= f.iconSatCooldown.preSize) then
					if (f.iconSatCooldown.curSize == 0) then f.iconSatCooldown:Hide() end
					if tracker.ui.icon.cooldown == DB.COOLDOWN_LEFT then
						spell.texcoord = 0.07 + (0.86 * spell.per)
						f.iconSatCooldown:SetWidth(f.iconSatCooldown.curSize)
						-- spell.texcoord = math.ceil(spell.texcoord * 10) / 10
						f.iconSatCooldown:SetTexCoord(0.07, spell.texcoord, 0.07, 0.93)
					elseif tracker.ui.icon.cooldown == DB.COOLDOWN_RIGHT then
						spell.texcoord = (0.93 - (0.86 * spell.per))
						f.iconSatCooldown:SetWidth(f.iconSatCooldown.curSize)
						-- spell.texcoord = math.ceil(spell.texcoord * 10) /10
						f.iconSatCooldown:SetTexCoord(spell.texcoord, 0.93, 0.07, 0.93)
					elseif tracker.ui.icon.cooldown == DB.COOLDOWN_UP then
						spell.texcoord = (0.07 + (0.86 * spell.per))
						f.iconSatCooldown:SetHeight(f.iconSatCooldown.curSize)
						-- spell.texcoord = math.ceil(spell.texcoord * 10) /10
						f.iconSatCooldown:SetTexCoord(0.07, 0.93, 0.07, spell.texcoord)
					else
						spell.texcoord = (0.93 - (0.86 * spell.per))
						f.iconSatCooldown:SetHeight(f.iconSatCooldown.curSize)
						-- spell.texcoord = math.ceil(spell.texcoord * 10) /10
						f.iconSatCooldown:SetTexCoord(0.07, 0.93, spell.texcoord, 0.93)
					end
					-- print(spell.per, spell.texcoord, f.iconSatCooldown.curSize)
					f.iconSatCooldown.preSize = f.iconSatCooldown.curSize
				end
			end
		end
		if f.spell.glow == DB.GLOW_CONDITION_TIME then
			tracker:SetGlow(f, true)
		end
	end
	-- tracker:CheckCondition(f, spell.remaining);
end

-- 매 프레임마다 bar frame 그려줌, 콜백 함수
local function OnUpdateCooldown(self, elapsed)
	UpdateCooldown(self:GetParent():GetParent(), elapsed);
end

-- 아이콘이 보이지 않도록 설정되면, 바에서 업데이트 처리를 한다
function HDH_TRACKER:OnUpdateBarValue(elapsed)
	UpdateCooldown(self:GetParent(), elapsed);
end

local function OnMouseDown(self)
	local curT = HDH_TRACKER.Get(self:GetParent().id)
	if not curT then curT = HDH_TRACKER.Get(self:GetParent():GetParent().id) end
	for k,v in pairs(HDH_TRACKER.GetList()) do
		if v.frame.text then
			if v.frame ~= curT.frame then
				v.frame.text:Hide()
			end
		end
	end
end

local function OnMouseUp(self)
	for k,v in pairs(HDH_TRACKER.GetList()) do
		if v.frame.text then
			v.frame.text:Show()
		end
	end
end

local function OnDragUpdate(self)
	local t = HDH_TRACKER.Get(self:GetParent().id)
	if not t then t = HDH_TRACKER.Get(self:GetParent():GetParent().id) end
	t.frame.text:SetText(("%s"):format(t.frame.text.text))
	-- t.frame.text:SetText(("%s\n|cffffffff(%d, %d)"):format(t.frame.text.text, t.frame:GetLeft(),t.frame:GetBottom()))
end

-- 프레임 이동 시킬때 드래그 시작 콜백 함수
local function OnDragStart(self)
	local t = HDH_AURA_TRACKER.Get(self:GetParent().id)
	if not t then t = HDH_AURA_TRACKER.Get(self:GetParent():GetParent().id) end
	t.frame:StartMoving()
end

-- 프레임 이동 시킬때 드래그 끝남 콜백 함수
local function OnDragStop(self)
	local t = HDH_TRACKER.Get(self:GetParent().id)
	if not t then t = HDH_TRACKER.Get(self:GetParent():GetParent().id) end
	t.frame:StopMovingOrSizing()
	if t then
		t.location.x = t.frame:GetLeft()
		t.location.y = t.frame:GetBottom()
		t.frame:ClearAllPoints()
		t.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT" , t.location.x , t.location.y)
	end
	OnMouseUp(self)
end


-------------------------------------------
-- icon frame struct
-------------------------------------------

local function frameBaseSettings(f)
	f:SetClampedToScreen(true)
	f:SetMouseClickEnabled(false);
	f.iconframe = CreateFrame("Frame", nil, f);
	f.iconframe:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
	f.iconframe:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.iconframe:Show();
	
	f.icon = f.iconframe:CreateTexture(nil, 'BACKGROUND')
	f.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	-- f.icon:SetTexCoord(0.08, 0.92, 0.92,0.08)
	f.icon:SetPoint('TOPLEFT', f.iconframe, 'TOPLEFT', 0, 0)
	f.icon:SetPoint('BOTTOMRIGHT', f.iconframe, 'BOTTOMRIGHT', 0, 0)
	
	f.cooldown1 = CreateFrame("StatusBar", nil, f.iconframe)
	f.cooldown1:SetScript('OnUpdate', OnUpdateCooldown)
	f.cooldown1:SetPoint('TOPLEFT', f.iconframe, 'TOPLEFT', 0, 0)
	f.cooldown1:SetPoint('BOTTOMRIGHT', f.iconframe, 'BOTTOMRIGHT', 0, 0)
	f.cooldown1:SetStatusBarTexture("Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg.blp");
	f.cooldown1:Hide();
	f.cooldown1.parent=f;
	f.cd = f.cooldown1
	
	f.cooldown2 = CreateFrame("Cooldown", nil, f.iconframe) -- 원형
	f.cooldown2:SetPoint('TOPLEFT', f.iconframe, 'TOPLEFT', 0, 0)
	f.cooldown2:SetPoint('BOTTOMRIGHT', f.iconframe, 'BOTTOMRIGHT', 0, 0)
	f.cooldown2:SetMovable(true);
	f.cooldown2:SetScript('OnUpdate', OnUpdateCooldown)
	f.cooldown2:SetHideCountdownNumbers(true) 
	f.cooldown2:SetSwipeTexture("Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg.blp"); -- Interface/AddOns/HDH_AuraTracker/cooldown_bg.blp
	f.cooldown2:SetDrawSwipe(true) 
	f.cooldown2:SetReverse(true)
	f.cooldown2:Hide();
	
	local tempf = CreateFrame("Frame", nil, f)
	f.counttext = tempf:CreateFontString(nil, 'OVERLAY')
	f.counttext:SetPoint('TOPLEFT', f, 'TOPLEFT', -1, 0)
	f.counttext:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.counttext:SetNonSpaceWrap(false)
	f.counttext:SetJustifyH('RIGHT')
	f.counttext:SetJustifyV('TOP')
	
	f.timetext = tempf:CreateFontString(nil, 'OVERLAY');
	f.timetext:SetPoint('TOPLEFT', f, 'TOPLEFT', -10, -1)
	f.timetext:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 10, 0)
	f.timetext:SetJustifyH('CENTER')
	f.timetext:SetJustifyV('CENTER')
	f.timetext:SetNonSpaceWrap(false)
	
	f.v1 = tempf:CreateFontString(nil, 'OVERLAY')
	f.v1:SetPoint('TOPLEFT', f, 'TOPLEFT', -1, 0)
	f.v1:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.v1:SetNonSpaceWrap(false)
	f.v1:SetJustifyH('RIGHT')
	f.v1:SetJustifyV('TOP')
	
	f.v2 = tempf:CreateFontString(nil, 'OVERLAY')
	f.v2:SetPoint('TOPLEFT', f, 'TOPLEFT', -1, 0)
	f.v2:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.v2:SetNonSpaceWrap(false)
	f.v2:SetJustifyH('RIGHT')
	f.v2:SetJustifyV('TOP')
	
	tempf:SetFrameLevel(f.cooldown2:GetFrameLevel()+1)

	f.iconSatCooldown = f.iconframe:CreateTexture(nil, 'OVERLAY')
	f.iconSatCooldown:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	-- f.icon:SetTexCoord(0.08, 0.92, 0.92,0.08)
	f.iconSatCooldown:SetPoint('TOPLEFT', f.iconframe, 'TOPLEFT', 0, 0)
	f.iconSatCooldown:SetPoint('BOTTOMRIGHT', f.iconframe, 'BOTTOMRIGHT', 0, 0)
	f.iconSatCooldown.preHeight = 0

	f.iconSatCooldown.spark = f.iconframe:CreateTexture(nil, "OVERLAY");
	f.iconSatCooldown.spark:SetBlendMode("ADD");
	f.iconSatCooldown.spark:Hide()
	
	f.border = CreateFrame("Frame", nil, f.iconframe):CreateTexture(nil, 'OVERLAY')
	f.border:SetTexture([[Interface/AddOns/HDH_AuraTracker/Texture/border.blp]])
	f.border:SetVertexColor(0,0,0)
	-- f.border:SetAllPoints(f);
end

--------------------------------------------
-- do -- TRACKER Static function
--------------------------------------------

	-- function HDH_TRACKER.ReLoad()
	-- 	HDH_TRACKER.objListx
	-- end

function HDH_TRACKER.GetClass(type)
	return HDH_TRACKER.CLASSLIST[type]
end

function HDH_TRACKER.RegClass(type, class)
	HDH_TRACKER.CLASSLIST[type] = class
end

function HDH_TRACKER.New(id, name, type, unit)
	local obj = nil;
	local class = HDH_TRACKER.GetClass(type)
	if class then
		obj = {};
		setmetatable(obj, class)
		obj:Init(id, name, type, unit)
		HDH_TRACKER.AddList(obj)
	end
	return obj
end

function HDH_TRACKER.Delete(trackerId)
	if trackerId then
		local t= HDH_TRACKER.Get(trackerId)
		t:Release()
		HDH_TRACKER.objList[t.id] = nil
	else
		for k, t in pairs(HDH_TRACKER.objList) do
			t:Release()
			HDH_TRACKER.objList[t.id] = nil
		end
	end
end

function HDH_TRACKER.AddList(tracker)
	HDH_TRACKER.objList[tracker.id] = tracker
end

function HDH_TRACKER.ModifyList(oldId, newId)
	if oldId == newId then return end
	HDH_TRACKER.objList[newId] = HDH_TRACKER.objList[oldId]
	HDH_TRACKER.objList[oldId] = nil
end

function HDH_TRACKER.Get(id)
	return HDH_TRACKER.objList[id] or nil
end

function HDH_TRACKER.GetList()
	return HDH_TRACKER.objList
end

function HDH_TRACKER.Updates(trackerId)
	if trackerId then
		local t= HDH_TRACKER.Get(trackerId)
		if t then
			t:Update()
		end
	else
		-- local curTalentId = select(1, GetSpecializationInfo(GetSpecialization()))
		-- local curTraits = C_ClassTalents.GetLastSelectedSavedConfigID(curTalentId)
		local ids = DB:GetTrackerIdsByTraitss(curTalentId, curTraits)
		for _, t in pairs(HDH_TRACKER.GetList()) do
			if t then
				t:Update()
			end
		end
	end

	return HDH_TRACKER.objList
end

-- function HDH_TRACKER.is()

function HDH_TRACKER.InitVaribles(trackerId)
	local id, name, type, unit
	if trackerId then
		id, name, type, unit, _, _, _ = DB:GetTrackerInfo(trackerId)
		tracker = HDH_TRACKER.Get(trackerId)
		tracker:Init(id, name, type, unit)
		-- print(trackerId, tracker)
		-- if not tracker then
		-- 	print('asdf')
		-- 	HDH_TRACKER.New(id, name, type, unit);
		-- else
			
		-- end
	else
		HDH_TRACKER.Delete()
		local trackerIds
		if GetSpecialization() < 5 then
			local talentID, _, _ = GetSpecializationInfo(GetSpecialization())
			local currentTraitsValue = C_ClassTalents.GetLastSelectedSavedConfigID(talentID)
			trackerIds = DB:GetTrackerIdsByTraitss(talentID, currentTraitsValue)
			if not trackerIds or #trackerIds == 0 then return end
		else
			trackerIds = DB:GetTrackerIds()
		end
		
		for _, trackerId in pairs(trackerIds) do
			id, name, type, unit = DB:GetTrackerInfo(trackerId)
			tracker = HDH_TRACKER.Get(id)
			if not tracker then
				HDH_TRACKER.New(id, name, type, unit);
			else
				tracker:Init(id, name, type, unit);
			end
		end
	end
end

function HDH_TRACKER.InitIcons(trackerId)
	if trackerId then
		local t = HDH_TRACKER.Get(trackerId)
		if t then
			t:InitIcons()
		end
	else
		for idx, t in pairs(HDH_TRACKER.GetList()) do
			t:InitIcons()
		end
	end
end

function HDH_TRACKER.UpdateSettings(trackerId)
	if trackerId and DB:HasUI(trackerId) then
		local t = HDH_TRACKER.Get(trackerId)
		if t then
			t:UpdateSetting()
			t:UpdateIcons()
			t:Update()
		end
	else
		for k, t in pairs(HDH_TRACKER.GetList()) do
			if not DB:HasUI(k) then
				t:UpdateSetting()
				t:UpdateIcons()
				t:Update()
			end
		end
	end
end

-- 바 프레임 이동시키는 플래그 및 이동바 생성+출력
function HDH_TRACKER.SetMoveAll(lock)
	if lock then
		HDH_TRACKER.ENABLE_MOVE = true
		for k, tracker in pairs(HDH_TRACKER.GetList()) do
			tracker:SetMove(true)
		end
	else
		HDH_TRACKER.ENABLE_MOVE = false
		for k, tracker in pairs(HDH_TRACKER.GetList()) do
			tracker:SetMove(false)
			
		end
	end
end

	-- function HDH_TRACKER.IsEqualClass(type, className)
	-- 	local ret= false;
	-- 	if type and HDH_GET_CLASS_NAME[type] == className then ret = true; end
	-- 	return ret;
	-- end
	
------------------------------------------
-- end -- TRACKER Static function 
------------------------------------------


------------------------------------------
 -- TRACKER instance function
------------------------------------------

function HDH_TRACKER:Init(id, name, type, unit)
	self.ui = DB:GetUI(id)
	self.location = DB:GetLocation(id)
	self.unit = unit
	self.name = name
	self.id = id
	self.type = type
	
	if self.frame == nil then
		self.frame = CreateFrame("Frame", HDH_AT_ADDON_FRAME:GetName()..id, HDH_AT_ADDON_FRAME)
		self.frame:SetFrameStrata('MEDIUM')
		self.frame:SetClampedToScreen(true)
		self.frame.parent = self
		self.frame.icon = {}
		self.frame.pointer = {}
		
		setmetatable(self.frame.icon, {
			__index = function(t,k) 
				local f = CreateFrame('Button', self.frame:GetName()..k, self.frame)
				t[k] = f
				frameBaseSettings(f)
				self:UpdateIconSettings(f)
				return f
			end}
		)
	else
		self:UpdateSetting()
	end

	self.frame:SetFrameLevel(tonumber(id)*10)
	self.frame:Hide();
	-- self:InitVariblesOption()
	-- self:InitVariblesAura()
	self.frame:ClearAllPoints()
	self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT" , self.location.x, self.location.y)
	self.frame:SetSize(self.ui.icon.size, self.ui.icon.size)
	self:InitIcons()
end

function HDH_TRACKER:ReleaseIcon(idx)
	-- self:StopAni(self.frame.icon[idx]);
	-- AT_StopTimer(self.frame.icon[idx]);
	self.frame.icon[idx]:SetScript('OnDragStart', nil)
	self.frame.icon[idx]:SetScript('OnDragStop', nil)
	self.frame.icon[idx]:SetScript('OnMouseDown', nil)
	self.frame.icon[idx]:SetScript('OnMouseUp', nil)
	self.frame.icon[idx]:SetScript('OnUpdate', nil)
	self.frame.icon[idx]:RegisterForDrag()
	self.frame.icon[idx]:EnableMouse(false);
	if self.frame.icon[idx].bar then 
		self.frame.icon[idx].bar:Hide();
		self.frame.icon[idx].bar:SetParent(nil)
		self.frame.icon[idx].bar = nil;
	end
	self:ActionButton_ReleaseOverlayGlow(self.frame.icon[idx])
	self.frame.icon[idx]:Hide()
	self.frame.icon[idx]:SetParent(nil)
	self.frame.icon[idx].spell = nil
	self.frame.icon[idx] = nil
end

function HDH_TRACKER:ReleaseIcons()
	if not self.frame.icon then return end
	for i=#self.frame.icon, 1, -1 do
		self:ReleaseIcon(i)
	end
end

function HDH_TRACKER:Release()
	self:ReleaseIcons()
	self.frame:Hide()
	self.frame:SetParent(nil)
	self.frame.parent = nil
	self.frame = nil
	if self.timer then
		for k,timer in ipairs(self.timer) do
			timer:Cancel();
			self.timer[k] = nil;
		end
	end
	self.timer = nil
end

function HDH_TRACKER:Modify(newName, newType, newUnit)
	-- HDH_DB_Modify(self.name, newName, newType, newUnit)
	-- HDH_AURA_TRACKER.ModifyList(self.id, newId)
	
	if newType ~= self.type then
		self:Release() -- 프레임 관련 메모리 삭제하고
		DB:TrancateTrackerElements(self.id)
		setmetatable(self, HDH_TRACKER.GetClass(newType)) -- 클래스 변경하고
	end
	self:Init(self.id, newName, newType, newUnit) -- 프레임 초기화 + DB 로드
	if HDH_TRACKER.ENABLE_MOVE then
		self:SetMove(false)
		self:SetMove(true)
	end
end

function HDH_TRACKER:CreateData(spec)
	-- interface
end

function HDH_TRACKER:IsHaveData()
	_, _, _, _, aura_filter = DB:GetTrackerInfo(self.id)
	local cnt;
	if aura_filter ~= DB.AURA_FILTER_REG then
		cnt = HDH_TRACKER.MAX_ICONS_COUNT;
	else
		cnt = DB:GetTrackerElementSize(self.id)   or 0;
	end
	return (cnt > 0) and cnt or false;
end

function HDH_TRACKER:GetClassName()
	return self.className
end

function HDH_TRACKER:UpdateSetting()
	if not self or not self.frame then return end
	self.frame:SetSize(self.ui.icon.size, self.ui.icon.size)
	-- if HDH_TRACKER.ENABLE_MOVE then
	-- 	if self.frame.text then self.frame.text:SetPoint("TOPLEFT", self.frame, "BOTTOMRIGHT", -5, 12) end
	-- end
	if not self.frame.icon then return end
	for k, iconf in pairs(self.frame.icon) do
		self:UpdateIconSettings(iconf)
		-- if self:IsGlowing(iconf) then
		-- 	self:SetGlow(iconf, false)
		-- end
		self:ActionButton_ResizeOverlayGlow(iconf)
		if not iconf.icon:IsDesaturated() then
			iconf.icon:SetAlpha(self.ui.icon.on_alpha)
			iconf.border:SetAlpha(self.ui.icon.on_alpha)
		else
			iconf.icon:SetAlpha(self.ui.icon.off_alpha)
			iconf.border:SetAlpha(self.ui.icon.off_alpha)
		end
	end	
	self:LoadOrderFunc()
	self.location.x = self.frame:GetLeft()
	self.location.y = self.frame:GetBottom()
end


function HDH_TRACKER:GetAnimatedValue(bar, v) -- v:target value
	if bar.targetValue ~= v then
		bar.animatedStartTime = bar.preTime or GetTime();
		bar.targetValue = v;
	end
	local gap = bar.targetValue - bar:GetValue();
	local gapTime;
	if gap ~= 0 then
		if gap > 0 then
			bar.termType = HDH_TRACKER.BAR_UP_ANI_TERM
		else
			bar.termType = HDH_TRACKER.BAR_DOWN_ANI_TERM
		end
		gapTime = (GetTime() - bar.animatedStartTime);
		if gapTime < bar.termType then
			v = gap * (gapTime/bar.termType);
		else
			v = gap;
		end
	else
		v = 0;
	end
	bar.preTime = GetTime();
	return bar:GetValue()+ v;
end

function HDH_TRACKER:MoveSpark(bar, value)
	if not bar or not self.ui.bar.show_spark then return end
	bar.min, bar.max = bar:GetMinMaxValues()
	bar.tmpV = (bar:GetValue() - bar.min)
	if bar.tmpV > 0.0 then
		bar.per = bar.tmpV / (bar.max - bar.min)
		if bar.per >= 1.0 then
			bar.per = 1
			bar.spark:Hide()
			return
		else
			bar.spark:Show()
		end
	else
		bar.per = 0
		bar.spark:Hide()
	end
	
	if bar:GetOrientation() == "HORIZONTAL" then
		if self.ui.bar.reverse_progress then
			bar.spark:SetPoint("CENTER", bar,"RIGHT", -bar:GetWidth() * bar.per, 0);
		else
			bar.spark:SetPoint("CENTER", bar,"LEFT", bar:GetWidth() * bar.per, 0);
		end
	else
		if self.ui.bar.reverse_progress then
			bar.spark:SetPoint("CENTER", bar,"TOP", 0, -bar:GetHeight() * bar.per);
		else
			bar.spark:SetPoint("CENTER", bar,"BOTTOM", 0, bar:GetHeight() * bar.per);
		end
	end
end

function HDH_TRACKER:UpdateArtBar(f)
	local op = self.ui.bar;
	local font = self.ui.font;
	local show_tooltip = self.ui.common.show_tooltip;
	local display_mode = self.ui.common.display_mode
	local hide_icon = (display_mode == DB.DISPLAY_BAR)

	if display_mode ~= DB.DISPLAY_ICON then
		if (f.bar and f.bar:GetObjectType() ~= "StatusBar") then
			f.bar:Hide();
			f.bar:SetParent(nil);
			f.bar = nil;
		end
		if not f.bar then
			f.bar = CreateFrame("StatusBar", nil, f);
			local t= f.bar:CreateTexture(nil,"BACKGROUND");
			t:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg.blp");
			t:SetPoint('TOPLEFT', f.bar, 'TOPLEFT', -1, 1)
			t:SetPoint('BOTTOMRIGHT', f.bar, 'BOTTOMRIGHT', 1, -1)
			f.bar.bg = t;
			f.bar.spark = f.bar:CreateTexture(nil, "OVERLAY");
			f.bar.spark:SetBlendMode("ADD");
			f.bar.spark:SetTexCoord(0, 1, 0, 0.96)
			f.name = f.bar:CreateFontString(nil,"OVERLAY");
		end
		f.bar.bg:SetVertexColor(unpack(op.bg_color));
		if font.show_name then
			f.name:Show();
		else
			f.name:Hide();
		end
		if font.name_align == DB.NAME_ALIGN_TOP or font.name_align == DB.NAME_ALIGN_BOTTOM then
			f.name:SetJustifyH("CENTER");
			f.name:SetJustifyV(font.name_align);
		else
			f.name:SetJustifyH(font.name_align);
			f.name:SetJustifyV("CENTER");
		end
		f.name:SetFont(HDH_TRACKER.FONT_STYLE, font.name_size, "OUTLINE");
		f.name:SetTextColor(unpack(font.name_color));
		f.name:SetPoint('TOPLEFT', f.bar, 'TOPLEFT', font.name_margin_left, -3)
		f.name:SetPoint('BOTTOMRIGHT', f.bar, 'BOTTOMRIGHT', -font.name_margin_right, 3)
		
		if op.reverse_progress then f.bar:SetStatusBarTexture(DB.BAR_TEXTURE[op.texture].texture_r); 
		else f.bar:SetStatusBarTexture(DB.BAR_TEXTURE[op.texture].texture); end
		f.bar:ClearAllPoints();
		if op.location == DB.BAR_LOCATION_T then     
			f.bar:SetSize(op.width, op.height);
			f.bar:SetPoint("BOTTOM",f, hide_icon and "BOTTOM" or "TOP",0,1); 
			f.bar:SetOrientation("Vertical"); f.bar:SetRotatesTexture(true);
			f.bar.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v");
			f.bar.spark:SetSize(op.width*1.15, 19);
		elseif op.location == DB.BAR_LOCATION_B then 
			f.bar:SetSize(op.width,op.height);
			f.bar:SetPoint("TOP",f, hide_icon and "TOP" or "BOTTOM",0,-1); 
			f.bar:SetOrientation("Vertical"); f.bar:SetRotatesTexture(true);
			f.bar.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v");
			f.bar.spark:SetSize(op.width*1.15, 19);
		elseif op.location == DB.BAR_LOCATION_L then 
			f.bar:SetSize(op.width,op.height);
			f.bar:SetPoint("RIGHT",f, hide_icon and "RIGHT" or "LEFT",-1,0); 
			f.bar:SetOrientation("Horizontal"); f.bar:SetRotatesTexture(false);
			f.bar.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark");
			f.bar.spark:SetSize(19, op.height*1.15);
		else 
			f.bar:SetSize(op.width,op.height);
			f.bar:SetPoint("LEFT",f, hide_icon and "LEFT" or "RIGHT",1,0); 
			f.bar:SetOrientation("Horizontal"); f.bar:SetRotatesTexture(false);
			f.bar.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark");
			f.bar.spark:SetSize(19, op.height*1.15);
			
		end
		f.bar:SetStatusBarColor(unpack(op.color));
		-- f.bar:SetAlpha(0.5);
		f.bar:SetReverseFill(op.reverse_progress);
		-- f.bar:Show();
		
		f.bar.spark:Hide();
		-- f.bar.spark:SetPoint("CENTER",f.bar,"RIGHT",0,0);
		self:SetGameTooltip(f.bar, show_tooltip or false)

		if not HDH_TRACKER.ENABLE_MOVE then
			f.bar:SetMouseClickEnabled(false)
		end
	end
end



function HDH_TRACKER:ConnectMoveHandler(count)
	if not count then return end
	for i=1, count do
		f = self.frame.icon[i]
		f:SetScript('OnDragStart', OnDragStart)
		f:SetScript('OnDragStop', OnDragStop)
		f:SetScript('OnMouseDown', OnMouseDown)
		f:SetScript('OnMouseUp', OnMouseUp)
		f:SetScript('OnUpdate', OnDragUpdate)
		f:RegisterForDrag('LeftButton')
		f:EnableMouse(true);
		f:SetMovable(true);
		if f.bar then
			f = f.bar;
			f:SetScript('OnDragStart', OnDragStart)
			f:SetScript('OnDragStop', OnDragStop)
			f:SetScript('OnMouseDown', OnMouseDown)
			f:SetScript('OnMouseUp', OnMouseUp)
			f:SetScript('OnUpdate', OnDragUpdate)
			f:RegisterForDrag('LeftButton')
			f:EnableMouse(true);
			f:SetMovable(true);
		end
	end
end

function HDH_TRACKER:ChangeCooldownType(f, cooldown_type)
	if cooldown_type == DB.COOLDOWN_UP then 
		f.cd = f.cooldown1
		f.cd:SetOrientation("Vertical")
		f.cd:SetReverseFill(false)
		f.cooldown2:Hide()

		f.iconSatCooldown:ClearAllPoints()
		f.iconSatCooldown:SetPoint("TOPLEFT", f.iconframe,"TOPLEFT",0,0)
		f.iconSatCooldown:SetPoint("TOPRIGHT", f.iconframe,"TOPRIGHT",0,0)
		f.iconSatCooldown:SetHeight(self.ui.icon.size)
		f.iconSatCooldown.spark:SetSize(self.ui.icon.size*1.1, 8);
		f.iconSatCooldown.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v");
		f.iconSatCooldown.spark:SetPoint("CENTER", f.iconSatCooldown,"BOTTOM",0,0)

	elseif cooldown_type == DB.COOLDOWN_DOWN  then 
		f.cd = f.cooldown1
		f.cd:SetOrientation("Vertical")
		f.cd:SetReverseFill(true)
		f.cooldown2:Hide()

		f.iconSatCooldown:ClearAllPoints()
		f.iconSatCooldown:SetPoint("BOTTOMLEFT", f.iconframe,"BOTTOMLEFT",0,0)
		f.iconSatCooldown:SetPoint("BOTTOMRIGHT", f.iconframe,"BOTTOMRIGHT",0,0)
		f.iconSatCooldown:SetHeight(self.ui.icon.size)
		f.iconSatCooldown.spark:SetSize(self.ui.icon.size*1.1, 8);
		f.iconSatCooldown.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v");
		f.iconSatCooldown.spark:SetPoint("CENTER", f.iconSatCooldown,"TOP",0,0)

	elseif cooldown_type == DB.COOLDOWN_LEFT  then 
		f.cd = f.cooldown1
		f.cd:SetOrientation("Horizontal"); 
		f.cd:SetReverseFill(true)
		f.cooldown2:Hide()

		f.iconSatCooldown:ClearAllPoints()
		f.iconSatCooldown:SetPoint("TOPLEFT", f.iconframe,"TOPLEFT",0,0)
		f.iconSatCooldown:SetPoint("BOTTOMLEFT", f.iconframe,"BOTTOMLEFT",0,0)
		f.iconSatCooldown:SetWidth(self.ui.icon.size)

		f.iconSatCooldown.spark:SetSize(8, self.ui.icon.size*1.1);
		f.iconSatCooldown.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark");
		f.iconSatCooldown.spark:SetPoint("CENTER", f.iconSatCooldown,"RIGHT",0,0)

	elseif cooldown_type == DB.COOLDOWN_RIGHT then 
		f.cd = f.cooldown1
		f.cd:SetOrientation("Horizontal"); 
		f.cd:SetReverseFill(false)
		f.cooldown2:Hide()

		f.iconSatCooldown:ClearAllPoints()
		f.iconSatCooldown:SetPoint("TOPRIGHT", f.iconframe,"TOPRIGHT",0,0)
		f.iconSatCooldown:SetPoint("BOTTOMRIGHT", f.iconframe,"BOTTOMRIGHT",0,0)
		f.iconSatCooldown:SetWidth(self.ui.icon.size)

		f.iconSatCooldown.spark:SetSize(8, self.ui.icon.size*1.1);
		f.iconSatCooldown.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark");
		f.iconSatCooldown.spark:SetPoint("CENTER", f.iconSatCooldown,"LEFT",0,0)

	else
		f.iconSatCooldown:Hide() 
		f.iconSatCooldown.spark:Hide() 
		f.cd = f.cooldown2
		f.cooldown1:Hide()
	end
end

function HDH_TRACKER:UpdateTimeText(text, value)
	if self.ui.font.cd_format == DB.TIME_TYPE_CEIL then value = value + 1; end
	if value > 5 then text:SetTextColor(unpack(self.ui.font.cd_color)) 
					else text:SetTextColor(unpack(self.ui.font.cd_color_5s)) end
	if value <= 9.9 and self.ui.font.cd_format == DB.TIME_TYPE_FLOAT then 
		text:SetText(('%.1f'):format(value))
	else
		text:SetText(UTIL.AbbreviateTime(value, self.ui.font.cd_abbreviate or false))
	end
end

function HDH_TRACKER:UpdateBarValue(f, isEnding)
	if f.bar and f.name then
		if self.ui.bar.reverse_fill then
			if isEnding then
				f.bar:SetMinMaxValues(0,1); 
				f.bar:SetValue(1); 
				f.name:SetTextColor(unpack(self.ui.font.name_color_off));
				if  self.ui.common.default_color and f.spell.dispelType then
					f.bar:SetStatusBarColor(DebuffTypeColor[f.spell.dispelType or ""].r,
											DebuffTypeColor[f.spell.dispelType or ""].g,
											DebuffTypeColor[f.spell.dispelType or ""].b)
				elseif self.ui.bar.use_full_color then
					f.bar:SetStatusBarColor(unpack(self.ui.bar.full_color));
				end
				f.bar.spark:Hide();
			else
				if self.ui.common.default_color and f.spell.dispelType then
					f.bar:SetStatusBarColor(DebuffTypeColor[f.spell.dispelType or ""].r,
											DebuffTypeColor[f.spell.dispelType or ""].g,
											DebuffTypeColor[f.spell.dispelType or ""].b)
				else
					f.bar:SetStatusBarColor(unpack(self.ui.bar.color));
				end
				local maxV = f.spell.endTime - f.spell.startTime;
				f.bar:SetMinMaxValues(0, maxV); 
				f.bar:SetValue(maxV-f.spell.remaining);
				f.name:SetTextColor(unpack(self.ui.font.name_color));
				if self.ui.bar.show_spark and f.spell.duration > 0 then f.bar.spark:Show(); 
				else f.bar.spark:Hide(); end
			end
		else
			if isEnding then
				f.bar:SetMinMaxValues(0,1); 
				f.bar:SetValue(0); 
				f.name:SetTextColor(unpack(self.ui.font.name_color_off));
				if self.ui.common.default_color and f.spell.dispelType then
					f.bar:SetStatusBarColor(DebuffTypeColor[f.spell.dispelType or ""].r,
											DebuffTypeColor[f.spell.dispelType or ""].g,
											DebuffTypeColor[f.spell.dispelType or ""].b)
				else
					f.bar:SetStatusBarColor(unpack(self.ui.bar.full_color));
				end
				f.bar.spark:Hide();
			else
				local maxV = f.spell.endTime - f.spell.startTime;
				f.bar:SetMinMaxValues(0, maxV); 
				-- f.bar:SetMinMaxValues(f.spell.startTime, f.spell.endTime); 
				f.bar:SetValue(f.spell.remaining); 
				if self.ui.common.default_color and f.spell.dispelType then
					f.bar:SetStatusBarColor(DebuffTypeColor[f.spell.dispelType or ""].r,
											DebuffTypeColor[f.spell.dispelType or ""].g,
											DebuffTypeColor[f.spell.dispelType or ""].b)
				else
					f.bar:SetStatusBarColor(unpack(self.ui.bar.color));
				end
				f.name:SetTextColor(unpack(self.ui.font.name_color));
				if self.ui.bar.show_spark and f.spell.duration > 0 then f.bar.spark:Show(); 
				else f.bar.spark:Hide(); end
			end
		end
	end
end

function HDH_TRACKER:IsSwitchByRemining(icon1, icon2) 
	if not icon1.spell and not icon2.spell then return end
	local s1 = icon1.spell
	local s2 = icon2.spell
	local ret = false;
	if (not s1.isUpdate and s2.isUpdate) then
		ret = true;
	elseif (s1.isUpdate and s2.isUpdate and s1.duration > 0) then
		if (s1.remaining < s2.remaining) or (s2.duration == 0) then
			ret = true;
		end
	elseif (not s1.isUpdate and not s2.isUpdate) and (s1.no <s2.no) then
		ret = true;
	end
	return ret;
end

function HDH_TRACKER:InAsendingOrderByTime()
	local tmp
	local cnt = #self.frame.icon;
	-- local order
	for i = 1, cnt-1 do
		for j = i+1 , cnt do
			if self:IsSwitchByRemining(self.frame.icon[j], self.frame.icon[i]) then
				tmp = self.frame.icon[i];
				self.frame.icon[i] = self.frame.icon[j];
				self.frame.icon[j] = tmp;
			end
		end
	end
end

function HDH_TRACKER:InDesendingOrderByTime()
	local tmp
	local cnt = #self.frame.icon;
	-- local order
	for i = 1, cnt-1 do
		for j = i+1 , cnt do
			if self:IsSwitchByRemining(self.frame.icon[i], self.frame.icon[j]) then
				tmp = self.frame.icon[i];
				self.frame.icon[i] = self.frame.icon[j];
				self.frame.icon[j] = tmp;
			end
		end
	end
end

function HDH_TRACKER:IsSwitchByHappenTime(icon1, icon2) 
	if not icon1.spell and not icon2.spell then return end
	local s1 = icon1.spell
	local s2 = icon2.spell
	local ret = false;
	if (not s1.isUpdate and s2.isUpdate) then
		ret = true;
	elseif (s1.isUpdate and s2.isUpdate) then
		if (s1.happenTime < s2.happenTime) then
			ret = true;
		end
	elseif (not s1.isUpdate and not s2.isUpdate) and (s1.no < s2.no) then
		ret = true;
	end
	return ret;
end

function HDH_TRACKER:InAsendingOrderByCast()
	local tmp
	local cnt = #self.frame.icon;
	-- local order
	for i = 1, cnt-1 do
		for j = i+1 , cnt do
			if self:IsSwitchByHappenTime(self.frame.icon[i], self.frame.icon[j]) then
				tmp = self.frame.icon[i];
				self.frame.icon[i] = self.frame.icon[j];
				self.frame.icon[j] = tmp;
			end
		end
	end
end

function HDH_TRACKER:InDesendingOrderByCast()
	local tmp
	local cnt = #self.frame.icon;
	-- local order
	for i = 1, cnt-1 do
		for j = i+1 , cnt do
			if self:IsSwitchByHappenTime(self.frame.icon[j], self.frame.icon[i]) then
				tmp = self.frame.icon[i];
				self.frame.icon[i] = self.frame.icon[j];
				self.frame.icon[j] = tmp;
			end
		end
	end
end

function HDH_TRACKER:LoadOrderFunc()
	if self.ui.common.order_by == DB.ORDERBY_REG then
		self.OrderFunc = nil;
	elseif self.ui.common.order_by == DB.ORDERBY_CD_ASC then
		self.OrderFunc = self.InAsendingOrderByTime
	elseif self.ui.common.order_by == DB.ORDERBY_CD_DESC then
		self.OrderFunc = self.InDesendingOrderByTime
	elseif self.ui.common.order_by == DB.ORDERBY_CAST_ASC then
		self.OrderFunc = self.InAsendingOrderByCast;
	elseif self.ui.common.order_by == DB.ORDERBY_CAST_DESC then
		self.OrderFunc = self.InDesendingOrderByCast;
	end
end

function HDH_TRACKER:CreateDummySpell(count)
	local icons =  self.frame.icon
	local ui = self.ui
	local curTime = GetTime()
	local prevf, f, spell
	if icons then
		if #icons > count then count = #icons end
	end
	count = count or 1;
	for i=1, count do
		f = icons[i]
		f:SetMouseClickEnabled(false);
		if not f:GetParent() then f:SetParent(self.frame) end
		if f.icon:GetTexture() == nil then
			f.icon:SetTexture("Interface/ICONS/TEMP")
			f.iconSatCooldown:SetTexture("Interface/ICONS/TEMP")
		end
		f:ClearAllPoints()
		prevf = f
		spell = f.spell
		if not spell then spell = {} f.spell = spell end
		spell.always = true
		spell.id = 0
		spell.count = 1 + i
		spell.duration = 50 * i
		spell.happenTime = 0;
		spell.glow = false
		spell.endTime = curTime + spell.duration
		spell.startTime = curTime
		spell.remaining = spell.startTime + spell.duration
		if spell.showValue then
			if spell.showV1 then
				spell.v1 = 1000
			end
		end
		if self.type == HDH_TRACKER.TYPE.BUFF then spell.isBuff = true
												else spell.isBuff = false end
		if ui.icon.cooldown == DB.COOLDOWN_CIRCLE then
			f.cd:SetCooldown(spell.startTime,spell.duration)
		else
			f.cd:SetMinMaxValues(spell.startTime, spell.remaining)
			f.cd:SetValue(spell.startTime+spell.duration);
		end
		if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
			f:SetScript("OnUpdate",nil);
			-- f.bar:SetMinMaxValues(spell.startTime, spell.endTime);
			-- f.bar:SetValue(spell.startTime+spell.duration);
			self:UpdateBarValue(f);
			f.bar:Show();
			spell.name = spell.name or ("NAME"..i);
		end
		f.counttext:SetText(i)
		if (ui.icon.cooldown == DB.COOLDOWN_CIRCLE) then 
			f.icon:SetAlpha(ui.icon.on_alpha)
			f.border:SetAlpha(ui.icon.on_alpha)
		else
			f.icon:SetAlpha(ui.icon.off_alpha)
			f.border:SetAlpha(ui.icon.on_alpha)
		end
		self:SetGameTooltip(f, false)
		spell.isUpdate = true
		f:Show()
	end
	return count;
end

function HDH_TRACKER:SetMove(move)
	if not self.frame then return end
	if move then
		local cnt = self:IsHaveData();
		if cnt then
			if not self.frame.text then
				local tf = CreateFrame("Frame", nil, self.frame)
				tf:SetFrameStrata("HIGH")
				--tf.SetAllPoints(frame)
				local text = tf:CreateFontString(nil, 'OVERLAY')
				self.frame.text = text
				text:ClearAllPoints()
				text:SetFontObject("Font_Yellow_M")
				text:SetWidth(190)
				text:SetHeight(70)
				--text:SetAlpha(0.7)
				
				text:SetJustifyH("LEFT")
				text.text = ("["..self.name.."]")
				text:SetMaxLines(6) 
			end
			self.frame.text:ClearAllPoints();
			if self.ui.common.reverse_v then
				self.frame.text:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT", 0, 20)
			else
				self.frame.text:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", 0, -20)
			end
			self.frame.id = self.id
			self.frame.name = self.name
			self.frame.text:Show()
			self.frame:EnableMouse(true)
			self.frame:SetMovable(true)
			cnt = self:CreateDummySpell(cnt);
			self:ConnectMoveHandler(cnt);
			self:ShowTracker();
			self:UpdateIcons()
		end
	else
		self.frame:Hide();
		self.frame.name = nil
		self.frame.id = nil
		self.frame:EnableMouse(false)
		self.frame:SetMovable(false)
		self.frame:SetScript('OnUpdate', nil)
		if self.frame.text then 
			self.frame.text:Hide() 
			self.frame.text:GetParent():SetParent(nil) 
			self.frame.text = nil
		end
		self:ReleaseIcons()
		self:InitIcons()
	end
end

function HDH_TRACKER:SetGameTooltip(f, show)
	if not HDH_TRACKER.ENABLE_MOVE then
		f:EnableMouse(show)
	end
	if show then
		f:SetScript("OnEnter",function(frame) 
			local spell = f.spell or (f:GetParent() and f:GetParent().spell)
			if not HDH_TRACKER.ENABLE_MOVE and spell and spell.id then
				local isItem = spell.isItem
				local id = spell.id
				local link = isItem and select(2,GetItemInfo(id)) or GetSpellLink(id)
				if not link then return end
				GameTooltip:SetOwner(f, "ANCHOR_BOTTOMRIGHT");
				if self:GetClassName() == "HDH_AURA_TRACKER" and spell.index then
					GameTooltip:SetUnitAura(self.unit, spell.index, self.filter);
				else	
					GameTooltip:SetHyperlink(link)
					--GameTooltip:Show()
				end
			end
		end)
		f:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	else
		f:SetScript("OnEnter", nil)
		f:SetScript("OnLeave", nil)
	end
end

local function ChangeFontLocation(f, fontf, location, op_font)
	local location_list = {op_font.count_location, op_font.cd_location, op_font.v2_location, op_font.v1_location}
	local size_list = {op_font.coun_tsize, op_font.cd_size , op_font.v2_size, op_font.v2_size}
	local margin = 0
	parent = f.iconframe;
	fontf:ClearAllPoints();
	fontf:Show();
	if location == DB.FONT_LOCATION_TL then
		fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', 1, -2)
		fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 200, -30)
		fontf:SetJustifyH('LEFT')
		fontf:SetJustifyV('TOP')
	elseif location == DB.FONT_LOCATION_BL then
		fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', 1, 30)
		fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 200, 1)
		fontf:SetJustifyV('BOTTOM')
		fontf:SetJustifyH('LEFT')
	elseif location == DB.FONT_LOCATION_TR then
		fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -200, -2)
		fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -0, -30)
		fontf:SetJustifyV('TOP')
		fontf:SetJustifyH('RIGHT')
	elseif location == DB.FONT_LOCATION_BR then
		fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -200, 30)
		fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -0, 1)
		fontf:SetJustifyV('BOTTOM')
		fontf:SetJustifyH('RIGHT')
	elseif location == DB.FONT_LOCATION_C then
		fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -100, 15)
		fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 100, -15)
		fontf:SetJustifyH('CENTER')
		fontf:SetJustifyV('CENTER')
	elseif location == DB.FONT_LOCATION_OB then
		fontf:SetPoint('TOPLEFT', parent, 'BOTTOMLEFT', -100, -1)
		fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 100, -40)
		fontf:SetJustifyH('CENTER')
		fontf:SetJustifyV('TOP')
	elseif location == DB.FONT_LOCATION_OT then
		fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -100, 40)
		fontf:SetPoint('BOTTOMRIGHT', parent, 'TOPRIGHT', 100, 0)
		fontf:SetJustifyH('CENTER')
		fontf:SetJustifyV('BOTTOM')
	elseif location == DB.FONT_LOCATION_OL then
		fontf:SetPoint('TOPRIGHT', parent, 'TOPLEFT', -1, 0)
		fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMLEFT', -1, 0)
		fontf:SetWidth(parent:GetWidth()+200);
		fontf:SetJustifyH('RIGHT')
		fontf:SetJustifyV('CENTER')
	elseif location == DB.FONT_LOCATION_OR then
		fontf:SetPoint('TOPLEFT', parent, 'TOPRIGHT', 1, 0)
		fontf:SetPoint('BOTTOMLEFT', parent, 'BOTTOMRIGHT', 1, 0)
		fontf:SetWidth(parent:GetWidth()+200);
		fontf:SetJustifyH('LEFT')
		fontf:SetJustifyV('RIGHT')
	elseif location == DB.FONT_LOCATION_BAR_L then
		fontf:SetPoint('LEFT', f.bar or parent, 'LEFT', 2, 0)
		fontf:SetWidth(parent:GetWidth()+200);
		fontf:SetJustifyH('LEFT')
		fontf:SetJustifyV('CENTER')
	elseif location == DB.FONT_LOCATION_BAR_C then
		fontf:SetPoint('CENTER', f.bar or parent, 'CENTER', 0, 0)
		fontf:SetWidth(parent:GetWidth()+200);
		fontf:SetJustifyH('CENTER')
		fontf:SetJustifyV('CENTER')
	elseif location == DB.FONT_LOCATION_BAR_R then
		fontf:SetPoint('RIGHT', f.bar or parent, 'RIGHT', -2, 0)
		fontf:SetWidth(parent:GetWidth()+200);
		fontf:SetJustifyH('RIGHT')
		fontf:SetJustifyV('CENTER')
	else
		fontf:Hide()
	end
end

-- bar 세부 속성 세팅하는 함수 (나중에 option 을 통해 바 값을 변경할수 있기에 따로 함수로 지정해둠)
function HDH_TRACKER:UpdateIconSettings(f)
	local icon = f.icon
	local op_icon = self.ui.icon
	local op_font = self.ui.font
	local op_bar = self.ui.bar
	local op_common = self.ui.common

	f:SetSize(op_icon.size,op_icon.size)
	f.iconframe:SetSize(op_icon.size,op_icon.size);
	self:SetGameTooltip(f, op_common.show_tooltip or false)
	
	f.border:SetWidth(op_icon.size*1.3)
	f.border:SetHeight(op_icon.size*1.3)
	f.border:SetPoint('CENTER', f.iconframe, 'CENTER', 0, 0)

	if op_icon.cooldown == DB.COOLDOWN_CIRCLE then
		f.cooldown2:SetSwipeColor(0,0,0,0.8)
	else
		-- f.cooldown1:SetStatusBarColor(unpack(op_icon.cooldown_bg_color))
		-- f.cooldown2:SetSwipeColor(unpack(op_icon.cooldown_bg_color))
		f.cooldown1:SetStatusBarColor(0,0,0,0)
		f.cooldown2:SetSwipeColor(0,0,0,0)
	end
	
	--f.cooldown2:SetDrawEdge(false);
	--f.cooldown2.textureImg:SetTexture(unpack(op_icon.cooldown_bg_color));
	
	--f.cooldown2:SetSwipeTexture(f.cooldown2.textureImg:GetTexture(),1,1,1);
	--local tmp = f:CreateTexture(nil,"OVERLAY")
	--tmp:SetTexture();
	
	

	--f.overlay.animIn:Play()
	if 4 > op_icon.size*0.08 then
		op_icon.margin = 4
	else
		op_icon.margin = op_icon.size*0.08
	end
	self:UpdateArtBar(f);
	local counttext = f.counttext
	counttext:SetFont(HDH_TRACKER.FONT_STYLE, op_font.count_size, "OUTLINE")
	--counttext:SetTextHeight(op_font.countsize)
	counttext:SetTextColor(unpack(op_font.count_color))
	ChangeFontLocation(f, counttext, op_font.count_location, op_font)
	
	local v1Text = f.v1
	v1Text:SetFont(HDH_TRACKER.FONT_STYLE, op_font.v1_size, "OUTLINE")
	v1Text:SetTextColor(unpack(op_font.v1_color))
	ChangeFontLocation(f, v1Text, op_font.v1_location, op_font)
	
	local v2Text = f.v2
	v2Text:SetFont(HDH_TRACKER.FONT_STYLE, op_font.v2_size, "OUTLINE")
	v2Text:SetTextColor(unpack(op_font.v2_color))
	ChangeFontLocation(f, v2Text, op_font.v2_location, op_font)
	
	local timetext = f.timetext
	timetext:SetFont(HDH_TRACKER.FONT_STYLE, op_font.cd_size, "OUTLINE")
	timetext:SetTextColor(unpack(op_font.cd_color))
	ChangeFontLocation(f, timetext, op_font.cd_location, op_font)
	
	f.timetext:Show()
	-- if op_icon.show_cooldown then f.timetext:Show()
	-- 						 else f.timetext:Hide() end
	
	self:ChangeCooldownType(f, self.ui.icon.cooldown)

	
	-- 아이콘 숨기기는 바와 연관되어 있기 때문에 바 설정쪽에 위치함.
	if op_common.display_mode == DB.DISPLAY_ICON then
		f.iconframe:Show()
		if f.bar then 
			f.bar:SetScript("OnUpdate",nil); 
			f.bar:Hide()
		end
	elseif op_common.display_mode == DB.DISPLAY_BAR then
		f.iconframe:Hide();
		if f.bar then
			f.bar:SetScript("OnUpdate", self.OnUpdateBarValue); 
			f.bar:Show()
		end
	else -- DISPLAY_ICON_AND_BAR
		f.iconframe:Show();
		if f.bar then
			f.bar:SetScript("OnUpdate", self.OnUpdateBarValue); 
			f.bar:Show()
		end
	end
	
	if not HDH_TRACKER.ENABLE_MOVE then
		if self:GetClassName() == "HDH_AURA_TRACKER" and self.ui.icon.able_buff_cancel then
			f:SetMouseClickEnabled(true);
			f:RegisterForClicks("RightButtonUp");
			-- f:SetScript("OnClick",nil);
			f:SetScript("OnClick", function(self) 
				local tracker = self:GetParent().parent;
				if tracker and tracker.unit and tracker.filter and self.spell.index then
					CancelUnitBuff(tracker.unit, self.spell.index, tracker.filter); 
				end
			end);
		else
			f:SetMouseClickEnabled(false);
			f:SetScript("OnClick",nil);
		end
	end
end

-------------------------------------------
-- 애니메이션 관련
-------------------------------------------

function HDH_TRACKER:ActionButton_SetupOverlayGlow(f)
	-- If we already have a SpellActivationAlert then just early return. We should already be setup
	if f.SpellActivationAlert then
		return;
	end
	local name = f:GetParent():GetName()..'g'..time()
	f.SpellActivationAlert = CreateFrame("Frame", name, f, "ActionBarButtonSpellActivationAlert")
	local frameWidth, frameHeight = f:GetSize();
	f.SpellActivationAlert:SetSize(frameWidth * 1.6, frameHeight * 1.6);
	f.SpellActivationAlert:SetPoint("CENTER", f, "CENTER", 0, 0);
	-- f.SpellActivationAlert:SetPoint("TOPLEFT", f, "TOPLEFT", -frameWidth * 0.3, frameWidth * 0.3);
	-- f.SpellActivationAlert:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", frameWidth * 0.3, -frameWidth * 0.3);
	f.SpellActivationAlert:Hide()
	-- button.SpellActivationAlert.animIn:Play();
end

function HDH_TRACKER:ActionButton_ResizeOverlayGlow(f)
	f = f.iconframe
	if not f.SpellActivationAlert then
		return;
	end
	f.SpellActivationAlert:Hide()
	local frameWidth, frameHeight = f:GetSize();
	f.SpellActivationAlert:SetSize(frameWidth * 1.6, frameHeight * 1.6);
end

function HDH_TRACKER:ActionButton_ReleaseOverlayGlow(f)
	f = f.iconframe
	if not f.SpellActivationAlert then
		return;
	end
	f.SpellActivationAlert:Hide()
	f.SpellActivationAlert:SetParent(nil)
	f.SpellActivationAlert = nil
end

function HDH_TRACKER:ActionButton_ShowOverlayGlow(f)
	f = f.iconframe;
	
	self:ActionButton_SetupOverlayGlow(f)
	if f.SpellActivationAlert.animOut:IsPlaying() then
		f.SpellActivationAlert.animOut:Stop();
	end
	if not f.SpellActivationAlert:IsShown() and not f.SpellActivationAlert.animIn:IsPlaying() then
		f.SpellActivationAlert.animIn:Play();
	end
end

function HDH_TRACKER:ActionButton_HideOverlayGlow(f)
	f = f.iconframe
	if not f.SpellActivationAlert then
		return;
	end

	if f.SpellActivationAlert.animIn:IsPlaying() then
		f.SpellActivationAlert.animIn:Stop();
	end

	if f:IsVisible() and not f.SpellActivationAlert.animOut:IsPlaying() then
		f.SpellActivationAlert.animOut:Play();
	else
		-- f.SpellActivationAlert.animOut:OnFinished();	--We aren't shown anyway, so we'll instantly hide it.
	end
end

function HDH_TRACKER:IsGlowing(f)
	if f.SpellActivationAlert and (f.SpellActivationAlert:IsShown() or f.SpellActivationAlert.animIn:IsPlaying())then
		return true
	else
		return false
	end
end

HDH_TRACKER.DB_Spell = {}
function HDH_TRACKER:IsIgnoreSpellByTalentSpell(spell_id)
	local ret = false;
	if not spell_id then return true end
	if DB_Spell.Ignore and DB_Spell.Ignore[1] then
		local name = DB_Spell.Ignore[1].Spell;
		local show = DB_Spell.Ignore[1].Show;
		local selected = HDH_AT_UTIL.IsTalentSpell(spell_id); -- true / false / nil: not found talent
		if selected == true then
			ret = (not show);
		elseif selected == false then
			ret = show;
		end
	end
	return ret;
end

function HDH_TRACKER:SetGlow(f, bool)
	if f.spell.ableGlow then -- 블리자드 기본 반짝임 효과면 무조건 적용
		self:ActionButton_ShowOverlayGlow(f) return
	end
	if bool and (f.spell and f.spell.glow ~= DB.GLOW_CONDITION_NONE) then
		local value = 0
		local active = false

		if f.spell.glow == DB.GLOW_CONDITION_ACTIVE then
			active = true
		else
			if f.spell.glow == DB.GLOW_CONDITION_TIME then
				value = f.spell.remaining
			elseif f.spell.glow == DB.GLOW_CONDITION_COUNT then
				if f.spell.charges and f.spell.charges.count > 0 then
					value = f.spell.charges.count
				else
					value = f.spell.count or 0
				end
			elseif f.spell.glow == DB.GLOW_CONDITION_VALUE then
				value = f.spell.v1
			end
			if f.spell.glowCondtion == DB.CONDITION_GT then
				active =  (value > f.spell.glowValue)
			elseif f.spell.glowCondtion == DB.CONDITION_LT then
				active =  (value < f.spell.glowValue)
			elseif f.spell.glowCondtion == DB.CONDITION_EQ then
				active =  (value == f.spell.glowValue) 
			end
		end
		if active then
			self:ActionButton_ShowOverlayGlow(f)
		else
			self:ActionButton_HideOverlayGlow(f)
		end

		-- if f.spell.glowCount 
		-- 	and (f.spell.count >= f.spell.glowCount 
		-- 	or (f.spell.charges and f.spell.charges.count >= f.spell.glowCount) ) then 
		-- 	self:ActionButton_ShowOverlayGlow(f)
		-- elseif f.spell.glowV1 and (f.spell.v1 >= f.spell.glowV1) then
		-- 	self:ActionButton_ShowOverlayGlow(f)
		-- elseif f.spell.glowTime then
			
		-- 	if (f.spell.glowTime >= f.spell.remaining) then
		-- 		self:ActionButton_ShowOverlayGlow(f)
		-- 	end
		-- else
		-- 	self:ActionButton_HideOverlayGlow(f)
		-- end
	else
		self:ActionButton_HideOverlayGlow(f)
	end
end

function HDH_TRACKER:GetAni(f, ani_type) -- row 이동 애니
	if ani_type == HDH_TRACKER.ANI_HIDE then
		if not f.aniHide then
			local ag = f:CreateAnimationGroup()
			f.aniHide = ag
			ag.a1 = ag:CreateAnimation("ALPHA")
			ag.a1:SetOrder(1)
			ag.a1:SetDuration(0.5) 
			ag.a1:SetFromAlpha(1);
			ag.a1:SetToAlpha(0.0);
			-- ag.a1:SetStartDelay(8);
			-- ag.a2 = ag:CreateAnimation("ALPHA")
			-- ag.a2:SetOrder(2)
			-- ag.a2:SetStartDelay(8);
			-- ag.a2:SetDuration(8) 
			-- ag.a2:SetFromAlpha(0.5);
			-- ag.a2:SetToAlpha(0);
			ag:SetScript("OnFinished", function(self) 
				self:GetParent():Hide(); 
			end)
			-- ag:SetScript("OnStop",function() f:SetAlpha(1.0);  end)
		end	
		return f.aniHide;
	elseif ani_type == HDH_TRACKER.ANI_SHOW then
		if not f.aniShow then
			local ag = f:CreateAnimationGroup()
			f.aniShow = ag
			ag.a1 = ag:CreateAnimation("ALPHA")
			ag.a1:SetOrder(1)
			ag.a1:SetDuration(0.2)
			ag.a1:SetFromAlpha(0);
			ag.a1:SetToAlpha(1);
			ag.tracker = f.parent
			ag:SetScript("OnFinished",function(self)
				if ag.tracker then
					self.tracker:Update();
				end
			end)
		end
		return f.aniShow;
	end
end

function HDH_TRACKER:ShowTracker()
	self:StartAni(self.frame, HDH_TRACKER.ANI_SHOW);
	-- self.frame:SetAlpha(1);
	-- self.frame:Show();
end

function HDH_TRACKER:HideTracker()
	self:StartAni(self.frame, HDH_TRACKER.ANI_HIDE);
	-- self.frame:Hide();
end

function HDH_TRACKER:StartAni(f, ani_type) -- row 이동 실행
	if ani_type == HDH_TRACKER.ANI_HIDE then
		if self:GetAni(f, HDH_TRACKER.ANI_SHOW):IsPlaying() then self:GetAni(f, HDH_TRACKER.ANI_SHOW):Stop() end
		if f:IsShown() and not self:GetAni(f, ani_type):IsPlaying() then
			self:GetAni(f, ani_type):Play();
		end
	elseif ani_type== HDH_TRACKER.ANI_SHOW then
		if self:GetAni(f, HDH_TRACKER.ANI_HIDE):IsPlaying() then
			self:GetAni(f, HDH_TRACKER.ANI_HIDE):Stop() 
			self:GetAni(f, ani_type):Play();
		end
		if not f:IsShown() and not self:GetAni(f, ani_type):IsPlaying() then
			f:Show();
			self:GetAni(f, ani_type):Play();
		end
	end
end

function HDH_TRACKER:RunTimer(timerName, time, func, ...)
	if not self.timer then self.timer = {} end
	if self.timer[timerName] then
		self.timer[timerName]:Cancel()
	end
	local args = {...}
	self.timer[timerName] = C_Timer.NewTimer(time, function() self.timer[timerName] = nil func(unpack(args)) end)
end

------------------------------------------
-- end -- TRACKER interface function
------------------------------------------


------------------------------------------
-- TRACKER Event
------------------------------------------

local function VersionUpdateDB()
	if DB:GetVersion() == 2.0 then
		local id, name, type, unit, aura_filter, aura_caster, transit
		for _, id in ipairs(DB:GetTrackerIds()) do
			id, name, type, unit, aura_filter, aura_caster, transit = DB:GetTrackerInfo(id)
			if unit == 1 then
				unit = 'player'
			elseif unit == 2 then
				unit = 'target'
			elseif unit == 3 then
				unit = 'focus'
			end
			DB:UpdateTracker(id, name, type, unit, aura_filter, aura_caster, transit)
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
end

local function PLAYER_ENTERING_WORLD()
	if not HDH_TRACKER.IsLoaded then 
		print('|cffffff00Loaded : AuraTracker |cffffffff(Settings: /at, /auratracker, /ㅁㅅ)')
		HDH_TRACKER.startTime = GetTime();
		HDH_AT_ADDON_FRAME:RegisterEvent('VARIABLES_LOADED')
		HDH_AT_ADDON_FRAME:RegisterEvent('PLAYER_REGEN_DISABLED')
		HDH_AT_ADDON_FRAME:RegisterEvent('PLAYER_REGEN_ENABLED')
		HDH_AT_ADDON_FRAME:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
		HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_CONFIG_UPDATED') -- 특성 빌드 설정 변경 완료 됐을때
		HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_CONFIG_DELETED') -- 특성 빌드 설정 변경 완료 됐을때
		-- HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_CONFIG_LIST_UPDATED') -- 특성 빌드 설정 변경 완료 됐을때
		-- HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_COND_INFO_CHANGED') -- 특성 빌드 설정 변경 완료 됐을때
		-- HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_CONFIG_CREATED') -- 특성 빌드 설정 변경 완료 됐을때
		HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_TREE_CURRENCY_INFO_UPDATED') -- 특성 빌드 설정 변경 완료 됐을때
		
	end

	VersionUpdateDB()

	HDH_TRACKER.InitVaribles()
	local trackerList = HDH_TRACKER.GetList()
	for _, t in pairs(trackerList) do
		t:PLAYER_ENTERING_WORLD()
	end
	HDH_TRACKER.IsLoaded = true;
end

-- 이벤트 콜백 함수
local function OnEvent(self, event, ...)
	-- local talentID = select(1, GetSpecializationInfo(GetSpecialization()))
	-- local transitID = C_ClassTalents.GetLastSelectedSavedConfigID(talentID)
	-- local transitName = UTIL.GetTraitsName(transitID)

	-- if not transitName then
	-- 	print("|cffffff00AuraTracker|cffffffff ".. L.NONACTIVATE_TRAIT)
	-- end
	if self.CUR_TRAIT_ID ~= C_ClassTalents.GetLastSelectedSavedConfigID(select(1, GetSpecializationInfo(GetSpecialization()))) then
		self.CUR_TRAIT_ID = C_ClassTalents.GetLastSelectedSavedConfigID(select(1, GetSpecializationInfo(GetSpecialization())))
		HDH_TRACKER.InitVaribles()
		HDH_TRACKER.Updates()
	end
	-- print( event, ...)
	if event =='ACTIVE_TALENT_GROUP_CHANGED' then
		-- HDH_AT_UTIL.IsTalentSpell(nil,nil,true);
		HDH_TRACKER.InitVaribles()
		HDH_TRACKER.Updates()
		if HDH_AT_ConfigFrame and HDH_AT_ConfigFrame:IsShown() then 
			HDH_AT_ConfigFrame:UpdateFrame()
		end
		-- HDH_cashTalentSpell = nil
	
	elseif event == 'PLAYER_REGEN_ENABLED' then	
		if not HDH_TRACKER.ENABLE_MOVE then
			HDH_TRACKER.Updates()
		end
	
	elseif event == 'PLAYER_REGEN_DISABLED' then
		if not HDH_TRACKER.ENABLE_MOVE then
			HDH_TRACKER.Updates()
		end
	
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- self:UnregisterEvent('PLAYER_ENTERING_WORLD')
		PLAY_SOUND = false
		C_Timer.After(3, PLAYER_ENTERING_WORLD)
		C_Timer.After(6, function() PLAY_SOUND = true end)
	elseif event =="GET_ITEM_INFO_RECEIVED" then
	elseif event == "TRAIT_CONFIG_UPDATED" then
		HDH_TRACKER.InitVaribles()
		HDH_TRACKER.Updates()
		if HDH_AT_ConfigFrame:IsShown() then
			HDH_AT_ConfigFrame:UpdateFrame()
		end
	elseif event == "TRAIT_CONFIG_DELETED" then
		DB:CheckTraitsDB()
		HDH_TRACKER.InitVaribles()
		if HDH_AT_ConfigFrame:IsShown() then
			HDH_AT_ConfigFrame:UpdateFrame()
		end
	elseif event == "TRAIT_CONFIG_CREATED" then -- 현재 사용 안함
		HDH_TRACKER.InitVaribles()
		if HDH_AT_ConfigFrame:IsShown() then
			HDH_AT_ConfigFrame:UpdateFrame()
		end
	elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		-- HDH_TRACKER.warining_count = HDH_TRACKER.warining_count or 0
		-- if HDH_TRACKER.warining_count % 20 == 0 then
		-- 	print('|cffffff00AuraTracker:|r '..L.PLASE_RESELECT_TRATIS_2)
		-- end
		-- HDH_TRACKER.warining_count = HDH_TRACKER.warining_count + 1
	end
end

-- 애드온 로드 시 가장 먼저 실행되는 함수
local function OnLoad(self)
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	--self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
end
	
HDH_AT_ADDON_FRAME = CreateFrame("Frame", "HDH_AT_iconframe", UIParent) -- 애드온 최상위 프레임
HDH_AT_ADDON_FRAME:SetScript("OnEvent", OnEvent)
OnLoad(HDH_AT_ADDON_FRAME)
