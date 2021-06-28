
local PANEL = {};


function PANEL:Init()

	self.Picker = vgui.Create("CheckEmGatePicker", self);
	self.Vars = vgui.Create("CheckEmGateVars", self);
	
end


function PANEL:PerformLayout()

	self.Picker:SetWide(self:GetWide());
	self.Picker:SetTall(240);

	self.Vars:SetPos(0, 252);
	self.Vars:SetWide(self:GetWide());
	self.Vars:SetTall(self:GetParent():GetTall() - self.Picker:GetTall() - 25);

end

function PANEL:OnSelected(class, mdl, sk)
	return class, mdl, sk;
end


vgui.Register("CheckEmToolMenu", PANEL);
