ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Counter";
ENT.Author			= "Aska";
ENT.Purpose			= "Every ON input will increment the top number.  Will output ON when the top number equals the bottom number";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 2;

CHECKEM.RegisterCheckEmGate("ce_counter", "Counter", "Logic");

CHECKEM.SetupCustomVars("ce_counter",
	{"Starting Number", "Count", 0, 0, 512},
	{"Number To Reach", "Reach", 10, 1, 512}
);

ENT.InputTexts = {"Increment", "Reset"};

function ENT:Initialize()
	self.BaseClass.Initialize(self);

	self:ResetSequence(self:LookupSequence("Ip0"));
	timer.Simple(.2, function()
		if (IsValid(self)) then
			self:ResetSequence(self:LookupSequence("Ip1t"));
			timer.Create(tostring(self) .. "sounds", .06, 3, function()
				if (SERVER && IsValid(self)) then self:EmitSound("checkem/pp_pop.mp3", 68, math.random(85, 92)); end
			end)
		end
	end)

	self:SetSkin(0);

	self.CanIncrement = true;
	self.CanReset = true;
end


function ENT:Think()
	//overriddin
end


function ENT:IncrementCounter()
	local count, reach = self:GetVariable("Count"), self:GetVariable("Reach");
	local new = math.Clamp((count + 1), 0, reach);
	self:SetVariable("Count", new);
	if (new == reach && !self:GetOutputOn(1)) then
		self:On();
	end
end

function ENT:ResetCounter()
	self:SetVariable("Count", 0);
	self:Off();
end


function ENT:CheckInputs(ip, on)
	if (ip == 1) then
		if (on) then
			if (self.CanIncrement) then
				self.CanIncrement = false;
				self:IncrementCounter();
			end
		else
			self.CanIncrement = true;
		end
	else
		if (on) then
			if (self.CanReset) then
				self.CanReset = false;
				self:ResetCounter();
			end
		else
			self.CanReset = true;
		end
	end
end

function ENT:Off()
	self:ChangeOPState(1, false);
	self:SetSkin(0);
end

function ENT:On()
	self:ChangeOPState(1, true);
	self:SetSkin(1);
end


function ENT:VariableChanged(var, val)
	local on = self:GetOutputOn(1);
	if (var == "Count") then
		local reach = self:GetVariable("Reach");
		if (val > reach) then self:SetVariable("Reach", val); end
		if (val >= reach && !on) then self:On(); end
		if (val < reach && on) then self:Off() end
	end
	if (var == "Reach") then
		local count = self:GetVariable("Count");
		if (val < count) then self:SetVariable("Count", val); end
		if (val <= count && !on) then self:On() end
		if (val > count && on) then self:Off(); end
	end
end


if (CLIENT) then


surface.CreateFont("CE_Counter_Big", {
	size = 52,
	weight = 600,
	antialias = true,
	font = "Arial"
});

surface.CreateFont("CE_Counter_Small", {
	size = 24,
	weight = 600,
	antialias = true,
	font = "Arial"
});



function ENT:Draw()
	self.BaseClass.Draw(self);
	self:DrawCounter();
end

function ENT:DrawCounter()
	local pos = self:GetPos();
    local up = self:GetUp();
    local right = self:GetRight();
	
	//local scale = self:GetScale();
	
    pos = (pos + (up * (1.02/* * scale*/)));
	pos = (pos + (right * .185));
    
    local ang = self:GetAngles();
    local rot = Vector(-85.5, 90, 0);
    ang:RotateAroundAxis(ang:Up(), rot.y);
	
	local count, reach = self:GetVariable("Count"), self:GetVariable("Reach");
	
	local clr = (self:GetOutputOn(1) && Color(218, 237, 218, 255)) || Color(203, 154, 154, 162);
	
	local s = .1;
    cam.Start3D2D(pos, ang, (s/* * scale*/))
    
		local size = ((1 / s) * 4);
		
		draw.SimpleText(tostring(count), "CE_Counter_Big", (size * .05), (size * -.2), clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		draw.SimpleText(tostring(reach), "CE_Counter_Small", (size * .038), (size * .69), clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		
    cam.End3D2D()
end


end
