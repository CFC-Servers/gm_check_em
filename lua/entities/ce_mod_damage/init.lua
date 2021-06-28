
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(10);
end


function ENT:ModifyOn(ent)
    self:SetSkin(11);
    ent:TakeDamage(self:GetVariable("Amt"));
end

function ENT:ModifyOff(ent)
    self:SetSkin(10);
end
