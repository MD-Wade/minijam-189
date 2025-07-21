function print_callstack() {
	var _array_callback = debug_get_callstack();
	show_debug_message(" -- Begin Callstack --");
	for (var _i = 0; _i < array_length(_array_callback) - 1; _i++) {
		show_debug_message(_array_callback[_i]);
	}
	show_debug_message(" -- End Callstack --");
}