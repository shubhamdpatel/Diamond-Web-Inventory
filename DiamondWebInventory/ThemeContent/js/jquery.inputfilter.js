/// This plugin for jQuery (1.7+) is created by Anders Fjällström - anders@morriz.net - http://www.morriz.net
/// For documentation see https://github.com/morriznet/jquery.inputfilter
/// The plugin is used to create filters for form input and textarea
/// Released under MIT license
/// ver 1.1

(function ($) {
    $.fn.inputfilter = function (options) {
        var settings = $.extend({
            // Default values
            allowNumeric: true, // is numbers allowed [0-9]
            allowText: false,   // is text allowed [a-z|å|ä|ö]
            allowEnter: true,   // is Enter allowed
            allowCustom: [],    // Array of chars to allow
            regex: null,        // Regular expression of allowed chars
            maxLength: null,    // Maximum number of chars permitted
            actionLog: false    // Log actions
        }, options);
        var keyLog = function (e, m) { if (!settings.actionLog) return; var r = 'Charcode: ' + e.which + ' Char: ' + String.fromCharCode(e.which) + (m.length != 0 ? ' - ' + m : ''); window.console && console.log(r) || alert(r); }
        return this.on('keypress change paste', function (e) {
            switch (e.type) {
                case 'keypress':
                    // Allow systemkeys, including Ctrl+any key
                    if (e.which == 0 || e.which == 8 || e.ctrlKey === true) { keyLog(e, 'Match sys'); return; }
                    // Maxlength
                    if (settings.maxLength != null && $(this).val().length >= settings.maxLength) {
                        keyLog(e, 'Max length reached');
                        e.preventDefault();
                        return;
                    }
                    if (settings.allowEnter && e.which == 13) { keyLog(e, 'Match enter'); return; }
                    // Allow numeric
                    if (settings.allowNumeric && String.fromCharCode(e.which).match(/[\d]/g) != null) { keyLog(e, 'Numeric match'); return; }
                    // Allow alfa
                    if (settings.allowText && String.fromCharCode(e.which).match(/[a-z|å|ä|ö|A-Z|Å|Ä|Ö]/g) != null) { keyLog(e, 'Text match'); return; }
                    // Allow chars in custom
                    if ($.inArray(String.fromCharCode(e.which), settings.allowCustom) != -1) { keyLog(e, 'Custom match'); return; }
                    // Allow regex
                    if (settings.regex != null && String.fromCharCode(e.which).match(settings.regex) != null) { keyLog(e, 'Regex match'); return; }
                    
                    // Block
                    keyLog(e, 'NO MATCH');
                    e.preventDefault();

                    break;
                default:
                    // Check field based on RegExp
                    var $this = this;
                    var $type = e.type;
                    setTimeout(function () {
                        var _regexp = ''; var _specialChars = [44, 46, 47, 42, 43, 45, 63, 36, 94, 92];
                        if (settings.allowNumeric) _regexp += (_regexp.length != 0 ? '|' : '') + '0-9';
                        if (settings.allowText) _regexp += (_regexp.length != 0 ? '|' : '') + 'a-z|å|ä|ö|A-Z|Å|Ä|Ö';
                        $(settings.allowCustom).each(function () { _regexp += (_regexp.length != 0 ? '|' : '') + ($.inArray(String(this).charCodeAt(0), _specialChars) != -1 ? '\\' : '') + this; });
                        if (settings.allowEnter) _regexp += (_regexp.length != 0 ? '|' : '') + '\n|\r';
                        _regexp = '[' + _regexp + ']' + (settings.regex != null ? '|' + settings.regex : '');
                        var _output = ''; var _input = $($this).val();
                        $(String(_input).match(new RegExp(_regexp, 'g'))).each(function () { _output += this; });
                        if(settings.maxLength != null && _output.length>settings.maxLength) _output = _output.substr(0,settings.maxLength)
                        $($this).val(_output);
                        if (!settings.actionLog) return; var r = 'Type: ' + $type + ' Regexp: ' + _regexp + ' Input: ' + _input + ' Output: ' + _output; window.console && console.log(r) || alert(r);
                    }, 0);
            }
        });
    };
}(jQuery));