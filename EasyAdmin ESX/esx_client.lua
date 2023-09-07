



Citizen.CreateThread(function()
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Citizen.Wait(500)
		if not ESX then
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		end
	end
end)

local function keyboard(p1,p2,p3,p4,p5,p6,p7,p8)
	if displayKeyboardInput then
		return displayKeyboardInput(p2, "", 64)
	else
		DisplayOnscreenKeyboard(p1, p2, p3, p4, p5, p6, p7, p8)
		
		while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
			Citizen.Wait( 0 )
		end
		result = GetOnscreenKeyboardResult()
		return result
	end
end


local function playerOption(playerId)

	if not ESX then return end
	failures = 0
	local playerInfos
	local playerLicenses
	if isAdmin then
		local thisESXMenu = _menuPool:AddSubMenu(thisPlayer,"~y~[ESX]~s~ Options","",true) 
		thisESXMenu:SetMenuWidthOffset(menuWidth)

		ESX.TriggerServerCallback('esx:getOtherPlayerData', function(player)
			playerInfos = player	
		end, playerId)

		if permissions["esx.license"] then
			ESX.TriggerServerCallback('esx_license:getLicenses', function(licenses)
				playerLicenses = licenses
			end, playerId)

			local attempt=0
			repeat 
				Wait(0)
				attempt=attempt+1
				if attempt>=500 then -- we didnt get our licenses within 500 ticks, abort.
					playerLicenses={}
					attempt = nil
				end
			until playerLicenses
		else
			playerLicenses = {}
		end

		local attempt=0
		local thisFailed=false
		repeat
			Wait(0)
			attempt=attempt+1
			if attempt>=3000 then
				-- make a button with error description instead of immediately showing anotification
				local thisItem = NativeUI.CreateItem("Error!", "ESX didn't provide any Infos for this Player, they might not be loaded in yet, or your ESX is broken. Please check your Server Console.")
				PrintDebugMessage("ESX didn't provide any Infos for Player ID "..playerId..", they might not be loaded in yet, or your ESX is broken. Please check your Server Console.", 1)
				thisESXMenu:AddItem(thisItem)
				thisFailed = true
				failures=failures+1
				if failures == 5 then -- only show notification at >5 errors.
					ShowNotification("ESX Plugin: ~r~Failed to get Player Infos, please contact support @ discord.gg/GugyRU8")
				end
				attempt=nil
				break
			end
		until playerInfos

		if thisFailed then -- if we cant load ESX player, dont attempt to make menu
			thisFailed=nil
			return
		end


		local accountsText = "Accounts:\n"

		
		local haveMoneyAccount = false
		for i, account in pairs(playerInfos.accounts) do
			accountsText=accountsText..""..account.name..":$"..account.money.."\n"
			if account.name == "money" then
				haveMoneyAccount = true
			end
		end

		if not haveMoneyAccount then
			if playerInfos.money then
				table.insert(playerInfos.accounts, {name = "money", money=playerInfos.money})
			end
		end

		if permissions["esx.money"] then
			local thisItem = NativeUI.CreateItem("~y~[ESX]~s~ Add/Remove Account Money",accountsText) -- create our new item
			thisESXMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				AddTextEntry("ESX_ADDACCOUNTMONEY_ACCOUNT", "Enter the Account to add Money to")
				local result = keyboard(1, "ESX_ADDACCOUNTMONEY_ACCOUNT", "", "", "", "", "", 64)

				if result and result ~= "" then
					AddTextEntry("ESX_ADDACCOUNTMONEY", "Enter the Amount of Money to add")
					local result2 = keyboard(1, "ESX_ADDACCOUNTMONEY", "", "", "", "", "", 16)

					if result2 and result2 ~= "" then
						TriggerServerEvent("EasyAdmin:esx:addAccountMoney", playerId, result,tonumber(result2))
					end
				end
			end


			local thisItem = NativeUI.CreateItem("~y~[ESX]~s~ Add/Remove Money",accountsText) -- create our new item
			thisESXMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				AddTextEntry("ESX_ADDACCOUNTMONEY", "Enter Ammount")
				local result = keyboard(1, "ESX_ADDACCOUNTMONEY", "", "", "", "", "", 16)

				if result and result ~= "" and tonumber(result) then
					TriggerServerEvent("EasyAdmin:esx:addMoney", playerId, tonumber(result))
				end
			end
		end


		if permissions["esx.items"] then
			local thisItem = NativeUI.CreateItem("~y~[ESX]~s~ Add/Remove Inventory Item","") -- create our new item
			thisESXMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				AddTextEntry("ESX_ADDINVENTORYITEM", "Enter Item Name")
				local result = keyboard(1, "ESX_ADDINVENTORYITEM", "", "", "", "", "", 64)

				if result and result ~= "" then
					local result2 = keyboard(1, "ESX_ADDACCOUNTMONEY", "", "", "", "", "", 64)


					if result2 and result2 ~= "" and tonumber(result2) then
						TriggerServerEvent("EasyAdmin:esx:addInventoryItem", playerId, result, tonumber(result2))
					end
				end
			end
		end


		if permissions["esx.setjob"] then
			local thisItem = NativeUI.CreateItem("~y~[ESX]~s~ Set Job","Current Job:\nname: "..playerInfos.job.name.."\ngrade: "..playerInfos.job.grade) -- create our new item
			thisESXMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				AddTextEntry("ESX_SETJOB", "Enter Job")
				local result = keyboard(1, "ESX_SETJOB", "", "", "", "", "", 64)

		
				if result and result ~= "" then
					AddTextEntry("ESX_SETJOBRANK", "Enter Grade")
					local result2 = keyboard(1, "ESX_SETJOBRANK", "", "", "", "", "", 64)
		

					if result2 and result2 ~= "" then
						TriggerServerEvent("EasyAdmin:esx:SetJob", playerId, result, result2)
					end
				end
			end
		end

		
		if permissions["esx.license"] then
			local licenses = "Licenses:\n"
	
			for i, license in pairs(playerLicenses) do
				licenses=licenses..""..license.label.." ("..license.type..")\n"
			end
			local thisItem = NativeUI.CreateItem("~y~[ESX]~s~ Add/Remove License",licenses) -- create our new item
			thisESXMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				AddTextEntry("ESX_ADDLICENSE", "Enter License Type")
				local result = keyboard(1, "ESX_ADDLICENSE", "", "", "", "", "", 64)

				if result and result ~= "" then
					TriggerServerEvent("EasyAdmin:esx:toggleLicense", playerId, result)
				end
			end
		end

		if permissions["esx.revive"] then
			local thisItem = NativeUI.CreateItem("~y~[ESX]~s~ Revive Player","") -- create our new item
			thisESXMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				TriggerServerEvent("EasyAdmin:esx:RevivePlayer", playerId)
			end
		end

		if permissions["esx.cuff"] then
			local thisItem = NativeUI.CreateItem("~y~[ESX]~s~ Handcuff Player","") -- create our new item
			thisESXMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				TriggerServerEvent("EasyAdmin:esx:HandcuffPlayer", playerId)
			end
		end




		if permissions["esx.resetskin"] then
			local thisItem = NativeUI.CreateItem("~y~[ESX]~s~ ~r~Reset Skin~s~","") -- create our new item
			thisESXMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				TriggerServerEvent("EasyAdmin:esx:ResetSkin", playerId)
			end
		end

		if not _menuPool then return end
		
		local thisPlayerDataMenu = _menuPool:AddSubMenu(thisESXMenu,"~y~[ESX]~s~ View Player Data","",true) -- Submenus work, too!
		thisPlayerDataMenu:SetMenuWidthOffset(menuWidth)

		local thisItem = NativeUI.CreateItem("Identifier", playerInfos.identifier) 
		thisPlayerDataMenu:AddItem(thisItem)

		local thisItem = NativeUI.CreateItem("~r~--ACCOUNTS--~s~", "") 
		thisPlayerDataMenu:AddItem(thisItem)

		for i, item in pairs(playerInfos.accounts) do
			local thisItem = NativeUI.CreateItem(item.name, "")
			thisItem:RightLabel(item.money)
			thisPlayerDataMenu:AddItem(thisItem)
			thisItem.Activated = function(ParentMenu,SelectedItem)
				if not permissions["esx.money"] then return end
				AddTextEntry("ESX_SETACCOUNTMONEY", "Enter the Amount of Money to set.")
				local result = keyboard(1, "ESX_SETACCOUNTMONEY", "", "", "", "", "", 16)
	

				if result and result ~= "" and tonumber(result) then
					TriggerServerEvent("EasyAdmin:esx:setAccountMoney", playerId, item.name,tonumber(result))
					thisItem:RightLabel(result)
				end
			end
		end


		if #playerInfos.loadout > 0 then
			local thisItem = NativeUI.CreateItem("~r~--LOADOUT--~s~", "") 
			thisPlayerDataMenu:AddItem(thisItem)

			for i, item in pairs(playerInfos.loadout) do
				local thisItem = NativeUI.CreateItem(item.name, "")
				thisItem:RightLabel(item.ammo)
				thisPlayerDataMenu:AddItem(thisItem)
			end
		end
		
		if playerLicenses and #playerLicenses > 0 then
			local thisItem = NativeUI.CreateItem("~r~--LICENSES--~s~", "") 
			thisPlayerDataMenu:AddItem(thisItem)

			for i,license in pairs(playerLicenses) do
				local thisItem = NativeUI.CreateItem(license.label, "")
				thisPlayerDataMenu:AddItem(thisItem)
			end
		end

		local thisItem = NativeUI.CreateItem("~r~--INVENTORY ITEMS--~s~", "") 
		thisPlayerDataMenu:AddItem(thisItem)
		

		for i, item in pairs(playerInfos.inventory) do
			if (ea_esx_hidenoitems == true and item.count ~= 0) or (ea_esx_hidenoitems == false) then
				local thisItem = NativeUI.CreateItem(item.name, "")
				thisItem:RightLabel(item.count)
				thisPlayerDataMenu:AddItem(thisItem)
				thisItem.Activated = function(ParentMenu,SelectedItem)
					if not permissions["esx.items"] then return end
					AddTextEntry("ESX_SETITEMAMOUNT", "Enter the Amount of Items to set.")
					local result = keyboard(1, "ESX_SETITEMAMOUNT", "", "", "", "", "", 16)
		

					if result and result ~= "" and tonumber(result) then
						TriggerServerEvent("EasyAdmin:esx:setInventoryItem", playerId, item.name,tonumber(result))
						thisItem:RightLabel(result)
					end
				end
			end
		end
		_menuPool:ControlDisablingEnabled(false)
		_menuPool:MouseControlsEnabled(false)
	end
