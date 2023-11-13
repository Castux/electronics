local config = dofile "config.lua"

local function connect_to_ap(ssid, pwd, cb)
	wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
		print("Connected to " .. T.SSID .. "...")
	end)
	wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
		print("Got IP address: " .. T.IP)
		print("Wifi ready")
		cb()
	end)

	print("Connecting to " .. ssid)
	wifi.sta.config({ssid = ssid, pwd = pwd})
end

local function setup_wifi(cb)
	print("Checking available wifi networks...")

	wifi.setmode(wifi.STATION)
	wifi.sta.getap(nil, nil, function(t)
		for ssid,_ in pairs(t) do
			local pwd = config.wifi[ssid]
			if pwd then
				connect_to_ap(ssid, pwd, cb)
				return
			end
		end

		print("No known networks")
	end)
end

local function loop(delay, func)
	local timer = tmr.create()
	timer:register(delay, tmr.ALARM_SEMI, function()
		func()
		timer:start()
	end)
	func()
	timer:start()

	return function()
		timer:unregister()
	end
end

local led_pin = 4
local led_timer = tmr.create()
local led_val = 1

local stop_blink
local function start_blink()
	gpio.mode(led_pin, gpio.OUTPUT)
	stop_blink = loop(100, function()
		led_val = 1 - led_val
		gpio.write(led_pin, led_val)
	end)
end

local function display_text(text)
	print("Text: " .. text)
end

local function show_message(data)
	local text = data:match("^T:(.*)")
	if text then
		display_text(text)
		return
	end

	local img = data:match("^I:(.*)")
	if img then
		display_image(img)
		return
	end

	print("Invalid data: " .. data)
end

local function get_data()
	http.get(config.url, nil, function(code, data)
		if (code < 0) then
			print("Failed HTTP request to " .. config.url)
		else
			show_message(data)
		end
	end)
end

start_blink()
setup_wifi(function()
	stop_blink()
	loop(60 * 1000, get_data)
end)
