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
HDH_TRACKER.ONUPDATE_FRAME_TERM = 0.1;
HDH_TRACKER.ANI_SHOW = 1
HDH_TRACKER.ANI_HIDE = 2
HDH_TRACKER.FONT_STYLE = "fonts/2002.ttf";
HDH_TRACKER.MAX_ICONS_COUNT = 10
HDH_TRACKER.BAR_UP_ANI_TERM = .15 -- second
HDH_TRACKER.BAR_DOWN_ANI_TERM = .15
HDH_TRACKER.GlobalCooldown = 1.9; -- default GC: 1.332
HDH_TRACKER.EndCooldown = 0.09;

HDH_TRACKER.startTime = 0

-------------------------------------------
-- EVENT SCRIPT
-------------------------------------------

local function UpdateCooldown(f, elapsed)
	local spell = f.spell;
	local tracker = f:GetParent().parent;
	if not spell or not tracker then return end
	
	-- f.elapsed = (f.elapsed or 0) + elapsed;
	-- if f.elapsed < HDH_TRACKER.ONUPDATE_FRAME_TERM then  return end  -- 30프레임
	-- f.elapsed = 0

	f.skip = (f.skip or 0) + 1
	if f.skip % 3 ~= 0 and elapsed < 0.03 then return end
	f.skip = 0

	spell.curTime = GetTime();
	spell.remaining = (spell.endTime or 0) - spell.curTime
	if spell.remaining > 0.0 and spell.duration > HDH_TRACKER.GlobalCooldown then
		tracker:UpdateTimeText(f.timetext, spell.remaining)

		if tracker.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
			tracker:UpdateBarValue(f, GetTime())
		end
		if f.spell.glow == DB.GLOW_CONDITION_TIME then
			tracker:UpdateGlow(f, true)
		end
	else
		f.timetext:SetText("")
	end
end

local function OnUpdateGlowColor(self, elapsed)
	self.sparkElapsed = (self.sparkElapsed or 0) + elapsed
	if self.sparkElapsed < (HDH_TRACKER.ONUPDATE_FRAME_TERM/2) or not self:GetParent().spell then return end
	self.playing = (self.playing or 0) + self.sparkElapsed
	self.sparkElapsed = 0
	self.p = HDH_AT_UTIL.LogScale(math.max(math.min((1.25 - (GetTime() % (1/self:GetParent().spell.glowEffectPerSec) + .001) / (1/self:GetParent().spell.glowEffectPerSec*0.8)), 1.), 0.3))
	self.p_c = math.max(self.p, 0.5)
	self.icon_size = self:GetParent():GetParent().parent.ui.icon.size
	
	if (math.min(1.4, self.playing / 0.25)) == 1.4 then
		self.color:SetSize(self.icon_size * 1.31, self.icon_size * 1.31)
		self.spot:SetVertexColor(self.p, self.p, self.p, 0.74)
		self.color:SetVertexColor(self:GetParent().spell.glowEffectColor[1] * self.p_c, 
								  self:GetParent().spell.glowEffectColor[2] * self.p_c, 
								  self:GetParent().spell.glowEffectColor[3] * self.p_c, 
								  self:GetParent().spell.glowEffectColor[4] * self.p_c)
		self.spot:SetSize(self.icon_size, self.icon_size)
	else -- starting animation
		self.color:SetSize(
			self.icon_size * (1.1 + (HDH_AT_UTIL.LogScale(self.playing/0.25) *.4)), 
			self.icon_size * (1.1 + (HDH_AT_UTIL.LogScale(self.playing/0.25) *.4)))
		self.spot:SetSize(self.icon_size * (0.8 + (HDH_AT_UTIL.LogScale(self.playing/0.25) * 0.3)),  
						  self.icon_size * (0.8 + (HDH_AT_UTIL.LogScale(self.playing/0.25) * 0.3)))
		self.spot:SetVertexColor(1, 1, 1, 1)
		self.color:SetVertexColor(self:GetParent().spell.glowEffectColor[1], 
								  self:GetParent().spell.glowEffectColor[2], 
								  self:GetParent().spell.glowEffectColor[3], 
								  self:GetParent().spell.glowEffectColor[4])
	end
end

-------------------------------------------
-- icon frame struct
-------------------------------------------

local function frameBaseSettings(f)
	f:SetClampedToScreen(true)
	f:SetMouseClickEnabled(false);
	f.icon = CreateFrame("Frame", nil, f, "HDH_AT_CooldownIconTemplate")
	f.icon:SetAllPoints(true)
	f.icon:Show()
	
	local tempf = CreateFrame("Frame", nil, f)
	tempf:SetFrameLevel(f.icon:GetFrameLevel() + 5)
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
	f.timetext:SetJustifyV('MIDDLE')
	f.timetext:SetNonSpaceWrap(false)
	
	f.v1 = tempf:CreateFontString(nil, 'OVERLAY')
	f.v1:SetPoint('TOPLEFT', f, 'TOPLEFT', -1, 0)
	f.v1:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.v1:SetNonSpaceWrap(false)
	f.v1:SetJustifyH('RIGHT')
	f.v1:SetJustifyV('TOP')
		
	tempf = CreateFrame("Frame", nil, f)
	tempf:SetPoint('TOPLEFT', f.icon, 'TOPLEFT', 0, 0)
	tempf:SetPoint('BOTTOMRIGHT', f.icon, 'BOTTOMRIGHT', 0, 0)
	tempf:SetScript("Onupdate", OnUpdateGlowColor)
	tempf:SetFrameLevel(f.icon:GetFrameLevel() + 4)
	f.icon.spark = tempf
	f.icon.spark.color = tempf:CreateTexture(nil, 'BORDER')
	f.icon.spark.color:SetTexture([[Interface/AddOns/HDH_AuraTracker/Texture/spark_rect.blp]])
	f.icon.spark.color:SetPoint('CENTER', tempf, 'CENTER', 0, 0)
	f.icon.spark.spot = tempf:CreateTexture(nil, 'OVERLAY')
	f.icon.spark.spot:SetTexture([[Interface/AddOns/HDH_AuraTracker/Texture/border2.blp]])
	f.icon.spark.spot:SetBlendMode("ADD")
	f.icon.spark.spot:SetPoint('CENTER', tempf, 'CENTER', 0, 0)

	f:SetScript('OnUpdate', UpdateCooldown)
end

