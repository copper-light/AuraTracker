local L = HDH_AT_L
local UTIL = HDH_AT_UTIL

local function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-------------------------------------------------------------
-- Aura List
-------------------------------------------------------------
HDH_AT_AuraRowMixin = {}

HDH_AT_AuraRowMixin.MODE = {}
HDH_AT_AuraRowMixin.MODE.EMPTY = 1
HDH_AT_AuraRowMixin.MODE.DATA = 2

function HDH_AT_AuraRowMixin:SetOnClickHandler(handler)
    self.onClickHandler = handler
end

function HDH_AT_AuraRowMixin:Set(no, key, id, name, texture, display, glow, value, isItem, readOnly)
	_G[self:GetName().."Icon"]:SetTexture(texture or 0)
    _G[self:GetName().."Icon"]:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    _G[self:GetName().."Icon"]:Show()
    _G[self:GetName().."AddIcon"]:Hide()
	_G[self:GetName().."TextNum"]:SetText(no)
	_G[self:GetName().."TextName"]:SetText(name)
    _G[self:GetName().."CheckButtonValue"]:SetChecked(value)
	_G[self:GetName().."CheckButtonAlways"]:SetChecked(display)
    _G[self:GetName().."CheckButtonGlow"]:SetChecked(glow)
	_G[self:GetName().."EditBoxID"]:SetText(id or key or "")
	_G[self:GetName().."CheckButtonIsItem"]:SetChecked(isItem)
	_G[self:GetName().."EditBoxID"]:ClearFocus() -- ButtonAddAndDel 의 값때문에 순서 굉장히 중요함
	_G[self:GetName().."RowDesc"]:Hide()
    _G[self:GetName().."CheckButtonAlways"]:Show()
    _G[self:GetName().."CheckButtonGlow"]:Show()
    _G[self:GetName().."CheckButtonValue"]:Show()
    _G[self:GetName().."ButtonConfig"]:Show()
    self.tmp_id = id
	self.tmp_chk = isItem
    self.readOnly = readOnly or false
    self.mode = HDH_AT_AuraRowMixin.MODE.DATA
end

function HDH_AT_AuraRowMixin:GetMode()
    return self.mode -- 0: data
end

function HDH_AT_AuraRowMixin:Get()
    local row_idx = _G[self:GetName().."TextNum"]:GetText()
	local key = _G[self:GetName().."EditBoxID"]:GetText()
    local value = _G[self:GetName().."CheckButtonValue"]:GetChecked()
	local always = _G[self:GetName().."CheckButtonAlways"]:GetChecked()
	local glow = _G[self:GetName().."CheckButtonGlow"]:GetChecked()
    local name = _G[self:GetName().."TextName"]:GetName()
    local texture = _G[self:GetName().."Icon"]:GetTexture()
    local isItem = _G[self:GetName().."CheckButtonIsItem"]:GetChecked()

    return row_idx, key, self.tmp_id, name, texture, always, glow, value, isItem
end

function HDH_AT_AuraRowMixin:Clear()
	_G[self:GetName().."Icon"]:SetTexture(0)
    _G[self:GetName().."Icon"]:Hide()
	_G[self:GetName().."TextNum"]:SetText(nil)
	_G[self:GetName().."TextName"]:SetText(nil)
	_G[self:GetName().."RowDesc"]:Show()
	_G[self:GetName().."CheckButtonAlways"]:SetChecked(true)
    _G[self:GetName().."CheckButtonGlow"]:SetChecked(false)
    _G[self:GetName().."CheckButtonValue"]:SetChecked(false)
	_G[self:GetName().."EditBoxID"]:SetText("")
	_G[self:GetName().."ButtonAdd"]:SetText(L.ADD)
	_G[self:GetName().."CheckButtonIsItem"]:SetChecked(false)
	_G[self:GetName().."EditBoxID"]:ClearFocus() -- ButtonAddAndDel 의 값때문에 순서 굉장히 중요함
    _G[self:GetName().."CheckButtonAlways"]:Hide()
    _G[self:GetName().."CheckButtonGlow"]:Hide()
    _G[self:GetName().."CheckButtonValue"]:Hide()
    _G[self:GetName().."ButtonConfig"]:Hide()
    _G[self:GetName().."AddIcon"]:Show()
    self.mode = HDH_AT_AuraRowMixin.MODE.EMPTY
    self.tmp_id = nil
	self.tmp_chk = false
    self.readOnly = false
end

function HDH_AT_AuraRowMixin:ChangeReadMode()
    if self.timer then
        self.timer:Cancel()
    end
    _G[self:GetName().."EditBoxID"]:Hide()

    if self.mode == HDH_AT_AuraRowMixin.MODE.DATA then
        _G[self:GetName().."CheckButtonAlways"]:Show()
        _G[self:GetName().."CheckButtonGlow"]:Show()
        _G[self:GetName().."CheckButtonValue"]:Show()
        _G[self:GetName().."ButtonConfig"]:Show()
        _G[self:GetName().."TextName"]:Show()
    else
        self:SetText("")
        _G[self:GetName().."RowDesc"]:Show()
    end
    _G[self:GetName().."CheckButtonIsItem"]:Hide()
    _G[self:GetName().."ButtonAdd"]:Hide()
    _G[self:GetName().."ButtonDel"]:Hide()
    _G[self:GetName().."ButtonCancel"]:Hide()
    _G[self:GetName().."CheckButtonIsItem"]:SetChecked(self.tmp_chk)
    _G[self:GetName().."EditBoxID"]:SetText(self.tmp_id or "")
end

function HDH_AT_OnClickIsItem(self)
    _G[self:GetParent():GetName().."EditBoxID"]:SetFocus()

    if self:GetParent().timer then
        self:GetParent().timer:Cancel()
    end
end

