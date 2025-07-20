/// @function                auto_line_break(_text, _max_width)
/// @description             Inserts newline characters into a string to make it fit a max width.
/// @param {string} _text    The string to format.
/// @param {real} _max_width The maximum width in pixels for a line.
/// @returns {string}

function auto_line_break(_text, _max_width) {
    // Clean up the input string first
    _text = string_trim(_text);

    var _result_string = "";
    var _current_line = "";
    
    // Split the text into individual words
    var _words = string_split(_text, " ");
    var _word_count = array_length(_words);
    
    for (var i = 0; i < _word_count; i++) {
        var _word = _words[i];
        
        // Skip any empty entries that might result from multiple spaces
        if (string_length(_word) == 0) continue;
        
        // Build a test line to measure its width
        var _test_line = _current_line == "" ? _word : _current_line + " " + _word;
        
        if (string_width(_test_line) < _max_width) {
            // The word fits, so add it to the current line
            _current_line = _test_line;
        } else {
            // The word does not fit, so we end the current line
            _result_string += _current_line + "\n";
            // The new line starts with the word that didn't fit
            _current_line = _word;
        }
    }
    
    // Add the final remaining line to the result
    _result_string += _current_line;
    
    return _result_string;
}