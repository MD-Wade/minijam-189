function approach(_current, _target, _amount) {
    var _is_less_than_target = (_current < _target);
    var _increased_value = min(_current + _amount, _target);
    var _decreased_value = max(_current - _amount, _target);

    return _is_less_than_target ? _increased_value : _decreased_value;
}
function wave(_from, _to, _duration, _offset) {
    var _amplitude = (_to - _from) * 0.5;
    var _midpoint = _from + _amplitude;
    var _phase = (_offset * (pi * 2)) - (pi / 2);
    
    var _time_seconds = current_time * 0.001;
    var _normalized_time = _time_seconds / _duration;
    var _time_radians = _normalized_time * (pi * 2);
    var _total_angle = _time_radians + _phase;
    var _sin_value = sin(_total_angle);
    
    var _result = _midpoint + (_sin_value * _amplitude);
    return _result;
}
function round_n(_value, _round_to) {
	return round(_value / _round_to) * _round_to;
}
function floor_n(_value, _round_to) {
	return floor(_value / _round_to) * _round_to;
}
function angle_rotate(_angle_current, _angle_target, _angle_speed) {
    var _angle_difference = angle_difference(_angle_current, _angle_target);
    var _angle_difference_sign = sign(_angle_difference);
    var _angle_difference_abs = abs(_angle_difference);
    if (_angle_difference_abs < _angle_speed) {
        return _angle_target;
    }
    var new_angle = _angle_current - (_angle_speed * _angle_difference_sign);
    return (new_angle + 360) % 360;
}