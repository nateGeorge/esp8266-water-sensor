dataToSend = {}
dataToSend[1] = {"pump on", 1}
sendToTS = require("sendToTS")
sendToTS.sendData("JSF pump keys", dataToSend, false, true)
sendToTS = nil
package.loaded["sendToTS"]=nil
startTime = tmr.now()/(1000*1000)
gpio.write(relayPin, gpio.HIGH)
shutOff = timeToOff*60
print('time to shutoff: '..tostring(shutOff))

local function stopPump()
    print('stopping pump because max time reached')
    gpio.write(relayPin, gpio.LOW)
    dataToSend[1] = {"pump on", 0}
    sendToTS = require("sendToTS")
    sendToTS.sendData("JSF pump keys", dataToSend, false, true, 'pauseAndRestart.lua')
    sendToTS = nil
    package.loaded["sendToTS"]=nil
end

tmr.alarm(2, 10*1000, 0, function()
    print('checking pump settings, then water height')
    if ((tmr.now()/(1000*1000)-startTime) >= shutOff) then
        stopPump()
    elseif not manualRun then
        -- check the water height and shut off pump if tanks are full
        readTS = require("readTS")
        readTS.readData('JSF water level keys', true, 1, 'managepump2.lua')
        readTS = nil
        package.loaded["readTS"]=nil
    else
        tmr.alarm(3, 10*1000, 1, function()
            if ((tmr.now()/(1000*1000)-startTime) >= shutOff) then
                stopPump()
            end
        end)
    end
end)
