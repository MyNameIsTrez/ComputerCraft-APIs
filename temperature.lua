-- This API relies on the 'json' API being installed! https://pastebin.com/4nRg9CHU

function getTemperature()
  local URL = "http://weerlive.nl/api/json-data-10min.php?key=demo&locatie=Amsterdam"
  local table = http.get(URL)
  local str = table.readAll()
  table.close()
  local obj = json.decode(str)
  return obj.liveweer[1].temp
end