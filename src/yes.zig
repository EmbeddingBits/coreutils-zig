const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer.();
    const args = std.os.argv[1..];

    const output = if(args.len > 0) std.mem.span(args[0]) else "y";

    while(true) {
        try stdout.writeAll(output);
        try stdout.writeByte('\n');
    }
}
