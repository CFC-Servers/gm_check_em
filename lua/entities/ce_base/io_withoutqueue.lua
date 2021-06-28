
//this script includes all of the input and output functions
//for the gate system


if (SERVER) then
	AddCSLuaFile("IO_ent.lua");
	AddCSLuaFile("sent_control.lua");
	include('IO_ent.lua')
end

include('sent_control.lua')


function ENT:SizeUp()
	if (SERVER) then
		local ip, op = self:NumInputs(), self:NumOutputs();
		if (ip > op) then
			self:ResetSequence(self:LookupSequence("bd" .. tostring(ip)));
			return;
		end
		if (op > ip) then
			self:ResetSequence(self:LookupSequence("bd" .. tostring(op)));
			return;
		end
		self:ResetSequence(self:LookupSequence("bd" .. tostring(ip)));
	end
end


//INPUT ARRAY STRUCTURE:
//	[1] - Input #1
//		[1] - On/Off
//		[2] - {Entity ID, Output}
//		[3] - Input Text
//	
//ex.
//	[1] - GetInput(1)
//		[1] - GetInputOn(1)
//		[2] - GetInputEnt(1)
//		[3] - GetInputText(1)


local clearedarray = {0, {NULL, nil}, ""};

//returns the inputs array
function ENT:InputArray()
	return self.Inputs;
end

//this function is called on initialize, set ENT.SetNumInputs from
//your entity before initialization to change the number of desired inputs
function ENT:SetupInputs()
	local num = self.SetNumInputs;
	if (num <= 0) then
		return;
	end
	if (num) then
		for i = 1, num do
			self:InputArray()[i] = table.Copy(clearedarray);
		end
		self:UpdateInputTexts();
		return;
	end
	Error(tostring(self) .. " has no SetNumInputs")
end

//you can call this function to change the number of
//inputs a gate has, any inputs that exist and are > num
//will be removed and their connections severed
function ENT:UpdateNumInputs(num)

	self.SetNumInputs = num;
	local ips = self:InputArray();
	local cur = self:NumInputs();

	//shut. down. EVERYTHING
	if (num == 0) then
		self:ClearAllInputs();
		self.Inputs = {};
		return;
	end

	//removing existing entries
	if (num < cur) then
		for i = 1, (cur - num) do
			local n = ((cur + 1) - i);
			self:ClearInput(n);
			table.remove(ips, n);
		end
	end

	//adding more onto the end
	if (num > cur) then
		for i = math.Clamp((cur + 1), 1, 10), num do
			self:InputArray()[i] = table.Copy(clearedarray);
		end
	end

	self:SizeUp();

	self:UpdateInputTexts();

end

//when this function is called it updates the input texts
//based on what is inside the self.InputTexts array
function ENT:UpdateInputTexts()
	local txt = self.InputTexts;
	for i = 1, #txt do
		if (txt[i] && i <= self:NumInputs()) then
			self:InputArray()[i][3] = txt[i];
		end
	end
end

