ENT.Type 			= "anim";
ENT.Base 			= "ce_base_modifier";
ENT.PrintName		= "Modifier: Freeze";
ENT.Author			= "Aska";
ENT.Purpose			= "Will freeze the thing it's connected to when it receives an ON input";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

CHECKEM.RegisterCheckEmGate("ce_mod_freeze", "Freeze", "Modifiers");

CHECKEM.SetupCustomVars("ce_mod_freeze",
	{"Time (in seconds)", "Time", 0, 0, 3, 2},
	{"Unfreeze When Off", "DoOff", true},
	{"Maintain Velocity", "Vel", false}
);
