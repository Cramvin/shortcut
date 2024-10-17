function get_shortcuts()
  shortcuts = minetest.deserialize(scstorage:get_string("shortcuts"))
end

if not pcall(get_shortcuts) then
  shortcuts = {}
end
if shortcuts == nil then
  shortcuts = {}
end

local found = false
for i=1,#shortcut do
  if not shortcut[i]["type"] then
    shortcut[i]["type"] = 0
    found = true
  else
    break
  end
end
if found then
  shortcut_funcs.save_shortcuts()
end