local DB = HDH_AT_ConfigDB
local BAR_INNER_MAX = 1000
local BAR_ANIMATE_DURATION = .10 --.15

------------------------------
-- HDH_AT_StatusBarTemplateMixin
------------------------------
HDH_AT_StatusBarTemplateMixin = {}

function HDH_AT_StatusBar_OnValueChanged(self, value)
    self.minV, self.maxV = self:GetMinMaxValues()
    if self.minV >= value then
        if self.enbleSpark and self.Spark:IsShown() then self.Spark:Hide() end
        self.full = nil
    elseif self.maxV <= value then
        if self.enbleSpark and self.Spark:IsShown() then self.Spark:Hide() end
        self.full = true
    else
        if self.enbleSpark and not self.Spark:IsShown() then self.Spark:Show() end
        self.full = false
    end
    if self.fullColor then 
        if self.full ~= nil and self.full ~= self.prevFull then
            if self.full then
                self:SetStatusBarColor(self.fullColor[1], self.fullColor[2], self.fullColor[3], self.fullColor[4])
            else
                self:SetStatusBarColor(self.normalColor[1], self.normalColor[2], self.normalColor[3], self.normalColor[4])
            end
        end
        self.prevFull = self.full
    end
end

function HDH_AT_StatusBarTemplateMixin:SetDirection(direction, toFill, texture)
    if self.direction == direction and self.toFill == toFill and self.texture == texture then return end
    self.direction = direction
    self.toFill = toFill
    self.texture = texture
    if direction == DB.COOLDOWN_UP or direction == DB.COOLDOWN_RIGHT then
        toFill = not toFill
    end

    self:SetReverseFill(toFill)
    self.Spark:ClearAllPoints()
    self:SetStatusBarTexture(texture)
    if direction == DB.COOLDOWN_LEFT or direction == DB.COOLDOWN_RIGHT then
        self:SetOrientation("Horizontal")
        self:SetRotatesTexture(false)
        self.Spark:SetPoint("TOP", self:GetStatusBarTexture(), toFill and "TOPLEFT" or "TOPRIGHT", 0, 1)
        self.Spark:SetPoint("BOTTOM", self:GetStatusBarTexture(), toFill and "BOTTOMLEFT" or "BOTTOMRIGHT", 0, -1)
        self.Spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark")
        self.Spark:SetWidth(9)

    else
        self:SetOrientation("vertical")
        self:SetRotatesTexture(true)
        self.Spark:SetPoint("LEFT", self:GetStatusBarTexture(), toFill and "BOTTOMLEFT" or "TOPLEFT", -1, 0)
        self.Spark:SetPoint("RIGHT", self:GetStatusBarTexture(), toFill and "BOTTOMRIGHT" or "TOPRIGHT", 1, 0)
        self.Spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v")
        self.Spark:SetHeight(9)
    end
    self.Spark:Hide()
    self.prevFull = nil
    HDH_AT_StatusBar_OnValueChanged(self, self:GetValue())
end

function HDH_AT_StatusBarTemplateMixin:UseChangedStatusColor(normalColor, fullColor)
    self.normalColor = normalColor
    self.fullColor = fullColor
    self.prevFull = nil
    if normalColor then
        HDH_AT_StatusBar_OnValueChanged(self, self:GetValue())
    end
end

function HDH_AT_StatusBarTemplateMixin:EnableSpark(bool, color)
    self.enbleSpark = bool
    self.prevFull = nil
    self.Spark:SetShown(false)
    if color then
        self.Spark:SetVertexColor(color[1], color[2], color[3], color[4])
    end
end

------------------------------------------
--- HDH_AT_MultiStatusBarTemplateMixin
------------------------------------------
HDH_AT_MultiStatusBarTemplateMixin = {}

