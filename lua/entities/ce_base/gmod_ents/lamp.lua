

local ENT = {};

ENT.CHKMInputs = {"On/Off"};


if (SERVER) then

function ENT:CheckInputs(ip, on)
	if (self:GetOn() != on) then
		self:Toggle();
	end
	self:SetOn(on);
end

end


CHECKEM.RegisterGModEnt("gmod_lamp", ENT);
