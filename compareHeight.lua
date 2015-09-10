-- if we have reached the cutoff height for stopping the pump, turn off the pump and wait for next reading
if tonumber(fields[6])>=maxHeight then
    tmr.stop(6)
    sendToTS = require("sendToTS")
    sendToTS.sendData("JSF pump keys", {"pump on", 0}, false, true, 'pauseAndRestart.lua')
    sendToTS = nil
    package.loaded["sendToTS"]=nil
end
