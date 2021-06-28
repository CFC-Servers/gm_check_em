
if (SERVER) then
	AddCSLuaFile("gmod_ents.lua");
end
include('gmod_ents.lua')


//check to see if a sent is a wireable entity or not
function CHECKEM.IsWireable(ent)

	if (!IsValid(ent)) then return false; end

	//dont include gates
	if (ent.CheckEmGate) then return false; end

	//are they a gmod entity?
	local gm = (CHECKEM.GModEnts[ent:GetClass()] != nil);
	//are they compatible with check em?
	local chkm = (ent.CHKMInputs != nil && #ent.CHKMInputs > 0);

	return (gm || chkm);

end

//retreive the gate and #op that is connected to this input
//returns ent, op, on
function CHECKEM.GetSENTInput(ent, ip)

	if (!CHECKEM.IsWireable(ent)) then return nil; end

	if (!IsValid(ent) || ip > #ent.CHKMInputs || ip <= 0 || ent.CHKMInputEnts == nil || table.Count(ent.CHKMInputEnts) < 1) then
		return nil;
	end

	local tbl = ent.CHKMInputEnts[ip];

	if (tbl == nil) then return nil, nil; end;

	return Entity(tbl[1]), tbl[2], tbl[3];

end

//returns whether SENT input #ip is on or off
//in boolean
function CHECKEM.GetSENTInputOn(ent, ip)
	local e, op, on = CHECKEM.GetSENTInput(ent, ip);
	return tobool(on);
end

//do all the work of adding input sents
local function DoInputAdd(ent, ip, gate, op)
	ent.CHKMInputEnts = (ent.CHKMInputEnts || {});

	if (ip > #ent.CHKMInputs || ip <= 0) then
		Error("CHECKEM.AddSENTInput ip out of range: " .. tostring(ip));
		return;
	end

	if (SERVER) then
		//attempt to clear this input first
		CHECKEM.ClearSENTInput(ent, ip);
	end

	local on = gate:GetOutputOn(op);
	local num = (on && 1) || 0;
	local tbl = {gate:EntIndex(), op, num};
	ent.CHKMInputEnts[ip] = tbl;
	if (SERVER) then ent:CheckInputs(ip, on) end
end


hook.Add("EntityRemoved", "CHECKEM_EntityRemoved", function(ent)
	if (SERVER) then

		if (IsValid(ent.CHKMWC)) then ent.CHKMWC:Remove(); end

		net.Start("CHKMRMVQ")
			net.WriteLong(ent:EntIndex());
		net.Broadcast()

		if (CHECKEM.IsWireable(ent)) then
			if (ent.CHKMInputs != nil) then
				for i = 1, #ent.CHKMInputs do
					local e, op, on = CHECKEM.GetSENTInput(ent, i);
					if (e != nil && IsValid(e) && e.CheckEmGate && e.ClearOutputEnt != nil) then
						e:ClearOutputEnt(op, ent, i);
					end
				end
			end
		end

	else
		CHECKEM.EventQueue[ent:EntIndex()] = nil;
	end
end);


//update the on/off state of #ip
function CHECKEM.UpdateIPState(ent, ip, on, b)

	if (!CHECKEM.IsWireable(ent)) then return; end

	if (!IsValid(ent) || ip > #ent.CHKMInputs || ip <= 0 || ent.CHKMInputEnts == nil || ent.CHKMInputEnts[ip] == nil) then
		return;
	end
	
	ent.CHKMInputEnts[ip][3] = on;
	if (SERVER) then
		ent:CheckInputs(ip, tobool(on));

		if (!b) then
			net.Start("CHKMSENTUPD")
				net.WriteLong(ent:EntIndex());
				net.WriteLong(ip);
				net.WriteLong(on);
			net.Broadcast()
		end
	end

end


if (SERVER) then


//add gate as input at #ip
function CHECKEM.AddSENTInput(ent, ip, gate, op)

	DoInputAdd(ent, ip, gate, op);

	net.Start("CHKMSENTADD")
		net.WriteLong(ent:EntIndex());
		net.WriteLong(ip);
		net.WriteLong(gate:EntIndex());
		net.WriteLong(op);
	net.Broadcast()

end

//remove the gate at #ip
function CHECKEM.ClearSENTInput(ent, ip)

	local gate, op, on = CHECKEM.GetSENTInput(ent, ip);

	if (!IsValid(gate)) then return; end

	gate:ClearOutputEnt(op, ent, ip);
	ent.CHKMInputEnts[ip] = {nil, nil, 0};
	CHECKEM.UpdateIPState(ent, ip, 0);

	if (ent["InputRemoved"] != nil) then
		ent:InputRemoved(ip);
	end

	net.Start("CHKMSENTCLR")
		net.WriteLong(ent:EntIndex());
		net.WriteLong(ip);
	net.Broadcast()

end



else


local function checkvalid(id)
	return IsValid(Entity(id));
end
local function checkvalid2(id, id2)
	return (IsValid(Entity(id)) && IsValid(Entity(id2)));
end


function CHECKEM.QueueDoInputAdd(id, ip, id2, op)
	local ent, gate = Entity(id), Entity(id2);
	if (IsValid(ent) && IsValid(gate)) then DoInputAdd(ent, ip, gate, op); end
end

net.Receive("CHKMSENTADD", function(len)
	local id, ip = net.ReadLong(), net.ReadLong();
	local id2, op = net.ReadLong(), net.ReadLong();
	CHECKEM.QueueEvent(id, {checkvalid2, {id, id2}}, CHECKEM.QueueDoInputAdd, id, ip, id2, op);
end);


function CHECKEM.QueueClearSENTIP(id, ip)
	local ent = Entity(id);
	if (IsValid(ent)) then ent.CHKMInputEnts[ip] = nil; end
end

net.Receive("CHKMSENTCLR", function(len)
	local id, ip = net.ReadLong(), net.ReadLong();
	CHECKEM.QueueEvent(id, {checkvalid, {id}}, CHECKEM.QueueClearSENTIP, id, ip);
end);


function CHECKEM.QueueSENTUPD(id, ip, on)
	local ent = Entity(id);
	if (IsValid(ent)) then ent.CHKMInputEnts[ip][3] = on; end
end

net.Receive("CHKMSENTUPD", function(len)
	local id, ip, on = net.ReadLong(), net.ReadLong(), net.ReadLong();
	CHECKEM.QueueEvent(id, {checkvalid, {id}}, CHECKEM.QueueSENTUPD, id, ip, on);
end);



end