function HDH_AT_MultiStatusBarTemplateMixin:OnUpdate(elapsed)
    -- self.elapsed = (self.elapsed or 0) + elapsed
    -- if self.elapsed < 0.015 then return end
    -- self.elapsed = 0

    self.skip = (self.skip or 0) + 1
	if self.skip % 2 ~= 0 and elapsed < 0.03 then return end
	self.skip = 0

    if self.gap and self.gap ~= 0 then
        local gapRatio = math.min(1., HDH_AT_UTIL.LogScale((GetTime() - self.animatedStartTime) / BAR_ANIMATE_DURATION))
        self:SetInnerValue(self.startValue + (self.gap * gapRatio))
    end
end

function HDH_AT_MultiStatusBarTemplateMixin:Setup(minMaxValues, points, pointType, direction, toFill, texture, texture_r)
    self.points = points or self.points or {}
    self.list = self.list or {}
    self.margin_x = 2
    self.margin_y = 2
    self.minValue = self.minValue or 0
    self.maxValue = self.maxValue or 1
    self.range = self.range or 1
    self.direction = direction or self.direction or DB.COOLDOWN_RIGHT
    self.toFill = toFill
    self.texture = texture or "Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg"
    self.texture_r = texture_r or "Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg"
    self.pointType = pointType or self.pointType or DB.BAR_SPLIT_RATIO
    self.backgroundColor = {0, 0, 0, 0.3}
    self.fullColor = {1, 0, 0, 1}
    self.normalColor = {0, 1, 0, 1}
    self.sparkColor = {1,1,1,1}
    self.innerValue = self.innerValue or 0
    self.value = self.value or 0
    self.innerPoints = self:UpdateSplitPoints(self.points, self.pointType, self.range)
    self.fullTextColor = {1,1,1,1}
    self.normalTextColor= {1,1,1,1}
    self.enbaleSpark = self.enbaleSpark or true
    self.sparkColor = self.sparkColor or {1,1,1,1}

    setmetatable(self.list, {
        __index = function(list, index)
            local newBar = CreateFrame("Frame", self:GetParent():GetName().."Bar"..index, self)
            newBar:SetFrameLevel(0)
            newBar.StatusBar = CreateFrame("StatusBar", newBar:GetName().."SB", newBar, "HDH_AT_StatusBarTemplate")
            newBar.StatusBar:SetPoint("TOPLEFT", newBar, "TOPLEFT", 1, -1)
            newBar.StatusBar:SetPoint("BOTTOMRIGHT", newBar, "BOTTOMRIGHT", -1, 1)
            newBar.StatusBar.id = index
			newBar.Background = newBar:CreateTexture(nil,"BACKGROUND")
			newBar.Background:SetPoint('TOPLEFT', newBar, 'TOPLEFT', 0, 0)
			newBar.Background:SetPoint('BOTTOMRIGHT', newBar, 'BOTTOMRIGHT', 0, 0)
			newBar.Background:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/cooldown_bg")
            list[index] = newBar

            if self.direction == DB.COOLDOWN_LEFT or  self.direction == DB.COOLDOWN_DOWN then
                newBar.StatusBar:SetDirection(self.direction, self.toFill, self.texture)
            else
                newBar.StatusBar:SetDirection(self.direction, self.toFill, self.texture_r)
            end

            newBar.Background:SetVertexColor(unpack(self.backgroundColor))
            newBar.StatusBar:EnableSpark(self.enbaleSpark, self.sparkColor)

            if self.fullColor then
                newBar.StatusBar:UseChangedStatusColor(self.normalColor, self.fullColor)
            elseif self.normalColor then
                newBar.StatusBar:SetStatusBarColor(unpack(self.normalColor))
            end

            return newBar
        end
    })
    if not self.Text then
        self.Text = self:CreateFontString(GetTime(), "ARTWORK")
        self.Text:SetTextColor(0,1,0,0.1)
    end
   
    self:UpdateLayout()
    if minMaxValues and #minMaxValues == 2 then
        self:SetMinMaxValues(minMaxValues[1], minMaxValues[2])
    end
    for _, bar in ipairs(self.list) do
        if self.direction == DB.COOLDOWN_LEFT or  self.direction == DB.COOLDOWN_DOWN then
            bar.StatusBar:SetDirection(self.direction, self.toFill, self.texture)
        else
            bar.StatusBar:SetDirection(self.direction, self.toFill, self.texture_r)
        end
    end
    self:SetInnerValue(self.innerValue)
