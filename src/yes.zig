const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    const args = std.os.argv[1..]; 

    // Buffer for reading from stdin
    var line_buffer: [1024]u8 = undefined;

    // Determine the string to repeat
    const output_str: []const u8 = if (args.len > 0)
        std.mem.span(args[0]) // Use first argument if provided
    else blk: {
        const line = try stdin.readUntilDelimiterOrEof(&line_buffer, '\n') orelse {
            break :blk "y";
        };
        // Trim trailing newline or whitespace if present
        break :blk std.mem.trimRight(u8, line, "\r\n");
    };

    // Infinite loop to repeatedly print the string
    while (true) {
        stdout.writeAll(output_str) catch |err| {
            if (err == error.BrokenPipe) return; // Exit silently on pipe close
            return err; // Propagate other errors
        };
        try stdout.writeByte('\n');
    }
}
