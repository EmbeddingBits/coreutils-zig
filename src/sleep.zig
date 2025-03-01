const std = @import("std");

fn printUsage() void {
    std.debug.print(
        \\Usage: sleep [seconds] [options]
        \\Sleep for a specified duration. If no flag is provided, the default unit is seconds.
        \\
        \\Options:
        \\  -s <seconds>    Sleep for the specified number of seconds
        \\  -h <hours>      Sleep for the specified number of hours
        \\  -m <minutes>    Sleep for the specified number of minutes
        \\  -d <days>       Sleep for the specified number of days
        \\  --help          Display this help message
        \\
        \\Examples:
        \\  sleep 5         Sleep for 5 seconds
        \\  sleep -s 5      Sleep for 5 seconds
        \\  sleep 3 -h 1    Sleep for 3 seconds + 1 hour
        \\
    , .{});
}

pub fn main() !void {
    var args = std.process.args();
    _ = args.next(); // Skip the program name

    var total_nanoseconds: u64 = 0;

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--help")) {
            printUsage();
            return;
        } else if (arg[0] == '-') {
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
        } else {
            // No flag, treat as default unit (seconds)
            const num = try std.fmt.parseUnsigned(u64, arg, 10);
            total_nanoseconds += num * 1_000_000_000; // Seconds to nanoseconds
        }
    }

    if (total_nanoseconds == 0) {
        std.debug.print("Error: No duration specified\n", .{});
        printUsage();
        return error.NoDurationSpecified;
    }

    std.time.sleep(total_nanoseconds);
}
