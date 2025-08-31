const std = @import("std");

fn printString(writer: anytype, str: []const u8, interpret_escapes: bool) !void {
    var i: usize = 0;
    while (i < str.len) : (i += 1) {
        if (interpret_escapes and str[i] == '\\' and i + 1 < str.len) {
            i += 1; // Skip the backslash
            switch (str[i]) {
                'n' => try writer.writeByte('\n'),
                't' => try writer.writeByte('\t'),
                '\\' => try writer.writeByte('\\'),
                '0' => try writer.writeByte(0),
                else => {
                    try writer.writeByte('\\'); // Print the backslash for unknown escapes
                    try writer.writeByte(str[i]);
                },
            }
        } else {
            try writer.writeByte(str[i]);
        }
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const args = std.os.argv[1..];

    var newline = true;    
    var spaces = true;     
    var escapes = false;   

    var arg_index: usize = 0;

    // Process options
    while (arg_index < args.len and args[arg_index][0] == '-') : (arg_index += 1) {
        const option = std.mem.span(args[arg_index]);
        if (std.mem.eql(u8, option, "-n")) {
            newline = false; // No newline
        } else if (std.mem.eql(u8, option, "-s")) {
            spaces = false;  // No spaces between arguments
        } else if (std.mem.eql(u8, option, "-e")) {
            escapes = true;  // Enable escapes
        } else if (std.mem.eql(u8, option, "-E")) {
            escapes = false; // Disable escapes (default)
        } else {
            // Unknown option, treat as part of the string
            break;
        }
    }

    // Print all remaining arguments
    while (arg_index < args.len) : (arg_index += 1) {
        const arg = std.mem.span(args[arg_index]);
        try printString(stdout, arg, escapes);
        if (spaces and arg_index < args.len - 1) {
            try stdout.writeByte(' '); // Space between arguments if -s is not set
        }
    }

    // Add newline if -n is not specified
    if (newline) {
        try stdout.writeByte('\n');
    }
}
