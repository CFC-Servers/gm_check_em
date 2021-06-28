
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(6);
end


function ENT:Think()
	if (self:GetVariable("Cnst") && self:GetInputOn(1) && IsValid(self.WeldedTo)) then
		local p, y, r = self:GetVariable("P"), self:GetVariable("Y"), self:GetVariable("R");
		self.WeldedTo:SetAngles(Angle(p, y, r));
	end
	self:NextThink(CurTime());
	return true;
end	


function ENT:ModifyOn(ent)
    self:SetSkin(7);
    local p, y, r = self:GetVariable("P"), self:GetVariable("Y"), self:GetVariable("R");
    if (!self:GetVariable("Cnst")) then
		ent:SetAngles(Angle(p, y, r));
	end
	if (ent:GetPhysicsObject():IsValid()) then ent:GetPhysicsObject():SetAngleVelocity(Vector(0, 0, 0)); end
end

function ENT:ModifyOff(ent)
    self:SetSkin(6);
end
