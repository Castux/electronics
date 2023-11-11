local function connect_to_wifi(ssid, password, callback)

	local disconnect_ct

	-- Define WiFi station event callbacks
	local wifi_connect_event = function(T)
		print("Connection to AP(" .. T.SSID .. ") established!")
		print("Waiting for IP address...")
		if disconnect_ct ~= nil then disconnect_ct = nil end
	end

	local wifi_got_ip_event = function(T)
		-- Note: Having an IP address does not mean there is internet access!
		-- Internet connectivity can be determined with net.dns.resolve().
		print("Wifi connection is ready! IP address is: " .. T.IP)
		callback()
	end

	local wifi_disconnect_event = function(T)
		if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then
			--the station has disassociated from a previously connected AP
			return
		end

		print("\nWiFi connection to AP(" .. T.SSID .. ") has failed!")

		--There are many possible disconnect reasons, the following iterates through
		--the list and returns the string corresponding to the disconnect reason.
		for key,val in pairs(wifi.eventmon.reason) do
			if val == T.reason then
			  print("Disconnect reason: " .. val .. "(" .. key .. ")")
			  break
			end
		end

		disconnect_ct = (disconnect_ct or 0) + 1
		print("Retrying connection... (attempt " .. disconnect_ct .. ")")
	end

	-- Register WiFi Station event callbacks
	wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wifi_connect_event)
	wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip_event)
	wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_disconnect_event)

	print("Connecting to WiFi access point...")
	wifi.setmode(wifi.STATION)
	wifi.sta.config({ssid = ssid, pwd = password})
end

return connect_to_wifi
