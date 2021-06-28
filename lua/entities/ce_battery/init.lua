
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(8);
	self.On = false;
end

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("ce_battery")
	ent:SetPos(tr.HitPos + Vector(0,0,20))
	ent:Spawn()
	return ent;
end

function ENT:Use(act, call)
	if (self.Sequenced) then return; end
	self.On = !self.On;
	local on = (self.On && 1) || 0;

	self:EmitSound("items/medshotno1.wav", 60, (math.random(216, 225) + (30 * on)));
	self:SetSkin(8 + on);
	self:ChangeOPState(1, self.On, true);
end

function ENT:SequenceOn()
	self:SetSkin(9);
	self:ChangeOPState(1, true, true);
end

function ENT:SequenceOff()
	self:SetSkin(8);
	self:ChangeOPState(1, false, true);
end

function ENT:DoOnDupe()
	if (self:GetOutputOn(1)) then self:SetSkin(9); self.On = true; end
end
