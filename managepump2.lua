relayPin = 1
gpio.mode(relayPin, gpio.OUTPUT)

readTS = require("readTS")
readTS.readData('JSF water level keys', true, 1, 'checkPumpSettings.lua')
readTS = nil
package.loaded["readTS"]=nil