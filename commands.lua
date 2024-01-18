local S = minetest.get_translator("shortcut")

function copy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[copy(k)] = copy(v) end
    return res
end

function to_change(t)
  change = 0
  for i=1,#sc_params do 
    if sc_params[i] == "*" then
      change = change + 1
    end
  end
  return change
end

function table_to_string(t)
  if #t > 0 then
    output = table.remove(t,1)
    if #t > 0 then
      for i=1,#t do
        output = output .. " " .. t[i]
      end
    end
    return output
  end
  return ""
end

function split_string(s)
  words = {}
  for word in s:gmatch("%S+") do table.insert(words, word) end
  return words
end

function into_two(params)
  t = split_string(params)
  first = table.remove(t,1)
  return first, t
end

function save_shortcuts()
  scstorage:set_string("shortcuts", minetest.serialize(shortcuts))
  shortcuts = minetest.deserialize(scstorage:get_string("shortcuts"))
end

function change_desc(player_name,params)
  number, desc = into_two(params)
  if shortcuts[player_name] ~= nil then
    if shortcuts[player_name][tonumber(number)] ~= nil then
      shortcuts[player_name][tonumber(number)].desc = table_to_string(desc)
      save_shortcuts()
      minetest.chat_send_player(player_name, S("Changed description of shortcut @1 to \"@2\".", number, shortcuts[player_name][tonumber(number)].desc))
    else
      minetest.chat_send_player(player_name, S("You have no shortcut number @1!", number))
    end
  else
    minetest.chat_send_player(player_name, S("You have no shortcuts!"))
  end
end

function read_desc(player_name,number)
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

function remove_shortcut(player_name,number)
  if shortcuts[player_name] ~= nil then
    if shortcuts[player_name][tonumber(number)] ~= nil then
      table.remove(shortcuts[player_name],number)
      save_shortcuts()
      minetest.chat_send_player(player_name, S("Removed command at @1.", tostring(number)))
    else
      minetest.chat_send_player(player_name, S("You have no shortcut number @1!", number))
    end
  else
    minetest.chat_send_player(player_name, S("You have no shortcuts!"))
  end
end

function run_shortcut(player_name,prms)
  number, cmd_params = into_two(prms)
  sc = shortcuts[player_name]
  if sc then
    sc = sc[tonumber(number)]
  end
  if sc then
    if #sc.params > 0 then
      sc_params = copy(sc.params)
      if to_change(sc_params) ~= #cmd_params then
         minetest.chat_send_player(player_name, S("You need to set parameters!"))
        return
      end
      j = 1
      for i=1,#sc_params do 
        if sc_params[i] == "*" then
          sc_params[i] = cmd_params[j]
          j = j + 1
        end
      end
      if to_change(sc_params) == 0 then
	success, output = minetest.registered_chatcommands[sc["cmd"]].func(player_name,table_to_string(sc_params))
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
      success, output = minetest.registered_chatcommands[sc["cmd"]].func(player_name)
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

function create_shortcut(player_name,prms)
  -- create shortcut and add it to the "shortcut" table
  -- register it as "sc <number in table> [<params>]" -> [] is future content
  command_name, params = into_two(prms)
  scs = shortcuts[player_name]
  if not scs then
    scs = {}
  end
  if minetest.registered_chatcommands[command_name] == nil then
    minetest.chat_send_player(player_name, S("The command \"@1\" doesn't exist!", command_name))
    return
  end
  scs[#scs+1] = {cmd=command_name,params=params,desc=S("A shortcut.")}
  shortcuts[player_name] = scs
  save_shortcuts()
  minetest.chat_send_player(player_name, S("Created new shortcut for @1 at @2 with \"@3 \".", command_name, tostring(#scs), table_to_string(params)))
end

function list_shortcuts(player_name)
  scs = shortcuts[player_name]
  if not scs then
    minetest.chat_send_player(player_name, S("You have no shortcuts!"))
    return
  end
  minetest.chat_send_player(player_name, S("You have following shortcuts:"))
  max = #tostring(#scs) - 1
  for i=1,#scs do
    space = ""
    for j=#tostring(i), max do
      space = space .. " "
    end
    minetest.chat_send_player(player_name, space .. tostring(i).. " | " .. scs[i].desc)
  end
end

function copy_shortcut(player_name,prms)
  number, params = into_two(prms)
  if player_name == params[1] then
    minetest.chat_send_player(player_name, S("You can't copy a shortcut to yourself!"))
    return
  end
  other_scs = {}
  if shortcuts[params[1]] ~= nil then
    other_scs = shortcuts[params[1]]
  end
  if shortcuts[player_name] ~= nil then
    sc = shortcuts[player_name][tonumber(number)]
    if sc ~= nil then
      other_scs[#other_scs+1] = {cmd=sc.cmd,params=sc.params,desc=sc.desc}
      shortcuts[params[1]] = other_scs
      save_shortcuts()
      minetest.chat_send_player(player_name, S("Copied shortcut successfully to @1!", params[1]))
    else
      minetest.chat_send_player(player_name, S("You have no shortcut number @1!", number))
    end
  else
    minetest.chat_send_player(player_name, S("You have no shortcuts!"))
  end
end

minetest.register_chatcommand("csc",{
    params = "<"..S("command name").."> [<"..S("params")..">]",
    description = S("Creates a shortcut to a command."),
    privs = {server=true},
    func = function(player_name,params)
             create_shortcut(player_name,params)
           end,
})

minetest.register_chatcommand("copysc",{
    params = "<"..S("number").."> <"..S("other player")..">",
    description = S("Copies a shortcut to another player."),
    privs = {server=true},
    func = function(player_name,params)
             copy_shortcut(player_name,params)
           end,
})

minetest.register_chatcommand("rsc",{
    params = "<"..S("number")..">",
    description = S("Removes a shortcut to a command."),
    privs = {server=true},
    func = function(player_name,number)
             remove_shortcut(player_name,number)
           end,
})

minetest.register_chatcommand("sscd",{
    params = "<"..S("number").."> <"..S("description")..">",
    description = S("Changes the description of a shortcut."),
    privs = {server=true},
    func = function(player_name,param)
             change_desc(player_name,param)
           end,
})

minetest.register_chatcommand("scd",{
    params = "<"..S("number")..">",
    description = S("Outputs the description of a shortcut."),
    privs = {server=true},
    func = function(player_name,number)
             read_desc(player_name,number)
           end,
})

minetest.register_chatcommand("sc",{
      params = "<"..S("number").."> [<"..S("params")..">]",
      description = S("Runs a shortcut."),
      privs = {server=true},
      func = function(player_name,params)
               run_shortcut(player_name,params)
             end,
    })

minetest.register_chatcommand("lsc",{
      description = S("Lists all shortcuts."),
      privs = {server=true},
      func = function(player_name)
               list_shortcuts(player_name)
             end,
    })