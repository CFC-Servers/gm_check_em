ENT.Type 			= "anim";
ENT.Base 			= "ce_base_sensor";
ENT.PrintName		= "Damage Sensor";
ENT.Author			= "Aska";
ENT.Purpose			= "Will output ON when it takes damage above a set threshold, or when the thing it's attached to does (toggleable)";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;

CHECKEM.RegisterCheckEmGate("ce_sensor_damage", "Damage", "Sensors");

CHECKEM.SetupCustomVars("ce_sensor_damage",
	{"Damage Threshold", "Dmg", 1, 1, 500},
	{"Off Delay", "Off", 0, 0, 8, 1},
	{"Sense Damage On Chip Only", "ChipOnly", false}
);


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(4);
	self.OffDelay = 0;
end
