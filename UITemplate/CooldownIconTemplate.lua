local DB = HDH_AT_ConfigDB

-----------------------------------------------
--- HDH_AT_CircleCooldownTemplateMixin
-----------------------------------------------
HDH_AT_CircleCooldownTemplateMixin = {}

function HDH_AT_CircleCooldownTemplate_OnShow(self)
	self = self:GetParent()
	if self.toFill then
		self.Icon:SetAlpha(self.onAlpha)
		self.Icon:SetDesaturated(nil)
	else
		self.Icon:SetAlpha(self.offAlpha)
		self.Icon:SetDesaturated(true)
	end
end

function HDH_AT_CircleCooldownTemplate_OnHide(self)
	self = self:GetParent()
	if self.toFill then
		self.Icon:SetAlpha(self.offAlpha)
		self.Icon:SetDesaturated(true)
	else
		self.Icon:SetAlpha(self.onAlpha)
		self.Icon:SetDesaturated(nil)
	end
end

-- toFill은 컬러 아이콘이 더 잘보이는 쪽으로 컬러가 채워지는 관점으로 의미로 사용 (swipColor 관점이 아님)
function HDH_AT_CircleCooldownTemplateMixin:Setup(cooldownType, toFill, color, onAlpha, offAlpha)
	if cooldownType == DB.COOLDOWN_CIRCLE then
		self.Cooldown:Show()
		self.Charge:Show()
		self.Cooldown:SetReverse(toFill)
		self.Charge:SetReverse(toFill)
		self.Charge:SetDrawEdge(true)
		self.Cooldown:SetDrawSwipe(true)
		self.Cooldown:SetSwipeColor(unpack(color))
		self.Cooldown:SetSwipeTexture("Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg")
		self.Cooldown:SetScript('OnHide', HDH_AT_CircleCooldownTemplate_OnHide)
		self.Cooldown:SetScript('OnShow', HDH_AT_CircleCooldownTemplate_OnShow)
	else
		self.Charge:SetDrawEdge(false)
		self.Cooldown:SetDrawSwipe(false)
	end
	self.onAlpha = onAlpha
	self.offAlpha = offAlpha
	self.toFill = toFill
end

function HDH_AT_CircleCooldownTemplateMixin:SetIcon(texture)
	self.Icon:SetTexture(texture)
end

function HDH_AT_CircleCooldownTemplateMixin:SetCooldown(startValue, duration, isTimer, isCharging)
	if isCharging then
		if isTimer then
			self.Charge:Clear()
			self.Charge:SetCooldown(startValue, duration)
			-- self:SetScript('OnHide', HDH_AT_CircleCooldownTemplate_OnUpdateLinearCooldown)
		else
			self.Charge:Pause()
		end
	else
		if isTimer then
			self.Cooldown:Clear()
			self.Cooldown:SetCooldown(startValue, duration)
		else
			self.Cooldown:Pause()
		end
		self.startValue = startValue
		self.duration = duration
	end
	self.isTimer = isTimer
	self.isCharging = isCharging
end

function HDH_AT_CircleCooldownTemplateMixin:SetValue(value)
	if self.isTimer then return end

	self.per = (value - self.startValue) / self.duration
	self.per = math.max(math.min(1, self.per), 0)
	self.Cooldown:SetCooldown(GetTime() - (100 * self.per), 100)
	if self.per < 1 then
		if not self.Cooldown:IsShown() then
			self.Cooldown:Show()
		end
	else
		if self.Cooldown:IsShown() then
			self.Cooldown:Hide()
		end
	end
end

function HDH_AT_CircleCooldownTemplateMixin:SetCharge(startValue, duration, isTimer)
	self:SetCooldown(startValue, duration, isTimer, true)
end

-----------------------------------------------
--- HDH_AT_LinearCooldownTemplateMixin
-----------------------------------------------
HDH_AT_LinearCooldownTemplateMixin = {}

function HDH_AT_LinearCooldownTemplate_OnUpdateLinearCooldown(self, elapsed)
	if not self.isTimer then return end
	self.delay = self.delay or GetTime()
	if GetTime() - self.delay < 0.03 then return end
	self.delay = nil
	self:SetValue(GetTime())
end

function HDH_AT_LinearCooldownTemplate_OnSizeChanged(self)
	local w, h = self:GetSize()
	local size = math.max(w, h)
	self.Progress.Icon:SetSize(size, size)
end

function HDH_AT_LinearCooldownTemplateMixin:SetIcon(texture)
	self.Progress.Icon:SetTexture(texture)
	self.Icon:SetTexture(texture)
end

