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


---------------------------
---------------------------


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
        self.Text:SetPoint("CENTER",0,-3)
    else
        self:Enable()
        self.Left:Show()
        self.Middle:Show()
        self.Right:Show()
        self.LeftActive:Hide()
        self.MiddleActive:Hide()
        self.RightActive:Hide()
        self.Text:SetPoint("CENTER",0,3)
    end
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
	_G[self:GetName().."ButtonIcon"]:SetNormalTexture(texture or 0)
	_G[self:GetName().."ButtonIcon"]:GetNormalTexture():SetTexCoord(0.08, 0.92, 0.08, 0.92);
	_G[self:GetName().."TextNum"]:SetText(no)
	_G[self:GetName().."TextName"]:SetText(name)
	_G[self:GetName().."TextID"]:SetText(id.."")
    _G[self:GetName().."CheckButtonValue"]:SetChecked(value)
	_G[self:GetName().."CheckButtonAlways"]:SetChecked(display)
    _G[self:GetName().."CheckButtonGlow"]:SetChecked(glow)
	_G[self:GetName().."EditBoxID"]:SetText(id or key or "")
	_G[self:GetName().."CheckButtonIsItem"]:SetChecked(isItem)
    self.tmp_id = id
	self.tmp_chk = isItem
	_G[self:GetName().."EditBoxID"]:ClearFocus() -- ButtonAddAndDel 의 값때문에 순서 굉장히 중요함
	_G[self:GetName().."RowDesc"]:Hide()
    _G[self:GetName().."CheckButtonAlways"]:Show()
    _G[self:GetName().."CheckButtonGlow"]:Show()
    _G[self:GetName().."CheckButtonValue"]:Show()
    _G[self:GetName().."ButtonSet"]:Show()
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
	--local showValue = _G[rowFrame:GetName().."CheckButtonShowValue"]:GetChecked()
    local name = _G[self:GetName().."TextName"]:GetName()
    local texture = _G[self:GetName().."ButtonIcon"]:GetNormalTexture()
    local isItem = _G[self:GetName().."CheckButtonIsItem"]:GetChecked()
    local id = _G[self:GetName().."TextID"]:GetText()

    return row_idx, key, id, name, texture, always, glow, value, isItem
end

function HDH_AT_AuraRowMixin:Clear()
	_G[self:GetName().."ButtonIcon"]:SetNormalTexture(0)
    _G[self:GetName().."ButtonIcon"]:GetNormalTexture():SetAtlas("ui-hud-minimap-zoom-in")
    _G[self:GetName().."ButtonIcon"]:GetNormalTexture():SetTexCoord(-0.09, 1.09, -0.09, 1.09)
	_G[self:GetName().."TextNum"]:SetText(nil)
	_G[self:GetName().."TextName"]:SetText(nil)
	_G[self:GetName().."RowDesc"]:Show()
	_G[self:GetName().."TextID"]:SetText(nil)
	_G[self:GetName().."CheckButtonAlways"]:SetChecked(true)
    _G[self:GetName().."CheckButtonGlow"]:SetChecked(false)
    _G[self:GetName().."CheckButtonValue"]:SetChecked(false)
	_G[self:GetName().."EditBoxID"]:SetText("")
	_G[self:GetName().."ButtonAdd"]:SetText(L.SAVE)
	_G[self:GetName().."CheckButtonIsItem"]:SetChecked(false)
	_G[self:GetName().."EditBoxID"]:ClearFocus() -- ButtonAddAndDel 의 값때문에 순서 굉장히 중요함
    _G[self:GetName().."CheckButtonAlways"]:Hide()
    _G[self:GetName().."CheckButtonGlow"]:Hide()
    _G[self:GetName().."CheckButtonValue"]:Hide()
    _G[self:GetName().."ButtonSet"]:Hide()
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
    _G[self:GetName().."TextID"]:Hide()

    if self.mode == HDH_AT_AuraRowMixin.MODE.DATA then
        _G[self:GetName().."CheckButtonAlways"]:Show()
        _G[self:GetName().."CheckButtonGlow"]:Show()
        _G[self:GetName().."CheckButtonValue"]:Show()
        _G[self:GetName().."ButtonSet"]:Show()
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
		btn:SetText(L.SAVE)
	else
		btn:SetText(L.EDIT)
	end
	--self:SetWidth(EDIT_WIDTH_L)
    
    if self:GetParent().mode == HDH_AT_AuraRowMixin.MODE.DATA then
        _G[self:GetParent():GetName().."CheckButtonAlways"]:Hide()
        _G[self:GetParent():GetName().."CheckButtonGlow"]:Hide()
        _G[self:GetParent():GetName().."CheckButtonValue"]:Hide()
        _G[self:GetParent():GetName().."ButtonSet"]:Hide()
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
        _G[self:GetName().."TextID"]:Hide()
        _G[self:GetName().."TextName"]:Hide()
        _G[self:GetName().."CheckButtonIsItem"]:Show()
        _G[self:GetName().."EditBoxID"]:Show()
        _G[self:GetName().."EditBoxID"]:SetFocus()
        if self.onClickHandler then
            self.onClickHandler(self)
        end
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
    local dropdownBtn = self:GetParent():GetParent()
    dropdownBtn.onEnterHandler(dropdownBtn, self, self.idx, self.value)
