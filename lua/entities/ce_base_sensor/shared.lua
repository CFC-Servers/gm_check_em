ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Sensor Base";
ENT.Author			= "Aska";
ENT.Purpose			= "Senses Things";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;

local drawsphere;
local triggersenses;

if (CLIENT) then
	drawsphere = CreateClientConVar("checkem_drawradspheres", 0, true, false);
	triggersenses = CreateClientConVar("checkem_disabletriggersensors", 0, true, true);
end

function ENT:Think()

	if (self.Sense != nil) then
		local ply = self:GetNetworkedEntity("CHKMOwner");
		if (IsValid(ply) && tonumber(ply:GetInfo("checkem_disabletriggersensors")) == 0) then
			self:Sense();
		else
			for i = 1, self:NumOutputs() do
				if (self:GetOutputOn(i)) then
					self:ChangeOPState(i, false, true);
				end
			end
		end
	end

	if (SERVER) then
		
	end

	if (CLIENT) then

		local sphere = self.RadialSphere;
		if (IsValid(sphere)) then
			
			local srad = self:GetVariable("SRad");
			if (self:GetVariable("Cube") || (!drawsphere:GetBool() && !CHECKEM.PlayerHoldingTool(LocalPlayer()))) then
				srad = .02;
			end

			if (sphere:GetModelScale() <= .02) then
				sphere:SetNoDraw(true);
			else
				sphere:SetNoDraw(false);
			end

			local dist = math.Clamp(math.abs(srad - self.RadSize) * .1, .02, 20);
			self.RadSize = math.Approach(self.RadSize, srad, (FrameTime() * (200 * dist)));
			local rad = self.RadSize;
			sphere:SetModelScale(rad, 0);

			sphere:SetSkin((self:GetOutputOn(1) && 1) || 0);
		end

		self:UpdateRenderBounds();

	end

	self:NextThink(CurTime());
	return true;

end
