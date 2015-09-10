tmr.alarm(5, timeToOff*60*1000*1000, 0, function()
    tmr.stop(6)
    dataToSend[1] = {"pump on", 0}
    sendToTS = require("sendToTS")
    sendToTS.sendData("JSF pump keys", dataToSend, false, true, 'pauseAndRestart.lua')
    sendToTS = nil
    package.loaded["sendToTS"]=nil
end)

gpio.write(relayPin, gpio.HIGH)

tmr.alarm(6, 10*1000*1000, 1, function()
    dataToSend = {}
    dataToSend[1] = {"pump on", 1}
    sendToTS = require("sendToTS")
    sendToTS.sendData("JSF pump keys", dataToSend, false, true)
    sendToTS = nil
    package.loaded["sendToTS"]=nil
    if not manualRun then
        -- check the water height and shut off pump if tanks are full
        readTS = require("readTS")
        readTS.readData('JSF water level keys', true, 1, 'compareHeight.lua')
        readTS = nil
        package.loaded["readTS"]=nil
    end
end)
