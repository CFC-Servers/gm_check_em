ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Input Sensor";
ENT.Author			= "Aska";
ENT.Purpose			= "Turns on/off when the player presses/releases certain keys";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;
ENT.SetNumOutputs = 10;

ENT.CustomAnim = true;

CHECKEM.RegisterCheckEmGate("ce_sensor_input", "Input", "Sensors");


local keys = {};
keys[1] = IN_FORWARD;
keys[2] = IN_BACK;
keys[3] = IN_MOVELEFT;
keys[4] = IN_MOVERIGHT;
keys[5] = IN_JUMP;
keys[6] = IN_ATTACK;
keys[7] = IN_ATTACK2;
keys[8] = IN_RELOAD;
keys[9] = IN_SPEED;

function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetModel("models/checkem/input.mdl");
	self:SetSkin(2);
	timer.Simple(.2, function()
		if (IsValid(self)) then self:ResetSequence(self:LookupSequence("Inputs")); end
		if (SERVER) then
			timer.Create(tostring(self) .. "sounds", .02, 5, function()
				if (IsValid(self)) then
					self:EmitSound("checkem/pp_pop.mp3", 68, math.random(85, 92));
				end
			end);
		end
	end);
end


function ENT:CheckOutputs(op, on)
	if (op == 10) then
		if (on) then
			//loop through output ents, see camera? put driver in it
			//make cameras wireable
		else
			//remove driver from camera if he has one
		end
	end
end


function ENT:Think()
	self.BaseClass.Think(self);
	if (!IsValid(self.WeldedTo)) then return; end
	if (!self.WeldedTo:IsVehicle()) then return; end
	if (!IsValid(self.WeldedTo:GetDriver())) then
		for i = 1, 10 do
			if (self:GetOutputOn(i)) then
				self:ChangeOPState(i, false, true);
			end
		end
		self:SetSkin(2);
		return;
	end

	if (!self:GetOutputOn(10)) then self:ChangeOPState(10, true, true); self:SetSkin(3); end

	local ply = self.WeldedTo:GetDriver();

	for k, v in pairs(keys) do
		if (ply:KeyDown(v)) then
			if (!self:GetOutputOn(k)) then self:ChangeOPState(k, true, true); end
		else
			if (self:GetOutputOn(k)) then self:ChangeOPState(k, false, true); end
		end
	end

	self:NextThink(CurTime());
	return true;
end

