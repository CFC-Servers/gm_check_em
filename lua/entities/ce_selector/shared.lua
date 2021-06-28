ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Selector Gate";
ENT.Author			= "Aska";
ENT.Purpose			= "Final input cycles between outputs, or select output individually.";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 4;
ENT.SetNumOutputs = 3;

CHECKEM.RegisterCheckEmGate("ce_selector", "Selector", "Logic");

CHECKEM.SetupCustomVars("ce_selector",
	{"Number of Outputs", "NumOP", 3, 2, 8}
);

function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(4);

	self.CurOn = 1;
	timer.Simple(.25, function()
		self:ChangeOPState(1, true);
	end);
end


function ENT:CheckInputs(ip, on)
	if (on) then
		if (ip == self:NumInputs()) then
			local old = self.CurOn;
			self.CurOn = (self.CurOn + 1);
			if (self.CurOn >= self:NumOutputs()+1) then self.CurOn = 1; end
			self:ChangeOPState(old, false);
			self:ChangeOPState(self.CurOn, true);
		elseif (ip == self:NumInputs()-1) then
			local old = self.CurOn;
			self.CurOn = (self.CurOn - 1);
			if (self.CurOn < 1) then self.CurOn = self:NumOutputs(); end
			self:ChangeOPState(old, false);
			self:ChangeOPState(self.CurOn, true);
		else
			if (ip == self.CurOn) then return; end
			self:ChangeOPState(self.CurOn, false);
			self:ChangeOPState(ip, true);
			self.CurOn = ip;
		end
	end
end
