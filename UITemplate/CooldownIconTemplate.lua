local DB = HDH_AT_ConfigDB

-----------------------------------------------
---HDH_AT_BaseCooldownTemplateMixin
-----------------------------------------------
HDH_AT_BaseCooldownTemplateMixin = {}

function HDH_AT_BaseCooldownTemplateMixin:SetTexture(texture)
	if self.Progress then
		self.Progress.Texture:SetTexture(texture)
		self.Overlay.Texture:SetTexture(texture)
	end
end

function HDH_AT_BaseCooldownTemplateMixin:SetHandler(startFunc, finishFunc, activedFunc)
	self.OnStartedFunc = startFunc
	self.OnFinishedFunc = finishFunc
	self.OnActivedFunc = activedFunc
end

-----------------------------------------------
--- HDH_AT_CircleCooldownTemplateMixin
-----------------------------------------------
HDH_AT_CircleCooldownTemplateMixin = {}

function HDH_AT_CircleCooldownTemplate_OnStarted(self)
	if self.OnStartedFunc then
		self.OnStartedFunc(self)
	end
	self.isRunning = true
end

function HDH_AT_CircleCooldownTemplate_OnFinished(self)
	if self.isRunning and self.OnFinishedFunc then
		self.OnFinishedFunc(self)
	end
	self.isRunning = false
end

function HDH_AT_CircleCooldownTemplateMixin:SetTexture(texture)
	self.Progress.Texture:SetTexture(texture)
	self.Overlay.Texture:SetTexture(texture)

	-- local w, h = self:GetSize()
	-- local size = math.max(w, h)
	-- self.Progress.Texture:SetSize(size, size)
end

function HDH_AT_CircleCooldownTemplateMixin:SetOverlayColor(r, g, b, a)
	if r ~= nil then
		self.Overlay.Texture:SetVertexColor(r, g, b, a)
		if not self.Overlay:IsShown() then
			self.Overlay:Show()
		end
		if self.Progress.Texture:IsShown() then
			self.Progress.Texture:SetShown(false)
		end
	else
		if self.Overlay:IsShown() then
			self.Overlay:Hide()
			self.Progress.Texture:SetShown(not self.toFill)
		end
	end
end

function HDH_AT_CircleCooldownTemplateMixin:SetShownProgressTexture(bool)
	if bool and not self.toFill then
		self.Progress.Texture:SetShown(bool)
	end
end

-- toFill은 컬러 아이콘이 더 잘보이는 쪽으로 컬러가 채워지는 관점으로 의미로 사용 (swipColor 관점이 아님)
function HDH_AT_CircleCooldownTemplateMixin:Setup(cooldownType, toFill, color, textureAlpha)
	self.Progress:Show()
	self.Charge:Show()
	self.Charge:SetDrawEdge(true)
	self.Progress:SetDrawSwipe(true)
	self.Progress:SetReverse(not toFill)
	self.Charge:SetReverse(not toFill)
	self.Progress:SetSwipeTexture("Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg")
	self.Progress:SetScript('OnHide', function(self) HDH_AT_CircleCooldownTemplate_OnFinished(self:GetParent()) end)
	self.Progress:SetScript('OnShow', function(self) HDH_AT_CircleCooldownTemplate_OnStarted(self:GetParent()) end)
	self.Progress.Texture:SetShown(not toFill)

	if cooldownType == DB.COOLDOWN_CIRCLE then
		self.Progress:SetSwipeColor(unpack(color))
	else
		self.Progress:SetSwipeColor(1,1,1,0)
	end

	self.isRunning = false
	self.textureAlpha = textureAlpha
	self.toFill = toFill
	self.Progress.Texture:SetAlpha(textureAlpha)
	self.cooldownType = cooldownType
	self.startValue = 0
	self.duration = 0
end

