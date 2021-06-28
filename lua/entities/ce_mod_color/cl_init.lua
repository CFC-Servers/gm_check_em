
include('shared.lua')


function ENT:Draw()
	self.BaseClass.Draw(self);
	self:DrawColors();
end

//local maton = surface.GetTextureID("models/checkem/timer");
//local matoff = surface.GetTextureID("models/checkem/timer2");

local maton = surface.GetTextureID("models/checkem/brush1");
local matoff = surface.GetTextureID("models/checkem/brush2");

function ENT:DrawColors()
	local pos = self:GetPos();
    local up = self:GetUp();
    local right = self:GetRight();
	
	//local scale = self:GetScale();
	
    pos = (pos + (up * (1.02/* * scale*/)));
	pos = (pos + (right * .185));
    
    local ang = self:GetAngles();
    local rot = Vector(-85.5, 90, 0);
    ang:RotateAroundAxis(ang:Up(), rot.y);
	
	local s = .01;
    cam.Start3D2D(pos, ang, (s/* * scale*/))

		local num = (1 / s);

		local x, y = (num * 3.75), (num * 4);
		local size = ((1 / s) * 8);

    	surface.SetDrawColor(self:GetVariable("OnClr"));

    	surface.SetTexture(maton);
		surface.DrawTexturedRect(-x, -y, size, size);

		if (self:GetVariable("DoOff")) then
			surface.SetDrawColor(self:GetVariable("OffClr"));

			surface.SetTexture(matoff);
			surface.DrawTexturedRect(-x, -y, size, size);
		end
		
    cam.End3D2D()
end
