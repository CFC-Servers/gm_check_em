
local PANEL = {};


function PANEL:Init()

	self.Tabs = vgui.Create("DPropertySheet", self);

	//create these first three in order
	self:CreateCategorySheet("Logic");
	self:CreateCategorySheet("Sensors");
	self:CreateCategorySheet("Modifiers");

	for k, v in pairs(CHECKEM.Gates) do
		if (k != "Logic" && k != "Sensors" && k != "Modifiers") then
			self:CreateCategorySheet(k);
		end
	end

	//self.Layout = vgui.Create("DIconLayout", self);
	
end


function PANEL:CreateCategorySheet(category)

	local scroll = vgui.Create("DScrollPanel", self);
	scroll:SetSize(self:GetWide(), self:GetTall());

	local p = vgui.Create("DIconLayout", self);
	p:Dock(FILL);
	p:SetUseLiveDrag(false);
	p:SetSelectionCanvas(false);
	//p.Paint = function() draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 150)) end

	local tbl = CHECKEM.Gates[category];
	for k, v in pairs(tbl) do

		local class, name = k, v;
		local b = p:Add("CheckEmGatePickerButton");
		b.MParent = self;
		b:SetGate(category, class);
		b:SetSize(64, 64);

	end

	scroll:AddItem(p);

	self.Tabs:AddSheet(category, scroll, nil, false, false, nil);

end

function PANEL:OnSelected(class, mdl, sk)
	self:GetParent():OnSelected(class, mdl, sk);
end


function PANEL:PerformLayout()

	self.Tabs:SetWide(self:GetWide());
	self.Tabs:SetTall(self:GetTall());

end


vgui.Register("CheckEmGatePicker", PANEL);
