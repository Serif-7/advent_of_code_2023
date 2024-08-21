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

        print("{s}\n", .{line});
    }
}

const Cursor = struct {
    square: u8,
    coord: .{ usize, usize },
};

const Grid = struct {
    grid: std.ArrayList(std.ArrayList(u8)),

    fn get_adjacent_pos(self: Grid, coord: .{ usize, usize }) std.BoundedArray(.{ usize, usize }, 8) {}
};
