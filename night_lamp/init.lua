tmr.create():alarm(3000, tmr.ALARM_SINGLE, function()
	print "Delaying 3 sec. before running"
	dofile "main.lua"
end)
