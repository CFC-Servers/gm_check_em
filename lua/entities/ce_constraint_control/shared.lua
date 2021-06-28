ENT.Type 			= "anim";
ENT.Base 			= "base_anim";
ENT.PrintName		= "Check 'em Constraint Controller";
ENT.Author			= "Aska";
ENT.Purpose			= "Controls GMod constraints for hooking into Check 'em";

ENT.Spawnable			= false;
ENT.AdminSpawnable		= false;

ENT.CHKMWinchControl = true;

if (SERVER) then



AddCSLuaFile("shared.lua");
	
ENT.WC = nil;


function ENT:Initialize()
	self:SetModel("models/checkem/basechip.mdl");
	self:PhysicsInit(SOLID_BBOX);
	self:SetMoveType(MOVETYPE_NONE);
	self:SetSolid(SOLID_NONE);
	self:DrawShadow(false);
	//self:SetColor(255, 255, 255, 0);
end


function ENT:SetWinchController(ent)
	self.WC = ent;
end

function ENT:GetWinchController(ent)
	return self.WC;
end


function ENT:SetDirection(dir)
	local wc = self:GetWinchController();
	if (IsValid(wc)) then
		wc:SetDirection(dir);
	else
		self:Remove();
	end
end


function ENT:GetDirection(dir)
	local wc = self:GetWinchController();
	if (IsValid(wc)) then
		return wc:GetDirection();
	else
		return nil;
	end
end

function ENT:IsExpanded()
	local wc = self:GetWinchController();
	if (IsValid(wc)) then
		return wc:IsExpanded();
	else
		return false;
	end
end
	

	
/*function ENT:OnDupeCopy(dupeinfo)
	
	if (IsValid(self:GetWinchController())) then
		dupeinfo.WC = self:GetWinchController();
	end
	
	return dupeinfo;
	
end


function ENT:OnDupePaste(dupeinfo, Created)
	
	//PrintTable(dupeinfo);
	//PrintTable(Created);
	
	local ent = Created[dupeinfo.WC];
	if (dupeinfo.EntToMod != nil && IsValid(ent)) then
		self:SetWinchController(ent);
	end
	
end*/
	
	
	
else
	
	
	


function ENT:Initialize()
	self:SetModelScale(3, 0);
end


function ENT:Draw()
	//dont draw you dick
	//self:DrawModel();
end

	
	
	
	
	
end
