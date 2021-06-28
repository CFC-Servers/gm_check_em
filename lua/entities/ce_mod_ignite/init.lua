
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(6);
end


function ENT:ModifyOn(ent)
    self:SetSkin(7);
    ent:Ignite(self:GetVariable("Dur"));
end

function ENT:ModifyOff(ent)
    self:SetSkin(6);
    if (self:GetVariable("ExOff")) then ent:Extinguish(); end
end
