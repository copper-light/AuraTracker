local DB = HDH_AT_ConfigDB
HDH_AURA_TRACKER = {}
HDH_AURA_TRACKER.BOSS_DEBUFF = {}
HDH_AURA_TRACKER.DISABLE_DEBUFF = {57724}
-- HDH_UNIT_LIST = {"player","target","focus","pet","boss1","boss2","boss3","boss4","boss5","party1","party2","party3","party4","arena1","arena2","arena3","arena4","arena5"};

local PLAY_SOUND = false

--------------------------------------------
-- OnUpdate
--------------------------------------------

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
			f.bar:SetValue(tracker.ui.bar.fill_bar and (maxV-spell.remaining) or (spell.remaining));
			tracker:moveSpark(tracker, f, spell);
		end

		if tracker.ui.common.display_mode ~= DB.DISPLAY_BAR then
			if tracker.ui.icon.cooldown ~= DB.COOLDOWN_CIRCLE then
				spell.per = math.ceil(spell.remaining / spell.duration * 1000) / 1000

				if spell.per < 0.99 then
					if not f.iconSatCooldown.spark:IsShown() then
						f.iconSatCooldown.spark:Show()
					end
				else
					if f.iconSatCooldown.spark:IsShown() then
						f.iconSatCooldown.spark:Hide()
					end
				end
				
				f.iconSatCooldown.curSize = math.ceil(f.icon:GetHeight() * spell.per * 10000) / 10000 
				if (f.iconSatCooldown.curSize ~= f.iconSatCooldown.preSize) then
					if (f.iconSatCooldown.curSize == 0) then f.iconSatCooldown:Hide() end
					if tracker.ui.icon.cooldown == DB.COOLDOWN_LEFT then
						spell.texcoord = (0.07 + (math.ceil(0.86 * spell.per * 1000) / 1000))
						f.iconSatCooldown:SetWidth(f.iconSatCooldown.curSize)
						f.iconSatCooldown:SetTexCoord(0.07, spell.texcoord, 0.07, 0.93)
					elseif tracker.ui.icon.cooldown == DB.COOLDOWN_RIGHT then
						spell.texcoord = (0.07 + 0.86 - (math.ceil(0.86 * spell.per * 1000) / 1000))
						f.iconSatCooldown:SetWidth(f.iconSatCooldown.curSize)
						f.iconSatCooldown:SetTexCoord(spell.texcoord, 0.93, 0.07, 0.93)
					elseif tracker.ui.icon.cooldown == DB.COOLDOWN_UP then
						spell.texcoord = (0.07 + (math.ceil(0.86 * spell.per * 1000) / 1000))
						f.iconSatCooldown:SetHeight(f.iconSatCooldown.curSize)
						-- f.iconSatCooldown:SetPoint("BOTTOM", 0, f.icon:GetHeight()-f.iconSatCooldown.curSize)
						f.iconSatCooldown:SetTexCoord(0.07, 0.93, 0.07, spell.texcoord)
					else
						spell.texcoord = (0.07 + 0.86 - (math.ceil(0.86 * spell.per * 1000) / 1000))
						f.iconSatCooldown:SetHeight(f.iconSatCooldown.curSize)
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
function HDH_AURA_TRACKER:OnUpdateBarValue(elapsed)
	UpdateCooldown(self:GetParent(), elapsed);
end

-- function HDH_AURA_TRACKER:CheckCondition(f, remaining)
	-- self:SetGlow(f, true);
-- end

function HDH_AURA_TRACKER:moveSpark(tracker,f, spell)
	if not tracker.ui.bar.show_spark then return end
	if tracker.ui.bar.fill_bar == tracker.ui.bar.reverse_progress then
		if f.bar:GetOrientation() == "HORIZONTAL" then
			f.bar.spark:SetPoint("CENTER", f.bar,"LEFT", f.bar:GetWidth() * (spell.remaining/(spell.endTime-spell.startTime)), 0);
		else
			f.bar.spark:SetPoint("CENTER", f.bar,"BOTTOM", 0, f.bar:GetHeight() * (spell.remaining/(spell.endTime-spell.startTime)));
		end
	else
		if f.bar:GetOrientation() == "HORIZONTAL" then
			f.bar.spark:SetPoint("CENTER", f.bar,"RIGHT", -f.bar:GetWidth() * (spell.remaining/(spell.endTime-spell.startTime)), 0);
		else
			f.bar.spark:SetPoint("CENTER", f.bar,"TOP", 0, -f.bar:GetHeight() * (spell.remaining/(spell.endTime-spell.startTime)));
		end
	end
end

-------------------------------------------
-- timer
-------------------------------------------

local function AT_Timer_Func(self)
	if self and self.arg then
		local tracker = self.arg:GetParent() and self.arg:GetParent().parent or nil;
		if tracker then
			tracker:StartAni(self.arg,1);
		end
	end
