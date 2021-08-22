# Introduction
This repository is for running a Node.js server. It hosts all the files for the "BackwardsOS" operating system for ComputerCraft (a Minecraft mod).

When the server is running and any changes to the files in its `synced/` directory are made, it'll tell any computers running BackwardsOS to redownload the updated server files.

This enables the latest version of BackwardsOS to be pushed across any singleplayer and multiplayer worlds that are using it.

# Getting started

## Running the server to download the latest version of BackwardsOS from

Run `node app.js`

## Downloading BackWardsOS to a Computer/Turtle

1. Open a Computer/Turtle.
2. Type `lua`
3. Paste and enter this:
`h=io.open("startup","w")h:write(http.get("http://h2896147.stratoserver.net:1338/file?name=programs/startup").readAll())h:close()`
4. Restart by holding `ctrl+r` for a few seconds.

# TODO

* Typing "aaaaa" and then removing the first "a" with backspace and then pressing "c" places the "c" at the end instead of the front. Might have to do with history[1] being very wrong.
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