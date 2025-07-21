enum E_TEXT_INFO_TYPES {
    MISTAKE, COMPLETE, CUSTOM
}

function text_info_init() {
    state_current = 0;
    state_tick = 0;
    state_tick_max = 0.5;
    state_tick_alpha = 0;

    var _angle_chosen = choose(irandom_range(55, 35), irandom_range(125, 145));
    x_target = xstart + lengthdir_x(32, _angle_chosen);
    y_target = ystart + lengthdir_y(32, _angle_chosen);

    text_string = "ERROR";
    text_colour_main = c_white;
    text_colour_alt = c_ltgray;
}

function text_info_step() {
    var _gamespeed_fps = game_get_speed(gamespeed_fps);
    state_tick += (1 / _gamespeed_fps);
    
    switch (state_current) {
        case 0: // fading in
            state_tick_alpha = state_tick / state_tick_max;
            if (state_tick >= state_tick_max) {
                state_current = 1; // move to next state
                state_tick = 0;
                state_tick_max = 2;
            }
            break;

        case 1: // moving to target
            state_tick_alpha = 1.0;
            if (state_tick >= state_tick_max) {
                state_current = 2; // move to next state
                state_tick = 0;
                state_tick_max = 0.5;
            }
            break;

        case 2: // fading out
            state_tick_alpha = 1 - (state_tick / state_tick_max);
            if (state_tick >= state_tick_max) {
                instance_destroy(); // destroy the instance
            }
            break;
	}

}

function text_info_draw() {
    state_tick_tweened = ease_value(state_tick_alpha, EaseOutSine);
    var _shadow_distance = lerp(12, 1, state_tick_tweened);
    var _colour_current = merge_colour(text_colour_alt, text_colour_main, state_tick_tweened);
    var _shadow_colour = merge_colour(_colour_current, c_black, 0.7);
    x = lerp(xstart, x_target, state_tick_tweened);
    y = lerp(ystart, y_target, state_tick_tweened);
    draw_set_alpha(state_tick_tweened);
    draw_set_font(fntHudSmall);
    draw_text_perlin(x, y, text_string, 1.0, 0.5, 1.0, _colour_current, _shadow_colour, _shadow_distance);
    draw_set_alpha(1);
}

function text_info_create(_pos_x, _pos_y, _type=E_TEXT_INFO_TYPES.MISTAKE, _text_override="", _text_colour_override=undefined) {
    var _text_current = _text_override;
    if (_text_current == "") {
        switch (_type) {
            case E_TEXT_INFO_TYPES.MISTAKE:
                _text_current = choose("WRONG!", "WHY?!")
                break;
            case E_TEXT_INFO_TYPES.COMPLETE:
                _text_current = choose("Nice.", "Good job.", "Well done.");
                break;
        }
    }

    var _text_colour = _text_colour_override;
    var _text_colour_alt = _text_colour_override;
    if (_text_colour == undefined) {
        switch (_type) {
            case E_TEXT_INFO_TYPES.MISTAKE:
                _text_colour = c_red;
                _text_colour_alt = merge_colour(c_red, c_white, 0.2);
                break;
            case E_TEXT_INFO_TYPES.COMPLETE:
                _text_colour = c_blue;
                _text_colour_alt = merge_colour(c_blue, c_white, 0.2);
                break;
            case E_TEXT_INFO_TYPES.CUSTOM:
                _text_colour = c_white;
                _text_colour_alt = merge_colour(c_white, c_black, 0.2);
                break;
        }
    }

    var _text_info = instance_create_layer(_pos_x, _pos_y, "TextInfo", TextInfo);
    _text_info.text_string = _text_current;
    _text_info.text_colour_main = _text_colour;
    _text_info.text_colour_alt = _text_colour_alt;
}