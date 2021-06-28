
//this array will store all of the gmod entity declarations
CHECKEM.GModEnts = (CHECKEM.GModEnts || {});

function CHECKEM.RegisterGModEnt(name, tbl)
	CHECKEM.GModEnts[name] = tbl;
end

for k, v in pairs(file.Find("lua/entities/ce_base/gmod_ents/*.lua", "GAME")) do
	if (SERVER) then
		AddCSLuaFile("gmod_ents/" .. v);
	end
	include("gmod_ents/" .. v);
end


local function NewCopy(self)
	if (self.OldCopy != nil) then self:OldCopy(); end
	duplicator.ClearEntityModifier(self, "CheckEmSENTDupe");

	if (self.CHKMInputEnts != nil) then
		local dupe = {info = {}};
		dupe.info.id = self:EntIndex();

		dupe.info.ip = table.Copy(self.CHKMInputEnts);

		duplicator.StoreEntityModifier(self, "CheckEmSENTDupe", dupe);
	end
end

local function NewPaste(self, ply, ent, Created)
	if (self.OldPaste != nil) then self:OldPaste(ply, ent, Created); end

	if (ent.EntityMods != nil) then
		local tbl = ent.EntityMods.CheckEmSENTDupe.info;
		local new = Created[tbl.id];

		if (!IsValid(new)) then return; end

		if (tbl.ip != nil) then
			local ip = table.Copy(tbl.ip);
			for k, v in pairs(ip) do
				if (v[1] != nil) then
					if (type(v[1]) == "number" && IsValid(Created[v[1]])) then
						v[1] = Created[v[1]]:EntIndex();
					end
				end
			end
			new.CHKMInputEnts = ip;
			new:CHKMDupeInfoClient(ip);
		end
	end
end

local function DupeInfo(self, tbl)
	timer.Simple(.25, function()
		if (IsValid(self)) then
			net.Start("CHKMDUPESENTIP")
				net.WriteLong(self:EntIndex());
				net.WriteTable(tbl);
			net.Broadcast()
		end
	end);
end


hook.Add("OnEntityCreated", "CHECKEM_OnEntityCreated", function(ent)
	timer.Simple(0, function()
		if (IsValid(ent)) then

			local tbl = CHECKEM.GModEnts[ent:GetClass()];
			if (tbl != nil) then
				for k, v in pairs(tbl) do
					ent[k] = v;
					if (k == "DoOnCreate") then
						ent:DoOnCreate();
					end
				end
				if (ent.PreEntityCopy != nil) then
					ent.OldCopy = ent.PreEntityCopy;
				end
				if (ent.PostEntityPaste != nil) then
					ent.OldPaste = ent.PostEntityPaste;
				end
				ent.PreEntityCopy = NewCopy;
				ent.PostEntityPaste = NewPaste;
				ent.CHKMDupeInfoClient = DupeInfo;
			end

			if (ent:GetClass() == "gmod_winch_controller") then
				local tbl = ent:GetTable(); //get the table containing the info we need

				local cnst = tbl.constraint; //get the constraint entity
				local ent1, ent2 = cnst.Ent1, cnst.Ent2;
				local pos1, pos2 = cnst.LPos1, cnst.LPos2;
				
				local parent = false;
				
				if (ent2:IsWorld()) then
					ent2 = ent1;
					pos1 = pos2;
				elseif (ent1:IsWorld()) then
					ent1 = ent2;
					pos2 = pos1;
				else
					parent = true;
					pos1 = ent1:LocalToWorld(pos1);
				end
				
				local typ = cnst.Type;
				local ctrl = ents.Create("ce_constraint_" .. typ:lower());
				
				if (!IsValid(ctrl)) then
					Msg("CHECKEM : Trying to create ce_constraint_control for invalid constraint type: " .. tostring(typ) .. "\n");
				else
				
					local tbl = table.Copy(player.GetAll());
				
					local dir = (pos1 - ent2:GetPos()):GetNormal();
					local tr = util.QuickTrace(pos1, (dir * 10000), tbl);
					local norm = tr.HitNormal;
					local ang = norm:Angle();
					ang:RotateAroundAxis(ang:Right(), 270);
					ctrl:SetAngles(ang);
					
					ctrl:SetPos((pos1 + (norm * 1.6)));
					
					if (parent) then
						ctrl:SetParent(ent1);
					end
					
					ctrl:SetWinchController(ent);
					ctrl:Spawn();
					
					constraint.Weld(ctrl, ent1, 0, 0, 0, true);
					
					ent.CHKMWC = ctrl;
					
				end
			end

		end
	end);
end);
