const std = @import("std");

pub fn main() !void {
    var args = std.process.args();
    _ = args.next(); // Skip the program name

    var total_nanoseconds: u64 = 0;

    while (args.next()) |arg| {
        const flag = arg;
        const value = args.next() orelse {
            std.debug.print("Error: Missing value for flag '{s}'\n", .{flag});
            return error.InvalidArgument;
        };

        const num = try std.fmt.parseUnsigned(u64, value, 10);

        if (std.mem.eql(u8, flag, "-s")) {
            total_nanoseconds += num * 1_000_000_000; // Seconds to nanoseconds
        } else if (std.mem.eql(u8, flag, "-h")) {
            total_nanoseconds += num * 3_600_000_000_000; // Hours to nanoseconds
        } else if (std.mem.eql(u8, flag, "-m")) {
            total_nanoseconds += num * 60_000_000_000; // Minutes to nanoseconds
        } else if (std.mem.eql(u8, flag, "-d")) {
            total_nanoseconds += num * 86_400_000_000_000; // Days to nanoseconds
        } else {
            std.debug.print("Unknown flag: '{s}'\n", .{flag});
            return error.UnknownFlag;
        }
    }

    if (total_nanoseconds == 0) {
        std.debug.print("Usage: sleep [-s seconds] [-h hours] [-m minutes] [-d days]\n", .{});
        return error.NoDurationSpecified;
    }

    std.time.sleep(total_nanoseconds);
}
