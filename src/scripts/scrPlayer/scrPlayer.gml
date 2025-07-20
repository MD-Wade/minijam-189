enum E_STATES_PLAYER {
    IDLE,
    MOVING,
    TASK,
}
enum E_STATES_PROMPT_TAB {
    IDLE,
    ACTIVE,

}

function PromptTab(_button_label, _description_label) constructor {
    self.button_label = _button_label;
    self.description_label = _description_label;
    self.state = E_STATES_PROMPT_TAB.IDLE;
    self.alert_count = 0;
    self.width_current = 0;
    self.width_desired = 24;
    self.colour_current = c_black;
    self.colour_desired = c_white;
    self.interpolate_speed = 0.05;

    function step_interpolate() {
        self.colour_current = merge_colour(self.colour_current, self.colour_desired, self.interpolate_speed);
        self.width_current = lerp(self.width_current, self.width_desired, self.interpolate_speed);
    }
}

#macro LISTENER_HEIGHT 64  // How high the "ears" are above the ground plane.
#macro LISTENER_SETBACK 32 // How far "behind" the player the ears are.

function player_init() {
    player_init_node();
    player_init_pathfinding();
    player_init_run();
    player_init_state();
    player_init_performance();
    player_init_prompts();
    player_init_audio_listener();
    player_init_fax_pile();
    player_prompt_set_active(0);
}
function player_init_node() {
    node_movement_speed = 4;
    node_target_instance = noone;
    node_current_instance = instance_nearest(x, y, Node);
    x = node_current_instance.x;
    y = node_current_instance.y;

    node_map = {};

    with (Node) {
        show_debug_message("Node found: " + string(node_input));
        other.node_map[$ string(node_input)] = id;
    }
    node_count_total = struct_names_count(node_map);
}
function player_init_pathfinding() {
    pathfinding_path = path_add();
}
function player_init_run() {
    run_sound_array = [sndPlayerRun1, sndPlayerRun2];
    run_sound_index = 0;
    run_sound_instance_last = -1;
    run_tick = 0;
    run_tick_maximum = 0.2;
    run_previous_x = x;
}
function player_init_audio_listener() {
    audio_falloff_set_model(audio_falloff_inverse_distance_clamped);

    audio_listener_set_orientation(
        0, 0, 0, -1, 0, -1, 0
    );
    audio_listener_set_position(
        0, room_width / 2, room_height / 2, 0
    );
    
    audio_emitter = audio_emitter_create();
    audio_emitter_falloff(audio_emitter, 48, 320, 1.0);
}
function player_init_state() {
    state_current = E_STATES_PLAYER.IDLE;
    state_previous = E_STATES_PLAYER.IDLE;
    state_tick = 0;
    state_tick_maximum = 0.5;
}
function player_init_prompts() {
    prompt_tabs = [];
    var _task_labels = [
        "PUTER",
        "FX. PILE",
        "PHONE",
        "FX.MCHNE",
        "COOKIES",
    ]
    for (var _prompt_index = 0; _prompt_index < node_count_total; _prompt_index ++) {
        var _prompt_label = string(_prompt_index + 1);
        var _prompt_node = node_map[$ _prompt_label];
        array_push(prompt_tabs, new PromptTab(_prompt_label, _task_labels[_prompt_index]));
    }

    var _border = 4;
    prompt_tab_width = 16;
    prompt_tab_height = 16;
    prompt_tabs_begin_x = performance_bar_x1;
    prompt_tabs_begin_y = performance_bar_y2;
    prompt_tabs_end_x = 0;
    prompt_tabs_end_y = (prompt_tabs_begin_y + (prompt_tab_height * node_count_total));

    prompt_length_base = 16;
    prompt_length_alert = 32;
    prompt_length_mod_min = 0.94;
    prompt_length_mod_max = 1.10;
}
function player_init_performance() {
    performance_value = 100;
    var _performance_bar_width = 72;
    var _performance_bar_height = 16;
    performance_bar_x1 = 0;
    performance_bar_y1 = 0;
    performance_bar_x2 = performance_bar_x1 + _performance_bar_width;
    performance_bar_y2 = performance_bar_y1 + _performance_bar_height;
}
function player_init_fax_pile() {
    global.fax_pile_count = 0;
}

function player_step() {
    player_depth_update();
    player_audio_emitter_update();

    switch (state_current) {
        case E_STATES_PLAYER.IDLE:
            player_node_input_check();
            break;
        case E_STATES_PLAYER.MOVING:
            player_node_input_check();
            player_run();
            break;
        case E_STATES_PLAYER.TASK:
            if (not instance_exists(TaskParent)) {
                player_state_set(E_STATES_PLAYER.IDLE);
            }
            break;
    }
}

