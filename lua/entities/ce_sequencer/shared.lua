ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Sequencer";
ENT.Author			= "Aska";
ENT.Purpose			= "Place chips on the sequencer, when the sequencer turns ON it will start activating the chips attached to it in sequence";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 2;

CHECKEM.RegisterCheckEmGate("ce_sequencer", "Sequencer", "Sequencer");

CHECKEM.SetupCustomVars("ce_sequencer",
	{"BPM", "bpm", 120, 10, 999},
	{"Rows", "row", 2, 1, 5},
	{"Columns", "col", 5, 1, 100},
	{"Loop", "loop", false},
	{"Reset When Off", "rst", false}
);

ENT.InputTexts = {"Play", "Reset"};


//multi-dimensional array
//one entry for every X
//one entry in each X for every Y


function ENT:SetupDataTables()
	self:DTVar("Float", 0, "Place");
end

function ENT:Initialize()
	self.BaseClass.Initialize(self);

	self:SetModel("models/checkem/sequencer.mdl");

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then phys:Wake(); end
	
	self.NumX, self.NumY = 5, 2;

	self.Place = 0;
	self.Cur = 0;

	if (CLIENT) then return; end
	self.Sequence = {};
	for i = 1, 5 do
		self.Sequence[i] = {}; //column
		for u = 1, 2 do
			self.Sequence[i][u] = nil; //row = entity
		end
	end
end

function ENT:GetNumY()
	return self.NumY;
end

function ENT:GetNumX()
	return self.NumX;
end

function ENT:GetSpeed()
	return self:GetVariable("bpm");
end

function ENT:GetX(i)
	if (i) then return self.Sequence[i]; end
	return self.Sequence;
end

function ENT:GetY(x, i)
	if (i) then return self.Sequence[x][i]; end
	return self.Sequence[x];
end


function ENT:ChangeNumY(num)
	local cur = self:GetNumY();
	
	self.NumY = num;

	if (CLIENT) then return; end

	if (num < cur) then
		//potentially deleting stuff
		for k, v in pairs(self:GetX()) do
			for i = (num + 1), cur do
				local ent = self:GetY(k, i);
				if (IsValid(ent)) then
					ent:Remove();
				end
				self.Sequence[k][i] = nil;
			end
		end

		return;
	end
end

function ENT:ChangeNumX(num)
	local cur = self:GetNumX();

	self.NumX = num;

	if (CLIENT) then return; end
	
	if (self:GetDTFloat(1) > num) then self:SetDTFloat(1, num); end

	if (num < cur) then
		//potentially deleting stuff
		for i = (num + 1), cur do
			for u = 1, self:GetNumY() do
				local ent = self.Sequence[i][u];
				if (IsValid(ent)) then
					ent:Remove();
				end
			end
			self.Sequence[i] = nil;
		end

		return;
	end

	if (num > cur) then
		//just increase size
		for i = (cur + 1), num do
			self.Sequence[i] = {};
			self.Sequence[i] = {};
			for u = 1, self:GetNumY() do
				self.Sequence[i][i] = nil;
			end
		end

		return;
	end
end



function ENT:Think()
	self.BaseClass.Think(self);
	self:SetPoseParameter("Rows", self:GetVariable("row"));
	self:SetPoseParameter("Columns", self:GetVariable("col"));

	if (SERVER) then
		local on = self:GetInputOn(1);

		local spd = self:GetSpeed();
		local loop = self:GetVariable("loop");

		if (on) then self:IncrementPlace(spd); end
		self:HandleIO();
	end

	//self.Place = math.Approach(self.Place, self:GetDTFloat(1), (FrameTime() * 20));
	self:SetPoseParameter("Tick", self:GetDTFloat(1));

	self:NextThink(CurTime());
	return true;
end


function ENT:Reset()
	local place = self.Cur;
	self.Cur = 0;
	self:SetDTFloat(1, 0);
	self.CanReset = false;
	self:SetSkin(0);
	self:ChangeOPState(1, false, true);
	if (place != 0) then
		for k, v in pairs(self:GetY(place)) do
			if (IsValid(v) && v["SequenceOff"] != nil) then v:SequenceOff(); end
		end
	end
end

function ENT:CheckInputs(ip, on)
	if (SERVER) then
		if (ip == 1 && !on) then
			if (self:GetVariable("rst")) then self:Reset(); end
		end
		if (ip == 2) then
			if (on && self.CanReset) then self:Reset(); end
			if (!on) then self.CanReset = true; end
		end
	end
