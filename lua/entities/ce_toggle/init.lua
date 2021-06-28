
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(12);
end

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("ce_toggle")
	ent:SetPos(tr.HitPos + Vector(0,0,20))
	ent:SetAngles(tr.HitNormal:Angle())
	ent:Spawn()
	return ent;
end

function ENT:SequenceOn()
	self:ChangeOPState(1, !self:GetOutputOn(1));
	self:SetSkin(12 + ((self:GetOutputOn(1) && 1) || 0));
end

function ENT:SequenceOff()
end

function ENT:DoOnDupe()
	if (self:GetOutputOn(1)) then self:SetSkin(13); end
end
