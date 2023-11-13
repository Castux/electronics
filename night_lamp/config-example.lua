local images = dofile "images.lua"

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

	times = {
--		{from = "00:00", image = images.sleeping, color = {0.7,0,0}},
		{from = "07:00", image = images.waking, color = {1,0.5,0}},
		{from = "07:45", image = images.awake, color = {0.2,1,0}},
		{from = "20:00", image = images.sleeping, color = {0.7,0,0}}
	}
}
