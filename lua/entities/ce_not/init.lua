
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("ce_not")
	ent:SetPos(tr.HitPos + Vector(0,0,20))
	ent:SetAngles(tr.HitNormal:Angle())
	ent:Spawn()
	return ent;
end

function ENT:SequenceOn()
	self:SetSkin(10);
	self:ChangeOPState(1, false, true);
end

function ENT:SequenceOff()
	self:SetSkin(11);
	self:ChangeOPState(1, true, true);
end
