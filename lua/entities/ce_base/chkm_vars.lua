

//ex.
//ENT.CHKMVars["NumPlayers"] = 1;
//ENT.CHKMVars["ColorID"] = "Red";
//ENT.CHKMVars["Text"] = "This is text!"

CHKMVAR_ANGLE = 1;
CHKMVAR_BOOL = 2;
CHKMVAR_ENTITY = 3;
CHKMVAR_NUMBER = 4;
CHKMVAR_STRING = 5;
CHKMVAR_VECTOR = 6;
CHKMVAR_TABLE = 7;


//CHECKEM.SetupCustomVars
//moved to autorun because if it's here then
//gates that are called before ce_base (ce_and, etc.) won't work

//set our entity up with its vars
function ENT:SetupCustomVars()
	local tbl = CHECKEM.Vars[self:GetClass()];
	if (!tbl || tbl == nil) then return; end
	for k, v in pairs(tbl) do
		if (!self[v.name]) then
			self:SetVariable(v.name, v.val, true);
			self[v.name] = v.val;
		end
	end
end

function ENT:HasCustomVars()
	return (table.Count(self.CHKMVars) > 0);
end

function ENT:SetVariable(var, val, b)
	self.CHKMVars[var] = val;
	if (!b) then //this is when we're initializing the entity, don't call VariableChanged
		self:VariableChanged(var, val);
	end
end

function ENT:GetVariable(var)
	if (self.CHKMVars[var] != nil) then
		return self.CHKMVars[var];
	end
	return nil;
end


function ENT:VariableChanged(var, val)

	//var is the string text that is your variable
	//val is the value it was changed to
	//when that value gets updated, this function is called
	//use this to apply the changes that variable should make

	//ex.
	//if (var == "NumPlayers") then
	//    self.NumPlayerShitVariable = val;
	//end

	//separated by server and client

end

function CHECKEM.sendCVal(val)
	local t = type(val);
	if (t == "Angle") then
		net.WriteLong(CHKMVAR_ANGLE);
		net.WriteAngles(val);
		return;
	end
	if (t == "boolean") then
		net.WriteLong(CHKMVAR_BOOL);
		local v = (val && 1) || 0;
		net.WriteLong(v);
		return;
	end
	if (t == "Entity") then
		net.WriteLong(CHKMVAR_ENTITY);
		net.WriteEntity(val);
		return;
	end
	if (t == "number") then
		net.WriteLong(CHKMVAR_NUMBER);
		net.WriteFloat(val);
		return;
	end
	if (t == "string") then
		net.WriteLong(CHKMVAR_STRING);
		net.WriteString(val);
		return;
	end
	if (t == "Vector") then
		net.WriteLong(CHKMVAR_VECTOR);
		net.WriteVector(val);
		return;
	end
	if (t == "table") then
		net.WriteLong(CHKMVAR_TABLE);
		net.WriteTable(val);
		return;
	end
end

function CHECKEM.recCVal()
	local t = net.ReadLong();
	if (t == CHKMVAR_ANGLE) then
		return net.ReadAngle();
	end
	if (t == CHKMVAR_BOOL) then
		return tobool(net.ReadLong());
	end
	if (t == CHKMVAR_ENTITY) then
		return net.ReadEntity();
	end
	if (t == CHKMVAR_NUMBER) then
		return net.ReadFloat();
	end
	if (t == CHKMVAR_STRING) then
		return net.ReadString();
	end
	if (t == CHKMVAR_VECTOR) then
		return net.ReadVector();
	end
	if (t == CHKMVAR_TABLE) then
		return net.ReadTable();
	end
end


if (SERVER) then


//ply is optional, if included, won't send to that player
function ENT:ChangeVariable(var, val, ply)
	self:SetVariable(var, val);
	net.Start("CHKMVAR")
		net.WriteLong(self:EntIndex());
		net.WriteString(var);
		CHECKEM.sendCVal(val);
	if (ply) then
		local tbl = {};
		for k, v in pairs(player.GetAll()) do
			if (v != ply) then table.insert(tbl, v); end
		end
		net.Send(tbl)
	else net.Broadcast() end
end

net.Receive("CHKMVAR", function(len, ply)
	local e = Entity(net.ReadLong());
	local var, val = net.ReadString(), CHECKEM.recCVal();
	e:ChangeVariable(var, val, ply);
end)


else



function ENT:ChangeVariable(var, val)
	self:SetVariable(var, val);
	net.Start("CHKMVAR")
		net.WriteLong(self:EntIndex());
		net.WriteString(var);
		CHECKEM.sendCVal(val);
	net.SendToServer()
end


local function checkvalid(id)
	return IsValid(Entity(id));
end

function CHECKEM.QueueChangeVariable(id, var, val)
	local e = Entity(id);
	if (IsValid(e)) then e:SetVariable(var, val); end
end

net.Receive("CHKMVAR", function(len)
	local id = net.ReadLong();
	local var, val = net.ReadString(), CHECKEM.recCVal();
	CHECKEM.QueueEvent(id, {checkvalid, {id}}, CHECKEM.QueueChangeVariable, id, var, val);
end)



//menu stuff

net.Receive("CHKMMENU", function(len)

	//get the gate entity
	local ent = Entity(net.ReadLong());
	if (!IsValid(ent) || table.Count(ent.CHKMVars) <= 0) then return; end

	local f = vgui.Create("CheckEmVarMenu");
	f:SetSize(300, 400);
	f:SetGate(ent);
	f:Center();
	f:MakePopup();

	/*local f = vgui.Create("DFrame");
	f:SetSize(300, 400);
	f:Center();
	f:MakePopup();

	local p = vgui.Create("CheckEmToolMenu", f);
	p:SetPos(0, 32);
	p:SetSize(300, 368);*/

end);


end

