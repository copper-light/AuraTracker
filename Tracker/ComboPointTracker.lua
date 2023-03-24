HDH_COMBO_POINT_TRACKER = {}
local DB = HDH_AT_ConfigDB
local MyClassKor, MyClass = UnitClass("player");

local POWER_INFO = {}

------------------------------------
-- HDH_COMBO_POINT_TRACKER class
------------------------------------
local super = HDH_AURA_TRACKER
setmetatable(HDH_COMBO_POINT_TRACKER, super) -- 상속
HDH_COMBO_POINT_TRACKER.__index = HDH_COMBO_POINT_TRACKER
HDH_COMBO_POINT_TRACKER.className = "HDH_COMBO_POINT_TRACKER"

HDH_TRACKER.TYPE.POWER_COMBO_POINTS = 15
HDH_TRACKER.TYPE.POWER_SOUL_SHARDS = 16
HDH_TRACKER.TYPE.POWER_HOLY_POWER = 17
HDH_TRACKER.TYPE.POWER_CHI = 18
HDH_TRACKER.TYPE.POWER_ARCANE_CHARGES = 19


HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_COMBO_POINTS,   HDH_COMBO_POINT_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_SOUL_SHARDS,    HDH_COMBO_POINT_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_HOLY_POWER,     HDH_COMBO_POINT_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_CHI,      		HDH_COMBO_POINT_TRACKER)
HDH_TRACKER.RegClass(HDH_TRACKER.TYPE.POWER_ARCANE_CHARGES, HDH_COMBO_POINT_TRACKER)

POWER_INFO[HDH_TRACKER.TYPE.POWER_COMBO_POINTS] 	= {power_type="COMBO_POINTS", 	power_index = 4,	color={0.77, 0.12, 0.23, 1}, texture = "Interface/Icons/INV_Misc_Gem_Pearl_05"}; -- INV_Misc_Gem_Pearl_04 INV_chaos_orb INV_Misc_Gem_Pearl_04 Spell_AnimaRevendreth_Orb
POWER_INFO[HDH_TRACKER.TYPE.POWER_SOUL_SHARDS]		= {power_type="SOUL_SHARDS",	power_index = 7, 	color={201/255, 34/255, 1, 	 1}, texture = "Interface/Icons/inv_misc_enchantedpearlE"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_HOLY_POWER]		= {power_type="HOLY_POWER", 	power_index = 9,	color={1, 216/255, 47/255, 1}, texture = "Interface/Icons/Spell_Holy_SealOfWrath"}; -- Ability_Priest_SpiritOfTheRedeemer
POWER_INFO[HDH_TRACKER.TYPE.POWER_CHI]				= {power_type="CHI", 			power_index = 12,	color={0, 196/255, 117/255, 1}, texture = "Interface/Icons/INV_Misc_Gem_Pearl_06"};
POWER_INFO[HDH_TRACKER.TYPE.POWER_ARCANE_CHARGES]	= {power_type="ARCANE_CHARGES",	power_index = 16,	color={2/255, 60/255, 189/255, 1}, texture = "Interface/Icons/Spell_Nature_WispSplode"};

HDH_COMBO_POINT_TRACKER.POWER_INFO = POWER_INFO;

local function OnUpdateBar(self)
	if self.bar then
		self.bar:SetValue(self:GetParent().parent:GetAnimatedValue(self.bar, not self:GetParent().parent.ui.bar.to_fill and 1 - self.spell.v1 or self.spell.v1))
		self:GetParent().parent:MoveSpark(self.bar)
		if self:GetParent().parent.ui.bar.use_full_color then 
			if self.bar:GetValue() == 1 then
				self.bar:SetStatusBarColor(unpack(self:GetParent().parent.ui.bar.full_color))
			else
				self.bar:SetStatusBarColor(unpack(self:GetParent().parent.ui.bar.color))
			end
		end
	end
end

