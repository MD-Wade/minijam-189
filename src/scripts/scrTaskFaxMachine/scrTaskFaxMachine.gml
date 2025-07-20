function task_fax_machine_init() {
    task_parent_init();
    task_fax_machine_init_scene();

    title_text = "FAX MACHINE";
}

function task_fax_machine_step() {
    switch (state_current) {
        case E_STATES_TASK_PARENT.TRANSITION_IN:
            task_parent_step_state_transition_in();
            break;
        case E_STATES_TASK_PARENT.MINIGAME:
            if (keyboard_check_pressed(vk_escape)) {
                show_debug_message("Escape pressed, exiting fax machine task.");
                instance_destroy();
            }
            break;
    }
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

function task_fax_machine_draw() {
    task_parent_draw_background();
    task_parent_draw_title();
    task_fax_machine_draw_scene();
}
function task_fax_machine_draw_scene() {
    var _current_pos_x = lerp(scene_begin_x, scene_target_x, state_tick_tween);
    var _current_pos_y = lerp(scene_begin_y, scene_target_y, state_tick_tween);

    draw_sprite(sSceneFaxMachine, 0, _current_pos_x, _current_pos_y);
    draw_sprite(sSceneFaxMachine, 1, _current_pos_x, _current_pos_y);

    var _hand_pos_x = lerp(hand_start_x, mouse_x, state_tick_tween);
    var _hand_pos_y = lerp(hand_start_y, mouse_y, state_tick_tween);
    draw_sprite(sTaskHandFaxMachine, 0, _hand_pos_x, _hand_pos_y);
}

function task_fax_machine_minigame_entry() {
    task_parent_minigame_entry(TaskFaxMachine);
}