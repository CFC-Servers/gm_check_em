ENT.Type 			= "anim";
ENT.Base 			= "ce_base_modifier";
ENT.PrintName		= "Modifier: Damage";
ENT.Author			= "Aska";
ENT.Purpose			= "Will damage the thing it's connected to when it receives an ON input";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

CHECKEM.RegisterCheckEmGate("ce_mod_damage", "Damage", "Modifiers");

CHECKEM.SetupCustomVars("ce_mod_damage",
	{"Damage Amount", "Amt", 16, 1, 500}
);
