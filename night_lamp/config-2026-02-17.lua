local images = dofile "images.lua"

local golden = {1,0.5,0}
local cyan = {0,0.5,0.5}
local purple = {0.25,0,0.5}

local weekday = {
	{from = "06:40", image = images.waking, color = golden},
	{from = "06:45", image = images.awake, color = cyan},
	{from = "20:00", image = images.sleeping, color = purple}
}

local weekend = {
	{from = "07:00", image = images.waking, color = golden},
	{from = "08:00", image = images.awake, color = cyan},
	{from = "20:00", image = images.sleeping, color = purple}
}

return {
	ssid = "Molybdenum",
	password = "AtomicNumber42!",
	timezone = 3,

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
