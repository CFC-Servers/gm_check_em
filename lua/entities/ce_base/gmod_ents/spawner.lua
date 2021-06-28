

local ENT = {};

ENT.CHKMInputs = {"Spawn"};


if (SERVER) then

function ENT:CheckInputs(ip, on)
	if (on) then
		self:DoSpawn(self.Player);
	end
end

end


CHECKEM.RegisterGModEnt("gmod_spawner", ENT);

