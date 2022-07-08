--[[lit-meta
	name = "CoolingTool/Thing"
	version = "0.0.1"
	dependencies = {
		"creationix/coro-http",
		"creationix/coro-fs",
		"luvit/secure-socket",
	}
]]

local uv = require 'uv'
local v = require 'vips'
local http = require 'coro-http'
local fs = require 'coro-fs'
local caption = require 'caption'
local dialog = require 'dialog'
local stitch = require 'stitch'


local avatarForm = 'https://cdn.discordapp.com/avatars/%s.png?size=128'
local emojiForm = 'https://twemoji.maxcdn.com/v/latest/svg/%s.svg'
local circForm = [[
    <svg height="%s" width="%s">
        <circle cx="%s" cy="%s" r="%s" fill="#FFF"/>
    </svg>
]]



local function download(url, size)
    return v.Image.thumbnail_buffer(select(2, http.request("GET", url)), size)
end



local function bro()
    local w, h = 230, 112

    local rsiz = 64

    local link1 = 'https://cdn.discordapp.com/embed/avatars/1.png'
    local link2 = 'https://cdn.discordapp.com/embed/avatars/4.png'

    local ranks = {
        download(emojiForm:format'1f464', rsiz),
        download(emojiForm:format'1f5e3', rsiz),
        download(emojiForm:format'1f465', rsiz),
        download(emojiForm:format'1fac2', rsiz),
    }

    local base = v.Image.black(w, h):copy{interpretation = "srgb"}
    local circ = v.Image.new_from_buffer(circForm:format(h, w, h/2, h/2, h/2))

    local x = uv.hrtime()

    local icon1 = download(link1, h):composite(circ, "dest-in")
    local icon2 = download(link2, h):composite(circ, "dest-in")

    local final = base:insert(icon1, 0, 0)
        :insert(icon2, w - h, 0)
        :composite(ranks[math.random(#ranks)], 'over',
                    {x = w/2 - rsiz/2, y = h/2 - rsiz/2})

    local png = final:pngsave_buffer()

    local path = 'out/bro.png'
    fs.writeFile(path, png)


    print('bro:', (uv.hrtime()-x)*1e-9)
end

local function emote()
    local x = uv.hrtime()

    local svg = download(emojiForm:format'1f9d1-200d-1f373', 1024)
        
    local png = svg:pngsave_buffer()

    local path = 'out/emoji.png'
    fs.writeFile(path, png)

    print('emote:', (uv.hrtime()-x)*1e-9)
end

--stitch('assets/stickers/sup frames', 'out/sup.gif', 48)
--stitch('assets/stickers/cry frames', 'out/cry.gif', 48)
--stitch('assets/stickers/eating frames', 'out/eating.gif', 48)
--stitch('assets/stickers/wave frames', 'out/wave.gif', 48)
--stitch('assets/stickers/wave2 frames', 'out/wave2.gif', 48)
--stitch('assets/stickers/evil frames', 'out/evil.gif', 48)
--stitch('assets/stickers/dnd frames', 'out/dnd.gif', 48)
--stitch('assets/stickers/omw frames', 'out/omw.gif', 48)
--stitch('assets/stickers/dance frames', 'out/dance.gif', 48)
--stitch('assets/stickers/good frames', 'out/good.gif', 48)
stitch('assets/stickers/smirk frames', 'out/smirk.gif', 48)

--dialog('out/dialog.gif', "LISTEN UP! I'M BOTTLES, THE SHORT-SIGHTED MOLE.")

--bro()
--emote()

--caption('out/emoji.png', 'out/captioned.png', 'get cooking mate, better start now')
--caption('assets/steve.jpeg', 'out/steve.jpeg', 'get real and ready and happy', {Q = 75})
--caption('assets/jpg.jpeg', 'out/jpg.jpeg', 'get real and angry and ready', {Q = 50})
--caption('assets/jpg-1.jpeg', 'out/jpg-1.jpeg', 'get real and happy and ready', {Q = 1})
--caption('out/eating.gif', 'out/captioned.gif', 'bigboned', {effort = 1})
--caption('assets/jim.gif', 'out/jim-captioned.gif', "jimmy's lost fruits journey", {effort = 1})
caption('assets/tenor.gif', 'out/tenor-captioned.gif', 'man i hate twitter', {effort = 10, dither = 1})
