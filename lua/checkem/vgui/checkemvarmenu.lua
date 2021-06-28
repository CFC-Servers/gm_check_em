
local PANEL = {};

function PANEL:Init()

	self.MDL = vgui.Create("CheckEmGateInfo", self);

	self.VarMenu = vgui.Create("CheckEmGateVars", self);

	self:ShowCloseButton(true);
	self:SetTitle("Check 'em Tweaking Menu");
	
end

function PANEL:SetGate(ent)
	self.Gate = ent;
	self.MDL:SetGate(ent);
	self.VarMenu:SetGate(ent);
	self:InvalidateLayout();
end

function PANEL:GetGate()
	return self.Gate;
end

function PANEL:PerformLayout()

	self.BaseClass.PerformLayout(self);

	self.MDL:SetPos(0, 25);
	self.MDL:SetSize(self:GetWide(), 100);

	self.VarMenu:SetPos(0, 125);
	self.VarMenu:SetWide(self:GetWide());

	local h = (25 + self.MDL:GetTall()) + self.VarMenu:GetTall();
	self:SetTall(h);

end


vgui.Register("CheckEmVarMenu", PANEL, "DFrame");
