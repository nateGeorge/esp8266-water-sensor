gpio.mode(1,gpio.INPUT)
tmr.alarm(1,1000,1,function()
    print(gpio.read(1))
end)