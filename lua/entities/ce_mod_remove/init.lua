
AddCSLuaFile('shared.lua');
AddCSLuaFile('cl_init.lua');


include('shared.lua')


local function RemoveEntity( ent )
 
        if (ent:IsValid()) then
        	ent:Remove()
        end
 
end

local function DoRemoveEntity( Entity, b )
 
        if (!Entity) then return false end
        if (!Entity:IsValid()) then return false end
        if (Entity:IsPlayer()) then return false end
 
        // Nothing for the client to do here
        if ( CLIENT ) then return true end
 
        // Remove all constraints (this stops ropes from hanging around)
        constraint.RemoveAll( Entity )
       
        // Remove it properly in 1 second
        timer.Simple( 1, function()
            RemoveEntity( Entity );
        end )
       
        // Make it non solid
        Entity:SetNotSolid( true )
        Entity:SetMoveType( MOVETYPE_NONE )
        Entity:SetNoDraw( true )
       
	   if (b) then
        // Send Effect
        local ed = EffectData()
                ed:SetEntity( Entity )
        util.Effect( "entity_remove", ed, true, true )
       end
	   
        return true
 
end

function ENT:ModifyOn(ent)
	self:EmitSound("buttons/button16.wav", 82, math.random(90, 105));
	self:Remove();
	DoRemoveEntity(ent, true);
end
