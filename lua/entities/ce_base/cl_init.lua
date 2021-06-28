
include('shared.lua')
include('cl_event_queue.lua')

local gates = CreateClientConVar("checkem_drawgates", 1, false, false);
local blips = CreateClientConVar("checkem_drawblips", 1, false, false);
local wires = CreateClientConVar("checkem_drawwires", 1, false, false);
local highQ = CreateClientConVar("checkem_highwires", 1, false, false)
local spark = CreateClientConVar("checkem_dospark", 1, false, false);


function ENT:Draw()
	local wep = CHECKEM.PlayerHoldingTool(LocalPlayer());
	if (!gates:GetBool() && !wep) then return; end
	self:DrawModel();
	if (blips:GetBool() || (!blips:GetBool() && wep)) then self:DoDiodeLighting(); end
	if (wires:GetBool() || (!wires:GetBool() && wep)) then self:DrawWires(); end
end


function ENT:UpdateRenderBounds()
	
	if (CurTime() < self.UpdateRB) then return; end
	self.UpdateRB = (CurTime() + 1);

	local pos = self:GetPos();
	local min = self:LocalToWorld(self:OBBMins());
	local max = self:LocalToWorld(self:OBBMaxs());

	local num;
	local emin, emax;
	local e;

	num = self:NumInputs();
	if (num > 0) then
		for i = 1, num do
			e = self:GetInputEnt(i);
			if (IsValid(e)) then
				emin = e:LocalToWorld(e:OBBMins());
				emax = e:LocalToWorld(e:OBBMaxs());
				if (emin.x < min.x) then min.x = emin.x; end
				if (emin.y < min.y) then min.y = emin.y; end
				if (emin.z < min.z) then min.z = emin.z; end
				if (emax.x > max.x) then max.x = emax.x; end
				if (emax.y > max.y) then max.y = emax.y; end
				if (emax.z > max.z) then max.z = emax.z; end
			end
		end
	end

	num = self:NumOutputs();
	if (num > 0) then
		for i = 1, num do
			e = self:GetOutputEnts(i);
			for k, v in pairs(e) do
				local v = Entity(v[1]);
				if (IsValid(v)) then
					emin = v:LocalToWorld(v:OBBMins());
					emax = v:LocalToWorld(v:OBBMaxs());
					if (emin.x < min.x) then min.x = emin.x; end
					if (emin.y < min.y) then min.y = emin.y; end
					if (emin.z < min.z) then min.z = emin.z; end
					if (emax.x > max.x) then max.x = emax.x; end
					if (emax.y > max.y) then max.y = emax.y; end
					if (emax.z > max.z) then max.z = emax.z; end
				end
			end
		end
	end

	e = self.RadialSphere;
	if (e) then
		num = self:GetVariable("SRad");
		num = Vector(num, num, num);
		emin = (pos - num);
		emax = (pos + num);
		if (emin.x < min.x) then min.x = emin.x; end
		if (emin.y < min.y) then min.y = emin.y; end
		if (emin.z < min.z) then min.z = emin.z; end
		if (emax.x > max.x) then max.x = emax.x; end
		if (emax.y > max.y) then max.y = emax.y; end
		if (emax.z > max.z) then max.z = emax.z; end
		if (IsValid(e)) then
			e:SetRenderBoundsWS(emin, emax);
		end
	end

	local c = self:GetVariable("Cube");
	if (c) then
		local x, y, z = self:GetVariable("X"), self:GetVariable("Y"), self:GetVariable("Z");
		num = Vector(x, y, z);
		emin = (pos - num);
		emax = (pos + num);
		if (emin.x < min.x) then min.x = emin.x; end
		if (emin.y < min.y) then min.y = emin.y; end
		if (emin.z < min.z) then min.z = emin.z; end
		if (emax.x > max.x) then max.x = emax.x; end
		if (emax.y > max.y) then max.y = emax.y; end
		if (emax.z > max.z) then max.z = emax.z; end
	end

	if (self:GetClass() == "ce_sequencer") then
		local x = self:GetNumX();
		num = (10 * x);
		num = Vector(num, num, num);
		emin = (pos - num);
		emax = (pos + num);
		if (emin.x < min.x) then min.x = emin.x; end
		if (emin.y < min.y) then min.y = emin.y; end
		if (emin.z < min.z) then min.z = emin.z; end
		if (emax.x > max.x) then max.x = emax.x; end
		if (emax.y > max.y) then max.y = emax.y; end
		if (emax.z > max.z) then max.z = emax.z; end
	end

	self:SetRenderBoundsWS(min, max);

