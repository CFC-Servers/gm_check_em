
include('shared.lua')

local cx = CreateClientConVar("ce_test_x", 0, true, false);
local cy = CreateClientConVar("ce_test_y", 0, true, false);
local cz = CreateClientConVar("ce_test_z", 0, true, false);

CHECKEM.HandleLayout("ce_sensor_input", function(panel, ent)
		ent:SetModel("models/checkem/input.mdl");
		ent:SetSkin(0);
		ent:SetAngles(Angle(0, 180, 0));
		panel:SetCamPos(Vector(0, -3, 18));
		panel:SetLookAt(Vector(0, -3, 0));
	end);

function ENT:Draw()
	self.BaseClass.Draw(self);
	self:DrawIcons();
end

local off = {
	{surface.GetTextureID("models/checkem/Arrow_1"), 90},
	{surface.GetTextureID("models/checkem/Arrow_1"), -90},
	{surface.GetTextureID("models/checkem/Arrow_1"), 180},
	{surface.GetTextureID("models/checkem/Arrow_1"), 0},
	{surface.GetTextureID("models/checkem/Jump_1"), 0},
	{surface.GetTextureID("models/checkem/mouseleft_1"), 0},
	{surface.GetTextureID("models/checkem/mouseright_1"), 0},
	{surface.GetTextureID("models/checkem/Reload_1"), 0},
	{surface.GetTextureID("models/checkem/Sprint_1"), 0},
	{surface.GetTextureID("models/checkem/Camera_1"), 0},
};

local on = {
	{surface.GetTextureID("models/checkem/Arrow_2"), -45},
	{surface.GetTextureID("models/checkem/Arrow_2"), 0},
	{surface.GetTextureID("models/checkem/Arrow_2"), 45},
	{surface.GetTextureID("models/checkem/Arrow_2"), 90},
	{surface.GetTextureID("models/checkem/Jump_2"), 0},
	{surface.GetTextureID("models/checkem/mouseleft_2"), 0},
	{surface.GetTextureID("models/checkem/mouseright_2"), 0},
	{surface.GetTextureID("models/checkem/Reload_2"), 0},
	{surface.GetTextureID("models/checkem/Sprint_2"), 0},
	{surface.GetTextureID("models/checkem/Camera_2"), 0},
};


function ENT:DrawIcons()
	local pos = self:GetPos();
    local up = self:GetUp();
    local right = self:GetRight();
	
	//local scale = self:GetScale();
	
    pos = (pos + (up * (1.02/* * scale*/)));
	pos = (pos + (right * .185));
    
    local ang = self:GetAngles();
    local rot = Vector(-85.5, 90, 0);
    ang:RotateAroundAxis(ang:Up(), rot.y);
	
	local clr = (self:GetOutputOn(1) && Color(218, 237, 218, 255)) || Color(203, 154, 154, 162);
	
	local s = .1;
    cam.Start3D2D((pos + (self:GetUp() * .05)), ang, (s/* * scale*/))
    
		local size = ((1 / s) * 4);
		
		surface.SetDrawColor(Color(255, 255, 255, 255));

		for i = 1, 5 do
			local mat = (self:GetOutputOn(i) && on[i][1]) || off[i][1];
	    	surface.SetTexture(mat);
			surface.DrawTexturedRectRotated(-16, (-96 + ((size * 1.2) * (i - 1))), size, size, off[i][2]);
		end
		for i = 1, 5 do
			local mat = (self:GetOutputOn(i+5) && on[i+5][1]) || off[i+5][1];
	    	surface.SetTexture(mat);
			surface.DrawTexturedRect(48, (-116 + ((size * 1.2) * (i - 1))), size, size, off[i][2]);
		end

    cam.End3D2D()
end
