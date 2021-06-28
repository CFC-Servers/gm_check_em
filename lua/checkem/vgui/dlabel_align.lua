
local PANEL = {};

function PANEL:SetTextAlignX(align)
	self.TextAlignX = align;
end

function PANEL:GetTextAlignX()
	return (self.TextAlignX || TEXT_ALIGN_CENTER);
end

function PANEL:SetTextAlignY(align)
	self.TextAlignY = align;
end

function PANEL:GetTextAlignY()
	return (self.TextAlignY || TEXT_ALIGN_CENTER);
end

vgui.Register("DLabel_Align", PANEL, "DLabel");
