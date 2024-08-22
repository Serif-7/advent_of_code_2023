const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("test_input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var grid = Grid.init(buf, alloc);
}

const Cursor = struct {
    square: u8,
    coord: .{ usize, usize },
};

const Grid = struct {
    grid: std.ArrayList(std.ArrayList(u8)),

    fn get_adjacent_pos(self: Grid, coord: .{ usize, usize }) std.BoundedArray(.{ usize, usize }, 8) {}

    fn init(string: []const u8, alloc: std.mem.Allocator) Grid {
        var grid = std.ArrayList(std.ArrayList(u8)).init(alloc);

        var iter = std.mem.splitScalar(u8, string, '\n');

        for (0..iter.peek().len) |_| {
            grid.append(std.ArrayList(u8).init(alloc));
        }
        while (iter.next()) |line| {
            if (std.mem.eql(u8, line, "")) {
                break;
            }

            //fill out grid
            for (line, 0..line.len) |c, i| {
                grid.items[i].append(c);
            }
            // print("{s}\n", .{line});
        }

        return Grid{
            .grid = grid,
        };
    }
};
