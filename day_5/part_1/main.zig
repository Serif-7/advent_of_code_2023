const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("test_input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var iter = std.mem.splitSequence(u8, buf, "\n\n");

    const seeds = iter.next().?;

    print("{s}\n", .{seeds});

    while (iter.next()) |lines| {
        if (iter.peek() == null) {
            break;
        }
        // if (std.mem.eql(u8, line, "")) {
        // continue;
        // }
        // print("--------------\n", .{});
        // print("{s}\n", .{lines});
        // print("--------------\n", .{});
        const map = try RangeMap.init(lines, alloc);
        defer map.deinit();

        map.print();
    }
}

//parse a line to an actual hashmap
// fn parse_map(line: []const u8) void {

// }

//converts a number through a given map
// fn convert(num: usize, map) usize {}

const RangeMap = struct {
    alloc: std.mem.Allocator,
    name: []const u8,
    //index 0 corresponds to the first line, 1 to the 2nd, etc
    src: []usize,
    dest: []usize,
    length: []usize,
    lines: []const u8, //original lines (Debugging)

    pub fn init(lines: []const u8, alloc: std.mem.Allocator) !RangeMap {
        var name: []const u8 = undefined;
        var iter = std.mem.splitScalar(u8, lines, '\n');

        if (iter.next()) |line| {
            name = line;
        }
        var src_arr = std.ArrayList(usize).init(alloc);
        var dest_arr = std.ArrayList(usize).init(alloc);
        var length_arr = std.ArrayList(usize).init(alloc);

        errdefer {
            src_arr.clearAndFree();
            dest_arr.clearAndFree();
            length_arr.clearAndFree();
        }
        // defer {
        //     // src_arr.;
        //     dest_arr.deinit();
        //     start_arr.deinit();
        // }
        while (iter.next()) |line| {
            var line_iter = std.mem.splitAny(u8, line, " \n");

            if (line_iter.next()) |tok| {
                try dest_arr.append(try std.fmt.parseInt(usize, tok, 10));
            }
            if (line_iter.next()) |tok| {
                try src_arr.append(try std.fmt.parseInt(usize, tok, 10));
            }
            if (line_iter.next()) |tok| {
                try length_arr.append(try std.fmt.parseInt(usize, tok, 10));
            }
        }

        return RangeMap{
            .alloc = alloc,
            .lines = lines,
            .name = name,
            .src = try src_arr.toOwnedSlice(),
            .dest = try dest_arr.toOwnedSlice(),
            .length = try length_arr.toOwnedSlice(),
        };
    }

    pub fn deinit(self: RangeMap) void {
        self.alloc.free(self.src);
        self.alloc.free(self.dest);
        self.alloc.free(self.length);
        // std.mem.Allocator.free(self.alloc, self.dest);
        // std.mem.Allocator.free(self.alloc, self.start);
    }

    // pub fn convert(n: usize) usize {

    // }

    pub fn print(self: RangeMap) void {
        std.debug.print("RangeMap:\n", .{});
        std.debug.print("{s}\n", .{self.lines});
    }
};
