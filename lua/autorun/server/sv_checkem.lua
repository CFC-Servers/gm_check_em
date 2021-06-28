
AddCSLuaFile("autorun/sh_checkem.lua");
AddCSLuaFile("autorun/client/cl_checkem.lua");

include('autorun/sh_checkem.lua')

resource.AddWorkshop("104768448");

util.AddNetworkString("CHKMSETIP");
util.AddNetworkString("CHKMCLRIP");
util.AddNetworkString("CHKMIPTXT");
util.AddNetworkString("CHKMIPST");
util.AddNetworkString("CHKMNUMIP");
util.AddNetworkString("CHKMSETOP");
util.AddNetworkString("CHKMCLROP");
util.AddNetworkString("CHKMOPADD");
util.AddNetworkString("CHKMCLROPENT");
util.AddNetworkString("CHKMOPTXT");
util.AddNetworkString("CHKMOPST");
util.AddNetworkString("CHKMNUMOP");
util.AddNetworkString("CHKMVAR");
util.AddNetworkString("CHKMWTIP");
util.AddNetworkString("CHKMSPARK");
util.AddNetworkString("CHKMSENTADD");
util.AddNetworkString("CHKMSENTCLR");
util.AddNetworkString("CHKMSENTUPD");
util.AddNetworkString("CHKMMENU");
util.AddNetworkString("CHKMPLYVAR");
util.AddNetworkString("CHKMTOOLGATE");
util.AddNetworkString("CHKMWIREGATE");
util.AddNetworkString("CHKMWIREIP");
util.AddNetworkString("CHKMWIREOP");
util.AddNetworkString("CHKMWIRELESS");
util.AddNetworkString("CHKMWIRESEQ");
util.AddNetworkString("CHKMWIRESEQX");
util.AddNetworkString("CHKMWIRESEQY");
util.AddNetworkString("CHKMDUPEOP");
util.AddNetworkString("CHKMDUPEIP");
util.AddNetworkString("CHKMDUPESENTIP");
util.AddNetworkString("CHKMDUPEVAR");
util.AddNetworkString("CHKMRMVQ");
util.AddNetworkString("CHKMTOOLMODE");
util.AddNetworkString("CHKMTOOLSTG");

hook.Add("PlayerInitialSpawn", "CHKM_PlayerInitialSpawn", function(ply)
	ply.GateToSpawn = "ce_battery";
	ply.CHECKEMToolModel = "models/checkem/basechip.mdl";
	ply.CHECKEMToolSkin = 8;
	ply.CHKMVars = {};
	for k, v in pairs(CHECKEM.Vars) do
		ply.CHKMVars[k] = {};
		for j, c in pairs(v) do
			ply.CHKMVars[k][j] = c.val;
		end
	end
	timer.Create(tostring(ply) .. "chkmoptionsupdate", 1, 0, function()
		if (IsValid(ply)) then
			ply:SetNetworkedInt("CHKMCntProtect", tonumber(ply:GetInfo("checkem_disableotherstools")));
		else
			timer.Remove(tostring(ply) .. "chkmoptionsupdate");
		end
	end);
end);
