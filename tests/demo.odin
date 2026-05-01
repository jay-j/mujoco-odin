package mujoco_tests

import mj ".."
import "core:time"
import gl "vendor:OpenGL"
import SDL "vendor:sdl2"


main :: proc() {
	gfx := Gfx{}
	window_init(&gfx)

	m: ^mj.Model
	d: ^mj.Data

	// Load the model
	load_errors: [1000]u8
	m = mj.loadXML("demo.xml", nil, cstring(&load_errors[0]), len(load_errors))
	if m == nil {
		mj.mju_error(cstring(&load_errors[0]))
	}
	d = mj.makeData(m)

	// Conect the model to the rendering system
	mj.mjv_makeScene(m, &gfx.scn, 2000)
	mj.mjr_makeContext(m, &gfx.con, i32(mj.tFontScale._150))

	main_loop: for {
		// Process events (mouse, keyboard)
		for event: SDL.Event; SDL.PollEvent(&event); {
			if event.type == SDL.EventType.QUIT {
				break main_loop
			}
		}

		// Run many simulation steps in between graphic display steps
		t_start := d.time
		for d.time < t_start + 0.016 {
			// NOTE: insert motor commands here! d->ctrl[]

			// Advance physics
			mj.step(m, d)
		}

		// Get the latest scene drawn to the backbuffer
		mj.mjv_updateScene(m, d, &gfx.opt, nil, &gfx.cam, i32(mj.tCatBit.ALL), &gfx.scn)
		window_update_and_render(&gfx)

		// NOTE: Insert any custom GUI overlay code here

		SDL.GL_SwapWindow(gfx.window)

		// NOTE: Implement a proper framerate control using remaining time
		time.accurate_sleep(16 * time.Millisecond)
	}

	mj.mjv_freeScene(&gfx.scn)
	mj.mjr_freeContext(&gfx.con)
	mj.deleteData(d)
	mj.deleteModel(m)
}


//~ Boilerplate Helper Procedures

// Generic bundle of mujoco graphics objects
Gfx :: struct {
	cam:        mj.vCamera,
	opt:        mj.vOption,
	scn:        mj.vScene,
	con:        mj.rContext,
	window:     ^SDL.Window,
	gl_context: SDL.GLContext,
}


window_init :: proc(gfx: ^Gfx) {
	// setup the window with the OS
	SDL.Init(SDL.INIT_VIDEO)
	gfx.window = SDL.CreateWindow(
		"mujoco",
		SDL.WINDOWPOS_CENTERED_DISPLAY(1),
		SDL.WINDOWPOS_UNDEFINED,
		1920,
		1080,
		SDL.WINDOW_SHOWN | SDL.WINDOW_OPENGL | SDL.WINDOW_RESIZABLE,
	)
	gfx.gl_context = SDL.GL_CreateContext(gfx.window)
	SDL.GL_MakeCurrent(gfx.window, gfx.gl_context)

	// TODO where do these go?
	SDL.GL_SetAttribute(SDL.GLattr.RED_SIZE, 8)
	SDL.GL_SetAttribute(SDL.GLattr.BLUE_SIZE, 8)
	SDL.GL_SetAttribute(SDL.GLattr.GREEN_SIZE, 8)
	SDL.GL_SetAttribute(SDL.GLattr.ALPHA_SIZE, 8)

	// Framebuffers don't work on OpenGL 3.3
	gl.load_up_to(4, 5, SDL.gl_set_proc_address)

	// Disabling the OpenGL Depth Test greatly enables seemingly good alpha over behavior
	// gl.Enable(gl.DEPTH_TEST)
	gl.Enable(gl.CULL_FACE)
	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
	gl.Enable(gl.ALPHA_TEST)


	// Setup the window in mujoco
	mj.mjv_defaultCamera(&gfx.cam)
	mj.mjv_defaultOption(&gfx.opt)
	mj.mjv_defaultScene(&gfx.scn)
	mj.mjr_defaultContext(&gfx.con)
}


window_update_and_render :: proc(gfx: ^Gfx) {
	gl.ClearColor(0.5, 0.7, 1.0, 0.0)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
	viewport := mj.rRect{}
	SDL.GetWindowSize(gfx.window, &viewport.width, &viewport.height)
	mj.mjr_render(viewport, &gfx.scn, &gfx.con)
}
