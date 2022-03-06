local path = require 'path'
local v = require 'vips'
local uv = require 'uv'
local Image = v.Image
local alpha = require 'alpha'

local function caption(i, o, text, opt)
	local x = uv.hrtime()
	
	local img = Image.new_from_file(path.resolve(i))
	

	local width = img:width()
	local size = width / 10
	local text_dpi = 600 * (width / 1000)
	local text_width = width - ((width / 25) * 2)

	local font_string = 'futura'
	local font_path = 'assets/caption.otf'

	local caption_text = text

	local text = Image.text(caption_text, {
		rgba = true,
		align = 'centre',
		font = font_string,
		fontfile = font_path,
		dpi = text_dpi,
		width = text_width,})

	local caption_image = text:flatten{background = 255}
		--:equal{0,0,0,0}:bandand():ifthenelse(255, text)
		:gravity('centre', width, text:height() + size, {
			extend = 'white',})

	
	if alpha.has(img) then
		caption_image = alpha.add(caption_image)
	end

	local final = caption_image
		:join(img, 'vertical')

	
	final:write_to_file(path.resolve(o), opt)

	print('caption:', (uv.hrtime()-x)*1e-9)
end

return caption
