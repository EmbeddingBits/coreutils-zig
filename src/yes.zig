const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    const args = std.os.argv[1..]; // Skip program name (argv[0])

    // Buffer for reading from stdin or building the argument string
    var line_buffer: [1024]u8 = undefined;

    // Determine the string to repeat
    const output_str: []const u8 = if (args.len > 0) blk: {
        // Concatenate all arguments with spaces
        var total_len: usize = 0;
        for (args, 0..) |arg, i| {
            const arg_str = std.mem.span(arg);
            if (i > 0) total_len += 1; // Space between args
            total_len += arg_str.len;
        }

        // Check if the total length fits in the buffer
        if (total_len >= line_buffer.len) {
            try stdout.writeAll("Error: arguments too long\n");
            std.process.exit(1);
        }

        // Build the string in the buffer
        var offset: usize = 0;
        for (args, 0..) |arg, i| {
            const arg_str = std.mem.span(arg);
            if (i > 0) {
                line_buffer[offset] = ' ';
                offset += 1;
            }
            @memcpy(line_buffer[offset..][0..arg_str.len], arg_str);
            offset += arg_str.len;
        }
        break :blk line_buffer[0..total_len];
    } else blk: {
        // Read a line from stdin if no arguments
        const line = try stdin.readUntilDelimiterOrEof(&line_buffer, '\n') orelse {
            // If no input (e.g., EOF), default to "y"
            break :blk "y";
        };
        // Trim trailing newline or whitespace if present
        break :blk std.mem.trimRight(u8, line, "\r\n");
    };

    // Infinite loop to repeatedly print the string
    while (true) {
        stdout.print("{s}\n", .{output_str}) catch |err| {
            if (err == error.BrokenPipe) return; // Exit silently on pipe close
            return err; // Propagate other errors
        };
    }
}
