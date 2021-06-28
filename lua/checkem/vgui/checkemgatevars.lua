
local PANEL = {};

function PANEL:Init()

	self.Vars = vgui.Create("DPanelList", self);
	self.Vars:SetSpacing(5);
	self.Vars:SetPadding(8);
	self.Vars:EnableHorizontal(false);
	self.Vars:EnableVerticalScrollbar(true);

end


function PANEL:GrabVars()

	if (self.Gate == nil) then return; end
	if (type(self.Gate) != "string" && !IsValid(self.Gate)) then return; end

	local class = self.Gate;
	if (type(class) != "string") then class = class:GetClass(); end
	local vars = CHECKEM.Vars[class];
	if (!vars || vars == nil) then self.Vars:Clear(); return nil; end
	return vars;
end


function PANEL:CreateVarEditor(var)

	local gate = self:GetGate();
	local ply = LocalPlayer();

	local name, nicename = var.name, var.nicename;

	if (var.custom != nil) then
		return var.custom(self.Vars, gate, name, var);
	end

	local t = type(var.val);

	if (t == "boolean") then

		local chk = vgui.Create("DCheckBoxLabel", self.Vars);
		chk:SetText(nicename);
		chk:SetTextColor(Color(0, 0, 0, 255));

		if (type(gate) == "string") then
			chk:SetValue(var.val);
			CHECKEM.UpdateLocalVar(gate, name, var.val);
			chk.OnChange = function(pnl, val)
				CHECKEM.UpdateLocalVar(gate, name, val);
			end
		else
			local cur = gate:GetVariable(name);
			chk:SetValue(cur);
			chk.OnChange = function(pnl, val)
				gate:ChangeVariable(name, val);
			end
		end

		return chk;

	end

	if (t == "number") then

		local precision = (var.precision || 0);

		//just a num slider
		local num = vgui.Create("DNumSlider", self.Vars);
		num.Label:SetTextColor(Color(0, 0, 0, 255));
		num:SetText(nicename);
		num:SetDecimals(precision);
		/*num.Wang.OnTextChanged = function(pnl)
			print(type(pnl:GetValue()), pnl:GetValue())
			num:OnValueChanged(pnl:GetValue());
		end*/
		
		if (var.min && var.max) then
			num:SetMinMax(var.min, var.max);
		end

		if (type(gate) == "string") then
			num:SetValue(var.val);
			CHECKEM.UpdateLocalVar(gate, name, var.val);
			num.OnValueChanged = function(pnl, val)
				local num = math.Round(tonumber(val), precision);
				//print(num);
				CHECKEM.UpdateLocalVar(gate, name, num);
			end
		else
			local cur = gate:GetVariable(name);
			num:SetValue(cur);
			num.OnValueChanged = function(pnl, val)
				local num = math.Round(tonumber(val), precision);
				//print(num);
				gate:ChangeVariable(name, num);
			end
		end

		return num;

	end

	if (t == "string") then

		if (var.allowinput) then
			
			//create a text box

		else
			
			local str = vgui.Create("DComboBox", self.Vars);
			str:SetText(var.txt);

			for k, v in pairs(var.strs) do
				str:AddChoice(v);
			end

			if (type(gate) == "string") then
				CHECKEM.UpdateLocalVar(gate, name, var.val);
				str.OnSelect = function(pnl, index, val, data)
					CHECKEM.UpdateLocalVar(gate, name, val);
				end
			else
				local cur = gate:GetVariable(name);
				str:SetText(cur);
				str.OnSelect = function(pnl, index, val, data)
					gate:ChangeVariable(name, val);
				end
			end

			return str;

		end

	end

	//color
	if (t == "table") then

		local clr = vgui.Create("DColorMixer", self.Vars);
		clr:SetText("On Color");
		clr:SetTall(200);

		if (type(gate) == "string") then
			CHECKEM.UpdateLocalVar(gate, name, var.val);
			clr:SetColor(Color(255, 0, 0, 255));
			clr.ValueChanged = function(pnl, color)
				pnl:UpdateConVars(color);
				CHECKEM.UpdateLocalVar(gate, name, color);
			end
		else
			local cur = gate:GetVariable(name);
			clr.RGB:SetRGB(Color(cur.r, cur.g, cur.b));
			clr:SetColor(cur);
			clr.ValueChanged = function(pnl, color)
				pnl:UpdateConVars(color);
				gate:ChangeVariable(name, color);
			end
		end

		return clr;

	end

end


//USE MENU
function PANEL:SetGate(ent)
	self.Vars:Clear();
	self.Gate = ent;

	//populate the panel list with var editors
	local vars = self:GrabVars();
	if (vars != nil) then
		for k, v in pairs(vars) do
			local pnl = self:CreateVarEditor(v);
			self.Vars:AddItem(pnl);
		end

		local h = 16; //initial padding top+bottom
		for k, v in pairs(self.Vars:GetItems()) do
			h = (h + (v:GetTall() + 5)); //height + spacing
		end

		if (type(ent) == "string") then
			h = math.Clamp(h, 0, 310);
			self:SetTall(h);
		else
			self:SetTall(h);
		end
	else
		self:SetTall(0);
	end
	self:InvalidateLayout();
end


function PANEL:GetGate()
	return self.Gate;
end


function PANEL:PerformLayout()

	self.Vars:SetPos(0, 0);
	self.Vars:SetSize(self:GetSize());

end


function PANEL:Paint()
	if (!self:GetGate() || self:GetParent().ToolMenu) then return; end
	draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(150, 150, 150, 100));
	draw.RoundedBox(0, 4, 4, self:GetWide()-8, self:GetTall()-8, Color(200, 200, 200, 100));
end

vgui.Register("CheckEmGateVars", PANEL);
