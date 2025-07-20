enum E_STATES_NPC_CONTROLLER {
    INACTIVE,
    GAME,
    COOKIES
}

function npc_controller_init() {
    npc_controller_init_spawn();
    npc_controller_init_state();
    npc_controller_init_variants();
}
function npc_controller_init_state() {
    state_current = E_STATES_NPC_CONTROLLER.INACTIVE;
    state_previous = E_STATES_NPC_CONTROLLER.INACTIVE;
    state_tick = 0;
    state_tick_maximum = random_range(spawn_time_minimum, spawn_time_maximum);
}
function npc_controller_init_spawn() {
    spawn_time_minimum = 0.25;
    spawn_time_maximum = 2.5;
}
function npc_controller_init_variants() {
    npc_variant_sprites = [
        sNpc1,
        sNpc2,
        sNpc3,
        sNpc4,
        sNpc5,
        sNpc6,
        sNpc7,
        sNpc8,
        sNpc9,
        sNpc10,
    ];
}
function npc_controller_init_nodes() {
    global.node_fax_pile = Node2;
    global.node_cookies = Node5;
    global.node_npc_cookies = NodeNpc4;

    global.nodes_npcs = [];
    var _nodes_npcs_count = instance_number(NodeNpc);
    for (var _node_npc_index = 0; _node_npc_index < _nodes_npcs_count; _node_npc_index ++) {
        var _node_npc = instance_find(NodeNpc, _node_npc_index);
        array_push(global.nodes_npcs, _node_npc);
    }
}

function npc_controller_step() {
    switch (state_current) {
        case E_STATES_NPC_CONTROLLER.INACTIVE:
            npc_controller_step_state_inactive();
            break;
        case E_STATES_NPC_CONTROLLER.GAME:
            npc_controller_step_state_game();
            break;
        case E_STATES_NPC_CONTROLLER.COOKIES:
            npc_controller_step_state_cookies();
            break;
    }
}
function npc_controller_step_state_inactive() {
    // Nothin', this is like for menus and stuff
}
function npc_controller_step_state_game() {
    var _gamespeed_fps = game_get_speed(gamespeed_fps)
    state_tick += (1 / _gamespeed_fps);

    if (state_tick >= state_tick_maximum) {
        state_tick = 0;
        state_tick_maximum = random_range(spawn_time_minimum, spawn_time_maximum);
        npc_controller_spawn_npc();
    }
}
function npc_controller_room_start() {
	switch (room) {
		case roomDemo:
			npc_controller_init_nodes();
            npc_controller_state_set(E_STATES_NPC_CONTROLLER.GAME);
            break;
	}
}

function npc_controller_spawn_npc() {
    var _exit_node_index;
    var _spawn_node_index = irandom(array_length(global.nodes_npcs) - 1);
    var _spawn_node = global.nodes_npcs[_spawn_node_index];
    do {
        _exit_node_index = irandom(array_length(global.nodes_npcs) - 1);
    } until (_exit_node_index != _spawn_node_index);

    var _exit_node = global.nodes_npcs[_exit_node_index];
    var _npc_instance = instance_create_layer(_spawn_node.x, _spawn_node.y, "WorldObjects", Npc, {
        node_exit: _exit_node,
        node_spawn: _spawn_node
    });
    _npc.sprite_index = npc_controller_get_variant_sprite();
}

function npc_controller_state_set(_state) {
    state_previous = state_current;
    state_current = _state;
    state_tick = 0;
}
function npc_controller_get_variant_sprite() {
    var _variant_index = irandom(array_length(npc_variant_sprites) - 1);
    return npc_variant_sprites[_variant_index];
}