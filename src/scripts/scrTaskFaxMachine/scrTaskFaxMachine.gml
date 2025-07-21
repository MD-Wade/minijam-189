function task_fax_machine_init() {
    task_parent_init_state();
    task_parent_init_title(true);
    task_fax_machine_init_scene();
    task_fax_machine_init_paper();
    task_fax_machine_init_keypad();
    task_fax_machine_init_inputs();
    task_fax_machine_init_digits();

    title_text = "FAX MACHINE";
}

function task_fax_machine_init_scene() {
    scene_target_x = 0;
    scene_target_y = 0;
    scene_begin_x = 0;
    scene_begin_y = room_height;
    scene_width = room_width;
    scene_height = room_height;

    hand_start_x = 256;
    hand_start_y = room_height;
}
function task_fax_machine_init_paper() {
    paper_base_x = 110;
    paper_base_y = 145;
    var _number_direction = point_direction(0, 0, 15, 20);
    paper_number_x = paper_base_x + lengthdir_x(48, _number_direction);
    paper_number_y = paper_base_y + lengthdir_y(48, _number_direction);
}
function task_fax_machine_init_inputs() {
    map_keypad_inputs = {
        "Digit1": [vk_numpad1, ord("1")],
        "Digit2": [vk_numpad2, ord("2")],
        "Digit3": [vk_numpad3, ord("3")],
        "Digit4": [vk_numpad4, ord("4")],
        "Digit5": [vk_numpad5, ord("5")],
        "Digit6": [vk_numpad6, ord("6")],
        "Digit7": [vk_numpad7, ord("7")],
        "Digit8": [vk_numpad8, ord("8")],
        "Digit9": [vk_numpad9, ord("9")],
        "Digit0": [vk_numpad0, ord("0")],
        "DigitC": [ord("C")],
        "BACKSPACE": [vk_backspace],
        "SEND": [vk_enter]
    }
}
function task_fax_machine_init_digits() {
    var _digits_begin_x = 240;
    var _digits_begin_y = 143;

    var _digit_width = 16;

    digit_positions = array_create(11);
    for (var _digit_index = 0; _digit_index < 11; _digit_index ++) {
        digit_positions[_digit_index] = [
            _digits_begin_x + (_digit_index * _digit_width), _digits_begin_y
        ];
    }

    map_digits_image_indices = {
        "Digit0": 0,
        "Digit1": 1,
        "Digit2": 2,
        "Digit3": 3,
        "Digit4": 4,
        "Digit5": 5,
        "Digit6": 6,
        "Digit7": 7,
        "Digit8": 8,
        "Digit9": 9,
        "DigitC": 10
    }

    inputted_string = "";
}
function task_fax_machine_init_keypad() {
    var _keypad_begin_x = 460;
    var _keypad_begin_y = 90;
    var _button_width = sprite_get_width(sFaxNumpad);
    var _button_height = sprite_get_height(sFaxNumpad);

    var _width_with_padding = _button_width + 4;
    var _height_with_padding = _button_height + 4;

    map_keypad_positions = {
        "Digit1": [_keypad_begin_x + 0, _keypad_begin_y + 0],
        "Digit2": [_keypad_begin_x + _width_with_padding, _keypad_begin_y + 0],
        "Digit3": [_keypad_begin_x + (_width_with_padding * 2), _keypad_begin_y + 0],
        "Digit4": [_keypad_begin_x + 0, _keypad_begin_y + _height_with_padding],
        "Digit5": [_keypad_begin_x + _width_with_padding, _keypad_begin_y + _height_with_padding],
        "Digit6": [_keypad_begin_x + (_width_with_padding * 2), _keypad_begin_y + _height_with_padding],
        "Digit7": [_keypad_begin_x + 0, _keypad_begin_y + (_height_with_padding * 2)],
        "Digit8": [_keypad_begin_x + _width_with_padding, _keypad_begin_y + (_height_with_padding * 2)],
        "Digit9": [_keypad_begin_x + (_width_with_padding * 2), _keypad_begin_y + (_height_with_padding * 2)],
        "DigitC": [_keypad_begin_x + _width_with_padding, _keypad_begin_y + (_height_with_padding * 3)],
        "Digit0": [_keypad_begin_x, _keypad_begin_y + (_height_with_padding * 3)],
        "BACKSPACE": [_keypad_begin_x + (_width_with_padding * 2), _keypad_begin_y + (_height_with_padding * 3)],
        "SEND": [_keypad_begin_x, _keypad_begin_y + 152],
        "CANCEL": [_keypad_begin_x + 70, _keypad_begin_y + 152]
    }

    map_keypad_image_indices = {
        "Digit1": 0,
        "Digit2": 2,
        "Digit3": 4,
        "Digit4": 6,
        "Digit5": 8,
        "Digit6": 10,
        "Digit7": 12,
        "Digit8": 14,
        "Digit9": 16,
        "DigitC": 18,
        "Digit0": 20,
        "BACKSPACE": 22,
        "CANCEL": 24,
        "SEND": 0,
    }
}