function HDH_AT_CircleCooldownTemplateMixin:SetCooldown(startValue, duration, isTimer, isCharging)
	-- if self.startValue == startValue and self.duration == duration then return end
	if isCharging then
		if isTimer then
			-- self.Charge:Clear()
			self.Charge:SetCooldown(startValue, duration)
		else
			self.Charge:Pause()
		end
		self.startValue = startValue
		self.duration = duration
	else
		if isTimer then
			-- self.Progress:Clear()
			self.Progress:SetCooldown(startValue, duration)
		else
			self.Progress:Pause()
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
	self.Progress:SetCooldown(GetTime() - (100 * self.per), 100)
	if self.per < 1 then
		if not self.Progress:IsShown() then
			self.Progress:Show()
		end
	else
		if self.Progress:IsShown() then
			self.Progress:Hide()
		end
	end
end

function HDH_AT_CircleCooldownTemplateMixin:Stop()
	if self.Progress:IsShown() then
		self.Progress:Clear()
		-- self.Progress:Hide()
	end
end


function HDH_AT_CircleCooldownTemplateMixin:Clear()
	self.startValue = nil
	self.duration = nil
	self.isTimer = nil
	self.per = nil
	self.prevPer = nil
	self.isCharging = nil
end

-----------------------------------------------
--- HDH_AT_LinearCooldownTemplateMixin
-----------------------------------------------
HDH_AT_LinearCooldownTemplateMixin = {}

function HDH_AT_LinearCooldownTemplate_OnStarted(self)
	self.isRunning = true
	if self.OnStartedFunc then
		self.OnStartedFunc(self)
	end
end

function HDH_AT_LinearCooldownTemplate_OnFinished(self)
	self.startValue = nil
	self.duration = nil
	if self.isRunning and self.OnFinishedFunc then
		self.OnFinishedFunc(self)
	end
	self.isRunning = false
end

function HDH_AT_LinearCooldownTemplate_OnUpdateLinearCooldown(self, elapsed)
	if not self.isTimer then return end
	-- self.delay = self.delay or GetTime()
	-- if GetTime() - self.delay < 0.001 then return end
	-- self.delay = nil

	self.skip = (self.skip or 0) + 1
	if self.skip % 2 ~= 0 and elapsed < 0.03 then return end
	self.skip = 0

	self:SetValue(GetTime())
end

function HDH_AT_LinearCooldownTemplate_OnSizeChanged(self)
	local w, h = self:GetSize()
	local size = math.max(w, h)
	self.Progress.Texture:SetSize(size, size)
end

