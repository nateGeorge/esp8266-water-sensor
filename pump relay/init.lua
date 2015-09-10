-- gpio pins 0 and 2 on the esp01 are actually 3 and 4 in nodemcu land
relayPin = 4
gpio.mode(relayPin, gpio.OUTPUT)
noConnectCount = 0
tmr.alarm(1, 5000, 1, function()
    if (wifi.sta.status()==5) then
        noConnectCount = 0
        dofile('managePump.lc')
        tmr.stop(1)
    elseif (wifi.sta.status()~=5) and (wifi.sta.status()~=1) then
        wifi.sta.connect()
    else
        noConnectCount = noConnectCount + 1
    end
    if (noConnectCount > 4) then
        node.restart()
    end
end)