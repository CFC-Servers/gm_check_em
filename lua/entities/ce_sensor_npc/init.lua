
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Sense()
	local cube = self:GetVariable("Cube");
	local min = self:GetVariable("NumNPC");
	local on = self:GetOutputOn(1);
	
	local pos = self:GetPos();
	local rad = self:GetVariable("SRad");
	local x, y, z = self:GetVariable("X"), self:GetVariable("Y"), self:GetVariable("Z");
	local tbl = (cube && ents.FindInBox((pos - Vector(x, y, z)), pos + Vector(x, y, z))) || ents.FindInSphere(pos, rad);

	local num = 0;
	for k, v in pairs(tbl) do
		if (IsValid(v) && v:IsNPC() && v:Health() > 0) then
			num = (num + 1);
		end
	end
	if (num >= min) then
		if (!on) then self:ChangeOPState(1, true, true); self:SetSkin(15); end
	else
		if (on) then self:ChangeOPState(1, false, true); self:SetSkin(14); end
	end
end
