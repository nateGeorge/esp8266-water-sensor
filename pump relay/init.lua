-- gpio pins 0 and 2 on the esp01 are actually 3 and 4 in nodemcu land
relayPin = 1
gpio.mode(relayPin, gpio.OUTPUT)
gpio.write(relayPin, gpio.LOW)
noConnectCount = 0
tmr.alarm(1, 5000, 1, function()
    print(wifi.sta.status())
    if (wifi.sta.status()==5) then
        noConnectCount = 0
        tmr.stop(1)
        dofile('managepump2.lua')
    elseif (wifi.sta.status()~=5) and (wifi.sta.status()~=1) then
        wifi.sta.connect()
    else
        noConnectCount = noConnectCount + 1
    end
    if (noConnectCount > 4) then
        node.restart()
    end
end)
