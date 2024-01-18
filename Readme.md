# Shortcut

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Q5Q67BE9Y)

A mod for the open source game Minetest(>=0.5.4) which makes it possible to create shortcuts to commands.

___

# Commands

If you have parameters that you don't know when you create a shortcut, you can use * to replace it.

| Command                        | Description                         | Example                                |
| ------------------------------ | ----------------------------------- | -------------------------------------- |
| /lsc                           | lists shortcuts                     | /lsc                                   |
| /csc \<command name\> [\<params\>] | creates shortcuts                   | /csc grant * fly                       |
| /rsc \<number\>                  | removes a shortcut                  | /rsc 1                                 |
| /sc \<number\>                   | runs a shortcut                     | /sc 1 User1234                         |
| /sscd \<number\> \<description\>   | sets a description for a shortcut   | /sscd 1 Gives a player fly privileges. |
| /scd \<number\>                  | shows the description of a shortcut | /scd 1                                 |

___

# Installation

Either download it through in game with the Content API or

1. Download the mod from [here](https://github.com/Cramvin/shortcut/releases/tag/Release)

2. Open the Minetest mods directory (end of path looks like .../Minetest-0.5.8/mods)

3. Unzip the contents of the download into the Minetest mods directory

4. In game select a world and under mods activate **shortcut**

To deinstall it delete the shortcut directory in the mods directory.

___

# Feedback

If you have any wishes for a new feature or you have found a bug then please let me know in the Issues tab or on the Content API site of Minetest.
