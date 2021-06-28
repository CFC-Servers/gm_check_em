ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Timer";
ENT.Author			= "Aska";
ENT.Purpose			= "When the chip receives an ON input it starts a timer for X seconds.  Will output ON when the timer finishes";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 2;

CHECKEM.RegisterCheckEmGate("ce_timer", "Timer", "Logic");

CHECKEM.SetupCustomVars("ce_timer",
	{"Time (in seconds)", "Time", 1, 0.1, 64, 1},
	{"Reset when off", "ROff", false}
);

ENT.InputTexts = {"Start Timer", "Reset"};

function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetSkin(0);

	self:ResetSequence(self:LookupSequence("Ip0"));
	timer.Simple(.2, function()
		if (IsValid(self)) then
			self:ResetSequence(self:LookupSequence("Ip1t"));
			timer.Create(tostring(self) .. "sounds", .06, 3, function()
				if (SERVER && IsValid(self)) then self:EmitSound("checkem/pp_pop.mp3", 68, math.random(85, 92)); end
			end)
		end
	end)

	self.Timer = 0;
	self.TimerStart = 0;
	self.CanReset = true;
end


function ENT:Think()
	local on = self:GetOutputOn(1);
	if (on) then
		if (self.Timer == 0) then self:Off(); return; end
	else
		local t = self.Timer;
		if (self.Timer != 0 && CurTime() >= t) then self:On(); end
	end
	self:NextThink(CurTime());
end

function ENT:StartTimer(t)
	self.TimerStart = CurTime();
	self.Timer = (CurTime() + t);
end

function ENT:ResetTimer()
	self.TimerStart = 0;
	self.Timer = 0;
	self:Off();
end


function ENT:CheckInputs(ip, on)
	if (ip == 1) then
		if (on) then
			if (self.Timer == 0) then self:StartTimer(self:GetVariable("Time")); end
		else
			if (self:GetVariable("ROff")) then self:ResetTimer(); end
		end
	else
		if (on) then
			if (self.CanReset) then
				self.CanReset = false;
				self:ResetTimer();
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


if (CLIENT) then


function ENT:Draw()
	self.BaseClass.Draw(self);
	self:DrawTimer();
end

//local maton = surface.GetTextureID("models/checkem/timer");
//local matoff = surface.GetTextureID("models/checkem/timer2");

function ENT:DrawTimer()
	local pos = self:GetPos();
    local up = self:GetUp();
    local right = self:GetRight();
	
	//local scale = self:GetScale();
	
    pos = (pos + (up * (1.02/* * scale*/)));
	pos = (pos + (right * .185));
    
    local ang = self:GetAngles();
    local rot = Vector(-85.5, 90, 0);
    ang:RotateAroundAxis(ang:Up(), rot.y);
	
	local start, t = self.TimerStart, (self.Timer - self.TimerStart);
	local dur = (CurTime() - start);
	
	local s = .01;
    cam.Start3D2D(pos, ang, (s/* * scale*/))

		local num = (1 / s);

		local x, y = (num * 3.8), (num * 4);
		local size = ((1 / s) * 8);

    	/*surface.SetDrawColor(Color(255, 255, 255, 255));

    	surface.SetTexture(matoff);
		surface.DrawTexturedRect(-x, -y, size, size);

		if (self.Timer != 0) then
			local frac = math.Clamp((dur / t), 0, 1);
			local w = (size * frac);
			surface.SetTexture(maton);
			surface.DrawTexturedRectUV(-x, -y, w, size, size * 8, size * 8);
		end*/

		local frac = (self.Timer == 0 && .01) || math.Clamp((dur / t), .01, 1);
		local w = (size * frac);

		surface.SetDrawColor((self:GetOutputOn(1) && Color(200, 255, 200, 255)) || Color(255, 200, 200, 255));
		surface.DrawRect(-x, -y, w, size);
		
    cam.End3D2D()
end


end
