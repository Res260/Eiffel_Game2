note
	description: "An haptic device uniquely identified with an index."
	author: "Louis Marchand"
	date: "Mon, 02 Mar 2015 14:20:07 +0000"
	revision: "0.1"

class
	GAME_HAPTIC_DEVICE

inherit
	GAME_HAPTIC

create {GAME_SDL_CONTROLLER}
	make

feature {NONE} -- Initialization

	make(a_index:INTEGER)
			-- Initialization of `Current' using `a_index' as internal index.
		require
			Is_Haptic_Enabled: game_library.is_haptic_enable
			Is_Index_Valid: a_index < {GAME_SDL_EXTERNAL}.sdl_numhaptics
			Is_Haptic_Not_Already_Open: not {GAME_SDL_EXTERNAL}.SDL_HapticOpened(a_index)
		do
			default_create
			index := a_index
		end

feature -- Query

	index:INTEGER

	name:READABLE_STRING_GENERAL
			-- A text to identified `Current'
		local
			l_c_pointer:POINTER
			l_c_string:C_STRING
		do
			clear_error
			l_c_pointer := {GAME_SDL_EXTERNAL}.SDL_HapticName(index)
			if l_c_pointer.is_default_pointer then
				manage_error_pointer(l_c_pointer, "Cannot retreive haptic name.")
				Result := ""
			else
				create l_c_string.make_by_pointer(l_c_pointer)
				Result := l_c_string.string
			end
		end

feature {NONE} -- Implementation

	internal_open:POINTER
			-- <Precursor>
		do
			Result := {GAME_SDL_EXTERNAL}.SDL_HapticOpen(index)
		end

end
