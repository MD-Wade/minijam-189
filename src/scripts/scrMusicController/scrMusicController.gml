function music_controller_init() {
	audio_instance = -1;
}

function music_controller_room_start() {
	if audio_is_playing(audio_instance) {
		audio_stop_sound(audio_instance);
	}
	audio_instance = audio_play_sound(bgmMain, 1, true);
}

function music_controller_step() {
	// nothing
}