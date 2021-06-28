
local ENT = {};

ENT.CHKMInputs = {"Explode"};


if (SERVER) then

function ENT:CheckInputs(ip, on)
	if (on) then
		self:Explode(0, self);
	end
end

end


CHECKEM.RegisterGModEnt("gmod_dynamite", ENT);
