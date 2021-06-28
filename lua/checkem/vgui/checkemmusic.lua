
local PANEL = {};


local c, d, e, f, g, a, b, cs, ds, fs, gs, as = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12;

local keys = {"C", "D", "E", "F", "G", "A", "B"};

local accidentals = {"C#", "D#", "F#", "G#", "A#"};

function PANEL:Init()

	self.Notes = {};
	self.Folder = "Piano";

	self:SetSize(272, 116);

	local w, h = (self:GetWide()/7), self:GetTall();
	for i = 1, 7 do
		local key = vgui.Create("DButton", self);
		key:SetText(keys[i]);
		key:SetSize(w, h);
		key:SetPos(w * (i-1), 0);
		key.DoClick = function(pnl)
			self:OnValueChanged(i);
			local oct = tostring(self.vars:GetItems()[5]:GetValue());
			surface.PlaySound("checkem/instruments/keyboard/" .. self.Folder .. "/" .. keys[i] .. oct .. ".wav");
		end
	end

	for i = 1, 5 do
		local neww, newh = (w*.5), (h*.5);
		local key = vgui.Create("DButton", self);
		key:SetText(accidentals[i]);
		key:SetSize(neww, newh);
		local x = (w * i) - (neww * .5);
		if (i >= 3) then x = (x + w); end
		key:SetPos(x, 0);
		key.DoClick = function(pnl)
			self:OnValueChanged(7+i);
			local oct = tostring(self.vars:GetItems()[5]:GetValue());
			surface.PlaySound("checkem/instruments/keyboard/" .. self.Folder .. "/" .. accidentals[i] .. oct .. ".wav");
		end
	end
	
end


function PANEL:OnValueChanged(val)
	//override
end


function PANEL:PerformLayout()
end


vgui.Register("CheckEmMusic", PANEL);
