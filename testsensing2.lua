local pin1 = 1
local pin2 = 2
local pin3 = 5
local pin4 = 6
local pin5 = 7
gpio.mode(pin1, gpio.INPUT)
gpio.mode(pin2, gpio.INPUT)
gpio.mode(pin3, gpio.INPUT)
gpio.mode(pin4, gpio.INPUT)
gpio.mode(pin5, gpio.INPUT)
tmr.alarm(1,1000,1,function()
    print('1 ft:')
    print(gpio.read(pin1))
    print('2 ft:')
    print(gpio.read(pin2))
    print('3 ft:')
    print(gpio.read(pin3))
    print('4 ft:')
    print(gpio.read(pin4))
    print('5 ft:')
    print(gpio.read(pin5))
end)