function task_fax_machine_step() {
    switch (state_current) {
        case E_STATES_TASK_PARENT.TRANSITION_IN:
            task_parent_step_state_transition_in();
            break;
        case E_STATES_TASK_PARENT.MINIGAME:
            task_fax_machine_step_minigame();
            break;
    }
}
function task_fax_machine_step_minigame() {
    var _keypad_key_names = variable_struct_get_names(map_keypad_positions);
    for (var _key_index = 0; _key_index < array_length(_keypad_key_names); _key_index ++) {
        var _key_name = _keypad_key_names[_key_index];
        var _key_pos = map_keypad_positions[$ _key_name];
        var _input_array = map_keypad_inputs[$ _key_name];

        for (var _input_index = 0; _input_index < array_length(_input_array); _input_index ++) {
            var _input_key = _input_array[_input_index];
            if (keyboard_check_pressed(_input_key)) {
                show_debug_message("Key pressed: " + _key_name);
                task_fax_machine_input_key(_key_name);
                break;
            }
        }
    }
}

function task_fax_machine_draw() {
    task_parent_draw_background();
    task_parent_draw_title();
    task_fax_machine_draw_scene();
    task_fax_machine_draw_digits();
    task_fax_machine_draw_keypad();
}
function task_fax_machine_draw_scene() {
    var _current_pos_x = lerp(scene_begin_x, scene_target_x, state_tick_tween);
    var _current_pos_y = lerp(scene_begin_y, scene_target_y, state_tick_tween);

    draw_sprite(sSceneFaxMachine, 0, _current_pos_x, _current_pos_y);
    task_fax_machine_draw_paper();

    var _hand_pos_x = lerp(hand_start_x, mouse_x, state_tick_tween);
    var _hand_pos_y = lerp(hand_start_y, mouse_y, state_tick_tween);
}
function task_fax_machine_draw_keypad() {
    var _current_pos_x = lerp(scene_begin_x, scene_target_x, state_tick_tween);
    var _current_pos_y = lerp(scene_begin_y, scene_target_y, state_tick_tween);

    var _keypad_key_names = variable_struct_get_names(map_keypad_positions);
    for (var _key_index = 0; _key_index < array_length(_keypad_key_names); _key_index ++) {
        var _key_name = _keypad_key_names[_key_index];
        var _key_pos = map_keypad_positions[$ _key_name];
        var _sprite_index = sFaxNumpad;
        var _key_image_index = map_keypad_image_indices[$ _key_name];

        if (_key_name == "SEND") {
            _sprite_index = sFaxNumpadSend;
            _key_image_index = 0;
        }

        var _key_pressed = false;
        var _input_array = map_keypad_inputs[$ _key_name];
        for (var _input_index = 0; _input_index < array_length(_input_array); _input_index ++) {
            var _input_key = _input_array[_input_index];
            if (keyboard_check(_input_key)) {
                _key_pressed = true;
                break;
            }
        }

        if (_key_pressed) {
            _key_image_index += 1;
        }
        draw_sprite(_sprite_index, _key_image_index, _current_pos_x + _key_pos[0], _current_pos_y + _key_pos[1]);
    }
}
function task_fax_machine_draw_digits() {
    var _current_pos_x = lerp(scene_begin_x, scene_target_x, state_tick_tween);
    var _current_pos_y = lerp(scene_begin_y, scene_target_y, state_tick_tween);

    var _input_length_current = string_length(inputted_string);
    for (var _digit_index = 0; _digit_index < array_length(digit_positions); _digit_index ++) {
        var _digit_value = string_char_at(inputted_string, _digit_index + 1);
        var _digit_pos = digit_positions[_digit_index];

        if (_digit_index >= _input_length_current) {
            break;
        }
        var _digit_image_index = map_digits_image_indices[$ "Digit" + string(_digit_value)];
        draw_sprite_ext(sFaxDigitDisplay, _digit_image_index, 
            _current_pos_x + _digit_pos[0], _current_pos_y + _digit_pos[1], 
            1.0, 1.0, 0, c_white, 1.0);
    }
}
function task_fax_machine_draw_paper() {
    var _current_pos_x = lerp(scene_begin_x, scene_target_x, state_tick_tween);
    var _current_pos_y = lerp(scene_begin_y, scene_target_y, state_tick_tween);
    var _paper_header_x = _current_pos_x + paper_base_x;
    var _paper_header_y = _current_pos_y + paper_base_y;
    var _paper_number_x = _current_pos_x + paper_number_x;
    var _paper_number_y = _current_pos_y + paper_number_y;

    draw_set_font(fntFaxHeader);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_colour(c_black);
    draw_set_alpha(1.0);

    draw_sprite(sSceneFaxMachine, 1, _current_pos_x, _current_pos_y);
    draw_text_transformed(_paper_header_x, _paper_header_y, "photograph of cookie", 
        1.0, 1.0, 10);
    draw_text_transformed(_paper_number_x, _paper_number_y, 
        string(global.fax_held.fax_number_formatted), 0.8, 0.8, 10);
}

