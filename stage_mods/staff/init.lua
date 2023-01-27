local organisateurs = {}
local joueurs = {}
local team = {}
vanished = {}
local mute = false
local fly = false
local build = false
minetest.register_privilege("organisateur", {
    description = "Organisateur du stage",
    give_to_singleplayer = true,
    give_to_admin = true
})
minetest.unregister_chatcommand("killme")
minetest.unregister_chatcommand("me")
minetest.register_on_joinplayer(function(player)
	local has, missing = minetest.check_player_privs(player:get_player_name(), {
        organisateur = true})

        if has then
            local name = player:get_player_name()
	    player:set_nametag_attributes({
		text = name.."\n=Organisateur=",
		color = "#FF0000",
	    })
	    table.insert(organisateurs, player:get_player_name())
        else
		local pl_team = player:get_attribute("team")
		if pl_team then
			local name = player:get_player_name()
	    		player:set_nametag_attributes({
				text = name.."\n-Equipe "..pl_team.."-",
				color = "#00FFFF",
	    		})
		end
        	table.insert(joueurs, player:get_player_name())
		--[[local privs = minetest.get_player_privs(player:get_player_name())
  		privs.fly = nil
		privs.fast = nil
  		minetest.set_player_privs(player:get_player_name(), privs)]]--
        end
end)
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    local has, missing = minetest.check_player_privs(hitter:get_player_name(), {
        organisateur = true})

    if has then
        return false
    else
	minetest.chat_send_player(hitter:get_player_name(), "[STAGE] Impossible de frapper ce joueur, il vous manque le privilège : " .. dump(missing))
        for _, toname in pairs(organisateurs) do
		minetest.chat_send_player(toname, minetest.colorize("#ff0000","[AdministrationStage] " .. hitter:get_player_name() .. " a essayé de frapper " .. player:get_player_name() .. " mais le serveur lui en a interdit."))
	end
        return true
    end
end)
local function display_message_formspec(player)
    local formspec = "size[6,2]" ..
                    "label[0,0;*** Cette séance est terminée ! \nSi vous voulez jouer, venez sur mon serveur nommé francium ***]" ..
                    "button_exit[2,1;2,1;ok;OK]"
    for _, toname in pairs(joueurs) do
		minetest.show_formspec(toname, "staff:finish_message", formspec)
    end
    
end

minetest.register_chatcommand("finish", {
    params = "<message>",
    description = "Affiche un message en gros",
    func = function(player_name, message)
        local player = minetest.get_player_by_name(player_name)
        if not player then
            return false, "Joueur introuvable"
        end
        display_message_formspec(player)
    end
})

minetest.register_chatcommand("mute", {
    privs = {
        organisateur = true,
    },
    func = function(name, param)
	if param == "on" then
		mute = true
		for _, toname in pairs(joueurs) do
		minetest.chat_send_player(toname, minetest.colorize("#FF0000", "[Stage] Vous ne pouvez désormais plus parler dans le tchat."))
		end
		return true, "[Stage] Le tchat est maintenant mute."
	elseif param == "off" then
		mute = false
		for _, toname in pairs(joueurs) do
		minetest.chat_send_player(toname, minetest.colorize("#FF0000", "[Stage] Vous pouvez de nouveau parler dans le tchat."))
		end
		return true, "[Stage] Le tchat n'est plus mute."
	else
		return true, "[Stage] Vous devez utiliser la commande en faisant /mute on ou /mute off"
	end
        return true, ""
    end,
})
minetest.register_chatcommand("setteam", {
    privs = {
        organisateur = true,
    },
    func = function(name, param)
	local player, color = string.match(param, "^(%S+)%s(%S+)$")
	if player and color then
		minetest.chat_send_player(player, minetest.colorize("#FF0000", "[Stage] Vous êtes maintenant dans l'équipe " .. color .. "."))
		local pl = minetest.get_player_by_name(player)
		pl:set_nametag_attributes({
			text = player.."\n-Equipe "..color.."-",
			color = "#00FFFF",
	    	})
		pl:set_attribute("team", color)
	else
		if param then
			minetest.chat_send_player(param, minetest.colorize("#FF0000", "[Stage] Vous n'êtes plus dans une équipe."))
			local pl = minetest.get_player_by_name(param)
			pl:set_nametag_attributes({
				text = player,
				color = "#FFFFFF",
	    		})
			pl:set_attribute("team", nil)
		else
			minetest.chat_send_player(name, "[Stage] Erreur : vous devez fournir un ou deux arguments")
		end
	end
    end,
})
minetest.register_chatcommand("getteam", {
    privs = {
        organisateur = true,
    },
    func = function(name, param)
	if param then
		local pl = minetest.get_player_by_name(param)
		local pl_team = pl:get_attribute("team")
		if pl_team then
			minetest.chat_send_player(name, "[Stage] Le joueur " .. param .. " est dans l'équipe " .. pl_team .. ".")
		else
			minetest.chat_send_player(name, "[Stage] Le joueur " .. param .. " est dans aucune équipe.")
		end
	else
		minetest.chat_send_player(name, "[Stage] Erreur : vous devez fournir un arguments")
	end
    end,
})
minetest.register_chatcommand("fly", {
    privs = {
        organisateur = true,
    },
    func = function(name, param)
	if param == "on" then
		fly = true
		for _, toname in pairs(joueurs) do
		minetest.chat_send_player(toname, minetest.colorize("#FF0000", "[Stage] Vous avez maintenant le privilège de voler dans les airs, pour l'activer appuyez sur le touche K."))
		local privs = minetest.get_player_privs(toname)
  		privs.fly = true
		privs.fast = true
  		minetest.set_player_privs(toname, privs)
		end
		return true, "[Stage] Les joueurs peuvent maintenant voler dans les airs"
	elseif param == "off" then
		fly = false
		for _, toname in pairs(joueurs) do
		minetest.chat_send_player(toname, minetest.colorize("#FF0000", "[Stage] Vous ne pouvez plus voler dans les airs."))
		local privs = minetest.get_player_privs(toname)
  		privs.fly = nil
		privs.fast = nil
  		minetest.set_player_privs(toname, privs)
		end
		return true, "[Stage] Les joueurs ne peuvent plus voler dans les airs."
	else
		return true, "[Stage] Vous devez utiliser la commande en faisant /fly on ou /fly off"
	end
        return true, ""
    end,
})
minetest.register_chatcommand("build", {
    privs = {
        organisateur = true,
    },
    func = function(name, param)
	if param == "on" then
		build = true
		for _, toname in pairs(joueurs) do
		minetest.chat_send_player(toname, minetest.colorize("#FF0000", "[Stage] Vous avez maintenant la permission de construire et de casser des blocks."))
		local privs = minetest.get_player_privs(toname)
		privs.creative = true
  		minetest.set_player_privs(toname, privs)
		end
		return true, "[Stage] Les joueurs peuvent maintenant construire et casser des blocks."
	elseif param == "off" then
		build = false
		for _, toname in pairs(joueurs) do
		minetest.chat_send_player(toname, minetest.colorize("#FF0000", "[Stage] Vous n'avez plus la permission de construire et de casser des blocks."))
		local privs = minetest.get_player_privs(toname)
		privs.creative = nil
  		minetest.set_player_privs(toname, privs)
		end
		return true, "[Stage] Les joueurs ne peuvent plus poser et casser des blocks."
	else
		return true, "[Stage] Vous devez utiliser la commande en faisant /build on ou /build off"
	end
        return true, ""
    end,
})
minetest.register_on_chat_message(function(name, message)
    if minetest.check_player_privs(name, { organisateur = true }) then
        minetest.chat_send_all(minetest.colorize("#FF0000", "[Organisateur] <" .. name .. "> " .. message))
	return true
    else
        if mute==true then
		minetest.chat_send_player(name, minetest.colorize("#FF0000", "[Stage] Vous ne pouvez pas parler dans le tchat."))
		return true
    	end
    end

    return false
end)

