-- Corona virus statistics.

function get()
	return https.get('https://corona.lmao.ninja/all')
end