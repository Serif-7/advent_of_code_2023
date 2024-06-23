const std = @import("std");
const print = std.debug.print;

// testing syntax

const digits = [_][]const u8{
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
};
const slice = [_]struct { []const u8, u8 }{
    .{ "one", 1 },
    .{ "two", 2 },
    .{ "three", 3 },
    .{ "four", 4 },
    .{ "five", 5 },
    .{ "six", 6 },
    .{ "seven", 7 },
    .{ "eight", 8 },
    .{ "nine", 9 },
};
const digit_map = std.ComptimeStringMap(u8, slice);

pub fn main() !void {
    const string = "onetwothree\nfourfivesix";

    inline for (0.., string) |si, char| {
        print("String Index: {d}\n", .{si});
        print("char: {c}\n\n", .{char});

        const num: ?u8 = inline for (digits) |digit| {
            if (std.mem.startsWith(u8, string[si..], digit)) {
                print("Hit: {s}\n", .{string[si..]});
                break digit_map.get(digit);
            }
        } else null;

        print("Digit: {?}\n", .{num});
    }
}
