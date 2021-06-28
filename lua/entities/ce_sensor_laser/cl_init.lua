
include('shared.lua')

local laser = CreateClientConVar("checkem_drawlasers", 0, false, false);

function ENT:Draw()
	self.BaseClass.Draw(self);
	if (!laser:GetBool() && !CHECKEM.PlayerHoldingTool(LocalPlayer())) then return; end
	self:DrawLaser();
end


local off = Material("cable/redlasers");
local on = Material("cable/greenlaser");
function ENT:DrawLaser()
	local mat = off;
	if (self:GetOutputOn(1)) then
		mat = on;
	end

	local tr = util.QuickTrace(self:GetPos(), (self:GetUp() * self:GetVariable("Dis")), self);
	render.SetMaterial(mat);
	render.DrawBeam(self:GetPos(), tr.HitPos, 3, 0, 0, mat);
end