minetest.register_on_leaveplayer(function(player)
	local has, missing = minetest.check_player_privs(player:get_player_name(), {
        organisateur = true})
	local name = player:get_player_name()
        if has then
	    	local name = player:get_player_name()
	    	local idx = table.indexof(organisateurs, name)
	    	if idx ~= -1 then
			table.remove(organisateurs, idx)
	    	end
        else
        	local name = player:get_player_name()
		local idx = table.indexof(joueurs, name)
		if idx ~= -1 then
			table.remove(joueurs, idx)
		end
        end
	local name = player:get_player_name()

	if vanished[name] then
		vanished[name] = nil
	end
end)

local old_node_dig = minetest.node_dig
function minetest.node_dig(pos, node, digger)
	local has, missing = minetest.check_player_privs(digger:get_player_name(), {
        organisateur = true})

        if has then
            return old_node_dig(pos, node, digger)
	end
	if build == true then
		return old_node_dig(pos, node, digger)
	else
		return true
	end
end

local old_node_place = minetest.item_place
function minetest.item_place(itemstack, placer, pointed_thing)
	local has, missing = minetest.check_player_privs(placer:get_player_name(), {
        organisateur = true})

        if has then
            return old_node_place(itemstack, placer, pointed_thing)
	end
	--if itemstack:get_definition().type == "node" then
		if build == true then
			return old_node_place(itemstack, placer, pointed_thing)
		else
			return
		end
	--end
end

-- Vanish command
vanish = function(player, toggle)

	if not player then return false end

	local name = player:get_player_name()

	vanished[name] = toggle

	local prop

	if toggle == true then

		-- hide player and name tag
		prop = {
			visual_size = {x = 0, y = 0},
		}

		player:set_nametag_attributes({
			color = {a = 0, r = 255, g = 255, b = 255}
		})
	else
		-- show player and tag
		prop = {
			visual_size = {x = 1, y = 1},
		}

		player:set_nametag_attributes({
		text = name.."\n=Organisateur=",
		color = "#FF0000",
	    })
	end

	player:set_properties(prop)

end


minetest.register_chatcommand("vanish", {
	params = "<name>",
	description = "Make player invisible",
	privs = {organisateur = true},

	func = function(name, param)

		local player = minetest.get_player_by_name(name)

		if vanished[name] then

			vanish(player, nil)
		else
			vanish(player, true)
		end

	end
})
minetest.register_chatcommand("rtp", {
    params = "",
    description = "",
    privs = {organisateur=true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return
        end
        local pos = player:getpos()
	local tppos = {}
        tppos.x = math.random(1, 30000)
        tppos.y = math.random(1, 10)
        tppos.z = math.random(1, 30000)
        player:setpos(tppos)
    end,
})
minetest.register_chatcommand("pbuild", {
    params = "",
    description = "",
    privs = {organisateur=true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return
        end
        local pos = player:getpos()
        for i = -22, 22 do
            for j = -22, 22 do
                for k = -22, 22 do
                    minetest.remove_node({x=pos.x+i, y=pos.y+j, z=pos.z+k})
                end
            end
        end
	minetest.set_node(pos, {name="protector:protect"})
    end,
})
