
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');
AddCSLuaFile('io.lua');
AddCSLuaFile('chkm_vars.lua');
AddCSLuaFile('cl_event_queue.lua');


include('shared.lua')


function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end

function ENT:Spark(port, num)
	net.Start("CHKMSPARK")
		net.WriteLong(self:EntIndex());
		net.WriteLong(port);
		net.WriteLong(num)
	net.Broadcast()
end

function ENT:Use(act, call)
	if (CHECKEM.PlayerHoldingTool(act) && self.HasCustomMenu) then
		net.Start("CHKMMENU")
			net.WriteLong(self:EntIndex());
		net.Send(act)
	end
end


//dupe

function ENT:DupeOutputsClient(tbl)
	timer.Simple(.25, function()
		if (IsValid(self)) then
			net.Start("CHKMDUPEOP")
				net.WriteLong(self:EntIndex());
				net.WriteTable(tbl);
			net.Broadcast()
		end
	end);
end

function ENT:DupeInputsClient(tbl)
	timer.Simple(.25, function()
		if (IsValid(self)) then
			net.Start("CHKMDUPEIP")
				net.WriteLong(self:EntIndex());
				net.WriteTable(tbl);
			net.Broadcast()
		end
	end);
end

function ENT:DupeVarsClient(tbl)
	timer.Simple(.25, function()
		if (IsValid(self)) then
			net.Start("CHKMDUPEVAR")
				net.WriteLong(self:EntIndex());
				net.WriteTable(tbl);
			net.Broadcast()
		end
	end);
end


function ENT:PreEntityCopy()
	duplicator.ClearEntityModifier(self, "CheckEmDupe");

	local dupe = {info = {}};
	dupe.info.id = self:EntIndex();

	if (self:NumOutputs() > 0) then
		dupe.info.op = table.Copy(self:OutputArray());
	
		dupe.info.sents = {};
		for i = 1, self:NumOutputs() do
			for k, v in pairs(self:GetOutputSENTs(i)) do
				if (!table.HasValue(dupe.info.sents, v[1])) then table.insert(dupe.info.sents, v[1]); end
			end
		end
	end

	if (self:NumInputs() > 0) then
		dupe.info.ip = table.Copy(self:InputArray());
	end

	if (table.Count(self.CHKMVars) > 0) then
		dupe.info.vars = table.Copy(self.CHKMVars);
	end

	if (IsValid(self.WeldedTo)) then
		dupe.info.weldid = self.WeldedTo:EntIndex();
	end

	if (self.Sequenced) then
		dupe.info.sequenced = self.Sequenced;
	end

	if (self:GetClass() == "ce_sequencer") then
		dupe.info.sequence = table.Copy(self.Sequence);
		for k, v in pairs(dupe.info.sequence) do
			for l, b in pairs(v) do
				dupe.info.sequence[k][l] = b:EntIndex();
			end
		end
	end

	duplicator.StoreEntityModifier(self, "CheckEmDupe", dupe);
end

function ENT:PostEntityPaste(ply, ent, Created)
	if (ent.EntityMods != nil) then
		local tbl = ent.EntityMods.CheckEmDupe.info;
		local new = Created[tbl.id];

		if (!IsValid(new)) then return; end

		new:DoOnDupeFirst(Created);

		if (tbl.op != nil) then
			local op = table.Copy(tbl.op);
			for k, v in pairs(op) do
				for l, b in pairs(v[2]) do
					if (type(b[1]) == "number" && IsValid(Created[b[1]])) then
						b[1] = Created[b[1]]:EntIndex();
					else
						b[1] = nil;
					end
				end
				for l, b in pairs(v[3]) do
					if (type(b[1]) == "number" && IsValid(Created[b[1]])) then
						local sent = Created[b[1]];
						b[1] = sent:EntIndex();
					else
						b[1] = nil;
					end
				end
			end
			new.Outputs = op;
			new:DupeOutputsClient(op);
		end
		if (tbl.ip != nil) then
			local ip = table.Copy(tbl.ip);
			for k, v in pairs(ip) do
				if (type(v[2][1]) == "number" && IsValid(Created[v[2][1]])) then
					v[2][1] = Created[v[2][1]]:EntIndex();
				else
					v[2][1] = nil;
					v[1] = 0;
				end
			end		
			new.Inputs = ip;
			new:DupeInputsClient(ip);
		end
		if (tbl.sents != nil) then
			for k, v in pairs(tbl.sents) do
				local e = Created[v];
				timer.Simple(.5, function()
					if (IsValid(e)) then
						if (!e.HasCHKMDuped) then e:PostEntityPaste(ply, e, Created); e.HasCHKMDuped = true; end
					end
				end);
			end
		end
		if (tbl.vars != nil) then
			local vars = table.Copy(tbl.vars);
			new.CHKMVars = vars;
			new:DupeVarsClient(vars);
		end
		if (tbl.weldid != nil) then
			new.WeldedTo = Created[tbl.weldid];
		end
		if (tbl.sequenced != nil) then
			new.Sequenced = tbl.sequenced;
		end
		if (tbl.sequence != nil) then
			for x, y in pairs(tbl.sequence) do
				for i, ent in pairs(y) do
					tbl.sequence[x][i] = Created[ent];
				end
			end
			new.DupeSeq = table.Copy(tbl.sequence);
		end

		new:SetNetworkedEntity("CHKMOwner", ply)
		new:DoOnDupe(Created);
	end
end