end

local function AT_HasTImer(f)
	return f.timer and true or false
end	

local function AT_StopTimer(f)
	if f and f.timer then
		f.timer:Cancel()
		f.timer = nil
	end
end

local function AT_StartTimer(f, runTime)
	if HDH_TRACKER.ENABLE_MOVE then return end
	if f then
		if f.timer and f.timer.runTime ~= runTime then
			AT_StopTimer(f);
		end
		if not f.timer then
			f:GetParent().parent:StopAni(f);
			local d = runTime- GetTime();
			if d > 0 then
				f.timer = C_Timer.NewTimer(d, AT_Timer_Func)
				f.timer.arg = f
				f.timer.runTime = runTime;
			end
		end
	end
end

-------------------------------------------
-- sound
-------------------------------------------

function HDH_PlaySoundFile(path, channel)
	if PLAY_SOUND then
		PlaySoundFile(path,channel)
	end
end
	
function HDH_OnShowCooldown(self)
	local f = self:GetParent():GetParent();
	if f.spell and f.spell.startSound and not OptionFrame:IsShown() then
		if (f.spell.duration - f.spell.remaining) < 0.5 then
			HDH_PlaySoundFile(f.spell.startSound,"SFX")
		end
	end
end

function HDH_OnHideCooldown(self)
	local f = self:GetParent():GetParent();
	if f.spell and f.spell.endSound and not OptionFrame:IsShown() then
		HDH_PlaySoundFile(f.spell.endSound, "SFX")
	end
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
	f.cooldown1:SetStatusBarTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\cooldown_bg.blp");
	f.cooldown1:Hide();
	f.cooldown1.parent=f;
	f.cd = f.cooldown1
	
	f.cooldown2 = CreateFrame("Cooldown", nil, f.iconframe) -- 원형
	f.cooldown2:SetPoint('TOPLEFT', f.iconframe, 'TOPLEFT', 0, 0)
	f.cooldown2:SetPoint('BOTTOMRIGHT', f.iconframe, 'BOTTOMRIGHT', 0, 0)
	f.cooldown2:SetMovable(true);
	f.cooldown2:SetScript('OnUpdate', OnUpdateCooldown)
	f.cooldown2:SetHideCountdownNumbers(true) 
	f.cooldown2:SetSwipeTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\cooldown_bg.blp"); -- Interface\\AddOns\\HDH_AuraTracker\\cooldown_bg.blp
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
	
	f.border = CreateFrame("Frame", nil, f.iconframe):CreateTexture(nil, 'OVERLAY')
	f.border:SetTexture([[Interface/AddOns/HDH_AuraTracker/Texture/border.blp]])
	f.border:SetVertexColor(0,0,0)
	-- f.border:SetAllPoints(f);
end

------------------------------------------
 -- AURA TRACKER Class
--------------------------------------------
local super = HDH_TRACKER
setmetatable(HDH_AURA_TRACKER, super) -- 상속
HDH_AURA_TRACKER.__index = HDH_AURA_TRACKER
HDH_AURA_TRACKER.className = "HDH_AURA_TRACKER"

HDH_TRACKER.TYPE.BUFF = 1
HDH_TRACKER.TYPE.DEBUFF = 2
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.BUFF, HDH_AURA_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.DEBUFF, HDH_AURA_TRACKER)

