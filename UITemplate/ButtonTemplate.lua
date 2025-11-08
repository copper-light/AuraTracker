---------------------------------------------
--- HDH_AT_BottomTapMixin
---------------------------------------------
HDH_AT_BottomTapMixin = {}

function HDH_AT_BottomTapMixin:SetActivate(bool)
    if bool then
        self:Disable()
        self.Left:Hide()
        self.Middle:Hide()
        self.Right:Hide()
        self.LeftActive:Show()
        self.MiddleActive:Show()
        self.RightActive:Show()

        if HDH_AT.LE == HDH_AT.LE_CLASSIC then
            self.LeftActive:SetTexCoord(0, 0.15625, 0.15, 1.0)
            self.MiddleActive:SetTexCoord(0.15625, 0.84375, 0.15, 1.0)
            self.RightActive:SetTexCoord(0.84375, 1.0, 0.15, 1.0)
            self.Text:SetPoint("TOP", 0, -9)
        else
            self.Text:SetPoint("TOP", 0, -11)
        end
    else
        self:Enable()
        self.Left:Show()
        self.Middle:Show()
        self.Right:Show()
        self.LeftActive:Hide()
        self.MiddleActive:Hide()
        self.RightActive:Hide()
        self.Text:SetPoint("TOP",0, -7)
    end
end

---------------------------------------------
--- HDH_AT_UITabBtnMixin
---------------------------------------------
HDH_AT_UITabBtnMixin = {}

function HDH_AT_UITabBtnMixin:SetActivate(bool)
    if bool then
        self.Active1:Show()
        self.Active2:Show()
    else
        self.Active1:Hide()
        self.Active2:Hide()
    end
end

----------------------------------------------
---HDH_AT_TrackerTapBtnTemplateMixin
----------------------------------------------
HDH_AT_TrackerTapBtnTemplateMixin = {}

function HDH_AT_TrackerTapBtnTemplateMixin:SetActivate(bool)
    if bool then
        _G[self:GetName().."BgLine2"]:Show()
        _G[self:GetName().."On"]:Show()
        self.BG:SetColorTexture(0,0,0,0.5)
        self.Text:SetTextColor(1,0.8,0)
    else
        _G[self:GetName().."BgLine2"]:Hide()
        _G[self:GetName().."On"]:Hide()
        self.BG:SetColorTexture(0,0,0,0.3)
        self.Text:SetTextColor(0.8,0.8,0.8)
    end
end
