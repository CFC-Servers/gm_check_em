
include('shared.lua')

CHECKEM.HandleLayout("ce_tag", function(panel, ent)
	ent:SetModel("models/checkem/tag.mdl");
	ent:SetBodygroup(1, 1);
	panel:SetCamPos(Vector(9, 9, 6));
	panel:SetLookAt(Vector(0, 0, 4));
end);

function ENT:OnRemove()
	self.BaseClass.BaseClass.OnRemove(self);
	if (IsValid(self.Glass)) then self.Glass:Remove(); end
	if (IsValid(self.Refract)) then self.Refract:Remove(); end
end
