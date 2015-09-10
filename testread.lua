readTS = require("readTS")
readTS.readData('JSF water level keys', true, 1, 'compareHeight.lua')
readTS = nil
package.loaded["readTS"]=nil