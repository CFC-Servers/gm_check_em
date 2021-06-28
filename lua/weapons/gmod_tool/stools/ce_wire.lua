TOOL.Category = "Check 'em"
TOOL.Name = "Wiring Tool"
TOOL.Command = nil
TOOL.ConfigName = nil --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud
TOOL.WireTool = true;

TOOL.CheckEmTool = true;

TOOL_OUTPUT_MODE = 1;
TOOL_INPUT_MODE = 2;

TOOL_MODESWITCH_DELAY = .2;


if (CLIENT) then
	language.Add("tool.ce_wire.name", "Wiring Tool");
	language.Add("tool.ce_wire.desc", "Modifies connections with the Check 'Em system");

	language.Add("tool.ce_wire.0", "Left click: Select an output\tRight Click: Switch input mode");
	language.Add("tool.ce_wire.1", "Left click: Connect output to input\tRight Click: Switch input on SENTs");
	language.Add("tool.ce_wire.2", "Left click: Select an input\tRight Click: Switch input mode/Switch input on SENTs");

	local cantool = CreateClientConVar("checkem_disableotherstools", 0, true, true);
end



function TOOL:Init()
	self.Gate = nil;
	self.IP, self.OP = nil, nil;
	self.GateAboutToConnect, self.OPAboutToConnect = nil, nil;
	self.NextRightClick = 0;
end


function TOOL:LeftClick(tr)
		
	if (SERVER && game.SinglePlayer()) then
		self:GetOwner():SendLua("LocalPlayer():GetActiveWeapon():GetToolObject():DoLeftClick()");
	end

	local wireless = self:GetOwner().CHKMWireless || false;

	local mode = self:GetWireMode();
	local stage = self:GetStage();

	local ent = self.Gate;
	
	if (IsValid(ent)) then
		local owner = ent:GetNetworkedEntity("CHKMOwner");
		if (IsValid(owner) && owner:IsPlayer() && self:GetOwner() != owner && owner:GetNWInt("CHKMCntProtect", 0) == 1) then
			if (CLIENT) then
				if (self.GateAboutToConnect) then self.GateAboutToConnect.KeepLit = 0; end
				GAMEMODE:AddNotify(owner:GetName() .. " has connection protection turned on!", NOTIFY_ERROR, 3);
				surface.PlaySound("ambient/water/drip" .. tostring(math.random(1, 4)) .. ".wav");
			end
			self.GateAboutToConnect, self.OPAboutToConnect = nil, nil;
			self:SetStage(0);
			return false;
		end
	end

	if (mode == TOOL_OUTPUT_MODE) then
		local op = self.OP;
		if (stage == 0) then

			if (!IsValid(ent) || !ent.CheckEmGate || ent:NumOutputs() <= 0) then return; end
			self.GateAboutToConnect = ent;
			self.OPAboutToConnect = op;
			if (CLIENT && ent) then ent.KeepLit = op; end
			if (SERVER) then ent:Spark(0, op); end
			self:SetStage(1);

		else

			local ip = self.IP;
			local gate, op = self.GateAboutToConnect, self.OPAboutToConnect;
			if (SERVER && IsValid(gate) && IsValid(ent) && ent != gate && !ent.Sequenced) then
				if ((ent.CheckEmGate && ent:NumInputs() > 0 && ip <= ent:NumInputs()) || CHECKEM.IsWireable(ent)) then
					gate:ConnectTo(op, ent, ip, wireless);
					if (ent.CheckEmGate) then
						ent:Spark(1, ip);
					else
						gate:Spark(0, op);
					end
				end
			end

			if (CLIENT && gate) then gate.KeepLit = 0; end
			self.GateAboutToConnect, self.OPAboutToConnect = nil, nil;
			self:SetStage(0);

		end
	end
	

	if (mode == TOOL_INPUT_MODE) then
		if (stage == 2) then
			
			local ip = self.IP;
			if (IsValid(ent)) then
				if (ent.CheckEmGate) then
					if (IsValid(ent:GetInputEnt(ip))) then
						local gate, op = ent:GetInputEnt(ip), ent:GetInputOutput(ip);
						self.GateAboutToConnect = gate;
						self.OPAboutToConnect = op;
						if (SERVER) then

							net.Start("CHKMWTIP")
								net.WriteLong(gate:EntIndex());
								net.WriteLong(op);
							net.Send(self:GetOwner())

							timer.Simple(0, function()
								ent:ClearInput(ip);
							end);
							ent:Spark(1, ip);

						end
						self:SetStage(1);
					end
				else
					if (IsValid(CHECKEM.GetSENTInput(ent, ip))) then
						local e, op, on = CHECKEM.GetSENTInput(ent, ip);
						self.GateAboutToConnect = e;
						self.OPAboutToConnect = op;
						if (SERVER) then

							net.Start("CHKMWTIP")
								net.WriteLong(e:EntIndex());
								net.WriteLong(op);
							net.Send(self:GetOwner())

							timer.Simple(0, function()
								CHECKEM.ClearSENTInput(ent, ip)
							end);
							e:Spark(0, op);

						end
						self:SetStage(1);
					end
				end
			end

		else

			local ip = self.IP;
			local gate, op = self.GateAboutToConnect, self.OPAboutToConnect;
			if (SERVER) then
				if (IsValid(gate) && IsValid(ent) && ent != gate) then
					if ((ent.CheckEmGate && ent:NumInputs() > 0 && ip <= ent:NumInputs()) || CHECKEM.IsWireable(ent)) then
						gate:ConnectTo(op, ent, ip, wireless);
						if (ent.CheckEmGate) then
							ent:Spark(1, ip);
						else
							gate:Spark(0, op);
						end
					end
				end
				net.Start("CHKMWTIP")
					net.WriteLong(gate:EntIndex());
					net.WriteLong(0);
				net.Send(self:GetOwner())
			end

			self.GateAboutToConnect, self.OPAboutToConnect = nil, nil;
			self:SetStage(2);

		end
	end

