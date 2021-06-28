ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Toggle Gate";
ENT.Author			= "Aska";
ENT.Purpose			= "If its input is ON, it will output OFF, and vice versa";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 1;

CHECKEM.RegisterCheckEmGate("ce_toggle", "Toggle", "Logic");
CHECKEM.RegisterCheckEmGate("ce_toggle", "Toggle", "Sequencer");

function ENT:CheckInputs(ip, on)
	
	if (on) then
		self:ChangeOPState(1, !self:GetOutputOn(1));
	end

	if (SERVER) then self:SetSkin(12 + ((self:GetOutputOn(1) && 1) || 0)); end
end