end


function ENT:Spark(port, num)

	if (!spark:GetBool() && !CHECKEM.PlayerHoldingTool(LocalPlayer())) then return; end
	local str = (port == 1 && "Ip") || "Op";
	local atch = self:GetAttachment(self:LookupAttachment(str .. tostring(num)));

	ParticleEffect("CheckEm.Plug", atch.Pos, Angle(0, 0, 0), self);
	self:EmitSound("weapons/stunstick/spark" .. tostring(math.random(1, 3)) .. ".wav", 75, (math.random(110, 122) - (20 * port)));

end


local wired = Material("sprites/light_glow02_add");
local wireless_op = Material("checkem/Blip");
local wireless_ip = Material("checkem/Blip2");
local on = Color(50, 255, 50, 255);
local off = Color(255, 50, 50, 255);
local selected = Color(255, 225, 100, 255);

function ENT:DoDiodeLighting()

	if (self:NumInputs() > 0) then
		for i = 1, self:NumInputs() do
			local atch = self:GetAttachment(self:LookupAttachment("Ip" .. tostring(i)));
			if (!atch) then return; end
			local pos = atch.Pos;
			local clr = (self:GetInputOn(i) && on) || off;
			local size = 10;
			local wireless = self:GetInputWireless(i);

			if (self.LightIP == i) then
				clr = selected
			end

			local mat = (wireless && wireless_ip) || wired;
			if (wireless) then size = 4 end

			render.SetMaterial(mat);
			render.DrawSprite(pos, size, size, clr);
		end
	end

	if (self:NumOutputs() > 0) then
		for i = 1, self:NumOutputs() do
			local atch = self:GetAttachment(self:LookupAttachment("Op" .. tostring(i)));
			if (!atch) then return; end
			local pos = atch.Pos;
			local clr = (self:GetOutputOn(i) && on) || off;
			local size = 10;
			local wireless = self:GetOutputHasWireless(i);

			if (self.LightOP == i || self.KeepLit == i) then
				clr = selected;
			end

			local mat = (wireless && wireless_op) || wired;
			if (wireless) then size = 4 end

			render.SetMaterial(mat);
			render.DrawSprite(pos, size, size, clr);
		end
	end

end


local function blink()
	local t = (math.Round(CurTime() * 3.6) % 2);
	if (t == 1) then
		return true;
	else
		return false;
	end
end

local off = Material("checkem/wire");
local on = Material("checkem/wire2");

local function calcBezier(p0, p1, p2, p3, t)
	t = math.Clamp(t, 0.0, 1.0);
	local ot = (1.0 - t);
	return (math.pow(ot, 3) * p0) + (math.pow(t, 3) * p3) + (3.0 * math.pow(ot, 2) * t * p1) + (3.0 * ot * math.pow(t, 2) * p2);
end

local function Bezier(p0, p1, p2, p3, t)
	return Vector(calcBezier(p0.x, p1.x, p2.x, p3.x, t), calcBezier(p0.y, p1.y, p2.y, p3.y, t), calcBezier(p0.z, p1.z, p2.z, p3.z, t));
end

local WIRE_QUALITY = 16;
local WIRE_CP_SCALE = 16;

