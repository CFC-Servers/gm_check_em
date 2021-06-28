ENT.Type 			= "anim";
ENT.Base 			= "ce_base_sensor";
ENT.PrintName		= "Use Sensor";
ENT.Author			= "Aska";
ENT.Purpose			= "Will output ON when a player USES it, or USES the prop it's attached to (toggleable)";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;

CHECKEM.RegisterCheckEmGate("ce_sensor_use", "Use", "Sensors");

CHECKEM.SetupCustomVars("ce_sensor_use",
	{"Off Delay", "Off", 0, 0, 8, 2},
	{"Allow Hold", "Hold", true},
	{"Sense Use On Chip Only", "ChipOnly", false}
);


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(2);
	self.PlayerHolding = nil;
	self.OffDelay = 0;
	self.On = false;

	if (SERVER) then
		hook.Add("KeyPress", self, self.KeyPress);
		hook.Add("KeyRelease", self, self.KeyRelease);
	end

end


if (SERVER) then

function ENT:BeingHeld(ply)
	self.PlayerHolding = ply;
	self.On = true;
end

function ENT:LetGo()
	local ply = self.PlayerHolding;
	if (IsValid(ply)) then
		self.PlayerHolding = nil;
	end
end


function ENT:KeyPress(ply, key)
	if (!IsValid(ply) || !ply:Alive() || key != IN_USE || CHECKEM.PlayerHoldingTool(ply)) then return; end

	local tr = ply:GetEyeTrace();
	local ent = tr.Entity;

	if (!IsValid(ent)) then return; end
	if (ent:GetPos():Distance(ply:GetPos()) > 102) then return; end
	if (ent != self && ent != self.WeldedTo) then return; end
	if (ent == self.WeldedTo && self:GetVariable("ChipOnly")) then return; end

	local hold = self:GetVariable("Hold");
	local delay = self:GetVariable("Off");
	if (hold) then
		if (!IsValid(self.PlayerHolding)) then self:BeingHeld(ply); end
	else
		if (!self:GetOutputOn(1)) then
			self:LetGo();
			self.OffDelay = (CurTime() + delay);
			self.On = true;
		end
	end
end

function ENT:KeyRelease(ply, key)
	if (!IsValid(ply) || !ply:Alive() || key != IN_USE) then return; end
	local hold = self:GetVariable("Hold");
	local delay = self:GetVariable("Off");
	if (hold && IsValid(self.PlayerHolding) && ply == self.PlayerHolding) then
		self.OffDelay = (CurTime() + delay);
		self:LetGo();
	end
end

end
