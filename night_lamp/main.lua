local config = dofile "config.lua"
local connect_to_wifi = dofile "wifi.lua"
local run_clock = dofile "clock.lua"

connect_to_wifi(config.ssid, config.password, function()

	sntp.sync()
	run_clock()
end)
