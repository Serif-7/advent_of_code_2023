const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("test_input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var iter = std.mem.splitScalar(u8, buf, '\n');

    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        var diff_array = std.ArrayList(usize).init(alloc);
        var line_iter = std.mem.tokenizeAny(u8, line, " ");
        while (line_iter.next()) |token| {
            if (line_iter.peek() == null) {
                break;
            }
            const diff = ;
            diff_array.append()
        }

        print("{s}\n", .{line});
    }
}
