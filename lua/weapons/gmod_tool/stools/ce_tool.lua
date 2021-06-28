TOOL.Category = "Check 'em"
TOOL.Name = "Check 'em Tool"
TOOL.Command = nil
TOOL.ConfigName = nil --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 


if (CLIENT) then

	language.Add("tool.ce_tool.name", "Check 'Em Tool")
	language.Add("tool.ce_tool.desc", "Place Check 'Em Gates With This Tool")
	language.Add("tool.ce_tool.0", "Left click to place a Check 'Em gate or update an existing one. Right click to rotate the gate. Reload to copy gate.")
	
end


function TOOL:Init()
	self.Sequencer = nil;
	self.SpawnRot = 0;
	self.LastRightClick = 0;
end


function TOOL:LeftClick(tr) --On left click
	
	if (SERVER) then
		local ply = self:GetOwner();
		local gate = self:GetOwner().GateToSpawn;

		if (IsValid(tr.Entity) && tr.Entity:GetClass() == gate) then
			if (ply.CHKMVars[gate] != nil) then
				for k, v in pairs(ply.CHKMVars[gate]) do
					if (tr.Entity:GetVariable(k) != v) then
						tr.Entity:ChangeVariable(k, v);
					end
				end
			end
			return true;
		end

		local e = ents.Create(gate);
		e:SetPos(tr.HitPos + (tr.HitNormal * .75));
		
		local ang = tr.HitNormal:Angle();
		ang:RotateAroundAxis(ang:Right(), -90);
		ang:RotateAroundAxis(ang:Up(), -self.SpawnRot);
		e:SetAngles(ang);

		e:Spawn();
		e:SetNetworkedEntity("CHKMOwner", ply);

		if (IsValid(self.Sequencer)) then
			self.Sequencer:AttachGate(e, self.ClosestX, self.ClosestY);
		else
			if (!tr.Entity:IsWorld()) then
				e.WeldedTo = tr.Entity;
				constraint.Weld(e, tr.Entity, tr.PhysicsBone, 0, 0, true);
				e:SetParent(tr.Entity);
			else
				local phys = e:GetPhysicsObject();
				if (phys:IsValid()) then
					phys:EnableMotion(false);
				end
			end
		end

		if (ply.CHKMVars[gate] != nil) then
			if (IsValid(e)) then
				for k, v in pairs(ply.CHKMVars[gate]) do
					timer.Simple(.1, function() if (IsValid(e) && type(k) != "number") then e:ChangeVariable(k, v) end end);
				end
			end
		end

		undo.Create(e.PrintName)
			undo.AddEntity(e);
			undo.SetPlayer(self:GetOwner());
		undo.Finish()
	end
	
	return true;
	
end

function TOOL:RightClick(tr)
	if (CurTime() < self.LastRightClick) then return; end
	self.LastRightClick = (CurTime() + .1);
	local rot = 15;
	if (self:GetOwner():KeyDown(IN_USE)) then rot = 45; end
	self.SpawnRot = (self.SpawnRot + rot);
	if (self.SpawnRot >= 360) then self.SpawnRot = (self.SpawnRot - 360); end
	if (CLIENT) then surface.PlaySound("checkem/rotate_" .. tostring(rot) .. ".wav"); end
end


function TOOL:Reload()
	local ply = self:GetOwner();
	local tr = ply:GetEyeTrace();
	local e = tr.Entity;
	if (!IsValid(e)) then return; end
	if (!e.CheckEmGate) then return; end

	local c = e:GetClass();
	ply.GateToSpawn = c;
	ply.CHECKEMToolModel = e:GetModel();
	ply.CHECKEMToolSkin = e:GetSkin();

	if (SERVER && e:HasCustomVars()) then
		for k, v in pairs(CHECKEM.Vars[c]) do
			ply.CHKMVars[c][v.name] = e:GetVariable(v.name);
		end
	end

	return true;
end


function TOOL:UpdateGhostGate(ent, ply)

	ent:SetModel(ply.CHECKEMToolModel);
	ent:SetSkin(ply.CHECKEMToolSkin);

	if (IsValid(self.Sequencer)) then
		local seq = self.Sequencer;
		local x, y = self.ClosestX, self.ClosestY;
		local pos, ang = seq:GetSequencePos(x, y), seq:GetSequenceAng(x, y);
		ent:SetPos(pos);
		ent:SetAngles(ang);
	else
		local tr = ply:GetEyeTrace();
		if (IsValid(tr.Entity) && tr.Entity:GetClass() == ply.GateToSpawn) then
			ent:SetNoDraw(true);
		else
			ent:SetNoDraw(false);
			ent:SetPos(tr.HitPos + (tr.HitNormal * .75));
			local ang = tr.HitNormal:Angle();
			ang:RotateAroundAxis(ang:Right(), -90);
			ang:RotateAroundAxis(ang:Up(), -self.SpawnRot);
			ent:SetAngles(ang);
		end
	end

	if (ent:GetModel() == "models/checkem/tag.mdl") then ent:SetBodygroup(1, 1); end

end

function TOOL:Think()

	if (!IsValid(self.GhostEntity)) then
		self:MakeGhostEntity("models/checkem/basechip.mdl", Vector(0, 0, 0), Angle(0, 0, 0));
	else
		local ply = self:GetOwner();
		if (!ply.CHECKEMToolModel) then ply.CHECKEMToolModel = "models/checkem/basechip.mdl"; end
		if (!ply.CHECKEMToolSkin) then ply.CHECKEMToolSkin = 8; end
		self:UpdateGhostGate(self.GhostEntity, self:GetOwner());
	end

	if (CLIENT) then self:DoClientThink(); end

end

