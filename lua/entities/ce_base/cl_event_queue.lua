
//Check 'em relies heavily on clientside effects and prettiness
//This event system takes care of instances where players are editing gate
//systems outside of your PVS, where the entities don't exist yet clientside

//what this does is let you queue up events with a condition tied to an entity index
//when the condition (normally "does this entity exist yet?") is met then it will
//go ahead and perform that event.  if an entity is removed the server notifies clients
//to clear the event queue for that gate, it doesn't need to know about it at that point

CHECKEM.EventQueue = (CHECKEM.EventQueue || {});
CHECKEM.NextQueue = 0;
CHECKEM.QueueDelay = .1;

function CHECKEM.QueueEvent(id, cnd, func, ...)

	if (id == 0) then return; end

	CHECKEM.EventQueue[id] = (CHECKEM.EventQueue[id] || {});

	local tbl = {};
	tbl[1] = cnd;
	tbl[2] = func;
	tbl[3] = {...};

	table.insert(CHECKEM.EventQueue[id], tbl);
end

function CHECKEM.QueueEventtxt(txt, id, cnd, func, ...)

	if (id == 0) then return; end

	CHECKEM.EventQueue[id] = (CHECKEM.EventQueue[id] || {});

	local tbl = {};
	tbl[1] = cnd;
	tbl[2] = func;
	tbl[3] = {...};
	tbl.txt = txt;

	table.insert(CHECKEM.EventQueue[id], tbl);
end


local broke = false;

local function QueueFunction()
	broke = true;
	for id, v in pairs(CHECKEM.EventQueue) do

		local tbl = CHECKEM.EventQueue[id][1];

		local cnd = tbl[1][1];
		local cndarg = tbl[1][2];
		if (cnd(unpack(cndarg))) then
			tbl[2](unpack(tbl[3]));
			table.remove(CHECKEM.EventQueue[id], 1);
			if (table.Count(CHECKEM.EventQueue[id]) <= 0) then CHECKEM.EventQueue[id] = nil; end
		end

	end
	broke = false;
end

timer.Create("CHKM_QueueCheck", 5, 0, function()
	if (broke) then
		broke = false;
		hook.Add("Think", "CHECKEM_EventQueueThink", QueueFunction);
	end
end);

hook.Add("Think", "CHECKEM_EventQueueThink", QueueFunction);

net.Receive("CHKMRMVQ", function(len)
	local id = net.ReadLong();
	timer.Simple(.2, function() CHECKEM.EventQueue[id] = nil; end);
end);
