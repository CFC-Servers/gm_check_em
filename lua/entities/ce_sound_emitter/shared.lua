ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Sound Emitter";
ENT.Author			= "Aska";
ENT.Purpose			= "TURN IT ON AND OFF YOULL BE sounded BY IT";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 1;
ENT.SetNumOutputs = 0;

CHECKEM.RegisterCheckEmGate("ce_sound_emitter", "Sound Emitter", "Logic");
CHECKEM.RegisterCheckEmGate("ce_sound_emitter", "Sound Emitter", "Sequencer");


local b;

local function CreateSoundBrowser(vars, gate, name, var)
	local msc = vgui.Create("CheckEmSoundBrowser", vars);

	if (type(gate) == "string") then
		CHECKEM.UpdateLocalVar(gate, name, var.val);
		msc.OnValueChanged = function(pnl, val)
			CHECKEM.UpdateLocalVar(gate, name, val);
		end
	else
		if (gate:GetVariable("Snd") != "") then msc.txt:SetText(gate:GetVariable("Snd")); end
		msc.OnValueChanged = function(pnl, val)
			gate:ChangeVariable(name, val);
		end
	end

	msc.vars = vars;
	b = msc;

	return msc;
end

local function CreatePitchSlider(vars, gate, name, var)
	local msc = vgui.Create("DNumSlider", vars);
	msc.Label:SetTextColor(Color(0, 0, 0, 255));
	msc:SetText("Pitch");
	msc:SetMinMax(0, 4);

	if (type(gate) == "string") then
		msc:SetValue(1);
		CHECKEM.UpdateLocalVar(gate, name, var.val);
		msc.OnValueChanged = function(pnl, val)
			b.pitch = val;
			CHECKEM.UpdateLocalVar(gate, name, val);
		end
	else
		msc:SetValue(gate:GetVariable("Pch"));
		msc.OnValueChanged = function(pnl, val)
			b.pitch = val;
			gate:ChangeVariable(name, val);
		end
	end

	msc.vars = vars;

	return msc;
end


CHECKEM.SetupCustomVars("ce_sound_emitter",
	{"Sound", "Snd", "", CreateSoundBrowser},
	{"Sustain", "Sus", true},
	{"Volume", "Vol", 1, .1, 1, 2},
	{"Pitch", "Pch", 1, CreatePitchSlider}
);


function ENT:calcpitch()
	return (50 + (50 * self:GetVariable("Pch")));
end

function ENT:Initialize()
	self.BaseClass.Initialize(self);
	if (SERVER) then
		self:SetModel("models/checkem/basechip2.mdl");

		self:ResetSequence(self:LookupSequence("Ip0"));
		timer.Simple(.2, function()
			self:ResetSequence(self:LookupSequence("Ip1"));
			self:EmitSound("checkem/pp_pop.mp3", 68, math.random(85, 92));
		end)
		
		self:SetSkin(8);
		//self.PlaySound = "checkem/instruments/Piano/";
		self.PlaySound = CreateSound(self, "common/NULL.WAV");
	end
end

function ENT:VariableChanged(var, val)
	if (SERVER) then
		local t = false;
		if (self.PlaySound:IsPlaying()) then self.PlaySound:Stop(); t = true; end
		self.PlaySound = CreateSound(self, self:GetVariable("Snd"));
		if (t) then
			self.PlaySound:Play();
			self.PlaySound:ChangeVolume(self:GetVariable("Vol"), 0);
			self.PlaySound:ChangePitch(self:calcpitch(), 0);
		end
	end
end


function ENT:CheckInputs(ip, on)
	if (SERVER) then
		self:SetSkin((on && 9) || 8);
		if (on) then
			self:DoPlaySound();
		else
			if (!self:GetVariable("Sus")) then self.PlaySound:FadeOut(.12); end
		end
	end
end


if (SERVER) then


function ENT:DoPlaySound()
	local str = tostring(self) .. "ChkmPlaySound";
	if (timer.Exists(str)) then self.PlaySound:Stop(); timer.Destroy(str); end

	self.PlaySound:Play();
	self.PlaySound:ChangeVolume(self:GetVariable("Vol"), 0);
	self.PlaySound:ChangePitch(self:calcpitch(), 0);

	local p = (.5 + (.5 * self:GetVariable("Pch"))); //"Pch" == 0 means we're multiplying by .5
	local dur = SoundDuration(self:GetVariable("Snd")) * (1 / p);
	timer.Create(str, dur,
		1,
	function()
		if (IsValid(self)) then self.PlaySound:Stop(); end	
	end);
end

function ENT:SequenceOn()
	self:SetSkin(9);
	self:DoPlaySound();
	//self:EmitSound(self.PlaySound .. keys[self:GetVariable("Pitch")] .. tostring(self:GetVariable("Oct")) .. ".wav");
end

function ENT:SequenceOff()
	self:SetSkin(8);
	if (!self:GetVariable("Sus")) then self.PlaySound:FadeOut(.12); end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self);
	local snd = self.PlaySound;
	if (snd:IsPlaying()) then snd:Stop(); end
end

function ENT:DoOnDupe()
	self.PlaySound = CreateSound(self, self:GetVariable("Snd"));
	self.PlaySound:ChangeVolume(self:GetVariable("Vol"), 0);
	self.PlaySound:ChangePitch(self:calcpitch(), 0);
end


end
