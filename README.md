# Introduction
Project for hosting a server that stores and updates ComputerCraft APIs in real-time. (for Tekkit Classic, CC 1.33)

# TODO

* Crafting program prototype.
* Allow recursive directories in the synced/jobs/ and any other synced/ folder.
	* Currently there's jobs/crafting.lua and jobs/items in CC.
* Figure out why the "lua" program starts with an extra enter in my program.
* Add ctrl+backspace from VS Code.
* Add ctrl+delete from VS Code.
* Manually expand one-liners like "if X==Y then Z() end" into multiple lines.
* Catch any errors inside the OS.
	* If the error didn't occur in a crucial file, throw an error inside of the OS.
* Offline usage.
* Overwrite print() and write() so the passed strings are written to a table.
    * The table shouldn't hold an infinite amount of elements.
    * ctrl+f.
* Ability to use any application/game using Xvfb inside CC.
