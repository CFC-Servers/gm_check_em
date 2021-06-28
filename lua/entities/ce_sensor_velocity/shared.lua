ENT.Type 			= "anim";
ENT.Base 			= "ce_base_sensor";
ENT.PrintName		= "Velocity Sensor";
ENT.Author			= "Aska";
ENT.Purpose			= "Will output ON if it is moving faster than a certain speed";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;

CHECKEM.RegisterCheckEmGate("ce_sensor_velocity", "Velocity", "Sensors");

CHECKEM.SetupCustomVars("ce_sensor_velocity",
	{"Speed Threshold", "Speed", 200, 1, 1024},
	{"Sense Vertical Movement", "Vert", true},
	{"Sense Horizontal Movement", "Hor", true}
);


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(12);
end
