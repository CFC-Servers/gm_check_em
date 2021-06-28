ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "BPM Changer";
ENT.Author			= "Aska";
ENT.Purpose			= "Changes the BPM of the sequencer that it's attached to";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;
ENT.SetNumOutputs = 0;

CHECKEM.RegisterCheckEmGate("ce_seq_bpm", "BPM Changer", "Sequencer");


CHECKEM.SetupCustomVars("ce_seq_bpm",
	{"Reset when off", "Reset", false},
	{"BPM", "BPM", 120, 10, 999}
);


if (SERVER) then


function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:ResetSequence(self:LookupSequence("Op0"));
	if (SERVER) then
		self:SetSkin(0);
		//self.PlaySound = "checkem/instruments/Piano/";
		self.oldBPM = 120;
	end
end

function ENT:SequenceOn()
	self:SetSkin(1);

	self.oldBPM = self:GetParent():GetVariable("bpm");
	self:GetParent():ChangeVariable("bpm", self:GetVariable("BPM"));
end

function ENT:SequenceOff()
	self:SetSkin(0);
	if (self:GetVariable("Reset")) then self:GetParent():ChangeVariable("bpm", self.oldBPM); end
end



else



surface.CreateFont("CE_Inst_NumBPM", {
	size = 50,
	weight = 600,
	antialias = true,
	font = "Arial"
});
surface.CreateFont("CE_Inst_BPM", {
	size = 24,
	weight = 600,
	antialias = true,
	font = "Arial"
});



function ENT:Draw()
	self.BaseClass.Draw(self);
	self:DrawBPM();
end

function ENT:DrawBPM()
	local pos = self:GetPos();
    local up = self:GetUp();
    local right = self:GetRight();
	
	//local scale = self:GetScale();
	
    pos = (pos + (up * (1.02/* * scale*/)));
	pos = (pos + (right * .185));
    
    local ang = self:GetAngles();
    local rot = Vector(-85.5, 90, 0);
    ang:RotateAroundAxis(ang:Up(), rot.y);
	
	local bpm = self:GetVariable("BPM");
	
	local clr = (self:GetSkin() == 1 && Color(218, 237, 218, 255)) || Color(203, 154, 154, 162);
	
	local s = .1;
    cam.Start3D2D(pos, ang, (s/* * scale*/))
    
		local size = ((1 / s) * 4);
		
		draw.SimpleText(tostring(bpm), "CE_Inst_NumBPM", (size * .05), (size * -.2), clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		draw.SimpleText("BPM", "CE_Inst_BPM", (size * .05), (size * .7), clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		
    cam.End3D2D()
end



end
