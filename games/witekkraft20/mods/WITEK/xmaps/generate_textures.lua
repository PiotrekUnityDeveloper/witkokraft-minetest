dofile("../tga_encoder/init.lua")

local _ = { 1 }
local K = { 0 }
local W = { 255 }

local pixels = {
	{ _, K, K, K, K, K, _ },
	{ _, K, W, W, W, K, _ },
	{ K, K, W, W, W, K, K },
	{ K, W, W, W, W, W, K },
	{ _, K, W, W, W, K, _ },
	{ _, _, K, W, K, _, _ },
	{ _, _, _, K, _, _, _ },
}
tga_encoder.image(pixels):save("textures/xmaps_arrow.tga")

local pixels = {
	{ _, _, _, _, K, _, _ },
	{ K, K, _, K, W, K, _ },
	{ K, W, K, W, W, W, K },
	{ K, W, W, W, W, K, _ },
	{ K, W, W, W, K, _, _ },
	{ K, W, W, W, W, K, _ },
	{ K, K, K, K, K, K, _ },
}
tga_encoder.image(pixels):save("textures/xmaps_arrow_diagonal.tga")

local pixels = {
	{ _, _, K, K, K, _, _ },
	{ _, K, W, W, W, K, _ },
	{ K, W, W, W, W, W, K },
	{ K, W, W, W, W, W, K },
	{ K, W, W, W, W, W, K },
	{ _, K, W, W, W, K, _ },
	{ _, _, K, K, K, _, _ },
}
tga_encoder.image(pixels):save("textures/xmaps_dot_large.tga")

local pixels = {
	{ _, _, _, _, _, _, _ },
	{ _, _, K, K, K, _, _ },
	{ _, K, W, W, W, K, _ },
	{ _, K, W, W, W, K, _ },
	{ _, K, W, W, W, K, _ },
	{ _, _, K, K, K, _, _ },
	{ _, _, _, _, _, _, _ },
}
tga_encoder.image(pixels):save("textures/xmaps_dot_small.tga")

local pixels = {
	{ _, _, _, _, _, _, _ },
	{ _, _, _, _, _, _, _ },
	{ _, _, _, K, K, _, _ },
	{ _, _, K, W, W, K, _ },
	{ _, _, K, W, W, K, _ },
	{ _, _, _, K, K, _, _ },
	{ _, _, _, _, _, _, _ },
}
tga_encoder.image(pixels):save("textures/xmaps_dot_tiny.tga")
