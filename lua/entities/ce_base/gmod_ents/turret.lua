
local ENT = {};

ENT.CHKMInputs = {"Shoot"};


function ENT:DoOnCreate()
	if (SERVER) then self.oldToggle = self:GetToggle(); end	
end

function ENT:InputRemoved(ip)
	if (SERVER) then CHECKEM.UpdateIPState(self, ip, 0); self:SetToggle(self.oldToggle); end
end


if (SERVER) then

function ENT:CheckInputs(ip, on)
	if (self:GetToggle()) then self:SetToggle(false); end
	self:SetOn(on);
end

end


CHECKEM.RegisterGModEnt("gmod_turret", ENT);
