# Introduction
Project for hosting a server that stores and updates ComputerCraft APIs in real-time. (for Tekkit Classic, CC 1.33)

# TODO

* Replace term.write with a version that saves history?
* lua program doesn't draw correctly while scrolling.

* Fix wrapping when typing past terminal width.
* The server doesn't always respond to the long poll GET on a file being saved.
* If the user types anything while scrolled up, scroll the user to the bottom.
* Move utils.cursor_prompt, utils.cursor_prompt to a globals file.

* Change special "r" and "t" keys to ones that are never used in typing.
	* Maybe replace vanilla ctrl+r and ctrl+t?
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
* Backport require()
* synced_metadata can't have separate keys for an API and program with the same name.
* Allow user to stay on stable updates, but notify the user often when new stable versions are available.