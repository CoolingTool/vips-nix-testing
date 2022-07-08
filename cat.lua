local path = require 'path'
local flr = math.floor
local v = require 'vips'
local Image = v.Image
local caption = require 'caption'

local function plural(n, word)
	return n .. word .. (n ~= 1 and 's' or '')
end

local cat = Image.new_from_file(path.resolve("assets/cat.light.gif"), {n = -1})
local cat_frames = {}

local cat_width = cat:width()
local cat_page_height = cat:get('page-height')
local cat_pages = cat:height() / cat_page_height
local cat_delay = cat:get("delay")[1] / 1000
for i = 0, cat_pages-1 do
	local page = cat:crop(0, i * cat_page_height, cat_width, cat_page_height)
	table.insert(cat_frames, page)
end

local n_frames = (#cat_frames-1)*10

-- 47 hours, 38 minutes, and 12 seconds
--local remaining = 47*60*60 + 38*60 + 13 - cat_delay

--version that actually ends
local remaining = n_frames * cat_delay

local frames = {}
local new_page_height
for i = 0, n_frames do
 	remaining = math.max(0, remaining - cat_delay)
	local cat_frame = cat_frames[(i%#cat_frames)+1]
	local new_frame = caption(cat_frame, nil, 
		'Your mother will\n' ..
		'explode in ' .. --plural(flr(remaining/3600),' hour') .. ',\n' ..
		plural(flr(remaining/60%60),' minute') .. ', and ' .. plural(flr(remaining % 60),' second')
 	)
 	if not new_page_height then new_page_height = new_frame:height() end
 	table.insert(frames, new_frame)
end

final = Image.arrayjoin(frames, {across = 1})
final:set('page-height', new_page_height)
final:set('loop', 1)
		
final:write_to_file(path.resolve("test2.gif"), {dither = 1, effort = 10})