function HDH_AT_OnEditFocusGained(self)
    if self:GetParent().timer then
        self:GetParent().timer:Cancel()
    end
	local btn = _G[self:GetParent():GetName().."ButtonAdd"]
	local chk = _G[self:GetParent():GetName().."CheckButtonIsItem"]
	if(self:GetText() == "") then
		btn:SetText(L.ADD)
	else
		btn:SetText(L.EDIT)
	end

    if self:GetParent().mode == HDH_AT_AuraRowMixin.MODE.DATA then
        _G[self:GetParent():GetName().."CheckButtonAlways"]:Hide()
        _G[self:GetParent():GetName().."CheckButtonGlow"]:Hide()
        _G[self:GetParent():GetName().."CheckButtonValue"]:Hide()
        _G[self:GetParent():GetName().."ButtonConfig"]:Hide()
        _G[self:GetParent():GetName().."ButtonDel"]:Show()
    else
        _G[self:GetParent():GetName().."ButtonCancel"]:Show() 
    end
    _G[self:GetParent():GetName().."RowDesc"]:Hide()
    _G[self:GetParent():GetName().."ButtonAdd"]:Show() 
end

function HDH_AT_OnTextChanged(self)
    if string.len(self:GetText()) == 0 then
        self.Desc:Show()
    else
        self.Desc:Hide()
    end
end

function HDH_AT_OnEditFocusLost(self)
    -- 버튼 클릭 이벤트보다 포커스 로스트 이벤트가 먼저 일어나서 버튼 이벤트가 발생하지 않는 문제로 인하여
    -- 이벤트를 지연시킴
    self:GetParent().timer = C_Timer.NewTimer(0.5, function(self)
        self = self.arg
        self:GetParent():ChangeReadMode()
        self.timer = nil
    end)
    self:GetParent().timer.arg = self
end

function HDH_AT_OnEditEscape(self)
	_G[self:GetParent():GetName().."CheckButtonIsItem"]:SetChecked(self.tmp_chk)
	self:SetText(self.tmp_id or "")
	self:ClearFocus()
    self:GetParent():ChangeReadMode()
end

function HDH_AT_OnClickRowFrame(self)
    if not self.readOnly then
        _G[self:GetName().."TextName"]:Hide()
        _G[self:GetName().."CheckButtonIsItem"]:Show()
        _G[self:GetName().."EditBoxID"]:Show()
        _G[self:GetName().."EditBoxID"]:SetFocus()
    end
     if self.onClickHandler then
        self.onClickHandler(self)
    end
end

-------------------------------------------------------------
-- DropDown 
-------------------------------------------------------------

local TEXT_DD_MULTI_SELETED = "%d 개 선택됨"

HDH_AT_DropDownMixin = {
    globals= {"HDH_AT_DropDownMixin"}
}

function HDH_AT_DropDown_OnEnteredItem(self)
    local dropdownBtn = self.dropdownBtn
    dropdownBtn.onEnterHandler(dropdownBtn, self, self.idx, self.value)
    if dropdownBtn.hiddenBG and dropdownBtn.hiddenBG:IsShown() then
        dropdownBtn.hiddenBG:Hide()
    end
end

function HDH_AT_DropDown_OnSelectedItem(self)
    local dropdownBtn = self.dropdownBtn
    dropdownBtn:SetSelectedIndex(self.idx)
    dropdownBtn.onClickHandler(dropdownBtn, self, self.idx, self.value)
    if dropdownBtn.hiddenBG and dropdownBtn.hiddenBG:IsShown() then
        dropdownBtn.hiddenBG:Hide()
    end
end

function HDH_AT_DropDown_OnCheckButon(self)
    local dropdownBtn = self:GetParent().dropdownBtn
    dropdownBtn.selectedValueCount = dropdownBtn.selectedValueCount or 0
    if self:GetChecked() then
        dropdownBtn.selectedValueCount = dropdownBtn.selectedValueCount + 1
    else
        dropdownBtn.selectedValueCount = max(dropdownBtn.selectedValueCount - 1, 0)
    end

    _G[dropdownBtn:GetName().."Text"]:SetText(string.format(TEXT_DD_MULTI_SELETED, dropdownBtn.selectedValueCount))

    dropdownBtn.onClickHandler(dropdownBtn, self:GetParent(), self:GetParent().idx, self:GetParent().value)
end

