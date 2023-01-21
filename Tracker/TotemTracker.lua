local DB = HDH_AT_ConfigDB
HDH_TT_TRACKER = {}

local AdjustName= {}
------------------------------------
-- HDH_T_TRACKER class
------------------------------------
do 
	setmetatable(HDH_TT_TRACKER, HDH_AURA_TRACKER) -- 상속
	HDH_TT_TRACKER.__index = HDH_TT_TRACKER
	HDH_TT_TRACKER.className = "HDH_TT_TRACKER"
	HDH_TRACKER.TYPE.TOTEM = 4
	HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.TOTEM, HDH_TT_TRACKER)
	local super = HDH_AURA_TRACKER
	
	function HDH_TT_TRACKER:Update(...) -- HDH_TRACKER override
		if not self.frame or HDH_TRACKER.ENABLE_MOVE then return end
		local haveTotem, name, startTime, duration, icon, endTime
		local slot = ... or MAX_TOTEMS
		local ui = self.ui
		local f
		local ret = 1;
		if not self.frame.pointer or not ui then return end
		if ( slot <= MAX_TOTEMS ) then
			for i =1, MAX_TOTEMS do
				haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
				--option = self.frame.TotemPointer and self.frame.TotemPointer[name] or nil
				if haveTotem then
					if self.aura_filter == DB.AURA_FILTER_ALL then
						f = self.frame.icon[ret];
						f.spell = {};
						f.spell.icon = icon;
						f.icon:SetTexture(icon);
						f.iconSatCooldown:SetTexture(icon)
						f.no = i;
						ret = ret +1;
					else
						if AdjustName[name] then
							name = AdjustName[name]
						end
						f = self.frame.pointer[name];
					end
					if f and f.spell then
						f.spell.duration = duration
						f.spell.count = 0
						f.spell.overlay = 0
						f.spell.startTime = startTime
						f.spell.isUpdate = true
						f.spell.name = name
						endTime = startTime + duration;
						f.spell.remaining = endTime-GetTime();
						if f.spell.endTime ~= endTime then
							f.spell.endTime = endTime;
							f.spell.happenTime = GetTime();
						end
						f.spell.slot = i;
						f.spell.isUpdate = true;
					end
				end
			end
		end
		if (self:UpdateIcons() > 0) or self.ui.common.always_show or UnitAffectingCombat("player") then
			self:ShowTracker();
		else
			self:HideTracker();
		end
	end

	
	function HDH_TT_TRACKER:InitIcons() -- HDH_TRACKER override
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
		self.frame.pointer = {}

		if aura_filter == DB.AURA_FILTER_ALL then
			if #(self.frame.icon) > 0 then self:ReleaseIcons() end
		else
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

				self.frame.pointer[spell.name] = f;
			end
			for i = #(self.frame.icon) , iconIdx+1, -1  do
				self:ReleaseIcon(i)
			end
		end
		self:LoadOrderFunc();
		
		if #(self.frame.icon) > 0 or aura_filter == DB.AURA_FILTER_ALL then
			self.frame:SetScript("OnEvent", HDH_TT_OnEvent)
			self.frame:RegisterEvent("PLAYER_TOTEM_UPDATE");
			--self.frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
		else
			self.frame:UnregisterAllEvents()
		end
		self:Update()
	end
	
end


-----------------------------------------------------------------------------
-- icon 정보 업데이트 
-----------------------------------------------------------------------------

function HDH_TT_OnEvent(self, event, ...)
	if not self.parent then return end
	local tracker = self.parent
	
	if event == "PLAYER_TOTEM_UPDATE" then 
		if not HDH_TRACKER.ENABLE_MOVE then
			tracker:Update(...)
		end
	elseif event == "UPDATE_SHAPESHIFT_FORM" then
	
	end
end

-------------------------------------------
-------------------------------------------