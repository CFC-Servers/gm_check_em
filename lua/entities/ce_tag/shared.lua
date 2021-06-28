ENT.Type 			= "anim";
ENT.Base 			= "ce_base";
ENT.PrintName		= "Tag";
ENT.Author			= "Aska";
ENT.Purpose			= "Entity to be sensed by Tag Sensors";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.SetNumInputs = 0;
ENT.SetNumOutputs = 0;

ENT.CheckEmGate = false;

CHECKEM.RegisterCheckEmGate("ce_tag", "Tag", "Sensors");

CHECKEM.SetupCustomVars("ce_tag",
	{"Color", "clr", "White", "Select Color", false, {"Red", "Green", "Blue", "Violet", "White", "Yellow", "Orange"}},
	{"Sense Only From Tag", "TagOnly", false}
);


local clrs = {};
clrs["Red"] = Color(255, 0, 0, 255);
clrs["Green"] = Color(0, 255, 0, 255);
clrs["Blue"] = Color(0, 0, 255, 255);
clrs["Violet"] = Color(255, 0, 255, 255);
clrs["White"] = Color(255, 255, 255, 255);
clrs["Yellow"] = Color(255, 255, 0, 255);
clrs["Orange"] = Color(255, 155, 0, 255);

function ENT:Initialize()

	self.BaseClass.Initialize(self);
	self.OffDelay = 0;

	if (SERVER) then
				
		self:SetModel("models/checkem/tag.mdl")
		
		self:PhysicsInit(SOLID_VPHYSICS);

		self:SetCollisionGroup(COLLISION_GROUP_WEAPON);

	else
		
		local glass = ClientsideModel("models/checkem/tagb.mdl");
		glass:SetPos(self:GetPos());
		glass:SetAngles(self:GetAngles());
		glass:SetParent(self);
		glass:SetColor(clrs[self:GetVariable("clr")]);
		self.Glass = glass;

		/*local refract = ClientsideModel("models/checkem/tagr.mdl");
		refract:SetPos(self:GetPos());
		refract:SetAngles(self:GetAngles());
		refract:SetParent(self);
		self.Refract = refract;*/
		
	end

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then phys:Wake(); end

	//fix the parenting of the bulb
	timer.Simple(0, function() local phys = self:GetPhysicsObject() if (phys:IsValid()) then phys:EnableMotion(true);  end end);
	timer.Simple(0, function() local phys = self:GetPhysicsObject() if (phys:IsValid()) then phys:EnableMotion(false);  end end);
	
end

if (SERVER) then
	function ENT:ExtendOn()
		if (self:GetSkin() != 1) then self:SetSkin(1); end
		self.OffDelay = (CurTime() + .1);
	end

	function ENT:Think()
		if (CurTime() >= self.OffDelay && self:GetSkin() != 0) then
			self:SetSkin(0);
		end
	end
end

function ENT:VariableChanged(var, val)
	if (CLIENT) then
		if (var == "clr") then
			self.Glass:SetColor(clrs[val]);
		end
	end
	if (SERVER) then
		if (var == "TagOnly") then
			if (IsValid(self.WeldedTo)) then
				self.WeldedTo.CHKMTagged = !val;
				self.WeldedTo.CHKMTag = (!val && self) || nil;
			end
		end
	end
end

if (CLIENT) then


local mat = Material("sprites/light_glow02_add");
function ENT:DrawLight()
	local atch = self:GetAttachment(self:LookupAttachment("light"));
	if (!atch) then return; end
	local pos = atch.Pos;

	local size = 32;

	render.SetMaterial(mat);
	render.DrawSprite(pos, size, size, clrs[self:GetVariable("clr")]);
end


function ENT:Draw()
	self.BaseClass.Draw(self);
	if (self:GetSkin() == 1) then self:DrawLight(); end //we on?  light up!
end


end
