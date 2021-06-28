
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Sense()
	local chiponly = self:GetVariable("ChipOnly");
	local water = self:WaterLevel();
	if (water > 0 || (!chiponly && IsValid(self.WeldedTo) && self.WeldedTo:WaterLevel() > 0)) then
		if (!self:GetOutputOn(1)) then self:ChangeOPState(1, true, true); self:SetSkin(7); end
	else
		if (self:GetOutputOn(1)) then self:ChangeOPState(1, false, true); self:SetSkin(6); end
	end
end
