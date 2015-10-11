-- checks for updated settings from thingspeak channel, called after reading settings
manualRun = false -- if the 'run pump' button has been clicked or set
print(createdTimes[1])
if file.open('latestTime') then
    local line = file.readline()
    latestTime = string.sub(line,1,string.len(line)-1) -- hack to remove CR/LF
    print('latest time: '..latestTime)
    print('latest time from server: '..createdTimes[1])
    if latestTime~=createdTimes[1] then
        if fields[1]~=nil and fields[2]~=nil and fields[3]~=nil then
            file.open('heights','w+')
            file.writeline(fields[1])
            file.writeline(fields[2])
            file.writeline(fields[3])
            file.close()
        end
        print(fields[4]==1 and fields[5]~=nil)
        print('fields:')
        for i,v in ipairs(fields) do
            print(v)
        end
        if tonumber(fields[4])==1 and fields[5]~=nil then
            timeToOff = tonumber(fields[5]);
            manualRun = true
            print('manually running pump for '..tostring(timeToOff)..' minutes')
            dofile('turn on pump.lua')
        end
        if tonumber(fields[6])==1 then
            print('turning off pump')
            file.close()
            file.open('latestTime','w+')
            file.writeline(createdTimes[1])
            file.close()
            manualRun = true
            gpio.write(relayPin, gpio.LOW)
            dataToSend[1] = {"pump on", 0}
            sendToTS = require("sendToTS")
            sendToTS.sendData("JSF pump keys", dataToSend, false, true, 'pauseAndRestart.lua')
            sendToTS = nil
            package.loaded["sendToTS"]=nil
        end
    end
    file.close()
    file.open('latestTime','w+')
    file.writeline(createdTimes[1])
    file.close()
else
    file.open('latestTime','w+')
    file.writeline(createdTimes[1])
    file.close()
end

if file.open('heights') and not manualRun then
    local line = file.readline()
    minHeight = string.sub(line,1,string.len(line)-1) -- hack to remove CR/LF
    line = file.readline()
    maxHeight = string.sub(line,1,string.len(line)-1) -- hack to remove CR/LF
    line = file.readline()
    line = string.sub(line,1,string.len(line)-1) -- hack to remove CR/LF
    timeToOff = tonumber(line)*60
    file.close()
elseif not manualRun then
    minHeight = 2
    maxHeight = 4
    timeToOff = 2*60
end

if maxHeight~=nil and not manualRun then
    print('min height: '..tostring(minHeight))
    print('max height:'..tostring(maxHeight))
    print('max time on: '..tostring(timeToOff))
    -- check the water height and shut off pump if tanks are full
    readTS = require("readTS")
    readTS.readData('JSF water level keys', true, 1, 'compareHeight.lua')
    readTS = nil
    package.loaded["readTS"]=nil
end
