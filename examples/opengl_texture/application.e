note
	description : "An OpenGL example using Texture loaded from SDL_Surface"
	author: "Louis Marchand"
	date: "Sat, 02 Jan 2016 21:31:37 +0000"
	revision    : "1.0"

class
	APPLICATION

inherit
	GL
	GLU
	GAME_LIBRARY_SHARED

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		do
			game_library.enable_video
			game_library.enable_gl
			run
			game_library.clear_all_events
			game_library.quit_library
		end

	run
			-- Run the example
		local
			l_window_builder:GAME_WINDOW_GL_BUILDER
			l_window:GAME_WINDOW_GL
		do
			has_error := False
			l_window_builder.set_gl_version (2, 1)
			l_window_builder.enable_resizable
			if not l_window_builder.has_error then
				l_window := l_window_builder.generate_window
				if not l_window.has_error then
					init_gl
					if not has_error then
						init_gl_texture
						if not has_error then
							l_window.expose_actions.extend (agent update_screen(?, l_window))
							l_window.size_change_actions.extend (agent on_resize(?, l_window))
							game_library.quit_signal_actions.extend (agent quit)
							game_library.launch
						end
					end
				else
					io.error.put_string ("Cannot generate GL window%N")
					has_error := True
				end
			else
				io.error.put_string ("Cannot generate GL window%N")
				has_error := True
			end

		end

	init_gl
			-- Initialize OpenGL
		do
			glMatrixMode (gl_projection)
			glLoadIdentity
			manage_gl_error
			if not has_error then
				glMatrixMode (gl_ModelView)
				glLoadIdentity
				manage_gl_error
				if not has_error then
					glClearColor (0.0, 0.0, 0.0, 0.0)
					manage_gl_error
				end
			end
		end

	init_gl_texture
			-- Enable and create the OpenGL texture that will have it's ID store in `texture_id'
		local
			l_texture_id:NATURAL
		do
			if attached texture_surface as la_surface then
				if not la_surface.has_error then
					glEnable(GL_TEXTURE_2D)
					glGenTextures(1, $l_texture_id)
					texture_id := l_texture_id
					glBindTexture(GL_TEXTURE_2D, l_texture_id)
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
					if la_surface.must_lock then
						la_surface.lock
					end
					if la_surface.must_lock implies la_surface.is_lock then
						glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, la_surface.width, la_surface.height, 0, GL_BGRA.as_natural_32, gl_unsigned_int_8_8_8_8.as_natural_32, la_surface.pixels.item);
						manage_gl_error
					end
					if la_surface.is_lock then
						la_surface.unlock
					end
				else
					has_error := True
				end
			else
				has_error := True
			end
		end

	manage_gl_error
			-- When an OpenGL error is detected, set `has_error' and print the error string
		local
			l_error_code:NATURAL
			l_error_string:C_STRING
		do
			if l_error_code /~ gl_no_error then
				create l_error_string.make_by_pointer (gluErrorString(l_error_code))
				io.error.put_string ("OpenGL error: " + l_error_string.string + "%N")
				has_error := True
			end
		end

	texture_surface:detachable GAME_SURFACE
			-- Return a {GAME_SURFACE} with the BGRA (32 bits little-endian) pixel format
		local
			l_image:GAME_IMAGE_BMP_FILE
			l_origin_surface:GAME_SURFACE
			l_pixel_format:GAME_PIXEL_FORMAT
		do
			create l_image.make ("texture.bmp")
			if l_image.is_openable then
				l_image.open
				if l_image.is_open then
					create l_origin_surface.share_from_image (l_image)
					if l_origin_surface.is_open then
						create l_pixel_format.default_create
						l_pixel_format.set_bgra8888
						Result := l_origin_surface.as_converted_to_pixel_format (l_pixel_format)
						if l_origin_surface.has_error then
							Result := Void
						end
					end
				end
			end
		end

	update_screen(a_timestamp:NATURAL_32; a_window:GAME_WINDOW)
			-- Redraw the scene
		do
			glClear (gl_color_buffer_bit)
			glBindTexture(GL_TEXTURE_2D, texture_id)
			glBegin (gl_quads)
			glTexCoord2f (1, 1)
			glvertex2f (-0.5, -0.5)
			glTexCoord2f (0, 1)
			glvertex2f (0.5, -0.5)
			glTexCoord2f (0, 0)
			glvertex2f (0.5, 0.5)
			glTexCoord2f (1, 0)
			glvertex2f (-0.5, 0.5)
			glEnd
			a_window.update
		end

	on_resize(a_timestamp:NATURAL_32; a_window:GAME_WINDOW_GL)
			-- When `a_window' is resized
		local
			l_size:TUPLE[width, height:INTEGER]
		do
			l_size := a_window.gl_drawable_size
			glviewport (0, 0, l_size.width, l_size.height)
			update_screen(a_timestamp, a_window)
		end

	quit(a_timestamp:NATURAL_32)
			-- When the user quit the application
		do
			game_library.stop
		end

	has_error:BOOLEAN
			-- An error occured

	texture_id:NATURAL
			-- The internal id of the OpenGL texture

end