ESX = nil
globalLicenses = {}


Citizen.CreateThread(function()
	function setESXObj(obj)
		ESX = obj
	end
	function setLicenses(licenses)
		globalLicenses = licenses
		collectgarbage()
	end

	repeat
		ESX = exports["es_extended"]:getSharedObject()
		Citizen.Wait(10000)
		if not ESX then
			TriggerEvent('esx:getSharedObject', setESXObj)
		else
			TriggerEvent("esx_license:getLicensesList", setLicenses)
		end
	until ESX
end)



RegisterServerEvent("EasyAdmin:esx:addAccountMoney")
AddEventHandler("EasyAdmin:esx:addAccountMoney", function(playerId, account,accountMoney)
	if DoesPlayerHavePermission(source,"easyadmin.esx.money") and ESX then
		SendWebhookMessage(moderationNotification, getName(source).." gave "..getName(playerId).." $"..accountMoney.." "..account.." Money.", "esx")

		local xPlayer = ESX.GetPlayerFromId(playerId)
		if accountMoney < 0 then
			xPlayer.removeAccountMoney(account, -accountMoney)
		else
			xPlayer.addAccountMoney(account, accountMoney)
		end
	end
end)

RegisterServerEvent("EasyAdmin:esx:setAccountMoney")
AddEventHandler("EasyAdmin:esx:setAccountMoney", function(playerId, account,accountMoney)
	if DoesPlayerHavePermission(source,"easyadmin.esx.money") and ESX then
		SendWebhookMessage(moderationNotification, getName(source).." gave "..getName(playerId).." $"..accountMoney.." "..account.." Money.", "esx")

		local xPlayer = ESX.GetPlayerFromId(playerId)
		xPlayer.setAccountMoney(account, accountMoney)
	end
end)

RegisterServerEvent("EasyAdmin:esx:addMoney")

AddEventHandler("EasyAdmin:esx:addMoney", function(playerId, money)
	if DoesPlayerHavePermission(source,"easyadmin.esx.money") and ESX then
		SendWebhookMessage(moderationNotification, getName(source).." gave "..getName(playerId).." $"..money..".", "esx")

		local xPlayer = ESX.GetPlayerFromId(playerId)
		if money < 0 then
			xPlayer.removeMoney(-money)
		else
			xPlayer.addMoney(money)
		end
	end
end)

RegisterServerEvent("EasyAdmin:esx:addInventoryItem")
AddEventHandler("EasyAdmin:esx:addInventoryItem", function(playerId, item, count)
	if DoesPlayerHavePermission(source,"easyadmin.esx.items") and ESX then
		SendWebhookMessage(moderationNotification, getName(source).." gave "..getName(playerId).." "..count.." "..item..".", "esx")

		local xPlayer = ESX.GetPlayerFromId(playerId)
		if count < 0 then
			xPlayer.removeInventoryItem(item,-count)
		else
			xPlayer.addInventoryItem(item, count)
		end
	end
end)

RegisterServerEvent("EasyAdmin:esx:setInventoryItem")
AddEventHandler("EasyAdmin:esx:setInventoryItem", function(playerId, item, count)
	if DoesPlayerHavePermission(source,"easyadmin.esx.items") and ESX then
		SendWebhookMessage(moderationNotification, getName(source).." gave "..getName(playerId).." "..count.." "..item..".", "esx")

		local xPlayer = ESX.GetPlayerFromId(playerId)
		xPlayer.setInventoryItem(item, count)
	end
end)


RegisterServerEvent("EasyAdmin:esx:SetJob")
AddEventHandler("EasyAdmin:esx:SetJob", function(playerId, job, grade)
	if DoesPlayerHavePermission(source,"easyadmin.esx.setjob") and ESX then
		local xPlayer = ESX.GetPlayerFromId(playerId)
		SendWebhookMessage(moderationNotification, getName(source).." set job of "..getName(playerId).." to "..job..".", "esx")

		xPlayer.setJob(job,tonumber(grade))
	end
end)

RegisterServerEvent("EasyAdmin:esx:ResetSkin")
AddEventHandler("EasyAdmin:esx:ResetSkin", function(playerId)
	if DoesPlayerHavePermission(source,"easyadmin.esx.resetskin") and ESX then
		TriggerClientEvent('esx_skin:openSaveableMenu', playerId)
		SendWebhookMessage(moderationNotification, getName(source).." reset skin of "..getName(playerId)..".", "esx")
		TriggerClientEvent("EasyAdmin:showNotification", source, getName(playerId).."'s skin menu has been opened.")
	end
end)

RegisterServerEvent("EasyAdmin:esx:toggleLicense")
AddEventHandler("EasyAdmin:esx:toggleLicense", function(playerId, license)
	local playerId = playerId
	local license = license
	local source = source
	if DoesPlayerHavePermission(source,"easyadmin.esx.license") and ESX then
		local found = false
		for i, l in pairs(globalLicenses) do
			if l.type == license then
				found = true
				TriggerEvent("esx_license:checkLicense", playerId, license, function(hasLicense)
					if hasLicense then
						TriggerEvent("esx_license:removeLicense", playerId, license)
						SendWebhookMessage(moderationNotification, getName(source).." removed license **"..license.."** from "..getName(playerId)..".", "esx")
						TriggerClientEvent("EasyAdmin:showNotification", source, getName(playerId).."'s "..license.." has been removed ")
					else
						TriggerEvent("esx_license:addLicense", playerId, license)
						SendWebhookMessage(moderationNotification, getName(source).." added license **"..license.."** to "..getName(playerId)..".", "esx")
						TriggerClientEvent("EasyAdmin:showNotification", source, getName(playerId).." has been added the license "..license)
					end
				end)
			end
		end
		Wait(3000)
		if not found then
			TriggerClientEvent("EasyAdmin:showNotification", source, "This License does not exist.")
		end
	end
end)


RegisterServerEvent("EasyAdmin:esx:HandcuffPlayer")
AddEventHandler("EasyAdmin:esx:HandcuffPlayer", function(playerId)
	if DoesPlayerHavePermission(source,"easyadmin.esx.cuff") and ESX then
		TriggerClientEvent("esx_policejob:handcuff", playerId)
		SendWebhookMessage(moderationNotification, getName(source).." hancuffed "..getName(playerId)..".", "esx")
	end
end)

RegisterServerEvent("EasyAdmin:esx:RevivePlayer")
AddEventHandler("EasyAdmin:esx:RevivePlayer", function(playerId)
	if DoesPlayerHavePermission(source,"easyadmin.esx.revive") and ESX then
		TriggerClientEvent("esx_ambulancejob:revive", playerId)
		SendWebhookMessage(moderationNotification, getName(source).." revived "..getName(playerId)..".", "esx")
	end
end)