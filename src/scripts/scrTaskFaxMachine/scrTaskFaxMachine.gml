function task_fax_machine_init() {
    task_parent_init();
    task_parent_init_object(sprite_index);

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

function task_fax_machine_draw() {
    task_parent_draw_background();
    task_parent_draw_object();
    task_parent_draw_title();
}

function task_fax_machine_minigame_entry() {
    task_parent_minigame_entry(TaskFaxMachine);
}