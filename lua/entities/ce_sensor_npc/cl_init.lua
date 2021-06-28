
include('shared.lua')

local off = Material("models/checkem/triggerradius");
local on = Material("models/checkem/triggerradius2");

function ENT:Draw()
	self.BaseClass.Draw(self);

	if (self:GetVariable("Cube")) then
		render.SetMaterial((self:GetOutputOn(1) && on) || off);

		local x, y, z = self:GetVariable("X"), self:GetVariable("Y"), self:GetVariable("Z");
		local lx, ly, lz = self.lerpx, self.lerpy, self.lerpz;

		if (LocalPlayer():GetInfo("checkem_drawradspheres") == "0" && !CHECKEM.PlayerHoldingTool(LocalPlayer())) then
			x, y, z = 0, 0, 0;
		end

		local distx = math.Clamp(math.abs(x - lx) * .1, .02, 20);
		self.lerpx = math.Approach(self.lerpx, x, (FrameTime() * (200 * distx)));
		local disty = math.Clamp(math.abs(y - ly) * .1, .02, 20);
		self.lerpy = math.Approach(self.lerpy, y, (FrameTime() * (200 * disty)));
		local distz = math.Clamp(math.abs(z - lz) * .1, .02, 20);
		self.lerpz = math.Approach(self.lerpz, z, (FrameTime() * (200 * distz)));
		lx, ly, lz = self.lerpx, self.lerpy, self.lerpz;

		render.DrawBox(self:GetPos(), Angle(0, 0, 0), Vector(-lx, -ly, -lz), Vector(lx, ly, lz), Color(255, 255, 255, 255));
	end
end
