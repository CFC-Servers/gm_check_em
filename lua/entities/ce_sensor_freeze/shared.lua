ENT.Type 			= "anim";
ENT.Base 			= "ce_base_sensor";
ENT.PrintName		= "Freeze Sensor";
ENT.Author			= "Aska";
ENT.Purpose			= "Will output ON if the thing it's attached to is frozen";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;

CHECKEM.RegisterCheckEmGate("ce_sensor_freeze", "Freeze", "Sensors");


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(18);
end
