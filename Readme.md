Sensihome 

Sensihome is a project - LUA appliacation running on the ES8266 platform 
on top of NodeMCU.
It is a simple application present data from any ESP8266 compatible sensor and it also allows the 
end user to control the pins(if set as I/O pins) on easch ESP8266 node.

The LUA nodes are standalone and have a setup section and a stand-alone data acquisition 
section with a presentational option. These are separated in 2 LUA files : setup.lua and sensor.lua.

The sensor.lua will output data from a DHT-11 temperature + humidity sensor connected on 
PIN 4(GPIO2) and controlls the state of the GPIO0 pin (3).

Programming the ESP8266 
-----------------------

http://randomnerdtutorials.com/esp8266-web-server/


Custom build NodeMCU firmware
---------------------------------------
http://frightanic.com/nodemcu-custom-build/



