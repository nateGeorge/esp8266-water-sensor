print('running file in 5s...')
tmr.alarm(1,5000, 0, function()
    if wifi.sta.status() == 5 then
        dofile('connectMQTT-wellheight.lua')
    end
end)

tmr.alarm(2, 30000, 0, function()
    node.restart() -- in case it can't connect to mqtt or something and is just sitting there
end)
