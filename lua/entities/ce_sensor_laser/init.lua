
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Sense()
	local dis = self:GetVariable("Dis");
	local world = self:GetVariable("World");
	local on = self:GetOutputOn(1);
	
	local tr = util.QuickTrace(self:GetPos(), (self:GetUp() * dis), self);
	
	if (IsValid(tr.Entity) || (world && tr.HitWorld)) then
		if (!on) then self:ChangeOPState(1, true, true); self:SetSkin(17); end
	else
		if (on) then self:ChangeOPState(1, false, true); self:SetSkin(16); end
	end
end
