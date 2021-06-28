ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Randomizer";
ENT.Author			= "Aska";
ENT.Purpose			= "Will turn ON and OFF randomly.  The length of time it remains ON and OFF is randomly chosen between these mins and maxs";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;

CHECKEM.RegisterCheckEmGate("ce_randomizer", "Randomizer", "Logic");

CHECKEM.SetupCustomVars("ce_randomizer",
	{"Minimum ON Time", "MinOn", .8, .1, 25, 1},
	{"Maximum ON Time", "MaxOn", 2, .1, 25, 1},
	{"Minimum OFF Time", "MinOff", .8, .1, 25, 1},
	{"Maximum OFF Time", "MaxOff", 2, .1, 25, 1}
);
