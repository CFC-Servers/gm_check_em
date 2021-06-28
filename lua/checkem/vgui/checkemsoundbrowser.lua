
local PANEL = {};


local function NodeSelected(pnl, node)

	local folder = node:GetFolder();
	local sndList = pnl.SndList;

	sndList:UpdateListWithFolder(folder, node:GetPathID());
	sndList.folder = folder:Right(folder:len() - 6);

end

local function SetupSoundFolder(node, name, path, icon, slist)
	local f = node:AddFolder(name, "sound", path, false);
	f:SetIcon("games/16/" .. icon .. ".png");
	f.BrowseContentType = "sound";
	f.BrowseExtension = "*.wav";
	f.ContentType = "sound";
	f.SndList = slist;

	f.OnNodeSelected = NodeSelected;
end


function PANEL:Init()

	self:SetSize(272, 262);
	self.pitch = 1;

	local browse = vgui.Create("DTree", self);
	browse:SetSize(self:GetWide() - 6, self:GetTall() * .4);

	local slist  = vgui.Create("DListView", self);
	local col = slist:AddColumn("Sounds", 0);
	slist:SetPos(0, browse:GetTall() + 4);
	slist:SetSize(browse:GetWide(), self:GetTall() * .5);
	col:SetSize(browse:GetWide(), col:GetTall());

	slist.UpdateListWithFolder = function(pnl, folder, id)
		pnl:Clear();

		local limit = 1200;
		local sounds = file.Find(folder .. "/*.wav", id);
		for k, v in pairs(sounds) do
			if (k < limit) then
				timer.Simple(.001 * k, function()
					local line = pnl:AddLine(v);
					line.text = v;
					line.PaintOver = function(w, h)
						draw.SimpleText(line.text, "DebugFixed", 0.0, 0.0, Color(0, 0, 0, 255), 0, 0);
					end
				end);
			end
		end
		sounds = file.Find(folder .. "/*.mp3", id);
		for k, v in pairs(sounds) do
			if (k < limit) then
				timer.Simple(.001 * k, function()
					local line = pnl:AddLine(v);
					line.text = v;
					line.PaintOver = function(w, h)
						draw.SimpleText(line.text, "DebugFixed", 0.0, 0.0, Color(0, 0, 0, 255), 0, 0);
					end
				end);
			end
		end
		sounds = file.Find(folder .. "/*.ogg", id);
		for k, v in pairs(sounds) do
			if (k < limit) then
				timer.Simple(.001 * k, function()
					local line = pnl:AddLine(v);
					line.text = v;
					line.PaintOver = function(w, h)
						draw.SimpleText(line.text, "DebugFixed", 0.0, 0.0, Color(0, 0, 0, 255), 0, 0);
					end
				end);
			end
		end
	end

	slist.OnRowSelected = function(pnl, id, line)
		local str = pnl.folder .. "/" .. line:GetColumnText(1);
		pnl.txt:SetText(str);
		self:OnValueChanged(str);
	end

	local stext = vgui.Create("DTextEntry", self);
	stext:SetText("Sound Path");
	stext:SetPos(0, (browse:GetTall() + slist:GetTall() + 6));
	stext:SetSize(browse:GetWide() * .85, self:GetTall() * .08);

	stext.OnEnter = function(pnl)
		self:OnValueChanged(pnl:GetText());
	end
	stext.OnTextChanged = function(pnl)
		self:OnValueChanged(pnl:GetText());
	end

	local plyBtn = vgui.Create("DButton", self);
	plyBtn:SetText("Play");
	plyBtn:SetPos(stext:GetWide() + 2, (browse:GetTall() + slist:GetTall() + 6));
	plyBtn:SetSize(self:GetWide() * .15, stext:GetTall());

	plyBtn.DoClick = function(pnl)
		LocalPlayer():EmitSound(stext:GetText(), 100, (50 + (50 * self.pitch)));
	end


	local Games = browse:AddNode("Games");

	SetupSoundFolder(Games, "All", "GAME", "all", slist);
	SetupSoundFolder(Games, "Garry's Mod", "garrysmod", "garrysmod", slist);


	local Content = engine.GetGames();
	for k, v in SortedPairs(Content) do

		if (!v.mounted) then continue; end

		SetupSoundFolder(Games, v.title, v.folder, v.folder, slist);

	end

	self.Browser = browse;
	self.txt = stext;
	slist.txt = stext;
	self.SndList = slist;
	
end


function PANEL:OnValueChanged(val)
	//override
end


function PANEL:PerformLayout()
end


vgui.Register("CheckEmSoundBrowser", PANEL);
