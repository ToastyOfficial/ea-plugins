Citizen.CreateThread(function()
	repeat
		Wait(0)
	until permissions
	permissions["esx"] = false
	permissions["esx.money"] = false
	permissions["esx.items"] = false
	permissions["esx.license"] = false
	permissions["esx.setjob"] = false
	permissions["esx.resetskin"] = false
	permissions["esx.cuff"] = false
	permissions["esx.revive"] = false
end)