function HDH_AT_DropDownMixin:GetIndex(value)
    local listFrame = _G[self:GetName().."List"]
    local items = self.item
    local ret
    if self.multiSelector then
        ret = {}
        for i, item in ipairs(items) do
            if item.CheckButton and item.CheckButton:GetChecked() then
                if item.value == value then
                    ret[#ret + 1] = i
                end
            end
        end
        return ret
    else
        for i, item in ipairs(items) do
            if item.value == value then
                return i
            end
        end
    end
    return nil
end

function HDH_AT_DropDownMixin:GetSelectedValue()
    if self.multiSelector then
        local listFrame = _G[self:GetName().."List"]
        local items = self.item
        local ret = {}
        for i, item in ipairs(items) do
            if item.CheckButton and item.CheckButton:GetChecked() then
                ret[#ret + 1] = item.value
            end
        end
        return ret
    else
        if self.selectedIdx then
            return self.value
        else
            return nil
        end
    end
end

function HDH_AT_DropDownMixin:Size()
    local listFrame = _G[self:GetName().."List"]
    local items = self.item  or {}
    local size = 0
    for i, item in ipairs(items) do
        if item:IsShown() then
            size = size + 1
        end
    end

    return size
end

function HDH_AT_DropDownMixin:Reset()
    local listFrame = _G[self:GetName().."List"]
    local items = self.item or {}

    for _, item in ipairs(items) do
        item:Hide()
        item.idx = nil
        item.value = nil
        item.name = nil
        item.texture = nil
    end
    self:SelectClear()
end

function HDH_AT_DropDownMixin:SelectClear()
    local listFrame = _G[self:GetName().."List"]
    local items = self.item
    if self:Size() == 0 then
        _G[self:GetName().."Text"]:SetText(L.NOTHING_LIST)
        _G[self:GetName().."Text"]:SetFontObject("Font_Gray_S")
        if _G[self:GetName().."Texture"] then
            _G[self:GetName().."Texture"]:SetTexture()
        end
        listFrame:SetHeight(1)
    else
        if self.multiSelector then
            for i, item in ipairs(items) do
                if item.CheckButton then
                    item.CheckButton:SetChecked(false)
                end
            end
            self.selectedValueCount = 0
            _G[self:GetName().."Text"]:SetText(string.format(TEXT_DD_MULTI_SELETED))
        else
            for i, child in ipairs(items) do
                _G[child:GetName().."On"]:Hide()
            end

            self.selectedIdx = nil
            self.value = nil
            _G[self:GetName().."Text"]:SetText(L.SELECT)
            _G[self:GetName().."Text"]:SetFontObject("Font_Yellow_S")
        end
    end
end

function HDH_AT_DropDownMixin:SetSelectedValue(value)
    local listFrame = _G[self:GetName().."List"]
    local items = self.item
    if self.multiSelector then
        local selectedValueCount = 0
        for i, item in ipairs(items) do
            if item.CheckButton then
                if hasValue(value, item.value) then
                    item.CheckButton:SetChecked(true)
                    selectedValueCount = selectedValueCount + 1
                else
                    item.CheckButton:SetChecked(false)
                end
            end
        end
        self.selectedValueCount = selectedValueCount
       _G[self:GetName().."Text"]:SetText(string.format(TEXT_DD_MULTI_SELETED, selectedValueCount))
       return selectedValueCount
    else
        local idx = nil
        for i, item in ipairs(items) do
            if item.value == value then
                self:SetSelectedIndex(i)
                idx = i
                break
            end
            
        end
        return idx
    end
end

function HDH_AT_DropDownMixin:SetSelectedIndex(idx, show)
    local listFrame = _G[self:GetName().."List"]
    local items = self.item
    show = show or false

    if not self.multiSelector then
        if idx <= 0 or idx > #items then return end
        local seletedItemFrame = items[idx]
        for i, child in ipairs(items) do
            if _G[child:GetName().."On"] then
                if i ~= idx then 
                    _G[child:GetName().."On"]:Hide()
                else
                    _G[child:GetName().."On"]:Show()
                end
            end
        end

        if not show and not self.always_show_list then
            listFrame:Hide()
        end
        _G[self:GetName().."Text"]:SetText(seletedItemFrame.name)
        _G[self:GetName().."Text"]:SetFontObject("Font_White_S")
        if _G[self:GetName().."Texture"] then
            local t = _G[self:GetName().."Texture"]
            if self.useAtlasSize then
                t:SetAtlas(seletedItemFrame.texture)
            else
                t:SetTexture(seletedItemFrame.texture) 
            end
        end
        self.selectedIdx = idx
        self.value = seletedItemFrame.value
    end
end

function HDH_AT_DropDownMixin:SetText(name)
    self.Text:SetText(name)
end

function HDH_AT_DropDownMixin:UseAtlasSize(bool)
    self.useAtlasSize = bool
end

function HDH_AT_DropDownMixin:GetItem()
    return self.item
end

function HDH_AT_DropDownMixin:SetHookOnClick(func)
    self.hookOnClickFunc = func
end

function HDH_AT_DropDown_Init(frame, itemValues, onClickHandler, onEnterHandler, template, multiSelector, always_show_list)
    local multiSelector = multiSelector or false
    local listFrame = _G[frame:GetName().."List"]
    local itemFrame
    template = template or "HDH_AT_DropDownOptionItemTemplate"
    itemValues = itemValues or {}
    frame.always_show_list = always_show_list or false
    local id, name, texture, handler
    local totalHeight = 1

    if frame.item then
        frame:SelectClear()
    end

    frame.item = frame.item or {}
    local item = frame.item
    local template_name 
    if #itemValues > 0 then    
        for i = 1, #itemValues do
            id, name, texture, handler = unpack(itemValues[i])
            if type(template) == 'table' then
                template_name = template[i]
            else
                template_name = template
            end

            if item[i] then
                if template_name ~= item[i].template_name then
                    item[i]:Hide()
                    item[i]:SetParent(nil)
                    item[i] = nil
                    itemFrame = CreateFrame("Button", listFrame:GetName().."i"..time()..i, listFrame, template_name)
                    item[i] = itemFrame
                else
                    itemFrame = item[i]
                    itemFrame:Show()
                end
            else
                itemFrame = CreateFrame("Button", listFrame:GetName().."i"..time()..i, listFrame, template_name)
                item[i] = itemFrame
            end

            if item[i-1] then
                itemFrame:SetPoint("TOPLEFT", item[i-1], "BOTTOMLEFT", 0, 0)
            else
                itemFrame:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 1, -1)
            end
            itemFrame:SetPoint("RIGHT", listFrame, "RIGHT", -1, 0)
            itemFrame.Text:SetText(name)

            if texture then
                local t = _G[itemFrame:GetName().."Texture"]
                if frame.useAtlasSize then
                    t:SetAtlas(texture)
                    t:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(1, 1, 1, 1))
                elseif frame.useFullSizeTexture then
                    t:SetTexture(texture) 
                else
                    t:SetTexture(texture) 
                    t:ClearAllPoints()
                    t:SetPoint("LEFT", itemFrame,"LEFT", 1, 0)
                    t:SetSize(itemFrame:GetHeight()-2, itemFrame:GetHeight()-2)
                    t:SetTexCoord(0.1,0.9,0.1,0.9)
	                t:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(1, 1, 1, 0))
                end
            end
            
            if onClickHandler then
                itemFrame:SetScript("OnClick", HDH_AT_DropDown_OnSelectedItem)
                frame.onClickHandler = onClickHandler
            end
            if onEnterHandler then
                itemFrame:SetScript("OnEnter", HDH_AT_DropDown_OnEnteredItem)
                frame.onEnterHandler = onEnterHandler
            end

            if itemFrame.CheckButton then
                itemFrame.CheckButton:SetScript("OnClick", HDH_AT_DropDown_OnCheckButon)
            end
            itemFrame.template_name= template_name
            itemFrame.idx = i
            itemFrame.value = id
            itemFrame.name = name
            itemFrame.texture = texture
            itemFrame.dropdownBtn = frame

            totalHeight = totalHeight + itemFrame:GetHeight()
        end

        if(not always_show_list) then
            local height = totalHeight + 1
            listFrame:SetHeight(height) 
        else
            frame:SetHeight(totalHeight-2) 
            listFrame:SetHeight(totalHeight+1) 
            listFrame:Show()
            listFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
            listFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
            frame.Text:Hide()
            if frame.RightText then
                frame.RightText:Hide()
                frame.BG:Hide()
            end
        end
    end

	if #item > #itemValues then
		for i = #itemValues+1, #item do
			item[i]:Hide()
		end
	end

    if #itemValues == 0 then
        _G[frame:GetName().."Text"]:SetText(L.NOTHING_LIST)
        listFrame:SetHeight(1)
    else
        frame.selectedIdx = nil
        frame.value = nil
        if multiSelector then
            _G[frame:GetName().."Text"]:SetText(string.format(TEXT_DD_MULTI_SELETED, 0))
            _G[frame:GetName().."Text"]:SetFontObject("Font_White_S")

        else
            _G[frame:GetName().."Text"]:SetText(L.SELECT)
            _G[frame:GetName().."Text"]:SetFontObject("Font_Yellow_S")
        end
    end

    if not always_show_list then
        listFrame:SetScript("OnShow", function(self)
            table.insert(UISpecialFrames, listFrame:GetName())
            listFrame:EnableKeyboard(1)
        end)
    end

    frame.multiSelector = multiSelector
