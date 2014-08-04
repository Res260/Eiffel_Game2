note
	description: "Joystick manager. Not tested. It is most probable that it does not work correctly"
	author: "Louis Marchand"
	date: "May 24, 2012"
	revision: "1.0.0.0"

class
	GAME_JOYSTICK

inherit
	DISPOSABLE
	GAME_SDL_ANY

create {GAME_SDL_CONTROLLER}
	make

feature {NONE} -- Initialization

	make(a_from_index:INTEGER)
			-- Initialization for `Current'.
		do
			index:=a_from_index
		end

feature -- Access

	name:STRING
			-- Return the Joystick Name.
		local
			l_text_return:C_STRING
		do
			if is_opened then
				create l_text_return.make_by_pointer ({GAME_SDL_EXTERNAL}.SDL_JoystickName(joy_ptr))
			else
				create l_text_return.make_by_pointer ({GAME_SDL_EXTERNAL}.SDL_JoystickNameForIndex(index))
			end
			Result:=l_text_return.string
		end

	open
			-- Open `Current' (Allocate internal structure).
		require
			Open_Joystick_Not_Open:not is_opened
		do
			clear_error
			joy_ptr:={GAME_SDL_EXTERNAL}.SDL_JoystickOpen(index)
			if joy_ptr.is_default_pointer then
				has_error := True
			end
		ensure
			Is_Open_Or_Error: not has_error implies is_opened
		end

	close
			-- Close `Current' (Free internal structure).
		require
			Close_Is_Open: is_opened
		do
			{GAME_SDL_EXTERNAL}.SDL_JoystickClose(joy_ptr)
		end

	is_opened:BOOLEAN
			-- True if the joystick has been opened.
		do
			Result := {GAME_SDL_EXTERNAL}.SDL_JoystickGetAttached(joy_ptr)
		end

	index:INTEGER
		-- The internal `index' representing `Current'

	axes_number:INTEGER
			-- Get the number of axes on the joystick.
		require
			Get_Axes_Number_Opened: is_opened
		do
			clear_error
			Result:={GAME_SDL_EXTERNAL}.SDL_JoystickNumAxes(joy_ptr)
			has_error := Result < 0
		end

	axis_value(a_axis_id:INTEGER):INTEGER_16
			-- Get the value of the axis identified by `a_axis_id'.
			-- Note that `a_axis_id' index start at 0
		require
			Get_Axis_Value_Opened: is_opened
			Get_Axis_Value_Axis_Id_Valid: a_axis_id<axes_number
		do
			Result:={GAME_SDL_EXTERNAL}.SDL_JoystickGetAxis(joy_ptr,a_axis_id)
		end

	balls_number:INTEGER
			-- Return the number of balls on the joystick.
		require
			Get_Balls_Number_Opened: is_opened
		do
			clear_error
			Result:={GAME_SDL_EXTERNAL}.SDL_JoystickNumBalls(joy_ptr)
			has_error := Result < 0
		end

	ball_change(a_ball_id:INTEGER):TUPLE[x_relative, y_relative:INTEGER]
			-- Return the state of the ball identified by `a_ball_id' (relative to the last read).
			-- Note that `a_ball_id' index start at 0
		require
			Get_Ball_Value_Opened: is_opened
			Get_Ball_Value_Ball_Id_Valid: a_ball_id<axes_number
		local
			l_dx,l_dy,l_error:INTEGER
		do
			clear_error
			{GAME_SDL_EXTERNAL}.SDL_JoystickUpdate
			l_error:={GAME_SDL_EXTERNAL}.SDL_JoystickGetBall(joy_ptr,a_ball_id,$l_dx,$l_dy)
			Result:=[l_dx,l_dy]
			has_error := l_error < 0
		end

	buttons_number:INTEGER
			-- Return the number of buttons on the joystick.
		require
			Get_Buttons_Number_Opened: is_opened
		do
			clear_error
			Result:={GAME_SDL_EXTERNAL}.SDL_JoystickNumButtons(joy_ptr)
			has_error := Result < 0
		end

	is_button_pressed(a_button_id:INTEGER):BOOLEAN
			-- True if the button identified by `a_button_id' is pressed, False otherwise
			-- Note that `a_button_id' index start at 0
		require
			Is_Buttons_Pressed_Opened: is_opened
			Is_Button_Pressed_Button_Id_Valid: a_button_id<buttons_number
		do
			Result:={GAME_SDL_EXTERNAL}.SDL_JoystickGetButton(joy_ptr, a_button_id)
		end

	hats_number:INTEGER
			-- Return the number of hats on the joystick.
		require
			Get_Hats_Number_Opened: is_opened
		do
			clear_error
			Result:={GAME_SDL_EXTERNAL}.SDL_JoystickNumHats(joy_ptr)
			has_error := Result < 0
		end

	hat_state(a_hat_id:INTEGER):GAME_JOYSTICK_HAT_STATE
			-- The state of the hat identified by `a_hat_id'
			-- Note that `a_hat_id' index start at 0
		require
			Get_Hat_State_Opened: is_opened
			Get_Hat_State_Hat_Id_Valid: a_hat_id<hats_number
		do
			create Result.make ({GAME_SDL_EXTERNAL}.SDL_JoystickGetHat(joy_ptr, a_hat_id))
		end

	guid:READABLE_STRING_GENERAL
			-- A unique hardware identifier of `Current'
		local
			l_guid_pointer, l_string_buffer:POINTER
			l_c_string:C_STRING
		do
			l_string_buffer := l_string_buffer.memory_alloc (50)
			if is_opened then
				l_guid_pointer := {GAME_SDL_EXTERNAL}.SDL_JoystickGetGUID(joy_ptr)
			else
				l_guid_pointer := {GAME_SDL_EXTERNAL}.SDL_JoystickGetDeviceGUID(index)
			end
			{GAME_SDL_EXTERNAL}.SDL_JoystickGetGUIDString(l_guid_pointer, l_string_buffer, 50)
			create l_c_string.own_from_pointer (l_string_buffer)
			Result := l_c_string.string
		end

	instance_id:INTEGER_32
			-- Identifier of `Current' used in event handeling
		require
			Is_Buttons_Pressed_Opened: is_opened
		do
			clear_error
			Result := {GAME_SDL_EXTERNAL}.SDL_JoystickInstanceID(joy_ptr)
			has_error := Result < 0
		end

	is_haptic_capable:BOOLEAN
			-- Is `Current' has haptic features
		local
			l_error : INTEGER
		do
			clear_error
			l_error := {GAME_SDL_EXTERNAL}.SDL_JoystickIsHaptic(joy_ptr)
			Result := l_error = 1
			has_error := l_error < 0
		end

	haptic_controller:GAME_JOYSTICK_HAPTIC_CONTROLLER
		require
			Is_Haptic_Capable: is_haptic_capable
		do
			if attached internal_haptic_controller as la_internal_haptic_controller then
				Result := la_internal_haptic_controller
			else
				create Result.make(Current)
				internal_haptic_controller := Result
			end
		end

feature -- Events (ToDo)

feature {NONE} -- Implementation

	internal_haptic_controller: detachable GAME_JOYSTICK_HAPTIC_CONTROLLER

	joy_ptr:POINTER

	dispose
	do
		if is_opened then
			close
		end
	end

end