end

function HDH_AT_MultiStatusBarTemplateMixin:UseChangedStatusColor(normalColor, fullColor)
    self.normalColor = normalColor
    self.fullColor = fullColor
    for _, bar in ipairs(self.list) do
        bar.StatusBar:UseChangedStatusColor(normalColor, fullColor)
    end
end

function HDH_AT_MultiStatusBarTemplateMixin:ToInnerValue(value)
    if self.range == 0 then return 0 end
    return (value - self.minValue) / self.range * BAR_INNER_MAX
end

function HDH_AT_MultiStatusBarTemplateMixin:GetValue()
    return self.value
end

function HDH_AT_MultiStatusBarTemplateMixin:SetText(text)
    self.Text:SetText(text or "")
end

function HDH_AT_MultiStatusBarTemplateMixin:GetText()
    return self.Text:GetText()
end

function HDH_AT_MultiStatusBarTemplateMixin:SetTextLocation(location, margin_left, margin_right)
    if location ~= DB.FONT_LOCATION_HIDE then
        if location == DB.FONT_LOCATION_BAR_L then
            self.Text:SetJustifyH("LEFT");
            self.Text:SetJustifyV('MIDDLE');
        elseif location == DB.FONT_LOCATION_BAR_R then
            self.Text:SetJustifyH("RIGHT");
            self.Text:SetJustifyV('MIDDLE');
        elseif location == DB.FONT_LOCATION_BAR_C then
            self.Text:SetJustifyH("CENTER");
            self.Text:SetJustifyV('MIDDLE');
        elseif location == DB.FONT_LOCATION_BAR_T then
            self.Text:SetJustifyH("CENTER");
            self.Text:SetJustifyV("TOP");
        else -- BOTTOM
            self.Text:SetJustifyH("CENTER");
            self.Text:SetJustifyV("BOTTOM");
        end
        -- SetJustify 의 값이 변경될 경우,
        -- 텍스트가 재할당될떄까지 값이 적용되지 않아서 텍스트 수동으로 재할당함
        if string.len(self.Text:GetText() or "") > 0 then
            local tmp = self.Text:GetText()
            self.Text:SetText("")
            self.Text:SetText(tmp)
        end
        self.Text:Show()
    else
        self.Text:Hide()
    end
    self.Text:SetPoint('TOPLEFT', self, 'TOPLEFT', margin_left, -3)
    self.Text:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -margin_right, 3)
end

function HDH_AT_MultiStatusBarTemplateMixin:SetTextSize(size, fonStyle)
    self.Text:SetFont(fonStyle or "fonts/2002.ttf", size, "OUTLINE")
end

function HDH_AT_MultiStatusBarTemplateMixin:SetTextColor(normalTextColor, fullTextColor)
    self.normalTextColor = normalTextColor
    self.fullTextColor = fullTextColor
    self.Text.full = nil
    self:SetInnerValue(self.innerValue)
end

