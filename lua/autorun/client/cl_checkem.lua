
include('autorun/sh_checkem.lua')

surface.CreateFont("chkmfont", {
	size = ScreenScale(5),
	weight = 500,
	antialias = true,
	font = "Arial"
});


CHECKEM.Layouts = {};

function CHECKEM.HandleLayout(class, func)
	if (CHECKEM.Layouts[class] == nil) then
		CHECKEM.Layouts[class] = func;
	end
end


local function dobasegates(sk, mdl, ang)

	local f = function(panel, ent)
		ent:SetModel(mdl);
		ent:SetSkin(sk);
		ent:SetAngles(ang);
		panel:SetCamPos(Vector(0, 0, 8));
		panel:SetLookAt(Vector(0, 0, 0));
	end

	return f;

end

local tbl = {};
tbl["ce_and"] = 2;
tbl["ce_or"] = 4;
tbl["ce_xor"] = 6;
tbl["ce_battery"] = 8;
tbl["ce_not"] = 10;
tbl["ce_toggle"] = 12;
tbl["ce_randomizer"] = 14;
tbl["ce_timer"] = 16;
tbl["ce_counter"] = 18;
tbl["ce_seq_piano"] = 0;
tbl["ce_seq_drums"] = 0;
tbl["ce_seq_bpm"] = 0;

for k, v in pairs(tbl) do
	CHECKEM.HandleLayout(k, dobasegates(v, "models/checkem/basechip.mdl", Angle(0, 180, 0)));
end

local tbl = {};
tbl["ce_sensor_player"] = 0;
tbl["ce_sensor_use"] = 2;
tbl["ce_sensor_damage"] = 4;
tbl["ce_sensor_water"] = 6;
tbl["ce_sensor_impact"] = 8;
tbl["ce_sensor_tag"] = 10;
tbl["ce_sensor_velocity"] = 12;
tbl["ce_sensor_npc"] = 14;
tbl["ce_sensor_laser"] = 16;
tbl["ce_sensor_freeze"] = 18;

for k, v in pairs(tbl) do
	CHECKEM.HandleLayout(k, dobasegates(v, "models/checkem/sensor.mdl", Angle(0, -180, 0)));
end

local tbl = {};
tbl["ce_mod_remove"] = 0;
tbl["ce_mod_color"] = 16;
tbl["ce_mod_ignite"] = 6;
tbl["ce_mod_damage"] = 10;
tbl["ce_mod_freeze"] = 12;
tbl["ce_mod_physprop"] = 14;

for k, v in pairs(tbl) do
	CHECKEM.HandleLayout(k, dobasegates(v, "models/checkem/basechip2.mdl", Angle(0, -180, 0)));
end

CHECKEM.HandleLayout("ce_sound_emitter", dobasegates(8, "models/checkem/basechip2.mdl", Angle(0, -180, 0)));


hook.Add("HUDPaint", "CHKM_DrawInputNames", function()
	
	local ply = LocalPlayer();
	if (!ply:Alive()) then return; end

	local wep = ply:GetActiveWeapon();
	if (!IsValid(wep)) then return; end
	if (wep:GetClass() != "gmod_tool") then return; end

	local tool = wep:GetToolObject();
	if (!tool || type(tool) == "boolean") then return; end
	if (!tool.WireTool) then return; end

	local ent, ip = tool.Gate, tool.IP;

	if (!IsValid(ent) || !ip || ip == 0) then return; end
	//if (ent:GetPos():Distance(ply:GetShootPos()) > 250) then return; end

	if (ent.CheckEmGate) then
		
		if (ent.InputTexts == nil) then return; end
		if (ent:NumInputs() <= 0 || table.Count(ent.InputTexts) <= 0) then return; end

		local txt = (tostring(ip) .. ": " .. ent:GetInputText(ip));

		surface.SetFont("chkmfont");
		local w, h = surface.GetTextSize(txt);

		local ipatch = ent:GetAttachment(ent:LookupAttachment("Ip" .. tostring(ip)));
		local ippos = ipatch.Pos:ToScreen();

		local x, y = ((ippos.x - w) - 4), (ippos.y - (h * .5));

		draw.RoundedBox(4, (x - 16), y, (w + 8), h, Color(50, 50, 80, 200));
		draw.SimpleText(txt, "chkmfont", (ippos.x - 16), ippos.y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER);

	else //SENT

		if (tool:GetStage() == 0 || ent.CHKMInputs == nil) then return; end
		local ips = ent.CHKMInputs;

		if (ips[ip] != nil) then
			local txt = (tostring(ip) .. ": " .. ips[ip]);

			surface.SetFont("chkmfont");
			local w, h = surface.GetTextSize(txt);

			local pos = ent:GetPos():ToScreen();

			local x, y = ((pos.x - w) - 4), (pos.y - (h * .5));

			draw.RoundedBox(4, (x - 16), y, (w + 8), h, Color(50, 50, 80, 200));
			draw.SimpleText(txt, "chkmfont", (pos.x - 16), pos.y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER);
		end

	end

end);

hook.Add("HUDPaint", "CHKM_DrawOutputNames", function()
	
	local ply = LocalPlayer();
	if (!ply:Alive()) then return; end

	local wep = ply:GetActiveWeapon();
	if (!IsValid(wep)) then return; end
	if (wep:GetClass() != "gmod_tool") then return; end

	local tool = wep:GetToolObject();
	if (!tool || type(tool) == "boolean") then return; end
	if (!tool.WireTool) then return; end

	local ent, op = tool.Gate, tool.OP;

	if (IsValid(tool.GateAboutToConnect)) then
		ent, op = tool.GateAboutToConnect, tool.OPAboutToConnect;
	end
	
	if (!IsValid(ent) || !op || op == 0 || ent.OutputTexts == nil || table.Count(ent.OutputTexts) <= 0) then return; end
	//if (ent:GetPos():Distance(ply:GetShootPos()) > 250) then return; end

	if (ent.CheckEmGate) then
		
		if (ent:NumOutputs() <= 0 || table.Count(ent.OutputTexts) <= 0) then return; end

		local txt = (tostring(op) .. ": " .. ent:GetOutputText(op));

		surface.SetFont("chkmfont");
		local w, h = surface.GetTextSize(txt);

		local ipatch = ent:GetAttachment(ent:LookupAttachment("Op" .. tostring(op)));
		local ippos = ipatch.Pos:ToScreen();

		local x, y = ((ippos.x + 16) - 4), (ippos.y - (h * .5));

		draw.RoundedBox(4, x, y, (w + 8), h, Color(50, 50, 80, 200));
		draw.SimpleText(txt, "chkmfont", (ippos.x + 16), ippos.y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);

	end

end);
