local REDNET_SIDE = "back"
local RECEIVER_ID = 80


rednet.open(REDNET_SIDE)
rednet.send(RECEIVER_ID)