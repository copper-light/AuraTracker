-- ##### 현재 사용하지 않는 트래커

CT_VERSION = 0.1
HDH_HEALTH_TRACKER = {}

local DB = HDH_AT_ConfigDB

local POWRE_BAR_SPLIT_MARGIN = 4;
local MyClassKor, MyClass = UnitClass("player");

-- local POWRE_NAME = {}

------------------------------------
do -- HDH_HEALTH_TRACKER class
------------------------------------
	local super = HDH_POWER_TRACKER;
	setmetatable(HDH_HEALTH_TRACKER, super) -- 상속
	HDH_HEALTH_TRACKER.__index = HDH_HEALTH_TRACKER
	HDH_HEALTH_TRACKER.className = "HDH_HEALTH_TRACKER"
	
	HDH_TRACKER.TYPE.HEALTH = 99
	HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.HEALTH,      HDH_HEALTH_TRACKER)

	local POWER_INFO = {}
	POWER_INFO[HDH_TRACKER.TYPE.HEALTH] = {power_type="HEALTH", power_index=HDH_TRACKER.TYPE.HEALTH, color={0, 1, 0}, regen=true, texture = "Interface/Icons/Ability_Malkorok_BlightofYshaarj_Green"};

	HDH_HEALTH_TRACKER.POWER_INFO = POWER_INFO;

	b = true
	a = 0
	function HDH_HEALTH_TRACKER:UpdateBarValue(f, elapsed, non_animate)
		super.UpdateBarValue(self, f, elapsed, non_animate)
		
		if f.bar and f.bar.absorb_f and elapsed then
			if a % 1 == 0 then
				b = not b
			end
			if b then
				a = max(a - elapsed*2, 0)
			else
				a = min(a + elapsed*2, 1)
			end
			f.bar.absorb_f.texture:SetVertexColor(1,1,1, 0.6 * a +0.4);
		end

		absorbs_value = UnitGetTotalAbsorbs('player') or 0;
		if f.absorbs_value ~= absorbs_value or absorbs_value > 0 then
			self:UpdateAbsorb(f, absorbs_value)
			f.absorbs_value = absorbs_value
		end
	end
			
	-- function HDH_HEALTH_TRACKER:CreateData(spec)
		
	-- end
	
	function HDH_HEALTH_TRACKER:GetPower()
		return UnitHealth("player") or 0;
	end

	function HDH_HEALTH_TRACKER:GetPowerMax()
		return UnitHealthMax("player");
	end


	function HDH_HEALTH_TRACKER:UpdateArtBar(f) 
		super.UpdateArtBar(self, f)

		if f.bar and not f.bar.absorb_f then
			local healthBar = f.bar.bar[1]
			local absorb_f = CreateFrame("StatusBar", nil, healthBar);
			local absorb = absorb_f:CreateTexture(nil, "OVERLAY"); 
			absorb:SetTexture([[Interface\RaidFrame\Shield-Fill.blp]]);
			-- absorb:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/normTex");
			absorb:SetVertexColor(1,1,1, 0.4);
			absorb:SetPoint("TOPLEFT", absorb_f, "TOPLEFT", 0, 0);
			absorb:SetPoint("BOTTOMRIGHT", absorb_f, "BOTTOMRIGHT", 0, 0);
			absorb:SetBlendMode("ADD");

			local overlay = absorb_f:CreateTexture(nil, "OVERLAY",nil, 7); 
			overlay:SetTexture("Interface/RaidFrame/Shield-Overlay",true,true);
			overlay:SetVertTile(true) 
			overlay:SetHorizTile(true)
			overlay:SetPoint("TOPLEFT", absorb_f, "TOPLEFT", 1, -1);
			overlay:SetPoint("BOTTOMRIGHT", absorb_f, "BOTTOMRIGHT", -1, 1);
			overlay:SetAlpha(1);

			f.bar.absorb_f = absorb_f
			f.bar.absorb_f.texture = absorb
		end
		

	end
	
	function HDH_HEALTH_TRACKER:ChangeCooldownType(f, cooldown_type) -- 호출되지 말라고 빈함수
	end
	
	local s2 = sqrt(2);
	local cos, sin, rad = math.cos, math.sin, math.rad;
	local function CalculateCorner(angle)
		local r = rad(angle);
		return 0.5 + cos(r) / s2, 0.5 + sin(r) / s2;
	end
	
	local function RotateTexture(texture, angle)
        local LRx, LRy = CalculateCorner(angle + 45);
        local LLx, LLy = CalculateCorner(angle + 135);
        local ULx, ULy = CalculateCorner(angle + 225);
        local URx, URy = CalculateCorner(angle - 45);
        
        texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
	end
	
	function HDH_HEALTH_TRACKER:UpdateAbsorb(f, value)
		if f.bar == nil then return end
		local healthBar = f.bar.bar[1];
		local absorb_f = f.bar.absorb_f;
		local h_max = self:GetPowerMax()
		local h_value = healthBar:GetValue()
		local ui = DB:GetTrackerUI(self.id)
		-- print((totalAbsorb/health_max) * self.bar:GetWidth())
		if absorb_f then
			if value == 0 then 
				if absorb_f:IsShown() then absorb_f:Hide() end
			else
				if not absorb_f:IsShown() then absorb_f:Show() end
				absorb_f:ClearAllPoints();
				if h_value + value > h_max then
					if ui.bar.cooldown_progress ==  DB.COOLDOWN_RIGHT then
						absorb_f:SetPoint("RIGHT", healthBar, "RIGHT", 0, 0);
					elseif ui.bar.cooldown_progress ==  DB.COOLDOWN_LEFT then
						absorb_f:SetPoint("LEFT", healthBar, "LEFT", 0, 0);
					elseif ui.bar.cooldown_progress ==  DB.COOLDOWN_UP then
						absorb_f:SetPoint("TOP", healthBar, "TOP", 0, 0);
					elseif ui.bar.cooldown_progress ==  DB.COOLDOWN_DOWN then
						absorb_f:SetPoint("BOTTOM", healthBar, "BOTTOM", 0, 0);
					end
				else
					if ui.bar.cooldown_progress ==  DB.COOLDOWN_RIGHT then
						absorb_f:SetPoint("LEFT", healthBar, "LEFT", healthBar:GetWidth() * (h_value/h_max), 0);
					elseif ui.bar.cooldown_progress ==  DB.COOLDOWN_LEFT then
						absorb_f:SetPoint("RIGHT", healthBar, "RIGHT", -healthBar:GetWidth() * (h_value/h_max), 0);
					elseif ui.bar.cooldown_progress ==  DB.COOLDOWN_UP then
						absorb_f:SetPoint("BOTTOM", healthBar, "BOTTOM", 0,  healthBar:GetHeight() * (h_value/h_max));
					elseif ui.bar.cooldown_progress ==  DB.COOLDOWN_DOWN then
						absorb_f:SetPoint("TOP", healthBar, "TOP", 0, -healthBar:GetHeight() * (h_value/h_max));
					end
				end
				if healthBar:GetOrientation() == "HORIZONTAL" then
					if absorb_f.texture.rotate ~= 0 then
						RotateTexture(absorb_f.texture,0);
						absorb_f.texture.rotate = 0
					end
					absorb_f:SetSize(min((value/h_max), 1) * healthBar:GetWidth(), healthBar:GetHeight());
				else
					if absorb_f.texture.rotate ~= 90 then
						RotateTexture(absorb_f.texture,90)
						absorb_f.texture.rotate = 90
					end
					absorb_f:SetSize(healthBar:GetWidth(), min((value/h_max), 1) * healthBar:GetHeight());
				end
			end
			
		end
	end
	
	function HDH_HEALTH_TRACKER:InitIcons() -- HDH_TRACKER override
		super.InitIcons(self)
		if self.frame then
			self.frame:SetScript("OnEvent", OnEventTracker)
			self.frame:UnregisterAllEvents()
		end
	end
	
	function HDH_HEALTH_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:InitIcons()
		-- self:UpdateBar(self.frame.icon[1]);
	end
	
	function HDH_HEALTH_TRACKER:PLAYER_ENTERING_WORLD()
	end
	
	function HDH_HEALTH_TRACKER:OnEvent(event, unit, powerType)
		if self == nil or self.parent == nil then return end
		if (event == 'UNIT_MAXHEALTH')then  -- (event == "UNIT_POWER")
		end
	end
------------------------------------
end -- HDH_HEALTH_TRACKER class
------------------------------------