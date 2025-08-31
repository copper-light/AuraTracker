-------------------------------------
--  HDH_AT_CheckButtonTemplateMixin
-------------------------------------

HDH_AT_CheckButtonTemplateMixin = {}

function HDH_AT_CheckButton_OnClick(self)
    self:SetChecked(not (self.isChecked or false))
    if self.OnClickfunc then
        self.OnClickfunc(self)
    end
end

function HDH_AT_CheckButton_OnEnter(self)
    local visibleWidth = self:GetFontString():GetWidth()
    local fullWidth = self:GetFontString():GetUnboundedStringWidth()
    if fullWidth > visibleWidth then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:AddLine(self:GetText());
        GameTooltip:Show();
    end
end

function HDH_AT_CheckButton_OnLeave(self)
    if GameTooltip:IsShown() then
        GameTooltip:Hide()
    end
end

function HDH_AT_CheckButtonTemplateMixin:SetChecked(bool)
    self.Active:SetShown(bool)
    self.isChecked = bool
end

function HDH_AT_CheckButtonTemplateMixin:GetChecked()
    return self.isChecked or false
end

function HDH_AT_CheckButtonTemplateMixin:SetScript(scriptTypeName, func)
    if scriptTypeName == "OnClick" then
        self.OnClickfunc = func
    end
end

function HDH_AT_CheckButtonTemplateMixin:SetText(text)
    self.Base.Text:SetText(text)
end

function HDH_AT_CheckButtonTemplateMixin:SetFontObject(object)
    if self.Base then
        self.Base.Text:SetFontObject(object)
    end
end

function HDH_AT_CheckButtonTemplateMixin:GetFontString()
    return self.Base.Text
end

function HDH_AT_CheckButtonTemplateMixin:GetText()
    return self.Base.Text:GetText()
end


---------------------------------
-- HDH_AT_TalentCheckButtonMixin
---------------------------------
HDH_AT_TalentCheckButtonMixin = {}

function HDH_AT_TalentCheckButton_OnClick(self)
    self:SetChecked(not (self.isChecked or false))
    if self.OnClickfunc then
        self.OnClickfunc(self)
    end
end

function HDH_AT_TalentCheckButtonMixin:SetChecked(bool)
    self.isChecked = bool
    if bool then
        self:SetSize(100, 30)
        self.Icon:SetDesaturated(false)
        self.Icon:SetAlpha(1)
        self.Name:Show()
        self.Active:Show()
    else
        self:SetSize(50, 30)
        self.Icon:SetDesaturated(true)
        self.Icon:SetAlpha(0.4)
        self.Name:Hide()
        self.Active:Hide()
    end
end

function HDH_AT_TalentCheckButtonMixin:SetActivate(bool)
    self:SetChecked(bool)
end

function HDH_AT_TalentCheckButtonMixin:SetText(text)
    self.Name:SetText(text)
end

function HDH_AT_TalentCheckButtonMixin:GetText()
    return self.Name:GetText()
end

function HDH_AT_TalentCheckButtonMixin:SetValue(id)
    self.id = id
end

function HDH_AT_TalentCheckButtonMixin:GetValue()
    return self.id 
end

function HDH_AT_TalentCheckButtonMixin:SetUnassigned()
    self.Icon:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
    self.Name:SetText(L.UNASSIGNED)
end