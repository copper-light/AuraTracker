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


local super = HDH_C_TRACKER
setmetatable(HDH_DK_RUNE_TRACKER, super) -- 상속
HDH_DK_RUNE_TRACKER.__index = HDH_DK_RUNE_TRACKER
HDH_DK_RUNE_TRACKER.className = "HDH_DK_RUNE_TRACKER"
HDH_DK_RUNE_TRACKER.POWER_INFO = POWER_INFO
	
-- 매 프레임마다 bar frame 그려줌, 콜백 함수
local function DK_OnUpdateCooldown(self)
	local spell = self:GetParent():GetParent().spell
	if not spell then self:Hide() return end
	
	spell.curTime = GetTime()
	if spell.curTime - (spell.delay or 0) < HDH_TRACKER.ONUPDATE_FRAME_TERM then return end -- 10프레임
	spell.delay = spell.curTime
	spell.remaining = spell.endTime - spell.curTime

	if spell.remaining > 0 and spell.duration > 0 then
		self:GetParent():GetParent():GetParent().parent:UpdateTimeText(self:GetParent():GetParent().timetext, spell.remaining);
		if  self:GetParent():GetParent():GetParent().parent.ui.icon.cooldown ~= DB.COOLDOWN_CIRCLE then
			self:SetValue(spell.endTime - (spell.curTime - spell.startTime))
		end
	end
	-- if self:GetParent():GetParent():GetParent().parent.option.bar.enable and self:GetParent():GetParent().spell.duration > HDH_C_TRACKER.GlobalCooldown then
		-- self:GetParent():GetParent().bar:SetValue(self:GetParent():GetParent():GetParent().parent.option.bar.fill_bar and GetTime() or spell.startTime+spell.remaining);
	-- end
end

function HDH_DK_RUNE_TRACKER:CreateData()
	local trackerId = self.id
	local key = self.POWER_INFO[self.type].power_type
	local id = 0
	local name = self.POWER_INFO[self.type].power_type
	local texture = self.POWER_INFO[self.type].texture;
	local isAlways = true
	local isValue = false
	local isItem = false
	local r,g,b,a = unpack(self.POWER_INFO[self.type].color)

	if DB:GetTrackerElementSize(trackerId) > MAX_RUNES then
		DB:TrancateTrackerElements(trackerId)
	end

	for i = 1 , MAX_RUNES do
		local elemIdx = DB:AddTrackerElement(trackerId, key .. i, id, name .. i, texture, isAlways, isValue, isItem)
		DB:SetReadOnlyTrackerElement(trackerId, elemIdx) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다
	end 

	DB:CopyGlobelToTracker(trackerId)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.column_count', 6)
	DB:SetTrackerValue(trackerId, 'ui.%s.common.order_by', DB.ORDERBY_CD_ASC)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.width', 40)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.height', 20)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.reverse_fill', true)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.reverse_progress', false)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.texture', 3)	
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.show_spark', true)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.use_full_color', true)
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', {r,g,b, 0.35})
	DB:SetTrackerValue(trackerId, 'ui.%s.bar.full_color', self.POWER_INFO[self.type].color)
	DB:SetTrackerValue(trackerId, 'ui.%s.font.show_name', false)
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
	if f.spell.startTime ~= 0 then
		if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1) end
		if f.spell.count == 0 then f.counttext:SetText(nil)
								else f.counttext:SetText(f.spell.count) end
		f.cd:Show()
		f.icon:SetAlpha(self.ui.icon.off_alpha)
		f.border:SetAlpha(self.ui.icon.off_alpha)
		f.border:SetVertexColor(0,0,0)
		f.iconSatCooldown:Show()
		if self.ui.icon.cooldown == DB.COOLDOWN_CIRCLE then
			f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
		else
			f.cd:SetMinMaxValues(f.spell.startTime, f.spell.endTime)
			f.cd:SetValue(f.spell.endTime - (GetTime() - f.spell.startTime))
		end
		self:SetGlow(f, false)
		f:Show()
		if self.ui.display_mode ~= DB.DISPLAY_ICON and f.bar then
			self:UpdateBarValue(f, false);
		end
		
	else
		if self.ui.display_mode ~= DB.DISPLAY_ICON and f.bar then self:UpdateBarValue(f, true); end
		f.icon:SetDesaturated(nil)
		f.timetext:SetText("");
		if self.ui.display_mode ~= DB.DISPLAY_BAR and f.spell.always then 
			f.icon:SetAlpha(self.ui.icon.on_alpha)
			f.border:SetAlpha(self.ui.icon.on_alpha)
			f.border:SetVertexColor(unpack(self.ui.icon.active_border_color)) 
			f.counttext:SetText(nil)
			f.iconSatCooldown:Hide()
			f.iconSatCooldown.spark:Hide()
			f.cd:Hide() 
			self:SetGlow(f, true)
			f:Show()
		else
			f:Hide()
		end
	end
	self:Update_Layout()
