const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("test_input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var grid = Grid.init(buf, alloc);
    defer grid.deinit();
}

const Coord = struct {
    x: usize = 0,
    y: usize = 0,

    fn eql(self: Coord, comp: Coord) bool {
        if (self.x == comp.x and self.y == comp.y) {
            return true;
        } else {
            return false;
        }
    }
};

const Cursor = struct {
    square: u8,
    coord: Coord,
    last_pos: Coord,
};

const Grid = struct {
    grid: std.ArrayList(std.ArrayList(u8)),
    cursor: Cursor,

    //find valid positions to move to, within 1 square
    fn get_adjacent_pos(self: Grid) std.BoundedArray(Coord, 8) {
        var res = try std.BoundedArray(Coord, 8).init(8);
        const north = Coord{ self.cursor.coord.x, self.cursor.coord.y + 1 };
        const south = Coord{ self.cursor.coord.x, self.cursor.coord.y - 1 };
        const east = Coord{ self.cursor.coord.x + 1, self.cursor.coord.y };
        const west = Coord{ self.cursor.coord.x - 1, self.cursor.coord.y };
        res.appendSliceAssumeCapacity(switch (self.cursor.square) {
            '-' => [_]Coord{ east, west },
            '|' => [_]Coord{ north, south },
            '.' => [_]Coord{},
            'L' => [_]Coord{ north, west },
            'J' => [_]Coord{ east, north },
            '7' => [_]Coord{ south, west },
            'F' => [_]Coord{ south, east },
            else => [_]Coord{},
        });

        // remove last position (because we came from there)
        for (res.slice(), 0..res.slice(0).len) |c, i| {
            if (c.eql(self.last_pos)) {
                res.swapRemove(i);
            }
        }
        return res;
    }

    //load grid into arrays and initialize cursor to starting pos
    fn init(string: []const u8, alloc: std.mem.Allocator) Grid {
        var grid = std.ArrayList(std.ArrayList(u8)).init(alloc);

        var iter = std.mem.splitScalar(u8, string, '\n');

        for (0..iter.peek().len) |_| {
            grid.append(std.ArrayList(u8).init(alloc));
        }
        var y: usize = 0;
        var curs: Cursor = undefined;
        while (iter.next()) |line| {
            if (std.mem.eql(u8, line, "")) {
                break;
            }

            //fill out grid
            for (line, 0..line.len) |c, x| {
                grid.items[x].append(c);
                if (c == 'S') {
                    curs = Cursor{
                        .square = 'S',
                        .coord = Coord{ .x = x, .y = y },
                        .last_pos = Coord{ .x = 0, .y = 0 },
                    };
                }
            }
            // print("{s}\n", .{line});
            y += 1;
        }

        return Grid{
            .grid = grid,
            .cursor = curs,
        };
    }

    fn deinit(self: Grid) void {
        for (self.grid.items) |*arr| {
            arr.clearAndFree();
        }
        self.grid.clearAndFree();
    }
};

const Tnode = struct {
    leaves: std.BoundedArray(Tnode, 4),
    terminus: bool = true,
    distance: usize = 1, // distance from root
    square: u8,

    fn add_leaf(self: Tree, square: u8, alloc: std.mem.Allocator) !void {
        try self.leaves.append(Tnode{
            .square = square,
            .distance = self.distance + 1,
            .terminus = true,
            .leaves = try std.BoundedArray(Tnode, 4).init(alloc),
        });
        self.terminus = false;
    }
};

const Tree = struct {
    leaves: std.BoundedArray(Tnode, 4),

    fn add_leaf(self: Tree, square: u8, alloc: std.mem.Allocator) !void {
        try self.leaves.append(Tnode{
            .square = square,
            .distance = self.distance + 1,
            .terminus = true,
            .leaves = try std.BoundedArray(Tnode, 4).init(alloc),
        });
    }

    fn all_leaves_terminate(self: Tree) bool {}
};
