
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:VariableChanged(var, val)
	if (var == "NumOP") then
		self:ChangeNumInputs(val+2);
		self:ChangeNumOutputs(val);
	end
end

function ENT:DoOnDupe()
	timer.Simple(.2, function()
		if (IsValid(self)) then self:SizeUp(); end
	end);
end
