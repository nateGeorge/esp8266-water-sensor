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
            if data == "true" and autoMode then
                turnOffPump()
            end
            lastMsgTime = tmr.now()
        elseif (topic == "wellSystem/tank_empty") then
            if data == "true" and autoMode then
                turnOnPump()
            end
            lastMsgTime = tmr.now()
        elseif (topic == "wellSystem/pump_on") then
            if data == "true" then
                turnOnPump()
                tmr.alarm(4, pumpRuntime, 1, function()
                    turnOffPump()
                end)
            elseif data == "false" then
                turnOffPump()
                tmr.stop(4)
            end
        elseif (topic == "wellSystem/"..user.."/setting/pumpTimeout") then
            pumpTimeout = tonumber(data)
            save_setting('pumpTimeout', pumpTimeout)
            mqtt:publish("wellSystem/"..user,"confirm pumpTimeout "..tostring(pumpTimeout), 0, 0, function(conn) end)
        elseif (topic == "wellSystem/"..user.."/setting/pumpRuntime") then
            pumpRuntime = tonumber(data)
            save_setting('pumpRuntime', pumpRuntime)
            mqtt:publish("wellSystem/"..user,"confirm pumpRuntime "..tostring(pumpRuntime), 0, 0, function(conn) end)
        elseif (topic == "wellSystem/"..user.."/setting/autoMode") then
            autoMode = set_auto(data)
            if (not autoMode) then
                turnOffPump()
            end
            save_setting('autoMode', tostring(autoMode))
            mqtt:publish("wellSystem/"..user,"confirm autoMode "..tostring(autoMode), 0, 0, function(conn) end)
        end
      end
    end)
    
    mqtt:connect("m11.cloudmqtt.com", 19283, 0, function(conn)
      print("connected")
      mqtt:lwt("wellSystem/"..user, "offline", 0, 0)
      -- subscribe all topics starting with wellSystem/ with qos = 0
      mqtt:subscribe("wellSystem/#", 0, function(conn) 
        -- publish a message with data = my_message, QoS = 0, retain = 0
        mqtt:publish("wellSystem/"..user,"online", 0, 0, function(conn)
          print("sent")
          callback()
        end)
      end)
    end)
end

function turnOnPump()
    gpio.write(relayPin, 0)
    mqtt:publish("wellSystem/"..user,"pump on", 0, 0, function(conn) end)
end

function turnOffPump()
    gpio.write(relayPin, 1)
    mqtt:publish("wellSystem/"..user,"pump off", 0, 0, function(conn) end)
    tmr.stop(4)
end

function controlPump()
    print('starting pump control loop')
    tmr.alarm(2, 1000, 1, function()
        if (tmr.now() - lastMsgTime) > pumpTimeout then
            turnOffPump()
        end
        if (wifi.sta.status() ~= 5) then
            tmr.alarm(5, 5000, 0, function() node.restart() end)
        else
            tmr.stop(5)
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

function set_auto(auto)
  if (auto == 'true') then
    return true
  else
    return false
  end
end

if file.open('wellpump_creds') then
    user = string.sub(file.readline(), 1, -2)
    password = string.sub(file.readline(), 1, -2)
    well_full = true
    well_empty = false
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
    if file.open('autoMode') then
        file.close()
        autoMode = set_auto(read_setting('autoMode'))
    else
        autoMode = true
        save_setting('autoMode', tostring(autoMode))
    end
        
    connectMQTT(user, password, controlPump)
end
