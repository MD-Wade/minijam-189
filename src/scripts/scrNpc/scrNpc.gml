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
}
function npc_init_state() {
    state_current = E_STATES_NPC.WALK_TO_TARGET;
    state_previous = E_STATES_NPC.WALK_TO_TARGET;
    state_tick = 0;
    state_tick_maximum = 0.5;
}
function npc_init_pathfinding() {
    pathfinding_path = path_add();
    pathfinding_speed = 2.8;
}
function npc_init_target() {
    var _probability_fax = 40;                                          // 40% Chance of going to Fax Pile
    var _probability_cookies = 40;                                      // 40% Chance of going to Cookies (after Fax)
    var _probability_dawdle = 20;                                       // 20% Chance of just dawdling around (after Fax and Cookies)
    var _spawned_at_cookies = (node_spawn == global.node_npc_cookies);  // If spawned at Cookies, don't go there again

    if (irandom(100) < _probability_fax) {
        node_target_instance = global.node_fax_pile;
        node_target_type = E_NPC_TARGETS.FAX_PILE;
    } else if (irandom(100) < _probability_cookies) and (not _spawned_at_cookies) {
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
}
function npc_init_audio_emitter() {
    audio_emitter = audio_emitter_create();
    audio_emitter_falloff(audio_emitter, 32, 240, 1.0);
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
    draw_self();
}

function npc_cleanup() {
    if (not is_undefined(pathfinding_path)) {
        path_delete(pathfinding_path);
        pathfinding_path = undefined;
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

    mp_grid_path(
        global.pathfinding_grid,
        pathfinding_path,
        x,
        y,
        _target_x,
        _target_y,
        true
    );
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

    var _gamespeed_fps = game_get_speed(gamespeed_fps);
    run_tick += (1 / _gamespeed_fps);
    if (run_tick >= run_tick_maximum) {
        npc_run_tick_target();
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
        audio_emitter, run_sound_array[run_sound_index],
        false, 1, 0.92, 0, 0.65);
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
    do {
        var _desired_x = irandom(room_width);
        var _desired_y = irandom(room_height);
        var _desired_place_is_free = not place_meeting(_desired_x, _desired_y, WorldObject);
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