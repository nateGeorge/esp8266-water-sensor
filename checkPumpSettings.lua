-- checks for updated settings from thingspeak channel, called after reading settings
manualRun = false -- if the 'run pump' button has been clicked or set
if file.open('latestTime') then
    latestTime = file.readline()
    print(latestTime)
    print(createdTimes[1])
    if latestTime~=createdTimes[1] then
        if fields[1]~='null' and fields[2]~='null' and fields[3]~='null' then
            file.open('heights','w+')
            file.writeline(fields[1])
            file.writeline(fields[2])
            file.writeline(fields[3])
            file.close()
        end
        
        if fields[4]==1 and fields[5]~='null' then
            timeToOff = fields[4];
            manualRun = true
            dofile('turn on pump.lua')
        end
        
        if fields[6]==1 then
            manualRun = true
            gpio.write(relayPin, gpio.LOW())
            tmr.alarm(3, 5*60*1000, 0, function()
                dofile('init.lua')
            end)
        end
    end
    file.close()
    file.open('latesttime','w+')
    file.writeline(createdTimes[1])
    file.close()
else
    file.open('latesttime','w+')
    file.writeline(createdTimes[1])
    file.close()
end

if file.open('heights') and not manualRun then
    minHeight = file.readline()
    maxHeight = file.readline()
    timeToOff = file.readline()*60
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
    dofile('turn on pump.lua')
end
