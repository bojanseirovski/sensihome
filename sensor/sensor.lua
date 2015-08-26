ipAddr = "";
theIpNumbers = "";
thisId=node.chipid();
gpio.mode(led2, gpio.OUTPUT);
gpio.write(led2, gpio.LOW);

function connect_wifi()
   wifi.setmode(wifi.STATION);
   wifi.sta.config(ssid,passwd);
   tmr.alarm (1, 1000, 1, function ()
      if wifi.sta.getip() == nil then
         print ("Connecting...");
      else
          ipAddr = ""..wifi.sta.getip ();
          local ip1,ip2,ip3,ip4 = string.match(ipAddr,'(.+)%.(.+)%.(.+)%.(.+)');
          theIpNumbers = ip1..ip2..ip3..ip4;
          print("Done: "..ipAddr);
         tmr.stop (1);
      end
   end)
end

function opositeState(state)
     if(state=="OFF") then
          return "ON"
     else
          return "OFF"
     end
end
Temperature = 0;
lastCheck = tmr.time();

function runServer()
     srv=net.createServer(net.TCP)
     srv:listen(80,function(conn)
          conn:on("receive", function(client,request)
               theTime = tmr.time();
               local buf = "";
               local blah , tempTemp, hum = dht.read(dhtpin);
               if(string.find(request,"pin2\/ON")) then
                    state2 = "OFF"; 
                    gpio.write(led2, gpio.HIGH);
               end
               if(string.find(request,"pin2\/OFF")) then
                    state2 = "ON";
                    gpio.write(led2, gpio.LOW);
               end
               if(string.find(request,"node\/RESET")) then
                file.remove("settings");
                node.restart();
               end
               if(not string.find(request,"reqtype\/json")) then
                    buf = buf.."<html><body>";
                    buf = buf.."<h2> Remote switch with temperature sensor - SensiHome :</h2>";
                    buf = buf.."<hr/>";
                    buf = buf.."<p>Temperature : "..tempTemp.." &deg; C</p>";
                    buf = buf.."<p>Humidity : "..hum.." % </p>";
                    buf = buf.."<p>Switch : Turn it <a href=\"\/id\/"..thisId.."\/pin2\/"..state2.."\">"..state2.."</a></p>";
                    buf = buf.."</body></html>";
               end
               if(string.find(request,"reqtype\/json")) then 
                    buf = {temperature=tempTemp, humidity=hum , pin2=opositeState(state2), id=thisId,status="OK" };
                    buf = cjson.encode(buf);
               end

               if(string.find(request,"register\/WEB")) then
                    if(string.find(request,"ip\/"..theIpNumbers)) then
                         buf={id=thisId,dev_type="H" , type_name="Sensor, temperature, humidity; Actuator, switch",status="OK",value_fields="pin1" };
                         buf = cjson.encode(buf);
                         client:send(buf);
                         client:close();
                    else
                         buf = {status="ERROR"};
                         buf = cjson.encode(buf);
                    end
               end

               if(not string.find(request,"id\/"..thisId) and not string.find(request,"register\/WEB")) then 
                    buf = {status="ERROR"};
                    buf = cjson.encode(buf);
               end               
               
               client:send(buf);
               client:close();
               collectgarbage("collect");
          end)
     end)     
end
