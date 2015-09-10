local dataToSend = {}
dataToSend[1] = {'pump on', 1}

sendToTS = require("sendToTS")
sendToTS.sendData('JSF pump keys', dataToSend, false, true)

sendToSparkfun = nil
package.loaded["sendToTS"]=nil
