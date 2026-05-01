// Copyright 2021 DeepMind Technologies Limited
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
package mujoco

mjNAUX          :: 10        // number of auxiliary buffers
mjMAXTEXTURE    :: 1000      // maximum number of textures
mjMAXMATERIAL   :: 1000      // maximum number of materials with textures

//---------------------------------- primitive types (mjt) -----------------------------------------
tGridPos :: enum u32 {
	TOPLEFT     = 0, // top left
	TOPRIGHT    = 1, // top right
	BOTTOMLEFT  = 2, // bottom left
	BOTTOMRIGHT = 3, // bottom right
	TOP         = 4, // top center
	BOTTOM      = 5, // bottom center
	LEFT        = 6, // left center
	RIGHT       = 7, // right center
} // grid position for overlay

tFramebuffer :: enum u32 {
	WINDOW    = 0, // default/window buffer
	OFFSCREEN = 1, // offscreen buffer
} // OpenGL framebuffer option

tDepthMap :: enum u32 {
	NEAR = 0, // standard depth map; 0: znear, 1: zfar
	FAR  = 1, // reversed depth map; 1: znear, 0: zfar
} // depth mapping for `mjr_readPixels`

tFontScale :: enum u32 {
	_50  = 50,  // 50% scale, suitable for low-res rendering
	_100 = 100, // normal scale, suitable in the absence of DPI scaling
	_150 = 150, // 150% scale
	_200 = 200, // 200% scale
	_250 = 250, // 250% scale
	_300 = 300, // 300% scale
} // font scale, used at context creation

tFont :: enum u32 {
	NORMAL = 0, // normal font
	SHADOW = 1, // normal font with shadow (for higher contrast)
	BIG    = 2, // big font (for user alerts)
} // font type, used at each text operation

rRect :: struct {
	left:   i32, // left (usually 0)
	bottom: i32, // bottom (usually 0)
	width:  i32, // width (usually buffer width)
	height: i32, // height (usually buffer height)
} // OpenGL rectangle

//---------------------------------- mjrContext ----------------------------------------------------
rContext :: struct {
	// parameters copied from mjVisual
	lineWidth:   f32,    // line width for wireframe rendering
	shadowClip:  f32,    // clipping radius for directional lights
	shadowScale: f32,    // fraction of light cutoff for spot lights
	fogStart:    f32,    // fog start = stat.extent * vis.map.fogstart
	fogEnd:      f32,    // fog end = stat.extent * vis.map.fogend
	fogRGBA:     [4]f32, // fog rgba
	shadowSize:  i32,    // size of shadow map texture
	offWidth:    i32,    // width of offscreen buffer
	offHeight:   i32,    // height of offscreen buffer
	offSamples:  i32,    // number of offscreen buffer multisamples

	// parameters specified at creation
	fontScale:  i32,     // font scale
	auxWidth:   [10]i32, // auxiliary buffer width
	auxHeight:  [10]i32, // auxiliary buffer height
	auxSamples: [10]i32, // auxiliary buffer multisamples

	// offscreen rendering objects
	offFBO:            u32, // offscreen framebuffer object
	offFBO_r:          u32, // offscreen framebuffer for resolving multisamples
	offColor:          u32, // offscreen color buffer
	offColor_r:        u32, // offscreen color buffer for resolving multisamples
	offDepthStencil:   u32, // offscreen depth and stencil buffer
	offDepthStencil_r: u32, // offscreen depth and stencil buffer for multisamples

	// shadow rendering objects
	shadowFBO: u32, // shadow map framebuffer object
	shadowTex: u32, // shadow map texture

	// auxiliary buffers
	auxFBO:     [10]u32, // auxiliary framebuffer object
	auxFBO_r:   [10]u32, // auxiliary framebuffer object for resolving
	auxColor:   [10]u32, // auxiliary color buffer
	auxColor_r: [10]u32, // auxiliary color buffer for resolving

	// materials with textures
	mat_texid:      [10000]i32, // material texture ids (-1: no texture)
	mat_texuniform: [1000]i32,  // uniform cube mapping
	mat_texrepeat:  [2000]f32,  // texture repetition for 2d mapping

	// texture objects and info
	ntexture:    i32,       // number of allocated textures
	textureType: [1000]i32, // type of texture (mjtTexture) (ntexture)
	texture:     [1000]u32, // texture names

	// displaylist starting positions
	basePlane:      u32, // all planes from model
	baseMesh:       u32, // all meshes from model
	baseHField:     u32, // all height fields from model
	baseBuiltin:    u32, // all builtin geoms, with quality from model
	baseFontNormal: u32, // normal font
	baseFontShadow: u32, // shadow font
	baseFontBig:    u32, // big font

	// displaylist ranges
	rangePlane:   i32, // all planes from model
	rangeMesh:    i32, // all meshes from model
	rangeHField:  i32, // all hfields from model
	rangeBuiltin: i32, // all builtin geoms, with quality from model
	rangeFont:    i32, // all characters in font

	// skin VBOs
	nskin:           i32,  // number of skins
	skinvertVBO:     ^u32, // skin vertex position VBOs (nskin)
	skinnormalVBO:   ^u32, // skin vertex normal VBOs (nskin)
	skintexcoordVBO: ^u32, // skin vertex texture coordinate VBOs (nskin)
	skinfaceVBO:     ^u32, // skin face index VBOs (nskin)

	// character info
	charWidth:     [127]i32, // character widths: normal and shadow
	charWidthBig:  [127]i32, // character widths: big
	charHeight:    i32,      // character heights: normal and shadow
	charHeightBig: i32,      // character heights: big

	// capabilities
	glInitialized:      i32, // is OpenGL initialized
	windowAvailable:    i32, // is default/window framebuffer available
	windowSamples:      i32, // number of samples for default/window framebuffer
	windowStereo:       i32, // is stereo available for default/window framebuffer
	windowDoublebuffer: i32, // is default/window framebuffer double buffered

	// framebuffer
	currentBuffer: i32, // currently active framebuffer: mjFB_WINDOW or mjFB_OFFSCREEN

	// pixel output format
	readPixelFormat: i32, // default color pixel format for mjr_readPixels

	// depth output format
	readDepthMap: i32, // depth mapping: mjDEPTH_ZERONEAR or mjDEPTH_ZEROFAR
} // custom OpenGL context