end

function HDH_AT_DropDown_OnSelectedItem(self)
    local dropdownBtn = self:GetParent():GetParent()
    dropdownBtn:SetSelectedIndex(self.idx)
    dropdownBtn.onClickHandler(dropdownBtn, self, self.idx, self.value)
end

function HDH_AT_DropDown_OnCheckButon(self)
    local dropdownBtn = self:GetParent():GetParent():GetParent()
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
            _G[self:GetName().."Text"]:SetText(string.format(TEXT_DD_MULTI_SELETED, selectedValueCount))
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

    if not multiSelector then
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
    local id, name, texture
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
                else
                    t:SetTexture(texture) 
                    t:ClearAllPoints()
                    t:SetPoint("LEFT", itemFrame,"LEFT", 4, 0)
                    t:SetSize(itemFrame:GetHeight()-8, itemFrame:GetHeight()-8)
                    t:SetTexCoord(0.1,0.9,0.1,0.9)
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
            -- table.insert(UIMenus, listFrame:GetName())
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
        list:SetShown(not list:IsShown())
    end
end

function HDH_AT_DropDown_OnLeave(self)
    -- if not self.always_show_list and not _G[self:GetName().."List"]:IsMouseOver() then
    --     -- _G[self:GetName().."List"]:Hide()
    -- end
end

local function CheckMouseOver(frame) 
    local children = frame:GetChildren()
    if #children >= 1 then
        for _, child in ipairs(children) do
            if CheckMouseOver(child) then
                return true
            end
            if child:IsMouseOver() then
                return true
            end
        end
    end
    return false
end


function HDH_AT_DropDownList_OnLeave(self)
    -- local parent = self:GetParent()
    -- if not parent.always_show_list and not self:GetParent():IsMouseOver() then
    --     local show = CheckMouseOver(self)
    --     if not show then
    --         self:Hide()
    --     end
    -- end
end

function HDH_AT_DropDownItem_OnLeave(self)
    -- local parent = self:GetParent()
    -- if not parent:GetParent().always_show_list and not parent:IsMouseOver() and not parent:GetParent():IsMouseOver() then
    --     local hide = true
    --     for _, child in ipairs(parent:GetParent().item) do
    --         if child:IsMouseOver() then
    --             hide = false
    --             break
    --         end
    --     end
    --     if hide then
    --         parent:Hide()
    --     end
    -- end
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

function HDH_AT_ColorPickerMixin:SetHandler(handler, errorHandler)
    self.handler = handler
    self.errorHandler = errorHandler
end

local function OnSelectedColorPicker()
    if ColorPickerFrame.buttonFrame == nil then return end
    self = ColorPickerFrame.buttonFrame
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
    self = ColorPickerFrame.buttonFrame
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

------------------------------------------------------------------------
--
------------------------------------------------------------------------

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


-----------------------------------
-- dlalog
-----------------------------------

HDH_AT_DialogFrameTemplateMixin = {}
HDH_AT_DialogFrameTemplateMixin.DLG_TYPE = {OK =1, YES_NO=2, EDIT=3, NONE= 4};

function HDH_AT_DialogFrameTemplateMixin:AlertShow(msg, type, func, cancelFunc, ...)
    local main = self:GetParent()
    type = type or self.DLG_TYPE.OK
	if self:IsShown() then return end
	self.text = msg;
	self.dlg_type = type;
	self.func = func;
    self.cancelFunc = cancelFunc;
	self.arg = {...};
	self:Show();
end

function HDH_AT_DialogFrameTemplateMixin:Close()
	self:Hide();
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

function HDH_AT_SplitBarTemplateMixin:GetValue()
    local value = self.EditBox:GetText()
    if string.len(value) > 0 then
        return tonumber(self.EditBox:GetText())
    else
        return 0
    end
end