--------------------------------------------
-- do -- TRACKER Static function
--------------------------------------------

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
			HDH_TRACKER.objList[t.id] = nil
			t:Release()
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
		for _, t in pairs(HDH_TRACKER.GetList()) do
			if t then
				t:Update()
			end
		end
	end

	return HDH_TRACKER.objList
end

function HDH_TRACKER.InitVaribles(trackerId)
	local id, name, type, unit
	local tracker
	if trackerId then
		id, name, type, unit, _, _, _ = DB:GetTrackerInfo(trackerId)
		tracker = HDH_TRACKER.Get(trackerId)
		tracker:Init(id, name, type, unit)
	else
		HDH_TRACKER.Delete()
		local trackerIds = {}
		if HDH_AT_UTIL.GetSpecialization() < 5 then
			local talentID, _, _ = HDH_AT_UTIL.GetSpecializationInfo(HDH_AT_UTIL.GetSpecialization())
			if talentID then
				local currentTraitsValue = HDH_AT_UTIL.GetLastSelectedSavedConfigID(talentID)
				trackerIds = DB:GetTrackerIdsByTraits(talentID, currentTraitsValue)
				if not trackerIds or #trackerIds == 0 then return end
			end
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

function HDH_TRACKER.InitIcon(trackerId)
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
			t:UpdateAllIcons()
			t:Update()
			if HDH_TRACKER.ENABLE_MOVE then
				t:UpdateMoveFrame()
			end
		end
	else
		for k, t in pairs(HDH_TRACKER.GetList()) do
			if not DB:HasUI(k) then
				t:UpdateSetting()
				t:UpdateAllIcons()
				t:Update()
				if HDH_TRACKER.ENABLE_MOVE then
					t:UpdateMoveFrame()
				end
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
	self.frame:ClearAllPoints()
	self.frame:SetPoint("CENTER", UIParent, "CENTER" , self.location.x, self.location.y)
	self.frame:SetSize(self.ui.icon.size, self.ui.icon.size)
	self:InitIcons()
end

function HDH_TRACKER:ReleaseIcon(idx)
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
		for k,timer in pairs(self.timer) do
			timer:Cancel();
			self.timer[k] = nil;
		end
	end
	self.timer = nil
end

function HDH_TRACKER:GetElementSize()
	if self.frame.icon then
		return #self.frame.icon
	else
		return 0
	end
end

function HDH_TRACKER:Modify(newName, newType, newUnit)
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

function HDH_TRACKER:CreateData()
	-- interface
end

