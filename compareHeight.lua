-- if we have reached the cutoff height for stopping the pump, turn off the pump and wait for next reading
print('water height: '..fields[6]..', max height: '..tostring(maxHeight))
if tonumber(fields[6])>=maxHeight then
    print('stopping pump, water full')
    tmr.stop(6)
    tmr.stop(5)
    sendToTS = require("sendToTS")
    sendToTS.sendData("JSF pump keys", {"pump on", 0}, false, true, 'pauseAndRestart.lua')
    sendToTS = nil
    package.loaded["sendToTS"]=nil
else
    dofile('turn on pump.lua')
end
