ENT.Type 			= "anim";
ENT.Base 			= "ce_base_modifier";
ENT.PrintName		= "Modifier: Ignite";
ENT.Author			= "Aska";
ENT.Purpose			= "Will ignite the thing it's connected to when it receives an ON input";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

CHECKEM.RegisterCheckEmGate("ce_mod_ignite", "Ignite", "Modifiers");

CHECKEM.SetupCustomVars("ce_mod_ignite",
	{"Duration", "Dur", 1, 1, 120, 2},
	{"Extinguish When Off", "ExOff", true}
);
