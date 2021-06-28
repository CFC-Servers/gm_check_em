ENT.Type 			= "anim";
ENT.Base 			= "base_anim";
ENT.PrintName		= "CheckEm Base";
ENT.Author			= "Aska";
ENT.Purpose			= "Sets Up The Structure For All CheckEm Gates";
ENT.Category		= "CheckEm";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

ENT.CheckEmGate = true;

include('io.lua')
include('chkm_vars.lua')

game.AddParticles("particles/checkem.pcf");

PrecacheParticleSystem("CheckEm.Plug");

ENT.AutomaticFrameAdvance = true;


local pop = {"ce_xor", "ce_or", "ce_randomizer", "ce_toggle",
	"ce_and", "ce_battery", "ce_not"
};

function ENT:Initialize()
	
	self.DoPP = false;

	self.ipideal, self.opideal = 0, 0;

	self.Inputs, self.Outputs = {}, {};

	self.SetNumInputs = (self.SetNumInputs || 2);
	self.InputTexts = (self.InputTexts || {});

	self.SetNumOutputs = (self.SetNumOutputs || 1);
	self.OutputTexts = (self.OutputTexts || {});

	self.CHKMVars = (self.CHKMVars || {});

	self:SetupCustomVars();
	self.HasCustomMenu = (self.HasCustomMenu || true);

	if (SERVER) then
				
		self:SetModel("models/checkem/basechip.mdl")
		self:ResetSequence(self:LookupSequence("bd0"));
		
		self:PhysicsInit(SOLID_VPHYSICS);

		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then phys:Wake(); phys:SetMass(.1); end

		self:SetCollisionGroup(COLLISION_GROUP_WEAPON);

		self:SetUseType(SIMPLE_USE);

	else
		self.UpdateRB = (CurTime() + 1);
	end

	self:SetupInputs();
	self:SetupOutputs();
	
	self:SizeUp();

	//make some poppy noises
	timer.Simple(.2, function()
		if (IsValid(self)) then
			self.DoPP = true;
			if (SERVER && table.HasValue(pop, self:GetClass())) then
				if (self.SetNumInputs > 0) then
					timer.Create(tostring(self) .. "ipsounds", .04, self.SetNumInputs, function()
						if (IsValid(self)) then
							self:EmitSound("checkem/pp_pop.mp3", 68, math.random(85, 92));
						end
					end);
				end
				if (self.SetNumOutputs > 0) then
					timer.Create(tostring(self) .. "opsounds", .05, self.SetNumOutputs, function()
						if (IsValid(self)) then
							self:EmitSound("checkem/pp_pop.mp3", 68, math.random(85, 92));
						end
					end);
				end
			end
			local phys = self:GetPhysicsObject();
			if (phys:IsValid() && IsValid(self:GetParent())) then
				phys:EnableCollisions(false);
				phys:EnableGravity(false);
				phys:EnableDrag(false);
			end
		end
	end);
	
end


//destroy any connections with other gates
//so they don't try to reference a non-existent entity
//set their inputs connected to this gate to off
function ENT:OnRemove()
	if (SERVER) then
		self:ClearAllOutputs();
		self:ClearAllInputs();

		net.Start("CHKMRMVQ")
			net.WriteLong(self:EntIndex());
		net.Broadcast()
	end
end


function ENT:Think()
	
	if (IsValid(self:GetParent()) && self:GetParent():GetClass() == "ce_sequencer") then
		self:SetPoseParameter("Outputs", 0);
		return;
	end

	if (self.DoPP) then
		//stuff
		local ip = self:NumInputs();
		self.ipideal = math.Approach(self.ipideal, ip, (FrameTime() * 25));
		self:SetPoseParameter("Inputs", self.ipideal);

		local op = self:NumOutputs();
		self.opideal = math.Approach(self.opideal, op, (FrameTime() * 25));
		self:SetPoseParameter("Outputs", self.opideal);
	end

	if (CLIENT) then
		self:UpdateRenderBounds();
	end

end

function ENT:CheckOutputs(op, on)
	//override
end

function ENT:DoOnDupeFirst()
	//do stuff here you've just been duped son
	//called before the normal dupe stuff happens
end

function ENT:DoOnDupe()
	//do stuff here you've just been duped son
	//called after the normal dupe stuff happens
end
