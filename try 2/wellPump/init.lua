print('running file in 5s...')
tmr.alarm(1,5000, 0, function()
    if wifi.sta.status() == 5 then
        dofile('connectMQTT-wellpump.lua')
    end
end)
