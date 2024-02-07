local S = minetest.get_translator("shortcut")

function shortcut_funcs.change_desc(player_name,params)
  number, desc = shortcut_funcs.into_two(params)
  if shortcuts[player_name] ~= nil then
    if shortcuts[player_name][tonumber(number)] ~= nil then
      shortcuts[player_name][tonumber(number)].desc = table_to_string(desc)
      shortcut_funcs.save_shortcuts()
      minetest.chat_send_player(player_name, S("Changed description of shortcut @1 to \"@2\".", number, shortcuts[player_name][tonumber(number)].desc))
    else
      minetest.chat_send_player(player_name, S("You have no shortcut number @1!", number))
    end
  else
    minetest.chat_send_player(player_name, S("You have no shortcuts!"))
  end
end

function shortcut_funcs.read_desc(player_name,number)
  if shortcuts[player_name] ~= nil then
    if shortcuts[player_name][tonumber(number)] ~= nil then
      minetest.chat_send_player(player_name, shortcuts[player_name][tonumber(number)].desc)
    else
      minetest.chat_send_player(player_name, S("You have no shortcut number @1!", number))
    end
  else
    minetest.chat_send_player(player_name, S("You have no shortcuts!"))
  end
end

function shortcut_funcs.remove_shortcut(player_name,number)
  if shortcuts[player_name] ~= nil then
    if shortcuts[player_name][tonumber(number)] ~= nil then
      table.remove(shortcuts[player_name],number)
      shortcut_funcs.save_shortcuts()
      minetest.chat_send_player(player_name, S("Removed command at @1.", tostring(number)))
    else
      minetest.chat_send_player(player_name, S("You have no shortcut number @1!", number))
    end
  else
    minetest.chat_send_player(player_name, S("You have no shortcuts!"))
  end
end

function shortcut_funcs.run_shortcut(player_name,prms)
  number, cmd_params = shortcut_funcs.into_two(prms)
  sc = shortcuts[player_name]
  if sc then
    sc = sc[tonumber(number)]
  end
  if sc then
    if #sc.params > 0 then
      sc_params = shortcut_funcs.copy(sc.params)
      if shortcut_funcs.to_change(sc_params) ~= #cmd_params then
         minetest.chat_send_player(player_name, S("You need to set parameters!"))
        return
      end
      j = 1
      for i=1,#sc_params do 
        if sc_params[i] == "@p" then
          local player = minetest.get_player_by_name(cmd_params[j])
          if not player then 
            minetest.chat_send_player(player_name, S("Player @1 is not online!", cmd_params[j]))
            return
          end
          sc_params[i] = cmd_params[j]
          j = j + 1
        elseif sc_params[i] == "*" then
          sc_params[i] = cmd_params[j]
          j = j + 1
        end
      end
      if shortcut_funcs.to_change(sc_params) == 0 then
	success, output = minetest.registered_chatcommands[sc["cmd"]].func(player_name,shortcut_funcs.table_to_string(sc_params))
        if success then
	  if output == nil then
            minetest.chat_send_player(player_name, S("Command was executed successfully!"))
          else
            minetest.chat_send_player(player_name, output)
          end
        else
	  minetest.chat_send_player(player_name, S("Something went wrong!"))
        end
      else
	minetest.chat_send_player(player_name, S("Something went wrong!"))
      end
    else
      success, output = minetest.registered_chatcommands[sc["cmd"]].func(player_name, "")
      if success then
	if output == nil then
          minetest.chat_send_player(player_name, S("Command was executed successfully!"))
        else
          minetest.chat_send_player(player_name, output)
        end
      else
	minetest.chat_send_player(player_name, S("Something went wrong!"))
      end
    end
  else
    minetest.chat_send_player(player_name, S("Shortcut not found!"))
  end
end

function shortcut_funcs.create_shortcut(player_name,prms)
  -- create shortcut and add it to the "shortcut" table
  scs = shortcuts[player_name]
  if not scs then
    scs = {}
  end
  if prms ~= '' then
    command_name, params = shortcut_funcs.into_two(prms)
    if minetest.registered_chatcommands[command_name] == nil then
      minetest.chat_send_player(player_name, S("The command \"@1\" doesn't exist!", command_name))
      return
    end
    scs[#scs+1] = {cmd=command_name,params=params,desc=S("A shortcut.")}
    shortcuts[player_name] = scs
    shortcut_funcs.save_shortcuts()
    minetest.chat_send_player(player_name, S("Created new shortcut for @1 at @2 with \"@3 \".", command_name, tostring(#scs), shortcut_funcs.table_to_string(params)))
  else
    cmd = {cmd="", params={""}, desc=S("A shortcut.")}
    minetest.show_formspec(player_name, "shortcut:create", shortcut_funcs.get_create_formspec(cmd))
  end
end

function shortcut_funcs.list_shortcuts(player_name,other_player)
  scs = shortcuts[player_name]
  if not scs then
    minetest.chat_send_player(player_name, S("You have no shortcuts!"))
    return
  end
  if other_player ~= '' then
    scs = shortcuts[other_player]
    if not scs then
      minetest.chat_send_player(player_name, S("Player @1 has no shortcuts!", other_player))
      return
    end
    minetest.chat_send_player(player_name, S("Player @1 has the following shortcuts:", other_player))
  else
    minetest.chat_send_player(player_name, S("You have following shortcuts:"))
  end
  max = #tostring(#scs) - 1
  for i=1,#scs do
    space = ""
    for j=#tostring(i), max do
      space = space .. " "
    end
    minetest.chat_send_player(player_name, space .. tostring(i).. " | " .. scs[i].desc)
  end
end

function shortcut_funcs.copy_shortcut(player_name,prms)
  number, params = shortcut_funcs.into_two(prms)
  if player_name == params[1] then
    minetest.chat_send_player(player_name, S("You can't copy a shortcut to yourself!"))
    return
  end
  scs = {}
  if shortcuts[player_name] ~= nil then
    scs = shortcuts[player_name]
  end
  if shortcuts[params[1]] ~= nil then
    sc = shortcuts[params[1]][tonumber(number)]
    if sc ~= nil then
      scs[#scs+1] = {cmd=sc.cmd,params=sc.params,desc=sc.desc}
      shortcuts[player_name] = scs
      shortcut_funcs.save_shortcuts()
      minetest.chat_send_player(player_name, S("Copied shortcut successfully to @1!", params[1]))
    else
      minetest.chat_send_player(player_name, S("Player @1 has no shortcut number @2!", number))
    end
  else
    minetest.chat_send_player(player_name, S("You have no shortcuts!"))
  end
end

function shortcut_funcs.edit_shortcut(player_name,number)
  scs = {}
  if shortcuts[player_name] ~= nil then
    scs = shortcuts[player_name]
    sc = scs[tonumber(number)]
    if sc ~= nil then
      shortcuts[player_name][tonumber(number)].edit = true
      minetest.show_formspec(player_name, "shortcut:edit", shortcut_funcs.get_edit_formspec(sc))
    else
      minetest.chat_send_player(player_name, S("You have no shortcut number @1!", number))
    end
  else
    minetest.chat_send_player(player_name, S("You have no shortcuts!"))
  end
end