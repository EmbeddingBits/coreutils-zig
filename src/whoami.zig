const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    // Get the effective user ID (EUID) using a Linux syscall
    const euid = std.os.linux.geteuid();

    // Open /etc/passwd file
    const file = try std.fs.openFileAbsolute("/etc/passwd", .{ .mode = .read_only });
    defer file.close();

    // Create a buffered reader for efficiency
    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    // Read the file line by line
    var line_buffer: [1024]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&line_buffer, '\n')) |line| {
        // Split the line into fields (format: name:password:uid:gid:gecos:home:shell)
        var fields = std.mem.split(u8, line, ":");
        const username = fields.next() orelse continue; // First field: username
        _ = fields.next(); // Skip password field
        const uid_str = fields.next() orelse continue; // Third field: UID

        // Parse the UID from the string
        const uid = std.fmt.parseInt(u32, uid_str, 10) catch continue;

        // If this UID matches the EUID, print the username
        if (uid == euid) {
            try stdout.writeAll(username);
            try stdout.writeByte('\n');
            return;
        }
    }

    // If no matching UID is found
    try stdout.writeAll("Could not determine username\n");
    std.process.exit(1);
}
