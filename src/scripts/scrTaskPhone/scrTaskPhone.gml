function TaskPhoneResponse(_text, _performance_penalty=0) constructor {
    self.text = _text;
    self.performance_penalty = _performance_penalty;
}
function TaskPhoneConversation(_dialogue_incoming, _response_options) constructor {
    self.dialogue_incoming = _dialogue_incoming;
    self.response_options = _response_options;
}

global.task_pool_phone_conversations = [];
array_push(global.task_pool_phone_conversations, new TaskPhoneConversation(
    "Hello? Is this thing on? ...Hello? Can you hear me?\n" +
    "... Ah, yes. Hello. Sorry. I need that TPS report.",
    [
        new TaskPhoneResponse("Let me put you through to accounting...", 0),    // 0 indicates correct response
        new TaskPhoneResponse("Who is this?", -5),
        new TaskPhoneResponse("You, and everyone else around here...", -10),
        new TaskPhoneResponse("Gonna need you to speak up for me, bud.", -8)
    ]
));

function task_phone_init() {
	task_parent_init();
    task_parent_init_object(sprite_index);
    task_phone_init_text();
    task_phone_init_conversation();

    title_text = "PHONE";
    audio_play_sound(sndPhoneBegin, 1, false);
}
function task_phone_init_text() {
    dialogue_incoming_box_x1 = (80);
    dialogue_incoming_box_x2 = (room_width - 192);
    dialogue_incoming_box_y1 = (8);
    dialogue_incoming_box_y2 = (92);
    dialogue_incoming_text_x = (dialogue_incoming_box_x1 + 8);
    dialogue_incoming_text_y = (dialogue_incoming_box_y1 + 8);
    dialogue_box_width = (dialogue_incoming_box_x2 - dialogue_incoming_box_x1);
    dialogue_box_height = (dialogue_incoming_box_y2 - dialogue_incoming_box_y1);

    dialogue_incoming = undefined;
    dialogue_char_index = 0;
    dialogue_incoming_tick = 0;
    dialogue_incoming_tick_maximum = 0.05;
    dialogue_incoming_string_current = "";
}
function task_phone_init_conversation() {
    conversation = task_phone_get_conversation(1.0);
    dialogue_incoming = auto_line_break(conversation.dialogue_incoming, dialogue_box_width / 2);
    dialogue_response_options = conversation.response_options;
}

function task_phone_step() {
    switch (state_current) {
        case E_STATES_TASK_PARENT.TRANSITION_IN:
            task_parent_step_state_transition_in();
            break;
        case E_STATES_TASK_PARENT.MINIGAME:
            task_phone_step_state_minigame();
            break;
    }
}


function task_phone_step_state_minigame() {
    if (dialogue_char_index < string_length(dialogue_incoming)) {
        var _character_current = string_char_at(dialogue_incoming, dialogue_char_index);
        var _dialogue_speed = task_phone_get_dialogue_speed(_character_current);
        var _current_speed = (1 / game_get_speed(gamespeed_fps)) * _dialogue_speed;

        dialogue_incoming_tick += _current_speed;
        while (dialogue_incoming_tick >= dialogue_incoming_tick_maximum) {
            dialogue_incoming_tick -= dialogue_incoming_tick_maximum;
            dialogue_char_index ++;
        }

        dialogue_incoming_string_current = string_copy(dialogue_incoming, 1, dialogue_char_index);
    }

    var _buttons_to_check = array_length(dialogue_response_options);
    for (var _button_index = 0; _button_index < _buttons_to_check; _button_index++) {
        var _button_string = string(_button_index + 1);
        if (keyboard_check_pressed(ord(_button_string))) {
            var _response_data = dialogue_response_options[_button_index];
            show_debug_message("Response selected: " + _response_data.text);
            task_phone_select_response(_button_index);
        }
    }
}

function task_phone_draw() {
    task_parent_draw_background();
    task_parent_draw_object();
    task_parent_draw_title();
    task_phone_draw_text();
    task_phone_draw_response_options();
}


function task_phone_draw_text() {
    var _box_outline_width = 2;
    draw_set_font(fntPhoneDialogue);
    draw_set_alpha(1.0);

    draw_set_colour(c_white);
    draw_rectangle(
        dialogue_incoming_box_x1 - _box_outline_width, 
        dialogue_incoming_box_y1 - _box_outline_width, 
        dialogue_incoming_box_x2 + _box_outline_width, 
        dialogue_incoming_box_y2 + _box_outline_width, 
        false);
    draw_set_colour(c_black);
    draw_rectangle(
        dialogue_incoming_box_x1,
        dialogue_incoming_box_y1,
        dialogue_incoming_box_x2,
        dialogue_incoming_box_y2,
        false);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);

    draw_text_perlin(
        dialogue_incoming_text_x, 
        dialogue_incoming_text_y, 
        dialogue_incoming_string_current,
        1.0, 0.5, 1.0, c_white, c_dkgray, 1
    );
}
function task_phone_draw_response_options() {
    // --- Layout Variables ---
    var _response_box_start_x = dialogue_incoming_box_x1;
    var _response_box_start_y = room_height - 128;
    var _response_box_width = dialogue_incoming_box_x2 - _response_box_start_x - 16;
    var _response_box_height = 32;
    var _response_x = _response_box_start_x;
    var _response_y = _response_box_start_y;

    // --- Drawing Loop ---
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_font(fntPhoneResponse);
    draw_set_alpha(1.0);
    var _options_count = array_length(dialogue_response_options);
    for (var _option_index = 0; _option_index < _options_count; _option_index ++) {
        var _option_index_reversed = (_options_count - 1) - _option_index;
        var _response_data = dialogue_response_options[_option_index_reversed];

        var _response_text = _response_data.text;
        var _bbox_top = _response_y - _response_box_height;
        var _bbox_bottom = _response_y;
        var _bbox_left = _response_x;
        var _bbox_right = _response_x + _response_box_width;
        var _text_x = _bbox_left + 8;
        var _text_y = mean(_bbox_top, _bbox_bottom);
        var _text_shown = "[" + string(_option_index_reversed + 1) + "] " + _response_text;

        draw_set_colour(c_black);
        draw_rectangle(_bbox_left, _bbox_top, _bbox_right, _bbox_bottom, false);
        draw_set_colour(c_white);
        draw_text(_text_x, _text_y, _text_shown);

        _response_y -= _response_box_height;
    }
}

function task_phone_get_dialogue_speed(_character_current) {
    switch (_character_current) {
        case ".":
        case "!":
        case "?":
            return 0.1;
        case ",":
            return 0.35;
        case " ":
            return 0.75;
        default:
            return 1.0;
    }
}
function task_phone_get_conversation(_difficulty_weight=1.0) {
    var _task_random_index = irandom(array_length(global.task_pool_phone_conversations) - 1);
    return global.task_pool_phone_conversations[_task_random_index];
}

function task_phone_select_response(_response_index) {
    if (dialogue_response_options == undefined) return;
	if (_response_index < 0) return;
	if (_response_index >= array_length(dialogue_response_options)) return;

    audio_play_sound(sndPhoneEnd, 1, false);
    instance_destroy();
}

function task_phone_minigame_entry() {
	task_parent_minigame_entry(TaskPhone);
}