do

	function HDH_AURA_TRACKER:Init(id, name, type, unit)
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
	
	function HDH_AURA_TRACKER:Release()
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

	function HDH_AURA_TRACKER:Modify(newName, newType, newUnit)
		-- HDH_DB_Modify(self.name, newName, newType, newUnit)
		-- HDH_AURA_TRACKER.ModifyList(self.id, newId)
		
		if newType ~= self.type then
			self:Release() -- 프레임 관련 메모리 삭제하고
			setmetatable(self, HDH_TRACKER.GetClass(newType)) -- 클래스 변경하고
		end
		self:Init(self.id, newName, newType, newUnit) -- 프레임 초기화 + DB 로드
		self:OnModifyEvent();
		if HDH_TRACKER.ENABLE_MOVE then
			self:SetMove(false)
			self:SetMove(true)
		end
	end
	
	function HDH_AURA_TRACKER:IsHaveData()
		_, _, _, _, aura_filter = DB:GetTrackerInfo(self.id)
		local cnt;
		if aura_filter ~= DB.AURA_FILTER_REG then
			cnt = HDH_TRACKER.MAX_ICONS_COUNT;
		else
			cnt = DB:GetTrackerElementSize(self.id)   or 0;
		end
		return (cnt > 0) and cnt or false;
	end
	
	function HDH_AURA_TRACKER:OnModifyEvent() -- 다른 클래스에서 DB 업데이트할 수 있도록 인터페이스 준비.
		-- interface
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
		end
	end

	-- bar 세부 속성 세팅하는 함수 (나중에 option 을 통해 바 값을 변경할수 있기에 따로 함수로 지정해둠)
	function HDH_AURA_TRACKER:UpdateIconSettings(f)
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
	
	function HDH_AURA_TRACKER:UpdateArtBar(f)
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
				t:SetTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\cooldown_bg.blp");
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

			-- 아이콘 숨기기는 바와 연관되어 있기 때문에 바 설정쪽에 위치함.
			if hide_icon then
				f.iconframe:Hide();
				-- f.border:Hide();
				f.bar:SetScript("OnUpdate",self.OnUpdateBarValue);
			else
				f.iconframe:Show();
				-- f.border:Show();
				f.bar:SetScript("OnUpdate",nil);
			end
			
			if op.reverse_progress then f.bar:SetStatusBarTexture(DB.BAR_TEXTURE[op.texture].texture_r); 
			else f.bar:SetStatusBarTexture(DB.BAR_TEXTURE[op.texture].texture); end
			f.bar:ClearAllPoints();
			if op.location == DB.BAR_LOCATION_T then     
				f.bar:SetSize(op.height,op.width);
				f.bar:SetPoint("BOTTOM",f, hide_icon and "BOTTOM" or "TOP",0,1); 
				f.bar:SetOrientation("Vertical"); f.bar:SetRotatesTexture(true);
				f.bar.spark:SetTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\UI-CastingBar-Spark_v");
				f.bar.spark:SetSize(op.height*1.3, 19);
			elseif op.location == DB.BAR_LOCATION_B then 
				f.bar:SetSize(op.height,op.width);
				f.bar:SetPoint("TOP",f, hide_icon and "TOP" or "BOTTOM",0,-1); 
				f.bar:SetOrientation("Vertical"); f.bar:SetRotatesTexture(true);
				f.bar.spark:SetTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\UI-CastingBar-Spark_v");
				f.bar.spark:SetSize(op.height*1.3, 19);
			elseif op.location == DB.BAR_LOCATION_L then 
				f.bar:SetSize(op.width,op.height);
				f.bar:SetPoint("RIGHT",f, hide_icon and "RIGHT" or "LEFT",-1,0); 
				f.bar:SetOrientation("Horizontal"); f.bar:SetRotatesTexture(false);
				f.bar.spark:SetTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\UI-CastingBar-Spark");
				f.bar.spark:SetSize(19, op.height*1.3);
			else 
				f.bar:SetSize(op.width,op.height);
				f.bar:SetPoint("LEFT",f, hide_icon and "LEFT" or "RIGHT",1,0); 
				f.bar:SetOrientation("Horizontal"); f.bar:SetRotatesTexture(false);
				f.bar.spark:SetTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\UI-CastingBar-Spark");
				f.bar.spark:SetSize(19, op.height*1.3);
				
			end
			f.bar:SetStatusBarColor(unpack(op.color));
			-- f.bar:SetAlpha(0.5);
			f.bar:SetReverseFill(op.reverse_progress);
			-- f.bar:Show();
			
			f.bar.spark:Hide();
			-- f.bar.spark:SetPoint("CENTER",f.bar,"RIGHT",0,0);
			self:SetGameTooltip(f.bar, show_tooltip or false);
			f.bar:SetMouseClickEnabled(false);
		else
			if f.bar then f.bar:Hide(); f.bar:SetScript("OnUpdate",nil); end
			if hide_icon then
				f.iconframe:Show();
			end
		end
	end
	
	function HDH_AURA_TRACKER:SetGameTooltip(f, show)
		f:EnableMouse(show)
		if show then
			f:SetScript("OnEnter",function(frame) 
				local spell = f.spell or (f:GetParent() and f:GetParent().spell)
				if not HDH_TRACKER.ENABLE_MOVE and spell and spell.id then
					local isItem = spell.isItem
					local id = spell.id
					local link = isItem and select(2,GetItemInfo(id)) or GetSpellLink(id)
					if not link then return end
					GameTooltip:SetOwner(f, "ANCHOR_BOTTOMRIGHT");
					if self:GetClassName() == "HDH_TRACKER" and spell.index then
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
	
	function HDH_AURA_TRACKER:CreateData(spec)
		-- interface
	end
	
	function HDH_AURA_TRACKER:ReleaseIcons()
		if not self.frame.icon then return end
		for i=#self.frame.icon, 1, -1 do
			self:ReleaseIcon(i)
		end
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
	
	function HDH_AURA_TRACKER:CreateDummySpell(count)
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
				f.icon:SetTexture("Interface\\ICONS\\TEMP")
				f.iconSatCooldown:SetTexture("Interface\\ICONS\\TEMP")
			end
			f:ClearAllPoints()
			prevf = f
			spell = f.spell
			if not spell then spell = {} f.spell = spell end
			spell.always = true
			spell.id = 0
			spell.count = 1+i
			spell.duration = 50*i
			spell.happenTime = 0;
			spell.glow = false
			spell.endTime = curTime + spell.duration
			spell.startTime = spell.endTime - spell.duration
			spell.remaining = spell.startTime+spell.duration
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
			f.icon:SetAlpha(ui.icon.on_alpha)
			f.border:SetAlpha(ui.icon.on_alpha)
			self:SetGameTooltip(f, false)
			if i <=	100 then  f.cd:Show() 
						   f.icon:SetAlpha(ui.icon.on_alpha)
						   f.border:SetAlpha(ui.icon.on_alpha) 
						   spell.isUpdate = true
					  else f.cd:Hide()
						   f.icon:SetAlpha(ui.icon.off_alpha)
						   f.border:SetAlpha(ui.icon.off_alpha)
						   spell.isUpdate = false end
			f:Show()
		end
		return count;
	end
	
	function HDH_AURA_TRACKER:ReleaseIcon(idx)
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

	function HDH_AURA_TRACKER:UpdateSetting()
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

	function HDH_AURA_TRACKER:ConnectMoveHandler(count)
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
	
	function HDH_AURA_TRACKER:SetMove(move)
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
					text:SetFont(HDH_TRACKER.FONT_STYLE, 13, "OUTLINE")
					text:SetTextColor(1,0,0)
					text:SetWidth(190)
					text:SetHeight(70)
					--text:SetAlpha(0.7)
					
					text:SetJustifyH("LEFT")
					text.text = ("|cffffff00["..self.name.."]")
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

	function HDH_AURA_TRACKER:ChangeCooldownType(f, cooldown_type)
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
			f.iconSatCooldown.spark:SetTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\UI-CastingBar-Spark_v");
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
			f.iconSatCooldown.spark:SetTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\UI-CastingBar-Spark_v");
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
			f.iconSatCooldown.spark:SetTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\UI-CastingBar-Spark");
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
			f.iconSatCooldown.spark:SetTexture("Interface\\AddOns\\HDH_AuraTracker\\Texture\\UI-CastingBar-Spark");
			f.iconSatCooldown.spark:SetPoint("CENTER", f.iconSatCooldown,"LEFT",0,0)

		else
			f.iconSatCooldown:Hide() 
			f.iconSatCooldown.spark:Hide() 
			f.cd = f.cooldown2
			f.cooldown1:Hide()
		end
	end
	
	local function ValueFormat(value, v_type)
		if not value then return "" end
		if value < 1000 then
			value = string.format("%d%s", value, (v_type and "%" or ""))
		elseif value < 1000000 then
			value = value/1000
			value = string.format("%dk%s", value, (v_type and "%" or ""))
		else
			value = value/1000000
			value = string.format("%dm%s", value, (v_type and "%" or ""))
		end
		return value	
	end
	
	function HDH_AURA_TRACKER:UpdateTimeText(text, value)
		if self.ui.font.cd_format == DB.TIME_TYPE_FLOOR then value = value + 1; end
		if value > 5 then text:SetTextColor(unpack(self.ui.font.cd_color)) 
				     else text:SetTextColor(unpack(self.ui.font.cd_color_5s)) end
		if value <= 9.9 and self.ui.font.cd_format == DB.TIME_TYPE_FLOAT then 
			text:SetText(('%.1f'):format(value))
		elseif value < 60 then text:SetText(('%d'):format(value))
		else text:SetText(('%d:%02d'):format((value)/60, (value)%60)) end
	end
	
	function HDH_AURA_TRACKER:UpdateBarValue(f, isEnding)
		if f.bar and f.name then
			if self.ui.bar.fill_bar then
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
	
	function HDH_AURA_TRACKER:IsSwitchByRemining(icon1, icon2) 
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
	
	function HDH_AURA_TRACKER:InAsendingOrderByTime()
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
	
	function HDH_AURA_TRACKER:InDesendingOrderByTime()
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
	
	function HDH_AURA_TRACKER:IsSwitchByHappenTime(icon1, icon2) 
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
	
	function HDH_AURA_TRACKER:InAsendingOrderByCast()
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
	
	function HDH_AURA_TRACKER:InDesendingOrderByCast()
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
	
	function HDH_AURA_TRACKER:LoadOrderFunc()
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

	function HDH_AURA_TRACKER:IsRaiding()
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
	
	function HDH_AURA_TRACKER:MatchBossUnit(target_unit)
		local ret = false;
		if self.boss_guid and target_unit then
			for i = 1, MAX_BOSS_FRAMES do
			local boss_unit = "boss"..i;
				if ExstisUnit(boss_unit) then
					local boss_guid = UnitGUID(boss_unit);
					if Uboss_guid and boss_guid == UnitGUID(target_unit) then
						return true;
					end
				end
			end
		end
		return ret;
	end
	
	function HDH_AURA_TRACKER:UpdateIcons()
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local column_count = self.ui.common.column_count or 10-- 한줄에 몇개의 아이콘 표시
		local margin_h = self.ui.common.margin_h
		local margin_v = self.ui.common.margin_v
		local size = self.ui.icon.size -- 아이콘 간격 띄우는 기본값
		local reverse_v = self.ui.common.reverse_v -- 상하반전
		local reverse_h = self.ui.common.reverse_h -- 좌우반전
		local icons = self.frame.icon
		local aura_filter = self.aura_filter
		local aura_caster = self.aura_caster
		local display_mode = self.ui.common.display_mode
		local cooldown_type = self.ui.icon.cooldown
		
		local i = 0 -- 몇번째로 아이콘을 출력했는가?
		local col = 0  -- 열에 대한 위치 좌표값 = x
		local row = 0  -- 행에 대한 위치 좌표값 = y
		if self.OrderFunc then self.OrderFunc(self) end 
		for k,f in ipairs(icons) do
			if not f.spell then break end
			if f.spell.isUpdate then
				f.spell.isUpdate = false
				
				if aura_caster == DB.AURA_CASTER_ONLY_MINE then
					if f.spell.count < 2 then f.counttext:SetText(nil)
										 else f.counttext:SetText(f.spell.count) end
				else
					if f.spell.count < 2 then if f.spell.overlay <= 1 then f.counttext:SetText(nil)
																      else f.counttext:SetText(f.spell.overlay) end
										 else f.counttext:SetText(f.spell.count)  end
				end
				
				if f.spell.showValue and f.spell.v1 then 
					f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(f.spell.v1, true)) 
				else 
					f.v1:SetText(nil) 
				end
				
				if f.spell.duration == 0 then 
					f.cd:Hide() f.timetext:SetText("");
					f.icon:SetDesaturated(nil)
			    	f.icon:SetAlpha(self.ui.icon.on_alpha)
			    	f.border:SetAlpha(self.ui.icon.on_alpha)
					f.iconSatCooldown:Hide()
					f.iconSatCooldown.spark:Hide()
				else 
					f.cd:Show()
					
					self:UpdateTimeText(f.timetext, f.spell.remaining)
					
					if cooldown_type ~= DB.COOLDOWN_CIRCLE then
						f.icon:SetAlpha(self.ui.icon.off_alpha)
						f.border:SetAlpha(self.ui.icon.off_alpha)
						f.icon:SetDesaturated(1)
						f.iconSatCooldown:SetAlpha(self.ui.icon.on_alpha)
						f.iconSatCooldown:Show()
						-- f.iconSatCooldown.spark:Show()
					else
						f.icon:SetAlpha(self.ui.icon.on_alpha)
						f.border:SetAlpha(self.ui.icon.on_alpha)
						f.icon:SetDesaturated(nil)
					end
				end
				
				if not self.ui.common.default_color or f.spell.dispelType == nil then 
					f.border:SetVertexColor(unpack(self.ui.icon.active_border_color)) 
				else 
					f.border:SetVertexColor(
						DebuffTypeColor[f.spell.dispelType or ""].r, 
						DebuffTypeColor[f.spell.dispelType or ""].g, 
						DebuffTypeColor[f.spell.dispelType or ""].b,
						1
					)
				end
				if cooldown_type == DB.COOLDOWN_CIRCLE then
					if HDH_TRACKER.startTime < f.spell.startTime or (f.spell.duration == 0) then
						f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
					else
						f.cd:SetCooldown(HDH_TRACKER.startTime, f.spell.duration - (f.spell.startTime - HDH_TRACKER.startTime));
					end
				else
					f.cd:SetMinMaxValues(f.spell.startTime, f.spell.endTime);
					f.cd:SetValue(GetTime());
				end
				if display_mode ~= DB.DISPLAY_ICON and f.bar then
					-- f.bar:SetMinMaxValues(f.spell.startTime, f.spell.endTime);
					if not f.bar:IsShown() then f.bar:Show(); end
					f.name:SetText(f.spell.name);
					-- f.name:SetTextColor(unpack(self.ui.bar.name_color));
					if f.spell.duration == 0 then
						-- f.bar:SetMinMaxValues(0,1);
						-- f.bar:SetValue(1);
						f.spell.remaining = 1;
						f.spell.endTime = 1;
						f.spell.startTime = 0;
					else
						-- f.bar:SetMinMaxValues(f.spell.startTime, f.spell.endTime);
						-- f.bar:SetValue(f.spell.startTime+ f.spell.remaining);
						-- self:UpdateBarValue(f);
					end
					f.iconSatCooldown.spark:Hide()
					self:UpdateBarValue(f);
				end
				f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
				i = i + 1
				if i % column_count == 0 then row = row + size + margin_v; col = 0
								         else col = col + size + margin_h end
				ret = ret + 1
				f:Show()
				self:SetGlow(f, true)
			else
				f.timetext:SetText(nil);
				if f.spell.always then 
					-- if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1)
					-- 								   f.icon:SetAlpha(self.ui.icon.off_alpha)
					-- 								   f.border:SetAlpha(self.ui.icon.off_alpha)
					-- 								   f.border:SetVertexColor(0,0,0) end
					f.icon:SetDesaturated(1)
					f.icon:SetAlpha(self.ui.icon.off_alpha)
					f.border:SetAlpha(self.ui.icon.off_alpha)
					f.border:SetVertexColor(0,0,0) 
					f.v1:SetText(nil)
					f.counttext:SetText(nil)
					f.cd:Hide()
					f.iconSatCooldown.spark:Hide() 
					f.iconSatCooldown:Hide() 
					if display_mode ~= DB.DISPLAY_ICON and f.bar then 
						if not f.bar:IsShown() then f.bar:Show(); end
						-- f.bar:SetMinMaxValues(0,1); 
						-- f.bar:SetValue(0); 
						f.name:SetText(f.spell.name);
						-- f.name:SetTextColor(1,1,1,0.35);
						self:UpdateBarValue(f, true);
					end--f.bar:Hide();
					f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
					i = i + 1
					if i % column_count == 0 then row = row + size + margin_v; col = 0
								     else col = col + size + margin_h end
					f:Show()
					self:SetGlow(f, false)
				else
					if self.ui.common.location_fix then
						i = i + 1
						if i % column_count == 0 then row = row + size + margin_v; col = 0
										 else col = col + size + margin_h end
					end
					f:Hide()
				end
				f.spell.endTime = nil;
				f.spell.duration = 0;
				f.spell.duration = 0;
				f.spell.remaining = 0;
				f.spell.happenTime = nil;
				f.spell.overlay = 0
				f.spell.count = 0
			end
		end
		return ret
	end

	local StaggerID = { }
	StaggerID[124275] = true
	StaggerID[124274] = true
	StaggerID[124273] = true 
	
	function HDH_AURA_TRACKER.GetAuras(self)
		local curTime = GetTime()
		local name, count, duration, endTime, caster, id, v1, v2, v3
		local ret = 0;
		local f

		for i = 1, 40 do 
			-- name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod
			name, _, count, dispelType, duration, endTime, caster, _, _, id, _, _, _, _, _, v1, v2, v3 = UnitAura(self.unit, i, self.filter)
			if not id then break end
			f = self.frame.pointer[tostring(id)] or self.frame.pointer[name]
			if f and f.spell then		
				spell = f.spell
				
				if not StaggerID[id] then -- 시간차가 아니면
					spell.v1 = (v1 ~= 0) and v1 or nil
				else -- 시간차
					-- if spell.v1_hp then
						-- spell.v1 = math.ceil((v3 / UnitHealthMax(self.unit)) *100)
					-- else
						spell.v1 = v2; 
					-- end
				end
				
				if not spell.isUpdate then
					spell.count = count
				else
					spell.count = (spell.count or 0) + count
				end
				
				spell.id = id
				spell.dispelType = dispelType
				spell.overlay = (spell.overlay or 0) + 1
				if spell.endTime ~= endTime then spell.endTime = endTime; spell.happenTime = GetTime(); end
				if endTime > 0 then spell.remaining = spell.endTime - curTime
				else spell.remaining = 0; end
				spell.duration = duration
				spell.startTime = endTime - duration
				spell.index = i; -- 툴팁을 위해, 순서
				ret = ret + 1;
				spell.isUpdate = true
			end
		end
		return ret;
	end
	
	function HDH_AURA_TRACKER.GetAurasAll(self)
		local curTime = GetTime()
		local ret = 1;
		local f
		for i = 1, 40 do 
			name, icon, count, dispelType, duration, endTime, caster, _, _, id, canApplyAura, isBossDebuff, castByPlayer = UnitAura(self.unit, i, self.filter)
			if not id then break end
			if self.aura_filter == DB.AURA_FILTER_ONLY_BOSS then
				if not castByPlayer and (self.isRaiding or (isBossDebuff)) then
					f = self.frame.icon[ret];
				else
					f = nil;
				end
			else
				f = self.frame.icon[ret];
			end
			
			if f then
				if not f.spell then f.spell = {} end
				spell = f.spell
				spell.no = i;
				spell.isUpdate = true
				spell.count = count
				spell.id = id
				spell.overlay = 0
				spell.endTime = endTime
				spell.name = name;
				spell.dispelType = dispelType
				spell.remaining = spell.endTime - curTime
				spell.duration = duration 	
				spell.startTime = endTime - duration
				spell.icon = icon
				spell.index = i; -- 툴팁을 위해, 순서
				spell.happenTime = GetTime();
				f.icon:SetTexture(icon)
				f.iconSatCooldown:SetTexture(icon)
				ret = ret + 1;
			end
		end
		for i = ret, #(self.frame.icon) do
			self.frame.icon[i]:Hide()
		end
	end

	-- 버프, 디버프의 상태가 변경 되었을때 마다 실행되어, 데이터 리스트를 업데이트 하는 함수
	function HDH_AURA_TRACKER:Update()
		if not self.frame or HDH_TRACKER.ENABLE_MOVE then return end
		if not UnitExists(self.unit) or not self.frame.pointer or not self.ui then 
			self.frame:Hide() return 
		end
		self.GetAurasFunc(self)
		if (self:UpdateIcons() > 0) or UnitAffectingCombat("player") then --  self.ui.icon.always_show 
			self:ShowTracker();
		else
			-- self.frame:Hide()
			self:HideTracker();
		end
	end

	function HDH_AURA_TRACKER:InitIcons()
		if HDH_TRACKER.ENABLE_MOVE then return end
		local trackerId = self.id
		local id, name, type, unit, aura_filter, aura_caster = DB:GetTrackerInfo(trackerId)
		self.aura_filter = aura_filter
		self.aura_caster = aura_caster
		if not id then return end
		local elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem, glowCondition, glowValue
		local elemSize = DB:GetTrackerElementSize(trackerId)
		local spell 
		local f
		local iconIdx = 0;
		local isBuff = (self.type == HDH_TRACKER.TYPE.BUFF);
		self.frame.pointer = {}

		if isBuff then self.filter = "HELPFUL";
		else self.filter = "HARMFUL"; end

		if aura_filter == DB.AURA_FILTER_ALL or aura_filter == DB.AURA_FILTER_ONLY_BOSS then
			self.GetAurasFunc = HDH_AURA_TRACKER.GetAurasAll
			if #(self.frame.icon) > 0 then self:ReleaseIcons() end
		else
			if aura_caster == DB.AURA_CASTER_ONLY_MINE then
				self.filter = self.filter .. "|PLAYER"
			end
			for i = 1, elemSize do
				elemKey, elemId, elemName, texture, isAlways, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
				glowType, glowCondition, glowValue = DB:GetTrackerElementGlow(trackerId, i)

				-- if not self:IsIgnoreSpellByTalentSpell(auraList[i]) then
				iconIdx = iconIdx + 1
				f = self.frame.icon[iconIdx]
				if f:GetParent() == nil then f:SetParent(self.frame) end
				self.frame.pointer[elemKey or tostring(elemId)] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
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
				-- if not auraList[i].defaultImg then auraList[i].defaultImg = texture; 
				-- elseif auraList[i].defaultImg ~= auraList[i].texture then spell.fix_icon = true end
				spell.id = tonumber(elemId)
				spell.count = 0
				spell.duration = 0
				spell.remaining = 0
				spell.overlay = 0
				spell.endTime = 0
				spell.is_buff = isBuff;
				spell.isUpdate = false
				spell.isItem =  isItem
				f.spell = spell
				f.icon:SetTexture(texture or "Interface\\ICONS\\INV_Misc_QuestionMark")
				f.iconSatCooldown:SetTexture(texture or "Interface\\ICONS\\INV_Misc_QuestionMark")
				f.iconSatCooldown:SetDesaturated(nil)
				-- f.icon:SetDesaturated(1)
				-- f.icon:SetAlpha(self.ui.icon.off_alpha)
				-- f.border:SetAlpha(self.ui.icon.off_alpha)
				self:ChangeCooldownType(f, self.ui.icon.cooldown)
				self:SetGlow(f, false)
				
				-- spell.startSound = auraList[i].StartSound
				-- spell.endSound = auraList[i].EndSound
				-- spell.conditionSound = auraList[i].ConditionSound
				-- if spell.startSound then
				-- 	f.cooldown2:SetScript("OnShow", HDH_OnShowCooldown)
				-- 	f.cooldown1:SetScript("OnShow", HDH_OnShowCooldown)
				-- end
				-- if spell.endSound then
				-- 	f.cooldown1:SetScript("OnHide", HDH_OnHideCooldown)
				-- 	f.cooldown2:SetScript("OnHide", HDH_OnHideCooldown)
				-- end
				-- end
			end
			self.GetAurasFunc = HDH_AURA_TRACKER.GetAuras
			for i = #(self.frame.icon) , iconIdx+1, -1  do
				self:ReleaseIcon(i)
			end
		end
		self:LoadOrderFunc();
		
		self.frame:SetScript("OnEvent", OnEventTracker)
		self.frame:UnregisterAllEvents()

		if aura_filter == DB.AURA_FILTER_ONLY_BOSS then
			self.frame:RegisterEvent('UNIT_AURA')
			self.frame:RegisterEvent("ENCOUNTER_START");
			self.frame:RegisterEvent("ENCOUNTER_END");
		end
		if #(self.frame.icon) > 0 or aura_filter == DB.AURA_FILTER_ALL then
			self.frame:RegisterEvent('UNIT_AURA')
			if self.unit == 'target' then
				self.frame:RegisterEvent('PLAYER_TARGET_CHANGED')
			elseif self.unit == 'focus' then
				self.frame:RegisterEvent('PLAYER_FOCUS_CHANGED')
			elseif string.find(self.unit, "boss") then 
				self.frame:RegisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT')
			elseif string.find(self.unit, "party") then
				self.frame:RegisterEvent('GROUP_ROSTER_UPDATE')
			elseif self.unit == 'pet' then
				self.frame:RegisterEvent('UNIT_PET')
			elseif string.find(self.unit, 'arena') then
				self.frame:RegisterEvent('ARENA_OPPONENT_UPDATE')
			end
		else
			return 
		end
		
		self:Update()
		return iconIdx;
	end

	function HDH_AURA_TRACKER:IsIgnoreSpellByTalentSpell(DB_Spell)
		local ret = false;
		if not DB_Spell then return true end
		if DB_Spell.Ignore and DB_Spell.Ignore[1] then
			local name = DB_Spell.Ignore[1].Spell;
			local show = DB_Spell.Ignore[1].Show;
			local selected = HDH_AT_UTIL.IsTalentSpell(name); -- true / false / nil: not found talent
			if selected == true then
				ret = (not show);
			elseif selected == false then
				ret = show;
			end
		end
		return ret;
	end
	
	function HDH_AURA_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:InitIcons()
	end
	
	function HDH_AURA_TRACKER:PLAYER_ENTERING_WORLD()
		self.isRaiding = self:IsRaiding()
	end
	
	-- function HDH_AURA_TRACKER:OnEffectEvent(self, event, ...)
		-- if event == "AT_EVENT_START_SOUND" then
		
		-- elseif event == "AT_EVENT_END_SOUND" then
		
		-- elseif event == "AT_EVENT_CONDITION_SOUND" then
		
		-- elseif event == ""
	-- end
	
	-------------------------------------------
	-- timer 
	-------------------------------------------


