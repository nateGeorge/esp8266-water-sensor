-- initialize pins for reading water levels of 1-5 ft
-- table is in format pin number, feet
local waterLevels = {}
local dataToSend = {}
local waterHeight
local lastNum
waterLevels[1] = {1, 1}
waterLevels[2] = {2, 2}
waterLevels[3] = {5, 3}
waterLevels[4] = {6, 4}
waterLevels[5] = {7, 5}
for num, arr in ipairs(waterLevels) do
    gpio.mode(arr[1], gpio.INPUT)
    dataToSend[num] = {tostring(arr[2]).."ft", gpio.read(arr[1])}
    if gpio.read(arr[1]) == 1 then
        waterHeight = arr[2];
    end
    lastNum = num
end
    
tmr.alarm(4, 60*1000, 1, function()
    for num, arr in ipairs(waterLevels) do
        dataToSend[num] = {tostring(arr[2]), gpio.read(arr[1])}
        if gpio.read(arr[1]) == 1 then
            waterHeight = arr[2];
        end
        lastNum = num
    end
    if waterHeight == nil then
        waterHeight = 0
    end
    dataToSend[lastNum + 1] = {'Water Height', waterHeight}
    sendToTS = require("sendToTS")
    if waterHeight >= 4 then
        sendToTS.sendData('JSF water level keys', dataToSend, false, true, 'stopAndSleep.lua')
    else
        sendToTS.sendData('JSF water level keys', dataToSend, false, true)
    end
    sendToTS = nil
    package.loaded["sendToTS"]=nil
end)