function task_fax_machine_input_key(_key_name) {
    switch (_key_name) {
        case "Digit1":
        case "Digit2":
        case "Digit3":
        case "Digit4":
        case "Digit5":
        case "Digit6":
        case "Digit7":
        case "Digit8":
        case "Digit9":
        case "Digit0":
        case "DigitC":
            task_fax_machine_input_digit(_key_name);
            break;
        case "BACKSPACE":
            task_fax_machine_input_backspace();
            break;
        case "SEND":
            task_fax_machine_input_send();
            break;
    }
    show_debug_message("Inputted string: " + inputted_string);
}
function task_fax_machine_input_digit(_key_name) {
    if (string_length(inputted_string) >= 11) {
        return; // prevent inputting more than 11 digits
    }

    audio_play_sound(sndUiSelection, 1, false);
    switch (_key_name) {
        case "Digit1": inputted_string += "1"; break;
        case "Digit2": inputted_string += "2"; break;
        case "Digit3": inputted_string += "3"; break;
        case "Digit4": inputted_string += "4"; break;
        case "Digit5": inputted_string += "5"; break;
        case "Digit6": inputted_string += "6"; break;
        case "Digit7": inputted_string += "7"; break;
        case "Digit8": inputted_string += "8"; break;
        case "Digit9": inputted_string += "9"; break;
        case "Digit0": inputted_string += "0"; break;
        case "DigitC": inputted_string += "C"; break;
    }
}
function task_fax_machine_input_backspace() {
    if (string_length(inputted_string) > 0) {
        inputted_string = string_copy(inputted_string, 1, string_length(inputted_string) - 1);
        audio_play_sound(sndUiBack, 1, false);
    }
}
function task_fax_machine_input_send() {
    if (string_length(inputted_string) < 1) {
        return;
    }

    audio_play_sound(sndUiConfirm, 1, false);
    instance_destroy();
}


function task_fax_machine_minigame_entry() {
    if (is_undefined(global.fax_held)) {
        return;
    }
    task_parent_minigame_entry(TaskFaxMachine);
}