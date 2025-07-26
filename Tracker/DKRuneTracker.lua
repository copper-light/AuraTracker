HDH_DK_RUNE_TRACKER = {}
local DB = HDH_AT_ConfigDB
local MyClassKor, MyClass = UnitClass("player");
local MAX_RUNES = 6;
	
------------------------------------
 -- HDH_DK_RUNE_TRACKER class
------------------------------------
HDH_TRACKER.TYPE.POWER_RUNE = 20
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_RUNE, HDH_DK_RUNE_TRACKER)

local POWER_INFO = {}
POWER_INFO[HDH_TRACKER.TYPE.POWER_RUNE] 	= {power_type="RUNE", 	power_index = 5,	color={0.77, 0.12, 0.23, 1}, texture = "Interface/Icons/Spell_Deathknight_BloodPresence"};

local OLD_DK_COLOR = {
	{color = {1.0, 0.235, 0.240, 1}, texture = "Interface/Icons/Spell_Deathknight_BloodPresence"},
	{color = {1.0, 0.235, 0.240, 1}, texture = "Interface/Icons/Spell_Deathknight_BloodPresence"},
	{color = {0.25, 0.6, 1, 1}, texture = "Interface/Icons/Spell_Deathknight_FrostPresence"},
	{color = {0.25, 0.6, 1, 1}, texture = "Interface/Icons/Spell_Deathknight_FrostPresence"},
	{color = {0.062, 1, 0.006, 1}, texture = "Interface/Icons/Spell_Deathknight_UnholyPresence"},
	{color = {0.062, 1, 0.006, 1}, texture = "Interface/Icons/Spell_Deathknight_UnholyPresence"}
}

local function adjuistColor(src, dst)
	local r,g,b,a = unpack(src)
	local ratio = max(r,g,b)

	r,g,b,_ = unpack(dst)
	r = r * ratio
	g = g * ratio
	b = b * ratio

	return r,g,b,a
end

local RUN_INDEX = {}
RUN_INDEX[1] = 1
RUN_INDEX[2] = 2
RUN_INDEX[3] = 5
RUN_INDEX[4] = 6
RUN_INDEX[5] = 3
RUN_INDEX[6] = 4

local super = HDH_C_TRACKER
setmetatable(HDH_DK_RUNE_TRACKER, super) -- 상속
HDH_DK_RUNE_TRACKER.__index = HDH_DK_RUNE_TRACKER
HDH_DK_RUNE_TRACKER.className = "HDH_DK_RUNE_TRACKER"
HDH_DK_RUNE_TRACKER.POWER_INFO = POWER_INFO
	
function HDH_DK_RUNE_TRACKER:CreateData()
	local trackerId = self.id
	local key = self.POWER_INFO[self.type].power_type
	local id = 0
	local name = self.POWER_INFO[self.type].power_type
	local texture = self.POWER_INFO[self.type].texture;
	local display = DB.SPELL_ALWAYS_DISPLAY
	local isValue = false
	local isItem = false
	local r,g,b,a = unpack(self.POWER_INFO[self.type].color)

	if DB:GetTrackerElementSize(trackerId) > MAX_RUNES then
		DB:TrancateTrackerElements(trackerId)
	end

	if select(4, GetBuildInfo()) >= 100000 then
		for i = 1 , MAX_RUNES do
			DB:AddTrackerElement(trackerId, key .. i, id, name .. i, texture, display, isValue, isItem)
			DB:SetReadOnlyTrackerElement(trackerId, i) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다
		end 
	else
		for i = 1 , MAX_RUNES do
			DB:AddTrackerElement(trackerId, key .. i, id, name .. i, OLD_DK_COLOR[i].texture, display, isValue, isItem)
			DB:SetReadOnlyTrackerElement(trackerId, i) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다
		end 
	end

	DB:CopyGlobelToTracker(trackerId)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.column_count', 6)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.reverse_h', false)

	if select(4, GetBuildInfo()) >= 100000 then
		DB:SetTrackerValue(trackerId, 'ui.%s.common.order_by', DB.ORDERBY_CD_ASC)
	end

	DB:SetTrackerValue(trackerId, 'ui.%s.bar.width', 40)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.height', 20)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.to_fill', true)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.cooldown_progress', DB.COOLDOWN_RIGHT)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.location', DB.BAR_LOCATION_R)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.texture', 3)	
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.show_spark', true)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.use_full_color', true)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', {r,g,b, 0.35})
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.full_color', self.POWER_INFO[self.type].color)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.name_location', DB.FONT_LOCATION_HIDE)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.count_location', DB.FONT_LOCATION_HIDE)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_BAR_R)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.cd_format', DB.TIME_TYPE_CEIL)
	DB:SetTrackerValue(trackerId, 'ui.%s.icon.size', 40)
	DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', self.POWER_INFO[self.type].color)
	DB:SetTrackerValue(trackerId, 'ui.%s.icon.cooldown', DB.COOLDOWN_RIGHT)
	self:UpdateSetting();
