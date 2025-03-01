const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const cwd = try std.fs.cwd().realpathAlloc(allocator, ".");
    defer allocator.free(cwd);

    try std.io.getStdOut().writeAll(cwd);
    try std.io.getStdOut().writeAll("\n");

}
