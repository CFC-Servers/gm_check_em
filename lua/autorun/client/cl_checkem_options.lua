hook.Add("PopulateToolMenu", "Checkem_AddOptions", function()

	spawnmenu.AddToolMenuOption("Options", "Check 'Em", "Visibility", "Visibility", "", "",
		function(pnl)

			pnl:AddControl("Label", {Text = "These settings change what Check 'Em elements you can see when not holding a tool gun"});
		
			pnl:AddControl("CheckBox", {
				Label = "Draw Wires",
				Description = "Changes the visibility of wires",
				Command = "checkem_drawwires"
			});
			pnl:AddControl("CheckBox", {
				Label = "Draw Fancy Wires",
				Description = "When enabled, wires will curve and bend smoothly between nodes",
				Command = "checkem_highwires"
			});
			
			pnl:AddControl("CheckBox", {
				Label = "Draw Gates",
				Description = "Changes the visibility of Check 'Em gates",
				Command = "checkem_drawgates"
			});

			pnl:AddControl("CheckBox", {
				Label = "Draw Blips",
				Description = "Changes the visibility of Check 'Em diode blips",
				Command = "checkem_drawblips"
			});

			pnl:AddControl("CheckBox", {
				Label = "Draw Sparks",
				Description = "Changes the visibility of Check 'Em spark when connecting",
				Command = "checkem_dospark"
			});

			pnl:AddControl("CheckBox", {
				Label = "Draw Lasers",
				Description = "Changes the visibility of the Check 'Em laser sensor's laser",
				Command = "checkem_drawlasers"
			});
			
			pnl:AddControl("CheckBox", {
				Label = "Draw Sensor Radius Spheres",
				Description = "Changes the visibility of radius spheres from sensors",
				Command = "checkem_drawradspheres"
			});
				
		end, nil);
	
	spawnmenu.AddToolMenuOption("Options", "Check 'Em", "Usability", "Usability", "", "",
		function(pnl)
		
			pnl:AddControl("CheckBox", {
				Label = "Disable your sensors triggering",
				Description = "Toggles whether sensors you've created can be triggered",
				Command = "checkem_disabletriggersensors"
			});

			pnl:AddControl("CheckBox", {
				Label = "Connection protection (your tools only)",
				Description = "Toggles whether other players are able to connect/disconnect your gates",
				Command = "checkem_disableotherstools"
			});
				
		end, nil);
	
end);
