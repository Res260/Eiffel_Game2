note
	description : "An example of sprite animation and movement using surfaced window"
	date        : "Sat, 28 Mar 2015 20:52:21 +0000"
	revision    : "2.0"

class
	APPLICATION

inherit
	GAME_LIBRARY_SHARED		-- To use `game_library'
	IMG_LIBRARY_SHARED		-- To use `image_file_library'

create
	make

feature {NONE} -- Initialization

	make
		do
			game_library.enable_video -- Enable the video functionalities
			image_file_library.enable_image (true, false, false)  -- Enable PNG image (but not TIF or JPG).
			run_game  -- Run the core creator of the game.
			image_file_library.quit_library  -- Correctly unlink image files library
			game_library.quit_library  -- Clear the library before quitting
		end

	run_game
			-- Create ressources and launch the game
		local
			l_desert:DESERT
			l_maryo:MARYO
			l_window:GAME_WINDOW_SURFACED
		do
			create l_desert
			if not l_desert.has_error then
				create l_maryo
				l_maryo.y := 375
				l_maryo.x := 200
				if not l_maryo.has_error then
					create l_window.make_default ("Example Animation", l_desert.width, l_desert.height)
					game_library.quit_signal_actions.extend (agent on_quit)
					l_window.key_pressed_actions.extend (agent on_key_pressed(?, ?, l_maryo))
					l_window.key_released_actions.extend (agent on_key_released(?,?,  l_maryo))
					game_library.iteration_actions.extend (agent on_iteration(?, l_maryo, l_desert, l_window))
					game_library.launch
				else
					print("Cannot create the Maryo surface.")
				end
			else
				print("Cannot create the desert surface.")
			end
		end


feature {NONE} -- Implementation

	on_iteration(a_timestamp:NATURAL_32; a_maryo:MARYO; a_desert:GAME_SURFACE; l_window:GAME_WINDOW_SURFACED)
			-- Event that is launch at each iteration.
		do
			a_maryo.update (a_timestamp)
			if a_maryo.x < 0 then
				a_maryo.x := 0
			elseif a_maryo.x + a_maryo.sub_image_width > a_desert.width then
				a_maryo.x := a_desert.width - a_maryo.sub_image_width
			end
			l_window.surface.fill_rect (create {GAME_COLOR}.make_rgb (0, 128, 255), 0, 0, a_desert.width, a_desert.height)
			l_window.surface.draw_surface (a_desert, 0, 0)
			l_window.surface.draw_sub_surface (a_maryo.surface, a_maryo.sub_image_x, a_maryo.sub_image_y,
									a_maryo.sub_image_width, a_maryo.sub_image_height, a_maryo.x, a_maryo.y)
			l_window.update
		end


	on_key_pressed(a_timestamp: NATURAL_32; a_key_state: GAME_KEY_STATE; a_maryo:MARYO)
			-- Action when a keyboard key has been pushed
		do
			if not a_key_state.is_repeat then		-- Be sure that the event is not only an automatic repetition of the key
				if a_key_state.is_right then
					a_maryo.go_right(a_timestamp)
				elseif a_key_state.is_left then
					a_maryo.go_left(a_timestamp)
				end
			end

		end

	on_key_released(a_timestamp: NATURAL_32; a_key_state: GAME_KEY_STATE; a_maryo:MARYO)
			-- Action when a keyboard key has been released
		do
			if not a_key_state.is_repeat then		-- I don't know if a key release can repeat, but you never know...
				if a_key_state.is_right then
					a_maryo.stop_right
				elseif a_key_state.is_left then
					a_maryo.stop_left
				end
			end
		end

	on_quit(a_timestamp: NATURAL_32)
			-- This method is called when the quit signal is send to the application (ex: window X button pressed).
		do
			game_library.stop  -- Stop the controller loop (allow game_library.launch to return)
		end


end
