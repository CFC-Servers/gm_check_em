ENT.Type 			= "anim";
ENT.Base 			= "ce_base_sensor";
ENT.PrintName		= "Pressure Sensor";
ENT.Author			= "Aska";
ENT.Purpose			= "Will output ON if it has enough props on top of it";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;

CHECKEM.RegisterCheckEmGate("ce_sensor_pressure", "Pressure", "Sensors");

CHECKEM.SetupCustomVars("ce_sensor_pressure",
	{"Number of Items", "Num", 1, 1, 16},
	{"Silent", "Silent", false},
	{"Detect Players", "DPly", true},
	{"Detect Props", "DProp", true},
	{"Detect NPCs", "DNPC", true},
	{"Detect SENTs", "DSENT", true},
	{"Detect World", "DWorld", true},
	{"Detect Ragdolls", "DRag", true}
);
