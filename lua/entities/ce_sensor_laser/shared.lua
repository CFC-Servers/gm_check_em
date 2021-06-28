ENT.Type 			= "anim";
ENT.Base 			= "ce_base_sensor";
ENT.PrintName		= "Laser Sensor";
ENT.Author			= "Aska";
ENT.Purpose			= "Will output ON if something touches the laser it's emitting, can also detect the world (toggleable)";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;

CHECKEM.RegisterCheckEmGate("ce_sensor_laser", "Laser", "Sensors");

CHECKEM.SetupCustomVars("ce_sensor_laser",
	{"Distance", "Dis", 64, 1, 1024},
	{"Hit World", "World", false}
);


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(16);
end
