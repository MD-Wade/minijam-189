function FaxOrder() constructor {
    self.fax_number = fax_pile_get_ten_digit_number();
    self.pages_count = irandom_range(global.fax_pile_page_count_min, global.fax_pile_page_count_max);
    self.pages_completed = 0;
    self.fax_title = get_random_fax_title();

    function get_random_fax_title() {
        var _fax_order_index = irandom(array_length(global.fax_order_names) - 1);
        return global.fax_order_names[_fax_order_index];
    }
}

function fax_pile_controller_init() {
    global.fax_pile_count = 0;
    global.fax_pile_page_count_min = 1;
    global.fax_pile_page_count_max = 5;
    global.fax_pile_orders = [];

    global.fax_order_names = [
        "Cookie Invoice",
        "Scaled Up Photo of a Cookie",
        "Cookie Business Lobbying Proposal"
    ]
}
function fax_pile_controller_init_stacks() {
    global.fax_pile_stacks = [];
    fax_stack_count = instance_number(FaxPile);
    for (var _fax_pile_index = 0; _fax_pile_index < fax_stack_count; _fax_pile_index ++) {
        var _fax_pile_index = instance_find(FaxPile, _fax_pile_index);
        array_push(global.fax_pile_stacks, _fax_pile_index);
    }
}

function fax_pile_controller_add_order() {
    var _fax_order = new FaxOrder();
    global.fax_pile_count ++;
    array_push(global.fax_pile_stacks, _fax_pile);
}
function fax_pile_controller_update_stacks() {
    var _fax_pile_count = array_length(global.fax_pile_stacks);
    for (var _fax_pile_index = 0; _fax_pile_index < _fax_pile_count; _fax_pile_index ++) {
        var _fax_pile = global.fax_pile_stacks[_fax_pile_index];
    }
}
function fax_pile_get_ten_digit_number() {
    var _digits = "0123456789";
    var _number = "";

    for (var _digit_index = 0; _digit_index < 10; _digit_index ++) {
        // Area Code has to be 3 non-zero digits
        var _random_digit = string_char_at(_digits, irandom(10));

        if (_digit_index < 3) {
           _random_digit = string_char_at(_digits, irandom_range(1, 9));
        } else if (_digit_index == 9) {
            // Last digit should be 1-9 so its decimal form is the same
            _random_digit = string_char_at(_digits, irandom_range(1, 9));
        }
        _number += _random_digit;
    }

    return _number;
}