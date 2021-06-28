ENT.Type 			= "anim";
ENT.Base 			= "ce_constraint_control";
ENT.PrintName		= "Check 'em Constraint Winch";
ENT.Author			= "Aska";
ENT.Purpose			= "Controls GMod winches for hooking into Check 'em";

ENT.Spawnable			= false;
ENT.AdminSpawnable		= false;

ENT.CHKMInputs = {"Extend", "Retract"};

if (SERVER) then

AddCSLuaFile("shared.lua");

function ENT:CheckInputs(ip, on)
	if (ip == 1) then
		if (on) then
			self:SetDirection(1);
		else
			if (CHECKEM.GetSENTInputOn(self, 2)) then
				self:SetDirection(-1);
			else
				self:SetDirection(0);
			end
		end
	else
		if (on) then
			self:SetDirection(-1);
		else
			if (CHECKEM.GetSENTInputOn(self, 1)) then
				self:SetDirection(1);
			else
				self:SetDirection(0);
			end
		end
	end
end

end


CHECKEM.RegisterGModEnt("ce_constraint_winch", ENT);
