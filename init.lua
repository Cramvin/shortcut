shortcuts = {}
first_load = true
scstorage = minetest.get_mod_storage()
dofile(minetest.get_modpath('shortcut')..'/load_shortcuts.lua')
dofile(minetest.get_modpath('shortcut')..'/commands.lua')
