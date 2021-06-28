ENT.Type 			= "anim";
ENT.Base 			= "ce_base_modifier";
ENT.PrintName		= "Modifier: Remove";
ENT.Author			= "Aska";
ENT.Purpose			= "Will remove the thing it's connected to when it receives an ON input";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

CHECKEM.RegisterCheckEmGate("ce_mod_remove", "Remove", "Modifiers");
