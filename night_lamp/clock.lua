local config = dofile "config.lua"

local function init_led()
	pwm.setup(config.pin_r, 100, 0)
	pwm.setup(config.pin_g, 100, 0)
	pwm.setup(config.pin_b, 100, 0)

	pwm.start(config.pin_r)
	pwm.start(config.pin_g)
	pwm.start(config.pin_b)
end

local function set_led_immediate(r,g,b)
	pwm.setduty(config.pin_r, (1-r) * 1023)
	pwm.setduty(config.pin_g, (1-g) * 1023)
	pwm.setduty(config.pin_b, (1-b) * 1023)
end

local current_r, current_g, current_b = 0,0,0

local function triangle(x)
	return math.abs(0.5 - x % 1) * 2
end

local function update_led()
	local sec, usec = rtctime.get()
	local t = sec + usec / 1000000

	local mod = 1 - triangle(t / 4) * 0.5

	set_led_immediate(current_r * mod, current_g * mod, current_b * mod)
end

function set_led(r,g,b)
	current_r, current_g, current_b = r,g,b
end

local function init_i2c_display()
	i2c.setup(0, config.sda, config.scl, i2c.FASTPLUS)
	return u8g2.ssd1306_i2c_128x64_noname(0, config.sla)
end

local function setup_draw(disp)
	disp:setFont(u8g2.font_6x10_tf)
	disp:setFontRefHeightExtendedText()
	disp:setFontPosTop()
	disp:setFontDirection(0)
end

local function get_time()
	local tz_offset = config.timezone * 3600
	local tm = rtctime.epoch2cal(rtctime.get() + tz_offset)
	return string.format("%02d:%02d", tm.hour, tm.min), tm.wday
end

local function get_image_color(time, day)
	local t = config.times[day]

	for i = 1, #t-1 do
		if time >= t[i].from and time < t[i+1].from then
			return t[i].image, t[i].color
		end
	end

	return t[#t].image, t[#t].color
end

local last_time
local function update_clock(disp)

	local time, day = get_time()
	if time == last_time then
		return
	end
	last_time = time

	local image, color = get_image_color(time, day)

	if color then
		set_led(color[1], color[2], color[3])
	else
		set_led(1,1,1)
	end

	disp:clearBuffer()

	if image then
		disp:setDrawColor(1)
		disp:drawXBM(0, 0, 128, 64, image)
	end

	disp:setDrawColor(0)
	disp:drawBox(0, 0, 6*5 + 2, 10 + 2)

	disp:setDrawColor(1)
	disp:drawStr(1, 1, image and time or "??:??")

	disp:updateDisplay()

	if time == "12:00" then
		sntp.sync()
	end
end

local function loop(func, interval)
	local timer = tmr.create()
	timer:register(interval, tmr.ALARM_SEMI, function()
		func()
		timer:start()
	end)
	timer:start()
	func()
end

local function run_clock()

	init_led()
	loop(update_led, 10)

	local disp = init_i2c_display()
	setup_draw(disp)
	loop(function() update_clock(disp) end, 1000)
end

return run_clock
