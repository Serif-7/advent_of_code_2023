const std = @import("std");
const print = std.debug.print;

// lessons
// var loc: usize = std.math.maxInt(usize);

pub fn main() !void {
    const buf = @embedFile("test_input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var iter = std.mem.splitSequence(u8, buf, "\n\n");

    // set up seed ranges
    const seed_line = iter.next().?;
    var seed_ranges = std.ArrayList(Range).init(alloc);
    defer seed_ranges.clearAndFree();
    var seed_iter = std.mem.splitScalar(u8, seed_line, ' ');
    while (seed_iter.next()) |seed| {
        if (std.ascii.isAlphabetic(seed[0])) {
            continue;
        }

        const start: usize = try std.fmt.parseInt(usize, seed, 10);
        const len: usize = try std.fmt.parseInt(usize, seed_iter.next().?, 10);
        try seed_ranges.append(Range.init(start, len));
    }

    var range_maps = std.ArrayList(RangeMap).init(alloc);
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
        try range_maps.append(try RangeMap.init(lines, alloc));
    }

    defer {
        for (range_maps.items) |map| {
            map.deinit();
        }
        range_maps.clearAndFree();
    }

    //
    for (seed_ranges.items) |seed_range| {
        // var range_list = std.BoundedArray(Range, 500){};
        var range_list = std.ArrayList(Range).init(alloc);
        defer range_list.clearAndFree();
        try range_list.append(seed_range);
        var range_list_ptr: *std.ArrayList(Range) = &range_list;
        defer range_list_ptr.*.clearAndFree();

        for (range_maps.items) |map| {
            var new_list = std.ArrayList(Range).init(alloc);

            for (range_list_ptr.*.items) |range| {
                var res: std.ArrayList(Range) = try map.convert_range(range, alloc);
                defer res.clearAndFree();
                try new_list.appendSlice(try res.toOwnedSlice());
            }
            range_list_ptr.*.clearAndFree();
            range_list_ptr = &new_list;
        }

        //find lowest range bound
        var low: usize = std.math.maxInt(usize);
        for (range_list_ptr.*.items) |range| {
            if (range.start < low) {
                low = range.start;
            }
        }
        print("Lowest location number: {d}\n", .{low});

        // print("Converted Range: Start: {d}, End: {d}\n", .{ r.start, r.len });
    }
}

// end inclusive range
const Range = struct {
    start: usize,
    // dest: usize,
    end: usize,

    pub fn init(start: usize, len: usize) Range {
        return Range{
            .start = start,
            .end = start + (len - 1),
        };
    }

    // test if a number falls in the src range
    // pub fn convertable(self: Range, n: usize) bool {

    // }

    // pub fn convert(self: Range, n: usize) usize {
    //     if ((n >= self.src) and (n < (self.src + self.len))) {
    //         return self.dest + (n - self.src);
    //     } else {
    //         return n;
    //     }
    // }
};

const RangeMap = struct {
    alloc: std.mem.Allocator,
    name: []const u8,
    map: std.AutoArrayHashMap(Range, Range),
    //index 0 corresponds to the first line, 1 to the 2nd, etc
    // src: []usize,
    // dest: []usize,
    // length: []usize,
    lines: []const u8, //original lines (Debugging)

    pub fn init(lines: []const u8, alloc: std.mem.Allocator) !RangeMap {
        var name: []const u8 = undefined;
        var iter = std.mem.splitScalar(u8, lines, '\n');

        if (iter.next()) |line| {
            name = line;
        }
        var map = std.AutoArrayHashMap(Range, Range).init(alloc);

        errdefer {
            map.clearAndFree();
        }
        while (iter.next()) |line| {
            var line_iter = std.mem.splitAny(u8, line, " \n");

            var src_range = Range{ .start = undefined, .end = undefined };
            var dest_range = Range{ .start = undefined, .end = undefined };

            if (line_iter.next()) |tok| {
                // try dest_arr.append(try std.fmt.parseInt(usize, tok, 10));
                dest_range.start = try std.fmt.parseInt(usize, tok, 10);
            }
            if (line_iter.next()) |tok| {
                // try src_arr.append(try std.fmt.parseInt(usize, tok, 10));
                src_range.start = try std.fmt.parseInt(usize, tok, 10);
            }
            if (line_iter.next()) |tok| {
                // try length_arr.append(try std.fmt.parseInt(usize, tok, 10));
                dest_range.end = dest_range.start + (try std.fmt.parseInt(usize, tok, 10) - 1);
                src_range.end = src_range.start + (try std.fmt.parseInt(usize, tok, 10) - 1);
            }

            std.debug.assert((src_range.end - src_range.start) == (dest_range.end - dest_range.start));
            try map.put(src_range, dest_range);
        }

        // for (0.. src_arr.items.len) |i| {
        //     range_arr.appendAssumeCapacity(Range{.start = src_arr.items[i], .end = })
        // }

        return RangeMap{
            .alloc = alloc,
            .lines = lines,
            .name = name,
            .map = map,
        };
    }

    pub fn deinit(self: RangeMap) void {
        var m = self.map;
        m.clearAndFree();
        // std.mem.Allocator.free(self.alloc, self.dest);
        // std.mem.Allocator.free(self.alloc, self.start);
    }

    // convert a range through the map, splitting if range falls into
    // multiple transform ranges
    // return a list with all ranges
    pub fn convert_range(self: RangeMap, input_range: Range, alloc: std.mem.Allocator) !std.ArrayList(Range) {
        var range_list = std.ArrayList(Range).init(alloc);

        for (self.map.keys(), self.map.values()) |transform_range, dest_range| {

            //some intermediate values may be negative so I cast everything to isize first
            const input_start: isize = @intCast(input_range.start);
            const input_end: isize = @intCast(input_range.end);
            const src_start: isize = @intCast(transform_range.start);
            const src_end: isize = @intCast(transform_range.end);
            const dest_start: isize = @intCast(dest_range.start);
            const dest_end: isize = @intCast(dest_range.end);

            // case 1: input range falls entirely in transform range
            if (input_range.start >= transform_range.start and input_range.end < transform_range.end) {
                const res = Range{
                    .start = @intCast((dest_start + (input_start - src_start))),
                    .end = @intCast((dest_end - (src_end - input_end))),
                };

                try range_list.append(res);
                return range_list;
            }
            // case 2: range overlaps the end of a range but not the start
            if (input_range.start >= transform_range.start and input_range.end > transform_range.end) {
                const res = Range{ .start = (dest_range.start + (input_range.start - transform_range.start)), .end = (dest_range.end) };
                try range_list.append(res);
            }
            //case 3: range overlaps with the start of a range but not the end
            if (input_range.start < transform_range.start and (input_range.end <= transform_range.end and input_range.end > transform_range.start)) {
                const res = Range{ .start = dest_range.start, .end = dest_range.end - (input_range.end - transform_range.end) };
                try range_list.append(res);
            }
        }

        return range_list;
    }

    pub fn print(self: RangeMap) void {
        std.debug.print("RangeMap:\n", .{});
        std.debug.print("{s}\n", .{self.lines});
    }
};