end

function HDH_AT_DropDown_OnShow(self)
    _G[self:GetName().."Text"]:SetWidth(50)
end

function HDH_AT_DropDown_OnLoad(self)
    _G[self:GetName().."Text"]:SetText(L.SELECT)
    _G[self:GetName().."Text"]:SetFontObject("Font_Yellow_S")
end

function HDH_AT_DropDown_OnClick(self)
    if self.hookOnClickFunc then
        self.hookOnClickFunc(self)
    end
    if not self.always_show_list then
        local list = _G[self:GetName().."List"]

        if not self.hiddenBG then
            self.hiddenBG = CreateFrame("Frame", self:GetName().."HiddenBG", UIParent)
            self.hiddenBG:SetFrameStrata("Dialog")
            self.hiddenBG:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0,0)
            self.hiddenBG:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0,0)
            self.hiddenBG:SetScript("OnMouseDown", function(self) self:Hide() end)
            self.hiddenBG:SetScript("OnShow", function(self) 
                table.insert(UISpecialFrames, self:GetName())
                self:EnableKeyboard(1)
            end)
            self.hiddenBG:SetPropagateMouseClicks(true)
            self.hiddenBG.list = list

            self.hiddenBG2 = CreateFrame("Frame", self:GetName().."HiddenBG2", self.hiddenBG)
            self.hiddenBG2:SetPoint("TOPLEFT", self, "TOPLEFT", 0,0)
            self.hiddenBG2:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0,0)
            self.hiddenBG2:SetScript("OnMouseDown", function(self) self:GetParent():Hide() end)
        end
        self.hiddenBG:Show()
        list:ClearAllPoints()
        list:SetParent(self.hiddenBG)
        list:SetFrameStrata("Dialog")
        list:SetClampedToScreen(true)
        list:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0)
        list:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0)
        list:SetShown(true)
    end
end

function HDH_AT_DropDown_OnLeave(self)
end

function HDH_AT_DropDownList_OnLeave(self)
end

function HDH_AT_DropDownItem_OnLeave(self)
end


------------------------------------------------------------------
-- SLIDER
------------------------------------------------------------------

HDH_AT_SliderMixin = {}

local function SliderValueFormat(self, value)
    if (self.enableInt) then
        value = math.floor(value + 0.5)
    else
        value = math.floor( (value) * 10 ) / 10
    end
    return value
end

function HDH_AT_SliderMixin:UpdateMinMaxValues(value)
    local min, max
    if self.dynamic then
        min = value - self.range
        max = value + self.range
        max = math.min(max, self.max)
        min = math.max(min, self.min)
    else
        min = self.min
        max = self.max
    end
    self:SetMinMaxValues(min, max)
    self.MinValue:SetText(min)
    self.MaxValue:SetText(max)
    return self.dynamic
end

function HDH_AT_OnValueChanged_Slider(self, value)
    value = SliderValueFormat(self, value)
    self:SetValue(value)
    self.Value:SetText(self.format:format(value))
end

function HDH_AT_OnMouseUp_Slider(self)
    local value = SliderValueFormat(self, self:GetValue())
    self:UpdateMinMaxValues(value)
    self.handler(self, value)
end

function HDH_AT_SliderMixin:UpdateValue(value)
    value = SliderValueFormat(self, value)
    self:UpdateMinMaxValues(value)
    self:SetValue(value)
    self.Value:SetText(self.format:format(value))
end

function HDH_AT_SliderMixin:Init(value, min, max, enableInt, dynamic, range, format)
    self.format = format or (enableInt and "%d") or "%.1f"
    self.min = min or 0  
    self.max = max or 20
    self.enableInt = enableInt or false
    self.dynamic = dynamic or false
    self.range = range or 10
    self:UpdateMinMaxValues(value)
    self:SetValue(value)
    -- HDH_AT_OnMouseUp_Slider(self)
end

function HDH_AT_SliderMixin:SetHandler(handler)
    self.handler = handler
end

----------------------------------------------------------------
-- Color Picker 
----------------------------------------------------------------

HDH_AT_ColorPickerMixin = {}

function HDH_AT_ColorPickerMixin:SetColorRGBA(r, g, b, a)
    self.rgba = {r, g, b, a}
    self.Color:SetVertexColor(r, g, b, a)
    self.EditBox:SetText(UTIL.ColorToString(r, g, b, self.enableAlpha and a))
end

function HDH_AT_ColorPickerMixin:GetColorRGBA()
    return unpack(self.rgba)
end

function HDH_AT_ColorPickerMixin:SetEnableAlpha(enable)
    self.enableAlpha = enable
end

function HDH_AT_ColorPickerMixin:Cancel()
    local r, g, b, a = unpack(self.rgba)
    self:SetColorRGBA(r, g, b, a)
end

function HDH_AT_ColorPickerMixin:SetHandler(handler, errorHandler)
    self.handler = handler
    self.errorHandler = errorHandler
end

local function OnSelectedColorPicker()
    if ColorPickerFrame.buttonFrame == nil then return end
    local self = ColorPickerFrame.buttonFrame
    local r, g, b  = ColorPickerFrame:GetColorRGB()
    self:SetColorRGBA(r, g, b, ColorPickerFrame:GetColorAlpha())
    self.handler(self, r, g, b, ColorPickerFrame:GetColorAlpha())
    ColorPickerFrame.buttonFrame = nil
    ColorPickerFrame:Hide()
