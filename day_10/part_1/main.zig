const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("test_input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var grid = Grid.init(buf, alloc);
    defer grid.deinit();

    var tree = Tree.init(alloc);

    while (!tree.all_leaves_terminate()) {
        tree.add_leaves(grid.get_adjacent_pos(grid.cursor));
    }

    return tree.furthest_distance();
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
    square: u8 = 'S',
    coord: Coord = Coord{ 0, 0 },
    last_pos: ?Cursor = null,
};

const Grid = struct {
    grid: std.ArrayList(std.ArrayList(u8)),

    //find valid positions to move to, within 1 square
    fn get_adjacent_pos(self: Grid, cursor: Cursor) std.BoundedArray(Cursor, 8) {
        var res = try std.BoundedArray(Cursor, 8).init(8);
        const north = Coord{ cursor.coord.x, cursor.coord.y + 1 };
        const south = Coord{ cursor.coord.x, cursor.coord.y - 1 };
        const east = Coord{ cursor.coord.x + 1, cursor.coord.y };
        const west = Coord{ cursor.coord.x - 1, cursor.coord.y };
        res.appendSliceAssumeCapacity(switch (cursor.square) {
            '-' => [_]Cursor{
                Cursor{
                    .square = '-',
                    .coord = east,
                    .last_pos = cursor,
                },
                Cursor{
                    .square = '-',
                    .coord = west,
                    .last_pos = cursor,
                },
            },
            '|' => [_]Cursor{
                Cursor{
                    .square = '|',
                    .coord = north,
                    .last_pos = cursor,
                },
                Cursor{
                    .square = '|',
                    .coord = south,
                    .last_pos = cursor,
                },
            },
            'L' => [_]Cursor{
                Cursor{
                    .square = 'L',
                    .coord = north,
                    .last_pos = cursor,
                },
                Cursor{
                    .square = 'L',
                    .coord = west,
                    .last_pos = cursor,
                },
            },
            'J' => [_]Cursor{
                Cursor{
                    .square = 'J',
                    .coord = east,
                    .last_pos = cursor,
                },
                Cursor{
                    .square = 'J',
                    .coord = north,
                    .last_pos = cursor,
                },
            },
            '7' => [_]Cursor{
                Cursor{
                    .square = '7',
                    .coord = south,
                    .last_pos = cursor,
                },
                Cursor{
                    .square = '7',
                    .coord = west,
                    .last_pos = cursor,
                },
            },
            'F' => [_]Cursor{
                Cursor{
                    .square = 'F',
                    .coord = south,
                    .last_pos = cursor,
                },
                Cursor{
                    .square = 'F',
                    .coord = east,
                    .last_pos = cursor,
                },
            },
            else => [_]Cursor{},
        });

        // remove last position (because we came from there) and filter invalid
        // coords
        for (res.slice(), 0..res.slice().len) |c, i| {
            if (c.eql(cursor.last_pos)) {
                res.swapRemove(i);
            }
            if (c.coord.x < 0 or c.coord.y < 0) {
                res.swapRemove(i);
            }
        }

        //assign squares
        for (res.slice()) |*c| {
            c.square = self.grid.items[c.coord.x].items[c.coord.y];
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

//Tree
// instance of Tree doubles as tree node
const Tree = struct {
    leaves: std.BoundedArray(Tree, 4),
    root: bool = true,
    terminus: bool = false, // true if there is no more of the grid to walk
    distance: usize = 0, //distance cannot be > 0 if root is true
    square: u8 = 'S',
    coord: Coord = Coord{ 0, 0 },

    fn init(alloc: std.mem.Allocator) Tree {
        return Tree{
            .leaves = std.BoundedArray(Tree, 4).init(alloc),
        };
    }

    fn add_leaf(self: Tree, square: u8, alloc: std.mem.Allocator) !void {
        try self.leaves.append(Tree{
            .leaves = try std.BoundedArray(Tree, 4).init(alloc),
            .root = false,
            .distance = self.distance + 1,
            .square = square,
        });
    }

    fn all_leaves_terminate(self: Tree) bool {
        var terminates = true;
        for (self.leaves) |leaf| {
            if (leaf.terminus == false) {
                terminates = false;
            }
        }
        if (terminates) {
            return true;
        } else {
            for (self.leaves) |leaf| {
                terminates = leaf.all_leaves_terminate();
            }
        }
        return terminates;
    }
};
