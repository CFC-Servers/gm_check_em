ENT.Type 			= "anim";
ENT.Base 			= "ce_base_sensor";
ENT.PrintName		= "Water Sensor";
ENT.Author			= "Aska";
ENT.Purpose			= "Will output ON if it's underwater, or the thing it's attached to is underwater (toggleable)";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;

CHECKEM.RegisterCheckEmGate("ce_sensor_water", "Water", "Sensors");

CHECKEM.SetupCustomVars("ce_sensor_water",
	{"Sense Water On Chip Only", "ChipOnly", false}
);


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(6);
end
