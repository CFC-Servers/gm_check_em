
include('shared.lua')


function ENT:CreateRadialSphere()
	local ent = ClientsideModel("models/checkem/triggerradius.mdl");
	timer.Simple(0, function() 
		ent:SetPos(self:GetPos());
		ent:SetModelScale(.02, 0);
		ent:SetColor(Color(255, 255, 255, 255));
		ent:SetParent(self);
	end);
	self.RadialSphere = ent;
	self.RadSize = .02;
end

function ENT:OnRemove()
	self.BaseClass.BaseClass.OnRemove(self);
	if (IsValid(self.RadialSphere)) then self.RadialSphere:Remove(); end
end