end

local function OnOKColorPicker()
    if ColorPickerFrame:IsShown() then 
        ColorPickerFrame:Hide() 
        ColorPickerFrame.buttonFrame = nil
    end
end

local function OnCancelColorPicker()
    local self = ColorPickerFrame.buttonFrame
    local r, g, b, a  = ColorPickerFrame:GetPreviousValues()
    self:SetColorRGBA(r, g, b, a)
    self.handler(self, r, g, b, a)

    ColorPickerFrame.buttonFrame = nil
end

function HDH_AT_ColorPickerMixin:SetEnableAlpha(enableAlpha)
    self.hasOpacity = enableAlpha
end

function HDH_AT_OnClickColorPicker(self)
    if self.enableAlpha == nil then
        self.enableAlpha = true
    end
	if ColorPickerFrame:IsShown() then return end
	ColorPickerFrame.colorButton = self
	local r, g, b, a = self:GetColorRGBA()
	a = a and a or 1;
	if self.enableAlpha then
		ColorPickerFrame.opacity = a
    end

    ColorPickerFrame.func = HDH_OnSelectedColor

    local info = {};
    ColorPickerFrame.buttonFrame = self
    info.swatchFunc = (function () end);
    info.cancelFunc = OnCancelColorPicker;
	info.r = r 
    info.g = g 
    info.b = b
    info.opacity = a 
	info.hasOpacity = self.enableAlpha;

    if ColorPickerFrame.Footer then
        ColorPickerFrame.Footer.OkayButton:HookScript("OnClick", OnSelectedColorPicker)
    else
        ColorPickerOkayButton:HookScript("OnClick", OnSelectedColorPicker)
    end

	ColorPickerFrame:SetupColorPickerAndShow(info);
end

-----------------------------------
-- dlalog
-----------------------------------

HDH_AT_DialogFrameTemplateMixin = {}
HDH_AT_DLG_TYPE = {OK=1, YES_NO=2, EDIT=3, MULTILINE_EDIT_OK=4, MULTILINE_EDIT_YES_NO=5, WARNING=6, WARNING_YES_NO=7};
HDH_AT_DLG_ICON = {
    "Interface/DialogFrame/UI-Dialog-Icon-AlertOther",
    "Interface/DialogFrame/UI-Dialog-Icon-AlertOther",
    "Interface/DialogFrame/UI-Dialog-Icon-AlertOther",
    "Interface/DialogFrame/UI-Dialog-Icon-AlertOther",
    "Interface/DialogFrame/UI-Dialog-Icon-AlertOther",
    "Interface/DialogFrame/UI-Dialog-Icon-AlertNew",
    "Interface/DialogFrame/UI-Dialog-Icon-AlertNew",
}

function HDH_AT_DialogFrameTemplateMixin:AlertShow(msg, type, func, cancelFunc, editboxText, ...)
	if self:IsShown() then return end
    self.EditBox:SetText(editboxText or "")
    self.EditBox:SetText(HDH_AT_UTIL.Trim(self.EditBox:GetText()))
	self.text = msg;
	self.dlg_type = type or HDH_AT_DLG_TYPE.WARNING
	self.func = func;
    self.cancelFunc = cancelFunc;
	self.arg = {...};
	self:Show();
end

function HDH_AT_DialogFrameTemplateMixin:Close()
	self:Hide();
end

function HDH_AT_DialogFrameTemplateMixin:OnShow()
	_G[self:GetName().."Text"]:SetText(self.text);
    self.Icon:SetTexture(HDH_AT_DLG_ICON[self.dlg_type])
    if self.dlg_type == HDH_AT_DLG_TYPE.YES_NO or self.dlg_type == HDH_AT_DLG_TYPE.WARNING_YES_NO then
        _G[self:GetName().."ButtonClose2"]:Hide()
        _G[self:GetName().."ButtonClose"]:Show()
        _G[self:GetName().."ButtonOK"]:Show()
        _G[self:GetName().."Edit"]:Hide()
        _G[self:GetName().."ButtonEditOK"]:Hide()
        _G[self:GetName().."ButtonEditCancel"]:Hide()
    elseif self.dlg_type == HDH_AT_DLG_TYPE.OK or self.dlg_type == HDH_AT_DLG_TYPE.WARNING then
        _G[self:GetName().."ButtonClose"]:Hide()
        _G[self:GetName().."ButtonOK"]:Hide()
        _G[self:GetName().."ButtonClose2"]:Show()
        -- _G[self:GetName().."ButtonClose2"]:SetPoint('CENTER', _G[self:GetName().."Text"], 'BOTTOM', 0, -45)
        _G[self:GetName().."Edit"]:Hide()
        _G[self:GetName().."ButtonEditOK"]:Hide()
        _G[self:GetName().."ButtonEditCancel"]:Hide()
    elseif self.dlg_type == HDH_AT_DLG_TYPE.EDIT then
        _G[self:GetName().."Edit"]:Show()
        _G[self:GetName().."Edit"]:SetMultiLine(false)
        _G[self:GetName().."Edit"]:SetHeight(24)
        _G[self:GetName().."Edit"]:SetWidth(350)
        _G[self:GetName().."ButtonClose2"]:Hide()
        _G[self:GetName().."ButtonClose"]:Hide()
        _G[self:GetName().."ButtonOK"]:Hide()
        _G[self:GetName().."ButtonEditOK"]:Show()
        _G[self:GetName().."ButtonEditCancel"]:Show()
    elseif self.dlg_type == HDH_AT_DLG_TYPE.MULTILINE_EDIT_OK then
        _G[self:GetName().."Edit"]:Show()
        -- _G[self:GetName().."Edit"]:SetMultiLine(true)
         _G[self:GetName().."Edit"]:SetHeight(24)
        _G[self:GetName().."Edit"]:SetWidth(350)
        -- _G[self:GetName().."ButtonClose2"]:SetPoint('CENTER', _G[self:GetName().."Text"], 'BOTTOM', 0, -45 - 62)
        _G[self:GetName().."ButtonClose2"]:Show()
        _G[self:GetName().."ButtonClose"]:Hide()
        _G[self:GetName().."ButtonOK"]:Hide()
        _G[self:GetName().."ButtonEditOK"]:Hide()
        _G[self:GetName().."ButtonEditCancel"]:Hide()
    elseif self.dlg_type == HDH_AT_DLG_TYPE.MULTILINE_EDIT_YES_NO then
        _G[self:GetName().."Edit"]:Show()
        -- _G[self:GetName().."Edit"]:SetMultiLine(true)
         _G[self:GetName().."Edit"]:SetHeight(24)
        _G[self:GetName().."Edit"]:SetWidth(350)
        _G[self:GetName().."ButtonClose2"]:Hide()
        _G[self:GetName().."ButtonClose"]:Hide()
        _G[self:GetName().."ButtonOK"]:Hide()
        _G[self:GetName().."ButtonEditOK"]:Show()
        _G[self:GetName().."ButtonEditCancel"]:Show()
    end