function HDH_AT_LinearCooldownTemplateMixin:Setup(cooldownType, toFill, enableSpark, color, onAlpha, offAlpha)
	local w, h = self:GetSize()
	local spark_size = self:GetWidth()
	self.toFill = toFill
	self.enableSpark = enableSpark
	self.onAlpha = onAlpha
	self.offAlpha = offAlpha
	if not toFill then 
		if cooldownType == DB.COOLDOWN_UP then
			cooldownType = DB.COOLDOWN_DOWN
		elseif cooldownType == DB.COOLDOWN_DOWN then
			cooldownType = DB.COOLDOWN_UP
		elseif cooldownType == DB.COOLDOWN_LEFT then
			cooldownType = DB.COOLDOWN_RIGHT
		elseif cooldownType == DB.COOLDOWN_RIGHT then
			cooldownType = DB.COOLDOWN_LEFT
		end
	end

	self.Progress.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	self.Progress.Icon:SetAlpha(onAlpha)
	self.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	self.Icon:SetAlpha(offAlpha)

	if cooldownType == DB.COOLDOWN_UP then
		self.Progress:ClearAllPoints()
		self.Progress:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		self.Progress:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		self.Progress:SetHeight(spark_size)
		self.Progress.Icon:ClearAllPoints()
		self.Progress.Icon:SetPoint("BOTTOM")

		if enableSpark then
			self.Spark:SetSize(spark_size, 7)
			self.Spark:SetPoint("CENTER", self.Progress, "TOP", 0, 0)
			self.Spark.Texture:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v")
			self.Spark.Texture:SetVertexColor(unpack(color or {1,1,1,1}))
		end

		self.UpdateFunc = function(self, per)
			self.Progress:SetHeight(math.floor(self:GetHeight() * per))
		end
		
	elseif cooldownType == DB.COOLDOWN_DOWN then
		self.Progress:ClearAllPoints()
		self.Progress:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
		self.Progress:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		self.Progress:SetHeight(spark_size)
		self.Progress.Icon:ClearAllPoints()
		self.Progress.Icon:SetPoint("TOP")

		if enableSpark then
			self.Spark:SetSize(spark_size, 7)
			self.Spark:SetPoint("CENTER", self.Progress, "BOTTOM", 0, 0)
			self.Spark.Texture:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v")
			self.Spark.Texture:SetVertexColor(unpack(color or {1,1,1,1}))
		end

		self.UpdateFunc = function(self, per)
			self.Progress:SetHeight(self:GetHeight() * per)
		end

	elseif cooldownType == DB.COOLDOWN_LEFT then
		self.Progress:ClearAllPoints()
		self.Progress:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
		self.Progress:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		self.Progress:SetWidth(spark_size)
		self.Progress.Icon:ClearAllPoints()
		self.Progress.Icon:SetPoint("LEFT")

		if enableSpark then
			self.Spark:SetSize(7, spark_size)
			self.Spark:SetPoint("CENTER", self.Progress, "RIGHT", 0, 0)
			self.Spark.Texture:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark")
			self.Spark.Texture:SetVertexColor(unpack(color or {1,1,1,1}))
		end

		self.UpdateFunc = function(self, per)
			self.Progress:SetWidth(math.floor(self:GetWidth() * per))
		end

	elseif cooldownType == DB.COOLDOWN_RIGHT then
		self.Progress:ClearAllPoints()
		self.Progress:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		self.Progress:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		self.Progress:SetHeight(spark_size)
		self.Progress.Icon:ClearAllPoints()
		self.Progress.Icon:SetPoint("RIGHT")

		if enableSpark then
			self.Spark:SetSize(7, spark_size)
			self.Spark:SetPoint("CENTER", self.Progress,"LEFT",0,0)
			self.Spark.Texture:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark")
			self.Spark.Texture:SetVertexColor(unpack(color or {1,1,1,1}))
		end

		self.UpdateFunc = function(self, per)
			self.Progress:SetWidth(self:GetWidth() * per)
		end
	end

	if not enableSpark then
		self.Spark:Hide()
	end
end

function HDH_AT_LinearCooldownTemplateMixin:SetCooldown(startValue, duration, isTimer, isCharging)
	self.startValue = startValue
	self.duration = duration
	self.isTimer = isTimer
	self.isCharging = isCharging or false
	self.Icon:SetDesaturated(not self.isCharging)
	self.Icon:SetAlpha(self.isCharging and self.onAlpha or self.offAlpha)
	self:SetScript('OnUpdate', isTimer and HDH_AT_LinearCooldownTemplate_OnUpdateLinearCooldown or nil)
end

