
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Initialize()
	self.BaseClass.BaseClass.Initialize(self);
	self:SetModel("models/checkem/basechip2.mdl");
	self:ResetSequence(0);
	timer.Simple(.2, function()
		self:ResetSequence(self:LookupSequence("Ip1"));
		self:EmitSound("checkem/pp_pop.mp3", 68, math.random(85, 92));
	end)
end
