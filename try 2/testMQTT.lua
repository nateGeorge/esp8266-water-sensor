function connectMQTT(user, password)    
    mqtt = mqtt.Client("jsf_pump", 120, user, password)
    
    mqtt:on("connect", function(con) print ("connected") end)
    mqtt:on("offline", function(con) print ("offline") end)
    
    -- on receive message
    mqtt:on("message", function(conn, topic, data)
      print(topic .. ":" )
      if data ~= nil then
        print(data)
      end
    end)
    
    mqtt:connect("m11.cloudmqtt.com", 19283, 0, function(conn) 
      print("connected")
      -- subscribe topic with qos = 0
      mqtt:subscribe("wellSystem/#", 0, function(conn) 
        -- publish a message with data = my_message, QoS = 0, retain = 0
        mqtt:publish("wellSystem/pump_on","false",0,0, function(conn) 
          print("sent")
        end)
      end)
    end)
end


if file.open('wellpump_creds') then
    user = string.sub(file.readline(),1,-2)
    password = string.sub(file.readline(),1,-2)
    connectMQTT(user, password)
end