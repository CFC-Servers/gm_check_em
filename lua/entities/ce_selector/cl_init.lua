
include('shared.lua')


CHECKEM.HandleLayout("ce_selector", function(panel, ent)
	ent:SetModel("models/checkem/Basechip.mdl");
	ent:SetAngles(Angle(0, -90, 0));
	ent:SetSkin(4);
	//ent:SetPoseParameter("Inputs", 5);
	//ent:SetPoseParameter("Outputs", 3);
	ent:ResetSequence("bd5");
	panel:SetCamPos(Vector(0, 0, 18));
	panel:SetLookAt(Vector(0, 0, 0));
end);
