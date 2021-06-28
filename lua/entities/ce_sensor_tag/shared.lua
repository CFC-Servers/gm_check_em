ENT.Type 			= "anim";
ENT.Base 			= "ce_base_sensor";
ENT.PrintName		= "Tag Sensor";
ENT.Author			= "Aska";
ENT.Purpose			= "Will remain OFF until the required number of players enters its space, will then output ON";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;

CHECKEM.RegisterCheckEmGate("ce_sensor_tag", "Tag", "Sensors");

CHECKEM.SetupCustomVars("ce_sensor_tag",
	{"Color", "clr", "White", "Select Color", false, {"Red", "Green", "Blue", "Violet", "White", "Yellow", "Orange"}},
	{"Number Of Tags", "NumTag", 1, 1, 64},
	{"Sphere Radius", "SRad", 64, 1, 1024},
	{"Cube", "Cube", false},
	{"Cube X", "X", 64, 1, 1024},
	{"Cube Y", "Y", 64, 1, 1024},
	{"Cube Z", "Z", 64, 1, 1024}
);


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(10);

	if (CLIENT) then
		self.lerpx, self.lerpy, self.lerpz = 0, 0, 0;
		self:CreateRadialSphere();
	end
end


function ENT:VariableChanged(var, val)
	if (var == "SRad") then
		self.SphereRadius = val;
	end
	if (CLIENT && var == "Cube") then
		if (val) then
			self.RadialSphere:Remove(); self.RadialSphere = nil;
		else
			self.lerpx, self.lerpy, self.lerpz = 0, 0, 0;
			if (!IsValid(self.RadialSphere)) then self:CreateRadialSphere(); end
		end	
	end
end