function HDH_COMBO_POINT_TRACKER:CreateData()
	local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
	local trackerId = self.id
	local id = 0
	local key
	local name
	local texture = self.POWER_INFO[self.type].texture;
	local display = DB.SPELL_ALWAYS_DISPLAY
	local isValue = HDH_TRACKER.TYPE.POWER_SOUL_SHARDS == self.type
	local isItem = false
	local isFirstCreated = false
	for elemIdx = 1, power_max do
		if not self:IsHaveData(elemIdx) then
			key = self.POWER_INFO[self.type].power_type .. elemIdx
			name = self.POWER_INFO[self.type].power_type .. elemIdx
			DB:SetTrackerElement(trackerId, elemIdx, key, id, name, texture, display, isValue, isItem)
			DB:SetReadOnlyTrackerElement(trackerId, elemIdx) -- 사용자가 삭제하지 못하도록 수정 잠금을 건다
			if elemIdx == 1 then
				isFirstCreated = true
			end
		end
	end 

	if isFirstCreated then
		DB:CopyGlobelToTracker(trackerId)
		DB:SetTrackerValue(trackerId, 'ui.%s.common.display_mode', DB.DISPLAY_ICON)
		DB:SetTrackerValue(trackerId, 'ui.%s.common.column_count', 10)
		DB:SetTrackerValue(trackerId, 'ui.%s.common.reverse_h', false)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.width', 40)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.height', 20)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.to_fill', true)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.cooldown_progress', DB.COOLDOWN_RIGHT)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.location', DB.BAR_LOCATION_R)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.texture', 3)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', self.POWER_INFO[self.type].color)
		DB:SetTrackerValue(trackerId, 'ui.%s.bar.show_spark', true)
		DB:SetTrackerValue(trackerId, 'ui.%s.font.name_location', DB.FONT_LOCATION_HIDE)
		DB:SetTrackerValue(trackerId, 'ui.%s.font.count_location', DB.FONT_LOCATION_HIDE)
		DB:SetTrackerValue(trackerId, 'ui.%s.icon.size', 40)
		DB:SetTrackerValue(trackerId, 'ui.%s.icon.active_border_color', self.POWER_INFO[self.type].color)

		if HDH_TRACKER.TYPE.POWER_SOUL_SHARDS == self.type then
			DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_BAR_R)
			DB:SetTrackerValue(trackerId, 'ui.%s.icon.cooldown', DB.COOLDOWN_RIGHT)
			DB:SetTrackerValue(trackerId, 'ui.%s.bar.use_full_color', true)
			local r,g,b = unpack(self.POWER_INFO[self.type].color)
			DB:SetTrackerValue(trackerId, 'ui.%s.bar.color', {r,g,b, 0.35})
			DB:SetTrackerValue(trackerId, 'ui.%s.bar.full_color', self.POWER_INFO[self.type].color)
		else
			DB:SetTrackerValue(trackerId, 'ui.%s.font.v1_location', DB.FONT_LOCATION_C)
		end
		self:UpdateSetting();
	end
end

function HDH_COMBO_POINT_TRACKER:IsHaveData(index)
	if index then
		local key = DB:GetTrackerElement(self.id, index)
		if (self.POWER_INFO[self.type].power_type .. index) ~= key then
			return false
		end
	else
		for i = 1 , UnitPowerMax('player', self.POWER_INFO[self.type].power_index) do
			local key = DB:GetTrackerElement(self.id, i)
			if (self.POWER_INFO[self.type].power_type .. i) ~= key then
				return false
			end
		end 
	end
	
	return true
end

function HDH_COMBO_POINT_TRACKER:Release() -- HDH_TRACKER override
	if self and self.frame then
		self.frame:UnregisterAllEvents()
	end
	super.Release(self)
end

