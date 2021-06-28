

local ENT = {};

ENT.CHKMInputs = {"On/Off"};


if (SERVER) then

function ENT:CheckInputs(ip, on)
	self:SetOn(on);
end

end


CHECKEM.RegisterGModEnt("gmod_light", ENT);
