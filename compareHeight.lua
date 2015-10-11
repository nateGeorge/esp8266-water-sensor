-- if we have reached the cutoff height for stopping the pump, turn off the pump and wait for next reading
dataToSend = {}
print('water height: '..fields[6]..', max height: '..tostring(maxHeight))
if tonumber(fields[6])>=tonumber(maxHeight) then
    print('stopping pump, water full')
    print('turning off pump')
    dataToSend[1] = {"pump on", 0}
    sendToTS = require("sendToTS")
    sendToTS.sendData("JSF pump keys", dataToSend, false, true, 'pauseAndRestart.lua')
    sendToTS = nil
    package.loaded["sendToTS"]=nil
    gpio.write(relayPin, gpio.LOW)
    tmr.stop(2)
elseif tonumber(fields[6])<=tonumber(minHeight) then
    dofile('turn on pump.lua')
end