end

local function settingsMenuOptions() -- Options for the Settings Page, once again, passes nothing

	local thisItem = NativeUI.CreateListItem("~y~[ESX]~s~ Hide missing Items", {"true", "false"}, 1, "Hides Items which player has 0 of.")
	settingsMenu:AddItem(thisItem)
	settingsMenu.OnListChange = function(sender, item, index)
			if item == thisItem then
					local i = item:IndexToItem(index)
					if i == "true" then
						ea_esx_hidenoitems = true
					else
						ea_esx_hidenoitems = false
					end
					SetResourceKvp("ea_esx_hidenoitems", i)
			end
	end

end

if not GetResourceKvpString("ea_esx_hidenoitems") then
	SetResourceKvp("ea_esx_hidenoitems", "true")
	ea_esx_hidenoitems = true
else
	ea_esx_hidenoitems = GetResourceKvpString("ea_esx_hidenoitems")
	if ea_esx_hidenoitems == "true" then
		ea_esx_hidenoitems=true
	else
		ea_esx_hidenoitems=false
	end
end 

local function keyboard(p1,p2,p3,p4,p5,p6,p7,p8)
	if displayKeyboardInput then
		return displayKeyboardInput(p2, "", 64)
	else
		DisplayOnscreenKeyboard(p1, p2, p3, p4, p5, p6, p7, p8)
		
		while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
			Citizen.Wait( 0 )
		end
		result = GetOnscreenKeyboardResult()
		return result
	end
end

local pluginData = {
    name = "ESX Plugin",
    functions = {
        playerMenu = playerOption,
        settingsMenu = settingsMenuOptions,
    }
}


addPlugin(pluginData)