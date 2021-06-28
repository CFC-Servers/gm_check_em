
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


function ENT:Sense()
	local delay = self.OffDelay;
	local on = self:GetOutputOn(1);
	if (delay != 0 && CurTime() >= delay && on) then
		self:ChangeOPState(1, false, true);
		self:SetSkin(4);
	end
end

hook.Add("EntityTakeDamage", "CHECKEM_DamageEntityTakeDamage", function(ent, dmg)
	for k, v in pairs(ents.FindByClass("ce_sensor_damage")) do
		if (tonumber(v:GetNetworkedEntity("CHKMOwner"):GetInfo("checkem_disabletriggersensors")) == 0) then
			if (ent == v || (!v:GetVariable("ChipOnly") && IsValid(v.WeldedTo) && ent == v.WeldedTo) && CurTime() >= v.OffDelay) then
				if (dmg:GetDamage() >= v:GetVariable("Dmg")) then
					v:ChangeOPState(1, true, true);
					v:SetSkin(5);
					v.OffDelay = (CurTime() + v:GetVariable("Off"));
				end
			end
		end
	end
end);
