shortcuts = {}
shortcut_funcs = {}

scstorage = minetest.get_mod_storage()
dofile(minetest.get_modpath('shortcut')..'/utils.lua')
dofile(minetest.get_modpath('shortcut')..'/load_shortcuts.lua')
dofile(minetest.get_modpath('shortcut')..'/commands.lua')
dofile(minetest.get_modpath('shortcut')..'/registers.lua')
