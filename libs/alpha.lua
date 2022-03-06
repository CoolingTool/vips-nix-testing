local v = require 'vips'
local ffi = require 'ffi'

ffi.cdef [[
	int vips_image_hasalpha(VipsImage *image);
]]

local vips_lib
if ffi.os == "Windows" then
    vips_lib = ffi.load("libvips-42.dll")
else
    vips_lib = ffi.load("vips")
end

local function call_for_bool(self, vips_lib_func)
    local result = vips_lib_func(self.vimage)
    if result == nil then
        error(verror.get())
    end

    return result ~= 0
end

local function hasalpha(self)
    return call_for_bool(self, vips_lib.vips_image_hasalpha)
end

local function addalpha(self)
    local max_alpha

    if self:interpretation() == "rgb16" or
        self:interpretation() == "grey16" then
        max_alpha = 65535
    else
        max_alpha = 255
    end

    return self:bandjoin(max_alpha)
end

local function removealpha(self)
	return self:flatten()
end

return {
	has = hasalpha,
	add = addalpha,
	remove = removealpha,
}