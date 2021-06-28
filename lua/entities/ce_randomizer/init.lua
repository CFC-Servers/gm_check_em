
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(14);

	self.NowOn = {};
	
	timer.Simple(1, function()
		if (IsValid(self)) then self:On(); end
	end);
end

function ENT:On()
	local min, max = self.MinOn, self.MaxOn;

	local t = min;
	if (min != max) then
		t = math.Rand(min, max);
	end

	self:ChangeOPState(1, true, true);

	/*local ops = self:GetOutputEnts(1);

	if (#ops > 0) then

		local rnd = table.Random(ops);
		local id = rnd[1];
		local e = Entity(id);
		self:SendOPSignal(e, rnd[2], true);
		self.NowOn[id] = e;

	end*/
	
	self:SetSkin(15);
	timer.Simple(t, function()
		if (IsValid(self)) then self:Off(); end
	end);
end

function ENT:Off()
	local min, max = self.MinOff, self.MaxOff;
	
	local t = min;
	if (min != max) then
		t = math.Rand(min, max);
	end
	
	self:ChangeOPState(1, false, true);
	self:SetSkin(14);
	timer.Simple(t, function()
		if (IsValid(self)) then self:On(); end
	end);
end

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("ce_randomizer")
	ent:SetPos(tr.HitPos + Vector(0,0,20))
	ent:Spawn()
	return ent;
end

function ENT:VariableChanged(var, val)
	self[var] = math.Round(val, 1);
end

function ENT:DoOnDupe()
	self.MinOn = self:GetVariable("MinOn");
	self.MinOff = self:GetVariable("MinOff");
	self.MaxOn = self:GetVariable("MaxOn");
	self.MaxOff = self:GetVariable("MaxOff");
end
