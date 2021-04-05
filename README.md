# Introduction
Project for hosting a server that stores and updates ComputerCraft APIs in real-time. (for Tekkit Classic, CC 1.33)

# TODO
* Expand one-liners like "if X==Y then Z() end" into multiple lines, cause they're annoying to expand later.
* "Subterminal" class.
	* Make backwardsos.main() create a subterminal where the delete key does work.
* Catch any errors inside the OS.
	* If the error didn't occur in a crucial file, throw an error inside of the OS.
* Support offline usage.
* Make programs like 'ls' and 'cd' callable in my OS.
* Overwrite print() and write() so the passed strings are written to a table.
    * The table shouldn't hold an infinite amount of elements, so if #table > N and it is written to, the first (oldest) element should be set to nil.
    * Add scrolling up and down through the previously printed text.
    * Add ctrl+f support for searching through printed text.
* Write a basic Bomberman clone in P5.js.
    * Save a frame and convert it to an ASCII file.
        Doing this in advance of getting a http request should reduce latency, but not converting often enough per second could mean unnecessary low framerates for the players.
