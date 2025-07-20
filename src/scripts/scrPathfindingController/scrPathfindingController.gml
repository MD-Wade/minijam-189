function pathfinding_controller_init() {
    global.pathfinding_grid = undefined;
}
function pathfinding_controller_init_room() {
    var _grid_cell_width = 16;
    var _grid_cell_height = 16;
    room_buffer_width = (_grid_cell_width * 16);
    room_buffer_height = (_grid_cell_height * 12);
    pathfinding_grid_width = (room_width + (room_buffer_width * 2)) div _grid_cell_width;
    pathfinding_grid_height = (room_height + (room_buffer_height * 2)) div _grid_cell_height;
    var _begin_x = (room_buffer_width * -1);
    var _begin_y = (room_buffer_height * -1);
    global.pathfinding_grid = mp_grid_create(_begin_x, _begin_y, pathfinding_grid_width, pathfinding_grid_height, _grid_cell_width, _grid_cell_height);
    mp_grid_add_instances(global.pathfinding_grid, Solid, true);
}

function pathfinding_controller_room_start() {
    pathfinding_controller_destroy();

    switch (room) {
        case roomDemo:
            pathfinding_controller_init_room();
            break;
    }
}

function pathfinding_controller_destroy() {
    if not is_undefined(global.pathfinding_grid) {
        mp_grid_destroy(global.pathfinding_grid);
        global.pathfinding_grid = undefined;
    }
}