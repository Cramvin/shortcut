local S = minetest.get_translator("shortcut")

function shortcut_funcs.copy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[shortcut_funcs.copy(k)] = shortcut_funcs.copy(v) end
    return res
end

function shortcut_funcs.to_change(t)
  change = 0
  for i=1,#sc_params do 
    if sc_params[i] == "*" or sc_params[i] == "@p" then
      change = change + 1
    end
  end
  return change
end

function shortcut_funcs.table_to_string(t)
  if #t > 0 then
    return table.concat(t, " ")
  end
  return ""
end

function shortcut_funcs.split_string(s)
  words = {}
  for word in s:gmatch("%S+") do table.insert(words, word) end
  return words
end

function shortcut_funcs.into_two(params)
  t = shortcut_funcs.split_string(params)
  first = table.remove(t,1)
  return first, t
end

function shortcut_funcs.get_edit_formspec(cmd)
    local command_text = S("Command")
    local params_text = S("Parameters")
    local desc_text = S("Description")
    local button_text = S("Accept")

    local formspec = {
        "formspec_version[4]",
        "size[8,5.25]",
        "field[0.375,0.875;7.25,0.5;command;", minetest.formspec_escape(command_text), ";", minetest.formspec_escape(cmd.cmd), "]",
        "field[0.375,2;7.25,0.5;params;", minetest.formspec_escape(params_text), ";", minetest.formspec_escape(table.concat(cmd.params, " ")), "]",
        "field[0.375,3.125;7.25,0.5;description;", minetest.formspec_escape(desc_text), ";", minetest.formspec_escape(cmd.desc), "]",
        "button[2.5,3.875;3,1;accept;", minetest.formspec_escape(button_text), "]"
    }

    return table.concat(formspec, "")
end

function shortcut_funcs.get_create_formspec(cmd)
    local command_text = S("Command")
    local params_text = S("Parameters")
    local desc_text = S("Description")
    local button_text = S("Create")

    local formspec = {
        "formspec_version[4]",
        "size[8,5.25]",
        "field[0.375,0.875;7.25,0.5;command;", minetest.formspec_escape(command_text), ";", minetest.formspec_escape(cmd.cmd), "]",
        "field[0.375,2;7.25,0.5;params;", minetest.formspec_escape(params_text), ";", minetest.formspec_escape(table.concat(cmd.params, " ")), "]",
        "field[0.375,3.125;7.25,0.5;description;", minetest.formspec_escape(desc_text), ";", minetest.formspec_escape(cmd.desc), "]",
        "button[2.5,3.875;3,1;create;", minetest.formspec_escape(button_text), "]"
    }

    return table.concat(formspec, "")
end

function shortcut_funcs.save_shortcuts()
  scstorage:set_string("shortcuts", minetest.serialize(shortcuts))
  shortcuts = minetest.deserialize(scstorage:get_string("shortcuts"))
end