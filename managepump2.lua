relayPin = 2
gpio.mode(relayPin, gpio.OUTPUT)

readTS = require("readTS")
readTS.readData('JSF water pump settings', true, 1, 'checkPumpSettings.lua')
readTS = nil
package.loaded["readTS"]=nil
