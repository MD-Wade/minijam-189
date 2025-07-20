function task_fax_machine_init() {
    task_parent_init_state();
    task_parent_init_title(true);
    task_fax_machine_init_scene();
    task_fax_machine_init_paper();

    title_text = "FAX MACHINE";
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
function task_fax_machine_init_paper() {
    paper_base_x = 110;
    paper_base_y = 145;
    var _number_direction = point_direction(0, 0, 15, 20);
    paper_number_x = paper_base_x + lengthdir_x(48, _number_direction);
    paper_number_y = paper_base_y + lengthdir_y(48, _number_direction);
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

function task_fax_machine_draw() {
    task_parent_draw_background();
    task_parent_draw_title();
    task_fax_machine_draw_scene();
}
function task_fax_machine_draw_scene() {
    var _current_pos_x = lerp(scene_begin_x, scene_target_x, state_tick_tween);
    var _current_pos_y = lerp(scene_begin_y, scene_target_y, state_tick_tween);

    draw_sprite(sSceneFaxMachine, 0, _current_pos_x, _current_pos_y);
    task_fax_machine_draw_paper();
    draw_sprite(sSceneFaxMachine, 2, _current_pos_x, _current_pos_y);

    var _hand_pos_x = lerp(hand_start_x, mouse_x, state_tick_tween);
    var _hand_pos_y = lerp(hand_start_y, mouse_y, state_tick_tween);
}
function task_fax_machine_draw_paper() {
    // --- Your Original Logic ---
    var _current_pos_x = lerp(scene_begin_x, scene_target_x, state_tick_tween);
    var _current_pos_y = lerp(scene_begin_y, scene_target_y, state_tick_tween);
    var _paper_header_x = _current_pos_x + paper_base_x;
    var _paper_header_y = _current_pos_y + paper_base_y;
    var _paper_number_x = _current_pos_x + paper_number_x;
    var _paper_number_y = _current_pos_y + paper_number_y;

    draw_set_font(fntFaxHeader);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_colour(c_black);
    draw_set_alpha(1.0);

    draw_sprite(sSceneFaxMachine, 1, _current_pos_x, _current_pos_y);
    draw_text_transformed(_paper_header_x, _paper_header_y, "photograph of cookie", 
        1.0, 1.0, 10);
    draw_text_transformed(_paper_number_x, _paper_number_y, 
        string("(256) 281-1234"), 0.8, 0.8, 10);
}

function task_fax_machine_minigame_entry() {
    task_parent_minigame_entry(TaskFaxMachine);
}