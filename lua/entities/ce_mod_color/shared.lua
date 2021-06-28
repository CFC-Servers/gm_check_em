ENT.Type 			= "anim";
ENT.Base 			= "ce_base_modifier";
ENT.PrintName		= "Modifier: Color";
ENT.Author			= "Aska";
ENT.Purpose			= "Will change the color of the attached prop when ON, optional color can be set for OFF";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

CHECKEM.RegisterCheckEmGate("ce_mod_color", "Color", "Modifiers");

CHECKEM.SetupCustomVars("ce_mod_color",
	{"On Color", "OnClr", Color(255, 255, 255, 200)},
	{"Use Off Color", "DoOff", true},
	{"Off Color", "OffClr", Color(10, 10, 10, 100)}
);
