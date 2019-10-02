function getTemperature()
  local URL = 'http://weerlive.nl/api/json-data-10min.php?key=demo&locatie=Amsterdam'
  local table = http.get(URL)
  local str_data = table.readAll()
  local temp_index = str_data:find("temp")
  local temp = string.sub(str_data, temp_index + 8, temp_index + 11)
  return temp
end
local text = 'TEMP '..getTemperature()