function HDH_AT_LinearCooldownTemplateMixin:Setup(w, h, cooldownType, toFill, enableSpark, color, textureAlpha)
	self:SetSize(w, h)
	local spark_size = self:GetWidth()
	self.isRunning = false
	self.toFill = toFill
	self.enableSpark = enableSpark
	self.textureAlpha = textureAlpha
	if toFill then 
		if cooldownType == DB.COOLDOWN_UP then
			cooldownType = DB.COOLDOWN_DOWN
		elseif cooldownType == DB.COOLDOWN_DOWN then
			cooldownType = DB.COOLDOWN_UP
		elseif cooldownType == DB.COOLDOWN_LEFT then
			cooldownType = DB.COOLDOWN_RIGHT
		elseif cooldownType == DB.COOLDOWN_RIGHT then
			cooldownType = DB.COOLDOWN_LEFT
		end
	else
		
	end
	
	self.Progress.Texture:SetAlpha(textureAlpha)

	self.Spark:ClearAllPoints()
	if cooldownType == DB.COOLDOWN_UP then
		self.Progress:ClearAllPoints()
		self.Progress:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
		self.Progress:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		self.Progress:SetHeight(spark_size)
		self.Progress.Texture:ClearAllPoints()
		self.Progress.Texture:SetPoint("TOP")

		if enableSpark then
			self.Spark:SetHeight(7)
			self.Spark:SetPoint("LEFT", self.Progress, "BOTTOMLEFT", 0, 0)
			self.Spark:SetPoint("RIGHT", self.Progress, "BOTTOMRIGHT", 0, 0)
			self.Spark.Texture:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v")
			self.Spark.Texture:SetVertexColor(unpack(color or {1,1,1,1}))
		end

		self.UpdateFunc = function(self, per)
			self.Progress:SetHeight((self:GetHeight() * per))
			-- self.Progress.Texture:SetTexCoord(0.07, 0.93, 0.07 + (0.86 * per), 0.93)
		end

	elseif cooldownType == DB.COOLDOWN_DOWN then
		self.Progress:ClearAllPoints()
		self.Progress:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		self.Progress:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		self.Progress:SetHeight(spark_size)
		self.Progress.Texture:ClearAllPoints()
		self.Progress.Texture:SetPoint("BOTTOM")

		if enableSpark then
			self.Spark:SetHeight(7)
			self.Spark:SetPoint("LEFT", self.Progress, "TOPLEFT", 0, 0)
			self.Spark:SetPoint("RIGHT", self.Progress, "TOPRIGHT", 0, 0)
			self.Spark.Texture:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v")
			self.Spark.Texture:SetVertexColor(unpack(color or {1,1,1,1}))
		end

		self.UpdateFunc = function(self, per)
			self.Progress:SetHeight((self:GetHeight() * per))
			-- self.Progress.Texture:SetTexCoord(0.07, 0.93, 0.07 + (0.86 * per), 0.93)
		end

	elseif cooldownType == DB.COOLDOWN_LEFT then
		self.Progress:ClearAllPoints()
		self.Progress:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
		self.Progress:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		self.Progress:SetWidth(spark_size)
		self.Progress.Texture:ClearAllPoints()
		self.Progress.Texture:SetPoint("LEFT")

		if enableSpark then
			self.Spark:SetWidth(7)
			self.Spark:SetPoint("TOP", self.Progress, "TOPRIGHT", 0, 0)
			self.Spark:SetPoint("BOTTOM", self.Progress, "BOTTOMRIGHT", 0, 0)
			self.Spark.Texture:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark")
			self.Spark.Texture:SetVertexColor(unpack(color or {1,1,1,1}))
		end

		self.UpdateFunc = function(self, per)
			self.Progress:SetWidth((self:GetWidth() * per))
			-- self.Progress.Texture:SetTexCoord(0.07 + (0.86 * per), 0.93, 0.07 , 0.93)
		end

	elseif cooldownType == DB.COOLDOWN_RIGHT then
		self.Progress:ClearAllPoints()
		self.Progress:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		self.Progress:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		self.Progress:SetWidth(spark_size)
		self.Progress.Texture:ClearAllPoints()
		self.Progress.Texture:SetPoint("RIGHT")

		if enableSpark then
			self.Spark:SetWidth(7)
			self.Spark:SetPoint("TOP", self.Progress,"TOPLEFT",0,0)
			self.Spark:SetPoint("BOTTOM", self.Progress,"BOTTOMLEFT",0,0)
			self.Spark.Texture:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark")
			self.Spark.Texture:SetVertexColor(unpack(color or {1,1,1,1}))
		end

		self.UpdateFunc = function(self, per)
			self.Progress:SetWidth((self:GetWidth() * per))
			-- self.Progress.Texture:SetTexCoord(0.07 + (0.86 * per), 0.93, 0.07, 0.93)
		end
	end
	self.startValue = nil
	self.duration = nil
	self.isTimer = nil
	self.per = nil
	self.prevPer = nil
	-- self.Spark:SetShown(enableSpark)
end

function HDH_AT_LinearCooldownTemplateMixin:SetShownProgressTexture(bool)
	self.prevPer = nil
	self.Progress.Texture:SetShown(bool)
end

function HDH_AT_LinearCooldownTemplateMixin:SetOverlayColor(r, g, b, a)
	if r ~= nil then
		self.Overlay.Texture:SetVertexColor(r, g, b, a)
		if not self.Overlay:IsShown() then
			self.Overlay:Show()
		end
	else
		if self.Overlay:IsShown() then
			self.Overlay:Hide()
		end
	end
end

