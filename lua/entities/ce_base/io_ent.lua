
//this handles all ingoing and outgoing connections
//with other entities in the checkem system

//connects ENT's output #op to ent through input #ip
function ENT:ConnectTo(op, ent, ip, wireless)

	//verify that this is a valid thing to connect to	
	if 	(!IsValid(ent) || (!ent.CheckEmGate && !CHECKEM.IsWireable(ent))) then
		Error(tostring(self) .. " cannot connect to invalid/incompatible entity " .. tostring(ent));
		return;
	end

	if (op <= self:NumOutputs() && op > 0) then

		if (ent.CheckEmGate) then

			if (ip <= ent:NumInputs()) then

				local curent, curop = ent:GetInputEnt(ip), ent:GetInputOutput(ip);

				if (curent == self && curop == op) then return; end //this is all already setup

				//setup self:GetOutput(op) with all the new info
				self:AddOutput(op, ent, ip, wireless);

				//setup ent:GetInput(ip) with all the new info
				local on = (self:GetOutputOn(op) && 1) || 0;
				ent:SetInput(ip, on, self, op, wireless);

			end

		else

			if (CHECKEM.IsWireable(ent)) then

				local curent, curop, _ = CHECKEM.GetSENTInput(ent, ip);

				if (curent == self && curop == op) then return; end //this is all already setup

				self:AddOutput(op, ent, ip, wireless);

				CHECKEM.AddSENTInput(ent, ip, self, op);

			end

		end

	end

end

//This is called everytime one of ENT's inputs are updated on or off
function ENT:CheckInputs(ip)

	//do your input checking here, call ENT:ChangeOPState(op, num)
	//after checking inputs to change the on/off state of any output

	//ip == the input that changed and invoked this function's calling

end
