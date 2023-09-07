QBCore = nil


Citizen.CreateThread(function()
	repeat
		if GetResourceState('qb-core') == "started" then
			QBCore = exports['qb-core']:GetCoreObject()
			if not QBCore then
				Citizen.Wait(10000)
			end
		else
			Wait(1000)
		end
	until QBCore


	QBCore.Functions.CreateCallback('EasyAdmin:qb:getPlayerInfos', function(source, cb, playerId)
		local src = source
		local Player = QBCore.Functions.GetPlayer(playerId)
		if Player then
			cb(Player.PlayerData) -- this will time out anyway if we cant fetch the player
		end
	end)
end)



RegisterServerEvent("EasyAdmin:qb:addAccountMoney", function(playerId, account,accountMoney)
	if DoesPlayerHavePermission(source,"easyadmin.qb.money") and QBCore then
		SendWebhookMessage(moderationNotification, getName(source).." gave "..getName(playerId).." $"..accountMoney.." "..account.." Money.", "qb")

		local xPlayer = QBCore.Functions.GetPlayer(playerId)
		if accountMoney < 0 then
			xPlayer.Functions.RemoveMoney(account, accountMoney)
		else
			xPlayer.Functions.AddMoney(account, accountMoney)
		end
	end
end)

RegisterServerEvent("EasyAdmin:qb:setAccountMoney", function(playerId, account,accountMoney)
	if DoesPlayerHavePermission(source,"easyadmin.qb.money") and QBCore then
		SendWebhookMessage(moderationNotification, getName(source).." gave "..getName(playerId).." $"..accountMoney.." "..account.." Money.", "qb")

		local xPlayer = QBCore.Functions.GetPlayer(playerId)
		xPlayer.Functions.SetMoney(account, accountMoney)
	end
end)

RegisterServerEvent("EasyAdmin:qb:addInventoryItem", function(playerId, item, count)
	if DoesPlayerHavePermission(source,"easyadmin.qb.items") and QBCore then
		SendWebhookMessage(moderationNotification, getName(source).." gave "..getName(playerId).." "..count.." "..item..".", "qb")

		local xPlayer = QBCore.Functions.GetPlayer(playerId)
		if count < 0 then
			xPlayer.Functions.RemoveItem(item,-count)
		else
			xPlayer.Functions.AddItem(item, count)
		end
	end
end)

RegisterServerEvent("EasyAdmin:qb:SetJob", function(playerId, job, grade)
	if DoesPlayerHavePermission(source,"easyadmin.qb.setjob") and QBCore then
		local xPlayer = QBCore.Functions.GetPlayer(playerId)
		SendWebhookMessage(moderationNotification, getName(source).." set job of "..getName(playerId).." to "..job..".", "qb")

		xPlayer.Functions.SetJob(job,tonumber(grade))
	end
end)


RegisterServerEvent("EasyAdmin:qb:HandcuffPlayer", function(playerId)
	if DoesPlayerHavePermission(source,"easyadmin.qb.cuff") and QBCore then
		TriggerClientEvent("police:client:GetCuffed", playerId, source)
		SendWebhookMessage(moderationNotification, getName(source).." hancuffed "..getName(playerId)..".", "qb")
	end
end)

RegisterServerEvent("EasyAdmin:qb:RevivePlayer", function(playerId)
	if DoesPlayerHavePermission(source,"easyadmin.qb.revive") and QBCore then
		TriggerClientEvent('hospital:client:Revive', playerId)
		TriggerClientEvent("hospital:client:HealInjuries", playerId, "full")
		SendWebhookMessage(moderationNotification, getName(source).." revived "..getName(playerId)..".", "qb")
	end
end)


