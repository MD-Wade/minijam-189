/// feather ignore all

#macro C_PERLIN_SURFACE_SIZE 1024
#macro C_PERLIN_NOISE_SIZE_MASK 1023
#macro C_PERLIN_NOISE_BUFFER_SIZE 1048576
#macro C_PERLIN_NOISE_BUFFER_MASK 1048575
 
/*
@function           perlin_noise_2d
@description        Returns a perlin noise value for a given 2D coordinate
@argument           _x
@argument           _y
*/
function perlin_noise_2d(_x, _y) {
    var _x_int = floor(_x);
    var _y_int = floor(_y);
    var _x_frac = frac(_x);
    var _y_frac = frac(_y);

    var _x0 = (_x_int) & C_PERLIN_NOISE_SIZE_MASK;
    var _y0 = (_y_int) & C_PERLIN_NOISE_SIZE_MASK;
    var _x1 = (_x_int + 1) & C_PERLIN_NOISE_SIZE_MASK;
    var _y1 = (_y_int + 1) & C_PERLIN_NOISE_SIZE_MASK;

    var _v00 = buffer_peek(global.perlin_noise_buffer, (_x0 + _y0 * C_PERLIN_SURFACE_SIZE) << 2, buffer_u8);
    var _v10 = buffer_peek(global.perlin_noise_buffer, (_x1 + _y0 * C_PERLIN_SURFACE_SIZE) << 2, buffer_u8);
    var _v01 = buffer_peek(global.perlin_noise_buffer, (_x0 + _y1 * C_PERLIN_SURFACE_SIZE) << 2, buffer_u8);
    var _v11 = buffer_peek(global.perlin_noise_buffer, (_x1 + _y1 * C_PERLIN_SURFACE_SIZE) << 2, buffer_u8);

    var _lerp_x0 = lerp(_v00, _v10, _x_frac);
    var _lerp_x1 = lerp(_v01, _v11, _x_frac);
    var _value = lerp(_lerp_x0, _lerp_x1, _y_frac);

    var _value = quantize_float(_value / 255.0);
    return (_value - 0.5) * 2.0;
}

/*
@function           shader_set_perlin_noise
@description        Prepares the shader for rendering perlin noise
*/
function shader_set_perlin_noise() {   
    static _u_seed  = shader_get_uniform(shdPerlin, "u_seed");
    static _u_table = shader_get_uniform(shdPerlin, "u_table");
 
    shader_set(shdPerlin);
    shader_set_uniform_f(_u_seed, global.perlin_noise_seed);
    shader_set_uniform_i_array(_u_table, global.perlin_noise_table);
}

/*
@function           perlin_noise_create_buffer
@description        Creates a global buffer with perlin noise values
*/
function perlin_noise_create_buffer() {
    var _surface_index = surface_create(C_PERLIN_SURFACE_SIZE, C_PERLIN_SURFACE_SIZE);
    var _buffer_surface = buffer_create(C_PERLIN_NOISE_BUFFER_SIZE << 2, buffer_fast, 1);
    var _buffer_result = buffer_create(C_PERLIN_NOISE_BUFFER_SIZE << 2, buffer_fast, 1);
    var _buffer_peek = 0;

    if (global.perlin_noise_buffer != undefined) {
        buffer_delete(global.perlin_noise_buffer);
    }

    global.perlin_noise_seed = random_range(25.11111, 25.88888);
    global.perlin_noise_table = perlin_noise_create_hash_table();

    shader_set_perlin_noise();
    surface_set_target(_surface_index)

    draw_clear_alpha(c_black, 0);
    draw_primitive_begin_texture(pr_trianglestrip, -1);
    draw_vertex_texture(0, 0, 0, 0);
    draw_vertex_texture(C_PERLIN_SURFACE_SIZE, 0, 1, 0);
    draw_vertex_texture(0, C_PERLIN_SURFACE_SIZE, 0, 1);
    draw_vertex_texture(C_PERLIN_SURFACE_SIZE, C_PERLIN_SURFACE_SIZE, 1, 1);
    draw_primitive_end();
    
    shader_reset();
    surface_reset_target();

    buffer_get_surface(_buffer_surface, _surface_index, 0);
    surface_free(_surface_index);

    buffer_seek(_buffer_result, buffer_seek_start, 0);
    for (var _buffer_pos_index = 0; _buffer_pos_index < C_PERLIN_NOISE_BUFFER_SIZE; _buffer_pos_index ++) {
        var _value = buffer_peek(_buffer_surface, _buffer_peek, buffer_u8);
        buffer_write(_buffer_result, buffer_u8, _value);
        _buffer_peek += 4;
    }

    buffer_delete(_buffer_surface);
    global.perlin_noise_buffer = _buffer_result;
    return _buffer_result;  
}

/*
@function           perlin_noise_create_hash_table
@description        Creates a global hash table for perlin noise
*/
function perlin_noise_create_hash_table() {
    var _size = 256;
    var _values_array = array_create(_size, 0);
    for (var _i = 0; _i < _size; _i++) {
        _values_array[_i] = _i;
    }
    _values_array = array_shuffle(_values_array);
    return _values_array;
}

function noise_range(_val, _scale, _min, _max) {
    return lerp(_min, _max, noise_get_value(_val, _scale));
}
function noise_get_value(_x, _scale) {
    var _xInt = floor(_x * _scale);
    var _xFrac = _x * _scale - _xInt;
    var _s = noise_random(_xInt);
    var _t = noise_random(_xInt + 1);
    var _u = fade(_xFrac);
    return lerp(_s, _t, _u);
}
function noise_random(_x) {
    return frac(sin(_x * 12.9898 + 78.233) * 43758.5453);
}
function fade(_t) {
    return _t * _t * _t * (_t * (_t * 6 - 15) + 10);
}

function draw_text_perlin(_x, _y, _text, _noise_scale, _noise_magnitude, _colour, _shadow_colour=c_black, _shadow_distance=0) {
    var _len = string_length(_text);
    var _nx, _ny, _char_x, _char_y;
    var _time = current_time / 1000;
    var _begin_x = _x;
    var _begin_y = _y;
    
    for (var _i = 1; _i <= _len; _i++) {
        var _char = string_char_at(_text, _i);
        _nx = noise_range(_time + _i * 0.5, _noise_scale, -1, 1);
        _ny = noise_range(_time + _i * 0.5 + 1000, _noise_scale, -1, 1);
        _char_x = _x + _nx * _noise_magnitude;
        _char_y = _y + _ny * _noise_magnitude;
        if (_shadow_distance != 0) {
            draw_set_colour(_shadow_colour);
            draw_text(_char_x + _shadow_distance, _char_y + _shadow_distance, _char);
            draw_set_colour(_colour);
            draw_text(_char_x - _shadow_distance, _char_y - _shadow_distance, _char);
        } else {
            draw_set_colour(_colour);
            draw_text(_char_x, _char_y, _char);
        }
        _x += string_width(_char);
		
        if (_char == "\n") {
            _x = _begin_x;
            _y += string_height(_char);
        }
    }
}

global.perlin_noise_buffer = undefined;