end

-----------------------------------
-- HDH_AT_SplitBarTemplateMixin
-----------------------------------

HDH_AT_SplitBarTemplateMixin = {}



local function HDH_AT_SplitBar_OnDragging(self)
    local x, y, w, h = self:GetBoundsRect()
    local p_x, p_y, p_w, p_h = self:GetParent():GetBoundsRect()
    self.Value:SetText(math.ceil((x - p_x) + math.floor( w / 2 )))
end

local function HDH_AT_SplitBar_OnDragStart(self)
    self:StartMoving()
    self:SetToplevel(true)
    self:SetScript('OnUpdate', HDH_AT_SplitBar_OnDragging)
end

local function HDH_AT_SplitBar_OnDragStop(self)
    self:StopMovingOrSizing();
	self:SetScript('OnUpdate', nil)

    local x, y, w, h = self:GetBoundsRect()
    local p_x, p_y, p_w, p_h = self:GetParent():GetBoundsRect()

    -- if y > p_y then
    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", (x - p_x)+10, 0)


    x, y, w, h = self:GetBoundsRect()
    p_x, p_y, p_w, p_h = self:GetParent():GetBoundsRect()
    self.Value:SetText(math.ceil((x - p_x) + math.floor( w / 2 )))
end

function HDH_AT_SplitBarTemplateMixin:SetSplitPoints(values)
    self.size = 0
    if values then
        for i=1, #values do
            self:AddPointer(i, values[i])
        end
    end

    for i = #self.splitList, self.size + 1, -1 do
        self:HidePointer(i)
    end
end

function HDH_AT_SplitBarTemplateMixin:GetValue()
    local value = self.EditBox:GetText()
    if string.len(value) > 0 then
        return tonumber(self.EditBox:GetText())
    else
        return 0
    end
end

function HDH_AT_SplitBarTemplateMixin:SetMinMaxValues(minValue, maxValue, isRatio)
    self.splitList = self.splitList or {}
    self.isRatio = isRatio
    
    if not self.minPointer then
        self.minPointer = CreateFrame("Frame", self:GetName().."splitMin", self, "HDH_AT_SplitPointerTemplate")
        self.minPointer:SetPoint("TOP", self.Bar, "TOPLEFT", 0, 0)
        self.minPointer.Line:Hide()
        self.minPointer.TopValue:Hide()
        self.minPointer.TopAnchor:Hide()
        self.minPointer.TopValue:SetFontObject('Font_Yellow_S')
        self.minPointer.BottomValue:SetFontObject('Font_Yellow_S')
    end
    self.minPointer.BottomValue:SetText(minValue)

    if not self.maxPointer then
        self.maxPointer = CreateFrame("Frame", self:GetName().."splitMin", self, "HDH_AT_SplitPointerTemplate")
        self.maxPointer:SetPoint("TOP", self.Bar, "TOPRIGHT", 0, 0)
        self.maxPointer.Line:Hide()
        self.maxPointer.TopValue:Hide()
        self.maxPointer.TopAnchor:Hide()
        self.maxPointer.TopValue:SetFontObject('Font_Yellow_S')
        self.maxPointer.BottomValue:SetFontObject('Font_Yellow_S')
    end
    local value = self.isRatio and (maxValue .. '%') or UTIL.CommaValue(maxValue)
    self.maxPointer.TopValue:SetText(value)
    self.maxPointer.BottomValue:SetText(value)
    self.minValue = minValue
    self.maxValue = maxValue

    if self:GetSize() ~= 0 and self:GetSize() % 2 == 0 then
        self.maxPointer.BottomAnchor:Hide()
        self.maxPointer.BottomValue:Hide()
        self.maxPointer.TopValue:Show()
        self.maxPointer.TopAnchor:Show()
    else
        self.maxPointer.BottomAnchor:Show()
        self.maxPointer.BottomValue:Show()
        self.maxPointer.TopValue:Hide()
        self.maxPointer.TopAnchor:Hide()
    end
end

function HDH_AT_SplitBarTemplateMixin:GetMinMaxValues()
    return self.minValue, self.maxValue
end

function HDH_AT_SplitBarTemplateMixin:RemovePointer(index)
    self:HidePointer(index)
    self.size = self.size - 1
end

function HDH_AT_SplitBarTemplateMixin:HidePointer(index)
    for i = index, #self.splitList do
        if self.splitList[i] and self.splitList[i].value then
            self.splitList[i].value = (self.splitList[i+1] and self.splitList[i+1].value) or nil
            if not self.splitList[i].value then
                self.splitList[i]:Hide()
            end
        end
    end
    
    if self:GetSize() ~= 0 and self:GetSize() % 2 == 0 then
        self.maxPointer.BottomAnchor:Hide()
        self.maxPointer.BottomValue:Hide()
        self.maxPointer.TopValue:Show()
        self.maxPointer.TopAnchor:Show()
    else
        self.maxPointer.BottomAnchor:Show()
        self.maxPointer.BottomValue:Show()
        self.maxPointer.TopValue:Hide()
        self.maxPointer.TopAnchor:Hide()
    end
end

