relayPin = 4
gpio.mode(relayPin, gpio.OUTPUT)

readTS = require("readTS")
readTS.readData(54556, true, 1)

readTS = nil
package.loaded["readTS"]=nil