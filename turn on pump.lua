tmr.alarm(5, timeToOff*60*1000, 0, function()
    tmr.stop(6)
    sendToTS = require("sendToTS")
    sendToTS.sendData("JSF pump keys", {"pump on", 0}, false, true, 'pauseAndRestart.lua')
    sendToTS = nil
    package.loaded["sendToTS"]=nil
end)

gpio.write(relayPin, gpio.HIGH)

tmr.alarm(6, 60*1000, 1, function()
    sendToTS = require("sendToTS")
    sendToTS.sendData("JSF pump keys", {"pump on", 1}, false, true)
    sendToTS = nil
    package.loaded["sendToTS"]=nil
    if not manualRun then
        readTS = require("readTS")
        readTS.readData('JSF water level keys', true, 1, 'compareHeight.lua')
        readTS = nil
        package.loaded["readTS"]=nil
    end
end)
