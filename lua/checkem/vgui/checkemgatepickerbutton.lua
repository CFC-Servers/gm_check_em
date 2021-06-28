
local PANEL = {};


function PANEL:Init()

	self.first = true;
	self.Down = false;
	self.On = false;

	self.MDL = vgui.Create("DModelPanel", self);
	self.MDL.OnMousePressed = function()
		self.MDL:GetParent():OnMousePressed();
	end
	self.MDL.OnMouseReleased = function()
		self.MDL:GetParent():OnMouseReleased();
	end
	self.MDL.OnCursorExited = function()
		self.MDL:GetParent():OnCursorExited();
	end

	self.GateName = vgui.Create("DLabel", self);
	self.GateName:SetColor(Color(255, 255, 255, 255));
	self.GateName.Paint = function()
		draw.RoundedBox(0, 0, 0, self.GateName:GetWide(), self.GateName:GetTall(), Color(0, 0, 0, 175));
	end
	
end


function PANEL:SetGate(category, class)

	self.Class = class;
	self.GateName:SetText(CHECKEM.Gates[category][class]);
	self.GateName:SizeToContents();
	self.MDL:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl");

	if (CHECKEM.Layouts[class]) then
		self.MDL.LayoutEntity = CHECKEM.Layouts[class];
	else
		//show them they dun fucked up
		ErrorNoHalt("Must create CHECKEM.HandleLayout for your gate.  Look in ce_or - cl_init.lua for an example");
		self.MDL:SetModel(".mdl");
		self.MDL:SetCamPos(Vector(10, -72, 25));
		self.MDL:SetLookAt(Vector(10, 0, 25));
		self.MDL.LayoutEntity = function(panel, ent) ent:SetAngles(Angle(0, -90, 0)) end
	end

end

function PANEL:OnMousePressed()
	self:SetSize(60, 60);
	self:InvalidateLayout();
	self.Down = true;
end

function PANEL:OnMouseReleased()
	self:SetSize(64, 64);
	self:InvalidateLayout();
	self.Down = false;
	self:OnSelected(self.Class, self.MDL.Entity:GetModel(), self.MDL.Entity:GetSkin());
end

function PANEL:OnCursorExited()
	if (self.Down) then
		self:OnMouseReleased();
	end
end

function PANEL:OnSelected(class, mdl, sk)
	self.MParent:OnSelected(class, mdl, sk);
	self:GetParent().Selected = self;
end

function PANEL:PaintOver()
	if (self:GetParent().Selected == self) then
		surface.SetDrawColor(Color(0, 0, 0, 255));
		surface.DrawLine(0, 0, self:GetWide()-1, 0);
		surface.DrawLine(0, self:GetTall()-1, self:GetWide()-1, self:GetTall()-1);
		surface.DrawLine(0, 0, 0, self:GetTall()-1);
		surface.DrawLine(self:GetWide()-1, 0, self:GetWide()-1, self:GetTall()-1);
		
		draw.RoundedBox(0, 1, 1, self:GetWide() - 2, self:GetTall() - 2, Color(200, 200, 255, 16));
	end
end

function PANEL:PerformLayout()

	if (self.first) then
		self.MDL:SetSize(self:GetSize());
		self.first = false;
	end

	self.MDL:SetPos((64 - self:GetWide()) * .5, (64 - self:GetTall()) * .5);

	self.GateName:SetPos((32 - (self.GateName:GetWide() * .5)), 50);

end


vgui.Register("CheckEmGatePickerButton", PANEL);
