const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("test_input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    //
    var dir_map = std.StringHashMap(Fork).init(alloc);
    defer dir_map.clearAndFree();

    var iter = std.mem.splitScalar(u8, buf, '\n');

    var directions = Directions{ .string = iter.next().? };

    // initial list of nodes ending with 'A'. Will be transformed into Forks
    var node_list = std.ArrayList([]const u8).init(alloc);
    defer node_list.clearAndFree();

    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            continue;
        }
        if (std.mem.eql(u8, line, "") and iter.peek() == null) {
            break;
        }

        var s_iter = std.mem.tokenizeAny(u8, line, " =(),");

        const key = s_iter.next().?;
        if (std.mem.endsWith(u8, key, "A")) {
            try node_list.append(key);
        }
        const left = s_iter.next().?;
        const right = s_iter.next().?;
        try dir_map.put(key, Fork{ .left = left, .right = right });

        // print("{s}\n", .{line});
    }

    print("Node List Length: {d}\n", .{node_list.items.len});

    //records steps to Z for each node
    //ex: node 1 reaches Z at step 5, 10, 16, 23, etc
    // when all items have a common multiple (ex: 5, 10, 15 ) the lowest number
    // is the final answer
    var steps_to_z = try std.ArrayList(std.ArrayList(usize)).initCapacity(alloc, 100);

    // var steps_to_z = try std.ArrayList(usize).initCapacity(alloc, 100);
    // defer steps_to_z.clearAndFree();
    defer {
        for (steps_to_z.items) |*arr| {
            arr.clearAndFree();
        }
        steps_to_z.clearAndFree();
    }

    // const goal = "ZZZ";
    // var curr_place: []const u8 = "AAA";
    var steps: usize = 0;
    var all_ends_with_z: bool = false;
    while (!all_ends_with_z) {
        // const fork = dir_map.get(curr_place).?;
        // print("dir: {c}\n", .{dir});
        // print("fork: {any}\n", .{fork});

        all_ends_with_z = transform(steps, &steps_to_z, &node_list, dir_map, directions.next_dir());

        print("##Node List: {d}\n", .{steps});
        for (steps_to_z.items) |step_count_arr| {
            for (step_count_arr.items) |step_count| {
                print("Step count: {d}", .{step_count});
            }
            print("\n", .{});
        }

        print("\n", .{});
        steps += 1;
        // if (steps == 1000) {
        //     // std.debug.panic("FUCK", {});
        //     std.posix.exit(1);
        // }
        // print("Steps: {d}\n", .{steps});
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

// fn all_ends_with_z(arr: std.ArrayList([]const u8)) bool {
//     for (arr.items) |node| {
//         if (!std.mem.endsWith(u8, node, "Z")) {
//             return false;
//         }
//     }
//     return true;
// }

fn transform(step_count: usize, steps_to_z: *std.ArrayList(std.ArrayList(usize)), arr: *std.ArrayList([]const u8), dir_map: std.StringHashMap(Fork), dir: u8) bool {
    var ends_with_z = true;
    for (0..arr.items.len, arr.items) |i, node| {
        const fork = dir_map.get(node).?;

        var res: []const u8 = undefined;

        if (dir == 'R') {
            res = fork.right;
        } else {
            res = fork.left;
        }

        arr.*.items[i] = res;
        if (!std.mem.endsWith(u8, res, "Z")) {
            ends_with_z = false;
        } else {
            steps_to_z.items[i].appendAssumeCapacity(step_count);
        }
    }
    return ends_with_z;
}
test {
    var directions = Directions{ .string = "LLR" };

    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'R');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'R');
}
test {
    var directions = Directions{ .string = "RLRLRLLLRRRLLL" };

    std.debug.assert(directions.next_dir() == 'R');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'R');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'R');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'R');
    std.debug.assert(directions.next_dir() == 'R');
    std.debug.assert(directions.next_dir() == 'R');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'L');
    std.debug.assert(directions.next_dir() == 'L');
}
