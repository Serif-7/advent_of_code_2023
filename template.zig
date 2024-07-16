const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("input.txt");

    var iter = std.mem.splitScalar(u8, buf, '\n');

    while (iter.next()) |line| {
        if (iter.peek() == null) {
            break;
        }

        print("{s}\n", .{line});
    }
}
