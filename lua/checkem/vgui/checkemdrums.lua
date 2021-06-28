
local PANEL = {};


function PANEL:Init()

	self.Folder = "Rock Drums";

	self:SetSize(272, 81);

	local typ = vgui.Create("DComboBox", self);
	typ:SetText(self.Folder);

	local _, drums = file.Find("sound/checkem/instruments/drums/*", "GAME");
	for k, v in pairs(drums) do
		typ:AddChoice(v);
	end

	self.Inst = vgui.Create("DComboBox", self);
	self:UpdateInstrumentBox(typ, "Rock Drums");
	self.Inst:SetText("kick.wav");

	typ.OnSelect = function(pnl, index, val, data)
		self:UpdateInstrumentBox(typ, val);
	end

	self.Inst.OnSelect = function(pnl, index, val, data)
		self:OnValueChanged(typ:GetValue() .. "/" .. val);
	end

	local plyBtn = vgui.Create("DButton", self);
	plyBtn:SetText("Play");

	plyBtn.DoClick = function(pnl)
		surface.PlaySound("checkem/instruments/drums/" .. typ:GetValue() .. "/" .. self.Inst:GetValue());
	end

	local w, h = self:GetWide(), 23;
	w = (w - 6);

	typ:SetPos(0, 0);
	typ:SetSize(w, h);
	self.Inst:SetPos(0, h + 6);
	self.Inst:SetSize(w, h);
	plyBtn:SetPos((w * .5) - 16, h + 35);
	plyBtn:SetSize(48, h);

	self:SizeToContentsY();
	
end

function PANEL:UpdateInstrumentBox(typ, folder)
	local inst = self.Inst;
	inst:Clear();

	local drums = file.Find("sound/checkem/instruments/drums/" .. folder .. "/*.wav", "GAME");
	for k, v in pairs(drums) do
		inst:AddChoice(v);
	end
	inst:ChooseOptionID(1);
	self:OnValueChanged(typ:GetValue() .. "/" .. inst:GetOptionText(1));

end


function PANEL:OnValueChanged(val)
	//override
end


function PANEL:PerformLayout()
end


vgui.Register("CheckEmDrums", PANEL);
