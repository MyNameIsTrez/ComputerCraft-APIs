function detectDevice(deviceName)
  local deviceSide = nil
  for k, v in pairs(redstone.getSides()) do
    if peripheral.getType(v) == deviceName then
      deviceSide = v
      break
    end
  end
  return(deviceSide)
end