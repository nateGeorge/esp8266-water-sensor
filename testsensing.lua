gpio.mode(2, gpio.OUTPUT)
gpio.write(2, gpio.HIGH)
gpio.mode(2, gpio.INT)
function pin1cb(level)
     if level == 1 then 
        gpio.trig(1, "down ")
        print('out of water')
    else 
        gpio.trig(1, "up ")
        print('water sensed')
    end
end
gpio.trig(2, "down ",pin1cb)