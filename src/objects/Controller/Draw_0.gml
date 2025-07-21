var _load_progress_music = audio_group_load_progress(ag_music);
var _load_progress_sound = audio_group_load_progress(ag_sound);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fntPhoneDialogue);
if (_load_progress_music < 100 or _load_progress_sound < 100) {
    var _mean_progress = floor(mean(_load_progress_music, _load_progress_sound));
    draw_text_perlin(room_width / 2, room_height / 2, "Loading Audio:\n" + string(_mean_progress) + "%", 1.0, 0.5, 1.0, c_white, c_dkgray, 1);
} else {
    draw_text_perlin(room_width / 2, room_height / 2, "Click to continue!", 1.0, 0.5, 1.0, c_white, c_dkgray, 1);
    if mouse_check_button_pressed(mb_left) {
        click_count ++;
    }
    if (click_count >= 2) {
        room_goto_next(); // Go to the next room
        instance_create_depth(0, 0, 0, MusicController);
        instance_create_depth(0, 0, 0, PathfindingController);
        instance_create_depth(0, 0, 0, NpcController);
        instance_create_depth(0, 0, 0, FaxPileController);
        instance_create_depth(0, 0, 0, TaskAssignmentController);
    }
}