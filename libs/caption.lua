local path = require 'path'
local v = require 'vips'
local uv = require 'uv'
local Image = v.Image
local alpha = require 'alpha'


local function caption(i, o, str, opt)
	local x = uv.hrtime()

	local image, isgif
	if type(i) == "string" then
		isgif = path.extname(i) == '.gif'
		image = Image.new_from_file(path.resolve(i), isgif and {n = -1} or {})
	else
		image = i
	end

	local width = image:width()
	local size = width / 10
	local text_dpi = 600 * (width / 1000)
	local text_width = width - ((width / 25) * 2)

	local font_string = 'futura' 

	-- actual image generation time

	local text = Image.text(str, {
		rgba = true,
		align = 'centre',
		font = font_string,
		dpi = text_dpi,
		width = text_width,
	})

	local caption_image = text:flatten{background = 255}
		:gravity('centre', width, text:height() + size, {
			extend = 'white'
		})

	if alpha.has(image) then caption_image = alpha.add(caption_image) end

	local final
	if isgif then
		local frames = {}

		local page_height = image:get('page-height')
		local pages = image:height() / page_height

		for i = 0, pages-1 do
			local page = image:crop(0, i * page_height, width, page_height)
			table.insert(frames, caption_image:join(page, 'vertical'))
		end

		final = Image.arrayjoin(frames, {across = 1})
		final:set('page-height', page_height + caption_image:height())
	else
		final = caption_image:join(image, 'vertical')
	end
	
	if o then
		final:write_to_file(path.resolve(o), opt)
	else
		return final
	end
	
	print('caption:', (uv.hrtime()-x)*1e-9)
end

return caption
