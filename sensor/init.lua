dhtpin = 4;
led2 = 3;
state2 = "ON";
ssid="";
passwd = "";
postToURL = nil;
interval=0;
settings = {};
local fileFound = file.open('settings','r');
if(fileFound ~= nil) then
        local sett = file.readline();
        if(sett~=nil) then
            file.close();
            settings = cjson.decode(sett);
            ssid=settings.ssid;
            passwd = settings.pass;
            if(settings.interval~=nil) then 
                interval=settings.interval;
            end
            if(settings.url~=nil and string.find(settings.url,"http:"))then
                postToURL = settings.url;
            end
            dofile("sensor.lua");
            connect_wifi();
            runServer(); 
        end
else
    dofile("setup.lua");
    runSetup();
end






