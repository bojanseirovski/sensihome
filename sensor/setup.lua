ipAddr = "192.168.1.1";
thisId=node.chipid();
cgi = {};
function unescape (s)
      s = string.gsub(s, "+", " ");
      s = string.gsub(s, "%%(%x%x)", function (h)
            return string.char(tonumber(h, 16));
          end)
      return s;
end
function decode (s)
      for name, value in string.gfind(s, "([^&=]+)=([^&=]+)") do
        name = unescape(name);
        value = unescape(value);
        cgi[name] = value;
      end
end

function runSetup()
     cfg={};
     cfg.ssid="sensi"..thisId;
     cfg.pwd="12345678";
     wifi.ap.config(cfg);
     cfg={};
     cfg.ip=ipAddr;
     cfg.netmask="255.255.255.0";
     cfg.gateway="192.168.1.1";
     wifi.ap.setip(cfg);
     wifi.setmode(wifi.SOFTAP);
     print("WiFi AP");
     srv=net.createServer(net.TCP);
     print("server created");
     srv:listen(80,function(conn)
          conn:on("receive", function(client,request)
               local pass = "123456789";
               local ssid = "sensi"..thisId ;
               local pingUrl = "";
               local pingInterval = 360;
               if(string.find(request,"POST"))then
                decode(request);
               if(cgi.passwd ~=nil) then
                    pass = cgi.passwd;
               end
               if(cgi.ssid ~=nil) then
                    ssid = cgi.ssid;
               end
               if(cgi.url ~=nil) then
                    pingUrl = cgi.url;
               end
               if(cgi.interval ~= nil) then
                    pingInterval = cgi.interval;
               end
               
               end
             
               local buf = "";
               buf = buf.."<html><body>";
               buf = buf.."<h2> SensiHome node - Setup :"..thisId.."</h2>";
               buf = buf.."<h2> "..ipAddr.."</h2>";
               buf = buf.."<hr>";
               buf = buf.."<form method=\"POST\">";
               buf = buf.."<input type=\"hidden\" name=\"id\" value=\""..thisId.."\">";
               buf = buf.."<p>SSID :<input type=\"text\" name=\"ssid\" value=\""..ssid.."\"></p>";
               buf = buf.."<p>Password : <input type=\"text\" name=\"passwd\" value=\""..pass.."\"></p>";
               buf = buf.."<p>POST to URL:<input type=\"text\" name=\"url\" value=\""..pingUrl.."\"></p>";
               buf = buf.."<p>POST interval:<input type=\"text\" name=\"interval\" value=\""..pingInterval.."\"></p>";
               buf = buf.."<input type=\"submit\" name=\"saveit\" value=\"Go\">";
               buf = buf.."</form>";
               buf = buf.."</body></html>";
               client:send(buf);
               client:close();
               
               if(string.find(request,"POST")) then
                    file.open("settings", "w+");
                    local savetable = {id=thisId,ssid=ssid,pass=pass,url=pingUrl,interval=pingInterval};
                    local toSave = cjson.encode(savetable);
                    file.write(toSave);
                    file.close();
                    node.restart()
               end
               collectgarbage();
               
          end)
     end)
end