function player_draw() {
    draw_self();
}
function player_draw_end() {
    player_draw_prompt_tabs();
    player_draw_performance_bar();
}
function player_draw_prompt_tabs() {
    var _prompt_tab_x = prompt_tabs_begin_x;
    var _prompt_tab_y = prompt_tabs_begin_y;
    for (var _prompt_index = 0; _prompt_index < array_length(prompt_tabs); _prompt_index ++) {
        var _prompt_tab = prompt_tabs[_prompt_index];
        player_draw_prompt_tab(_prompt_tab_x, _prompt_tab_y, _prompt_index);
        _prompt_tab_y += prompt_tab_height;
        _prompt_tab.step_interpolate();
    }
}
function player_draw_prompt_tab(_x, _y, _prompt_tab_index) {
    var _prompt_tab = prompt_tabs[_prompt_tab_index];
    _prompt_tab.width_desired = prompt_length_base;
    if (_prompt_tab.alert_count > 0) {
        _prompt_tab.width_desired = prompt_length_alert;
    }

    var _bbox_left = _x;
    var _bbox_top = _y;
    var _bbox_right = (_x + _prompt_tab.width_current);
    var _bbox_bottom = (_y + prompt_tab_height);
    var _border_size = 1;
    draw_set_colour(c_black);
    draw_rectangle(_bbox_left, _bbox_top, _bbox_right, _bbox_bottom, false);
    draw_set_colour(_prompt_tab.colour_current);
    draw_rectangle(_bbox_left + _border_size, _bbox_top + _border_size,
                     _bbox_right - _border_size, _bbox_bottom - _border_size, false);

    switch (_prompt_tab.state) {
        case E_STATES_PROMPT_TAB.IDLE:
            _prompt_tab.colour_desired = c_black;
            break;
        case E_STATES_PROMPT_TAB.ACTIVE:
            _prompt_tab.colour_desired = merge_colour(c_navy, c_ltgray, 0.6);
            break;
    }

    draw_set_font(fntHud);
    draw_set_halign(fa_right);
    draw_set_valign(fa_middle);
    draw_text_perlin(
        _bbox_right - _border_size,
        mean(_bbox_top, _bbox_bottom),
        _prompt_tab.button_label,
        1.0, 0.5, 1.0, c_white, c_dkgray, 1.0, _prompt_tab_index * 32
    )

    draw_set_font(fntHudSmall);
    draw_text_perlin(
        _bbox_right - _border_size - 16,
        mean(_bbox_top, _bbox_bottom),
        _prompt_tab.description_label,
        1.0, 0.5, 1.0, c_white, c_dkgray, 0.5, _prompt_tab_index * 64
    );
}
function player_draw_performance_bar() {
    var _outline_width = 2;
    draw_set_colour(c_black);
    draw_rectangle(
        performance_bar_x1,
        performance_bar_y1,
        performance_bar_x2,
        performance_bar_y2, false);

    draw_healthbar(
        performance_bar_x1 + _outline_width,
        performance_bar_y1 + _outline_width,
        performance_bar_x2 - _outline_width,
        performance_bar_y2 - _outline_width,
        performance_value,
        c_black, c_maroon, c_red, 0, true, true);
}

