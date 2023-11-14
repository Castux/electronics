local config = dofile "config.lua"

local disp
local function init_i2c_display()
	i2c.setup(0, config.sda, config.scl, i2c.FASTPLUS)

	disp = u8g2.ssd1306_i2c_128x64_noname(0, config.sla)
	disp:setFont(u8g2.font_6x10_tf)
	disp:setFontRefHeightExtendedText()
	disp:setFontPosTop()
	disp:setFontDirection(0)
end

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

local function write_wrap(str)

	for i = 1,#str do
		local row = math.floor((i - 1) / 18)
		local col = (i - 1) % 18
		disp:drawStr(col * 7, row * 10, str:sub(i,i))
	end
end

local function decode_image(data)
	local bytes = {}
	data:gsub("..", function(s) table.insert(bytes, string.char(tonumber(x, 16))) end)
	return table.concat(bytes)
end

local function show_message(data)

	disp:clearBuffer()

	local text = data:match("^T:(.*)")
	local img = data:match("^I:(.*)")

	if text then
		write_wrap(text)
	elseif img then
		disp:drawXBM(0, 0, decode_image(img))
	else
		disp:drawStr(1, 1, ":'(")
	end

	disp:updateDisplay()
end

local function get_data()
	http.get(config.url, nil, function(code, data)
		if (code < 0) then
			print("Failed HTTP request to " .. config.url)
			disp:clearBuffer()
			disp:drawStr(":(")
			disp:updateDisplay()
		else
			show_message(data)
		end
	end)
end

local function main()

	init_i2c_display()
	disp:drawStr(1, 1, "Setting up wifi...")
	disp:updateDisplay()

	start_blink()
	setup_wifi(function()
		stop_blink()
		loop(10 * 1000, get_data)
	end)

end

main()
