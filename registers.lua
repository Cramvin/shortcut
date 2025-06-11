local S = minetest.get_translator("shortcut")

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "shortcut:edit" then
        local player_name = player:get_player_name()
        local sc = 0
        for i=1,#shortcuts[player_name] do
          if shortcuts[player_name][i].edit then
            sc = i
          end
        end
        if sc ~= 0 then
          shortcuts[player_name][sc] = {cmd = fields.command, params = shortcut_funcs.split_string(fields.params), desc = fields.description}
          shortcut_funcs.save_shortcuts()
          minetest.close_formspec(player_name, formname)
          minetest.chat_send_player(player_name, S("Changed command at @1 successfully!", sc))
        end
    elseif formname == "shortcut:create" then
       local player_name = player:get_player_name()
       scs = shortcuts[player_name]
       if scs == nil then
         scs = {}
       end
       if fields.command == "" or fields.command == nil then
         minetest.close_formspec(player_name, formname)
         minetest.chat_send_player(player_name, S("Canceled shortcut creation!"))
         return
       end
       scs[#scs+1] = {cmd = fields.command, params = shortcut_funcs.split_string(fields.params), desc = fields.description}
       shortcuts[player_name] = scs
       shortcut_funcs.save_shortcuts()
       minetest.close_formspec(player_name, formname)
       minetest.chat_send_player(player_name, S("Created new shortcut for @1 at @2 with \"@3 \".", fields.command, tostring(#shortcuts[player_name]), fields.params))
    else
       return
    end
end)

minetest.register_chatcommand("csc",{
    params = "<"..S("command name").."> [<"..S("params")..">]",
    description = S("Creates a shortcut to a command."),
    privs = {server=true},
    func = function(player_name,params)
             shortcut_funcs.create_shortcut(player_name,params)
           end,
})

minetest.register_chatcommand("copysc",{
    params = "<"..S("number").."> <"..S("other player")..">",
    description = S("Copies a shortcut to another player."),
    privs = {server=true},
    func = function(player_name,params)
             shortcut_funcs.copy_shortcut(player_name,params)
           end,
})

minetest.register_chatcommand("rsc",{
    params = "<"..S("number")..">",
    description = S("Removes a shortcut to a command."),
    privs = {server=true},
    func = function(player_name,number)
             shortcut_funcs.remove_shortcut(player_name,number)
           end,
})

minetest.register_chatcommand("sscd",{
    params = "<"..S("number").."> <"..S("description")..">",
    description = S("Changes the description of a shortcut."),
    privs = {server=true},
    func = function(player_name,param)
             shortcut_funcs.change_desc(player_name,param)
           end,
})

minetest.register_chatcommand("scd",{
    params = "<"..S("number")..">",
    description = S("Outputs the description of a shortcut."),
    privs = {server=true},
    func = function(player_name,number)
             shortcut_funcs.read_desc(player_name,number)
           end,
})

minetest.register_chatcommand("esc",{
    params = "<"..S("number")..">",
    description = S("For editing a shortcut."),
    privs = {server=true},
    func = function(player_name,number)
             shortcut_funcs.edit_shortcut(player_name,number)
           end,
})

minetest.register_chatcommand("sc",{
      params = "<"..S("number").."> [<"..S("params")..">]",
      description = S("Runs a shortcut."),
      privs = {server=true},
      func = function(player_name,params)
               shortcut_funcs.run_shortcut(player_name,params)
             end,
    })

minetest.register_chatcommand("lsc",{
      params = "[<"..S("other player")..">]",
      description = S("Lists all shortcuts."),
      privs = {server=true},
      func = function(player_name,other_player)
               shortcut_funcs.list_shortcuts(player_name,other_player)
             end,
    })