function HDH_AT_LinearCooldownTemplateMixin:SetCooldown(startValue, duration, isTimer, isCharging, isGlobal)
	if self.startValue == startValue and self.duration == duration then return end
	self.startValue = startValue
	self.duration = duration
	self.isTimer = isTimer
	self.isCharging = isCharging or false
	self.isGlobal = isGlobal or false
	if self.isTimer then
		HDH_AT_LinearCooldownTemplate_OnStarted(self)
		self:SetScript('OnUpdate', HDH_AT_LinearCooldownTemplate_OnUpdateLinearCooldown)
	else
		self:SetScript('OnUpdate', nil)
	end
	-- self.Progress:Show()
	-- self.Progress.Texture:Show()
	-- self.Progress.Text
end

function HDH_AT_LinearCooldownTemplateMixin:SetValue(value)
	if self.startValue == nil then return end 
	self.per = (value - self.startValue) / self.duration
	self.per = math.max(math.min(1, self.per), 0)
	if self.isTimer and self.per == 1 then
		self:SetScript('OnUpdate', nil)
	end	
	
	self.per = math.floor(self.per * 100 + 0.1) / 100
	if self.prevPer == self.per then return end
	-- print(GetTime(), self.per)
	if self.isTimer then
		if self.toFill then
			if self.per == 0 then
				if self.Progress:IsShown() then self.Progress:Hide() end
			elseif self.per < 1 then
				if not self.Progress:IsShown() then self.Progress:Show() end
				self.UpdateFunc(self, self.per)
			else
				if self.Progress:IsShown() then self.Progress:Hide() end
				HDH_AT_LinearCooldownTemplate_OnFinished(self)
			end
		else
			if self.per < 1 then
				if not self.Progress:IsShown() then self.Progress:Show() end
				self.UpdateFunc(self, 1 - self.per)
			else
				if self.Progress:IsShown() then self.Progress:Hide() end
				HDH_AT_LinearCooldownTemplate_OnFinished(self)
			end
		end
	else
		if self.toFill then
			if self.per == 0 then
				if self.Progress:IsShown() then self.Progress:Hide() end
			else
				if not self.Progress:IsShown() then self.Progress:Show() end
				self.UpdateFunc(self, self.per)
			end
		else
			if self.per < 1 then
				if not self.Progress:IsShown() then self.Progress:Show() end
				self.UpdateFunc(self, 1 - self.per)
			else
				if self.Progress:IsShown() then self.Progress:Hide() end
			end
		end
	end
	self.prevPer = self.per

	if self.enableSpark then
		if (self.per == 0 or self.per == 1) then
			if self.Spark:IsShown() then
				self.Spark:Hide()
			end
		elseif not self.Spark:IsShown() then
			self.Spark:Show()
		end
	end
end

function HDH_AT_LinearCooldownTemplateMixin:Stop()
	if self.Progress:IsShown() then
		self.Progress:Hide()
		-- HDH_AT_LinearCooldownTemplate_OnFinished(self)
	end

	if self.Spark:IsShown() then
		self.Spark:Hide()
	end

	self:SetScript('OnUpdate', nil)
end

function HDH_AT_LinearCooldownTemplateMixin:Clear()
	self.startValue = nil
	self.duration = nil
	self.isTimer = nil
	self.per = nil
	self.prevPer = nil
end

-----------------------------------------------
--- HDH_AT_LinearCooldownTemplateMixin
-----------------------------------------------
HDH_AT_CooldownIconTemplateMixin = {}


local ICON_BORDER_VALUE = {0.120, 0.15, 0.18, 0.21, 0.24, 0.27, 0.30, 0.33, 0.36, 0.39}
local ICON_SIZE_VALUE =   {0.075, 0.10, 0.14, 0.21, 0.23, 0.30, 0.34, 0.37, 0.40, 0.42}

function HDH_AT_CooldownIconTemplate_OnSizeChanged(self)
	self:SetBorderSize(self.borderSize)
end

