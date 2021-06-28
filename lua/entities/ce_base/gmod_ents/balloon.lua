
local ENT = {};

ENT.CHKMInputs = {"Pop"};


if (SERVER) then

function ENT:CheckInputs(ip, on)
	if (on) then
		timer.Simple(0, function()
			self:TakeDamage(self, 1);
		end); //wont pop without the timer..?
	end
end

end


CHECKEM.RegisterGModEnt("gmod_balloon", ENT);