------------------------------------------
end -- TRACKER class
------------------------------------------




-------------------------------------------
-- 이벤트 메세지 function
-------------------------------------------
local function HDH_UNIT_AURA(self)
	if self then
		self:Update()
	end
end


function OnEventTracker(self, event, ...)
	if not self.parent then return end
	if event == 'UNIT_AURA' then
		local unit = select(1,...)
		if self.parent and unit == self.parent.unit then
			HDH_UNIT_AURA(self.parent)
		end
	elseif event =="PLAYER_TARGET_CHANGED" then
		self.parent:RunTimer("PLAYER_TARGET_CHANGED", 0.02, HDH_UNIT_AURA, self.parent) 
	elseif event == 'PLAYER_FOCUS_CHANGED' then
		HDH_UNIT_AURA(self.parent)
	elseif event == 'INSTANCE_ENCOUNTER_ENGAGE_UNIT' then
		HDH_UNIT_AURA(self.parent)
	elseif event == 'GROUP_ROSTER_UPDATE' then
		HDH_UNIT_AURA(self.parent)
	elseif event == 'UNIT_PET' then
		self.parent:RunTimer("UNIT_PET", 0.5, HDH_UNIT_AURA, self.parent) 
	elseif event == 'ARENA_OPPONENT_UPDATE' then
		self.parent:RunTimer("ARENA_OPPONENT_UPDATE", 0.5, HDH_UNIT_AURA, self.parent) 
	elseif event == "ENCOUNTER_START" then
		self.parent.isRaiding = true;
	elseif event == "ENCOUNTER_END" then
		self.parent.isRaiding = false;
	end
end

--------------------------------------------
-- 유틸
--------------------------------------------	

hooksecurefunc(C_ClassTalents, "LoadConfig", function(id, apply)
	-- print('hook', C_Traits.GetConfigInfo(id).name, apply)
	-- hook 치고 apply 가 false 가 안들어오고 TRAIT_CONFIG_UPDATED 가 콜되면 특성 변경으로 인식
end)
