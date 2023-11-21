local images = dofile "images.lua"

local weekday = {
	{from = "07:00", image = images.waking, color = {1,0.5,0}},
	{from = "07:20", image = images.awake, color = {0.2,1,0}},
	{from = "20:00", image = images.sleeping, color = {0.7,0,0}}
}

local weekend = {
	{from = "07:00", image = images.waking, color = {1,0.5,0}},
	{from = "08:00", image = images.awake, color = {0.2,1,0}},
	{from = "20:00", image = images.sleeping, color = {0.7,0,0}}
}

return {
	ssid = "SSID",
	password = "PASSWORD",
	timezone = 2,

	-- RGB led
	pin_r = 3,
	pin_g = 1,
	pin_b = 2,

	-- I2C display
	scl = 6,
	sda = 5,
	sla = 0x3c,

	-- 1 is Sunday
	times = {
		[1] = weekend,
		[2] = weekday,
		[3] = weekday,
		[4] = weekday,
		[5] = weekday,
		[6] = weekday,
		[7] = weekend
	}
}
