
CHECKEM = (CHECKEM || {});


//legacy function compatability cause i'm lazy
function net.WriteLong(int)
	net.WriteDouble(int);
end

function net.ReadLong()
	return net.ReadDouble();
end


for k, v in pairs(file.Find("lua/checkem/vgui/*.lua", "GAME")) do
	if (SERVER) then AddCSLuaFile("checkem/vgui/" .. v); print("AddCSLuaFile: ", v); end
	if (CLIENT) then include('checkem/vgui/' .. v) print("Including: ", v); end
end


CHECKEM.Gates = {};

function CHECKEM.RegisterCheckEmGate(classname, nicename, category)
	if (CHECKEM.Gates[category] == nil) then
		CHECKEM.Gates[category] = {};
	end
	CHECKEM.Gates[category][classname] = nicename;
end


//had to move this to autorun...
CHECKEM.Vars = {};

function CHECKEM.VarType(ent, var)
	if (CHECKEM.Vars[ent:GetClass()][var] == nil) then return; end
	local val = CHECKEM.Vars[ent:GetClass()][var].val;
	local t = type(val);
	return t;
end

//add this to the overall var list
function CHECKEM.SetupCustomVars(class, ...)
	if (CHECKEM.Vars[class] != nil) then return; end
	CHECKEM.Vars[class] = {};
	local arg = {...};
	for i = 1, #arg do

		local nicename = arg[i][1];
		local name, val = arg[i][2], arg[i][3];
		CHECKEM.Vars[class][i] = {};

		local tbl = CHECKEM.Vars[class][i];
		tbl.nicename = nicename;
		tbl.name = name;
		tbl.val = val;

		//custom variable type/editor
		if (type(arg[i][4]) == "function") then 
			tbl.custom = arg[i][4];
		else //otherwise handle it ourselves
			if (type(val) == "number") then
				if (arg[i][4] && arg[i][5]) then
					tbl.min = arg[i][4];
					tbl.max = arg[i][5];
				end

				if (arg[i][6]) then
					tbl.precision = arg[i][6];
				end
			end

			if (type(val) == "string") then
				tbl.txt = arg[i][4];
				tbl.allowinput = arg[i][5];
				if (!arg[i][5]) then
					tbl.strs = {};
					for k, v in pairs(arg[i][6]) do
						table.insert(tbl.strs, v);
					end
				end
			end
		end

	end
end


function CHECKEM.PlayerHoldingTool(ply)
	if (!IsValid(ply) || !ply:Alive()) then return; end
	local wep = ply:GetActiveWeapon();
	if (!IsValid(wep)) then return false; end
	return (wep:GetClass() == "gmod_tool");
end


if (SERVER) then


	net.Receive("CHKMPLYVAR", function(len)
		local ply = Entity(net.ReadLong());
		local class, name, val = net.ReadString(), net.ReadString(), CHECKEM.recCVal();
		ply.CHKMVars[class][name] = val;
	end);


end

if (CLIENT) then


	function CHECKEM.UpdateLocalVar(class, name, val)
		net.Start("CHKMPLYVAR")
			net.WriteLong(LocalPlayer():EntIndex());
			net.WriteString(class);
			net.WriteString(name);
			CHECKEM.sendCVal(val);
		net.SendToServer()
	end


end
