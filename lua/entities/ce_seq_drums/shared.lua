ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Drums";
ENT.Author			= "Aska";
ENT.Purpose			= "TURN IT ON AND OFF YOULL BE percussioned BY IT";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;
ENT.SetNumOutputs = 0;

CHECKEM.RegisterCheckEmGate("ce_seq_drums", "Drums", "Sequencer");


local function CreateInstBox(vars, gate, name, var)
	local inst = vgui.Create("CheckEmDrums", self);

	if (type(gate) == "string") then
		CHECKEM.UpdateLocalVar(gate, name, var.val);
		inst.OnValueChanged = function(pnl, val)
			CHECKEM.UpdateLocalVar(gate, name, val);
		end
	else
		local cur = gate:GetVariable(name);
		inst:SetText(cur);
		inst.OnValueChanged = function(pnl, val)
			gate:ChangeVariable(name, val);
		end
	end

	return inst;
end


CHECKEM.SetupCustomVars("ce_seq_drums",
	{"Sustain", "Sus", true},
	{"Volume", "Vol", 1, .1, 1, 2},
	{"Instrument", "Inst", "Rock Drums/kick.wav", CreateInstBox}
);

function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:ResetSequence(self:LookupSequence("Op0"));
	if (SERVER) then
		self:SetSkin(0);
		//self.PlaySound = "checkem/instruments/Piano/";
		self.PlaySound = CreateSound(self, "checkem/instruments/drums/Rock Drums/kick.wav");
	end
end

function ENT:VariableChanged(var, val)
	if (SERVER) then
		local t = false;
		if (self.PlaySound:IsPlaying()) then self.PlaySound:Stop(); t = true; end
		self.PlaySound = CreateSound(self, "checkem/instruments/drums/" .. self:GetVariable("Inst"));
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

	timer.Create(str, SoundDuration("checkem/instruments/drums/" .. self:GetVariable("Inst")),
		1,
	function()
		if (IsValid(self)) then self.PlaySound:Stop(); end	
	end);
	//self:EmitSound(self.PlaySound .. keys[self:GetVariable("Pitch")] .. tostring(self:GetVariable("Oct")) .. ".wav");
end

function ENT:SequenceOff()
	self:SetSkin(0);
	if (!self:GetVariable("Sus")) then self.PlaySound:FadeOut(.12); end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self);
	if (self.PlaySound:IsPlaying()) then self.PlaySound:Stop(); end
end

function ENT:DoOnDupe()
	self.PlaySound = CreateSound(self, "checkem/instruments/drums/" .. self:GetVariable("Inst"));
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
	//self:DrawNote();
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
