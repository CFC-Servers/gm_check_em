ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "XOR Gate";
ENT.Author			= "Aska";
ENT.Purpose			= "If one, and only one, of this gate's inputs are ON, it will output ON";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 2;

CHECKEM.RegisterCheckEmGate("ce_xor", "XOR", "Logic");

CHECKEM.SetupCustomVars("ce_xor",
	{"Number of Inputs", "NumIPs", 2, 2, 10}
);

function ENT:CheckInputs(ip, on)
	local off = true;
	for i = 1, self:NumInputs() do
		if (self:GetInputOn(i)) then
			if (off) then
				off = false;
			else
				off = true;
				break;
			end
		end
	end
	if (self:GetOutputOn(1) == off) then
		self:ChangeOPState(1, !off);
	end
	if (SERVER) then self:SetSkin(7 - ((off && 1) || 0)); end
end