if (SERVER) then


net.Receive("CHKMTOOLGATE", function(len)
	local ply, gate, mdl, sk = Entity(net.ReadLong()), net.ReadString(), net.ReadString(), net.ReadLong();
	ply.GateToSpawn = gate;
	ply.CHECKEMToolModel = mdl;
	ply.CHECKEMToolSkin = tonumber(sk);
end);

net.Receive("CHKMWIRESEQ", function(len)
	local wep = Entity(net.ReadLong());
	if (!IsValid(wep)) then return; end
	local tool = wep:GetToolObject();
	local num = net.ReadLong();
	local gate = nil;
	if (num != 0) then
		gate = Entity(num);
	end
	tool.Sequencer = gate;
end);

net.Receive("CHKMWIRESEQX", function(len)
	local wep = Entity(net.ReadLong());
	if (!IsValid(wep)) then return; end
	local tool = wep:GetToolObject();
	local num = net.ReadLong();
	tool.ClosestX = num;
end);

net.Receive("CHKMWIRESEQY", function(len)
	local wep = Entity(net.ReadLong());
	if (!IsValid(wep)) then return; end
	local tool = wep:GetToolObject();
	local num = net.ReadLong();
	tool.ClosestY = num;
end);

end


if (CLIENT) then



function TOOL:UpdateServerGate(gate)
	self.Sequencer = gate;
	net.Start("CHKMWIRESEQ")
		net.WriteLong(self.Weapon:EntIndex());
		if (gate != nil) then
			net.WriteLong(gate:EntIndex());
		else
			net.WriteLong(0);
		end
	net.SendToServer()
end

function TOOL:UpdateServerX(x)
	self.ClosestX = x;
	net.Start("CHKMWIRESEQX")
		net.WriteLong(self.Weapon:EntIndex());
		net.WriteLong(x);
	net.SendToServer()
end
function TOOL:UpdateServerY(y)
	self.ClosestY = y;
	net.Start("CHKMWIRESEQY")
		net.WriteLong(self.Weapon:EntIndex());
		net.WriteLong(y);
	net.SendToServer()
end

function TOOL:RemoveServerGate()
	local ent = self.Sequencer;
	if (ent != nil) then
		self:UpdateServerGate(nil);
	end
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
	p5 = Vector(p5.x, p5.y, 0);
    return behind(p1,p2,p5) and
           behind(p2,p3,p5) and
           behind(p3,p4,p5) and
           behind(p4,p1,p5)    
end


function TOOL:DoClientThink()

	local ply = self:GetOwner();
	local tr = ply:GetEyeTrace();
	if (!tr.Hit) then
		return;
	end

	local pos = tr.HitPos;
	local scrpos = pos:ToScreen();

	//if (LocalPlayer():IsWorldClicking()) then scrpos.x, scrpos.y = gui.MousePos(); end

	//LocalPlayer():ChatPrint(tostring(scrpos.x) .. "  " .. tostring(scrpos.y));

	local seq = nil;

	//we're gonna have to use the bounds of the model
	//to find the gate, if we still don't find anything
	//just set just RemoveServerGate();
	for k, v in pairs(ents.FindByClass("ce_sequencer")) do
		local dist = v:GetPos():Distance(ply:GetShootPos());
		local max = 1250;
		if (dist < max) then
			local bounds = self:RetreiveBounds(v);
			self:SortBounds(bounds);

			if (intersects(bounds[1], bounds[2], bounds[3], bounds[4], scrpos)) then
				seq = v;
				break;
			end
		end
	end

	if (IsValid(seq)) then
		if (seq != self.Sequencer) then self:UpdateServerGate(seq); end
	else
		self:RemoveServerGate();
	end

	//we are looking at a Sequencer, look for attachments
	if (IsValid(self.Sequencer) && self.Sequencer["GetNumX"] != nil && self.Sequencer["GetNumY"] != nil) then
		local ent = self.Sequencer;

		local x = self:FindClosestX(ent, scrpos);
		if (self.ClosestX != x) then self:UpdateServerX(x); end

		local y = self:FindClosestY(ent, scrpos, x);
		if (self.ClosestY != y) then self:UpdateServerY(y); end
	end

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

function TOOL:FindClosestX(gate, pos)
	local tbl = {};
	local num = gate:GetNumX();
	for i = 1, num do
		local atch = gate:GetAttachment(gate:LookupAttachment("1_" .. tostring(i)));
		table.insert(tbl, atch.Pos:ToScreen());
	end
	return FindClosest(pos, tbl);
end

function TOOL:FindClosestY(gate, pos, x)
	local tbl = {};
	local num = gate:GetNumY();
	for i = 1, num do
		local atch = gate:GetAttachment(gate:LookupAttachment(tostring(i) .. "_" .. tostring(x)));
		table.insert(tbl, atch.Pos:ToScreen());
	end
	return FindClosest(pos, tbl);
end


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



end


function TOOL.BuildCPanel(panel)

	local g = vgui.Create("CheckEmToolMenu", panel);
	g:SetPos(0, 0);
	g:SetSize(panel:GetWide(), 640);
	g.ToolMenu = true;

	g.OnSelected = function(pnl, class, mdl, sk)
		net.Start("CHKMTOOLGATE")
			net.WriteLong(LocalPlayer():EntIndex());
			net.WriteString(class);
			net.WriteString(mdl);
			net.WriteLong(sk);
		net.SendToServer()
		LocalPlayer().GateToSpawn = class;
		LocalPlayer().CHECKEMToolModel = mdl;
		LocalPlayer().CHECKEMToolSkin = tonumber(sk);
		g.Vars:SetGate(class);
	end

	panel:AddItem(g);
	
end