function HDH_AT_SplitBarTemplateMixin:SetMinMaxValues(minValue, maxValue)
    self.splitList = self.splitList or {}
    
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
    self.maxPointer.TopValue:SetText(maxValue)
    self.maxPointer.BottomValue:SetText(maxValue)
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
    -- self.splitList = self.splitList or {}
    local i
    for i = index, #self.splitList do
        if self.splitList[i] and self.splitList[i].value and self.size and self.size > 0 then
            self.size = self.size - 1
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
    self.splitList = self.splitList or {}
    local split
    if not self.splitList[index] then
        self.splitList[index] = CreateFrame("Frame", self:GetName().."split".. index , self, "HDH_AT_SplitPointerTemplate")
    end

    split = self.splitList[index]
    if not split.value then
        self.size = (self.size or 0) + 1
    end
    split.value = value 
    split:SetPoint("TOP", self.Bar, "TOPLEFT", self.Bar:GetWidth() * (value / self.maxValue), 0)
    split:Show()
    if index % 2 == 0 then
        split.BottomValue:SetText(split.value)
        split.BottomAnchor:Show()
        split.TopValue:Hide()
        split.TopAnchor:Hide()
    else
        split.TopValue:SetText(split.value)
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
        btn:SetPoint("TOPLEFT", self, "TOPLEFT", ((itemWidth) * (index - 1)) + 2, -2)
        btn:SetSize(itemWidth, itemHeight)
        btn:SetText(value[2])
        btn.index = index
        btn.value = value[1]
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
            -- btn.Active:Show()
            -- btn.Deactive:Hide()
            btn:Disable()
            -- btn:SetNormalFontObject("Font_White_S")
        else
            -- btn.Active:Hide()
            -- btn.Deactive:Show()
            btn:Enable()
            -- btn:SetNormalFontObject("Font_Gray_S")
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


------------------------------------------
-- HDH_AT_SliderTemplateMixin
------------------------------------------

HDH_AT_SliderTemplateMixin = {}

function HDH_AT_SliderTemplateMixin_OnClick(self)
    local tick = 0
    local value 
    if self:GetParent().maxValue > 1 then
        tick = 1
    else
        tick = 0.1
    end

    if self == self:GetParent().Left then
        value = self:GetParent().value - tick
    else
        value = self:GetParent().value + tick
    end

    if self:GetParent().value ~= value then
        if self:GetParent():SetValue(value) and self:GetParent().handler then
            self:GetParent().handler(self:GetParent(), self:GetParent().value)
        end
    end
end

function HDH_AT_SliderTemplateMixin:Init(value, min, max, a, b, c, format)
    self.format = format or ( (max > 1) and "%d") or "%.1f"
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

    if self.maxValue > 1 then
        value = math.floor(value+0.5)
    else
        value = math.floor((value * 10) + 0.5) / 10
    end
    
    if self.value ~= value then
        self.value = value
        self.Bar:SetWidth(math.max((value - self.minValue) * self.tickWidth, 0.01))
        self.EditBox:SetText(self.format:format(self.value))
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
--  HDH_AT_CheckButton2TemplateMixin
-------------------------------------

HDH_AT_CheckButton2TemplateMixin = {}

function HDH_AT_CheckButton2_OnClick(self)
    self:SetChecked(not (self.isChecked or false))
    if self.OnClickfunc then
        self.OnClickfunc(self)
    end
end

function HDH_AT_CheckButton2TemplateMixin:HiddenBackground(bool)
    self.isHideBackground = bool

    if bool then
        self.DeactiveCheckBoxTop:Show()
        self.DeactiveCheckBoxRight:Show()
        self.DeactiveCheckBoxLeft:Show()
        self.DeactiveCheckBoxBottom:Show()
        self.Deactive1:Hide()
        self.DeactiveBorderTop:Hide()
        self.DeactiveBorderLeft:Hide()
        self.DeactiveBorderBottom:Hide()
        self.DeactiveBorderRight:Hide()
    else
        self.DeactiveCheckBoxTop:Hide()
        self.DeactiveCheckBoxRight:Hide()
        self.DeactiveCheckBoxLeft:Hide()
        self.DeactiveCheckBoxBottom:Hide()
        self.Deactive1:Show()
        self.DeactiveBorderTop:Show()
        self.DeactiveBorderLeft:Show()
        self.DeactiveBorderBottom:Show()
        self.DeactiveBorderRight:Show()
    end
end

function HDH_AT_CheckButton2TemplateMixin:SetChecked(bool)
    if bool then
        if not self.isHideBackground then
            self.Active1:Show()
        end

        self.ActiveBorderTop:Show()
        self.ActiveBorderLeft:Show()
        self.ActiveBorderRight:Show()
        self.ActiveBorderBottom:Show()
        self.CheckMarker:Show()
    else
        self.Text:SetFontObject("Font_White_S")
        self.Active1:Hide()
        self.CheckMarker:Hide()
        self.ActiveBorderTop:Hide()
        self.ActiveBorderLeft:Hide()
        self.ActiveBorderRight:Hide()
        self.ActiveBorderBottom:Hide()
        self.Active2:Hide()
    end
    self.isChecked = bool
end

function HDH_AT_CheckButton2TemplateMixin:GetChecked()
    return self.isChecked or false
end

function HDH_AT_CheckButton2TemplateMixin:SetScript(scriptTypeName, func)
    if scriptTypeName == "OnClick" then
        self.OnClickfunc = func
    end
end

---
HDH_AT_SpellSearchEditBoxTemplateMixin = {}

function HDH_AT_SpellSearchEditBoxTemplateMixin:GetText()
    return self.EditBox:GetText()
end

function HDH_AT_SpellSearchEditBoxTemplateMixin:SetText(text)
    self.EditBox:SetText(text)
end
