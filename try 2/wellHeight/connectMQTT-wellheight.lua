function connectMQTT(user, password, callback)
    mqtt = mqtt.Client("jsf_tank", 1200, user, password) -- 20 min keepalive
    
    mqtt:on("connect", function(con) print ("connected") end)
    mqtt:on("offline", function(con) 
        print ("offline")
        node.restart()
    end)
    
    -- on receive message
    mqtt:on("message", function(conn, topic, data)
      if data ~= nil then
        print(topic .. ":" )
        print(data)
        if (topic == "wellSystem/"..user.."/setting/shortSleepTime") then
            shortSleepTime = tonumber(data)
            save_setting('shortSleepTime', shortSleepTime)
            mqtt:publish("wellSystem/"..user,"confirm shortSleepTime "..
            data, 0, 0, function(conn) end)
        elseif (topic == "wellSystem/"..user.."/setting/longSleepTime") then
            longSleepTime = tonumber(data)
            save_setting('longSleepTime', longSleepTime)
            mqtt:publish("wellSystem/"..user,"confirm longSleepTime "..
            data, 0, 0, function(conn) end)
        end
      end
    end)
    
    mqtt:connect("m11.cloudmqtt.com", 19283, 0, function(conn) 
      print("connected")
      mqtt:lwt("wellSystem/"..user, "offline", 0, 0)
      -- subscribe topic with qos = 0
      mqtt:subscribe("wellSystem/#", 0, function(conn) 
          -- report that we are online, wait for any setpoint changes
          mqtt:publish("wellSystem/"..user,"online", 0, 0, function(conn) 
          print("sent")
          end)
          tmr.alarm(3, 5000, 0, function() callback() end) -- wait for a few seconds to recieve settings
      end)
    end)
end

function checkHeight()
    print('checking water height')
    if gpio.read(emptyPin) == 1 then
        print('tank empty')
        -- publish a message with data = my_message, QoS = 0, retain = 0
        mqtt:publish("wellSystem/tank_empty","true",0,0, function(conn) 
          print("sent")
          end)
    else
          print('tank not empty')
          mqtt:publish("wellSystem/tank_empty","false",0,0, function(conn) 
          print("sent")
          end)
    end
    
    if gpio.read(fullPin) == 0 then
        print('tank full')
        -- publish a message with data = my_message, QoS = 0, retain = 0
        mqtt:publish("wellSystem/tank_full","true",0,0, function(conn)
          print("sent")
          sleepTime = longSleepTime
          end)
    else
          print('tank not full')
          mqtt:publish("wellSystem/tank_full","false",0,0, function(conn)
          print("sent")
          sleepTime = shortSleepTime
          end)
    end
    mqtt:publish("wellSystem/"..user,"offline",0,0, function(conn) 
          print("sent")
    end)
    tmr.alarm(1, 5000, 0, function()
        node.dsleep(sleepTime)
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

if file.open('wellheight_creds') then
    user = string.sub(file.readline(), 1, -2) -- get rid of newline at EOL
    password = string.sub(file.readline(), 1, -2)
    file.close()
    emptyPin = 1
    fullPin = 2
    gpio.mode(emptyPin, gpio.INPUT, gpio.PULLUP)
    gpio.mode(fullPin, gpio.INPUT, gpio.PULLUP)
    if file.open('longSleepTime') then
        file.close()
        sleepTime = tonumber(read_setting('longSleepTime'))
    else
        longSleepTime = 10*1000*1000 -- sleep for 10s
        save_setting('longSleepTime', longSleepTime)
    end
    if file.open('shortSleepTime') then
        file.close()
        sleepTime = tonumber(read_setting('shortSleepTime'))
    else
        shortSleepTime = 5*1000*1000 -- sleep for 10s
        save_setting('shortSleepTime',shortSleepTime)
    end
    connectMQTT(user, password, checkHeight)
end
