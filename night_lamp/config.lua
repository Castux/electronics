local images = dofile "images.lua"

return {
	ssid = "XXX",
	password = "XXX",
	timezone = 2,

	-- RGB led
	pin_r = 5,
	pin_g = 6,
	pin_b = 7,

	-- I2C display
	scl = 1,
	sda = 2,
	sla = 0x3c,

	times = {
		{from = "00:00", to = "07:00", image = images.sleeping, color = {0.7,0,0}},
		{from = "07:00", to = "07:30", image = images.waking, color = {1,0.5,0}},
		{from = "07:30", to = "20:00", image = images.awake, color = {0.2,1,0}},
		{from = "20:00", to = "24:00", image = images.sleeping, color = {0.7,0,0}}
	}
}
