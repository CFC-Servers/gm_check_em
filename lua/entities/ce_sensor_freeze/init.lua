
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Sense()
	local ent = self.WeldedTo;
	if (IsValid(ent)) then
		local phys = ent:GetPhysicsObject();
		if (phys:IsValid()) then
			if (!self:GetOutputOn(1) && !phys:IsMotionEnabled()) then self:ChangeOPState(1, true, true); self:SetSkin(19); end
			if (self:GetOutputOn(1) && phys:IsMotionEnabled()) then self:ChangeOPState(1, false, true); self:SetSkin(18); end
		end
	end
end