function HDH_AT_MultiStatusBarTemplateMixin:UpdateLayout()
    local w, h = self:GetSize()
    local margin_x = self.margin_x
    local margin_y = self.margin_y
    local length = (#self.innerPoints + 1)
    local bar, prevBar
    local barSize
    local direction = self.direction or DB.COOLDOWN_LEFT
    local toFill = self.toFill
    if direction == DB.COOLDOWN_UP or direction == DB.COOLDOWN_RIGHT then
        toFill = not toFill
    end

    local sumMinValue = 0
    local sumMaxValue = 0

     if not self.toFill then
        sumMinValue = BAR_INNER_MAX
    end

    for i=1, length do
        prevBar = bar
        bar = self.list[i]

        barSize = ((self.innerPoints[i] or BAR_INNER_MAX) - (self.innerPoints[i-1] or 0))
        if self.toFill then
            sumMaxValue = barSize + sumMinValue
            bar.StatusBar:SetMinMaxValues(sumMinValue, sumMaxValue)
        else
            sumMaxValue = sumMinValue - barSize
            bar.StatusBar:SetMinMaxValues(sumMaxValue, sumMinValue)
        end
        bar:ClearAllPoints()
        if direction == DB.COOLDOWN_LEFT then
            bar:SetSize((w - (margin_x * #self.innerPoints)) * (barSize / BAR_INNER_MAX), h)
            if     i == 1      then bar:SetPoint("RIGHT", 0, 0)
            elseif i == length then bar:SetPoint("LEFT", 0, 0)
                                    bar:SetPoint("RIGHT", prevBar, "LEFT", -margin_x, 0)
                               else bar:SetPoint("RIGHT", prevBar, "LEFT", -margin_x, 0) end

        elseif direction == DB.COOLDOWN_RIGHT then
            bar:SetSize((w - (margin_x * #self.innerPoints)) * (barSize / BAR_INNER_MAX), h)
            if     i == 1      then bar:SetPoint("LEFT", 0, 0)
            elseif i == length then bar:SetPoint("RIGHT", 0, 0)
                                    bar:SetPoint("LEFT", prevBar, "RIGHT", margin_x, 0)
                               else bar:SetPoint("LEFT", prevBar, "RIGHT", margin_x, 0) end

        elseif direction == DB.COOLDOWN_UP then
            bar:SetSize(w, (h - (margin_y * #self.innerPoints)) * (barSize / BAR_INNER_MAX))
            if     i == 1      then bar:SetPoint("BOTTOM", 0, 0)
			elseif i == length then bar:SetPoint("TOP", 0, 0)
                                    bar:SetPoint("BOTTOM", prevBar, "TOP", 0, margin_y)
                               else bar:SetPoint("BOTTOM", prevBar, "TOP", 0, margin_y) end

        else -- COOLDOWN_DOWN
            bar:SetSize(w, (h - (margin_y * #self.innerPoints)) * (barSize / BAR_INNER_MAX))
            if     i == 1      then bar:SetPoint("TOP", 0, 0)
			elseif i == length then bar:SetPoint("BOTTOM", 0, 0)
                                    bar:SetPoint("TOP", prevBar, "BOTTOM", 0, -margin_y)
                               else bar:SetPoint("TOP", prevBar, "BOTTOM", 0, -margin_y) end
        end

        sumMinValue = sumMaxValue
        if not bar:IsShown() then bar:Show() end
    end

    for i=length + 1, #self.list do
        self:RelaseBar(i)
    end
end

function HDH_AT_MultiStatusBarTemplateMixin:SetSize(w, h)
    self:SetWidth(w)
    self:SetHeight(h)
    self:UpdateLayout()
end

function HDH_AT_MultiStatusBarTemplateMixin:RelaseBar(index)
    self.list[index]:Hide()
    self.list[index] = nil
end

function HDH_AT_MultiStatusBarTemplateMixin:GetSplitPoints()
    return self.points
end

function HDH_AT_MultiStatusBarTemplateMixin:SetBackgroundColor(r, g, b, a)
    if not r or not g or not b or not a then return end
    self.backgroundColor = {r, g, b, a}
    for _, bar in ipairs(self.list) do
        bar.Background:SetVertexColor(r, g, b, a)
    end
end

function HDH_AT_MultiStatusBarTemplateMixin:EnableSpark(bool, color)
    self.enbaleSpark = bool
    self.sparkColor = color
    for _, bar in ipairs(self.list) do
        bar.StatusBar:EnableSpark(bool, color)
    end
end

function HDH_AT_MultiStatusBarTemplateMixin:SetValue(value, animate)
    if value == self.value then return end
    self.value = value
    value = self:ToInnerValue(value)
    if animate then
        self.animatedStartTime = GetTime()
        self.targetValue = value
        self.startValue = self.innerValue
        self.gap = self.targetValue - self.startValue
    else
        self.gap = nil
        self.targetValue = nil
        self.startValue = nil
        self.animatedStartTime = nil
        self.innerValue = value
    end
    self:SetInnerValue(self.innerValue)
end

function HDH_AT_MultiStatusBarTemplateMixin:SetInnerValue(value)
    if not value then return end
    self.innerValue = math.floor(value)
    if self.targetValue then
        if self.targetValue == self.innerValue then
            self.gap  = nil
            self.targetValue = nil
            self.startValue = nil
            self.animatedStartTime = nil
            if self:GetScript("OnUpdate") then
                self:SetScript("OnUpdate", nil)
            end
        else
            if not self:GetScript("OnUpdate") then
                self:SetScript("OnUpdate", self.OnUpdate)
            end
        end
    end
    if self.toFill then
        for _, bar in ipairs(self.list) do
            bar.StatusBar:SetValue(self.innerValue)
        end
    else
        for _, bar in ipairs(self.list) do
            bar.StatusBar:SetValue(BAR_INNER_MAX - self.innerValue)
        end
    end
    
    if self.Text:IsShown() then
        if self.innerValue >= BAR_INNER_MAX then
            if self.Text.full == false or self.Text.full == nil then
                self.Text.full = true
                self.Text:SetTextColor(unpack(self.fullTextColor))
            end
        else
            if self.Text.full == true  or self.Text.full == nil then
                self.Text.full = false
                self.Text:SetTextColor(unpack(self.normalTextColor))
            end
        end
    end
end

function HDH_AT_MultiStatusBarTemplateMixin:SetStatusBarColor(r, g, b, a)
    self.normalColor = {r, g, b, a}
    for _, bar in ipairs(self.list) do
        bar.StatusBar:SetStatusBarColor(r, g, b, a)
    end
end

function HDH_AT_MultiStatusBarTemplateMixin:SetMinMaxValues(minValue, maxValue, reload)
    if not reload and self.minValue == minValue and self.maxValue == maxValue then return false end
    if #self.points >= 1 and self.points[#self.points] >= ((maxValue - minValue) / (self.range) * BAR_INNER_MAX) then return false end
    self.minValue = minValue
    self.maxValue = maxValue
    self.range = maxValue - minValue
    self.innerPoints = self:UpdateSplitPoints(self.points, self.pointType, self.range)
    self:UpdateLayout()
    self:SetInnerValue(self.innerValue)
    return true
end

function HDH_AT_MultiStatusBarTemplateMixin:UpdateSplitPoints(points, pointType, range)
    local innerPoints = {}
    if (points == nil or #points == 0) and range == nil then
        return
    end
    if pointType == DB.BAR_SPLIT_RATIO then
        for i, v in ipairs(points) do
            if v < 100 then
                table.insert(innerPoints, v / 100 * BAR_INNER_MAX)
            end
        end
    else
        for _, v in ipairs(points) do
            if v < range then
                table.insert(innerPoints, v / range * BAR_INNER_MAX)
            end
        end
    end
    return innerPoints
end

function HDH_AT_MultiStatusBarTemplateMixin:SetSplitPoints(points, pointType)
    self.points = points or {}
    self.pointType = pointType or DB.BAR_SPLIT_RATIO
    self:SetMinMaxValues(self.minValue, self.maxValue, true)
end

function HDH_AT_MultiStatusBarTemplateMixin:GetMaxValue()
    return self.maxValue
end

function HDH_AT_MultiStatusBarTemplateMixin:GetMinMaxValues()
    return self.minValue, self.maxValue
end