function HDH_COMBO_POINT_TRACKER:ReleaseIcon(idx) -- HDH_TRACKER override
	local icon = self.frame.icon[idx]
	--icon:SetScript("OnEvent", nil)
	icon:Hide()
	icon:SetParent(nil)
	icon.spell = nil
	self.frame.icon[idx] = nil
end

function HDH_COMBO_POINT_TRACKER:CreateDummySpell(count)
	local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
	for i = 1, power_max do
		iconf = self.frame.icon[i]
		if iconf then 
			if not iconf.spell then
				iconf.spell = {}
			end
			iconf:SetParent(self.frame) 
			iconf.spell.duration = 0
			iconf.spell.count = 0
			iconf.spell.remaining = 0
			iconf.spell.startTime = 0
			iconf.spell.endTime = 0
			iconf.spell.key = i
			iconf.spell.id = 0
			iconf.spell.happenTime = 0;
			iconf.spell.no = 1
			iconf.spell.name = self.POWER_INFO[self.type].power_type .. i
			iconf.spell.icon = self.POWER_INFO[self.type].texture
			iconf.spell.glow = false
			iconf.spell.glowCount = 0
			iconf.spell.glowV1= 0
			iconf.spell.display = DB.SPELL_ALWAYS_DISPLAY
			iconf.spell.showValue = true;
			iconf.icon:SetTexture(self.POWER_INFO[self.type].texture);
			
			iconf.spell.v1 = power_max;	
			if (power_max) == i then
				iconf.icon:SetAlpha(self.ui.icon.off_alpha);
				iconf.spell.isUpdate = false;
			else
				iconf.spell.isUpdate = true;
				iconf.icon:SetAlpha(self.ui.icon.on_alpha);
			end
		end
	end
	return power_max;
end

function HDH_COMBO_POINT_TRACKER:ChangeCooldownType(f, cooldown_type)
	local spark_size = f.iconframe:GetWidth() 
	if cooldown_type == DB.COOLDOWN_UP then 
		f.cooldown2:Hide()
		f.iconSatCooldown:ClearAllPoints()
		f.iconSatCooldown:SetPoint("BOTTOMLEFT", f.iconframe,"BOTTOMLEFT",0,0)
		f.iconSatCooldown:SetPoint("BOTTOMRIGHT", f.iconframe,"BOTTOMRIGHT",0,0)
		f.iconSatCooldown:SetHeight(self.ui.icon.size)
		f.iconSatCooldown.spark:SetSize(spark_size, 7);
		f.iconSatCooldown.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v");
		f.iconSatCooldown.spark:SetPoint("CENTER", f.iconSatCooldown,"TOP",0,0)
		f.iconSatCooldown.spark:SetVertexColor(unpack(self.ui.icon.spark_color or {1,1,1,1}))

	elseif cooldown_type == DB.COOLDOWN_DOWN  then 
		f.cooldown2:Hide()
		f.iconSatCooldown:ClearAllPoints()
		f.iconSatCooldown:SetPoint("TOPLEFT", f.iconframe,"TOPLEFT",0,0)
		f.iconSatCooldown:SetPoint("TOPRIGHT", f.iconframe,"TOPRIGHT",0,0)
		f.iconSatCooldown:SetHeight(self.ui.icon.size)
		f.iconSatCooldown.spark:SetSize(spark_size, 7);
		f.iconSatCooldown.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark_v");
		f.iconSatCooldown.spark:SetPoint("CENTER", f.iconSatCooldown,"BOTTOM",0,0)
		f.iconSatCooldown.spark:SetVertexColor(unpack(self.ui.icon.spark_color or {1,1,1,1}))

	elseif cooldown_type == DB.COOLDOWN_LEFT  then 
		f.cooldown2:Hide()
		f.iconSatCooldown:ClearAllPoints()
		f.iconSatCooldown:SetPoint("TOPRIGHT", f.iconframe,"TOPRIGHT",0,0)
		f.iconSatCooldown:SetPoint("BOTTOMRIGHT", f.iconframe,"BOTTOMRIGHT",0,0)
		f.iconSatCooldown:SetWidth(self.ui.icon.size)
		f.iconSatCooldown.spark:SetSize(7, spark_size);
		f.iconSatCooldown.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark");
		f.iconSatCooldown.spark:SetPoint("CENTER", f.iconSatCooldown,"LEFT",0,0)
		f.iconSatCooldown.spark:SetVertexColor(unpack(self.ui.icon.spark_color or {1,1,1,1}))

	elseif cooldown_type == DB.COOLDOWN_RIGHT then 
		f.cooldown2:Hide()
		f.iconSatCooldown:ClearAllPoints()
		f.iconSatCooldown:SetPoint("TOPLEFT", f.iconframe,"TOPLEFT",0,0)
		f.iconSatCooldown:SetPoint("BOTTOMLEFT", f.iconframe,"BOTTOMLEFT",0,0)
		f.iconSatCooldown:SetWidth(self.ui.icon.size)
		f.iconSatCooldown.spark:SetSize(7, spark_size);
		f.iconSatCooldown.spark:SetTexture("Interface/AddOns/HDH_AuraTracker/Texture/UI-CastingBar-Spark");
		f.iconSatCooldown.spark:SetPoint("CENTER", f.iconSatCooldown,"RIGHT",0,0)
		f.iconSatCooldown.spark:SetVertexColor(unpack(self.ui.icon.spark_color or {1,1,1,1}))

	else 
		f.cd = f.cooldown2
		f.cd:SetReverse(false)
		f.cooldown1:Hide()
		f.iconSatCooldown:Hide()
		f.iconSatCooldown.spark:Hide()
		f.iconSatCooldown:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		f.iconSatCooldown:SetSize(f.icon:GetSize())
	end
