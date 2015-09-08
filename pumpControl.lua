local dataToSend = {}
dataToSend[1] = {'pump on', 1, 8}

sendToTS = require("sendToTS")
sendToTS.sendData(dataToSend, true, true)

sendToSparkfun = nil
package.loaded["sendToTS"]=nil