function HDH_AT_LinearCooldownTemplateMixin:SetCharge(startValue, duration, isTimer)
	self:SetCooldown(startValue, duration, isTimer, true)
end

function HDH_AT_LinearCooldownTemplateMixin:SetValue(value)
	if self.toFill then
		self.per = (value - self.startValue) / self.duration
		self.per = math.max(math.min(1, self.per), 0)
		if self.isTimer and self.per == 1 then 
			self:SetScript('OnUpdate', nil)
		end	
	else
		self.per = 1 - ((value - self.startValue) / self.duration)
		self.per = math.max(math.min(1, self.per), 0)
		if self.isTimer and self.per == 0 then 
			self:SetScript('OnUpdate', nil)
		end
	end
	
	if self.per == 0 then
		if self.Progress:IsShown() then self.Progress:Hide() end
	else
		if not self.Progress:IsShown() then self.Progress:Show() end
		self.UpdateFunc(self, self.per)
	end
	if self.enableSpark then
		if self.per == 0 or self.per == 1 then
			self.Spark:Hide()
		else
			self.Spark:Show()
		end
	end
end

-----------------------------------------------
--- HDH_AT_LinearCooldownTemplateMixin
-----------------------------------------------
HDH_AT_CooldownIconTemplateMixin = {}


local ICON_BORDER_VALUE = {0.120, 0.15, 0.18, 0.21, 0.24, 0.27, 0.30, 0.33, 0.36, 0.39}
local ICON_SIZE_VALUE =   {0.075, 0.10, 0.14, 0.21, 0.23, 0.30, 0.34, 0.37, 0.40, 0.42}

function HDH_AT_CooldownIconTemplate_OnUpdateLinearCooldown(elapsed)
	-- if (f.iconSatCooldown.curSize ~= f.iconSatCooldown.preSize) then
	-- 	f.tex = 0.86 * per
	-- 	if (f.iconSatCooldown.curSize == 0) then f.iconSatCooldown:Hide() end
	-- 	if direction == DB.COOLDOWN_LEFT then
	-- 		f.spell.texcoord = 0.07 + (f.tex)
	-- 		f.iconSatCooldown:SetWidth(f.iconSatCooldown.curSize)
	-- 		f.iconSatCooldown:SetTexCoord(0.07, f.spell.texcoord, 0.07, 0.93)
	-- 	elseif direction == DB.COOLDOWN_RIGHT then
	-- 		f.spell.texcoord = (0.93 - f.tex)
	-- 		f.iconSatCooldown:SetWidth(f.iconSatCooldown.curSize)
	-- 		f.iconSatCooldown:SetTexCoord(f.spell.texcoord, 0.93, 0.07, 0.93)
	-- 	elseif direction == DB.COOLDOWN_UP then
	-- 		f.spell.texcoord = (0.07 + f.tex)
	-- 		f.iconSatCooldown:SetHeight(f.iconSatCooldown.curSize)
	-- 		f.iconSatCooldown:SetTexCoord(0.07, 0.93, 0.07, f.spell.texcoord)
	-- 	else
	-- 		f.spell.texcoord = (0.93 - f.tex)
	-- 		f.iconSatCooldown:SetHeight(f.iconSatCooldown.curSize)
	-- 		f.iconSatCooldown:SetTexCoord(0.07, 0.93, f.spell.texcoord, 0.93)
	-- 	end
	-- 	f.iconSatCooldown.preSize = f.iconSatCooldown.curSize
	-- end
end

function HDH_AT_CooldownIconTemplate_OnSizeChanged(self)
	self:SetBorderSize(self.borderSize)
end

function HDH_AT_CooldownIconTemplateMixin:Setup()

end

function HDH_AT_CooldownIconTemplateMixin:SetBorderSize(borderSize)
	local border = 0.2355 * (1 - (ICON_BORDER_VALUE[borderSize] or 0))
	local size = 1 - (0.455 * (ICON_SIZE_VALUE[borderSize] or 0))

	self.Border:SetTexCoord(border, 1 - border, border, 1 - border)
	self.Icon:SetSize(self:GetWidth() * size, self:GetHeight() * size)
	self.borderSize = borderSize
end

function HDH_AT_CooldownIconTemplateMixin:SetBorderColor(r, g, b, a)
	self.Border:SetVertexColor(r, g, b, a)
end

