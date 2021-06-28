ENT.Type 			= "anim";
ENT.Base 			= "ce_constraint_control";
ENT.PrintName		= "Check 'em Constraint Hydraulic";
ENT.Author			= "Aska";
ENT.Purpose			= "Controls GMod hydraulics for hooking into Check 'em";

ENT.Spawnable			= false;
ENT.AdminSpawnable		= false;


if (SERVER) then
	AddCSLuaFile("shared.lua");
end

ENT.CHKMInputs = {"Extend"};


if (SERVER) then

function ENT:CheckInputs(ip, on)
	self:SetDirection((on && 1) || -1);
end

end


CHECKEM.RegisterGModEnt("ce_constraint_hydraulic", ENT);
