if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local UnitPower = UnitPower


local cpr = LibStub("AceAddon-3.0"):GetAddon("ComboPointsRedux")
local modName = "Festering Wounds"
local mod = cpr:NewModule(modName)

function mod:OnInitialize()
	self.MAX_POINTS = 8
	local _,_,_,FWstacks = UnitDebuff("target", "Festering Wound", nil, "PLAYER")
	self.Count =  FWstacks or 0
	self.displayName = "Festering Wounds"
	self.abbrev = "FW"
	self.events = { ["UNIT_AURA"] = "Update", ["PLAYER_SPECIALIZATION_CHANGED"] = "UpdateMaxPoints", ["PLAYER_LOGIN"] = "Update" }
end

local oldCount = 0
function mod:Update()
	print("update running")
	local _,_,_,FWstacks = UnitDebuff("target", "Festering Wound", nil, "PLAYER")
	self.Count =  FWstacks or 0
	local r, g, b = cpr:GetColorByPoints(modName, self.Count)
	local a, a2 = cpr:GetAlphas(modName)
	
	if self.Count > 0 then
		if self.graphics then
			for i = self.Count, 1, -1 do
				self.graphics.points[i].icon:SetVertexColor(r, g, b)
				self.graphics.points[i]:SetAlpha(a)
				self.graphics.points[i]:Show()
			end
			for j = self.MAX_POINTS, self.Count+1, -1 do
				self.graphics.points[j].icon:SetVertexColor(r, g, b)
				self.graphics.points[j]:SetAlpha(a2)
				self.graphics.points[j]:Show()
			end
		end
		
		--should prevent spamming issues when UNIT_AURA fires and
		--the aura we care about hasn't changed
		if oldCount ~= self.Count then
			oldCount = self.Count
			cpr:DoFlash(modName, self.Count)
		end
	else
		if self.graphics then
			for i = 1, self.MAX_POINTS do
				self.graphics.points[i].icon:SetVertexColor(r, g, b)
				self.graphics.points[i]:SetAlpha(a2)
				self.graphics.points[i]:Show()
			end
		end
		
		oldCount = 0
	end
    
    if self.text then self.text:SetNumPoints(cpr:GetTextValue(modName, self.Count)) end
end

function mod:UpdateMaxPoints()
	local _,_,_,FWstacks = UnitDebuff("target", "Festering Wound", nil, "PLAYER")
	self.Count =  FWstacks or 0
	local a, a2 = cpr:GetAlphas(modName)
	
	if GetSpecialization() == 3 then
		self.MAX_POINTS = 8
	else
		self.MAX_POINTS = 0
	end
	if self.graphics then
		for i = 1, 8 do
			self.graphics.points[i]:Hide()
			self.graphics.points[i]:SetAlpha(a2)
		end
		if self.MAX_POINTS > 0 then
			for i = 1, self.MAX_POINTS do
				self.graphics.points[i]:Show()
			end
			if self.Count > 0 then
				for i = 1, self.Count do
					self.graphics.points[i]:SetAlpha(a)
				end
			end
		end
	end
	cpr:UpdateSettings(modName)
end