end

function HDH_DK_RUNE_TRACKER:IsHaveData()
	for i = 1 , MAX_RUNES do
		local key = DB:GetTrackerElement(self.id, i)
		if (self.POWER_INFO[self.type].power_type .. i) ~= key then
			return false
		end
	end 

	return true
end

function HDH_DK_RUNE_TRACKER:UpdateIcon(f)
	if not f then return end
	if not f.spell then return end

	self:UpdateRune(f.spell.no)
	if f.spell.remaining > 0.1 then
		HDH_AT_UTIL.CT_StartTimer(f)
		if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1) end
		f.counttext:SetText((f.spell.count ~= 0) and f.spell.count or nil)
		f.cd:Show()
		f.icon:SetAlpha(self.ui.icon.off_alpha)
		f.border:SetAlpha(self.ui.icon.off_alpha)
		f.border:SetVertexColor(0,0,0)
		f.iconSatCooldown:Show()
		if self.ui.icon.cooldown == DB.COOLDOWN_CIRCLE or self.ui.icon.cooldown == DB.COOLDOWN_NONE then
			f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
		else
			f.cd:SetMinMaxValues(f.spell.startTime, f.spell.endTime)
			f.cd:SetValue(f.spell.endTime - (GetTime() - f.spell.startTime))
		end
		self:UpdateGlow(f, false)
		f:Show()
		if self.ui.display_mode ~= DB.DISPLAY_ICON and f.bar then
			self:UpdateBarValue(f, f.spell.startTime, f.spell.endTime, GetTime())
		end
	else
		if self.ui.display_mode ~= DB.DISPLAY_ICON and f.bar then 
			self:UpdateBarValue(f, 0, 1, 1)
			r,g,b,a = adjuistColor(self.ui.bar.full_color, OLD_DK_COLOR[f.spell.no].color)
			f.bar:SetStatusBarColor(r,g,b,a);
		end
		f.icon:SetDesaturated(nil)
		f.timetext:SetText("");
		if self.ui.display_mode ~= DB.DISPLAY_BAR and (f.spell.display == DB.SPELL_ALWAYS_DISPLAY)then 
			f.icon:SetAlpha(self.ui.icon.on_alpha)
			f.border:SetAlpha(self.ui.icon.on_alpha)

			if select(4, GetBuildInfo()) >= 100000 then
				f.border:SetVertexColor(unpack(self.ui.icon.active_border_color)) 
			else
				r,g,b,a = adjuistColor(self.ui.icon.active_border_color, OLD_DK_COLOR[f.spell.no].color)
				f.border:SetVertexColor(r,g,b,a) 
			end

			f.counttext:SetText(nil)
			f.iconSatCooldown:Hide()
			f.iconSatCooldown.spark:Hide()
			f.cd:Hide() 
			self:UpdateGlow(f, true)
			f:Show()
		else
			f:Hide()
		end
	end
	self:UpdateLayout()
end

if select(4, GetBuildInfo()) < 100000 then
	
end

function HDH_DK_RUNE_TRACKER:UpdateBarSettings(f)
	super.UpdateBarSettings(self, f)
	if self.ui.common.display_mode == DB.DISPLAY_ICON then return end

	local op = self.ui.bar
	local r, g, b, a = adjuistColor(self.ui.bar.color, OLD_DK_COLOR[f.spell.no].color)
	local normalColor = {r, g, b, a}
	local fr, fg, fb, fa = adjuistColor(self.ui.bar.full_color, OLD_DK_COLOR[f.spell.no].color)
	local fullColor = {fr, fg, fb, fa}

	if op.use_full_color and not self.ui.common.default_color then
		f.bar:UseChangedStatusColor(normalColor, fullColor)
	else
		f.bar:UseChangedStatusColor(nil)
		f.bar:SetStatusBarColor(unpack(normalColor))
	end