end



function TOOL:RightClick(tr)

	if (CurTime() < self.NextRightClick) then return; end
	self.NextRightClick = (CurTime() + .1);

	if (SERVER && game.SinglePlayer()) then
		self:GetOwner():SendLua("LocalPlayer():GetActiveWeapon():GetToolObject():DoRightClick()");
	end
	
	local mode = self:GetWireMode();
	local stage = self:GetStage();

	//output mode
	//	switch to input mode
	//	set stage to 2
	if (mode == TOOL_OUTPUT_MODE && stage != 1 && CurTime() >= self.Weapon:GetNextSecondaryFire()) then
		self.Weapon:SetNextSecondaryFire((CurTime() + TOOL_MODESWITCH_DELAY));
		if (SERVER) then
			self:SetWireMode(TOOL_INPUT_MODE);
			self:GetOwner():SendLua("surface.PlaySound(\"buttons/lightswitch2.wav\")");
		end
	end


	//input mode
	//	switch to output mode
	//	set stage 0
	//	or switch input on gmod ents
	if (mode == TOOL_INPUT_MODE && CurTime() >= self.Weapon:GetNextSecondaryFire()) then
		self.Weapon:SetNextSecondaryFire((CurTime() + TOOL_MODESWITCH_DELAY));
		if (stage != 1) then
			if (IsValid(self.Gate) && CHECKEM.IsWireable(self.Gate)) then
				if (CLIENT) then self:IncrementIP(); end
			else
				if (SERVER) then
					self:SetWireMode(TOOL_OUTPUT_MODE);
					self:GetOwner():SendLua("surface.PlaySound(\"buttons/lightswitch2.wav\")");
				end
			end
		end
	end

	if (CLIENT && stage == 1) then
		if (IsValid(self.Gate) && CHECKEM.IsWireable(self.Gate)) then
			self:IncrementIP();
		end
	end
	
end


function TOOL:Reload()
	return false;
end

function TOOL:Holster()
	if (SERVER) then
		self:SetWireMode(TOOL_OUTPUT_MODE);
	else
		self:RemoveServerGate();
	end
end

function TOOL:Deploy()
	if (SERVER) then
		self:SetWireMode(TOOL_OUTPUT_MODE);
	else
		self:RemoveServerGate();
	end
end


function TOOL:GetWireMode()
	return self:GetOwner():GetNWInt("CHKM_WireMode");
end

function TOOL:SetWireMode(mode)
	self:GetOwner():SetNWInt("CHKM_WireMode", mode);
	self:SetStage((mode == TOOL_OUTPUT_MODE && 0) || 2);
end

function TOOL:SwitchWireMode()
	local int = self:GetWireMode();
	self:SetWireMode((int == TOOL_OUTPUT_MODE && TOOL_INPUT_MODE) || TOOL_OUTPUT_MODE);
end



if (SERVER) then



net.Receive("CHKMWIREGATE", function(len)
	local wep = Entity(net.ReadLong());
	if (!IsValid(wep)) then return; end
	local tool = wep:GetToolObject();
	local num = net.ReadLong();
	local gate = nil;
	if (num != 0) then
		gate = Entity(num);
	end
	tool.Gate = gate;
end);

