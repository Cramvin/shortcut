function get_shortcuts()
  shortcuts = minetest.deserialize(scstorage:get_string("shortcuts"))
end

if not pcall(get_shortcuts) then
  shortcuts = {}
end