end

function HDH_DK_RUNE_TRACKER:UpdateAllIcons()
	for k,v in pairs(self.frame.icon) do
		self:UpdateIcon(v)
	end
	-- self:UpdateLayout()
end

function HDH_DK_RUNE_TRACKER:UpdateLayout()
	if not self.ui or not self.frame.icon then return end
	local f, spell
	local ret = 0 -- 쿨이 도는 스킬의 갯수를 체크하는것
	local line = self.ui.common.column_count or 10-- 한줄에 몇개의 아이콘 표시
	local margin_h = self.ui.common.margin_h
	local margin_v = self.ui.common.margin_v
	local reverse_v = self.ui.common.reverse_v -- 상하반전
	local reverse_h = self.ui.common.reverse_h -- 좌우반전
	local show_index = 0 -- 몇번째로 아이콘을 출력했는가?
	local col = 0  -- 열에 대한 위치 좌표값 = x
	local row = 0  -- 행에 대한 위치 좌표값 = y
	local cnt = #self.frame.icon;
	local reorder = {};
	local tmp;

	local size_w, size_h
	if self.ui.common.display_mode == DB.DISPLAY_BAR then
		size_w = self.ui.bar.width
		size_h = self.ui.bar.height
	elseif self.ui.common.display_mode == DB.DISPLAY_ICON_AND_BAR then
		if self.ui.bar.location == DB.BAR_LOCATION_R or self.ui.bar.location == DB.BAR_LOCATION_L then
			size_w = self.ui.bar.width + self.ui.icon.size
			size_h = max(self.ui.bar.height, self.ui.icon.size)
		else
			size_h = self.ui.bar.height + self.ui.icon.size
			size_w = max(self.ui.bar.width, self.ui.icon.size)
		end
		
	else
		size_w = self.ui.icon.size -- 아이콘 간격 띄우는 기본값
		size_h = self.ui.icon.size
	end

	if self.OrderFunc then self:OrderFunc(self) end 
	for i = 1 , cnt do
		f = self.frame.icon[i]
		if f and f.spell then
			if HDH_TRACKER.ENABLE_MOVE or f:IsShown() then
				f:ClearAllPoints()
				f:SetPoint('RIGHT', self.frame, 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
				show_index = show_index + 1
				if i % line == 0 then row = row + size_h + margin_v; col = 0
									else col = col + size_w + margin_h end
				if f.spell.remaining > 0 then ret = ret + 1 end -- 비전투라도 쿨이 돌고 잇는 스킬이 있으면 화면에 출력하기 위해서 체크함
			else
				if (f.spell.display == DB.SPELL_HIDE_TIME_ON_AS_SPACE or f.spell.display == DB.SPELL_HIDE_TIME_OFF_AS_SPACE) and self.ui.common.order_by == DB.ORDERBY_REG then
					show_index = show_index + 1
					f:ClearAllPoints()
					f:SetPoint('RIGHT', self.frame, 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
					if show_index % line == 0 then 
						row = row + size_h + margin_v
						col = 0
					else 
						col = col + size_w + margin_h
					end
				end
			end
		end
	end

	if  (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
			and (HDH_TRACKER.ENABLE_MOVE or ret > 0 or UnitAffectingCombat("player") or self.ui.common.always_show) then
		self:ShowTracker();
	else
		self:HideTracker();
	end
end

function HDH_DK_RUNE_TRACKER:UpdateRune(runeIndex, isEnergize)
	local ret = false
	local start, duration, runeReady = GetRuneCooldown(runeIndex);
	if select(4, GetBuildInfo()) < 100000 then
		runeIndex = RUN_INDEX[runeIndex]
	end
	if self and self.frame.pointer[runeIndex] then
		local spell = self.frame.pointer[runeIndex].spell
		if start~= 0 and start and spell then
			if HDH_TRACKER.startTime < start then
				spell.duration = duration
			else
				spell.duration = duration - (HDH_TRACKER.startTime-start)
			end
			spell.startTime = start
			spell.endTime = start + duration
			spell.remaining = spell.endTime - GetTime()
		else
			spell.duration = 0
			spell.startTime = 0
			spell.endTime = 0
			spell.remaining = 0 
		end
	end
	return ret;
end

function HDH_DK_RUNE_TRACKER:Update() -- HDH_TRACKER override
	if not self.frame or HDH_TRACKER.ENABLE_MOVE then return end
	-- for i = 1 , MAX_RUNES do
	-- 	self:UpdateRune(i)
	-- 	--self:UpdateRuneType(i)
	-- end
	self:UpdateAllIcons()
end

function HDH_DK_RUNE_TRACKER:InitIcons()
	-- if HDH_TRACKER.ENABLE_MOVE then return end
	local trackerId = self.id
	local id, name, _, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
	self.aura_filter = aura_filter
	self.aura_caster = aura_caster
	if not id then 
		return 
	end

	local elemKey, elemId, elemName, texture, display, glowType, isValue, isItem, glowCondition, glowValue, glowEffectType, glowEffectColor, glowEffectPerSec
	
	local spell 
	local f
	local iconIdx = 0
	self.frame.pointer = {}
	self.frame:UnregisterAllEvents()
	self.talentId = HDH_AT_UTIL.GetSpecialization()

	if not self:IsHaveData() then
		self:CreateData()
	end

	local elemSize = DB:GetTrackerElementSize(trackerId)

	for i = 1 , elemSize do
		elemKey, elemId, elemName, texture, display, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
		glowType, glowCondition, glowValue, glowEffectType, glowEffectColor, glowEffectPerSec = DB:GetTrackerElementGlow(trackerId, i)
			
		iconIdx = iconIdx + 1
		f = self.frame.icon[iconIdx]
		if f:GetParent() == nil then f:SetParent(self.frame) end
		self.frame.pointer[iconIdx] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
		spell = {}
		spell.glow = glowType
		spell.glowCondtion = glowCondition
		spell.glowValue = (glowValue and tonumber(glowValue)) or 0
		spell.glowEffectType = glowEffectType
		spell.glowEffectColor = glowEffectColor
		spell.glowEffectPerSec = glowEffectPerSec
		spell.showValue = isValue
		spell.display = display
		spell.v1 = 0 -- 수치를 저장할 변수
		spell.no = i
		spell.name = elemName
		spell.icon = texture
		spell.power_index = self.POWER_INFO[self.type].power_index
		spell.id = tonumber(elemId)
		spell.count = 0
		spell.duration = 0
		spell.remaining = 0
		spell.overlay = 0
		spell.endTime = 0
		spell.startTime = 0
		spell.is_buff = isBuff;
		spell.isUpdate = false
		spell.isItem =  isItem
		spell.charges = {};
		spell.charges.duration = 0;
		spell.charges.count = 0
		spell.charges.remaining = 0
		spell.charges.startTime = 0
		spell.charges.endTime = 0

		f.spell = spell
		f.icon:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
		f.iconSatCooldown:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")

		self:UpdateGlow(f, false)
		f:Hide()
	end

	self.frame:SetScript("OnEvent", self.OnEvent)
	self.frame:RegisterEvent("RUNE_POWER_UPDATE");
	self.frame:RegisterEvent("RUNE_TYPE_UPDATE");
	self.frame:RegisterEvent('UNIT_MAXPOWER')
	self:Update()
	self:LoadOrderFunc();

	for i = #self.frame.icon, iconIdx+1 , -1 do
		self:ReleaseIcon(i)
	end
	return iconIdx;
end

function HDH_DK_RUNE_TRACKER:OnEvent(event, ...)
	if not self.parent then return end
	if ( event == "RUNE_POWER_UPDATE" ) then	
		local runeIndex, isEnergize = ...;
		if runeIndex and runeIndex >= 1 and runeIndex <= MAX_RUNES then
			self.parent:Update();
		end
	elseif ( event == "RUNE_TYPE_UPDATE" ) then
		local runeIndex = ...;
		if ( runeIndex and runeIndex >= 1 and runeIndex <= MAX_RUNES ) then
			self.parent:Update();
		end
	end
end

------------------------------------
-- HDH_DK_RUNE_TRACKER class
------------------------------------