function FaxOrder() constructor {
    self.pages_count = irandom_range(global.fax_pile_page_count_min, global.fax_pile_page_count_max);
    self.pages_completed = 0;
    self.fax_number = fax_pile_get_ten_digit_number();
    self.fax_title = fax_pile_get_random_title();
    self.fax_number_formatted = "(" + string_copy(self.fax_number, 1, 3) + ") " + string_copy(self.fax_number, 4, 3) + "-" + string_copy(self.fax_number, 7, 4);
}

function fax_pile_controller_init() {
    global.fax_pile_page_count_min = 1;
    global.fax_pile_page_count_max = 5;
    global.fax_pile_stacks = [];
    global.fax_pile_orders = [];

    global.fax_order_names = [
        "Cookie Invoice",
        "Scaled Up Photo of a Cookie",
        "Cookie Business Lobbying Proposal"
    ]
}
function fax_pile_controller_init_stacks() {
    global.fax_pile_stacks = [];
    var _fax_stack_count = instance_number(FaxPile);
    for (var _fax_pile_index = 0; _fax_pile_index < _fax_stack_count; _fax_pile_index ++) {
        var _fax_pile_current = instance_find(FaxPile, _fax_pile_index);
        array_push(global.fax_pile_stacks, _fax_pile_current);
    }
}

function fax_pile_controller_room_start() {
    fax_pile_controller_init_stacks();
    fax_pile_controller_update_stacks();
}

function fax_pile_controller_add_order() {
    var _fax_order = new FaxOrder();
    array_push(global.fax_pile_orders, _fax_order);
    fax_pile_controller_update_stacks();
}
function fax_pile_controller_update_stacks() {
    var _fax_pile_count = array_length(global.fax_pile_stacks);
    var _fax_orders_remaining = array_length(global.fax_pile_orders);
    for (var _fax_pile_index = 0; _fax_pile_index < _fax_pile_count; _fax_pile_index ++) {
        var _fax_pile = global.fax_pile_stacks[_fax_pile_index];

        switch (_fax_orders_remaining) {
            case 0:
                _fax_pile.image_index = 4; // Empty Fax Pile
                _fax_orders_remaining = 0; // Go to Next Stack
                break;
            case 1:
                _fax_pile.image_index = 0; // 1 Fax Order
                _fax_orders_remaining = 0; // Go to Next Stack
                break;
            case 2:
                _fax_pile.image_index = 1; // 2 Fax Orders
                _fax_orders_remaining = 0; // Go to Next Stack
                break;
            case 3:
                _fax_pile.image_index = 2; // 3 Fax Orders
                _fax_orders_remaining = 0; // Go to Next Stack
                break;
            default:
                _fax_pile.image_index = 3;  // 4+ Fax Orders, Go to Next Stack
                _fax_orders_remaining -= 4; // Each Fax Pile can hold 4 orders
                break;
        }
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
function fax_pile_get_random_title() {
    var _fax_order_index = irandom(array_length(global.fax_order_names) - 1);
    return global.fax_order_names[_fax_order_index];
}