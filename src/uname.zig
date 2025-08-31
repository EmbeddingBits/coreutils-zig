const std = @import("std");
const clap = std.clap;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 1. Define the command-line parameters (flags) for clap.
    const params = comptime .{
        .all = clap.flag(.{ .shorthand = 'a', .long = "all", .description = "print all information, in the following order" }),
        .sysname = clap.flag(.{ .shorthand = 's', .long = "kernel-name", .description = "print the kernel name" }),
        .nodename = clap.flag(.{ .shorthand = 'n', .long = "nodename", .description = "print the network node hostname" }),
        .release = clap.flag(.{ .shorthand = 'r', .long = "kernel-release", .description = "print the kernel release" }),
        .version = clap.flag(.{ .shorthand = 'v', .long = "kernel-version", .description = "print the kernel version" }),
        .machine = clap.flag(.{ .shorthand = 'm', .long = "machine", .description = "print the machine hardware name" }),
    };

    // 2. Parse the command-line arguments.
    var diag = clap.Diagnostic{};
    var res = try clap.parse(clap.Help, &params, clap.parsers.default, .{
        .allocator = allocator,
        .diagnostic = &diag,
    });
    defer res.deinit();

    // 3. Handle help and parsing errors automatically.
    if (diag.fatal) {
        diag.report(std.io.getStdErr().writer(), res.ast) catch {};
        return error.Clap;
    }
    if (res.args.help) {
        try clap.usage(std.io.getStdOut().writer(), clap.Help, &params, res.ast);
        return;
    }

    // --- Logic after successful parsing ---

    // The '-s' flag is the default if no other flags are provided.
    var do_sysname = res.args.sysname;
    const any_flag_set = res.args.all or res.args.nodename or res.args.release or res.args.version or res.args.machine;
    if (!any_flag_set and !do_sysname) {
        do_sysname = true;
    }

    const uname_info = std.posix.uname();
    const stdout = std.io.getStdOut().writer();
    var needs_space = false;

    if (res.args.all) {
        try stdout.print("{s} {s} {s} {s} {s}\n", .{
            std.mem.sliceTo(&uname_info.sysname, 0),
            std.mem.sliceTo(&uname_info.nodename, 0),
            std.mem.sliceTo(&uname_info.release, 0),
            std.mem.sliceTo(&uname_info.version, 0),
            std.mem.sliceTo(&uname_info.machine, 0),
        });
    } else {
        if (do_sysname) {
            try stdout.print("{s}", .{std.mem.sliceTo(&uname_info.sysname, 0)});
            needs_space = true;
        }
        if (res.args.nodename) {
            if (needs_space) try stdout.print(" ", .{});
            try stdout.print("{s}", .{std.mem.sliceTo(&uname_info.nodename, 0)});
            needs_space = true;
        }
        if (res.args.release) {
            if (needs_space) try stdout.print(" ", .{});
            try stdout.print("{s}", .{std.mem.sliceTo(&uname_info.release, 0)});
            needs_space = true;
        }
        if (res.args.version) {
            if (needs_space) try stdout.print(" ", .{});
            try stdout.print("{s}", .{std.mem.sliceTo(&uname_info.version, 0)});
            needs_space = true;
        }
        if (res.args.machine) {
            if (needs_space) try stdout.print(" ", .{});
            try stdout.print("{s}", .{std.mem.sliceTo(&uname_info.machine, 0)});
            needs_space = true;
        }

        if (needs_space) {
            try stdout.print("\n", .{});
        }
    }
}