end

function ENT:GetSequencePos(x, y)
	local name = (tostring(y) .. "_" .. tostring(x));
	local atch = self:GetAttachment(self:LookupAttachment(name));
	if (!atch) then return 0, 0; end
	return atch.Pos;
end

function ENT:GetSequenceAng(x, y)
	local name = (tostring(y) .. "_" .. tostring(x));
	local atch = self:GetAttachment(self:LookupAttachment(name));
	if (!atch) then return 0, 0; end
	return atch.Ang;
end

function ENT:VariableChanged(var, val)
	if (var == "row") then self:ChangeNumY(val); end
	if (var == "col") then self:ChangeNumX(val); end
end


if (SERVER) then

function ENT:HandleIO()
	local place = self:GetDTFloat(1);
	if (place == 0) then return; end
	local cur = math.Clamp((math.floor(place) + 1), 0, self:GetNumX());
	if (self.Cur != cur) then

		if (self.Cur != 0) then
			for k, v in pairs(self:GetY(math.Clamp(self.Cur, 0, self:GetNumX()))) do
				if (IsValid(v)) then v:SequenceOff(); end
			end
		end

		if (cur <= self:GetNumX()) then
			for k, v in pairs(self:GetY(cur)) do
				if (IsValid(v)) then v:SequenceOn(); end
			end
		end

		self.Cur = cur;
	end
end

function ENT:IncrementPlace(spd)
	local cur = self:GetDTFloat(1);
	local p = cur + (spd / 4020);
	if (p >= self:GetNumX()) then
		if (self:GetVariable("loop")) then
			p = (p - self:GetNumX());
			self:SetSkin(1);
			self:ChangeOPState(1, true, true);
			timer.Simple(0, function()
				self:SetSkin(0);
				self:ChangeOPState(1, false, true);
			end);
			self:SetDTFloat(1, p);
			self.Cur = 0;

			//turn off anything in the last slot
			local tbl = self:GetY(self:GetNumX());
			for k, v in pairs(tbl) do
				if (IsValid(v)) then v:SequenceOff(); end
			end
		else
			if (!self:GetOutputOn(1)) then
				p = self:GetNumX();
				self:SetSkin(1);
				self:ChangeOPState(1, true, true);
				self:SetDTFloat(1, p);

				//turn off anything in the last slot
				local tbl = self:GetY(self:GetNumX());
				for k, v in pairs(tbl) do
					if (IsValid(v)) then v:SequenceOff(); end
				end
			end
		end
	else
		self:SetDTFloat(1, p);
	end
end

function ENT:AttachGate(ent, x, y)

	if (!IsValid(ent)) then return; end
	if (!ent["SequenceOn"]) then ent:Remove(); return; end
	if (!x || !y) then ent:Remove() return; end
	if (self:SpaceTaken(x, y)) then self:RemoveGate(x, y); end

	ent:SetPos(self:GetSequencePos(x, y));

	local ang = self:GetSequenceAng(x, y);
	ent:SetAngles(ang);

	constraint.Weld(ent, self, 0, 0, 0, true);

	ent:SetParent(self);
	ent.Sequenced = true;
	ent:ResetSequence(ent:LookupSequence("OpS"));

	local phys = ent:GetPhysicsObject();
	if (phys:IsValid()) then phys:EnableCollisions(false); end

	self.Sequence[x][y] = ent;

end

function ENT:SpaceTaken(x, y)
	return IsValid(self.Sequence[x][y]);
end

function ENT:RemoveGate(x, y)
	local e = self.Sequence[x][y];
	if (IsValid(e)) then
		e:Remove();
		self.Sequence[x][y] = nil;
	end
end

function ENT:DoOnDupe()

	local col, row = self:GetVariable("col"), self:GetVariable("row");
	self.NumX, self.NumY = col, row;

	self.CanReset = true;

	self.Sequence = {};
	for i = 1, col do
		self.Sequence[i] = {}; //column
		for u = 1, row do
			self.Sequence[i][u] = nil; //row = entity
		end
	end

	local seq = self.DupeSeq;
	for x, y in pairs(seq) do
		for i, ent in pairs(y) do
			self:AttachGate(ent, x, i);
		end
	end
	self.DupeSeq = nil;
end


end
