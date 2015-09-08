-- gpio pins 0 and 2 on the esp01 are actually 3 and 4 in nodemcu land

print(waterEmpty)
if waterEmpty==true or waterEmpty==false then
    if waterEmpty then
        print('turning on pump')
        gpio.write(relayPin, gpio.HIGH)
    elseif (waterFull and (gpio.read(relayPin) == gpio.HIGH)) then
        print('turning off pump')
        gpio.write(relayPin, gpio.LOW)
    end
    tmr.stop(1)
end