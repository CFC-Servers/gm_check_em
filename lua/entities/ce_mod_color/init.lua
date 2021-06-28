
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(4);
end


function ENT:ModifyOn(ent)
    self:SetSkin(5);

    local clr = self:GetVariable("OnClr");
    if (clr.a < 255) then
    	ent:SetRenderMode(1);
    else
    	ent:SetRenderMode(0);
    end
    ent:SetColor(clr);
end

function ENT:ModifyOff(ent)
    self:SetSkin(4);
    if (self:GetVariable("DoOff")) then
    	local clr = self:GetVariable("OffClr");
    	if (clr.a < 255) then
			ent:SetRenderMode(1);
		else
			ent:SetRenderMode(0);
		end
	    ent:SetColor(clr);
	end
end
