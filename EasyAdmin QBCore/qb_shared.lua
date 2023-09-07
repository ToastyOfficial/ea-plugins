Citizen.CreateThread(function()
	repeat
		Wait(0)
	until permissions
	permissions["qb"] = false
	permissions["qb.money"] = false
	permissions["qb.items"] = false
	permissions["qb.setjob"] = false
	permissions["qb.cuff"] = false
	permissions["qb.revive"] = false
end)