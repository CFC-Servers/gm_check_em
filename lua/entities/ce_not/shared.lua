ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "NOT Gate";
ENT.Author			= "Aska";
ENT.Purpose			= "If its input is ON, it will output OFF, and vice versa";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 1;

CHECKEM.RegisterCheckEmGate("ce_not", "NOT", "Logic");
CHECKEM.RegisterCheckEmGate("ce_not", "NOT", "Sequencer");

function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:ChangeOPState(1, true);
	if (SERVER) then self:SetSkin(11); end
end

function ENT:CheckInputs(ip, on)
	if (self:GetOutputOn(1) != !on) then
		self:ChangeOPState(1, !on);
	end
	if (SERVER) then self:SetSkin(11 - ((on && 1) || 0)); end
end
