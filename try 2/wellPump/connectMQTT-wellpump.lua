function connectMQTT(user, password, callback)
    mqtt = mqtt.Client("jsf_pump", 1200, user, password) -- 20 min keepalive
    
    mqtt:on("connect", function(con) print ("connected") end)
    mqtt:on("offline", function(con)
        print ("offline")
        node.restart()
    end)
    
    -- on receive message
    mqtt:on("message", function(conn, topic, data)
      print('heap: '..tostring(node.heap()))
      if data ~= nil then
        print(topic .. ":" )
        print(data)
        if (topic == "wellSystem/tank_full") then
            if data == "true" then
                gpio.write(relayPin, 0)
            end
            lastMsgTime = tmr.now()
        elseif (topic == "wellSystem/tank_empty") then
            if data == "true" then
                gpio.write(relayPin, 1)
            end
            lastMsgTime = tmr.now()
        elseif (topic == "wellSystem/pump_on") then
            if data == "true" then
                gpio.write(relayPin, 1)
                tmr.alarm(4, pumpRuntime, 1, function() gpio.write(relayPin, 0) end)
            elseif data == "false" then
                gpio.write(relayPin, 0)
            end
            lastMsgTime = tmr.now()
        elseif (topic == "wellSystem/"..user.."/setting/pumpTimeout") then
            pumpTimeout = tonumber(data)
            save_setting('pumpTimeout', pumpTimeout)
        elseif (topic == "wellSystem/"..user.."/setting/pumpRuntime") then
            pumpRuntime = tonumber(data)
            save_setting('pumpRuntime', pumpRuntime)
        end
      end
    end)
    
    mqtt:connect("m11.cloudmqtt.com", 19283, 0, function(conn)
      print("connected")
      mqtt:lwt("wellSystem/"..user, "offline", 0, 0)
      -- subscribe all topics starting with wellSystem/ with qos = 0
      mqtt:subscribe("wellSystem/#", 0, function(conn) 
        -- publish a message with data = my_message, QoS = 0, retain = 0
        mqtt:publish("wellSystem/"..user,"online",0,0, function(conn) 
          print("sent")
          callback()
        end)
      end)
    end)
end

function controlPump()
    print('starting pump control loop')
    tmr.alarm(2, 1000, 1, function()
        if (tmr.now() - lastMsgTime) > pumpTimeout then
            gpio.write(relayPin, 0)
        end
    end)
end

function save_setting(name,value)
  file.open(name, 'w')
  file.writeline(value)
  file.close()
end

function read_setting(name)
  file.open(name)
  result = string.sub(file.readline(value), 1, -2) -- to remove newline character
  file.close()
  return result
end

if file.open('wellpump_creds') then
    user = string.sub(file.readline(), 1, -2)
    password = string.sub(file.readline(), 1, -2)
    well_full = true
    well_empty = false
    relayPin = 1
    gpio.mode(relayPin, gpio.OUTPUT)
    gpio.write(1, 0)
    lastMsgTime = 0

    -- setup settings
    if file.open('pumpTimeout') then
        file.close()
        pumpTimeout = tonumber(read_setting('pumpTimeout'))
    else
        pumpTimeout = 11*60*1000*1000 -- 11 minute timeout, if no message recieved from water height, shut off pump
        save_setting('pumpTimeout', pumpTimeout)
    end
    if file.open('pumpRuntime') then
        file.close()
        pumpRuntime = tonumber(read_setting('pumpRuntime'))
    else
        pumpRuntime = 15*60*1000*1000 -- 15 minute default pump runtime when manually turned on
        save_setting('pumpRuntime', pumpRuntime)
    end
        
    connectMQTT(user, password, controlPump)
end
