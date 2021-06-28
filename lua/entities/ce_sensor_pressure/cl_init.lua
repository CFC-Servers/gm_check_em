
include('shared.lua')

CHECKEM.HandleLayout("ce_sensor_pressure", function(panel, ent)
	ent:SetModel("models/checkem/pressurepad.mdl");
	ent:SetAngles(Angle(0, 180, 0));
	panel:SetCamPos(Vector(0, 0, 42));
	panel:SetLookAt(Vector(0, 0, 0));
end);

