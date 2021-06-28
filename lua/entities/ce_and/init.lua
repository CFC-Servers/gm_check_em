
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(2);
end

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("ce_and")
	ent:SetPos(tr.HitPos + Vector(0,0,20))
	ent:SetAngles(tr.HitNormal:Angle())
	ent:Spawn()
	return ent;
end

function ENT:VariableChanged(var, val)
	if (var == "NumIPs") then
		self:ChangeNumInputs(val);
	end
end

function ENT:DoOnDupe()
	timer.Simple(.2, function()
		if (IsValid(self)) then self:SizeUp(); end
	end);
end