function player_node_input_check() {
    var _key_checks = variable_struct_get_names(node_map);
    for (var _key_index = 0; _key_index < array_length(_key_checks); _key_index ++) {
        var _key_current = _key_checks[_key_index];
        var _node_current = node_map[$ _key_current];

        if (keyboard_check_pressed(ord(_key_current))) {
            if (node_current_instance == _node_current) {
                player_task_begin(_node_current);
                break;
            }
            player_node_move(_node_current);
        }
    }
}
function player_node_move(_node_instance) {
    show_debug_message("Moving to node: " + string(_node_instance.node_input));
    var _node_index = player_get_node_index_from_input(_node_instance.node_input);
    player_prompt_set_active(_node_index);
    var _target_x = _node_instance.x;
    var _target_y = _node_instance.y;
    node_current_instance = noone;
    node_target_instance = _node_instance;
    player_state_set(E_STATES_PLAYER.MOVING);
    mp_grid_path(global.pathfinding_grid, pathfinding_path, x, y, _target_x, _target_y, true);
    path_start(pathfinding_path, node_movement_speed, path_action_stop, false);
}
function player_depth_update() {
    depth = -y;
}
function player_state_set(_state) {
    if (state_current != _state) {
        state_previous = state_current;
        state_current = _state;
        state_tick = 0;
    }
}
function player_run() {
    if (path_index == -1) {
        player_run_end();
    }

    var _direction_current = sign(x - run_previous_x);
    if (_direction_current != 0) {
        image_xscale = _direction_current;
    }
    run_previous_x = x;

    var _gamespeed_fps = game_get_speed(gamespeed_fps);
    run_tick += (1 / _gamespeed_fps);
    if (run_tick >= run_tick_maximum) {
        player_run_tick_target();
    }
}
function player_run_end() {
    run_tick = 0;
    run_sound_index = 0;
    image_angle = 0;
    node_current_instance = node_target_instance;
    node_target_instance = noone;
    player_state_set(E_STATES_PLAYER.IDLE);
    player_run_sound_stop();
}
function player_run_sound_stop() {
    if (audio_is_playing(run_sound_instance_last)) {
        audio_stop_sound(run_sound_instance_last);
    }
}
function player_run_sound_play() {
    player_run_sound_stop();
    run_sound_index = (run_sound_index + 1) mod array_length(run_sound_array);
    run_sound_instance_last = audio_play_sound_on(
        audio_emitter, run_sound_array[run_sound_index],
        false, 1);
}
function player_run_tick_target() {
    run_tick = 0;
    player_run_sound_play();

    switch (run_sound_index) {
        case 0:
            image_angle = -15;
            break;
        case 1:
            image_angle = 15;
            break;
    }
}
function player_task_begin(_node_instance) {
    show_debug_message("Task begin at node: " + string(_node_instance.node_input));
    player_state_set(E_STATES_PLAYER.TASK);
    _node_instance.node_action();
}
function player_prompt_set_active(_prompt_index_active) {
    for (var _prompt_index_iteration = 0; _prompt_index_iteration < array_length(prompt_tabs); _prompt_index_iteration ++) {
        var _prompt_tab = prompt_tabs[_prompt_index_iteration];
        if (_prompt_tab.state == E_STATES_PROMPT_TAB.ACTIVE) {
            _prompt_tab.state = E_STATES_PROMPT_TAB.IDLE;
        }

        if (_prompt_index_iteration == _prompt_index_active) {
            _prompt_tab.state = E_STATES_PROMPT_TAB.ACTIVE;
        }
    }
}
function player_camera_modulate() {
    var _view_angle = wave(-1, 1, 20, 0);
    camera_set_view_angle(view_camera[0], _view_angle);
}
function player_audio_emitter_update() {
    // 1. GET CAMERA PROPERTIES
    var _cam = view_camera[0];
    var _cam_x = camera_get_view_x(_cam);
    var _cam_y = camera_get_view_y(_cam);
    var _cam_width = camera_get_view_width(_cam);
    var _cam_height = camera_get_view_height(_cam);

    // 2. CALCULATE CAMERA CENTER
    var _cam_center_x = _cam_x + (_cam_width / 2);
    var _cam_center_y = _cam_y + (_cam_height / 2);

    // 3. SET LISTENER POSITION
    // The listener is positioned relative to the camera's center.
    var _listener_x = _cam_center_x;
    var _listener_y = LISTENER_HEIGHT;
    var _listener_z = _cam_center_y - LISTENER_SETBACK;

    audio_listener_set_position(0, _listener_x, _listener_y, _listener_z);

    // 4. SET LISTENER ORIENTATION
    // The listener looks from its high position down at the center of the view.
    var _look_target_x = _cam_center_x;
    var _look_target_y = 0; // Target is on the "ground".
    var _look_target_z = _cam_center_y;

    var _look_vec_x = _look_target_x - _listener_x; // = 0
    var _look_vec_y = _look_target_y - _listener_y; // = -LISTENER_HEIGHT
    var _look_vec_z = _look_target_z - _listener_z; // = LISTENER_SETBACK

    // The "up" vector should be (0, 1, 0) for a level head.
    // Using -1 for Y would mean the listener is upside down.
    var _up_vec_x = 0;
    var _up_vec_y = -1;
    var _up_vec_z = 0;

    audio_listener_set_orientation(0, _look_vec_x, _look_vec_y, _look_vec_z, _up_vec_x, _up_vec_y, _up_vec_z);
    audio_emitter_position(
        audio_emitter, x, 0, y
    );
}

function player_get_node_index_from_input(_input) {
    var _real = real(_input);
    return (_real - 1);
}