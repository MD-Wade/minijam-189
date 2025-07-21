function task_fax_pile_init() {
    task_parent_init();
    task_fax_pile_init_dialogue();
    task_fax_pile_init_orders();

    title_text = "FAX PILE";
}
function task_fax_pile_init_dialogue() {
    dialogue_box_x1 = (80);
    dialogue_box_x2 = (room_width - 192);
    dialogue_box_y1 = (8);
    dialogue_box_y2 = (40);
    dialogue_text_x = (dialogue_box_x1 + 8);
    dialogue_text_y = (dialogue_box_y1 + 8);
    dialogue_box_width = (dialogue_box_x2 - dialogue_box_x1);
    dialogue_box_height = (dialogue_box_y2 - dialogue_box_y1);
}
function task_fax_pile_init_orders() {
    order_selection = 0;
    order_start_x = dialogue_box_x1;
    order_start_y = dialogue_box_y2 + 24;
    order_width = (dialogue_box_width + 128);
    order_height = 20;
}

function task_fax_pile_step() {
    switch (state_current) {
        case E_STATES_TASK_PARENT.TRANSITION_IN:
            task_parent_step_state_transition_in();
            break;
        case E_STATES_TASK_PARENT.MINIGAME:
            task_fax_pile_step_minigame();
            break;
    }
}
function task_fax_pile_step_minigame() {
    task_fax_pile_step_input();

    if (keyboard_check_pressed(vk_escape)) {
        show_debug_message("Escape pressed, exiting fax pile task.");
        instance_destroy();
    }
}
function task_fax_pile_step_input() {
    if (array_length(global.fax_pile_orders) <= 0) {
        order_selection = 0;
        return;
    }

    if (keyboard_check_pressed(vk_up)) {
        order_selection --;
        audio_play_sound(sndUiSelection, 1, false);
        if (order_selection < 0) {
            order_selection = array_length(global.fax_pile_orders) - 1;
        }
    }

    if (keyboard_check_pressed(vk_down)) {
        order_selection ++;
        audio_play_sound(sndUiBack, 1, false);
        if (order_selection >= array_length(global.fax_pile_orders)) {
            order_selection = 0;
        }
    }

    if (keyboard_check_pressed(vk_space) or keyboard_check_pressed(vk_enter)) {
        global.fax_held = global.fax_pile_orders[order_selection];
        array_delete(global.fax_pile_orders, order_selection, 1);
        audio_play_sound(sndUiConfirm, 1, false);
        with (FaxPileController) {
            fax_pile_controller_update_stacks();
        }
        instance_destroy();
    }
}

function task_fax_pile_draw() {
    task_parent_draw_background();
    //task_parent_draw_object();
    task_fax_pile_draw_text();
    task_fax_pile_draw_orders();
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

    var _string_current = "SELECT AN ORDER TO FAX.";
    if (array_length(global.fax_pile_orders) <= 0) {
        _string_current = "NO ORDERS TO FAX.";
    }

    draw_text_perlin(
        dialogue_text_x, 
        dialogue_text_y, 
        _string_current,
        1.0, 0.5, 1.0, c_white, c_dkgray, 1
    );
}
function task_fax_pile_draw_orders() {
    var _order_count = array_length(global.fax_pile_orders);
    var _order_x = order_start_x;
    var _order_y = order_start_y;

    if (_order_count <= 0) {
        return;
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_font(fntFaxOrderList);
    for (var _order_index = 0; _order_index < _order_count; _order_index ++) {
        var _order_struct = global.fax_pile_orders[_order_index];
        var _order_selected = (_order_index == order_selection);
        var _order_text = string(_order_struct.pages_count) + " pages | "  + _order_struct.fax_number_formatted + " | " + _order_struct.fax_title;

        var _outline_width = 1;
        var _bbox_top = _order_y;
        var _bbox_left = _order_x;
        var _bbox_right = _order_x + order_width;
        var _bbox_bottom = _order_y + order_height;
        var _text_x = _order_x + 8;
        var _text_y = mean(_bbox_top, _bbox_bottom);

        draw_set_colour(c_black);
        draw_rectangle(_bbox_left, _bbox_top, _bbox_right, _bbox_bottom, false);
        draw_set_colour(_order_selected ? c_ltgray : c_dkgray);
        draw_rectangle(_bbox_left + _outline_width, 
            _bbox_top + _outline_width, 
            _bbox_right - _outline_width, 
            _bbox_bottom - _outline_width, 
            false);
        draw_set_colour(c_white);
        draw_text_perlin(_text_x, _text_y, _order_text, 2.0, 0.1, 4.0, c_white, c_black, 0.5);

        _order_y += order_height;
    }

}

function task_fax_pile_minigame_entry() {
    if (not is_undefined(global.fax_held)) {
        array_insert(global.fax_pile_orders, 0, global.fax_held);
    }
    with (FaxPileController) {
        fax_pile_controller_update_stacks();
    }
    global.fax_held = undefined;
    task_parent_minigame_entry(TaskFaxPile);
}