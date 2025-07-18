function player_init() {
    player_init_node();
    player_init_pathfinding();
}
function player_init_node() {
    node_movement_speed = 4;
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

function player_step() {
    player_node_input_check();
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
            player_node_move(_node_current);
        }
    }
}
function player_node_move(_node_instance) {
    show_debug_message("Moving to node: " + string(_node_instance.node_input));
    var _target_x = _node_instance.x;
    var _target_y = _node_instance.y;
    mp_grid_path(pathfinding_grid, pathfinding_path, x, y, _target_x, _target_y, true);
    path_start(pathfinding_path, node_movement_speed, path_action_stop, false);
}
function player_depth_update() {
    depth = -y;
}