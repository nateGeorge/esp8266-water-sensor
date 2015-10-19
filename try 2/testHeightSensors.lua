-- works: 1 2 5 6 7

emptyPin = 1
fullPin = 2

gpio.mode(emptyPin, gpio.INPUT, gpio.PULLUP)
gpio.mode(fullPin, gpio.INPUT, gpio.PULLUP)
tmr.alarm(1, 1000, 1, function() 
    print(gpio.read(emptyPin))
    print(gpio.read(fullPin))
end)