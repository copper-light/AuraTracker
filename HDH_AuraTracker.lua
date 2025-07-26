local DB = HDH_AT_ConfigDB

-- 특성 변환에 대해서는 글로벌로 체크함
local function ACTIVE_TALENT_GROUP_CHANGED()
	HDH_TRACKER.InitVaribles()
	HDH_TRACKER.Updates()
	if HDH_AT_ConfigFrame and HDH_AT_ConfigFrame:IsShown() then 
		HDH_AT_ConfigFrame:UpdateFrame()
	end
end

-- 애드온 로드 시 가장 먼저 실행되는 함수
local function PLAYER_ENTERING_WORLD()
    DB:VersionUpdateDB()

	if not HDH_TRACKER.IsLoaded then 
		print('|cffffff00Loaded : AuraTracker |cffffffff(Settings: /at, /auratracker, /ㅁㅅ)')
		HDH_TRACKER.startTime = GetTime();
		HDH_AT_ADDON_FRAME:RegisterEvent('PLAYER_REGEN_DISABLED')  -- 전투 시작
		HDH_AT_ADDON_FRAME:RegisterEvent('PLAYER_REGEN_ENABLED')   -- 전투 종료
		HDH_AT_ADDON_FRAME:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')    -- 특성 빌드 변경 변환
		HDH_AT_ADDON_FRAME:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')  -- 전문화 변환
		HDH_AT_ADDON_FRAME:RegisterEvent('GROUP_ROSTER_UPDATE')  -- 파티 구성
		HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_CONFIG_UPDATED') -- 특성 빌드 설정 변경 완료 됐을때
		HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_CONFIG_DELETED') -- 특성 빌드 설정 변경 완료 됐을때
		HDH_AT_ADDON_FRAME:RegisterEvent('TRAIT_TREE_CURRENCY_INFO_UPDATED') -- 특성 빌드 설정 변경 완료 됐을때
	end

	HDH_TRACKER.InitVaribles()
	local trackerList = HDH_TRACKER.GetList()
	for _, t in pairs(trackerList) do
		t:PLAYER_ENTERING_WORLD()
        t.isRaiding = t:IsRaiding()
	end
	
    HDH_TRACKER.IsLoaded = true
end

-- 이벤트 콜백 함수
local function OnEvent(self, event, ...)
	if event =='ACTIVE_TALENT_GROUP_CHANGED' or (event =='PLAYER_SPECIALIZATION_CHANGED' and 'player' == select(1, ...)) then
		HDH_AT_UTIL.RunTimer(self, "ACTIVE_TALENT_GROUP_CHANGED", 1, ACTIVE_TALENT_GROUP_CHANGED)
        
	elseif event == 'PLAYER_REGEN_ENABLED' then	
		if not HDH_TRACKER.ENABLE_MOVE then
			HDH_TRACKER.Updates()
		end
	
	elseif event == 'PLAYER_REGEN_DISABLED' then
		if not HDH_TRACKER.ENABLE_MOVE then
			HDH_TRACKER.Updates()
		end

	elseif event == 'GROUP_ROSTER_UPDATE' then
		if not HDH_TRACKER.ENABLE_MOVE then
			HDH_TRACKER.Updates()
		end

	elseif event == "TRAIT_CONFIG_UPDATED" then
		HDH_AT_UTIL.RunTimer(self, "ACTIVE_TALENT_GROUP_CHANGED", 1, ACTIVE_TALENT_GROUP_CHANGED)

	elseif event == "TRAIT_CONFIG_DELETED" then
		DB:CheckTraitsDB()
		HDH_TRACKER.InitVaribles()
		if HDH_AT_ConfigFrame:IsShown() then
			HDH_AT_ConfigFrame:UpdateFrame()
		end

	elseif event == "PLAYER_ENTERING_WORLD" then
		C_Timer.After(3, PLAYER_ENTERING_WORLD)
    end
end

HDH_AT_ADDON_FRAME = CreateFrame("Frame", "HDH_AT_MainFrame", UIParent) -- 애드온 최상위 프레임
HDH_AT_ADDON_FRAME:SetScript("OnEvent", OnEvent)
HDH_AT_ADDON_FRAME:RegisterEvent('PLAYER_ENTERING_WORLD')