function HDH_AT_CooldownIconTemplate_OnCooldownStarted(cooldownFrame)
	local self = cooldownFrame:GetParent():GetParent()
	-- print(GetTime(), "HDH_AT_CooldownIconTemplate_OnCooldownStarted")
	if self.OnCooldownStarted then
		self.OnCooldownStarted(self)
	end
end

function HDH_AT_CooldownIconTemplate_OnCooldownFinished(cooldownFrame)
	local self = cooldownFrame:GetParent():GetParent()
	-- print(GetTime(), "HDH_AT_CooldownIconTemplate_OnCooldownFinished")
	if self.OnCooldownFinished then
		self.OnCooldownFinished(self)
	end
end

function HDH_AT_CooldownIconTemplateMixin:Setup(w, h, cooldownType, toFill, enableSpark, sparkColor, circleColor, onAlpha, offAlpha, borderSize)
	self:SetSize(w, h)
	if self.Cooldown then
		self.Cooldown:Hide()
		self.Cooldown = nil
	end
	if cooldownType == DB.COOLDOWN_CIRCLE or cooldownType == DB.COOLDOWN_NONE then
		if not self.tmpCircle then
			self.tmpCircle = CreateFrame('Frame', nil, self.Icon, 'HDH_AT_CircleCooldownTemplate')
			self.tmpCircle:SetHandler(HDH_AT_CooldownIconTemplate_OnCooldownStarted, HDH_AT_CooldownIconTemplate_OnCooldownFinished)
			self.tmpCircle:SetAllPoints(true)
		end
		self.Cooldown = self.tmpCircle
		self.Cooldown:Setup(cooldownType, toFill, circleColor, onAlpha)

	else
		if not self.tmpLinear then
			self.tmpLinear = CreateFrame('Frame', nil, self.Icon, 'HDH_AT_LinearCooldownTemplate')
			self.tmpLinear:SetHandler(HDH_AT_CooldownIconTemplate_OnCooldownStarted, HDH_AT_CooldownIconTemplate_OnCooldownFinished)
			self.tmpLinear:SetAllPoints(true)
		end
		self.Cooldown = self.tmpLinear
		self.Cooldown:Setup(w, h, cooldownType, toFill, enableSpark, sparkColor, onAlpha)
	end
	self:SetBorderSize(borderSize)
	if self.Cooldown then
		self.Cooldown:Show()
	end
	local tmpTexutre = self.Icon.Texture:GetTexture()
	if tmpTexutre then
		self:SetTexture(tmpTexutre)
	end
	self.onAlpha = onAlpha
	self.offAlpha = offAlpha
	self.isAble = true
	self.toFill = toFill
	-- if self.cooldownType ~= DB.COOLDOWN_NONE then
	-- 	self.Icon.Texture:SetAlpha(offAlpha)
	-- else
	-- 	self.Icon.Texture:SetAlpha(onAlpha)
	-- end
	self.Icon.Texture:SetAlpha(offAlpha)
	self.borderColor = self.borderColor or {1, 1, 1, 1}
	
	self.Border:SetFrameLevel(self.Icon:GetFrameLevel() + 3)
	self.cooldownType = cooldownType
end

function HDH_AT_CooldownIconTemplateMixin:SetHandler(OnCooldownStarted, OnCooldownFinished)
	self.OnCooldownStarted = OnCooldownStarted
	self.OnCooldownFinished = OnCooldownFinished
end

function HDH_AT_CooldownIconTemplateMixin:GetAble()
	return self.isAble
end

function HDH_AT_CooldownIconTemplateMixin:SetBorderSize(borderSize)
	local border = 0.2355 * (1 - (ICON_BORDER_VALUE[borderSize] or 0))
	local size = 1 - (0.455 * (ICON_SIZE_VALUE[borderSize] or 0))

	self.Border.Texture:SetTexCoord(border, 1 - border, border, 1 - border)
	self.Icon:SetSize(self:GetWidth() * size, self:GetHeight() * size)
	self.borderSize = borderSize
end

