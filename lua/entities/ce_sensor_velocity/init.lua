
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Sense()
	local speed = self:GetVariable("Speed");
	local vel = self:GetVelocity();

	if (IsValid(self.WeldedTo)) then
		vel = self.WeldedTo:GetVelocity();
	end
	
	local xy = self:GetVariable("Hor");
	local z = self:GetVariable("Vert");

	self.LastChange = (self.LastChange || 0);

	if (CurTime() >= self.LastChange) then //delay it a tad just so it doesn't spaz off and on if it wobbles around the threshold (like slow moving wheeled vehicles)
		self.LastChange = (CurTime() + .1);
		if (!xy) then vel.x = 0; vel.y = 0; end
		if (!z) then vel.z = 0; end

		if (vel:Length() >= speed) then
			if (!self:GetOutputOn(1)) then self:ChangeOPState(1, true, true); self:SetSkin(13); end
		else
			if (self:GetOutputOn(1)) then self:ChangeOPState(1, false, true); self:SetSkin(12); end
		end
	end
end
