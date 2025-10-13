HDH_HEALTH_TRACKER = {}

local DB = HDH_AT_ConfigDB

local HEALTH_TEXTURE = "Interface/Icons/Ability_Malkorok_BlightofYshaarj_Green"

if HDH_AT.LE == HDH_AT.LE_CLASSIC then
	HEALTH_TEXTURE = "Interface/Icons/Spell_Holy_Renew"
end

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
	POWER_INFO[HDH_TRACKER.TYPE.HEALTH] = {power_type="HEALTH", power_index=HDH_TRACKER.TYPE.HEALTH, color={0, 1, 0}, regen=true, texture = HEALTH_TEXTURE};

	HDH_HEALTH_TRACKER.POWER_INFO = POWER_INFO;

	local function OnUpdateAbsorbBarValue(f, elapsed)
		if f.bar and f.bar.absorb_f and elapsed then
			if (f.absorbsGlowPoint or 0) % 1 == 0 then
				f.incrValue = not f.incrValue
			end
			if f.incrValue then
				f.absorbsGlowPoint = math.max((f.absorbsGlowPoint or 0) - elapsed * 2, 0)
			else
				f.absorbsGlowPoint = math.min((f.absorbsGlowPoint or 0) + elapsed * 2, 1)
			end
			f.bar.absorb_f.texture:SetVertexColor(1, 1, 1, f.absorbsGlowPoint * 0.4 + 0.6);
		end

		f.absorbs_value = f:GetParent().parent:GetAbsorbs()
		if f.absorbs_value ~= f.prev_absorbs_value or f.absorbs_value > 0 then
			f:GetParent().parent:UpdateAbsorb(f, f.absorbs_value)
			f.prev_absorbs_value = f.absorbs_value
		end
	end
	
	function HDH_HEALTH_TRACKER:GetPower()
		return UnitHealth(self.unit) or 0;
	end

	function HDH_HEALTH_TRACKER:GetPowerMax()
		return UnitHealthMax(self.unit);
	end

	function HDH_HEALTH_TRACKER:GetAbsorbs()
		if UnitGetTotalAbsorbs then
			return UnitGetTotalAbsorbs(self.unit) or 0 
		else
			return 0
		end
	end

	function HDH_HEALTH_TRACKER:UpdateBarSettings(f)
		super.UpdateBarSettings(self, f)

		if f.bar and not f.bar.absorb_f then
			local healthBar = f.bar
			local absorb_f = CreateFrame("Frame", nil, healthBar);
			-- absorb_f:SetFrameLevel(10)
			local absorb = absorb_f:CreateTexture(nil, "OVERLAY"); 
			absorb:SetTexture([[Interface\RaidFrame\Shield-Fill.blp]]);
			-- absorb:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/normTex");
			absorb:SetVertexColor(1, 1, 1, 0.4);
			absorb:SetPoint("TOPLEFT", absorb_f, "TOPLEFT", 0, 0);
			absorb:SetPoint("BOTTOMRIGHT", absorb_f, "BOTTOMRIGHT", 0, 0);
			absorb:SetBlendMode("ADD")

			local overlay = absorb_f:CreateTexture(nil, "OVERLAY", nil, 7); 
			overlay:SetTexture("Interface/RaidFrame/Shield-Overlay", true, true);
			overlay:SetVertTile(true) 
			overlay:SetHorizTile(true)
			overlay:SetPoint("TOPLEFT", absorb_f, "TOPLEFT", 1, -1);
			overlay:SetPoint("BOTTOMRIGHT", absorb_f, "BOTTOMRIGHT", -1, 1);
			overlay:SetAlpha(1)
			overlay:SetVertexColor(1,1,1)

			f.bar.absorb_f = absorb_f
			f.bar.absorb_f.texture = absorb
		end
	end

	local s2 = math.sqrt(2);
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
	
	-- 자동으로 붙는 형식으로 하자
	function HDH_HEALTH_TRACKER:UpdateAbsorb(f, value)
		if f.bar == nil then return end
		local healthBar = f.bar
		local absorb_f = f.bar.absorb_f;
		local h_max = self:GetPowerMax()
		local h_value = healthBar:GetValue()
		local ui = DB:GetTrackerUI(self.id)
		value = math.min(value, h_max)
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
				if ui.bar.cooldown_progress == DB.COOLDOWN_LEFT or ui.bar.cooldown_progress == DB.COOLDOWN_RIGHT then
					if absorb_f.texture.rotate ~= 0 then
						RotateTexture(absorb_f.texture, 0);
						absorb_f.texture.rotate = 0
					end
					absorb_f:SetSize(math.min((value/h_max), 1) * healthBar:GetWidth(), healthBar:GetHeight());
				else
					if absorb_f.texture.rotate ~= 90 then
						RotateTexture(absorb_f.texture, 90)
						absorb_f.texture.rotate = 90
					end
					absorb_f:SetSize(healthBar:GetWidth(), math.min((value/h_max), 1) * healthBar:GetHeight());
				end
			end
		end
	end

	-- 항상 보호막이 있는 애가 있는지 확인 후 활성할 할것
	-- function HDH_HEALTH_TRACKER:UpdateSpellInfo(index) -- HDH_TRACKER override
	-- 	super.UpdateSpellInfo(self, index)
	-- 	if self:GetAbsorbs()  > 0 then
	-- 		self.frame.icon[1].spell.isUpdate = true
	-- 	end
	-- end
	
    -- UNIT_ABSORB_AMOUNT_CHANGED
	-- UNIT_HEALTH
	function HDH_HEALTH_TRACKER:InitIcons() -- HDH_TRACKER override
		local ret = super.InitIcons(self)
		if ret and self.frame then
			self.frame:UnregisterAllEvents()
			if self.frame.icon and self.frame.icon[1] then
				self.frame.icon[1]:HookScript('OnUpdate', function(f, elapsed)
					OnUpdateAbsorbBarValue(f, elapsed)
				end)
				if HDH_AT.LE >= HDH_AT.LE_MISTS then
					self.frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
				end
				self.frame:RegisterUnitEvent("UNIT_HEALTH", self.unit)
			else
				self.frame.icon[1]:HookScript('OnUpdate', nil)
			end
		end
	end
	
	function HDH_HEALTH_TRACKER:OnEvent(event, unit, powerType)
		local self = self.parent
		if not self then return end
		if (event == 'UNIT_ABSORB_AMOUNT_CHANGED') or (event == 'UNIT_HEALTH') then  -- (event == "UNIT_POWER")
			self:Update()
		end
	end
------------------------------------
end -- HDH_HEALTH_TRACKER class
------------------------------------