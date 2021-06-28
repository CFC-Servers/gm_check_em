
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')

ENT.CustomAnim = true;

function ENT:Initialize()
	self.BaseClass.Initialize(self);
	self:SetModel("models/checkem/pressurepad.mdl");

	self:PhysicsInit(SOLID_VPHYSICS);

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then phys:Wake(); phys:SetMass(1); end

	self:SetCollisionGroup(COLLISION_GROUP_NONE);

	self:ResetSequence(0);
	timer.Simple(.2, function()
		if (IsValid(self)) then
			self:ResetSequence(self:LookupSequence("Out"));
			self:EmitSound("items/ammocrate_close.wav", 62, 250);
			self:EmitSound("checkem/pp_pop.mp3", 68, math.random(85, 92));
		end
	end);
end


local function IsSENT(v)
	return (scripted_ents.Get(v:GetClass()));
end

function ENT:Sense()
	local min = self:GetVariable("Num");
	
	local ply, npc, prop, sent, world, rag = self:GetVariable("DPly"), self:GetVariable("DNPC"),
		self:GetVariable("DProp"), self:GetVariable("DSENT"), self:GetVariable("DWorld"), self:GetVariable("DRag");

	if (!ply && !npc && !prop && !sent && !world && !rag) then return; end //you really dont want to detect anything?

	local num = 0;
	local t = self:Traces();

	if (t["World"] == true && world) then
		num = (num + 1);
	end
	local up = (self:GetUp().z > .7);
	for k, v in pairs(t) do
		if (k != "World" && v != self && self:GetParent() != v && v:GetMoveType() != MOVETYPE_NONE) then
			if (IsSENT(v) && sent) then
				num = (num + 1);
			end
			if (v:GetClass() == "prop_physics" && !IsSENT(v) && prop) then
				num = (num + 1);
			end
			if (v:IsPlayer() && ply && !up) then
				num = (num + 1);
			end
			if (v:IsNPC() && npc && !up) then
				num = (num + 1);
			end
			if (v:GetClass() == "prop_ragdoll" && rag) then
				num = (num + 1);
			end
		end
	end
	if (up) then
		if (ply) then
			for k, v in ipairs(player.GetAll()) do
				if (v:GetGroundEntity() == self) then
					num = (num + 1);
				end
			end
		end
		if (npc) then
			for k, v in ipairs(ents.FindByClass("npc_*")) do
				if (v:GetGroundEntity() == self) then
					num = (num + 1);
				end
			end
		end
	end

	local sil = self:GetVariable("Silent");
	if (num >= min) then
		if (!self:GetOutputOn(1)) then
			self:ChangeOPState(1, true, true);
			self:SetSkin(1);
			self:ResetSequence(self:LookupSequence("In"));
			if (!sil) then self:EmitSound("items/ammocrate_open.wav", 62, 250); end
		end
	else
		if (self:GetOutputOn(1)) then
			self:ChangeOPState(1, false, true);
			self:SetSkin(0);
			self:ResetSequence(self:LookupSequence("Out"));
			if (!sil) then self:EmitSound("items/ammocrate_close.wav", 62, 250); end
		end
	end
end

function ENT:Traces()
	local tbl = {};
	local pos = self:GetPos();
	local right = self:GetRight();
	local fwd = self:GetForward();
	local up = self:GetUp();
	pos = (pos + (up * 5) + (fwd * 22));
	
	local num = 4;
	local numdo = (num * .5);
	for i = (-numdo), (numdo) do
	
		local tp = (pos + (right * (8 * i)));
		local tpend = (tp - (fwd * 44));
		/*debugoverlay.Cross(tp, 5, .1);
		debugoverlay.Cross(tpend, 5, .1);
		debugoverlay.Line(tp, tpend, .1);*/
		
		local tr = util.TraceLine({
			start = tp,
			endpos = tpend,
			filter = self
		});
		
		if (tr.HitWorld) then
			tbl["World"] = true;
		else
			local ent = tr.Entity;
			if (IsValid(ent) && !table.HasValue(tbl, ent)) then
				table.insert(tbl, ent);
			end
		end
		
	end
	
	return tbl;
end