end

function HDH_COMBO_POINT_TRACKER:UpdateArtBar(f) -- HDH_TRACKER override
	super.UpdateArtBar(self,f)
	if f.bar then
		f.bar:SetScript("OnUpdate",nil);
	end
end

function HDH_COMBO_POINT_TRACKER:UpdateIcons()  -- HDH_TRACKER override
	local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
	local line = self.ui.common.column_count or 10-- 한줄에 몇개의 아이콘 표시
	local reverse_v = self.ui.common.reverse_v -- 상하반전
	local reverse_h = self.ui.common.reverse_h -- 좌우반전
	local margin_h = self.ui.common.margin_h
	local margin_v = self.ui.common.margin_v
	local icons = self.frame.icon
	local i = 0 -- 몇번째로 아이콘을 출력했는가?
	local col = 0  -- 열에 대한 위치 좌표값 = x
	local row = 0  -- 행에 대한 위치 좌표값 = y
	local to_fill = self.ui.bar.to_fill
	local value

	local size_w, size_h

	if self.ui.common.display_mode == DB.DISPLAY_BAR then
		size_w = self.ui.bar.width
		size_h = self.ui.bar.height
	elseif self.ui.common.display_mode == DB.DISPLAY_ICON_AND_BAR then
		if self.ui.bar.location == DB.BAR_LOCATION_R or self.ui.bar.location == DB.BAR_LOCATION_L then
			size_w = self.ui.bar.width + self.ui.icon.size
			size_h = max(self.ui.bar.height, self.ui.icon.size)
		else
			size_h = self.ui.bar.height + self.ui.icon.size
			size_w = max(self.ui.bar.width, self.ui.icon.size)
		end
		
	else
		size_w = self.ui.icon.size -- 아이콘 간격 띄우는 기본값
		size_h = self.ui.icon.size
	end
	
	for k,f in ipairs(icons) do
		if not f.spell then break end
		f.counttext:SetText(nil)
		if f.spell.isUpdate then
			f.spell.isUpdate = false

			if HDH_TRACKER.TYPE.POWER_SOUL_SHARDS ~= self.type and HDH_TRACKER.TYPE.POWER_ESSENCE ~= self.type then
				f.icon:SetDesaturated(nil)
				f.icon:SetAlpha(self.ui.icon.on_alpha)
				f.border:SetAlpha(self.ui.icon.on_alpha)
				f.border:SetVertexColor(unpack(self.ui.icon.active_border_color)) 

				if f.spell.showValue and f.spell.v1 < 1 then
					f.v1:SetText(string.format('%.1f', f.spell.v1))
					f.v1:Show()
				else
					f.v1:SetText("")
				end

				if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
					f.bar:SetMinMaxValues(0,1);
					f.bar:SetValue((to_fill and 1) or 0)
				end

				if f.spell.count < 1 then f.counttext:SetText(nil)
				else f.counttext:SetText(f.spell.count) end
				f.cd:Hide()
				self:SetGlow(f, true)
			else
				if f.spell.v1 < 1.0 then
					if f.spell.showValue and f.spell.v1 < 1 then
						f.v1:SetText(string.format('%.1f', f.spell.v1))
					else
						f.v1:SetText("")
					end

					if self.ui.common.display_mode ~= DB.DISPLAY_BAR then
						f.icon:SetDesaturated(1)
						f.icon:SetAlpha(self.ui.icon.off_alpha)
						f.iconSatCooldown:SetAlpha(self.ui.icon.on_alpha)
						f.border:SetAlpha(self.ui.icon.off_alpha)
						f.border:SetVertexColor(0,0,0) 
						
						if f.spell.v1 > 0 then
							f.iconSatCooldown:Show()
							f.iconSatCooldown.spark:Show()

							f.iconSatCooldown.curSize = math.ceil(f.icon:GetHeight() * f.spell.v1 * 1000) /1000
							if self.ui.icon.cooldown == DB.COOLDOWN_LEFT then
								f.spell.texcoord = 0.93 - (0.86 * f.spell.v1)
								f.iconSatCooldown:SetWidth(f.iconSatCooldown.curSize)
								f.iconSatCooldown:SetTexCoord(f.spell.texcoord, 0.93, 0.07, 0.93)
					
							elseif self.ui.icon.cooldown == DB.COOLDOWN_RIGHT then
								f.spell.texcoord = 0.07 + (0.86 * f.spell.v1)
								f.iconSatCooldown:SetWidth(f.iconSatCooldown.curSize)
								f.iconSatCooldown:SetTexCoord(0.07, f.spell.texcoord, 0.07, 0.93)
					
							elseif self.ui.icon.cooldown == DB.COOLDOWN_UP then
								f.spell.texcoord = 0.93 - (0.86 * f.spell.v1)
								f.iconSatCooldown:SetHeight(f.iconSatCooldown.curSize)
								f.iconSatCooldown:SetTexCoord(0.07, 0.93, f.spell.texcoord, 0.93)

							elseif self.ui.icon.cooldown == DB.COOLDOWN_DOWN then
								f.spell.texcoord = 0.07 + (0.86 * f.spell.v1)
								f.iconSatCooldown:SetHeight(f.iconSatCooldown.curSize)
								f.iconSatCooldown:SetTexCoord(0.07, 0.93, 0.07, f.spell.texcoord)
							else
								if self.type == HDH_TRACKER.TYPE.POWER_ESSENCE then
									f.iconSatCooldown:Hide()
									f.iconSatCooldown.spark:Hide()
									f.icon:SetDesaturated(nil)

									if not f.cd:IsShown() then
										f.cd:Show()
									end
									
									f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
								else
									f.iconSatCooldown:SetHeight(f.icon:GetHeight())
									f.iconSatCooldown:SetWidth(f.icon:GetWidth())
									f.iconSatCooldown:Hide()
									f.iconSatCooldown.spark:Hide()
								end
							end
						else
							f.iconSatCooldown:Hide()
							f.iconSatCooldown.spark:Hide()
							f.cd:Hide()
						end
					end

					if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
						f.bar:SetMinMaxValues(0, 1)
						value = self:GetAnimatedValue(f.bar, to_fill and f.spell.v1 or (1 - f.spell.v1))
						f.bar:SetValue(value)
						f.bar.spark:Show()
					end
				else
					if f.spell.showValue and f.spell.v1 < 1 then
						f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(f.spell.v1, self.ui.font.v1_abbreviate))
					else
						f.v1:SetText("")
					end
					f.icon:SetDesaturated(nil)
					f.icon:SetAlpha(self.ui.icon.on_alpha)
					f.iconSatCooldown:Hide()
					f.iconSatCooldown.spark:Hide()
					f.border:SetAlpha(self.ui.icon.on_alpha)
					f.border:SetVertexColor(unpack(self.ui.icon.active_border_color)) 
					self:SetGlow(f, true)

					if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
						f.bar:SetMinMaxValues(0,1);
						f.bar:SetValue((to_fill and 1) or 0)
						f.bar.spark:Hide()
					end
					f.cd:Hide()
				end

				if f.spell.count < 1 then f.counttext:SetText(nil)
				else f.counttext:SetText(f.spell.count) end
			end
			
			f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
			
			f:Show()

			i = i + 1
			if i % line == 0 then 
				row = row + size_h + margin_v; 
				col = 0
			else 
				col = col + size_w + margin_h 
			end

			ret = ret + 1

		else
			if k <= UnitPowerMax('player', self.POWER_INFO[self.type].power_index) then 
				if f.spell.display == DB.SPELL_ALWAYS_DISPLAY then 
					if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1) end
					f.icon:SetAlpha(self.ui.icon.off_alpha)
					-- f.iconSatCooldown:SetAlpha(self.ui.icon.on_alpha)
					f.iconSatCooldown:Hide()
					f.iconSatCooldown.spark:Hide()
					f.border:SetAlpha(self.ui.icon.off_alpha)
					f.border:SetVertexColor(0,0,0)
					f.v1:SetText("")
					self:SetGlow(f, false)
					f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', reverse_h and -col or col, reverse_v and row or -row)
					if f.cd:IsShown() then
						f.cd:Hide()
					end
					f:Show()
					if self.ui.common.display_mode ~= DB.DISPLAY_ICON and f.bar then
						f.bar:SetMinMaxValues(0,1);
						f.bar.spark:Hide()
					end

					i = i + 1
					if i % line == 0 then 
						row = row + size_h + margin_v; 
						col = 0
					else 
						col = col + size_w + margin_h 
					end
				else
					if f.spell.display == DB.SPELL_HIDE_AS_SPACE and self.ui.common.order_by == DB.ORDERBY_REG then
						i = i + 1
						if i % column_count == 0 then 
							row = row + size_h + margin_v
							col = 0
						else 
							col = col + size_w + margin_h
						end
					end
					f:Hide();
				end
			else
				self:ReleaseIcon(k);
			end
		end
	end
	return ret
