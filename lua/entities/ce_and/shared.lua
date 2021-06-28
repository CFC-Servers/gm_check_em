ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "AND Gate";
ENT.Author			= "Aska";
ENT.Purpose			= "If all of this gate's inputs are ON, it will output ON";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 2;


CHECKEM.RegisterCheckEmGate("ce_and", "AND", "Logic");

CHECKEM.SetupCustomVars("ce_and",
	{"Number of Inputs", "NumIPs", 2, 2, 10}/*,
	{"Red", "Red", 255, 0, 255},
	{"Green", "Green", 255, 0, 255},
	{"Blue", "Blue", 255, 0, 255},
	{"Invisible", "Invis", false}*/
);

function ENT:CheckInputs(ip, on)
	local on = true;
	for i = 1, self:NumInputs() do
		if (!self:GetInputOn(i)) then
			on = false;
			break;
		end
	end
	if (self:GetOutputOn(1) != on) then
		self:ChangeOPState(1, on);
	end
	if (SERVER) then self:SetSkin(2 + ((on && 1) || 0)); end
end
