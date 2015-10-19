relayPin = 1
relayState = 0
gpio.mode(relayPin, gpio.OUTPUT)
tmr.alarm(1, 1000, 1, function()
    gpio.write(1, relayState)
    if relayState == 0 then
        relayState = 1
    else
        relayState = 0
    end
end)