end

function HDH_COMBO_POINT_TRACKER:Update() -- HDH_TRACKER override
	if not self.frame or not self.frame.icon or HDH_TRACKER.ENABLE_MOVE then return end
	-- local auraList = DB_AURA.Talent[self:GetSpec()][self.name]
	-- if not auraList or #auraList == 0 then return end
	local iconf;
	local spell;
	local ret = 0;
	
	local power = UnitPower('player', self.POWER_INFO[self.type].power_index, true);
	local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index);

	if HDH_TRACKER.TYPE.POWER_SOUL_SHARDS == self.type then
		power = power / 10
	end
		
	for i = 1, power_max do
		iconf = self.frame.icon[i]
		if iconf then 
			if not iconf.spell then
				iconf.spell = {}
			end
			if math.ceil(power) >= i then
				iconf.spell.isUpdate = true
				if (power + 1 - i) < 1 then
					iconf.spell.v1 = power + 1 - i 
				else
					iconf.spell.v1 = 1
					iconf.spell.count = i
				end
			else
				iconf.spell.isUpdate = false
				iconf.spell.v1 = 0
				iconf.spell.count = 0
			end
			ret = ret + 1
		end
	end
	self:UpdateIcons();

	if (not (self.ui.common.hide_in_raid == true and IsInRaid())) 
			and (UnitAffectingCombat("player") or power > 0 or self.ui.common.always_show) then
		self:ShowTracker();
	else
		self:HideTracker();
	end
	return ret;
