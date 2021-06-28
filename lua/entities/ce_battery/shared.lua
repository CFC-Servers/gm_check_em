ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Battery";
ENT.Author			= "Aska";
ENT.Purpose			= "TURN IT ON AND OFF YOULL BE GASSED BY IT";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;

CHECKEM.RegisterCheckEmGate("ce_battery", "Battery", "Logic");
CHECKEM.RegisterCheckEmGate("ce_battery", "Battery", "Sequencer");
