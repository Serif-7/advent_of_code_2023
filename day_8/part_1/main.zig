const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var map = std.StringHashMap(Fork).init(alloc);
    defer map.clearAndFree();

    var iter = std.mem.splitScalar(u8, buf, '\n');

    var directions = Directions{ .string = iter.next().? };

    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            continue;
        }
        if (std.mem.eql(u8, line, "") and iter.peek() == null) {
            break;
        }

        var s_iter = std.mem.tokenizeAny(u8, line, " =(),");

        const key = s_iter.next().?;
        const left = s_iter.next().?;
        const right = s_iter.next().?;
        try map.put(key, Fork{ .left = left, .right = right });

        // print("{s}\n", .{line});
    }

    const goal = "ZZZ";
    var curr_place: []const u8 = "AAA";
    var steps: usize = 0;

    while (!std.mem.eql(u8, curr_place, goal)) {
        const dir = directions.next_dir();
        const fork = map.get(curr_place).?;
        // print("dir: {c}\n", .{dir});
        // print("fork: {any}\n", .{fork});

        if (dir == 'R') {
            curr_place = fork.right;
        } else {
            curr_place = fork.left;
        }
        steps += 1;
    }

    print("Final Sum: {d}\n", .{steps});
}

const Directions = struct {
    string: []const u8,
    index: usize = 0,

    pub fn next_dir(self: *Directions) u8 {
        std.debug.assert(!(self.index > self.string.len));
        if (self.index < self.string.len) {
            const res = self.string[self.index];
            // print("next_dir: {c}\n", .{res});
            // print("index: {d}\n", .{self.index});
            self.index += 1;
            return res;
        } else {
            const res = self.string[0];
            // print("next_dir: {c}\n", .{res});
            // print("index: {d}\n", .{self.index});
            self.index = 1;
            return res;
        }
    }
};

const Fork = struct {
    left: []const u8,
    right: []const u8,
};

test {
    var directions = Directions{ .string = "LLR" };

    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'R');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'R');
}