function HDH_AT_SplitBarTemplateMixin:AddPointer(index, value)
    if self.maxValue <= value then return false end
    self.splitList = self.splitList or {}
    local split
    if not self.splitList[index] then
        self.splitList[index] = CreateFrame("Frame", self:GetName().."split".. index , self, "HDH_AT_SplitPointerTemplate")
    end
    self.size = self.size + 1
    split = self.splitList[index]
    split.value = value 
    split:SetPoint("TOP", self.Bar, "TOPLEFT", self.Bar:GetWidth() * (value / self.maxValue), 0)
    split:Show()

    local text = self.isRatio and (split.value .. '%') or UTIL.CommaValue(split.value)
    if index % 2 == 0 then
        split.BottomValue:SetText(text)
        split.BottomAnchor:Show()
        split.TopValue:Hide()
        split.TopAnchor:Hide()
    else
        split.TopValue:SetText(text)
        split.TopAnchor:Show()
        split.BottomAnchor:Hide()
        split.BottomValue:Hide()
    end

    if self:GetSize() ~= 0 and self:GetSize() % 2 == 0 then
        self.maxPointer.BottomAnchor:Hide()
        self.maxPointer.BottomValue:Hide()
        self.maxPointer.TopValue:Show()
        self.maxPointer.TopAnchor:Show()
    else
        self.maxPointer.BottomAnchor:Show()
        self.maxPointer.BottomValue:Show()
        self.maxPointer.TopValue:Hide()
        self.maxPointer.TopAnchor:Hide()
    end
    return true
end

function HDH_AT_SplitBarTemplateMixin:GetSize()
    return self.size or 0
end

function HDH_AT_SplitBar_OnMouseUp(self)
    local w = self:GetWidth()

end

-----------------------------------
-- HDH_AT_AddDelEdtiboxTemplateMixin
-----------------------------------
HDH_AT_AddDelEdtiboxTemplateMixin = {}

function HDH_AT_AddDelEdtiboxTemplateMixin:GetValue()
    local value = self.EditBox:GetText()
    if string.len(value) > 0 then
        return tonumber(self.EditBox:GetText())
    else
        return 0
    end
end

function HDH_AT_AddDelEdtiboxTemplateMixin:SetValue(value)
    if tonumber(value) then
        self.EditBox:SetText(value)
    end
end


-------------------------------------
-- HDH_AT_SwitchFrameTemplateMixin-
-------------------------------------

HDH_AT_SwitchFrameTemplateMixin = {}

local switchDefualtItem = {
    { true, L.ON },
    { false, L.OFF },
}

function HDH_AT_SwitchFrameTemplateMixin:Init(itemList, onChangedHandler)
    itemList = itemList or switchDefualtItem
    if not itemList or #itemList == 0 then return end
    local size = #itemList
    local itemWidth, itemHeight = self:GetSize()
    if itemWidth >= 250 then
        itemWidth = (itemWidth-10) / size
    else
        itemWidth = (itemWidth-4) / size
    end
    
    itemHeight = self:GetHeight() - 4
    local btn
    self.onChangedHandler = onChangedHandler
    self.list = self.list or {}
    for index, value in ipairs(itemList) do
        if not self.list[index] then
            self.list[index] = CreateFrame("Button", self:GetName()..index, self, "HDH_AT_SwitchItemFrameTemplate")
            self.list[index]:SetScript("OnClick", function(btn)
                btn:GetParent():SetSelectedIndex(btn.index)
                if btn:GetParent().onChangedHandler then
                    btn:GetParent().onChangedHandler(btn:GetParent(), btn, btn.index, btn.index)
                end
            end)
        end
        btn = self.list[index]
        btn:ClearAllPoints()
        btn:SetFrameLevel(10)
        btn:SetPoint("TOPLEFT", self, "TOPLEFT", ((itemWidth) * (index - 1)) + 2, -2)
        btn:SetSize(itemWidth, itemHeight)
        btn:SetText(value[2])
        btn.index = index
        btn.value = value[1]

        if index == #itemList then
            btn:SetPoint("RIGHT", self, "RIGHT", -2, 0)
        end
    end
    self.itemList = itemList
end

function HDH_AT_SwitchFrameTemplateMixin:SetSelectedValue(selectedValue)
    local selectedIndex = 1
    for index, btn in ipairs(self.list) do
        if btn.value == selectedValue then
            selectedIndex = index
            break
        end
    end
    self:SetSelectedIndex(selectedIndex)
end

function HDH_AT_SwitchFrameTemplateMixin:SetSelectedIndex(selectedIndex)
    for index, btn in ipairs(self.list) do
        if index == selectedIndex then
            btn:Disable()
        else
            btn:Enable()
        end
    end
    self.index = selectedIndex
    self.value = self.list[selectedIndex].value
end

function HDH_AT_SwitchFrameTemplateMixin:GetSelectedIndex()
    return self.index
end

function HDH_AT_SwitchFrameTemplateMixin:GetSelectedValue()
    return self.value
end

function HDH_AT_SwitchFrameTemplateMixin:Enable()
    self.DisableLayer:Hide()
end

function HDH_AT_SwitchFrameTemplateMixin:Disable()
    self.DisableLayer:Show()
end

------------------------------------------
-- HDH_AT_SliderTemplateMixin
------------------------------------------

HDH_AT_SliderTemplateMixin = {}

function HDH_AT_SliderTemplateMixin_OnClick(self)
    local value 
    local slider = self:GetParent()

    if self == slider.Left or self == slider.HiddenLeft then
        value = slider.value - slider.tick
    else
        value = slider.value + slider.tick
    end

    if slider.value ~= value then
        if slider:SetValue(value) and slider.handler then
            slider.handler(slider, slider.value)
        end
    end
end

function HDH_AT_SliderTemplateMixin:Init(value, min, max, tick, format)
    self.tick = tick or 1
    self.tickDecimalPlaces = HDH_AT_UTIL.GetDecimalPlaces(self.tick)
    self.format = format or ((self.tickDecimalPlaces == 0) and "%d") or "%.1f"
    self.width = self:GetWidth() - 35
    self:SetMinMaxValues(min, max)
    self:SetValue(value)
end

function HDH_AT_SliderTemplateMixin:SetMinMaxValues(minValue, maxValue)
    self.minValue = minValue or 0
    self.maxValue = maxValue or 30
    self.range = maxValue - minValue
    self.tickWidth = self.width / self.range
    self.value = self.value or 0
    if minValue > self.value then
        self:SetValue(minValue)
    elseif maxValue < self.value then
        self:SetValue(maxValue)
    end
end

