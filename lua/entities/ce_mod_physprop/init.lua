
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')

local mats = {};
mats["Ice"] = "ice";
mats["Rubber"] = "rubber";
mats["Paper"] = "paper";
mats["Flesh"] = "flesh";
mats["Super Ice"] = "gmod_ice";
mats["slime"] = "slipperyslime";
mats["Concrete"] = "concrete";
mats["Glass"] = "glass";
mats["Metal"] = "metal";
mats["Wood"] = "wood";
mats["Dirt"] = "dirt";
mats["Metal Bouncy"] = "metal_bouncy";
mats["Super Bouncy"] = "gmod_bouncy";


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(14);
end


function ENT:ModifyOn(ent)
    self:SetSkin(15);
    local phys = ent:GetPhysicsObject();
	if (phys:IsValid()) then
		construct.SetPhysProp(self, ent, 0, nil, {GravityToggle = self:GetVariable("GTgl"), Material = mats[self:GetVariable("Mat")]});
		phys:ApplyForceCenter(Vector(0, 0, 0));
	end
end

function ENT:ModifyOff(ent)
    self:SetSkin(14);
  	local phys = ent:GetPhysicsObject();
	if (phys:IsValid()) then
		construct.SetPhysProp(self, ent, 0, nil, {GravityToggle = self:GetVariable("GTglOff"), Material = mats[self:GetVariable("MatOff")]});
		phys:ApplyForceCenter(Vector(0, 0, 0));
	end
end
