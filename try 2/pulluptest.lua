-- works: 1 2 5 6 7

pin = 2

gpio.mode(pin ,gpio.INPUT, gpio.PULLUP)
tmr.alarm(1,1000,1,function() print(gpio.read(pin)) end)