local uv = require 'uv'
local path = require 'path'
local v = require 'vips'
local Image = v.Image

local darkbg = {54, 57, 63}

local function quote(o, str)
	local x = uv.hrtime()

	local font_normal = "Whitney Book",

	local text = '<span size="12pt" line_height="1.1" color="#dcddde">' .. str .. '</span>'

	local final = Image.text(text, {
		rgba = true,
		font = font_string,
		fontfile = font_file,
		dpi = 96,})
			:flatten{background = darkbg}
	
	final:write_to_file(path.resolve(o))

	print('quote:', (uv.hrtime()-x)*1e-9)
end

return quote
