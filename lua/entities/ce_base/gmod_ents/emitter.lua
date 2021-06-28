
local ENT = {};

ENT.CHKMInputs = {"Emit"};


function ENT:DoOnCreate()
	self.oldToggle = self:GetToggle();
end

function ENT:InputRemoved(ip)
	self:SetToggle(self.oldToggle);
	self:SetOn(false);
end


if (SERVER) then

function ENT:CheckInputs(ip, on)
	if (self:GetToggle()) then self:SetToggle(false); end
	self:SetOn(on);
end

end


CHECKEM.RegisterGModEnt("gmod_emitter", ENT);
