local config = dofile "config.lua"

local function connect_to_ap(ssid, pwd)
	wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
		print("Connected to " .. T.SSID .. "...")
	end)
	wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
		print("Got IP address: " .. T.IP)
	end)

	print("Connecting to " .. ssid)
	wifi.sta.config({ssid = ssid, pwd = pwd})
end

local function setup_wifi()
	print("Checking available wifi networks...")

	wifi.setmode(wifi.STATION)
	wifi.sta.getap(nil, nil, function(t)
		for ssid,_ in pairs(t) do
			local pwd = config.wifi[ssid]
			if pwd then
				connect_to_ap(ssid, pwd)
				break
			end
		end
	end)
end

setup_wifi()
