
local ENT = {};

ENT.CHKMInputs = {"Forward", "Backward"};


function ENT:DoOnCreate()
	if (SERVER) then self.oldToggle = self:GetToggle(); end	
end

function ENT:InputRemoved(ip)
	if (SERVER) then CHECKEM.UpdateIPState(self, ip, 0); end

	local b = true;
	for i = 1, 2 do
		local e, op, on = CHECKEM.GetSENTInput(self, i);
		if (IsValid(e)) then b = false; end
	end
	if (b) then self:SetToggle(self.oldToggle); end
end


if (SERVER) then

function ENT:CheckInputs(ip, on)
	if (self:GetToggle()) then self:SetToggle(false); end
	
	if (ip == 1) then
		if (on) then self:SetForce(self.force, 1); self:Switch(true); return; end

		if (!CHECKEM.GetSENTInputOn(self, 2)) then
			self:Switch(false);
		else
			self:SetForce(self.force, -1);
		end
	else
		if (on) then self:SetForce(self.force, -1); self:Switch(true); return; end

		if (!CHECKEM.GetSENTInputOn(self, 1)) then
			self:Switch(false);
		else
			self:SetForce(self.force, 1);
		end
	end

end

end


CHECKEM.RegisterGModEnt("gmod_thruster", ENT);
