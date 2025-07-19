function task_fax_pile_init() {
    task_parent_init();
    task_parent_init_object(sTaskObjectFaxPile);

    title_text = "FAX PILE";
}

function task_fax_pile_step() {
    switch (state_current) {
        case E_STATES_TASK_PARENT.TRANSITION_IN:
            task_parent_step_state_transition_in();
            break;
        case E_STATES_TASK_PARENT.MINIGAME:
            if (keyboard_check_pressed(vk_escape)) {
                show_debug_message("Escape pressed, exiting fax pile task.");
                instance_destroy();
            }
            break;
    }
}

function task_fax_pile_draw() {
    task_parent_draw_background();
    task_parent_draw_object();
    task_parent_draw_title();
}

function task_fax_pile_minigame_entry() {
    task_parent_minigame_entry(TaskFaxPile);
}