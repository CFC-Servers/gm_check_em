ENT.Type 			= "anim";
ENT.Base 			= "ce_base_modifier";
ENT.PrintName		= "Modifier: PhysProp";
ENT.Author			= "Aska";
ENT.Purpose			= "Changes the physical properties of what it's attached to when it receives an ON input";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

CHECKEM.RegisterCheckEmGate("ce_mod_physprop", "PhysProp", "Modifiers");

CHECKEM.SetupCustomVars("ce_mod_physprop",
	{"Gravity Toggle", "GTgl", true},
	{"Material", "Mat", "Super Bouncy", "Select Material", false, {"Ice", "Rubber", "Paper", "Flesh", "Super Ice", "Slime", "Concrete", "Glass", "Metal", "Wood", "Dirt", "Metal Bouncy", "Super Bouncy"}},
	{"Gravity Toggle When Off", "GTglOff", true},
	{"Material When Off", "MatOff", "Rubber", "Select Material", false, {"Ice", "Rubber", "Paper", "Flesh", "Super Ice", "Slime", "Concrete", "Glass", "Metal", "Wood", "Dirt", "Metal Bouncy", "Super Bouncy"}}
);