net.Receive("CHKMWIREIP", function(len)
	local wep = Entity(net.ReadLong());
	if (!IsValid(wep)) then return; end
	local tool = wep:GetToolObject();
	local ip = net.ReadLong();
	tool.IP = ip;
end);

net.Receive("CHKMWIREOP", function(len)
	local wep = Entity(net.ReadLong());
	if (!IsValid(wep)) then return; end
	local tool = wep:GetToolObject();
	local op = net.ReadLong();
	tool.OP = op;
end);

net.Receive("CHKMWIRELESS", function(len)
	local ply = Entity(net.ReadLong());
	if (!IsValid(ply)) then return; end
	local wireless = tobool(net.ReadLong());
	ply.CHKMWireless = wireless;
end);


end


if (CLIENT) then


function TOOL.BuildCPanel(panel)
	local chk = vgui.Create("DCheckBoxLabel", panel);
	chk:SetText("Wireless Connections");
	chk.Label:SetTextColor(Color(0, 0, 0, 255));
	chk:SetValue(0);
	chk:SizeToContents();
	chk.OnChange = function(pnl, val)
		net.Start("CHKMWIRELESS")
			net.WriteLong(LocalPlayer():EntIndex());
			net.WriteLong((val && 1) || 0);
		net.SendToServer()
	end
	panel:AddItem(chk);
end


net.Receive("CHKMWTIP", function(len)
	local gate, op = Entity(net.ReadLong()), net.ReadLong();
	gate.KeepLit = op;
end);


function TOOL:DoLeftClick()
	local tr = LocalPlayer():GetEyeTrace();
	self:LeftClick(tr);
end

function TOOL:DoRightClick()
	local tr = LocalPlayer():GetEyeTrace();
	self:RightClick(tr);
end

function TOOL:DoReload()
	local tr = LocalPlayer():GetEyeTrace();
	self:Reload(tr);
end


function TOOL:UpdateServerGate(gate)
	self.Gate = gate;
	net.Start("CHKMWIREGATE")
		net.WriteLong(self.Weapon:EntIndex());
		if (gate != nil) then
			net.WriteLong(gate:EntIndex());
		else
			net.WriteLong(0);
		end
	net.SendToServer()
end

function TOOL:RemoveServerGate()
	local ent = self.Gate;
	if (ent != nil) then
		self.OP, self.IP = nil, nil;
		self:UpdateServerGate(nil);
		if (IsValid(ent)) then
			ent.LightIP, ent.LightOP = 0, 0;
		end
	end
end

function TOOL:UpdateServerOP(op)
	self.OP = op;
	net.Start("CHKMWIREOP")
		net.WriteLong(self.Weapon:EntIndex());
		net.WriteLong(op);
	net.SendToServer()
end

function TOOL:UpdateServerIP(ip)
	self.IP = ip;
	net.Start("CHKMWIREIP")
		net.WriteLong(self.Weapon:EntIndex());
		net.WriteLong(ip);
	net.SendToServer()
end

function TOOL:IncrementIP()
	local ent = self.Gate; 
	if (!IsValid(ent) || !CHECKEM.IsWireable(ent)) then return; end

	local max = #ent.CHKMInputs;
	local ip = self.IP;
	
	if (ip == max) then
		ip = 1;
	else
		ip = (ip + 1);
	end

	self:UpdateServerIP(ip);
	surface.PlaySound("checkem/inputswitch.wav");
end


function sortClockwise(a,b,c)
    return math.atan2(a.y-c.y,a.x-c.x) > math.atan2(b.y-c.y,b.x-c.x)
end

//hella cool bro ralle105 ( http://www.facepunch.com/threads/931152-What-do-you-need-help-with-V1?p=28038408&viewfull=1#post28038408 )
local function behind(p1,p2,p3)
    local n = (p2-p1):GetNormal()
    n.x,n.y = -n.y,n.x
    return (p3-p1):Dot(n) < 0
end
 
local function intersects(p1,p2,p3,p4,p5)
	//debugoverlay.Cross(Vector(p5.x, p5.y, 0), 4, .075, Color(255, 255, 255, 255));
	p5 = Vector(p5.x, p5.y, 0);
    return behind(p1,p2,p5) and
           behind(p2,p3,p5) and
           behind(p3,p4,p5) and
           behind(p4,p1,p5)    
end


