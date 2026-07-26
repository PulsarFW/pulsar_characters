function RegisterCommands()
	plsr.Chat:RegisterStaffCommand("logout", function(source, args, rawCommand)
		plsr.Execute:Client(source, "Characters", "Logout")
	end, {
		help = "Logout",
	}, 0)
	plsr.Chat:RegisterStaffCommand("logoutsid", function(source, args, rawCommand)
		local char = plsr.Fetch:SID(tonumber(args[1]))
		if char ~= nil then
			plsr.Execute:Client(char:GetData("Source"), "Characters", "Logout")
		end
	end, {
		help = "Force logs out another player by State ID",
		params = {
			{
				name = "Target",
				help = "State ID of who you want to force logout",
			},
		},
	}, 1)
	plsr.Chat:RegisterStaffCommand("logoutsource", function(source, args, rawCommand)
		plsr.Execute:Client(tonumber(args[1]), "Characters", "Logout")
	end, {
		help = "Force logs out another player by Source",
		params = {
			{
				name = "Target",
				help = "Source of who you want to force logout",
			},
		},
	}, 1)
	plsr.Chat:RegisterAdminCommand("logoutall", function(source, args, rawCommand)
		for k, v in pairs(plsr.Fetch:All()) do
			plsr.Execute:Client(v:GetData("Source"), "Characters", "Logout")
		end
	end, {
		help = "Force logs out all players",
	}, 0)

	plsr.Chat:RegisterAdminCommand("addrep", function(source, args, rawCommand)
		local char = plsr.Fetch:SID(tonumber(args[1]))
		if char ~= nil then
			plsr.Reputation.Modify:Add(char:GetData("Source"), args[2], tonumber(args[3]))
			plsr.Chat.Send.System:Single(
				source,
				string.format("%s Rep Added For %s To State ID %s", args[3], args[2], args[1])
			)
		else
			plsr.Chat.Send.System:Single(source, "Invalid Target")
		end
	end, {
		help = "Add Specified Reputation To Specified Player",
		params = {
			{
				name = "Target",
				help = "State ID of who you want to give the reputation to",
			},
			{
				name = "ID",
				help = "ID of the reputation you want to give",
			},
			{
				name = "Amount",
				help = "Amount of reputation to give",
			},
		},
	}, 3)

	plsr.Chat:RegisterAdminCommand("remrep", function(source, args, rawCommand)
		local char = plsr.Fetch:SID(tonumber(args[1]))
		if char ~= nil then
			plsr.Reputation.Modify:Remove(char:GetData("Source"), args[2], tonumber(args[3]))
			plsr.Chat.Send.System:Single(
				source,
				string.format("%s Rep Removed For %s From State ID %s", args[3], args[2], args[1])
			)
		else
			plsr.Chat.Send.System:Single(source, "Invalid Target")
		end
	end, {
		help = "Remove Specified Reputation To Specified Player",
		params = {
			{
				name = "Target",
				help = "State ID of who you want to remove the reputation from",
			},
			{
				name = "ID",
				help = "ID of the reputation you want to take",
			},
			{
				name = "Amount",
				help = "Amount of reputation to take",
			},
		},
	}, 3)

	plsr.Chat:RegisterAdminCommand("getrep", function(source, args, rawCommand)
		local char = plsr.Fetch:SID(tonumber(args[1]))
		if char ~= nil then
			local repLevel = plsr.Reputation:GetLevel(char:GetData("Source"), args[2])
			plsr.Chat.Send.System:Single(
				source,
				string.format("%s Rep Level For %s To State ID %s", repLevel, args[2], args[1])
			)
		else
			plsr.Chat.Send.System:Single(source, "Invalid Target")
		end
	end, {
		help = "Get Specified Reputation for Specified Player",
		params = {
			{
				name = "Target",
				help = "State ID of who you want to get the reputation of",
			},
			{
				name = "ID",
				help = "ID of the reputation you want to get",
			},
		},
	}, 2)

	plsr.Chat:RegisterAdminCommand("phoneperm", function(source, args, rawCommand)
		local char = plsr.Fetch:SID(tonumber(args[1]))
		local app, perm = args[2], args[3]

		if char ~= nil then
			local phonePermissions = char:GetData("PhonePermissions")
			if phonePermissions[app] then
				if phonePermissions[app][perm] ~= nil then
					if phonePermissions[app][perm] then
						phonePermissions[app][perm] = false
						plsr.Chat.Send.System:Single(source, "Disabled Permission")
					else
						phonePermissions[app][perm] = true
						plsr.Chat.Send.System:Single(source, "Enabled Permission")
					end

					char:SetData("PhonePermissions", phonePermissions)
				else
					plsr.Chat.Send.System:Single(source, "Permission Doesn't Exist")
				end
			else
				plsr.Chat.Send.System:Single(source, "App Doesn't Exist")
			end
		else
			plsr.Chat.Send.System:Single(source, "Invalid Target")
		end
	end, {
		help = "Add Specified App Permission",
		params = {
			{
				name = "Target",
				help = "State ID",
			},
			{
				name = "App ID",
				help = "ID of the app",
			},
			{
				name = "Perm ID",
				help = "Permission",
			},
		},
	}, 3)

	plsr.Chat:RegisterAdminCommand("laptopperm", function(source, args, rawCommand)
		local char = plsr.Fetch:SID(tonumber(args[1]))
		local app, perm = args[2], args[3]

		if char ~= nil then
			local laptopPermissions = char:GetData("LaptopPermissions")
			if laptopPermissions[app] then
				if laptopPermissions[app][perm] ~= nil then
					if laptopPermissions[app][perm] then
						laptopPermissions[app][perm] = false
						plsr.Chat.Send.System:Single(source, "Disabled Permission")
					else
						laptopPermissions[app][perm] = true
						plsr.Chat.Send.System:Single(source, "Enabled Permission")
					end

					char:SetData("LaptopPermissions", laptopPermissions)
				else
					plsr.Chat.Send.System:Single(source, "Permission Doesn't Exist")
				end
			else
				plsr.Chat.Send.System:Single(source, "App Doesn't Exist")
			end
		else
			plsr.Chat.Send.System:Single(source, "Invalid Target")
		end
	end, {
		help = "Add Specified App Permission",
		params = {
			{
				name = "Target",
				help = "State ID",
			},
			{
				name = "App ID",
				help = "ID of the app",
			},
			{
				name = "Perm ID",
				help = "Permission",
			},
		},
	}, 3)
end
