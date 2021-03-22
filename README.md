# Introduction
Project for hosting a server that stores and updates ComputerCraft APIs in real-time. (for Tekkit Classic, CC 1.33)

# TODO
* Create a "programs" folder that gets updated like the APIs.
	The files in it are like "startup", and shouldn't be loaded.
	Add a "/get-program" port.
* Update "startup" by copying from "files/startup"
	Copy "files/startup" to "." and overwrite the "startup" that was there.
* Subterminal.
	Make backwardsos.main() create a subterminal where the delete key *does* work.
* Support offline usage.
* Refactor server.js.
	Refactor app.post("/apis-get-latest", ...) into subfunctions.
* Live reloading from text editor ctrl+s.
	Detect text editor saving by having CC have an unanswered http.get in a parallel.waitForAny() at all times.
	Node.js may be able to detect a file save event by checking every second if any of the files
	have a higher mtime than they had at the previous check.