function HDH_AT_CooldownIconTemplateMixin:SetCooldownType(cooldownType, reverse, enableSpark, color)
	local spark_size = self:GetWidth()

	if cooldownType == DB.COOLDOWN_UP then
		self.CircleCooldown:Hide()
		self.LinearCooldown:Show()

		self.LinearCooldown:ClearAllPoints()
		self.LinearCooldown:SetPoint("TOPLEFT", self.Icon, "TOPLEFT", 0, 0)
		self.LinearCooldown:SetPoint("TOPRIGHT", self.Icon, "TOPRIGHT", 0, 0)
		self.LinearCooldown:SetHeight(spark_size)

		if enableSpark then
			self.LinearCooldown.Spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v")
			self.LinearCooldown.Spark:SetSize(spark_size, 7)
			self.LinearCooldown.spark:SetPoint("CENTER", self.LinearCooldown, "BOTTOM", 0, 0)
			self.LinearCooldown.spark:SetVertexColor(unpack(color or {1,1,1,1}))
		end

	elseif cooldownType == DB.COOLDOWN_DOWN then
		self.CircleCooldown:Hide()
		self.LinearCooldown:Show()

		self.LinearCooldown:ClearAllPoints()
		self.LinearCooldown:SetPoint("BOTTOMLEFT", self.Icon, "BOTTOMLEFT", 0, 0)
		self.LinearCooldown:SetPoint("BOTTOMRIGHT", self.Icon, "BOTTOMRIGHT", 0, 0)
		self.LinearCooldown:SetHeight(spark_size)

		if enableSpark then
			self.LinearCooldown.Spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v")
			self.LinearCooldown.Spark:SetSize(spark_size, 7)
			self.LinearCooldown.spark:SetPoint("CENTER", self.LinearCooldown, "TOP", 0, 0)
			self.LinearCooldown.spark:SetVertexColor(unpack(color or {1,1,1,1}))
		end

	elseif cooldownType == DB.COOLDOWN_LEFT then
		self.CircleCooldown:Hide()
		self.LinearCooldown:Show()

		self.LinearCooldown:ClearAllPoints()
		self.LinearCooldown:SetPoint("TOPLEFT", self.Icon, "TOPLEFT", 0, 0)
		self.LinearCooldown:SetPoint("BOTTOMLEFT", self.Icon, "BOTTOMLEFT", 0, 0)
		self.LinearCooldown:SetWidth(spark_size)

		if enableSpark then
			self.LinearCooldown.Spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark")
			self.LinearCooldown.Spark:SetSize(7, spark_size)
			self.LinearCooldown.spark:SetPoint("CENTER", self.LinearCooldown, "RIGHT", 0, 0)
			self.LinearCooldown.spark:SetVertexColor(unpack(color or {1,1,1,1}))
		end

	elseif cooldownType == DB.COOLDOWN_RIGHT then
		self.CircleCooldown:Hide()
		self.LinearCooldown:Show()

		self.LinearCooldown:ClearAllPoints()
		self.LinearCooldown:SetPoint("TOPRIGHT", self.Icon, "TOPRIGHT", 0, 0)
		self.LinearCooldown:SetPoint("BOTTOMRIGHT", self.Icon, "BOTTOMRIGHT", 0, 0)
		self.LinearCooldown:SetHeight(spark_size)

		if enableSpark then
			self.LinearCooldown.Spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark")
			self.LinearCooldown.Spark:SetSize(7, spark_size)
			self.LinearCooldown.spark:SetPoint("CENTER", self.LinearCooldown,"LEFT",0,0)
			self.LinearCooldown.spark:SetVertexColor(unpack(color or {1,1,1,1}))
		end

	elseif cooldownType == DB.COOLDOWN_CIRCLE then
		self.CircleCooldown:Show()
		self.LinearCooldown:Hide()

		self.CircleCooldown:SetSwipeColor(unpack(color))

	else -- cooldownType == DB.COOLDOWN_NONE
		self.CircleCooldown:Hide()
		self.LinearCooldown:Hide()
	end
end

function HDH_AT_CooldownIconTemplateMixin:SetIcon(texture)
	self.Icon:SetTexture(texture)
	self.LinearCooldown:SetTexture(texture)
end

function HDH_AT_CooldownIconTemplateMixin:SetGlowType(t, color, tickPerSec)

end

function HDH_AT_CooldownIconTemplateMixin:SetGlow(bool)

end

function HDH_AT_CooldownIconTemplateMixin:SetAlpha(satAlpha, desatAlpha)

end

function HDH_AT_CooldownIconTemplateMixin:SetChargeMinMaxValues(startV, endV, isTimer)

end

function HDH_AT_CooldownIconTemplateMixin:SetMinMaxValues(startV, endV, isTimer)

end

function HDH_AT_CooldownIconTemplateMixin:SetValue(value)

end

function HDH_AT_CooldownIconTemplateMixin:SetChargeValue(value)

end