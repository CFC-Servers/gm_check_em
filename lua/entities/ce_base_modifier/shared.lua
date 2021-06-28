ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Modifier Base";
ENT.Author			= "Aska";
ENT.Purpose			= "Modifies Things";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 1;
ENT.SetNumOutputs = 0;

function ENT:CheckInputs(ip, on)
	local ent = self.WeldedTo;
	if (!IsValid(ent)) then return; end
	if (on) then
		self:ModifyOn(ent);
	else
		self:ModifyOff(ent);
	end
end

function ENT:ModifyOn(ent)
	//override me
end

function ENT:ModifyOff(ent)
	//override me
end