function TOOL:Think()

	local ply = self:GetOwner();
	local tr = ply:GetEyeTrace();
	if (!tr.Hit) then
		return;
	end

	local pos = tr.HitPos;
	local scrpos = pos:ToScreen();
	local mode, stage = self:GetWireMode(), self:GetStage();

	
	//before all the crazy stuff, just see if we hit a gate with the trace
	if (IsValid(tr.Entity)) then
		local ent = tr.Entity;
		if (ent != self.Gate) then
			if (ent.CheckEmGate || CHECKEM.IsWireable(ent)) then
				if (self.Gate != nil) then self:RemoveServerGate(); end
				self:UpdateServerGate(ent);
			else
				self:DoBoundsCheck(scrpos);
			end
		end
	else

		self:DoBoundsCheck(scrpos);

	end

	//we are looking at a gate, look for inputs or outputs
	if (IsValid(self.Gate)) then
		local ent = self.Gate;

		if (ent.CheckEmGate) then
			if (mode == TOOL_OUTPUT_MODE && stage == 0) then
				
				if (ent.LightIP != 0) then
					ent.LightIP = 0;
					self.IP = 0;
				end

				//find an output
				local op = self:FindClosestOP(ent, scrpos);
				if (self.OP != op) then
					ent.LightOP = op;
					self:UpdateServerOP(op);
				end

			else

				if (ent.LightOP != 0) then
					ent.LightOP = 0;
					self.OP = nil;
				end

				//find an initial input
				if (ent:NumInputs() > 0) then
					local ip = self:FindClosestIP(ent, scrpos);
					if (self.IP != ip) then
						ent.LightIP = ip;
						self:UpdateServerIP(ip);
					end
				end

			end
		else
			if (self.IP == nil || self.IP == 0) then
				self:UpdateServerIP(1);
				//print(self.IP)
			end
		end

	end

end


function TOOL:DoBoundsCheck(scrpos)
	local success = false;

	//we're gonna have to use the bounds of the model
	//to find the gate, if we still don't find anything
	//just set just RemoveServerGate();
	for k, v in pairs(ents.FindByClass("ce_*")) do
		if (IsValid(v)) then
			if (v.CheckEmGate || v.CHKMWinchControl) then
				local dist = v:GetPos():Distance(self:GetOwner():GetShootPos());
				local max = 500;
				if (v:GetClass() != "ce_sensor_pressure") then
					if (v:GetClass() == "ce_sequencer") then max = 1250; end
					if (dist < max) then
						local bounds = self:RetreiveBounds(v);
						self:SortBounds(bounds);

						if (intersects(bounds[1], bounds[2], bounds[3], bounds[4], scrpos)) then
							success = true;
							if (v != self.Gate) then
								if (self.Gate != nil) then self:RemoveServerGate(); end
								self:UpdateServerGate(v);
								break;
							end
						end
					end
				end
			end
		end
	end

	//we're a failure
	if (!success && self.Gate != nil) then self:RemoveServerGate(); end
end


//these functions are used to find various inputs/outputs
//as well as the gates themselves
//used above


function TOOL:RetreiveBounds(gate)
	if (gate:LookupAttachment("Bound1") != 0) then
		local tbl = {};
		for i = 1, 4 do
			local atch = gate:GetAttachment(gate:LookupAttachment("Bound" .. tostring(i)));
			local pos = atch.Pos:ToScreen();
			pos = Vector(pos.x, pos.y, 0);
			table.insert(tbl, pos);
		end
		return tbl;
	end
	return nil;
end

function TOOL:SortBounds(bounds)
	local c = ((bounds[1] + bounds[2] + bounds[3] + bounds[4]) / 4);
	table.sort(bounds, function(a, b) return sortClockwise(a, b, c) end);
end

local function FindClosest(pos, tbl)
	
	local closest = 1;
	local dist = nil;
	for k, v in ipairs(tbl) do
		
		local px, py = pos.x, pos.y;
		local x, y = v.x, v.y;
		
		local newdist = math.sqrt((px - x)^2 + (py - y)^2);
		
		if (dist == nil || newdist < dist) then
			dist = newdist;
			closest = k;
		end
	end
	
	return closest;
	
end

function TOOL:FindClosestOP(gate, pos)
	local tbl = {};
	local num = gate:NumOutputs();
	for i = 1, num do
		local atch = gate:GetAttachment(gate:LookupAttachment("Op" .. tostring(i)));
		table.insert(tbl, atch.Pos:ToScreen());
	end
	return FindClosest(pos, tbl);
end

function TOOL:FindClosestIP(gate, pos)
	local tbl = {};
	local num = gate:NumInputs();
	for i = 1, num do
		local atch = gate:GetAttachment(gate:LookupAttachment("Ip" .. tostring(i)));
		table.insert(tbl, atch.Pos:ToScreen());
	end
	return FindClosest(pos, tbl);
end

	
end


