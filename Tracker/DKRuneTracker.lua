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

function HDH_DK_RUNE_TRACKER:GetElementCount()
	for i = 1 , MAX_RUNES do
		local key = DB:GetTrackerElement(self.id, i)
		if (self.POWER_INFO[self.type].power_type .. i) ~= key then
			return 0
		end
	end 

	return MAX_RUNES
end

function HDH_DK_RUNE_TRACKER:UpdateBarSettings(f)
	super.UpdateBarSettings(self, f)
	if self.ui.common.display_mode == DB.DISPLAY_ICON then return end

	if f.spell then
		local op = self.ui.bar
		local r, g, b, a = adjuistColor(self.ui.bar.color, OLD_DK_COLOR[f.spell.no].color)
		local fr, fg, fb, fa = adjuistColor(self.ui.bar.full_color, OLD_DK_COLOR[f.spell.no].color)
		local normalColor = {r, g, b, a}
		local fullColor = {fr, fg, fb, fa}

		if select(4, GetBuildInfo()) >= 100000 then
			normalColor = self.ui.bar.color
			fullColor = self.ui.bar.full_color
		end

		if op.use_full_color then
			f.bar:UseChangedStatusColor(normalColor, fullColor)
		else
			f.bar:UseChangedStatusColor(nil)
			f.bar:SetStatusBarColor(unpack(normalColor))
		end
	end
end

function HDH_DK_RUNE_TRACKER:UpdateSpellInfo(runeIndex)
	local ret = false
	local start, duration, runeReady
	local startIndex = runeIndex or 1
	local endIndex = runeIndex or MAX_RUNES
	local spell
	for i = startIndex , endIndex do
		start, duration, runeReady = GetRuneCooldown(i)
		if select(4, GetBuildInfo()) < 100000 then
			i = RUN_INDEX[i]
		end
		if self.frame.pointer[i] then
			spell = self.frame.pointer[i].spell
			if start ~= 0 and start and spell then
				if HDH_TRACKER.startTime < start then
					spell.duration = duration
					spell.startTime = start
				else
					spell.duration = duration - (HDH_TRACKER.startTime-start)
					spell.startTime = HDH_TRACKER.startTime
				end
				spell.endTime = start + duration
				spell.remaining = spell.endTime - GetTime()
				spell.isUpdate = true
				spell.v1 = 0
			else
				spell.duration = 0
				spell.startTime = 0
				spell.endTime = GetTime()
				spell.remaining = 0 
				spell.isUpdate = false
			end
		end
	end

	self.power = 0
	for i = 1, #self.frame.icon do
		if self.frame.icon[i] and not self.frame.icon[i].spell.isUpdate then
			self.power = self.power + 1
			self.frame.icon[1].spell.v1 = (not self.frame.icon[1].spell.isUpdate) and self.power or 0
			self.frame.icon[2].spell.v1 = (not self.frame.icon[2].spell.isUpdate) and self.power or 0
			self.frame.icon[3].spell.v1 = (not self.frame.icon[3].spell.isUpdate) and self.power or 0
			self.frame.icon[4].spell.v1 = (not self.frame.icon[4].spell.isUpdate) and self.power or 0
			self.frame.icon[5].spell.v1 = (not self.frame.icon[5].spell.isUpdate) and self.power or 0
			self.frame.icon[6].spell.v1 = (not self.frame.icon[6].spell.isUpdate) and self.power or 0
		end
	end
	return ret;
end


function HDH_DK_RUNE_TRACKER:UpdateIconAndBar(index)
	local startIndex = index or 1
	local endIndex = index or #self.frame.icon
	local f
	for i = startIndex, endIndex do
		f = self.frame.pointer[i]
		if f then
			if f.spell.remaining > HDH_TRACKER.EndCooldown then
				f.counttext:SetText((f.spell.count ~= 0) and f.spell.count or nil)
				f.icon:UpdateCooldowning()
				f.icon:SetCooldown(f.spell.startTime, f.spell.duration)

				f.v1:SetText("")
				if self.ui.display_mode ~= DB.DISPLAY_ICON and f.bar then
					self:UpdateBarMinMaxValue(f, f.spell.startTime, f.spell.endTime, GetTime())
				end
			else
				if self.ui.display_mode ~= DB.DISPLAY_ICON and f.bar then
					self:UpdateBarMinMaxValue(f, 0, 1, 1)
					if select(4, GetBuildInfo()) < 100000 then
						f.bar:SetStatusBarColor(adjuistColor(self.ui.bar.full_color, OLD_DK_COLOR[f.spell.no].color))
					end
				end
				
				f.v1:SetText((f.spell.showValue and f.spell.v1) and f.spell.v1 or nil)
				f.timetext:SetText("")
				if self.ui.display_mode ~= DB.DISPLAY_BAR then 
					f.icon:UpdateCooldowning(false)
					f.icon:Stop()
					if select(4, GetBuildInfo()) < 100000 then
						f.icon:SetBorderColor(adjuistColor(self.ui.icon.active_border_color, OLD_DK_COLOR[f.spell.no].color))
					end

					f.counttext:SetText(nil)
				end
			end
			self:UpdateGlow(f, true)
		end
	end
end

function HDH_DK_RUNE_TRACKER:InitIcons()
	self.power = 0
	local ret = HDH_TRACKER.InitIcons(self)
	self.frame.pointer = {}
	for i = 1 , ret do
		-- 룬은 순서가 보장되지 않는다. 
		-- 만약 쿨 도는 와중에 아이콘 순서 변경이 일어나면, 순간적으로 깜박이는 현상이 발생됨
		-- 그래서 한번 지정한 아이콘을 쿨 마지막까지 유지하기 위해서 pointer 사용
		self.frame.pointer[i] = self.frame.icon[i] 
		self.frame.icon[i].spell.power_index = self.POWER_INFO[self.type].power_index
	end
	self.frame:RegisterEvent("RUNE_POWER_UPDATE")
	self.frame:RegisterEvent("RUNE_TYPE_UPDATE")
	self:Update()
	return ret
end

function HDH_DK_RUNE_TRACKER:OnEvent(event, ...)
	if not self.parent then return end
	if ( event == "RUNE_POWER_UPDATE" ) then
		self.parent:Update()
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