function HDH_AT_SliderTemplateMixin:SetValue(value)
    if value < self.minValue then
        value = self.minValue
    elseif value > self.maxValue then
        value = self.maxValue
    end

    value = math.floor((value + (self.tick/2)) / self.tick) * self.tick
    if self.value ~= value then
        self.value = value
        self.Bar:SetWidth(math.max((value - self.minValue) * self.tickWidth, 0.01))
        self.Text:SetText(self.format:format(self.value))
        return true
    else
        return false
    end
end

function HDH_AT_SliderTemplateMixin:GetValue()
    return self.value
end

function HDH_AT_SliderTemplateMixin:OnUpdate()
    local new_x = select(1, self.Anchor:GetCenter()) - 1 - self:GetLeft() - 17
    if new_x < 0 then
        new_x = 0
    elseif new_x > (self.width) then
        new_x = self.width
    end

    local value = (self.range * (new_x / self.width)) + self.minValue
    if self:SetValue(value) and self.handler then
        self.handler(self, self.value)
    end
end

function HDH_AT_SliderTemplateMixin:GetMinMaxValues()
    return self.minValue, self.maxValue
end

function HDH_AT_SliderTemplateMixin:SetHandler(handler)
    self.handler = handler
end

function HDH_AT_SliderTemplateMixin_OnEnterPressed(self)
    local value = tonumber(self:GetText()) 
    local min, max = self:GetParent():GetMinMaxValues()
    if (value ~= nil) then
        if self:GetParent():SetValue(value) and self:GetParent().handler then
            self:GetParent().handler(self:GetParent(), self:GetParent().value)
        end
    else
        self:GetParent().EditBox:SetText(self:GetParent().format:format(self:GetParent().value))
    end
end

function HDH_AT_SliderTemplateMixin_OnEditFocusLost(self)
    self:SetText(self:GetParent().format:format(self:GetParent().value))
end

function HDH_AT_SliderTemplateMixin_OnEditFocusGained(self)
    self:SetText(self:GetParent().value)
end


------------------------------------
-- HDH_AT_LatestSpellItemTemplateMixin
------------------------------------
HDH_AT_LatestSpellItemTemplateMixin = {}

function HDH_AT_LatestSpellItemTemplateMixin:SetActive(bool)
    if bool then
        self.Background:Show()
        self.Line:Hide()
    else
        self.Background:Hide()
        self.Line:Show()
    end
end

-------------------------------------
--  HDH_AT_SpellSearchEditBoxTemplateMixin
-------------------------------------

HDH_AT_SpellSearchEditBoxTemplateMixin = {}

function HDH_AT_SpellSearchEditBoxTemplateMixin:GetValue()
    return self.EditBox:GetText()
end

function HDH_AT_SpellSearchEditBoxTemplateMixin:SetValue(value)
    self.EditBox:SetText(value)
end

function HDH_AT_SpellSearchEditBoxTemplateMixin:SetName(name)
    if name== nil or string.len(name) == 0 then
        self.Name:SetText("")
        self.Desc:Show()
    else
        self.Name:SetText(name)
        self.Desc:Hide()
    end
end

function HDH_AT_SpellSearchEditBoxTemplateMixin:SetIsItem(bool)
    self.CBIsItem:SetChecked(bool or false)
end

function HDH_AT_SpellSearchEditBoxTemplateMixin:GetIsItem()
    return self.CBIsItem:GetChecked()
end

function HDH_AT_SpellSearchEditBoxTemplateMixin:GetName()
    return self.Name:GetText()
end

function HDH_AT_SpellSearchEditBoxTemplateMixin:SetIcon(texture)
    self.Icon:SetTexture(texture)
    self.Icon:Show()
    self.DefaultIcon:Hide()
end

function HDH_AT_SpellSearchEditBoxTemplateMixin:SetDefaultIcon()
    self.DefaultIcon:Show()
    self.Icon:Hide()
end

function HDH_AT_SpellSearchEditBoxTemplateMixin:Reset()
    self.DefaultIcon:Show()
    self.Icon:Hide()
    self.Name:SetText("")
    self.EditBox:SetText("")
    self.Desc:SetText(L.PLEASE_INPUT_TRAIT_SPELL)
    self.Desc:Show()
    self.tmp_name = nil
    self.tmp_value = nil
    self.tmp_icon = nil
    self.tmp_isItem = false
    self.BtnCancel:Hide()
    self:SetIsItem(false)
    self.CBIsItem:Hide()
end

function HDH_AT_SpellSearchEditBoxTemplateMixin:SetBackup(value, name, icon, isItem)
    self.tmp_value = value
    self.tmp_name = name
    self.tmp_icon = icon
    self.tmp_isItem = isItem
end

function HDH_AT_SpellSearchEditBoxTemplateMixin:LoadBackup()
    if self.tmp_value then
        self:SetName(self.tmp_name or "")
        self:SetValue(self.tmp_value or "")
        self:SetIsItem(self.tmp_isItem or false)
        if self.tmp_icon then
            self:SetIcon(self.tmp_icon)
        else
            self:SetDefaultIcon()
        end
    else
        self:Reset()
    end
end

function HDH_AT_SpellSearchEditBoxTemplateMixin:SetOnClickHandler(handler)
    self.OnClickSearchHandler = handler
end

----------------------------------------
-- HDH_AT_MultiLineEditBoxTemplateMixin
----------------------------------------
HDH_AT_MultiLineEditBoxTemplateMixin = {}

function HDH_AT_MultiLineEditBoxTemplateMixin:SetText(text)
    self.SF.EditBox:SetText(text)
end

function HDH_AT_MultiLineEditBoxTemplateMixin:GetText()
    return self.SF.EditBox:GetText()
end

function HDH_AT_MultiLineEditBoxTemplateMixin:GetEditBox()
    return self.SF.EditBox
end

function HDH_AT_MultiLineEditBoxTemplateMixin:SetMultiLine(bool)
    self.SF.EditBox:SetMultiLine(bool)
    if bool then
        self.SF:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -7)
        self.SF:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 7)
    else
        self.SF:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -2)
        self.SF:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
    end
end

function HDH_AT_MultiLineEditBoxTemplateMixin:SetAutoFocus(bool)
    self.SF.EditBox:SetAutoFocus(bool)
end