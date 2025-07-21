function task_assignment_controller_init() {
    tick_current = 11;
    tick_max = 12.0;
}
function task_assignment_controller_init_probabilities() {
    assignment_probability_phone = 40;
}

function task_assignment_controller_step() {
    var _gamespeed_fps = game_get_speed(gamespeed_fps);
    
    tick_current += (1 / _gamespeed_fps);
    if (tick_current >= tick_max) {
        task_assignment_controller_create_task();
        tick_current = 0;
    }
}

function task_assignment_controller_create_task() {
    phone_call();
}