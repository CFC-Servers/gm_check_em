surface.CreateFont("menunamefont", {
	size = ScreenScale(8),
	weight = 800,
	antialias = true,
	font = "Arial"
});

surface.CreateFont("menuinfofont", {
	size = ScreenScale(4),
	weight = 500,
	antialias = true,
	font = "Arial"
});

local PANEL = {};

function PANEL:Init()

	self.MDL = vgui.Create("DModelPanel", self);

	self.GateName = vgui.Create("DLabel", self);
	self.GateName:SetFont("menunamefont");
	self.GateName:SetColor(Color(255, 255, 255, 255));

	self.GateInfo = vgui.Create("DLabel", self);
	self.GateInfo:SetFont("menuinfofont");
	self.GateInfo:SetColor(Color(255, 255, 255, 255));
	self.GateInfo:SetWrap(true);

end


function PANEL:SetGate(ent)
	self.Gate = ent;
	
	self.MDL:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl");

	if (CHECKEM.Layouts[ent:GetClass()]) then
		self.MDL.LayoutEntity = CHECKEM.Layouts[ent:GetClass()];
	else
		//show them they dun fucked up
		ErrorNoHalt("Must create CHECKEM.HandleLayout for your gate.  Look in ce_or - cl_init.lua for an example");
		self.MDL:SetModel(".mdl");
		self.MDL:SetCamPos(Vector(10, -72, 25));
		self.MDL:SetLookAt(Vector(10, 0, 25));
		self.MDL.LayoutEntity = function(panel, ent) ent:SetAngles(Angle(0, -90, 0)) end
	end

	self.GateName:SetText(ent.PrintName);
	self.GateName:SizeToContents();

	self.GateInfo:SetText(ent.Purpose);
end

function PANEL:GetGate()
	return self.Gate;
end


function PANEL:PerformLayout()

	local w, h = self:GetSize();
	h = (h - 10);

	self.MDL:SetPos(18, 5);
	self.MDL:SetSize(h, h);

	local gw, gh = self.GateName:GetSize();

	local x = (18 + self.MDL:GetWide());
	local lw = (self:GetWide() - x);

	self.GateName:SetPos((x + (lw * .5) - (gw * .5)), 8);
	
	self.GateInfo:SetPos((x + 6), 32);
	self.GateInfo:SetWide((w - (x + 10)));
	self.GateInfo:SizeToContentsY();

end


function PANEL:Paint()
	draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 100));
	draw.RoundedBox(0, 4, 4, self:GetWide()-8, self:GetTall()-8, Color(0, 0, 0, 100));
end

vgui.Register("CheckEmGateInfo", PANEL);
