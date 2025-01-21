local disp

local sda = 5 -- GPIO14
local scl = 6 -- GPIO12
local sla = 0x3c


local OLED_CONTROL_BYTE_CMD_SINGLE = 0x80
local OLED_CONTROL_BYTE_CMD_STREAM = 0x00
local OLED_CONTROL_BYTE_DATA_STREAM = 0x40

-- Fundamental commands (pg.28)
local OLED_CMD_SET_CONTRAST = 0x81	-- follow with 0x7F
local OLED_CMD_DISPLAY_RAM = 0xA4
local OLED_CMD_DISPLAY_ALLON = 0xA5
local OLED_CMD_DISPLAY_NORMAL = 0xA6
local OLED_CMD_DISPLAY_INVERTED = 0xA7
local OLED_CMD_DISPLAY_OFF = 0xAE
local OLED_CMD_DISPLAY_ON = 0xAF

-- Addressing Command Table (pg.30)
local OLED_CMD_SET_MEMORY_ADDR_MODE = 0x20	-- follow with 0x00 = HORZ mode = Behave like a KS108 graphic LCD
local OLED_CMD_SET_COLUMN_RANGE = 0x21	-- can be used only in HORZ/VERT mode - follow with 0x00 + 0x7F = COL127
local OLED_CMD_SET_PAGE_RANGE = 0x22	-- can be used only in HORZ/VERT mode - follow with 0x00 + 0x07 = PAGE7

-- Hardware Config (pg.31)
local OLED_CMD_SET_DISPLAY_START_LINE = 0x40
local OLED_CMD_SET_SEGMENT_REMAP = 0xA1
local OLED_CMD_SET_MUX_RATIO = 0xA8	-- follow with 0x3F = 64 MUX
local OLED_CMD_SET_COM_SCAN_MODE = 0xC8
local OLED_CMD_SET_DISPLAY_OFFSET = 0xD3	-- follow with 0x00
local OLED_CMD_SET_COM_PIN_MAP = 0xDA	-- follow with 0x12

-- Timing and Driving Scheme (pg.32)
local OLED_CMD_SET_DISPLAY_CLK_DIV = 0xD5	-- follow with 0x80
local OLED_CMD_SET_PRECHARGE = 0xD9	-- follow with 0x22
local OLED_CMD_SET_VCOMH_DESELCT = 0xDB	-- follow with 0x30

-- Charge Pump (pg.62)
local OLED_CMD_SET_CHARGE_PUMP = 0x8D	-- follow with 0x14

-- NOP
local OLED_CMD_NOP = 0xE3


local Wire = {

	begin = function()
		i2c.start(0)
		i2c.address(0, sla, i2c.TRANSMITTER)
	end,

	write = function(...)
		i2c.write(0, ...)
	end,

	endTransmission = function()
		i2c.stop(0)
	end
}

function OLED_init()

	Wire.begin();

	-- Tell the SSD1306 that a command stream is incoming
	Wire.write(OLED_CONTROL_BYTE_CMD_STREAM);

	Wire.write(0x0ae)		                -- display off */
	Wire.write(0x0d5, 0x0F0)		-- clock divide ratio (0x00=1) and oscillator frequency (0x8) */
	Wire.write(0x0a8, 0x03f)		-- multiplex ratio */
	Wire.write(0x0d3, 0x000)		-- display offset */
	Wire.write(0x040)		                -- set display start line to 0 */
	Wire.write(0x08d, 0x014)		-- [2] charge pump setting (p62): 0x014 enable, 0x010 disable, SSD1306 only, should be removed for SH1106 */
	Wire.write(0x020, 0x000)		-- horizontal addressing mode */

	Wire.write(0x0a1)				-- segment remap a0/a1*/
	Wire.write(0x0c8)				-- c0: scan dir normal, c8: reverse */
	-- Flipmode
	-- Wire.write(0x0a0)				-- segment remap a0/a1*/
	-- Wire.write(0x0c0)				-- c0: scan dir normal, c8: reverse */

	Wire.write(0x0da, 0x012)		-- com pin HW config, sequential com pin config (bit 4) disable left/right remap (bit 5) */

	Wire.write(0x081, 0x0cf) 		-- [2] set contrast control */
	Wire.write(0x0d9, 0x0f1) 		-- [2] pre-charge period 0x022/f1*/
	Wire.write(0x0db, 0x040) 		-- vcomh deselect level */
	-- if vcomh is 0, then this will give the biggest range for contrast control issue #98
	-- restored the old values for the noname constructor, because vcomh=0 will not work for all OLEDs, #116

	Wire.write(0x02e)				-- Deactivate scroll */
	Wire.write(0x0a4)				-- output ram to display */
	Wire.write(0x0a6)				-- none inverted normal display mode */
	Wire.write(0x0af)		                -- display on */

	-- End the I2C comm with the SSD1306
	Wire.endTransmission();

end

local f = 0
function loop()

	Wire.begin()
	Wire.write(OLED_CONTROL_BYTE_CMD_STREAM);
	Wire.write(OLED_CMD_SET_COLUMN_RANGE);
	Wire.write(0x00);
	Wire.write(0x7F);
	Wire.write(OLED_CMD_SET_PAGE_RANGE);
	Wire.write(0);
	Wire.write(0x07);
	Wire.endTransmission();

	Wire.begin();
	Wire.write(OLED_CONTROL_BYTE_DATA_STREAM)
	for i = 1,1024 do
		Wire.write(f)
	end
	Wire.endTransmission();

	f = (f == 0x00) and 0xff or 0x00

	loop_tmr:start()
end


function main()

	i2c.setup(0, sda, scl, i2c.FASTPLUS)

	OLED_init()

	loop_tmr = tmr.create()
	loop_tmr:register(1, tmr.ALARM_SEMI, loop)

	loop_tmr:start()

end

main()
