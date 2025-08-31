const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = std.process.argsWithAllocator(allocator) catch |err| {
        std.debug.print("Error getting args: {}\n", .{err});
        return;
    };
    defer args.deinit();

    _ = args.next();

    const file_name = args.next() orelse {
        std.debug.print("touch <filename>\n", .{});
        return;
    };

    const file = try std.fs.cwd().createFile(file_name, .{ .read = false });
    defer file.close();
}
