local path = require 'path'
local v = require 'vips'
local uv = require 'uv'
local alpha = require 'alpha'
local Image = v.Image

local darkbg = {54, 57, 63}

local function dialog(o, text)
	local x = uv.hrtime()
	
	local width = 480
	
	local font_string = 'CCComicrazy-Regular'
	local font_path = 'assets/dialog.ttf'

	local frames = {}

	for po in utf8.codes(text) do
		local dialog_text
		if #text ~= po then
			local vis = text:sub(1, po)
			local invis = text:sub(utf8.offset(text,po,2))
	
			dialog_text = '<span foreground="white">' .. vis .. '<span alpha="1">' .. invis .. '</span></span>'
		else
			dialog_text = '<span foreground="white">' .. text .. '</span>'
		end

		local text = Image.text(dialog_text, {
			rgba = true,
			font = font_string,
			fontfile = font_path,
			dpi = 175,
			width = width,})


		table.insert(frames, text)
	end

	-- join together frames with fake antialias
	local joined = Image.arrayjoin(frames, {across = 1})
		:flatten{background = darkbg}
	local final = joined:equal(darkbg):bandand()
		:ifthenelse({0,0,0,0},alpha.add(joined))
	
	final:set_type(24ULL, "page-height", frames[1]:height())
	
	final:write_to_file(path.resolve(o))

	print('dialog:', (uv.hrtime()-x)*1e-9)
end

return dialog
