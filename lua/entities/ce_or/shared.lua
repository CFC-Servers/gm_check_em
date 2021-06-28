ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "OR Gate";
ENT.Author			= "Aska";
ENT.Purpose			= "If any of this gate's inputs are ON, it will output ON";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 2;

CHECKEM.RegisterCheckEmGate("ce_or", "OR", "Logic");

CHECKEM.SetupCustomVars("ce_or",
	{"Number of Inputs", "NumIPs", 2, 2, 10}
);

function ENT:CheckInputs(ip, on)
	local off = true;
	for i = 1, self:NumInputs() do
		if (self:GetInputOn(i)) then
			off = false;
			break;
		end
	end
	if (self:GetOutputOn(1) == off) then
		self:ChangeOPState(1, !off);
	end
	if (SERVER) then self:SetSkin(5 - ((off && 1) || 0)); end
end
