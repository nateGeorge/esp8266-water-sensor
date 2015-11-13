relayPin = 1
gpio.mode(relayPin, gpio.OUTPUT)
gpio.write(relayPin, 1)
print('running file in 5s...')
tmr.alarm(1,1000, 1, function()
    if wifi.sta.status() == 5 then
        tmr.stop(1)
        dofile('connectMQTT-wellpump.lua')
    elseif wifi.sta.status()~=1 and wifi.sta.status()~=5 then
        node.restart()
    end
end)
