-- config file whit password 
dofile("config.lua")

wifi.setmode(wifi.STATION)
wifi.sta.config(SSD,PASSWORD)
tmr.delay(1000000)
humi="xx"
temp="xx"
fare="xx"
bimb=1
gpio.mode(led1, gpio.OUTPUT)

--load DHT11 module and read sensor
function ReadDHT11()
    status,temp,humi,temp_decimial,humi_decimial = dht.read(pin)
    fare=((temp*9/5)+32)
end 

function WriteCloud(v1,v2,v3)
   conn=net.createConnection(net.TCP, 0) 
   conn:on("receive", function(conn, payload) send=payload end) 
   conn:connect(80,'184.106.153.149') 
   conn:send("GET /update?key="..api.."&field1="..v1.."&field2="..v2.."&field3="..v3.." HTTP/1.1\r\n") 
   conn:send("Host: api.thingspeak.com\r\n") 
   conn:send("Accept: */*\r\n") 
   conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
   conn:send("\r\n")

end 

ReadDHT11()
WriteCloud(temp,humi,fare)

tmr.alarm(1,60000, 1, function() ReadDHT11() bimb=bimb+1 if bimb==5 then bimb=0 wifi.sta.connect() WriteCloud(temp,humi,fare) print("Reconnect")end end)

srv=net.createServer(net.TCP) srv:listen(80,function(conn)
    conn:on("receive",function(conn,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        local _on,_off = "",""
        if(_GET.pin == "ON1")then
              gpio.write(led1, gpio.HIGH);
        elseif(_GET.pin == "OFF1")then
              gpio.write(led1, gpio.LOW);
        end
        ledstatus=gpio.read(led1)
        if (path == "/json")then
            print ("Json")

        elseif( path == "/setup.html" )then
            print ("setup")

        else 



    conn:send('HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n\
<!DOCTYPE html>\
<html><head><meta charset="utf-8"><meta http-equiv="X-UA-Compatible" content="IE=edge">\
<meta name="viewport" content="width=device-width, initial-scale=1"><meta content="text/html;charset=utf-8">\
<title>Sensor Hub</title>\
<link rel="stylesheet" href="https://storage.googleapis.com/code.getmdl.io/1.0.0/material.indigo-pink.min.css">\
<script src="https://storage.googleapis.com/code.getmdl.io/1.0.0/material.min.js"></script>\
<link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">\
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css">\
<link rel="stylesheet" href="http://moebiusmania.github.io/ESP8266/style.css">\
<script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>\
<script src="http://moebiusmania.github.io/ESP8266/app.js"></script></head>\
<body><div class="demo-grid-2 mdl-grid"><div class="mdl-cell mdl-cell--12-col">\
<h3>Hydrometer with DHT11 sensor</h3></div>\
<div class="mdl-cell mdl-cell--4-col"><div class="mdl-card mdl-shadow--2dp humidity">\
<div class="mdl-card__title"><h2 class="mdl-card__title-text"><span class="fa fa-tint"></span> Humidity</h2>\
</div><div class="mdl-card__supporting-text">\
<p><span class="value">'..humi..'</span>% of relative humidity</p>')
conn:send('</div></div></div>\
<div class="mdl-card mdl-shadow--2dp temperature"><div class="mdl-card__title">\
<h2 class="mdl-card__title-text"><span class="fa fa-sun-o"></span> Temperature</h2>\
</div><div class="mdl-card__supporting-text mdl-grid"><div class="mdl-cell mdl-cell--10-col mdl-cell--3-col-phone">\
<p id="tempCels"><span class="value">'..temp..'</span>C°</p>\
<p id="tempFahr"><span class="value">'..fare..'</span>F°</p>\
</div><div class="mdl-cell mdl-cell--2-col mdl-cell--1-col-phone"><label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="switch-1">\
<input type="checkbox" id="switch-1" class="mdl-switch__input" checked /> <span class="mdl-switch__label"></span>\
</label></div> </div></div></div>')
conn:send('<div class="mdl-cell mdl-cell--4-col"><div class="mdl-card mdl-shadow--2dp device">\
<div class="mdl-card__title"><h2 class="mdl-card__title-text"><span class="fa fa-lightbulb-o"></span> Switch device</h2>\
</div><div class="mdl-card__supporting-text mdl-grid"><div class="mdl-cell mdl-cell--10-col mdl-cell--3-col-phone">\
<p id="devOff"><span class="value">Off</span></p><p id="devOn"><span class="value">On</span></p></div>\
<div class="mdl-cell mdl-cell--2-col mdl-cell--1-col-phone"><label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="switch-2">\
<input data-status="'..ledstatus..'" type="checkbox" id="switch-2" class="mdl-switch__input" /><span class="mdl-switch__label"></span>\
</label></div></div></div></div></div></body></html>')
    conn:on("sent",function(conn) conn:close() end)

     end
    end)

    
end)

