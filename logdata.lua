gpio.mode(1,gpio.INPUT) 
dataToSend[1] = {'Water Full', gpio.read(1)}
print(gpio.read(1))

sendToTS = require("sendToTS")
sendToTS.sendData(dataToSend, true)

sendToSparkfun = nil
package.loaded["sendToTS"]=nil