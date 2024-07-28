const std = @import("std");
const print = std.debug.print;

// lessons
// 1. var loc: usize = std.math.maxInt(usize);
// 2. local variables go out of scope, cant return a list from a function
// pass in a pointer to a list or slice and modify it
// 3. keep functions small if possible

var c1n: usize = 0;
var c1p: usize = 0;
var c2n: usize = 0;
var c2p: usize = 0;
var c3n: usize = 0;
var c3p: usize = 0;

pub fn main() !void {
    const buf = @embedFile("input.txt");
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

    var location_numbers = std.ArrayList(usize).init(alloc);
    defer location_numbers.clearAndFree();

    //
    for (seed_ranges.items) |seed_range| {
        // var range_list = std.BoundedArray(Range, 500){};

        // the initial seed range may be split into multiple ranges
        // therefore it is added to a list
        var range_list = std.ArrayList(Range).init(alloc);
        defer range_list.clearAndFree();
        try range_list.append(seed_range);

        for (range_maps.items) |map| {
            for (0..range_list.items.len) |_| {
                const r = range_list.orderedRemove(0);
                var res_list: [5]Range = undefined;
                const res = map.convert_range(r, &res_list);
                try range_list.appendSlice(res);
                // print("range_list after appending slice: {any}\n", .{range_list.items});
            }
            // print("new_list: {any}\n", .{new_list});
            // range_list_ptr = &new_list;
        }
        // print("range_list: {any}\n", .{range_list.items});

        //find lowest range bound
        var low: usize = std.math.maxInt(usize);
        for (range_list.items) |range| {
            // print("Range: {any}\n", .{range});
            if (range.start < low) {
                low = range.start;
            }
        }
        try location_numbers.append(low);
        // print("Lowest location number: {d}\n", .{low});

        // print("Converted Range: Start: {d}, End: {d}\n", .{ r.start, r.len });
    }
    print("c1n: {d}\n", .{c1n});
    print("c1p: {d}\n", .{c1p});
    print("c2n: {d}\n", .{c2n});
    print("c2p: {d}\n", .{c2p});
    print("c3n: {d}\n", .{c3n});
    print("c3p: {d}\n", .{c3p});

    var low: usize = std.math.maxInt(usize);
    for (location_numbers.items) |loc| {
        if (low > loc) {
            low = loc;
        }
    }
    print("Final Result: {d}\n", .{low});
}

// end inclusive range
const Range = struct {
    start: usize,
    // dest: usize,
    end: usize,

    pub fn init(start: usize, len: usize) Range {
        std.debug.assert(start < start + (len - 1));
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

            //assert src and dest ranges are the same length
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
    // multiple src ranges
    // return a list with all ranges
    pub fn convert_range(self: RangeMap, input_range: Range, result_list: *[5]Range) []Range {
        // var result_list = std.ArrayList(Range).init(alloc);
        // var result_list = std.BoundedArray(Range, 5){};
        // defer result_list.clearAndFree();

        // std.debug.print("Input Range: {any}\n", .{input_range});

        var result_list_len: usize = 0;

        // var c1n: usize = 0;
        // var c1p: usize = 0;
        // var c2n: usize = 0;
        // var c2p: usize = 0;
        // var c3n: usize = 0;
        // var c3p: usize = 0;

        for (self.map.keys(), self.map.values()) |src_range, dest_range| {

            // case 1: input range falls entirely in transform range
            if (input_range.start >= src_range.start and input_range.end <= src_range.end) {
                var res: Range = undefined;

                //negative offset
                if (src_range.start > dest_range.start) {
                    res = Range{
                        .start = input_range.start - (src_range.start - dest_range.start),
                        .end = input_range.end - (src_range.end - dest_range.end),
                    };
                    c1n += 1;
                }
                //positive offset
                else {
                    res = Range{
                        .start = input_range.start + (dest_range.start - src_range.start),
                        .end = input_range.end + (dest_range.end - src_range.end),
                    };
                    c1p += 1;
                }

                std.debug.assert(res.start < res.end);
                std.debug.print("input: {any}\n", .{input_range});
                std.debug.print("src: {any}\n", .{src_range});
                std.debug.print("dest: {any}\n", .{dest_range});
                std.debug.print("res: {any}\n\n", .{res});

                result_list[result_list_len] = res;
                result_list_len += 1;
                continue;
                // return result_list[0..result_list_len];
            }
            // case 2: range overlaps the end of a range but not the start
            if ((input_range.start >= src_range.start and input_range.start < src_range.end) and input_range.end >= src_range.end) {
                var res: Range = undefined;

                //negative offset
                if (src_range.start > dest_range.start) {
                    res = Range{
                        .start = input_range.start - (src_range.start - dest_range.start),
                        .end = dest_range.end,
                    };
                    c2n += 1;
                }
                //positive offset
                else {
                    res = Range{
                        .start = input_range.start + (dest_range.start - src_range.start),
                        .end = dest_range.end,
                    };
                    c2p += 1;
                }
                std.debug.assert(res.start < res.end);
                std.debug.print("input: {any}\n", .{input_range});
                std.debug.print("src: {any}\n", .{src_range});
                std.debug.print("dest: {any}\n", .{dest_range});
                std.debug.print("res: {any}\n\n", .{res});
                result_list[result_list_len] = res;
                result_list_len += 1;
            }
            //case 3: range overlaps with the start of a range but not the end
            if (input_range.start < src_range.start and (input_range.end <= src_range.end and input_range.end > src_range.start)) {
                // const res = Range{
                //     .start = dest_range.start,
                //     .end = @intCast(dest_end - (input_end - src_end)),
                // };
                var res: Range = undefined;
                //negative offset
                if (src_range.end > dest_range.end) {
                    res = Range{
                        .start = dest_range.start,
                        .end = input_range.end - (src_range.end - dest_range.end),
                    };
                    c3n += 1;
                }
                //postive offset
                else {
                    res = Range{
                        .start = dest_range.start,
                        .end = input_range.end + (dest_range.end - src_range.end),
                    };
                    c3p += 1;
                }
                std.debug.assert(res.start < res.end);
                std.debug.print("input: {any}\n", .{input_range});
                std.debug.print("src: {any}\n", .{src_range});
                std.debug.print("dest: {any}\n", .{dest_range});
                std.debug.print("res: {any}\n\n", .{res});
                result_list[result_list_len] = res;
                result_list_len += 1;
            }
            //case 4: input range subsumes src range
            if (input_range.start <= src_range.start and input_range.end >= src_range.end) {
                result_list[result_list_len] = dest_range;
                result_list_len += 1;
            }
        }
        if (result_list_len == 0) {
            result_list[0] = input_range;
            result_list_len += 1;
        }
        return result_list[0..result_list_len];
    }

    pub fn print(self: RangeMap) void {
        std.debug.print("RangeMap:\n", .{});
        std.debug.print("{s}\n", .{self.lines});
    }
};
