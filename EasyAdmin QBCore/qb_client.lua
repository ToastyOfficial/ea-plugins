



Citizen.CreateThread(function()
	while QBCore == nil do
		QBCore = exports['qb-core']:GetCoreObject()
		Citizen.Wait(500)
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

local function playerOptions(playerId)

	if not QBCore then return end
	failures = 0
	local playerInfos
	if isAdmin then
		local thisQBCoreMenu = _menuPool:AddSubMenu(thisPlayer,"~b~[QBCore]~s~ Options","",true) 
		thisQBCoreMenu:SetMenuWidthOffset(menuWidth)

		QBCore.Functions.TriggerCallback('EasyAdmin:qb:getPlayerInfos', function(player)
			playerInfos = player
		end, playerId)

		local attempt=0
		local thisFailed=false
		repeat
			Wait(0)
			attempt=attempt+1
			if attempt>=3000 then
				-- make a button with error description instead of immediately showing anotification
				local thisItem = NativeUI.CreateItem("Error!", "QBCore didn't provide any Infos for this Player, they might not be loaded in yet, or your QBCore is broken. Please check your Server Console.")
				PrintDebugMessage("QBCore didn't provide any Infos for Player ID "..playerId..", they might not be loaded in yet, or your QBCore is broken. Please check your Server Console.", 1)
				thisQBCoreMenu:AddItem(thisItem)
				thisFailed = true
				failures=failures+1
				if failures == 5 then -- only show notification at >5 errors.
					ShowNotification("QBCore Plugin: ~r~Failed to get Player Infos, please contact support @ discord.gg/GugyRU8")
				end
				attempt=nil
				break
			end
		until playerInfos

		if thisFailed then -- if we cant load QBCore player, dont attempt to make menu
			thisFailed=nil
			return
		end


		local accountsText = "Accounts:\n"

		
		local hasMoneyAccount = false
		for account, money in pairs(playerInfos.money) do
			accountsText=accountsText..""..account..":$"..money.."\n"
			if account == "money" then
				hasMoneyAccount = true
			end
		end

		if permissions["qb.money"] then
			local thisItem = NativeUI.CreateItem("~b~[QBCore]~s~ Add/Remove Account Money",accountsText) -- create our new item
			thisQBCoreMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				AddTextEntry("QBCore_ADDACCOUNTMONEY_ACCOUNT", "Enter the Account to add Money to")

				local result = keyboard(1, "QBCore_ADDACCOUNTMONEY_ACCOUNT", "", "", "", "", "", 64)


		
				if result and result ~= "" then
					AddTextEntry("QBCore_ADDACCOUNTMONEY", "Enter the Amount of Money to add")
					local result2 = keyboard(1, "QBCore_ADDACCOUNTMONEY", "", "", "", "", "", 16)

	
			
					if result2 and result2 ~= "" then
						TriggerServerEvent("EasyAdmin:qb:addAccountMoney", playerId, result,tonumber(result2))
					end
				end
			end
		end


		if permissions["qb.items"] then
			local thisItem = NativeUI.CreateItem("~b~[QBCore]~s~ Add/Remove Inventory Item","") -- create our new item
			thisQBCoreMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				AddTextEntry("QBCore_ADDINVENTORYITEM", "Enter Item Name")
				local result = keyboard(1, "QBCore_ADDINVENTORYITEM", "", "", "", "", "", 64)
		
				if result and result ~= "" then
					AddTextEntry("QBCore_ADDACCOUNTMONEY", "Enter the Amount of Items to add")
					local result2 = keyboard(1, "QBCore_ADDACCOUNTMONEY", "", "", "", "", "", 64)
		
					if result2 and result2 ~= "" and tonumber(result2) then
						TriggerServerEvent("EasyAdmin:qb:addInventoryItem", playerId, result, tonumber(result2))
					end
				end
			end
		end


		if permissions["qb.setjob"] then
			local thisItem = NativeUI.CreateItem("~b~[QBCore]~s~ Set Job","Current Job:\nname: "..playerInfos.job.name.."\ngrade: "..playerInfos.job.grade.level) -- create our new item
			thisQBCoreMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				AddTextEntry("QBCore_SETJOB", "Enter Job")
				local result = keyboard(1, "QBCore_SETJOB", "", "", "", "", "", 64)

				if result and result ~= "" then
					AddTextEntry("QBCore_SETJOBRANK", "Enter Grade")
					local result2 = keyboard(1, "QBCore_SETJOBRANK", "", "", "", "", "", 64)

					if result2 and result2 ~= "" then
						TriggerServerEvent("EasyAdmin:qb:SetJob", playerId, result, result2)
					end
				end
			end
		end

	

		if permissions["qb.revive"] then
			local thisItem = NativeUI.CreateItem("~b~[QBCore]~s~ Revive Player","") -- create our new item
			thisQBCoreMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				TriggerServerEvent("EasyAdmin:qb:RevivePlayer", playerId)
			end
		end

		if permissions["qb.cuff"] then
			local thisItem = NativeUI.CreateItem("~b~[QBCore]~s~ Handcuff Player","") -- create our new item
			thisQBCoreMenu:AddItem(thisItem) -- thisPlayer is global.
			thisItem.Activated = function(ParentMenu,SelectedItem)
				TriggerServerEvent("EasyAdmin:qb:HandcuffPlayer", playerId)
			end
		end


		if not _menuPool then return end
		
		local thisPlayerDataMenu = _menuPool:AddSubMenu(thisQBCoreMenu,"~b~[QBCore]~s~ View Player Data","",true) -- Submenus work, too!
		thisPlayerDataMenu:SetMenuWidthOffset(menuWidth)

		local thisItem = NativeUI.CreateItem("Identifier", playerInfos.license) 
		thisPlayerDataMenu:AddItem(thisItem)

		local thisItem = NativeUI.CreateItem("~r~--ACCOUNTS--~s~", "") 
		thisPlayerDataMenu:AddItem(thisItem)

		for account, value in pairs(playerInfos.money) do
			local thisItem = NativeUI.CreateItem(account, "")
			thisItem:RightLabel(value)
			thisPlayerDataMenu:AddItem(thisItem)
			thisItem.Activated = function(ParentMenu,SelectedItem)
				if not permissions["qb.money"] then return end
				AddTextEntry("QBCore_SETACCOUNTMONEY", "Enter the Amount of Money to set.")
				local result = keyboard(1, "QBCore_SETACCOUNTMONEY", "", "", "", "", "", 16)

				if result and result ~= "" and tonumber(result) then
					TriggerServerEvent("EasyAdmin:qb:setAccountMoney", playerId, account,tonumber(result))
					thisItem:RightLabel(result)
				end
			end
		end
	

		local thisItem = NativeUI.CreateItem("~r~--INVENTORY ITEMS--~s~", "") 
		thisPlayerDataMenu:AddItem(thisItem)
		

		for i, item in pairs(playerInfos.items) do
			if (ea_qb_hidenoitems == true and item.count ~= 0) or (ea_qb_hidenoitems == false) then
				local thisItem = NativeUI.CreateItem(item.name, "")
				thisItem:RightLabel(item.amount)
				thisPlayerDataMenu:AddItem(thisItem)
				thisItem.Activated = function(ParentMenu,SelectedItem)
					if not permissions["qb.items"] then return end
					AddTextEntry("QBCore_SETITEMAMOUNT", "Enter the Amount of Items to add/remove.")
					local result = keyboard(1, "QBCore_SETITEMAMOUNT", "", "", "", "", "", 16)

					if result and result ~= "" and tonumber(result) then
						TriggerServerEvent("EasyAdmin:qb:addInventoryItem", playerId, item.name,tonumber(result))
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

	local thisItem = NativeUI.CreateListItem("~b~[QBCore]~s~ Hide missing Items", {"true", "false"}, 1, "Hides Items which player has 0 of.")
	settingsMenu:AddItem(thisItem)
	settingsMenu.OnListChange = function(sender, item, index)
			if item == thisItem then
					local i = item:IndexToItem(index)
					if i == "true" then
						ea_qb_hidenoitems = true
					else
						ea_qb_hidenoitems = false
					end
					SetResourceKvp("ea_qb_hidenoitems", i)
			end
	end
end

if not GetResourceKvpString("ea_qb_hidenoitems") then
	SetResourceKvp("ea_qb_hidenoitems", "true")
	ea_qb_hidenoitems = true
else
	ea_qb_hidenoitems = GetResourceKvpString("ea_qb_hidenoitems")
	if ea_qb_hidenoitems == "true" then
		ea_qb_hidenoitems=true
	else
		ea_qb_hidenoitems=false
	end
end 

local pluginData = { -- enter your plugin infos, and any optional data, here.
    name = "QBCore Plugin", -- your plugin name
    functions = { -- functions which dont exist dont need to be added here.
        playerMenu = playerOptions,
        settingsMenu = settingsMenuOptions,
    }
}


addPlugin(pluginData) -- this function will add the plugin to EasyAdmin