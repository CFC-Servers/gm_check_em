
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(12);
	self.OldVel = nil;
	self.OldRot = nil;
	self.DoSlow = 0;
end


function ENT:ModifyOn(ent)
    self:SetSkin(13);

    local tm = self:GetVariable("Time");
	
	local phys = ent:GetPhysicsObject();
	if (phys:IsValid()) then
		self.OldVel = phys:GetVelocity();
		self.OldRot = phys:GetAngleVelocity();
		if (tm <= 0) then
			phys:EnableMotion(false);
		else
			self.DoWhen = CurTime();
			self.DoSlow = (CurTime() + tm);
		end
	end
end

function ENT:ModifyOff(ent)
    self:SetSkin(12);
    self.DoSlow = 0;
    if (self:GetVariable("DoOff")) then
	    local phys = ent:GetPhysicsObject();
		if (phys:IsValid()) then
			phys:EnableMotion(true);
			phys:ApplyForceCenter(Vector(0, 0, 0));
			if (self:GetVariable("Vel") && self.OldVel != nil && self.OldRot != nil) then
				phys:AddVelocity(self.OldVel);
				phys:AddAngleVelocity(self.OldRot);
				self.OldVel = nil;
				self.OldRot = nil;
			end
		end
	end
end

function ENT:Think()
	self.BaseClass.Think(self);

	if (!self:GetInputOn(1) || self.DoSlow == 0 || self:GetVariable("Time") <= 0) then return; end
	local ent = self.WeldedTo;
	if (!IsValid(ent)) then return; end
	local phys = ent:GetPhysicsObject();
	if (!phys:IsValid()) then return; end

	if (CurTime() <= self.DoSlow) then
		local dur, cur = (self.DoSlow - self.DoWhen), (self.DoSlow - CurTime());
		local new = (cur / dur);

		phys:SetVelocityInstantaneous(self.OldVel * new);
		phys:AddAngleVelocity((phys:GetAngleVelocity() * -1) + (self.OldRot * new));

	else
		phys:EnableMotion(false);
		self.DoSlow = 0;
	end

	self:NextThink(CurTime());
	return true;
end