//returns how many inputs this gate has
function ENT:NumInputs()
	return (#self:InputArray() || 0);
end

//removes everything inside the input at num
//b == true when you want it to ignore
//calling ClearOutputEnt on what's connected to it
function ENT:ClearInput(num, b)
	if (num <= self:NumInputs()) then

		if (SERVER) then

			if (!b && IsValid(self:GetInputEnt(num))) then
				local ent = self:GetInputEnt(num);
				local op = self:GetInputOutput(num);
				ent:ClearOutputEnt(op, self, num);
			end

			local str = "CHKMCLRIP";
			net.Start(str)
				net.WriteLong(self:EntIndex());
				net.WriteLong(num);
				net.WriteLong((b == true && 1) || 0);
			net.Broadcast()

		end

		local copy = table.Copy(clearedarray);
		self:InputArray()[num][1] = copy[1];
		self:InputArray()[num][2] = copy[2];
		self:InputArray()[num][4] = false;

		self:ChangeIPState(num, 0);

	end
end

function ENT:ClearAllInputs()
	for i = 1, self:NumInputs() do
		self:ClearInput(i);
	end
end

//returns the array stored in ENT.Inputs[num] if one exists
function ENT:GetInput(num)
	if (num != nil && num <= self:NumInputs()) then
		return self:InputArray()[num];
	end
	return nil;
end

//returns whether that input is on or off
function ENT:GetInputOn(num)
	return ((self:GetInput(num)[1] == 1) && true) || false;
end

//returns the entity connected to this input if one exists
function ENT:GetInputEnt(num)
	local ip = self:GetInput(num);
	if (ip == nil) then
		return nil;
	end
	local ent = Entity(ip[2][1]);
	if (IsValid(ent)) then
		return ent;
	end
	return nil;
end

//returns the output # connected to this input if one exists
function ENT:GetInputOutput(num)
	return self:GetInput(num)[2][2];
end

function ENT:GetInputWireless(num)
	return self:GetInput(num)[4];
end

//returns the string text describing the input at num
function ENT:GetInputText(num)
	if (!IsValid(self) || !num) then return nil; end
	local str = self:GetInput(num)[3];
	if (str != nil) then
		return tostring(str);
	end
	return nil;
end


//these functions are used when connecting gates together

function ENT:SetIPOn(ip, num)
	self:GetInput(ip)[1] = num;
end

function ENT:SetIPEnt(ip, ent)
	self:GetInput(ip)[2][1] = ent:EntIndex();
end

function ENT:SetIPOutput(ip, op)
	self:GetInput(ip)[2][2] = op;
end

function ENT:SetIPWireless(ip, wireless)
	self:GetInput(ip)[4] = wireless;
end


function ENT:ChangeIPState(ip, num, b)
	self:SetIPOn(ip, num);

	if (SERVER) then
		if (!b) then
			local str = "CHKMIPST";
			net.Start(str)
				net.WriteLong(self:EntIndex());
				net.WriteLong(ip);
				net.WriteLong(num);
			net.Broadcast()
		end
	end

	self:CheckInputs(ip, tobool(num));
end



if (SERVER) then



//use this function when connecting gates
function ENT:SetInput(ip, on, ent, op, wireless)
	if (!IsValid(ent)) then
		self:ClearInput(ip);
		return;
	end

	if (IsValid(self:GetInputEnt(ip))) then
		self:ClearInput(ip);
	end

	self:SetIPOn(ip, on);
	self:SetIPEnt(ip, ent);
	self:SetIPOutput(ip, op);
	self:SetIPWireless(ip, wireless);

	local str = "CHKMSETIP";
	net.Start(str)
		net.WriteLong(self:EntIndex());
		net.WriteLong(ip);
		net.WriteLong(on);
		net.WriteLong(ent:EntIndex());
		net.WriteLong(op);
		net.WriteLong((wireless && 1) || 0);
	net.Broadcast();
end

//use this function to change any input text
//it will send the updates to the client
function ENT:ChangeInputTexts(tbl)
	self.InputTexts = tbl;
	self:UpdateInputTexts();
	
	local str = "CHKMIPTXT";
	net.Start(str)
		net.WriteLong(self:EntIndex());
		net.WriteTable(tbl);
	net.Broadcast()
end

function ENT:ChangeNumInputs(num)
	local max = math.Clamp(num, 0, 10);
	local curnum = self:NumInputs();
	if (num <= max && num >= 0) then
		self:UpdateNumInputs(num);
		
		local str = "CHKMNUMIP";
		net.Start(str)
			net.WriteLong(self:EntIndex());
			net.WriteLong(num);
		net.Broadcast()
	
	end
end


else


net.Receive("CHKMSETIP", function(len)
	local ent, ip, on,
		ent2, op, wireless = Entity(net.ReadLong()), net.ReadLong(),
		net.ReadLong(), Entity(net.ReadLong()), net.ReadLong(), net.ReadLong();
	ent:SetIPOn(ip, on);
	ent:SetIPEnt(ip, ent2);
	ent:SetIPOutput(ip, op);
	ent:SetIPWireless(ip, tobool(wireless));
end);

net.Receive("CHKMCLRIP", function(len)
	local ent, num, b = Entity(net.ReadLong()),
		net.ReadLong(),	((net.ReadLong() == 1 && true) || false);
	if (!IsValid(ent)) then return; end
	ent:ClearInput(num, b);
end);

net.Receive("CHKMIPTXT", function(len)
	local e = Entity(net.ReadLong());
	if (!IsValid(e)) then return; end
	e.InputTexts = net.ReadTable();
	e:UpdateInputTexts();	
end);

net.Receive("CHKMIPST", function(len)
	local e = Entity(net.ReadLong());
	if (!IsValid(e)) then return; end
	local ip, num = net.ReadLong(), net.ReadLong();
	e:SetIPOn(ip, num);
end)

net.Receive("CHKMNUMIP", function(len)
	local e = Entity(net.ReadLong());
	if (!IsValid(e)) then return; end
	local num = net.ReadLong();
	e:UpdateNumInputs(num);
end)
	



end




//OUTPUT ARRAY STRUCTURE:
//	[1] - Output #1
//		[1] - On/Off
//		[2] - Gates Array
//			[1] - {Entity ID, Input}
//			[2] - {Entity ID, Input}
//			...
//		[3] - SENTs Array
//			[1] - {Entity ID, Input}
//			[2] - {Entity ID, Input}
//			...
//		[4] - Text
//ex.
//	[1] - GetOutput(1)
//		[1] 	- GetOutputOn(1)
//		[2]		- GetOutputEnts(1)
//		[3]		- GetOutputSENTs(1)
//		[4] 	- GetOutputText(1)


local clearedarray = {0, {}, {}, ""};


//returns the outputs array
function ENT:OutputArray()
	return self.Outputs;
end


//this function is called on initialize, set ENT.SetNumOutputs from
//your entity before initialization to change the number of desired outputs
function ENT:SetupOutputs()
	local num = self.SetNumOutputs;
	if (num) then
		for i = 1, num do
			self:OutputArray()[i] = table.Copy(clearedarray);
		end
		self:UpdateOutputTexts();
		return;
	end
	Error(tostring(self) .. " has no SetNumOutputs")
end

//when this function is called it updates the output texts
//based on what is inside the self.InputTexts array
function ENT:UpdateOutputTexts()
	local txt = self.OutputTexts;
	for i = 1, #txt do
		if (txt[i] && i <= self:NumOutputs()) then
			self:OutputArray()[i][4] = txt[i];
		end
	end
end

//returns how many outputs this gate has
function ENT:NumOutputs()
	return #self:OutputArray();
end

//removes everything inside the output at num
function ENT:ClearOutput(num)
	if (num <= self:NumOutputs()) then

		local e = self:GetOutputEnts(num);
		if (#e > 0) then
			for k, v in pairs(e) do
				local ent = Entity(v[1]);
				local ip = v[2];
				ent:ClearInput(ip, true);
			end

			self:OutputArray()[num][1] = 0;
			self:OutputArray()[num][2] = {};

			if (SERVER) then
				local str = "CHKMCLROP";
				net.Start(str)
					net.WriteLong(self:EntIndex());
					net.WriteLong(num);
				net.Broadcast()
			end
		end

		//clear gmod ents as well
		//update their input state

	end
end

function ENT:ClearAllOutputs()
	for i = 1, self:NumOutputs() do
		if (#self:GetOutputEnts(i) > 0) then
			self:ClearOutput(i);
		end
	end
end

//removes the connection between ENT and ent at
//output #op plugged into input #ip
function ENT:RemoveOPEnt(op, ent, ip)

	if (op <= self:NumOutputs()) then
 
		if (ent.CheckEmGate) then

			for k, v in ipairs(self:GetOutputEnts(op)) do
				local e, i = Entity(v[1]), v[2];
				if (ent == e && ip == i) then
					table.remove(self:GetOutputEnts(op), k);
				end
			end

		else

			if (CHECKEM.IsWireable(ent)) then

				for k, v in pairs(self:GetOutputSENTs(op)) do
					local e, i = Entity(v[1]), v[2];
					if (ent == e && ip == i) then
						table.remove(self:GetOutputSENTs(op), k);
					end
				end

			end

		end

	end


end


//you can call this function to change the number of
//inputs a gate has, any inputs that exist and are > num
//will be removed and their connections severed
function ENT:UpdateNumOutputs(num)

	self.SetNumOutputs = num;
	local ops = self:OutputArray();
	local cur = self:NumOutputs();

	//shut. down. EVERYTHING
	if (num == 0) then
		self:ClearAllOutputs();
		self.Outputs = {};
		return;
	end

	//removing existing entries
	if (num < cur) then
		for i = 1, (cur - num) do
			local n = ((cur + 1) - i);
			self:ClearOutput(n);
			table.remove(ops, n);
		end
	end

	//adding more onto the end
	if (num > cur) then
		for i = math.Clamp(cur, 1, 10), num do
			self:OutputArray()[i] = table.Copy(clearedarray);
		end
	end

	self:SizeUp();

	self:UpdateOutputTexts();

end


//returns the array stored in ENT.Outputs[num] if one exists
function ENT:GetOutput(num)
	if (num <= self:NumOutputs()) then
		return self:OutputArray()[num];
	end
	return nil;
end

//returns whether that output is on or off
function ENT:GetOutputOn(num)
	return ((self:GetOutput(num)[1] == 1) && true) || false;
end

//returns the entities connected to this output if any exists
function ENT:GetOutputEnts(num)
	return self:GetOutput(num)[2];
end

//returns the current SENTs op num is outputting to
function ENT:GetOutputSENTs(num)
	return self:GetOutput(num)[3];
end

function ENT:GetOutputHasWireless(num)
	local b = false;
	for k, v in pairs(self:GetOutputEnts(num)) do
		if (v[3]) then b = true; break; end
	end
	if (b) then return true; end
	for k, v in pairs(self:GetOutputSENTs(num)) do
		if (v[3]) then b = true; break; end
	end
	return b;
end

//returns the string text describing the output at num
function ENT:GetOutputText(num)
	local str = self:GetOutput(num)[4];
	if (str != nil) then
		return tostring(str);	
	end
	return nil;
end


//these functions are used when connecting gates together

function ENT:SetOPOn(op, num)
	self:GetOutput(op)[1] = num;
end

function ENT:AddOPEnt(op, ent, ip, wireless)
	if (ent.CheckEmGate) then

		local tbl = self:GetOutputEnts(op);
		table.insert(tbl, {ent:EntIndex(), ip, wireless});

	else

		if (CHECKEM.IsWireable(ent) && SERVER) then
			CHECKEM.AddSENTInput(ent, ip, self, op);
		end
		local tbl = self:GetOutputSENTs(op);
		table.insert(tbl, {ent:EntIndex(), ip, wireless});

	end

	if (SERVER) then
		net.Start("CHKMOPADD")
			net.WriteLong(self:EntIndex());
			net.WriteLong(op);
			net.WriteLong(ent:EntIndex());
			net.WriteLong(ip);
			net.WriteLong((wireless && 1) || 0);
		net.Broadcast()
	end

	local num = (self:GetOutputOn(op) && 1) || 0;
	self:UpdateInputsOfOP(op, num);
end

function ENT:SetOPInput(op, ip)
	self:GetOutput(op)[2][2] = ip;
end


//this function updates the on/off state of all the inputs
//connected to output #op
function ENT:UpdateInputsOfOP(op, num)

	for k, v in pairs(self:GetOutputEnts(op)) do
		local e = Entity(v[1]);
		if (IsValid(e)) then e:ChangeIPState(v[2], num, true); end
	end

	for k, v in pairs(self:GetOutputSENTs(op)) do
		local ent = Entity(v[1]);
		if (IsValid(ent)) then
			local e, op, on = CHECKEM.GetSENTInput(ent, v[2]);
			if (on != num) then
				CHECKEM.UpdateIPState(ent, v[2], num, true);
			end
		end
	end

	//TODO: clean up any SENTs that have been removed
	for k, v in pairs(self:GetOutputSENTs(op)) do
		local ent = Entity(v[1]);
		if (!IsValid(ent)) then
			


		end
	end

end

//use this function to update the on or off state of an output
//set bnet to true if you're running this on the server only
function ENT:ChangeOPState(op, b, bnet)
	local num = (b == true && 1) || 0;
	self:SetOPOn(op, num);
	self:UpdateInputsOfOP(op, num);

	if (bnet) then
		local str = "CHKMOPST";
		net.Start(str)
			net.WriteLong(self:EntIndex());
			net.WriteLong(op);
			net.WriteLong(num);
		net.Broadcast()
	end
end

function ENT:SendOPSignal(e, ip, b, bnet)
	e:ChangeIPState(ip, b, bnet);
end



if (SERVER) then


//use this function when connecting gates
function ENT:AddOutput(op, ent, ip, wireless)
	if (!IsValid(ent)) then
		return;
	end
	self:AddOPEnt(op, ent, ip, wireless);
end

function ENT:ClearOutputEnt(op, ent, ip)
	self:RemoveOPEnt(op, ent, ip);
	local str = "CHKMCLROPENT";
	net.Start(str)
		net.WriteLong(self:EntIndex());
		net.WriteLong(op);
		net.WriteLong(ent:EntIndex());
		net.WriteLong(ip);
	net.Broadcast();
end

//use this function to change any input text
//it will send the updates to the client
function ENT:ChangeOutputTexts(tbl)
	self.OutputTexts = tbl;
	self:UpdateOutputTexts();
	
	local str = "CHKMOPTXT";
	net.Start(str)
		net.WriteLong(self:EntIndex());
		net.WriteTable(tbl);
	net.Broadcast();
end


function ENT:ChangeNumOutputs(num)
	local max = math.Clamp(num, 0, 10);
	local curnum = self:NumOutputs();
	if (num <= max && num >= 0) then
		self:UpdateNumOutputs(num);
		
		local str = "CHKMNUMOP";
		net.Start(str)
			net.WriteLong(self:EntIndex());
			net.WriteLong(num);
		net.Broadcast()
	
	end
end


else



net.Receive("CHKMCLROP", function(len)
	local ent, op = Entity(net.ReadLong()), net.ReadLong();
	if (!IsValid(ent)) then return; end
	ent:ClearOutput(op);
end);

net.Receive("CHKMOPADD", function(len)
	local ent, op, ent2, ip, wireless = Entity(net.ReadLong()),
		net.ReadLong(), Entity(net.ReadLong()), net.ReadLong(), net.ReadLong();
	ent:AddOPEnt(op, ent2, ip, tobool(wireless));
end);

net.Receive("CHKMCLROPENT", function(len)
	local ent, op, ent2, ip = Entity(net.ReadLong()),
		net.ReadLong(), Entity(net.ReadLong()), net.ReadLong();
	ent:RemoveOPEnt(op, ent2, ip);
end);

net.Receive("CHKMOPTXT", function(len)
	local e = Entity(net.ReadLong());
	if (!IsValid(e)) then return; end
	e.OutputTexts = net.ReadTable();
	e:UpdateOutputTexts();	
end)

net.Receive("CHKMOPST", function(len)
	local e = Entity(net.ReadLong());
	if (!IsValid(e)) then return; end
	local op, num = net.ReadLong(), net.ReadLong();
	e:SetOPOn(op, num);
	e:UpdateInputsOfOP(op, num);
end)

net.Receive("CHKMNUMOP", function(len)
	local e = Entity(net.ReadLong());
	if (!IsValid(e)) then return; end
	local num = net.ReadLong();
	e:UpdateNumOutputs(num);
end)
	



end