local function DrawWireBetweenGates(opEnt, op, ipEnt, ip, canBlink)
	if (!IsValid(ipEnt)) then return; end
	local ipatch = ipEnt:GetAttachment(ipEnt:LookupAttachment("Ip" .. tostring(ip)));
	if (!ipatch) then return; end
	local ippos = ipatch.Pos;

	local opatch = opEnt:GetAttachment(opEnt:LookupAttachment("Op" .. tostring(op)));
	if (!opatch) then return; end
	local oppos = opatch.Pos;

	//push the wires behind the diodes
	local up = opEnt:GetUp();
	oppos = (oppos + (up * -.5));
	up = ipEnt:GetUp();
	ippos = (ippos + (up * -.5));
	
	local pos = opEnt:GetPos();
	local cpOne = oppos + (opatch.Ang:Forward():GetNormal() * WIRE_CP_SCALE);
	
	pos = ipEnt:GetPos();
	local cpTwo = ippos + (ipatch.Ang:Forward():GetNormal() * WIRE_CP_SCALE);
	
	local b = true;
	if (ip == ipEnt.LightIP && canBlink) then
		b = blink();
	end

	if (b) then
		local mat = (opEnt:GetOutputOn(op) && on) || off;
		render.SetMaterial(mat);
		
		if (highQ:GetBool()) then
			local frac = (1 / WIRE_QUALITY);
			local t = -frac;
			local prevPos = oppos;
			for ti = 0, WIRE_QUALITY do
				t = (t + frac);
				local newPos = Bezier(oppos, cpOne, cpTwo, ippos, t);
				local smax = (8 + ((prevPos - newPos):Length() / 8));
				render.DrawBeam(prevPos, newPos, .8, -8, -smax, Color(255, 255, 255, 255));
				prevPos = newPos;
			end
		else
			local smax = (8 + ((oppos - ippos):Length() / 8));
			render.DrawBeam(oppos, ippos, .8, -8, -smax, Color(255, 255, 255, 255));
		end
	end
end

local function DrawWireBetweenSENT(opEnt, op, SENT)
	local ippos = SENT:GetPos();

	local opatch = opEnt:GetAttachment(opEnt:LookupAttachment("Op" .. tostring(op)));
	local oppos = opatch.Pos;

	//push the wires behind the diodes
	local up = opEnt:GetUp();
	oppos = (oppos + (up * -.5));
	
	local pos = opEnt:GetPos();
	local cpOne = oppos + ((Vector(pos.x, pos.y, pos.z) - Vector(oppos.x, oppos.y, oppos.z)):GetNormal() * -WIRE_CP_SCALE);
	local cpTwo = ippos + ((Vector(pos.x, pos.y, pos.z) - Vector(ippos.x, ippos.y, ippos.z)):GetNormal() * WIRE_CP_SCALE);

	local mat = (opEnt:GetOutputOn(op) && on) || off;
	render.SetMaterial(mat);
	
	if (highQ:GetBool()) then
		local frac = (1 / WIRE_QUALITY);
		local t = -frac;
		local prevPos = oppos;
		for ti = 0, WIRE_QUALITY do
			t = (t + frac);
			local newPos = Bezier(oppos, cpOne, cpTwo, ippos, t);
			local smax = (8 + ((prevPos - newPos):Length() / 8));
			render.DrawBeam(prevPos, newPos, .8, -8, -smax, Color(255, 255, 255, 255));
			prevPos = newPos;
		end
	else
		local smax = (8 + ((oppos - ippos):Length() / 8));
		render.DrawBeam(oppos, ippos, .8, -8, -smax, Color(255, 255, 255, 255));
	end
end

local function DrawWireToCrosshair(opEnt, op)
	local opatch = opEnt:GetAttachment(opEnt:LookupAttachment("Op" .. tostring(op)));
	if (!opatch) then return; end
	local oppos = opatch.Pos;

	//push the wires behind the diodes
	local up = opEnt:GetUp();
	oppos = (oppos + (up * -.5));
	
	local tr = LocalPlayer():GetEyeTrace();
	
	local pos = opEnt:GetPos();
	local hitPos = tr.HitPos;
	local cpOne = oppos + ((Vector(pos.x, pos.y, pos.z) - Vector(oppos.x, oppos.y, oppos.z)):GetNormal() * -WIRE_CP_SCALE);
	local cpTwo = hitPos + (tr.HitNormal * 16);

	local mat = (opEnt:GetOutputOn(op) && on) || off;
	render.SetMaterial(mat);
	
	if (highQ:GetBool()) then
		local frac = (1 / WIRE_QUALITY);
		local t = -frac;
		local prevPos = oppos;
		for ti = 0, WIRE_QUALITY do
			t = (t + frac);
			local newPos = Bezier(oppos, cpOne, cpTwo, hitPos, t);
			local smax = (8 + ((prevPos - newPos):Length() / 8));
			render.DrawBeam(prevPos, newPos, .8, -8, -smax, Color(255, 255, 255, 255));
			prevPos = newPos;
		end
	else
		local smax = (8 + ((oppos - trPos):Length() / 8));
		render.DrawBeam(oppos, trPos, .8, -8, -smax, Color(255, 255, 255, 255));
	end
