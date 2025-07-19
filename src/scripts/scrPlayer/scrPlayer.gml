enum E_STATES_PLAYER {
    IDLE,
    MOVING,
    TASK,
}

function player_init() {
    player_init_node();
    player_init_pathfinding();
    player_init_run();
    player_init_state();
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
    var _grid_cell_width = 32;
    var _grid_cell_height = 24;
    var _grid_width = room_width div _grid_cell_width;
    var _grid_height = room_height div _grid_cell_height;
    pathfinding_grid = mp_grid_create(0, 0, _grid_width, _grid_height, _grid_cell_width, _grid_cell_height);
    pathfinding_path = path_add();
    mp_grid_add_instances(pathfinding_grid, Wall, true);
}
function player_init_run() {
    run_sound_array = [sndPlayerRun1, sndPlayerRun2];
    run_sound_index = 0;
    run_sound_instance_last = -1;
    run_tick = 0;
    run_tick_maximum = 0.35;
}
function player_init_state() {
    state_current = E_STATES_PLAYER.IDLE;
    state_previous = E_STATES_PLAYER.IDLE;
    state_tick = 0;
    state_tick_maximum = 0.5;
}

function player_step() {
    player_depth_update();

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
    var _target_x = _node_instance.x;
    var _target_y = _node_instance.y;
    node_current_instance = noone;
    node_target_instance = _node_instance;
    player_state_set(E_STATES_PLAYER.MOVING);
    mp_grid_path(pathfinding_grid, pathfinding_path, x, y, _target_x, _target_y, false);
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

    run_tick += (1 / room_speed);
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
    run_sound_instance_last = audio_play_sound(run_sound_array[run_sound_index], 0, false);
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
function player_camera_modulate() {
    var _view_angle = wave(-1, 1, 20, 0);
    camera_set_view_angle(view_camera[0], _view_angle);
}