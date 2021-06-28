
include('shared.lua')

CHECKEM.HandleLayout("ce_sequencer", function(panel, ent)
	ent:SetModel("models/checkem/sequencer.mdl");
	ent:SetAngles(Angle(0, 180, 0));
	panel:SetCamPos(Vector(0, 0, 18));
	panel:SetLookAt(Vector(0, 0, 0));
end);
