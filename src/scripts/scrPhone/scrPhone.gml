enum E_STATES_PHONE {
	IDLE, LINE_INCOMING, IN_USE
}

function phone_init() {
	depth -= 24;
	
	tick_current = 0;
	tick_maximum = 4;
	state_current = E_STATES_PHONE.IDLE;
	animation_speed = 0.2;
	image_speed = animation_speed;

	performance_penalty_miss = 15;
}

function phone_step() {
	switch (state_current) {
		case E_STATES_PHONE.IDLE:
			sprite_index = sWorldPhone;
			image_speed = 0;
			break;

		case E_STATES_PHONE.LINE_INCOMING:
			var _gamespeed_fps = game_get_speed(gamespeed_fps);
			tick_current += (1 / _gamespeed_fps);
			if (tick_current >= tick_maximum) {
				phone_call_miss();
			}
			phone_animation();
			break;

		case E_STATES_PHONE.IN_USE:
			sprite_index = sWorldPhoneInfo;
			image_speed = 0;
			break;
		
	}
}
function phone_animation() {
	if (tick_current >= (tick_maximum * 0.8)) {
		sprite_index = sWorldPhoneAlert;
	} else {
		sprite_index = sWorldPhoneInfo;
	}
	image_speed = animation_speed;
}

function phone_call() {
	with (Phone) {
		if (state_current != E_STATES_PHONE.IDLE) return;

		state_current = E_STATES_PHONE.LINE_INCOMING;
		tick_current = 0;
	}
}
function phone_call_miss() {
	with (Phone) {
		state_current = E_STATES_PHONE.IDLE;
		tick_current = 0;
		global.performance_value -= performance_penalty_miss;
		text_info_create(x, y, E_TEXT_INFO_TYPES.MISTAKE);
	}
}