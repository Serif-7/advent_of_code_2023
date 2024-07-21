const std = @import("std");
const print = std.debug.print;

// lessons
// var loc: usize = std.math.maxInt(usize);

pub fn main() !void {
    const buf = @embedFile("input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var iter = std.mem.splitSequence(u8, buf, "\n\n");

    // set up seed ranges
    const seed_line = iter.next().?;
    var seed_ranges = std.ArrayList(struct { start: usize, len: usize }).init(alloc);
    defer seed_ranges.clearAndFree();
    var seed_iter = std.mem.splitScalar(u8, seed_line, ' ');
    while (seed_iter.next()) |seed| {
        if (std.ascii.isAlphabetic(seed[0])) {
            continue;
        }

        const start: usize = try std.fmt.parseInt(usize, seed, 10);
        const len: usize = try std.fmt.parseInt(usize, seed_iter.next().?, 10);
        try seed_ranges.append(.{ .start = start, .len = len });
    }

    var maps = std.ArrayList(RangeMap).init(alloc);
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
        try maps.append(try RangeMap.init(lines, alloc));
    }

    // const n = maps.items[0].convert(53);
    // print("Converted number: {d}\n", .{n});

    defer {
        for (maps.items) |map| {
            map.deinit();
        }
        maps.clearAndFree();
    }

    // const seed_to_soil: RangeMap = maps.items[0];
    // const soil_to_fertilizer: RangeMap = maps.items[1];
    // const fertilizer_to_water: RangeMap = maps.items[2];
    // const water_to_light: RangeMap = maps.items[3];
    // const light_to_temperature: RangeMap = maps.items[4];
    // const temperature_to_humidity: RangeMap = maps.items[5];
    // const humidity_to_location: RangeMap = maps.items[6];

    //find lowest location number corresponding to initial seed list
    // var location_numbers = std.ArrayList(usize).init(alloc);
    // defer location_numbers.clearAndFree();

    var loc: usize = std.math.maxInt(usize);

    for (seed_ranges.items) |range| {
        var n: usize = undefined;
        for (range.start..(range.start + range.len)) |seed| {
            n = seed;
            for (maps.items) |map| {
                n = map.convert(n);
            }
            print("Converted Seed number to Location number: {d}\n", .{n});
            if (n < loc) {
                loc = n;
            }
        }

        // print("Converted Seed number to Location number: {d}\n", .{n});
    }

    print("Lowest Location Number: {d}\n", .{loc});
}

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

    //convert a number through the appropriate range
    pub fn convert(self: RangeMap, n: usize) usize {
        for (0..self.src.len) |i| {
            if ((n >= self.src[i]) and (n < (self.src[i] + self.length[i]))) {
                return self.dest[i] + (n - self.src[i]);
            }
        }

        return n;
    }

    pub fn print(self: RangeMap) void {
        std.debug.print("RangeMap:\n", .{});
        std.debug.print("{s}\n", .{self.lines});
    }
};
