enum E_STATES_NPC {
    WALK_TO_TARGET,
    ACTION,
    EXIT
}
enum E_NPC_TARGETS {
    FAX_PILE,
    COOKIES,
    DAWDLE
}

function npc_init() {
    npc_init_state();
    npc_init_pathfinding();
    npc_init_target();
    npc_init_run();
    npc_init_dawdle();
    npc_init_audio_emitter();
    npc_init_variant();
}
function npc_init_state() {
    state_current = E_STATES_NPC.WALK_TO_TARGET;
    state_previous = E_STATES_NPC.WALK_TO_TARGET;
    state_tick = 0;
    state_tick_maximum = 0.5;
}
function npc_init_pathfinding() {
    pathfinding_path = path_add();
    pathfinding_speed = 1.8;
}
function npc_init_target() {
    var _probability_fax = 40;                                          // 40% Chance of going to Fax Pile
    var _probability_cookies = 40;                                      // 40% Chance of going to Cookies (after Fax)
    var _probability_dawdle = 20;                                       // 20% Chance of just dawdling around (after Fax and Cookies)

    if (irandom(100) < _probability_fax) {
        node_target_instance = global.node_fax_pile;
        node_target_type = E_NPC_TARGETS.FAX_PILE;
        sprite_index = sNpcFax;
    } else if (irandom(100) < _probability_cookies) {
        node_target_instance = global.node_cookies;
        node_target_type = E_NPC_TARGETS.COOKIES;
    } else {
        node_target_instance = undefined;
        node_target_type = E_NPC_TARGETS.DAWDLE;
    }

    node_pathfind_to_target();
    node_current_instance = noone;
}
function npc_init_dawdle() {
    dawdle_time = random_range(1.5, 3.5);
}
function npc_init_run() {
    run_sound_array = [sndPlayerRun1, sndPlayerRun2];
    run_sound_index = 0;
    run_sound_instance_last = -1;
    run_tick = 0;
    run_tick_maximum = 0.42;
    run_previous_x = x;
}
function npc_init_audio_emitter() {
    audio_emitter = audio_emitter_create();
    audio_emitter_falloff(audio_emitter, 32, 240, 1.0);
}
function npc_init_variant() {
    image_speed = 0;
    image_index = irandom(image_number - 1);
}

function npc_step() {
    npc_depth_update();
    npc_audio_emitter_update();

    switch (state_current) {
        case E_STATES_NPC.WALK_TO_TARGET:
            npc_step_state_walk_to_target();
            break;
        case E_STATES_NPC.ACTION:
            npc_step_state_action();
            break;
        case E_STATES_NPC.EXIT:
            npc_step_state_exit();
            break;
    }
}
function npc_step_state_walk_to_target() {
    npc_run();

    if (path_index < 0) {
        npc_run_end();
        return;
    }
}
function npc_step_state_action() {
    var _gamespeed_fps = game_get_speed(gamespeed_fps);
    state_tick += (1 / _gamespeed_fps);
    if (state_tick >= state_tick_maximum) {
        npc_state_set(E_STATES_NPC.EXIT);
        npc_action_complete();
        node_pathfind_to_exit();
    }
}
function npc_step_state_exit() {
    npc_run();

    if (path_index < 0) {
        instance_destroy();
    }
}

function npc_draw() {
	draw_set_colour(c_black);
	draw_set_alpha(0.25);
	
	var _shadow_x1 = (x - 12);
	var _shadow_y1 = (y + 6);
	var _shadow_x2 = (x + 12);
	var _shadow_y2 = (y + 10);
	
	draw_ellipse(_shadow_x1, _shadow_y1, _shadow_x2, _shadow_y2, false);
	draw_set_colour(c_white);
	draw_set_alpha(1.0);
    draw_self();
}

function npc_cleanup() {
    if (not is_undefined(pathfinding_path)) {
        path_delete(pathfinding_path);
        pathfinding_path = undefined;
    }
    if (not is_undefined(audio_emitter)) {
        audio_emitter_free(audio_emitter);
        audio_emitter = undefined;
    }
}

function npc_state_set(_state) {
    state_previous = state_current;
    state_current = _state;
    state_tick = 0;
}
function node_pathfind_to_target() {
    var _target_x, _target_y;
    switch (node_target_type) {
        case E_NPC_TARGETS.DAWDLE:
            var _free_space = npc_get_free_space();
            _target_x = _free_space.x;
            _target_y = _free_space.y;
            break;

        default:
            _target_x = node_target_instance.x;
            _target_y = node_target_instance.y;
            break;
    }

    var _pathfinding_result = false;
    do {
        var _destination_x = _target_x + irandom_range(-16, 16);
        var _destination_y = _target_y + irandom_range(-16, 16);

        _pathfinding_result = mp_grid_path(
            global.pathfinding_grid,
            pathfinding_path,
            x, y,
            _destination_x, _destination_y,
            true);
        
    } until (_pathfinding_result);
    path_start(pathfinding_path, pathfinding_speed, path_action_stop, false);
}
function node_pathfind_to_exit() {
    mp_grid_path(
        global.pathfinding_grid,
        pathfinding_path,
        x,
        y,
        node_exit.x,
        node_exit.y,
        true
    );
    path_start(pathfinding_path, pathfinding_speed, path_action_stop, false);
}
function npc_depth_update() {
    depth = -y;
}
function npc_run() {
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
function npc_run_end() {
    run_tick = 0;
    run_sound_index = 0;
    image_angle = 0;
    node_current_instance = node_target_instance;
    node_target_instance = noone;

    var _desired_state = E_STATES_NPC.EXIT;
    switch (state_current) {
        case E_STATES_NPC.WALK_TO_TARGET:
            _desired_state = E_STATES_NPC.ACTION;
            state_tick_maximum = dawdle_time;
            break;
    }
    npc_state_set(_desired_state);
    npc_run_sound_stop();
}
function npc_run_sound_stop() {
    if (audio_is_playing(run_sound_instance_last)) {
        audio_stop_sound(run_sound_instance_last);
    }
}
function npc_run_sound_play() {
    npc_run_sound_stop();
    run_sound_index = (run_sound_index + 1) mod array_length(run_sound_array);
    
    run_sound_instance_last = audio_play_sound_on(
        audio_emitter, 
        run_sound_array[run_sound_index],
        false, 
        1, 
        0.92, 
        0, 
        0.65
    );
}
function npc_run_tick_target() {
    run_tick = 0;
    npc_run_sound_play();

    switch (run_sound_index) {
        case 0:
            image_angle = -15;
            break;
        case 1:
            image_angle = 15;
            break;
    }
}
function npc_get_free_space() {
    var _maximum_attempt_count = 100;
    do {
        var _desired_x = irandom(room_width / 2);
        var _desired_y = irandom(room_height);
        _maximum_attempt_count --;
        if (_maximum_attempt_count <= 0) {
            show_debug_message("Failed to find free space for NPC after " + _attempt_count + " attempts.");
            instance_destroy();
            return { x: _desired_x, y: _desired_y };
        }
        var _desired_place_is_free = not place_meeting(_desired_x, _desired_y, WorldObject) or (_maximum_attempt_count <= 0);
    } until (_desired_place_is_free);
    
    return {
        x: _desired_x,
        y: _desired_y
    }
}
function npc_audio_emitter_update() {
    audio_emitter_position(
        audio_emitter, x, 0, y
    );
}
function npc_action_complete() {
    switch (node_target_type) {
        case E_NPC_TARGETS.FAX_PILE:
            fax_pile_controller_add_order();
            sprite_index = sNpc;
            break;
    }
}