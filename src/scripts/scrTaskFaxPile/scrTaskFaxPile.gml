function task_fax_pile_init() {
    task_parent_init();
    task_parent_init_object(sTaskObjectFaxPile);
    task_fax_pile_init_dialogue();

    title_text = "FAX PILE";
}
function task_fax_pile_init_dialogue() {
    dialogue_box_x1 = (80);
    dialogue_box_x2 = (room_width - 192);
    dialogue_box_y1 = (8);
    dialogue_box_y2 = (92);
    dialogue_text_x = (dialogue_box_x1 + 8);
    dialogue_text_y = (dialogue_box_y1 + 8);
    dialogue_box_width = (dialogue_box_x2 - dialogue_box_x1);
    dialogue_box_height = (dialogue_box_y2 - dialogue_box_y1);
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
    task_fax_pile_draw_text();
    task_parent_draw_title();
}
function task_fax_pile_draw_text() {
    var _box_outline_width = 2;
    draw_set_font(fntPhoneDialogue);
    draw_set_alpha(1.0);

    draw_set_colour(c_white);
    draw_rectangle(
        dialogue_box_x1 - _box_outline_width, 
        dialogue_box_y1 - _box_outline_width, 
        dialogue_box_x2 + _box_outline_width, 
        dialogue_box_y2 + _box_outline_width, 
        false);
    draw_set_colour(c_black);
    draw_rectangle(
        dialogue_box_x1,
        dialogue_box_y1,
        dialogue_box_x2,
        dialogue_box_y2,
        false);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);

    var _string_current = "THE FAX PILE CURRENTLY HOLDS " + string(global.fax_pile_count) + " FAXES.\nTAKE THEM?"
    if (global.fax_pile_count <= 0) {
        _string_current = "NO FAXES TO TAKE.";
    }

    draw_text_perlin(
        dialogue_text_x, 
        dialogue_text_y, 
        _string_current,
        1.0, 0.5, 1.0, c_white, c_dkgray, 1
    );
}


function task_fax_pile_minigame_entry() {
    task_parent_minigame_entry(TaskFaxPile);
}