end

function ENT:DrawWires()
	local numop = self:NumOutputs();
	if (numop > 0) then
		for i = 1, numop do
			for k, v in pairs(self:GetOutputEnts(i)) do
				
				local wireless = v[3];
				if (!wireless || (wireless && CHECKEM.PlayerHoldingTool(LocalPlayer()))) then
					DrawWireBetweenGates(self, i, Entity(v[1]), v[2], true);
				end

			end
			for k, v in pairs(self:GetOutputSENTs(i)) do
				
				local ent = Entity(v[1]);
				local wireless = v[3];

				if (IsValid(ent)) then
					if (!wireless || (wireless && CHECKEM.PlayerHoldingTool(LocalPlayer()))) then
						DrawWireBetweenSENT(self, i, ent);
					end
				end

			end
		end
	end

	local lit = self.KeepLit;
	if (lit != 0 && lit != nil && LocalPlayer():GetActiveWeapon():GetClass() == "gmod_tool") then
		local tool = LocalPlayer():GetActiveWeapon():GetToolObject();
		local ippos = nil;

		local opatch = self:GetAttachment(self:LookupAttachment("Op" .. tostring(lit)));
		local oppos = (opatch.Pos + (self:GetUp() * -.5));

		if (tool.IP == nil) then
			//draw wire from OP to crosshair		
			DrawWireToCrosshair(self, lit);
		else
			//draw wire from OP to IP
			if (IsValid(tool.Gate)) then
				local ent = tool.Gate;
				if (ent.CheckEmGate && ent:NumInputs() > 0) then
					DrawWireBetweenGates(self, lit, ent, tool.IP, false);
				else
					DrawWireBetweenSENT(self, lit, ent);
				end
			end
		end
	end
end

net.Receive("CHKMSPARK", function(len)
	local ent = Entity(net.ReadLong());
	local port, num = net.ReadLong(), net.ReadLong();
	if (IsValid(ent)) then ent:Spark(port, num); end
end);


local function checkvalid(id)
	return IsValid(Entity(id));
end


function CHECKEM.QueueDupeOP(id, tbl)
	local ent = Entity(id);
	if (IsValid(ent)) then ent.Outputs = tbl; end
end

net.Receive("CHKMDUPEOP", function(len)
	local id, tbl = net.ReadLong(), net.ReadTable();
	CHECKEM.QueueEventtxt("CHKMDUPEOP", id, {checkvalid, {id}}, CHECKEM.QueueDupeOP, id, tbl);
end);


function CHECKEM.QueueDupeIP(id, tbl)
	local ent = Entity(id);
	if (IsValid(ent)) then ent.Inputs = tbl; end
end

net.Receive("CHKMDUPEIP", function(len)
	local id, tbl = net.ReadLong(), net.ReadTable();
	CHECKEM.QueueEventtxt("CHKMDUPEIP", id, {checkvalid, {id}}, CHECKEM.QueueDupeIP, id, tbl);
end);


function CHECKEM.QueueDupeVars(id, tbl)
	local ent = Entity(id);
	if (IsValid(ent)) then ent.CHKMVars = tbl; end
end

net.Receive("CHKMDUPEVAR", function(len)
	local id, tbl = net.ReadLong(), net.ReadTable();
	CHECKEM.QueueEventtxt("CHKMDUPEVAR", id, {checkvalid, {id}}, CHECKEM.QueueDupeVars, id, tbl);
end);


function CHECKEM.QueueDupeSENTIP(id, tbl)
	local ent = Entity(id);
	if (IsValid(ent)) then ent.CHKMInputEnts = tbl; end
end

net.Receive("CHKMDUPESENTIP", function(len)
	local id, tbl = net.ReadLong(), net.ReadTable();
	CHECKEM.QueueEventtxt("CHKMDUPESENTIP", id, {checkvalid, {id}}, CHECKEM.QueueDupeSENTIP, id, tbl);
end);