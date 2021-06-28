
local ENT = {};

ENT.CHKMInputs = {"Up", "Down"};

function ENT:InputRemoved(ip)
	if (SERVER) then CHECKEM.UpdateIPState(self, ip, 0); end
end


if (SERVER) then

function ENT:CheckInputs(ip, on)
	if (ip == 1) then
		if (on) then self:SetZVelocity(1); return; end

		if (!CHECKEM.GetSENTInputOn(self, 2)) then
			self:SetZVelocity(0);
		else
			self:SetZVelocity(-1);
		end
	else
		if (on) then self:SetZVelocity(-1); return; end

		if (!CHECKEM.GetSENTInputOn(self, 1)) then
			self:SetZVelocity(0);
		else
			self:SetZVelocity(1);
		end
	end
end

end


CHECKEM.RegisterGModEnt("gmod_hoverball", ENT);