function HDH_AT_CooldownIconTemplateMixin:SetBorderColor(r, g, b, a)
	self.borderColor = {r, g, b, a}
	self.Border.Texture:SetVertexColor(r, g, b, a)
end

function HDH_AT_CooldownIconTemplateMixin:SetTexture(texture)
	self.Icon.Texture:SetTexture(texture)
	self.Cooldown:SetTexture(texture)
end

function HDH_AT_CooldownIconTemplateMixin:GetTexture()
	return self.Icon.Texture:GetTexture()
end

-- function HDH_AT_CooldownIconTemplateMixin:SetGlowType(t, color, tickPerSec)

-- end

-- function HDH_AT_CooldownIconTemplateMixin:SetGlow(bool)

-- end

function HDH_AT_CooldownIconTemplateMixin:SetCooldown(startValue, duration, nonTimer)
	self.Cooldown:SetCooldown(startValue, duration, (nonTimer == nil) and true or nonTimer)
end

function HDH_AT_CooldownIconTemplateMixin:SetCharge(startValue, duration, nonTimer)
	self.Cooldown:SetCooldown(startValue, duration, (nonTimer == nil) and true or nonTimer, true)
end

function HDH_AT_CooldownIconTemplateMixin:SetGlobal(startValue, duration, nonTimer)
	self.Cooldown:SetCooldown(startValue, duration, (nonTimer == nil) and true or nonTimer, false, true)
end

function HDH_AT_CooldownIconTemplateMixin:SetValue(value)
	self.Cooldown:SetValue(value)
end

function HDH_AT_CooldownIconTemplateMixin:Stop()
	self.Cooldown:Stop()
end

function HDH_AT_CooldownIconTemplateMixin:UpdateCooldowning(bool)
	bool = (bool == nil) and true or false
	if bool then
		if self.toFill then
			self.Border.Texture:SetVertexColor(0, 0, 0, self.offAlpha)
		else
			self.Border.Texture:SetVertexColor(self.borderColor[1], self.borderColor[2], self.borderColor[3], self.borderColor[4])
		end
		
		-- if self.cooldownType ~= DB.COOLDOWN_NONE then
		-- 	self.Icon.Texture:SetAlpha(self.offAlpha)
		-- 	self.Icon.Texture:SetDesaturated(true)
		-- end
		self.Icon.Texture:SetAlpha(self.offAlpha)
		self.Icon.Texture:SetDesaturated(true)
		if not self.Cooldown.Progress.Texture:IsShown() then
			self.Cooldown:SetShownProgressTexture(true)
		end
	else
		if self.toFill then
			self.Icon.Texture:SetAlpha(self.onAlpha)
			self.Icon.Texture:SetDesaturated(false)
			self.Border.Texture:SetVertexColor(self.borderColor[1], self.borderColor[2], self.borderColor[3], self.borderColor[4])
		else
			-- if self.cooldownType ~= DB.COOLDOWN_NONE then
			-- 	self.Icon.Texture:SetAlpha(self.offAlpha)
			-- 	self.Icon.Texture:SetDesaturated(true)
			-- end
			self.Icon.Texture:SetAlpha(self.offAlpha)
			self.Icon.Texture:SetDesaturated(true)
			self.Border.Texture:SetVertexColor(0, 0, 0, self.offAlpha)
		end
		self.Cooldown:Clear()
	end
end

function HDH_AT_CooldownIconTemplateMixin:SetDesaturated()
	self.Icon.Texture:SetDesaturated(true)
	self.Icon.Texture:SetAlpha(self.offAlpha)
	self.Cooldown.Progress.Texture:Hide()
	self.Border.Texture:SetVertexColor(0, 0, 0, self.offAlpha)
end

function HDH_AT_CooldownIconTemplateMixin:SetOverlayColor(r, g, b, a)
	self.Cooldown:SetOverlayColor(r, g, b, a)
end

function HDH_AT_CooldownIconTemplateMixin:ShowOnlyEdgeSpark()
	self.Cooldown.Progress.Texture:Hide()
end