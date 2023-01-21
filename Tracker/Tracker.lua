
local DB = HDH_AT_ConfigDB

--------------------------------------------
-- TRACKER Class 
--------------------------------------------
HDH_TRACKER = {}
HDH_TRACKER.objList = {}
HDH_TRACKER.__index = HDH_TRACKER
HDH_TRACKER.className = "HDH_TRACKER"

HDH_TRACKER.CLASSLIST = {}
HDH_TRACKER.TYPE = {}

--------------------------------------------
-- Properties
--------------------------------------------
HDH_TRACKER.ENABLE_MOVE = false
HDH_TRACKER.ONUPDATE_FRAME_TERM = 0.016;
HDH_TRACKER.ANI_SHOW = 1
HDH_TRACKER.ANI_HIDE = 2
HDH_TRACKER.FONT_STYLE = "fonts\\2002.ttf";
HDH_TRACKER.MAX_ICONS_COUNT = 10

--------------------------------------------
do -- TRACKER Static function
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
			HDH_TRACKER.Release(trackerId)
		else
			for k, v in pairs(HDH_TRACKER.objList) do
				HDH_TRACKER.Release(v.id)
			end
		end
	end
	
	function HDH_TRACKER.Release(trackerId) -- t = (number) or (tracker obj)
		local obj = HDH_TRACKER.Get(trackerId)
		if not obj then return end
		obj:Release()
		HDH_TRACKER.objList[trackerId] = nil
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

	function HDH_TRACKER.Update(trackerId)
		if trackerId then
			local t= HDH_TRACKER.Get(trackerId)
			if t then
				t:Update()
			end
		else
			-- local curTalentId = select(1, GetSpecializationInfo(GetSpecialization()))
			-- local curTransit = C_ClassTalents.GetLastSelectedSavedConfigID(curTalentId)
			local ids = DB:GetTrackerIdsByTransits(curTalentId, curTransit)
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
			local talentID, _, _ = GetSpecializationInfo(GetSpecialization())
			local currentTransitValue = C_ClassTalents.GetLastSelectedSavedConfigID(talentID)
			local trackerIds = DB:GetTrackerIdsByTransits(talentID, currentTransitValue)
			if not trackerIds or #trackerIds == 0 then return end
			-- ClassTalents.UpdateLastSelectedSavedConfigID(GetSpecializationInfo(GetSpecialization()))
			-- local trackerId = trackerList[1]
			-- local tracker = DB:GetTracker(trackerId)

			-- local trackers =  DB:GetTrackerList()

			
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

	function HDH_TRACKER.UpdateSetting(trackerId)
		if trackerId and DB:HasUI(trackerId) then
			local t = HDH_TRACKER.Get(trackerId)
			if t then
				t:UpdateSetting()
				t:UpdateIcons()
			end
		else
			for k, t in pairs(HDH_TRACKER.GetList()) do
				if not DB:HasUI(k) then
					t:UpdateSetting()
					t:UpdateIcons()
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
end -- TRACKER Static function 
------------------------------------------


------------------------------------------
do -- TRACKER instance function
------------------------------------------

    function HDH_TRACKER:Init(...)
		
    end

	function HDH_TRACKER:GetClassName()
		return self.className
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
end -- TRACKER interface function
------------------------------------------


------------------------------------------
-- TRACKER Event
------------------------------------------

local function VersionUpdateDB()
	if DB:GetVersion() == 2.0 then
		local id, name, type, unit, aura_filter, aura_caster, transit
		for _, id in ipairs(DB:GetTrackerIds()) do
			id, name, type, unit, aura_filter, aura_caster, transit = DB:GetTrackerInfo(id)
			print(id, name, type, unit, aura_filter, aura_caster)
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
end

local function PLAYER_ENTERING_WORLD()
	if not HDH_TRACKER.IsLoaded then 
		print('|cffffff00HDH - AuraTracking |cffffffff(Setting: /at, /auratracking, /ㅁㅅ)')
		HDH_TRACKER.startTime = GetTime();
		HDH_AT_ADDON_FRAME:RegisterEvent('VARIABLES_LOADED')
		HDH_AT_ADDON_FRAME:RegisterEvent('PLAYER_REGEN_DISABLED')
		HDH_AT_ADDON_FRAME:RegisterEvent('PLAYER_REGEN_ENABLED')
		HDH_AT_ADDON_FRAME:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
		HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_TREE_CHANGED') -- 특성 빌드 설정 업데이트 하려고 할때 
		HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_CONFIG_UPDATED') -- 특성 빌드 설정 변경 완료 됐을때
		HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_CONFIG_DELETED') -- 특성 빌드 설정 변경 완료 됐을때
		-- HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_CONFIG_CREATED') -- 특성 빌드 설정 변경 완료 됐을때
		
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
	-- print( event, ...)
	if event =='ACTIVE_TALENT_GROUP_CHANGED' then
		-- HDH_AT_UTIL.IsTalentSpell(nil,nil,true);
		HDH_TRACKER.InitVaribles()
		HDH_TRACKER.Update()

		if HDH_AT_ConfigFrame and HDH_AT_ConfigFrame:IsShown() then 
			HDH_AT_ConfigFrame:UpdateFrame()
		end
		-- HDH_cashTalentSpell = nil
	
	elseif event == 'PLAYER_REGEN_ENABLED' then	
		if not HDH_TRACKER.ENABLE_MOVE then
			HDH_TRACKER.Update()
		end
	
	elseif event == 'PLAYER_REGEN_DISABLED' then
		if not HDH_TRACKER.ENABLE_MOVE then
			HDH_TRACKER.Update()
		end
	
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- self:UnregisterEvent('PLAYER_ENTERING_WORLD')
		PLAY_SOUND = false
		C_Timer.After(3, PLAYER_ENTERING_WORLD)
		C_Timer.After(6, function() PLAY_SOUND = true end)
	elseif event =="GET_ITEM_INFO_RECEIVED" then
	elseif event == "TRAIT_CONFIG_UPDATED" then
		HDH_TRACKER.InitVaribles()
		HDH_TRACKER.Update()
		if HDH_AT_ConfigFrame:IsShown() then
			HDH_AT_ConfigFrame:UpdateFrame()
		end
	elseif event == "TRAIT_CONFIG_DELETED" then
		DB:CheckTransitDB()
		HDH_TRACKER.InitVaribles()
		if HDH_AT_ConfigFrame:IsShown() then
			HDH_AT_ConfigFrame:UpdateFrame()
		end
	elseif event == "TRAIT_CONFIG_CREATED" then -- 현재 사용 안함
		HDH_TRACKER.InitVaribles()
		if HDH_AT_ConfigFrame:IsShown() then
			HDH_AT_ConfigFrame:UpdateFrame()
		end
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