function HDH_TRACKER:GetElementCount()
	local aura_filter
	local cnt;
	_, _, _, _, aura_filter = DB:GetTrackerInfo(self.id)
	if aura_filter ~=nil and aura_filter ~= DB.AURA_FILTER_REG then
		cnt = HDH_TRACKER.MAX_ICONS_COUNT;
	else
		cnt = (self.frame.icon and #self.frame.icon) or DB:GetTrackerElementSize(self.id) or 0;
	end
	return (cnt > 0) and cnt or 0;
end

function HDH_TRACKER:GetClassName()
	return self.className
end

function HDH_TRACKER:UpdateSetting()
	if not self or not self.frame then return end
	self.frame:SetSize(self.ui.icon.size, self.ui.icon.size)
	if not self.frame.icon then return end
	for k, f in pairs(self.frame.icon) do
		self:UpdateIconSettings(f)
		self:ActionButton_ResizeOverlayGlow(f)
	end	
	self:LoadOrderFunc()
	local x, y = UTIL.AdjustLocation(self.frame:GetLeft() + (self.ui.icon.size/2), self.frame:GetBottom()+(self.ui.icon.size/2))
	self.location.x = x
	self.location.y = y
end

function HDH_TRACKER:UpdateBarSettings(f)
	local op = self.ui.bar;
	local font = self.ui.font;
	local show_tooltip = self.ui.common.show_tooltip;
	local display_mode = self.ui.common.display_mode
	local hide_icon = (display_mode == DB.DISPLAY_BAR)
	local splitPoints = nil
	local splitPointType = nil
	if f.spell then
		splitPoints = f.spell.barSplitPoints
		splitPointType = f.spell.barSplitPointType
	end

	if display_mode ~= DB.DISPLAY_ICON then
		if not f.bar then
			f.bar = CreateFrame("Frame", nil, f, "HDH_AT_MultiStatusBarTemplate")
		end
		local bar = f.bar
		bar:Setup(nil, splitPoints, splitPointType, op.cooldown_progress, op.to_fill, DB.BAR_TEXTURE[op.texture].texture, DB.BAR_TEXTURE[op.texture].texture_r)
		bar:SetBackgroundColor(unpack(op.bg_color))
		if op.use_full_color and not self.ui.common.default_color then
			bar:UseChangedStatusColor(op.color, op.full_color)
		else
			bar:UseChangedStatusColor(nil)
			bar:SetStatusBarColor(unpack(op.color))
		end
		bar:EnableSpark(op.show_spark, op.spark_color or {1, 1, 1, 0.7})
		bar:SetSize(op.width, op.height)
		bar:SetTextLocation(font.name_location, font.name_margin_left, font.name_margin_right)
		bar:SetTextSize(font.name_size, HDH_TRACKER.FONT_STYLE)
		bar:SetTextColor(font.name_color, font.name_color_off)

		bar:ClearAllPoints();
		if op.location == DB.BAR_LOCATION_T then     
			bar:SetPoint("BOTTOM",f, hide_icon and "BOTTOM" or "TOP", 0, 1)
		elseif op.location == DB.BAR_LOCATION_B then 
			bar:SetPoint("TOP",f, hide_icon and "TOP" or "BOTTOM", 0, -1)
		elseif op.location == DB.BAR_LOCATION_L then 
			bar:SetPoint("RIGHT",f, hide_icon and "RIGHT" or "LEFT", -1, 0)
		else 
			bar:SetPoint("LEFT",f, hide_icon and "LEFT" or "RIGHT", 1, 0)
		end

		if hide_icon then
			f:GetSize(bar)
		end

		self:SetGameTooltip(bar, show_tooltip or false)
		if not HDH_TRACKER.ENABLE_MOVE then
			bar:SetMouseClickEnabled(false)
		end
		f.bar:Show()
	else
		if f.bar then
			f.bar:Hide()
			f.bar:SetParent(nil)
			f.bar = nil
		end
	end
end

function HDH_TRACKER:Update()
	-- interface
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

function HDH_TRACKER:UpdateBarValue(f, value)
	f.bar:SetValue(value)
end

function HDH_TRACKER:UpdateBarMinMaxValue(f, minV, maxV, value, r, g, b, a)
	if f.bar then
		if r then
			f.bar:SetStatusBarColor(r, g, b, a or 1)
		end
		f.bar:SetMinMaxValues(minV, maxV)
		f.bar:SetValue(value)
	end
end

function HDH_TRACKER:GetBarMax(elementIdx)
	local ret = 0 
	if self.frame.icon[elementIdx] and self.frame.icon[elementIdx].spell.duration then
		ret = self.frame.icon[elementIdx].spell.tmpBarMax
	end
	return ret 
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
	local curTime = GetTime()
	local f, spell
	-- if icons then
	-- 	if #icons > count then count = #icons end
	-- end
	count = count or 1;
	for i=1, count do
		f = icons[i]
		f:SetMouseClickEnabled(false);
		if not f:GetParent() then f:SetParent(self.frame) end
		if f.icon:GetTexture() == nil then
			f.icon:SetTexture("Interface/ICONS/TEMP")
		end
		spell = f.spell
		if not spell then spell = {} f.spell = spell end
		spell.display = DB.SPELL_ALWAYS_DISPLAY
		spell.id = 0
		spell.no = i
		spell.count = i
		spell.overlay = 0
		spell.duration = 50 * i
		spell.happenTime = 0;
		spell.glow = false
		spell.endTime = curTime + spell.duration
		spell.startTime = curTime
		spell.remaining = spell.duration
		if spell.showValue then
			if spell.showV1 then
				spell.v1 = 1000
			end
		end
		if self.type == HDH_TRACKER.TYPE.BUFF then spell.isBuff = true
											  else spell.isBuff = false end
		f.icon:SetCooldown(spell.startTime, spell.duration)
		f.icon:UpdateCooldowning()
		if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
			f:SetScript("OnUpdate",nil);
			self:UpdateBarMinMaxValue(f, spell.startTime, spell.endTime, spell.startTime);
			f.bar:Show();
			spell.name = spell.name or ("NAME"..i);
		end
		f.counttext:SetText(i)
		self:SetGameTooltip(f, false)
		spell.isUpdate = true
		f:Show()
	end

	if self.frame.icon then
		for i = #self.frame.icon, count + 1, -1 do
			self:ReleaseIcon(i)
		end
	end
	return count
end

function HDH_TRACKER:IsRaiding()
	local boss_unit, boss_guid
	for i = 1, MAX_BOSS_FRAMES do
		boss_unit = "boss"..i;
		boss_guid = UnitGUID(boss_unit);
		if boss_guid then
			return true
		end
	end
	return false
end

function HDH_TRACKER:UpdateMoveFrame(isDragging)
	local x, y, w, h, editingY, editingX
	local top, bottom, left, right
	local col_size = math.min(self.ui.common.column_count, #self.frame.icon)
	editingY = 0	
	editingX = 0
	if self.ui.common.display_mode == DB.DISPLAY_ICON then
		if self.ui.common.reverse_v then
			top = self.frame.icon[#self.frame.icon]
			bottom = self.frame.icon[1]
		else
			top = self.frame.icon[1]
			bottom = self.frame.icon[#self.frame.icon]
		end

		if self.ui.common.reverse_h then
			left = self.frame.icon[col_size]
			right = self.frame.icon[1]
		else
			left = self.frame.icon[1]
			right = self.frame.icon[col_size]
		end

	elseif self.ui.common.display_mode == DB.DISPLAY_BAR then
		if self.ui.bar.location == DB.BAR_LOCATION_T or self.ui.bar.location == DB.BAR_LOCATION_B then
			if self.ui.common.reverse_h then
				editingX = -(self.ui.bar.width - self.ui.icon.size) /2
			else
				editingX = (self.ui.bar.width - self.ui.icon.size) /2
			end
		else
			if self.ui.common.reverse_v then
				editingY = ((self.ui.bar.height - self.ui.icon.size) /2)
			else
				editingY = - ((self.ui.bar.height - self.ui.icon.size) /2)
			end
		end

		if self.ui.common.reverse_v then
			top = self.frame.icon[#self.frame.icon].bar
			bottom = self.frame.icon[1].bar
		else
			top = self.frame.icon[1].bar
			bottom = self.frame.icon[#self.frame.icon].bar
		end

		if self.ui.common.reverse_h then
			left = self.frame.icon[col_size].bar
			right = self.frame.icon[1].bar
		else
			left = self.frame.icon[1].bar
			right = self.frame.icon[col_size].bar
		end
	else
		if self.ui.bar.location == DB.BAR_LOCATION_T or self.ui.bar.location == DB.BAR_LOCATION_B then
			if self.ui.common.reverse_h then
				editingX = -math.max(0, (self.ui.bar.width - self.ui.icon.size) /2) 
			else
				editingX = math.max(0,  (self.ui.bar.width - self.ui.icon.size) /2)
			end
		else
			if self.ui.common.reverse_v then
				editingY = math.max(0, (self.ui.bar.height - self.ui.icon.size) /2) 
			else
				editingY = - math.max(0,  (self.ui.bar.height - self.ui.icon.size) /2)
			end
		end

		if self.ui.common.reverse_v then
			if self.ui.bar.location == DB.BAR_LOCATION_T then
				top = self.frame.icon[#self.frame.icon].bar
				bottom = self.frame.icon[1]
			elseif self.ui.bar.location == DB.BAR_LOCATION_B then
				editingY = editingY + self.ui.bar.height
				top = self.frame.icon[#self.frame.icon]
				bottom = self.frame.icon[1].bar
			else
				if self.ui.icon.size > self.ui.bar.height then
					top = self.frame.icon[#self.frame.icon]
					bottom = self.frame.icon[1]
				else
					top = self.frame.icon[#self.frame.icon].bar
					bottom = self.frame.icon[1].bar
				end
			end
		else
			if self.ui.bar.location == DB.BAR_LOCATION_T then
				editingY = editingY - self.ui.bar.height
				top = self.frame.icon[1].bar
				bottom = self.frame.icon[#self.frame.icon]
			elseif self.ui.bar.location == DB.BAR_LOCATION_B then
				top = self.frame.icon[1]
				bottom = self.frame.icon[#self.frame.icon].bar
			else
				if self.ui.icon.size > self.ui.bar.height then
					top = self.frame.icon[1]
					bottom = self.frame.icon[#self.frame.icon]
				else
					top = self.frame.icon[1].bar
					bottom = self.frame.icon[#self.frame.icon].bar
				end
			end
		end

		if self.ui.common.reverse_h then
			if self.ui.bar.location == DB.BAR_LOCATION_L then
				left = self.frame.icon[col_size].bar
				right = self.frame.icon[1]
			elseif self.ui.bar.location == DB.BAR_LOCATION_R then
				editingX = editingX - self.ui.bar.width
				left = self.frame.icon[col_size]
				right = self.frame.icon[1].bar
			else
				if self.ui.icon.size > self.ui.bar.width then
					left = self.frame.icon[col_size]
					right = self.frame.icon[1]
				else
					left = self.frame.icon[col_size].bar
					right = self.frame.icon[1].bar
				end
			end
		else
			if self.ui.bar.location == DB.BAR_LOCATION_L then
				editingX = editingX + self.ui.bar.width
				left = self.frame.icon[1].bar
				right = self.frame.icon[col_size]
			elseif self.ui.bar.location == DB.BAR_LOCATION_R then
				left = self.frame.icon[1]
				right = self.frame.icon[col_size].bar
			else
				if self.ui.icon.size > self.ui.bar.width then
					left = self.frame.icon[1]
					right = self.frame.icon[col_size]
				else
					left = self.frame.icon[1].bar
					right = self.frame.icon[col_size].bar
				end
			end
		end
	end

	self.frame.moveFrame.active:ClearAllPoints()
	self.frame.moveFrame.active:SetPoint("TOP", top, "TOP", 0, 0)
	self.frame.moveFrame.active:SetPoint("BOTTOM", bottom, "BOTTOM", 0, 0)
	self.frame.moveFrame.active:SetPoint("LEFT", left, "LEFT", 0, 0)
	self.frame.moveFrame.active:SetPoint("RIGHT", right, "RIGHT", 0, 0)

	if not isDragging then
		self.frame.moveFrame:ClearAllPoints()
		self.frame.moveFrame:SetSize(self.frame.moveFrame.active:GetSize())
		self.frame.moveFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.frame.moveFrame.active:GetLeft(), self.frame.moveFrame.active:GetBottom())

		self.frame.moveFrame.editingX = editingX
		self.frame.moveFrame.editingY = editingY
	end

	self.frame.moveFrame.text:ClearAllPoints();
	if self.frame.moveFrame.isSelected or isDragging then
		self.frame.moveFrame.text:SetPoint("TOPLEFT", self.frame.moveFrame.active, "TOPLEFT", 0, 1)
		self.frame.moveFrame.text:SetPoint("BOTTOMRIGHT", self.frame.moveFrame.active, "BOTTOMRIGHT", 0, -1)
	else
		self.frame.moveFrame.text:SetPoint("BOTTOM", self.frame.moveFrame, "TOP", 0, 4)
		if select(1, self.frame.moveFrame.active:GetSize()) > 100 then
			self.frame.moveFrame.active:SetPoint("LEFT", left, "LEFT", 0, 0)
			self.frame.moveFrame.active:SetPoint("RIGHT", right, "RIGHT", 0, 0)
		else
			self.frame.moveFrame.text:SetWidth(100)
		end
	end
end

local function OnMouseDown_MoveFrame(self)
	local cur = HDH_TRACKER.Get(self:GetParent().id)
	self.isDragging = true
	self:StartMoving()
	cur:UpdateMoveFrame()
	local x, y= self:GetCenter()
	self.preX = math.ceil(x)
	self.preY = math.ceil(y)
	
	local trackerList = HDH_TRACKER.GetList()
	for _, t in pairs(trackerList) do
		if t.id ~= self:GetParent().id then
			if t.frame.moveFrame then
				t.frame.moveFrame.isSelected = false
				t:UpdateMoveFrame()
			end
		end
	end
end

local function OnMouseUp_MoveFrame(self)
	self.isDragging = false
	self:StopMovingOrSizing() 
	local x, y= self:GetCenter()
	if math.ceil(x) ~= self.preX or self.preY ~= math.ceil(y) then
		self.isSelected = true
	else
		self.isSelected = not self.isSelected
	end
	local cur = HDH_TRACKER.Get(self:GetParent().id)
	cur:UpdateMoveFrame()

	if HDH_AT_ConfigFrame.trackerId ~= self:GetParent().id then
		local index = HDH_AT_ConfigFrame:GetTrackerIndex(self:GetParent().id)
		if index then
			HDH_AT_ConfigFrame:ChangeBody(nil, index)
		end
	end
end

local function OnUpdate_MoveFrame(self)
	local t = HDH_TRACKER.Get(self:GetParent().id)

	if self.isDragging then
		local x, y
		if t.ui.common.reverse_h then
			x = self:GetRight() - (t.ui.icon.size / 2)
		else
			x = self:GetLeft() + (t.ui.icon.size / 2)
		end

		if t.ui.common.reverse_v then
			y = self:GetBottom() + (t.ui.icon.size / 2) 
		else
			y = self:GetTop() - (t.ui.icon.size / 2)
		end
		y = y + self.editingY
		x = x + self.editingX
		x, y = UTIL.AdjustLocation(x, y)
		t.location.x = x
		t.location.y = y
		t.frame:SetPoint("CENTER", UIParent, "CENTER" , t.location.x , t.location.y)
		t:UpdateMoveFrame(self.isDragging)
	end

	local otherSelected = false
	for _, t in pairs(HDH_TRACKER.GetList()) do
		if t.frame.moveFrame and t.id ~= self:GetParent().id and (t.frame.moveFrame.isSelected or t.frame.moveFrame.isDragging) then
			otherSelected = true
			break
		end
	end
	if otherSelected then
		t.frame.moveFrame.text:Hide()
	else
		t.frame.moveFrame.text:Show()
	end

	if self.isSelected or self.isDragging then
		if self.isDragging then
			t.frame.moveBtn1:Hide()
			t.frame.moveBtn2:Hide()
			t.frame.moveBtn3:Hide()
			t.frame.moveBtn4:Hide()
		else
			t.frame.moveBtn1:Show()
			t.frame.moveBtn2:Show()
			t.frame.moveBtn3:Show()
			t.frame.moveBtn4:Show()
		end
		t.frame.moveFrame.active:SetAlpha(1)
		t.frame.moveFrame.active2:SetAlpha(1)
		t.frame.coord:Show()
		x, y = UTIL.AdjustLocation(t.frame.moveFrame.active:GetLeft(), t.frame.moveFrame.active:GetTop())
		t.frame.coord:SetText(("%d,%d"):format(x, y))
	else
		t.frame.moveBtn1:Hide()
		t.frame.moveBtn2:Hide()
		t.frame.moveBtn3:Hide()
		t.frame.moveBtn4:Hide()
		t.frame.moveFrame.active:SetAlpha(0)
		t.frame.moveFrame.active2:SetAlpha(0)
		t.frame.coord:Hide()
	end
end

local function OnClick_MoveButton(self)
	local t = HDH_AURA_TRACKER.Get(self:GetParent():GetParent().id)
	t.location.x = t.location.x + (self.x or 0)
	t.location.y = t.location.y + (self.y or 0)
	t.frame:SetPoint("CENTER", UIParent, "CENTER" , t.location.x , t.location.y)
	t:UpdateMoveFrame(self.isDragging)
end

local function CreateMoveFrame(self)
	local tf = CreateFrame("Frame", nil, self.frame)
	tf:SetFrameStrata("MEDIUM")
	tf:SetFrameLevel(10000)

	tf:SetPoint("TOPLEFT")
	tf:SetPoint("BOTTOMRIGHT")

	local t = tf:CreateTexture(nil, 'BACKGROUND')
	self.frame.moveFrame = tf
	t:SetPoint("TOPLEFT")
	t:SetPoint("BOTTOMRIGHT")
	t:SetColorTexture(1,0,0,0.5)
	t:SetAlpha(0)
	self.frame.moveFrame.active = t

	local t = tf:CreateTexture(nil, 'BORDER')
	t:SetPoint("TOPLEFT", self.frame.moveFrame.active, "TOPLEFT", 1, -1)
	t:SetPoint("BOTTOMRIGHT", self.frame.moveFrame.active, "BOTTOMRIGHT", -1 , 1)
	t:SetColorTexture(0,0,0,0.5)
	t:SetAlpha(0)
	self.frame.moveFrame.active2 = t

	t = tf:CreateTexture(nil, 'ARTWORK')
	t:SetColorTexture(1,0,0,1)
	t:SetSize(7,1)
	t:SetPoint("CENTER", self.frame, "CENTER", 0, 0)

	t = tf:CreateTexture(nil, 'ARTWORK')
	t:SetColorTexture(1,0,0,1)
	t:SetSize(1,7)
	t:SetPoint("CENTER", self.frame, "CENTER", 0, 0)

	t = tf:CreateTexture(nil, 'ARTWORK')
	t:SetColorTexture(1,0,0,1)
	t:SetSize(7,2)
	t:SetPoint("TOPLEFT", self.frame.moveFrame.active, "TOPLEFT", 0, 0)

	t = tf:CreateTexture(nil, 'ARTWORK')
	t:SetColorTexture(1,0,0,1)
	t:SetSize(2,7)
	t:SetPoint("TOPLEFT", self.frame.moveFrame.active, "TOPLEFT", 0, 0)

	t = tf:CreateTexture(nil, 'ARTWORK')
	t:SetColorTexture(1,0,0,1)
	t:SetSize(7,2)
	t:SetPoint("BOTTOMRIGHT", self.frame.moveFrame.active, "BOTTOMRIGHT", 0, 0)

	t = tf:CreateTexture(nil, 'ARTWORK')
	t:SetColorTexture(1,0,0,1)
	t:SetSize(2,7)
	t:SetPoint("BOTTOMRIGHT", self.frame.moveFrame.active, "BOTTOMRIGHT", 0, 0)

	local text = tf:CreateFontString(nil, 'OVERLAY')
	self.frame.coord = text
	text:SetPoint("TOPLEFT", self.frame.moveFrame.active, "TOPLEFT", 4, -4)
	text:SetFontObject("Font_Yellow_S_B")
	text:SetWidth(190)
	text:SetHeight(70)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("TOP")

	tf = CreateFrame("Frame", nil, self.frame.moveFrame)
	tf:SetFrameStrata("HIGH")
	local text = tf:CreateFontString(nil, 'OVERLAY')
	self.frame.moveFrame.text = text
	text:ClearAllPoints()
	text:SetFontObject("Font_Yellow_S_B")
	text:SetWidth(190)
	text:SetHeight(10)
	
	text:SetJustifyH("CENTER")
	text:SetText("["..self.name.."]")
	text:SetMaxLines(1) 
	
	local btn = CreateFrame("Button", nil, self.frame.moveFrame, "HDH_AT_ButtonTemplate")
	t = btn:CreateTexture(nil, 'OVERLAY')
	t:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/Left")
	t:SetTexCoord(0,1,0,1)
	t:SetPoint("CENTER")
	t:SetSize(8,10)
	btn:SetFrameStrata("HIGH")
	btn:SetSize(16, 16)
	btn:SetPoint("TOPRIGHT", self.frame.moveFrame.active, "BOTTOM", 0, 0)
	btn:SetScript("OnClick", OnClick_MoveButton)
	btn.x = -1
	self.frame.moveBtn1 = btn

	btn = CreateFrame("Button", nil, self.frame.moveFrame, "HDH_AT_ButtonTemplate")
	t = btn:CreateTexture(nil, 'OVERLAY')
	t:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/Left")
	t:SetTexCoord(1,0,0,1)
	t:SetPoint("CENTER")
	t:SetSize(8,10)
	btn:SetFrameStrata("HIGH")
	btn:SetSize(16, 16)
	btn:SetPoint("TOPLEFT", self.frame.moveFrame.active, "BOTTOM", 0, 0)
	btn:SetScript("OnClick", OnClick_MoveButton)
	btn.x = 1
	self.frame.moveBtn2 = btn

	btn = CreateFrame("Button", nil, self.frame.moveFrame, "HDH_AT_ButtonTemplate")
	t = btn:CreateTexture(nil, 'OVERLAY')
	t:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/Up")
	t:SetTexCoord(0,1,0,1)
	t:SetPoint("CENTER")
	t:SetSize(10,8)
	btn:SetFrameStrata("HIGH")
	btn:SetSize(16, 16)
	btn:SetPoint("BOTTOMLEFT", self.frame.moveFrame.active, "RIGHT", 0, 0)
	btn:SetScript("OnClick", OnClick_MoveButton)
	btn.y = 1
	self.frame.moveBtn3 = btn

	btn = CreateFrame("Button", nil, self.frame.moveFrame, "HDH_AT_ButtonTemplate")
	t = btn:CreateTexture(nil, 'OVERLAY')
	t:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/Up")
	t:SetTexCoord(0,1,1,0)
	t:SetPoint("CENTER")
	t:SetSize(10,8)
	btn:SetFrameStrata("HIGH")
	btn:SetSize(16, 16)
	btn:SetPoint("TOPLEFT", self.frame.moveFrame.active, "RIGHT", 0, 0)
	btn:SetScript("OnClick", OnClick_MoveButton)
	btn.y = -1
	self.frame.moveBtn4 = btn

	self.frame.moveFrame:SetScript("OnMouseDown", OnMouseDown_MoveFrame)
	self.frame.moveFrame:SetScript("OnUpdate", OnUpdate_MoveFrame)
	self.frame.moveFrame:SetScript("OnMouseUp", OnMouseUp_MoveFrame)

	self.frame.moveBtn1:Hide()
	self.frame.moveBtn2:Hide()
	self.frame.moveBtn3:Hide()
	self.frame.moveBtn4:Hide()
end

function HDH_TRACKER:SetMove(move)
	if not self.frame then return end
	if move then
		local cnt = self:GetElementCount()
		if cnt then
			if not self.frame.moveFrame then
				CreateMoveFrame(self)
			end
			self.frame.id = self.id
			self.frame.name = self.name
			self.frame:EnableMouse(true)
			self.frame:SetMovable(true)
			self.frame.moveFrame:SetFrameLevel(self.id * 100)
			self.frame.moveFrame:EnableMouse(true)
			self.frame.moveFrame:SetMovable(true)
			self.frame.moveFrame.isDragging = false
			self.frame.moveFrame.isSelected = self.frame.moveFrame.isSelected or false
			self.frame.moveFrame:Show()
			cnt = self:CreateDummySpell(cnt);
			self:ShowTracker();
			self:UpdateAllIcons()
			self:UpdateMoveFrame()
		end
	else
		self.frame:Hide();
		self.frame.name = nil
		self.frame.id = nil
		self.frame:EnableMouse(false)
		self.frame:SetMovable(false)
		if self.frame.text then 
			self.frame.text:Hide() 
			self.frame.text:GetParent():SetParent(nil) 
			self.frame.text = nil
			
		end
		if self.frame.moveFrame then
			self.frame.moveFrame:Hide()
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
				local link = isItem and select(2,GetItemInfo(id)) or UTIL.GetSpellLink(id)
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
	local parent = f.icon;
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
		fontf:SetJustifyV('MIDDLE')
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
		fontf:SetJustifyV('MIDDLE')
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
		fontf:SetJustifyV('MIDDLE')
	elseif location == DB.FONT_LOCATION_BAR_C then
		fontf:SetPoint('CENTER', f.bar or parent, 'CENTER', 0, 0)
		fontf:SetWidth(parent:GetWidth()+200);
		fontf:SetJustifyH('CENTER')
		fontf:SetJustifyV('MIDDLE')
	elseif location == DB.FONT_LOCATION_BAR_R then
		fontf:SetPoint('RIGHT', f.bar or parent, 'RIGHT', -2, 0)
		fontf:SetWidth(parent:GetWidth()+200);
		fontf:SetJustifyH('RIGHT')
		fontf:SetJustifyV('MIDDLE')
	else
		fontf:Hide()
	end
	local refresh = fontf:GetText()
	fontf:SetText("")
	fontf:SetText(refresh)
end

-- bar 세부 속성 세팅하는 함수 (나중에 option 을 통해 바 값을 변경할수 있기에 따로 함수로 지정해둠)
local ICON_BORDER_VALUE = {0.120, 0.15, 0.18, 0.21, 0.24, 0.27, 0.30, 0.33, 0.36, 0.39}
-- local ICON_SIZE_VALUE =   {0.075, 0.10, 0.14, 0.21, 0.23, 0.30, 0.34, 0.37, 0.40, 0.42}
function HDH_TRACKER:UpdateIconSettings(f)
	local op_icon = self.ui.icon
	local op_font = self.ui.font
	local op_common = self.ui.common

	f:SetSize(op_icon.size, op_icon.size)
	f.icon:Setup(op_icon.size, op_icon.size, op_icon.cooldown, false, true, op_icon.spark_color, op_icon.cooldown_bg_color, op_icon.on_alpha, op_icon.off_alpha, op_icon.border_size)
	f.icon:SetBorderColor(unpack(op_icon.active_border_color))
	if f.spell and f.spell.icon then
		f.icon:SetTexture(f.spell.icon)
	end

	local spot_border = math.min(0.2355 * (1 - (ICON_BORDER_VALUE[4] or 0)), 0.2355 * (1 - (ICON_BORDER_VALUE[op_icon.border_size] or 0)))
	f.icon.spark.spot:SetTexCoord(spot_border, 1 - spot_border, spot_border, 1 - spot_border)
	f.icon.spark:SetSize(op_icon.size, op_icon.size)
	f.icon.spark.spot:SetSize(op_icon.size, op_icon.size)
	f.icon.spark.color:SetSize(op_icon.size, op_icon.size)
	
	if 4 > op_icon.size * 0.08 then
		op_icon.margin = 4
	else
		op_icon.margin = op_icon.size * 0.08
	end
	
	-- font location 보다 먼저 호출되어서 BAR 가 생성되어있어야 BAR 위에 폰트가 올바르게 위치할 수 있음
	self:UpdateBarSettings(f)

	local counttext = f.counttext
	counttext:SetFont(HDH_TRACKER.FONT_STYLE, op_font.count_size, "OUTLINE")
	counttext:SetTextColor(unpack(op_font.count_color))
	ChangeFontLocation(f, counttext, op_font.count_location, op_font)
	
	local v1Text = f.v1
	v1Text:SetFont(HDH_TRACKER.FONT_STYLE, op_font.v1_size, "OUTLINE")
	v1Text:SetTextColor(unpack(op_font.v1_color))
	ChangeFontLocation(f, v1Text, op_font.v1_location, op_font)
	
	local timetext = f.timetext
	timetext:SetFont(HDH_TRACKER.FONT_STYLE, op_font.cd_size, "OUTLINE")
	timetext:SetTextColor(unpack(op_font.cd_color))
	ChangeFontLocation(f, timetext, op_font.cd_location, op_font)
	
	f.timetext:Show()

	self:SetGameTooltip(f, op_common.show_tooltip or false)

	-- 아이콘 숨기기는 바와 연관되어 있기 때문에 바 설정쪽에 위치함.
	if op_common.display_mode == DB.DISPLAY_BAR then
		f.icon:Hide();
	else -- DISPLAY_ICON_AND_BAR
		f.icon:Show();
	end

	if not HDH_TRACKER.ENABLE_MOVE then
		if self:GetClassName() == "HDH_AURA_TRACKER" and self.ui.icon.able_buff_cancel then
			f:SetMouseClickEnabled(true);
			f:RegisterForClicks("RightButtonUp");
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

function HDH_TRACKER:InitIcons()
	local trackerId = self.id
	local id, name, trackerType, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
	if not id then return 0 end
	local elemKey, elemId, elemName, texture, glowType, isValue, isItem, glowCondition, glowValue, glowEffectType, glowEffectColor, glowEffectPerSec
	local barValueType, barMaxValueType, barMaxValue, splitPoints, splitPointType, defaultImg
	local innerTrackingType, innerSpellId, innerCooldown 
	local display, connectedId, connectedIsItem, unlearnedHideMode
	local spell 
	local f
	local isLearned = true
	local iconIdx = 0;
	local needEquipmentEvent = false

	self.frame.pointer = {}
	self.aura_filter = aura_filter
	self.aura_caster = aura_caster
	self.talentId = HDH_AT_UTIL.GetSpecialization()

	if self:GetElementCount() == 0 then
		self:CreateData()
	end

	local elemSize = DB:GetTrackerElementSize(trackerId)
	for i = 1, elemSize do
		elemKey, elemId, elemName, texture, display, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
		display, connectedId, connectedIsItem, unlearnedHideMode = DB:GetTrackerElementDisplay(trackerId, i)
		glowType, glowCondition, glowValue, glowEffectType, glowEffectColor, glowEffectPerSec = DB:GetTrackerElementGlow(trackerId, i)
		defaultImg = DB:GetTrackerElementDefaultImage(trackerId, i)
		barValueType, barMaxValueType, barMaxValue, splitPoints, splitPointType = DB:GetTrackerElementBarInfo(trackerId, i)
		innerTrackingType, innerSpellId, innerCooldown =  DB:GetTrackerElementInnerCooldown(trackerId, i)

		if connectedId then
			isLearned = HDH_AT_UTIL.IsLearnedSpellOrEquippedItem(connectedId, nil, connectedIsItem)
			if connectedIsItem then
				needEquipmentEvent = true
			end
		else
			isLearned = true
		end
		if unlearnedHideMode ~= DB.SPELL_HIDE or isLearned then
			iconIdx = iconIdx + 1
			f = self.frame.icon[iconIdx]
			if f:GetParent() == nil then f:SetParent(self.frame) end
			if isLearned then
				self.frame.pointer[elemKey] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
			else
				spell.blankDisplay = true
			end
			spell = {}
			if type(elemKey) == "number" then
				spell.key = tonumber(elemKey)
			else
				spell.key = elemKey
			end

			spell.no = iconIdx
			spell.name = elemName
			spell.icon = texture
			spell.id = tonumber(elemId)
			spell.count = 0
			spell.v1 = 0 -- 수치를 저장할 변수
			spell.duration = 0
			spell.remaining = 0
			spell.overlay = 0
			spell.endTime = 0
			spell.isUpdate = false
			spell.defaultImg = defaultImg
			spell.isItem =  isItem
			spell.happenTime = 0

			spell.glow = glowType
			spell.glowCondtion = glowCondition
			spell.glowValue = (glowValue and tonumber(glowValue)) or 0
			spell.glowEffectType = glowEffectType
			spell.glowEffectColor = glowEffectColor
			spell.glowEffectPerSec = glowEffectPerSec
			spell.showValue = isValue
			spell.display = display
			
			spell.barSplitPoints = splitPoints
			spell.barSplitPointType = splitPointType or DB.BAR_SPLIT_RATIO
			spell.barValueType = barValueType
			spell.barMaxValueType = barMaxValueType
			spell.barMaxValue = barMaxValue

			if innerSpellId then
				spell.isInnerCDItem = true
				spell.innerSpellId = tonumber(innerSpellId)
				spell.innerCooldown = tonumber(innerCooldown)
				spell.innerTrackingType = innerTrackingType
			end

			f.spell = spell
			f.icon:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
			self:UpdateGlow(f, false)
			self:UpdateBarSettings(f)

			f:Hide()
			self:ActionButton_HideOverlayGlow(f)
			if f.bar then
				f.bar:SetSplitPoints(spell.barSplitPoints, spell.barSplitPointType)
			end
		end
	end
	
	for i = #(self.frame.icon) , iconIdx+1, -1 do
		self:ReleaseIcon(i)
	end
	self.frame:UnregisterAllEvents()
	if iconIdx > 0 then
		if needEquipmentEvent then
			self.frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
		end

		self.frame:SetScript("OnEvent", self.OnEvent)
		self:LoadOrderFunc()
	end
	
	return iconIdx;
end
-------------------------------------------
-- 애니메이션 관련
-------------------------------------------


if select(4, GetBuildInfo()) <= 49999 then -- 대격변 코드

	function HDH_TRACKER:ActionButton_SetupOverlayGlow(f)
		f.icon.overlay = ActionButton_GetOverlayGlow();
		local frameWidth, frameHeight = f.icon:GetSize();
		f.icon.overlay:SetParent(f.icon);
		f.icon.overlay:ClearAllPoints();
		f.icon.overlay:SetFrameLevel(f.icon:GetFrameLevel() + 4)
		-- Make the height/width available before the next frame:
		f.icon.overlay:SetSize(frameWidth * 1.3, frameHeight * 1.3);
		f.icon.overlay:SetPoint("TOPLEFT", f.icon, "TOPLEFT", -frameWidth * 0.3, frameHeight * 0.3);
		f.icon.overlay:SetPoint("BOTTOMRIGHT", f.icon, "BOTTOMRIGHT", frameWidth * 0.3, -frameHeight * 0.3);
	end

	function HDH_TRACKER:ActionButton_ResizeOverlayGlow(f)
		--interface
	end

	function HDH_TRACKER:ActionButton_ReleaseOverlayGlow(f)
		--interface
	end

	function HDH_TRACKER:ActionButton_ShowOverlayGlow(f)
		if not f.icon.overlay then
			self:ActionButton_SetupOverlayGlow(f.icon)
		end
		if ( f.icon.overlay.animOut:IsPlaying() ) then f.icon.overlay.animOut:Stop(); end
		f.icon.overlay.animIn:Play()
	end
	
	function HDH_TRACKER:ActionButton_HideOverlayGlow(f)
		if ( f.icon.overlay ) then
			ActionButton_HideOverlayGlow(f.icon);
		end
	end
	
	function HDH_TRACKER:IsGlowing(f)
		return f.icon.overlay and true or false
	end

else -- 용군단 코드

	function HDH_TRACKER:ActionButton_SetupOverlayGlow(f)
		if f.icon.SpellActivationAlert then
			return
		end
		local name = f.icon:GetParent():GetName()..'g'..math.random()
		local frameWidth, frameHeight = f.icon:GetSize()
		f.icon.SpellActivationAlert = CreateFrame("Frame", name, f, "ActionButtonSpellAlertTemplate")
		f.icon.SpellActivationAlert:SetFrameLevel(f.icon:GetFrameLevel() + 4)
		f.icon.SpellActivationAlert:SetSize(frameWidth * 1.6, frameHeight * 1.6)
		f.icon.SpellActivationAlert:SetPoint("CENTER", f, "CENTER", 0, 0)
		f.icon.SpellActivationAlert:Hide()
		f.icon.SpellActivationAlert.ProcStartFlipbook:SetSize(frameWidth * 4.05, frameWidth * 4.05)
	end
	
	function HDH_TRACKER:ActionButton_ResizeOverlayGlow(f)
		if not f.icon.SpellActivationAlert then
			return
		end
		f.icon.SpellActivationAlert:Hide()
		local frameWidth, frameHeight = f.icon:GetSize()
		f.icon.SpellActivationAlert:SetSize(frameWidth * 1.6, frameHeight * 1.6)
	end
	
	function HDH_TRACKER:ActionButton_ReleaseOverlayGlow(f)
		if not f.icon.SpellActivationAlert then
			return
		end
		f.icon.SpellActivationAlert:Hide()
		f.icon.SpellActivationAlert:SetParent(nil)
		f.icon.SpellActivationAlert = nil
	end
	
	function HDH_TRACKER:ActionButton_ShowOverlayGlow(f)
		if not  f.icon.SpellActivationAlert then
			self:ActionButton_SetupOverlayGlow(f)
		end
		if not f.icon.SpellActivationAlert:IsShown() or (not  f.icon.SpellActivationAlert.ProcStartAnim:IsPlaying() and not  f.icon.SpellActivationAlert.ProcLoop:IsPlaying()) then
			f.icon.SpellActivationAlert:Show()
			f.icon.SpellActivationAlert.ProcStartAnim:Play()
		end
	end
	
	function HDH_TRACKER:ActionButton_HideOverlayGlow(f)
		if not  f.icon.SpellActivationAlert then
			return
		end
	
		if  f.icon:IsVisible() then
			f.icon.SpellActivationAlert:Hide()
		end
	end
	
	function HDH_TRACKER:IsGlowing(f)
		if  f.icon.SpellActivationAlert and ( f.icon.SpellActivationAlert:IsShown()) then
			return true
		else
			return false
		end
	end
end

function HDH_TRACKER:UpdateGlow(f, bool)
	if f.spell.ableGlow then -- 블리자드 기본 반짝임 효과면 무조건 적용
		if f.spell.glowEffectType == DB.GLOW_EFFECT_DEFAULT then
			self:ActionButton_ShowOverlayGlow(f)
			if f.icon.spark:IsShown() then
				f.icon.spark:Hide() 
				f.spell.glowColorOn = false
			end
		else
			if not f.icon.spark:IsShown() then
				f.icon.spark.playing = 0
				f.icon.spark:Show() 
				f.spell.glowColorOn = true
			end
		end
		return
	end
	if bool and (f.spell and f.spell.glow ~= DB.GLOW_CONDITION_NONE) and self.ui.common.display_mode ~= DB.DISPLAY_BAR then
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
			value = value or 0
			if f.spell.glowCondtion == DB.CONDITION_GT_OR_EQ then
				active = (value >= f.spell.glowValue)
			elseif f.spell.glowCondtion == DB.CONDITION_LT_OR_EQ then
				active =  (value <= f.spell.glowValue)
			elseif f.spell.glowCondtion == DB.CONDITION_EQ then
				active =  (value == f.spell.glowValue) 
			elseif f.spell.glowCondtion == DB.CONDITION_GT then
				active =  (value > f.spell.glowValue) 
			elseif f.spell.glowCondtion == DB.CONDITION_LT then
				active =  (value < f.spell.glowValue) 
			end
		end
		if active then
			if f.spell.glowEffectType == DB.GLOW_EFFECT_DEFAULT then
				self:ActionButton_ShowOverlayGlow(f)
				if f.icon.spark:IsShown() then
					f.icon.spark:Hide() 
					f.spell.glowColorOn = false
				end
			else
				if not f.icon.spark:IsShown() then
					f.icon.spark.playing = 0
					f.icon.spark:Show() 
					f.spell.glowColorOn = true
				end
			end
		else
			self:ActionButton_HideOverlayGlow(f)
			if f.icon.spark:IsShown() then
				f.icon.spark:Hide() 
				f.spell.glowColorOn = false
			end
		end
	else
		self:ActionButton_HideOverlayGlow(f)
		if f.icon.spark:IsShown() then
			f.icon.spark:Hide() 
			f.spell.glowColorOn = false
		end
	end
end

function HDH_TRACKER:GetAni(f, ani_type) -- row 이동 애니
	if ani_type == HDH_TRACKER.ANI_HIDE then
		if not f.aniHide then
			local ag = f:CreateAnimationGroup()
			f.aniHide = ag
			ag.a1 = ag:CreateAnimation("ALPHA")
			ag.a1:SetOrder(0.5)
			ag.a1:SetDuration(1)
			ag.a1:SetFromAlpha(1)
			ag.a1:SetToAlpha(0.0)
			ag:SetScript("OnFinished", function(self) 
				self:GetParent():Hide(); 
			end)
		end	
		return f.aniHide;
	elseif ani_type == HDH_TRACKER.ANI_SHOW then
		if not f.aniShow then
			local ag = f:CreateAnimationGroup()
			f.aniShow = ag
			ag.a1 = ag:CreateAnimation("ALPHA")
			ag.a1:SetOrder(1)
			ag.a1:SetDuration(0.2)
			ag.a1:SetFromAlpha(0)
			ag.a1:SetToAlpha(1)
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
end

function HDH_TRACKER:HideTracker()
	self:StartAni(self.frame, HDH_TRACKER.ANI_HIDE);
end

function HDH_TRACKER:IsShown()
	return self.frame:IsShown()
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

------------------------------------------
-- end -- TRACKER interface function
------------------------------------------

function HDH_TRACKER:PLAYER_ENTERING_WORLD()
-- interface
end
