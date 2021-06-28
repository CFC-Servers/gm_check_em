
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Initialize()
	self.BaseClass.BaseClass.Initialize(self);
	self:SetModel("models/checkem/sensor.mdl");
	
	if (!self.CustomAnim) then
		self:ResetSequence(0);
		timer.Simple(.2, function()
			if (IsValid(self)) then
				self:ResetSequence(self:LookupSequence("Ip0"));
				self:EmitSound("checkem/pp_pop.mp3", 68, math.random(85, 92));
			end
		end);
	end
end

function ENT:DoOnDupe()
	
end
