local path = require 'path'
local fs = require 'fs'
local v = require 'vips'
local uv = require 'uv'
local alpha = require 'alpha'
local Image = v.Image
local g = v.gvalue

local darkbg = {54, 57, 63}

local function fpstodelay(fps, pages)
	local delay = 1 / fps * 1000
	local round = math.ceil(delay - .5)
	local delays = {}
	for _=1, pages do table.insert(delays, round) end
	return delays
end

local function stitch(i, o, fps)
	local x = uv.hrtime()
	
	local frames = {}

	for f, t in fs.scandirSync(path.resolve(i)) do
		if t == 'file' then
			local img = Image.new_from_file(path.join((path.resolve(i)),f))
			table.insert(frames, img)
		end
	end

	-- join together frames with fake antialias
	local joined = Image.arrayjoin(frames, {across = 1})
		:flatten{background = darkbg}
	local final = joined:equal(darkbg):bandand()
		:ifthenelse({0,0,0,0},alpha.add(joined))
	
	local page_height = frames[1]:height()
	local join_height = final:height()
	local pages = join_height / page_height

	final:set_type(g.gint_type, "page-height", page_height)
	final:set_type(g.array_int_type, "delay", fpstodelay(fps, pages))
	
	final:write_to_file(path.resolve(o), {effort = 10, dither = 0})

	print('stitch:', (uv.hrtime()-x)*1e-9)
end

return stitch
