
local ENT = {};

ENT.CHKMInputs = {"INPUT SENSOR: View"};


if (SERVER) then

function ENT:CheckInputs(ip, on)
	local ent, op, _ = CHECKEM.GetSENTInput(self, 1);
	if (ent:GetClass() != "ce_sensor_input" || op != 10) then return; end
	if (on) then
		local ply = ent.WeldedTo:GetDriver();
		ply:SetViewEntity(self);
		ply.UsingCamera = self;
		self.UsingPlayer = ply;
	else
		if (IsValid(self.UsingPlayer)) then
			local ply = self.UsingPlayer;
			ply:SetViewEntity(ply);
			ply.UsingCamera = nil;
			self.UsingPlayer = nil;
		end
	end	
end

end


CHECKEM.RegisterGModEnt("gmod_cameraprop", ENT);
