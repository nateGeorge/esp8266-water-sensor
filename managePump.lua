-- gpio pins 0 and 2 on the esp01 are actually 3 and 4 in nodemcu land
relayPin = 4
gpio.mode(relayPin, gpio.OUTPUT)
print(waterEmpty)
if waterEmpty==true or waterEmpty==false then
    if waterEmpty then
        print('turning on pump')
        gpio.write(relayPin, gpio.HIGH)
        tmr.alarm(5, 60*1000, 1, function()
            sendToTS = require("sendToTS")
            sendToTS.sendData("JSF pump keys", {"pump on", 1}, false, true)
            sendToTS = nil
            package.loaded["sendToTS"]=nil

            readTS = require("readTS")
            readTS.readData('JSF water level keys', true, 1)
            readTS = nil
            package.loaded["readTS"]=nil
            if (waterHeight>=4) then
                tmr.stop(5)
                sendToTS = require("sendToTS")
                sendToTS.sendData("JSF pump keys", {"pump on", 0}, false, true)
                sendToTS = nil
                package.loaded["sendToTS"]=nil
                print('turning off pump')
                gpio.write(relayPin, gpio.LOW)
                node.dsleep(5*60*1000*1000) -- sleep for 5 min
            end
        end)
    elseif (waterFull) then
        if (gpio.read(relayPin) == gpio.HIGH) then
            print('turning off pump')
            gpio.write(relayPin, gpio.LOW)
        end
        sendToTS = require("sendToTS")
        sendToTS.sendData("JSF pump keys", {"pump on", 0}, false, true)
        sendToTS = nil
        package.loaded["sendToTS"]=nil
        node.dsleep(5*60*1000*1000) -- sleep for 5 min
    end
    tmr.stop(1)
end