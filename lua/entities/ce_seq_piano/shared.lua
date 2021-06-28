ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Piano";
ENT.Author			= "Aska";
ENT.Purpose			= "TURN IT ON AND OFF YOULL BE piano'd BY IT";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;
ENT.SetNumOutputs = 0;

CHECKEM.RegisterCheckEmGate("ce_seq_piano", "Piano", "Sequencer");


local keys = {"C", "D", "E", "F", "G", "A", "B", "C#", "D#", "F#", "G#", "A#"};


local function CreateNoteEditor(vars, gate, name, var)
	local msc = vgui.Create("CheckEmMusic", vars);

	if (type(gate) == "string") then
		CHECKEM.UpdateLocalVar(gate, name, var.val);
		msc.OnValueChanged = function(pnl, val)
			CHECKEM.UpdateLocalVar(gate, name, val);
		end
	else
		msc.OnValueChanged = function(pnl, val)
			gate:ChangeVariable(name, val);
		end
	end

	msc.vars = vars;

	return msc;
end

local function CreateInstBox(vars, gate, name, var)
	local inst = vgui.Create("DComboBox", self);
	inst.Folder = "Piano";
	inst:SetText(inst.Folder);

	local _, keyboards = file.Find("sound/checkem/instruments/keyboard/*", "GAME");
	for k, v in pairs(keyboards) do
		inst:AddChoice(v);
	end

	if (type(gate) == "string") then
		CHECKEM.UpdateLocalVar(gate, name, var.val);
		inst.OnSelect = function(pnl, index, val, data)
			CHECKEM.UpdateLocalVar(gate, name, val);
		end
	else
		local cur = gate:GetVariable(name);
		inst:SetText(cur);
		inst.OnSelect = function(pnl, index, val, data)
			gate:ChangeVariable(name, val);
		end
	end

	return inst;
end

CHECKEM.SetupCustomVars("ce_seq_piano",
	{"Pitch", "Pitch", 1, CreateNoteEditor},
	{"Instrument", "Inst", "Piano", CreateInstBox},
	{"Sustain", "Sus", true},
	{"Volume", "Vol", 1, .1, 1, 2},
	{"Octave", "Oct", 4, 3, 6}
);

function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:ResetSequence(self:LookupSequence("Op0"));
	if (SERVER) then
		self:SetSkin(0);
		//self.PlaySound = "checkem/instruments/Piano/";
		self.PlaySound = CreateSound(self, "checkem/instruments/keyboard/Piano/C3.wav");
	end
end

function ENT:VariableChanged(var, val)
	if (var == "Oct" && val == 6 && self:GetVariable("Pitch") != 1) then
		self:SetVariable("Oct", 5);
	end
	local pitch, oct = self:GetVariable("Pitch"), self:GetVariable("Oct");
	local inst = self:GetVariable("Inst");

	if (SERVER) then
		local t = false;
		if (self.PlaySound:IsPlaying()) then self.PlaySound:Stop(); t = true; end
		self.PlaySound = CreateSound(self, "checkem/instruments/keyboard/" .. inst .. "/" .. keys[pitch] .. oct .. ".wav");
		if (t) then self.PlaySound:Play(); self.PlaySound:ChangeVolume(self:GetVariable("Vol"), 0); end
	end
end

if (SERVER) then



function ENT:SequenceOn()
	self:SetSkin(1);

	local str = tostring(self) .. "ChkmPlaySound";
	if (timer.Exists(str)) then self.PlaySound:Stop(); timer.Destroy(str); end

	self.PlaySound:Play();
	self.PlaySound:ChangeVolume(self:GetVariable("Vol"), 0);

	timer.Create(str, SoundDuration("checkem/instruments/keyboard/" .. self:GetVariable("Inst") .. "/" .. keys[self:GetVariable("Pitch")] .. self:GetVariable("Oct") .. ".wav"),
		1,
	function()
		if (IsValid(self)) then self.PlaySound:Stop(); end	
	end);
	//self:EmitSound(self.PlaySound .. keys[self:GetVariable("Pitch")] .. tostring(self:GetVariable("Oct")) .. ".wav");
end

function ENT:SequenceOff()
	self:SetSkin(0);
	if (!self:GetVariable("Sus")) then self.PlaySound:FadeOut(.3); end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self);
	if (self.PlaySound:IsPlaying()) then self.PlaySound:Stop(); end
end

function ENT:DoOnDupe()
	local pitch, oct = self:GetVariable("Pitch"), self:GetVariable("Oct");
	local inst = self:GetVariable("Inst");
	self.PlaySound = CreateSound(self, "checkem/instruments/keyboard/" .. inst .. "/" .. keys[pitch] .. oct .. ".wav");
	self.PlaySound:ChangeVolume(self:GetVariable("Vol"), 0);
end



else




surface.CreateFont("CE_Inst_Note", {
	size = 24,
	weight = 600,
	antialias = true,
	font = "Arial"
});



function ENT:Draw()
	self.BaseClass.Draw(self);
	self:DrawNote();
end

function ENT:DrawNote()
	local pos = self:GetPos();
    local up = self:GetUp();
    local right = self:GetRight();
	
	//local scale = self:GetScale();
	
    pos = (pos + (up * (1.02/* * scale*/)));
	pos = (pos + (right * .185));
    
    local ang = self:GetAngles();
    local rot = Vector(-85.5, 90, 0);
    ang:RotateAroundAxis(ang:Up(), rot.y);
	
	local pitch, octave = self:GetVariable("Pitch"), self:GetVariable("Oct");
	
	local clr = (self:GetSkin() == 1 && Color(218, 237, 218, 255)) || Color(203, 154, 154, 162);
	
	local s = .1;
    cam.Start3D2D(pos, ang, (s/* * scale*/))
    
		local size = ((1 / s) * 4);
		
		local str = tostring(keys[pitch]);
		if (pitch <= 7) then str = str .. "-"; end
		draw.SimpleText(str .. tostring(octave), "CE_Inst_Note", (size * .05), (size * .7), clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		
    cam.End3D2D()
end



end