end

function HDH_DK_RUNE_TRACKER:UpdateIcons()
	for k,v in pairs(self.frame.icon) do
		self:UpdateIcon(v)
	end
	-- self:Update_Layout()
end

function HDH_DK_RUNE_TRACKER:Update_Layout()
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
			if f:IsShown() then
				f:ClearAllPoints()
				f:SetPoint('RIGHT', self.frame, 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
				show_index = show_index + 1
				if i % line == 0 then row = row + size_h + margin_v; col = 0
									else col = col + size_w + margin_h end
				if f.spell.remaining > 0 then ret = ret + 1 end -- 비전투라도 쿨이 돌고 잇는 스킬이 있으면 화면에 출력하기 위해서 체크함
			else
				-- if self.option.base.fix then
				-- 	f:ClearAllPoints()
				-- 	f:SetPoint('RIGHT', self.frame, 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
				-- 	show_index = show_index + 1
				-- 	if i % line == 0 then row = row + size_h + margin_v; col = 0
				-- 					else col = col + size_w + margin_h end
				-- end
			end
		end
	end
	if HDH_TRACKER.ENABLE_MOVE or ret > 0 or UnitAffectingCombat("player") or self.ui.common.always_show  then
		self:ShowTracker();
	else
		self:HideTracker();
	end
end

function HDH_DK_RUNE_TRACKER:UpdateRune(runeIndex, isEnergize)
	local ret = false;
	local start, duration, runeReady = GetRuneCooldown(runeIndex);
	if self and self.frame.pointer[runeIndex] then
		local spell = self.frame.pointer[runeIndex].spell
		if start and spell then
			spell.duration = duration
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

-- function HDH_DK_RUNE_TRACKER:UpdateRuneType(runeIndex)
-- 	local runeType = GetRuneType(runeIndex)
-- 	local iconf = self.frame.pointer[runeIndex]
-- 	if not iconf then return end
-- 	iconf.spell.type = runeType
-- end

function HDH_DK_RUNE_TRACKER:Update() -- HDH_TRACKER override
	if not self.frame or HDH_TRACKER.ENABLE_MOVE then return end
	for i = 1 , MAX_RUNES do
		self:UpdateRune(i)
		--self:UpdateRuneType(i)
	end
	self:UpdateIcons()
end

function HDH_DK_RUNE_TRACKER:InitIcons()
	if HDH_TRACKER.ENABLE_MOVE then return end
	local trackerId = self.id
	local id, name, _, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
	self.aura_filter = aura_filter
	self.aura_caster = aura_caster
	if not id then 
		return 
	end

	local elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem, glowCondition, glowValue
	
	local spell 
	local f
	local iconIdx = 0
	self.frame.pointer = {}
	self.frame:UnregisterAllEvents()
	
	self.talentId = GetSpecialization()

	if not self:IsHaveData() then
		self:CreateData()
	end
	local elemSize = DB:GetTrackerElementSize(trackerId)

	for i = 1 , elemSize do
		elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
		glowType, glowCondition, glowValue = DB:GetTrackerElementGlow(trackerId, i)
			
		iconIdx = iconIdx + 1
		f = self.frame.icon[iconIdx]
		if f:GetParent() == nil then f:SetParent(self.frame) end
		self.frame.pointer[iconIdx] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
		spell = {}
		spell.glow = glowType
		spell.glowCondtion = glowCondition
		spell.glowValue = (glowValue and tonumber(glowValue)) or 0

		spell.showValue = isValue
		-- spell.glowV1= auraList[i].GlowV1
		spell.always = isAlways
		-- spell.showValue = auraList[i].ShowValue -- 수치표시
		-- spell.v1_hp =  auraList[i].v1_hp -- 수치 체력 단위표시
		spell.v1 = 0 -- 수치를 저장할 변수
		spell.aniEnable = true;
		spell.aniTime = 8;
		spell.aniOverSec = false;
		spell.no = i
		spell.name = elemName
		spell.icon = texture
		spell.power_index = self.POWER_INFO[self.type].power_index
		-- if not auraList[i].defaultImg then auraList[i].defaultImg = texture; 
		-- elseif auraList[i].defaultImg ~= auraList[i].texture then spell.fix_icon = true end
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
		
		self:SetGlow(f, false)
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
			-- self.parent:UpdateRune(runeIndex, isEnergize)
			-- self.parent:UpdateIcon(runeIndex)
			self.parent:Update();
		end
	elseif ( event == "RUNE_TYPE_UPDATE" ) then
		local runeIndex = ...;
		if ( runeIndex and runeIndex >= 1 and runeIndex <= MAX_RUNES ) then
			-- self.parent:UpdateRuneType(runeIndex)
			-- self.parent:UpdateIcon(runeIndex)
			self.parent:Update();
		end
	end
end

------------------------------------
-- HDH_DK_RUNE_TRACKER class
------------------------------------