enum E_STATES_TASK_PARENT {
    TRANSITION_IN,
    MINIGAME,
}

function task_parent_init() {
	task_parent_init_state();
    task_parent_init_title();
}
function task_parent_init_state() {
    state_current = E_STATES_TASK_PARENT.TRANSITION_IN;
    state_previous = E_STATES_TASK_PARENT.TRANSITION_IN;
    state_tick = 0;
    state_tick_maximum = 0.5;
    state_tick_alpha = 0;
    state_tick_tween = 0;
}
function task_parent_init_title() {
    title_text = "ERROR";
    title_text_x = (8);
    title_text_y = (room_height - 8);
}
function task_parent_init_object(_object_sprite) {
    object_sprite = _object_sprite;
    object_sprite_width = sprite_get_width(_object_sprite);
    object_sprite_height = sprite_get_height(_object_sprite);
    object_begin_x = (room_width);
    object_begin_y = (room_height / 2);
    object_target_x = (room_width - object_sprite_width);
    object_target_y = (room_height / 2);
}

function task_parent_step_state_transition_in() {
	var _game_speed_fps = game_get_speed(gamespeed_fps);
    state_tick += (1 / _game_speed_fps);
    state_tick_alpha = state_tick / state_tick_maximum;
    state_tick_tween = ease_value(state_tick_alpha, EaseOutBackSofter);
    if (state_tick >= state_tick_maximum) {
        task_parent_state_set(E_STATES_TASK_PARENT.MINIGAME);
        state_tick = 0;
    }
}

function task_parent_draw_background() {
    var _background_alpha = lerp(0, 0.6, state_tick_tween);
    draw_set_alpha(_background_alpha);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
}
function task_parent_draw_object() {
    var _object_x = lerp(object_begin_x, object_target_x, state_tick_tween);
    var _object_y = lerp(object_begin_y, object_target_y, state_tick_tween);
    draw_sprite(object_sprite, 0, _object_x, _object_y);
}
function task_parent_draw_title() {
    draw_set_font(fntTaskTitle);
    
    var _text_width = string_width(title_text);
    var _text_height = string_height(title_text);
    var _bbox_border = 4;
    var _bbox_top = title_text_y - _text_height - _bbox_border;
    var _bbox_left = title_text_x - _bbox_border;
    var _bbox_right = title_text_x + _text_width + _bbox_border;
    var _bbox_bottom = title_text_y + _bbox_border;

    draw_set_alpha(state_tick_tween);
    draw_set_colour(c_black);
    draw_rectangle(_bbox_left, _bbox_top, _bbox_right, _bbox_bottom, false);
    draw_set_valign(fa_bottom);
    draw_set_halign(fa_left);
    draw_text_perlin(title_text_x, title_text_y, title_text, 2.0, 0.7, 1.0, c_white, c_dkgray, 1);

    draw_set_alpha(1.0);
    draw_set_colour(c_white);
}

function task_parent_state_set(_current_state) {
    state_previous = state_current;
    state_current = _current_state;
    state_tick = 0;
}
function task_parent_minigame_entry(_minigame_object) {
	if (instance_exists(TaskParent)) return;
	
	instance_create_layer(0, 0, "Minigames", _minigame_object);
}