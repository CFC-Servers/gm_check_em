
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


//animate certain models that can be "switched"
local anim = {};
anim["models/props/switch001.mdl"] = {"up", "down"};
anim["models/props_combine/combinebutton.mdl"] = {"toggleout", "togglein"};
anim["models/props_mining/freightelevatorbutton01.mdl"] = {"idleon", "idleoff"};
anim["models/props_mining/freightelevatorbutton02.mdl"] = {"idleon", "idleoff"};
anim["models/props_mining/switch01.mdl"] = {"Up", "Down"};
anim["models/props_mining/switch_updown01.mdl"] = {"Up_Uplight_turnon", "Down_Downlight_turnon"};
anim["models/props_mining/control_lever01.mdl"] = {"open", "close"};

function ENT:AnimateModel(b)
	local ent = self.WeldedTo;
	if (IsValid(ent) && anim[ent:GetModel()] != nil) then
		local tbl = anim[ent:GetModel()];
		local num = (b && 1) || 2;
		ent:SetSequence(ent:LookupSequence(tbl[num]));
	end
end


function ENT:Sense()

	if (IsValid(self.PlayerHolding)) then
		self.On = true;
	else
		if (self.OffDelay != 0 && CurTime() >= self.OffDelay) then
			self.On = false;
		end
	end

	local on = self.On;
	if (self:GetOutputOn(1) != on) then
		self:ChangeOPState(1, on, true);
		self:SetSkin((on && 3) || 2);
		self:AnimateModel(on);
	end
end


hook.Add("PlayerDeath", "CHECKEM_UsePlyDeath", function(ply, key)
	
end);