end

function HDH_COMBO_POINT_TRACKER:InitIcons() -- HDH_TRACKER override
	-- if HDH_TRACKER.ENABLE_MOVE then return end
	local ret = 0
	local power_max = UnitPowerMax('player', self.POWER_INFO[self.type].power_index)
	local elemKey, elemId, elemName, texture, display, glowType, isValue, isItem, glowCondition, glowValue
	local trackerId = self.id
	
	if not self:IsHaveData() then
		self:CreateData()
	end
	for i = 1, power_max do
		elemKey, elemId, elemName, texture, display, glowType, isValue, isItem = DB:GetTrackerElement(trackerId, i)
		glowType, glowCondition, glowValue = DB:GetTrackerElementGlow(trackerId, i)
		f = self.frame.icon[i]
		spell = {}
		spell.glow = glowType
		spell.glowCondtion = glowCondition
		spell.glowValue = (glowValue and tonumber(glowValue)) or 0
		spell.per = 0
		spell.showValue = isValue
		spell.display = display
		spell.v1 = 0 -- 수치를 저장할 변수
		spell.aniEnable = true;
		spell.aniTime = 8;
		spell.aniOverSec = false;
		spell.no = i
		spell.name = elemName
		spell.icon = texture
		spell.power_index = self.POWER_INFO[self.type].power_index
		spell.id = tonumber(elemId)
		spell.count = 0
		spell.duration = 0
		spell.remaining = 0
		spell.overlay = 0
		spell.endTime = 0
		spell.happenTime = 0;
		spell.startTime = 0;
		spell.is_buff = false;
		spell.isUpdate = false
		spell.isItem =  isItem
		f.spell = spell
		f.icon:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")
		f.iconSatCooldown:SetTexture(texture or "Interface/ICONS/INV_Misc_QuestionMark")

		f:SetScript("OnUpdate", OnUpdateBar)
		self:SetGlow(f, false)
		f.spell = spell;
		f:Hide();
	end

	self.frame:SetScript("OnEvent", self.OnEvent)
	self.frame:RegisterUnitEvent('UNIT_POWER_UPDATE',"player")
	self.frame:RegisterUnitEvent('UNIT_MAXPOWER',"player")

	for i = power_max+1, #self.frame.icon do
		self:ReleaseIcon(i)
	end
	
	self:Update()
	return power_max
end

function HDH_COMBO_POINT_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
	self:InitIcons()
end

function HDH_COMBO_POINT_TRACKER:PLAYER_ENTERING_WORLD()
	if  UnitAffectingCombat("player") then
		self:Update()
	end
end

function HDH_COMBO_POINT_TRACKER:OnEvent(event, unit, powerType)
	if self == nil or self.parent == nil then return end
	if (event == "UNIT_POWER_UPDATE" ) and (self.parent.POWER_INFO[self.parent.type].power_type == powerType) then 
		if not HDH_TRACKER.ENABLE_MOVE then
			self.parent:Update()
		end
	elseif (event == 'UNIT_MAXPOWER') and (self.parent.POWER_INFO[self.parent.type].power_type == powerType) then
		if not HDH_TRACKER.ENABLE_MOVE then
			self.parent:InitIcons()
		end
	end	
end
------------------------------------
-- HDH_COMBO_POINT_TRACKER class
------------------------------------

