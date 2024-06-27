const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    // const fba = std.heap.FixedBufferAllocator.init(&mem);
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
    const buf = try file.readToEndAlloc(alloc, try file.getEndPos());
    defer alloc.free(buf);

    var iter = std.mem.splitScalar(u8, buf, '\n');
    var sum: usize = 0;

    while (iter.next()) |line| {
        if (iter.peek() == null) {
            break;
        }

        print("{s}\n", .{line});
    }
}
