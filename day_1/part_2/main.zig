const std = @import("std");
const print = std.debug.print;

// Advent of Code 2023: day 1 part 2
// https://adventofcode.com/2023/day/1

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

// StaticStringMap is on Zig 0.13
const digit_map = std.ComptimeStringMap(u8, slice);

// const digit_map = std.static_string_map.StaticStringMap(u8).initComptime(slice);

pub fn main() !void {
    const cwd: std.fs.Dir = std.fs.cwd();
    const file = try cwd.openFile("input.txt", .{});
    var buf: [65536]u8 = undefined;

    _ = try file.read(&buf);

    var iter = std.mem.splitScalar(u8, &buf, '\n');

    //hardcoded
    var digit_pairs: [1000][2]u8 = undefined;
    var pair_index: usize = 0;

    // while conditionals can be 'nullable values'
    while (iter.next()) |string| {
        if (iter.peek() == null) {
            break;
        }
        print("String: {s}\n", .{string});
        var first_digit: ?u8 = null;
        var second_digit: ?u8 = null;

        for (0.., string) |str_i, char| {
            if (!std.ascii.isASCII(char)) {
                // print("Non-ASCII characters in string\n", .{});
                // print("Non-ASCII char: {b}\n", .{char});
                break;
            }
            print("char: {c}\n", .{char});

            // check if char is a digit
            if (std.ascii.isDigit(char)) {
                print("Hit: Digit = {d}\n", .{char - '0'});
                if (first_digit == null) {
                    first_digit = char - '0';
                } else {
                    second_digit = char - '0';
                    // print("sd: {?}\n", .{second_digit});
                    // print("fd: {?}\n", .{first_digit});
                }
                continue;
            }

            // if (j == 100) return;
            // print("Value of j: {d}\n", .{j});
            if (std.ascii.isAlphabetic(char)) {
                // const num: ?u8 = inline for (0.., digits) |k, digit| {
                //     if (std.mem.startsWith(u8, string[j..], digit)) {
                //         break k + 1;
                //     }
                // } else null;

                const num: ?u8 = inline for (digits) |digit| {
                    // if (string.len >= j + digit.len and std.mem.eql(u8, string[j.. j + digit.len], digit)) {
                    if (std.mem.startsWith(u8, string[str_i..], digit)) {
                        print("Hit: Digit = {?}\n", .{digit_map.get(digit)});
                        break digit_map.get(digit);
                    }
                } else null;

                print("sd: {?}\n", .{second_digit});
                print("fd: {?}\n", .{first_digit});
                if (first_digit == null) {
                    first_digit = num;
                } else if (num == null) {
                    continue;
                } else {
                    second_digit = num;
                }
            }
        }

        if (second_digit == null) {
            second_digit = first_digit;
        }
        if (first_digit == null or second_digit == null) {
            print("Null values.\n", .{});
            print("String len: {d}", .{string.len});
            // print("Digit pair 1: {d}{d}\n", .{ digit_pairs[0][0], digit_pairs[0][1] });
            return error.GenericError;
        }
        digit_pairs[pair_index][0] = first_digit.?;
        print("First Digit: {?}\n", .{first_digit});
        digit_pairs[pair_index][1] = second_digit.?;
        print("Second Digit: {?}\n", .{second_digit});
        pair_index += 1;
    }

    var sum: usize = 0;

    // var two_digit: usize = 0;

    // print("digit pairs: {s}", .{digit_pairs});

    for (digit_pairs) |tup| {
        // print("{d} : ", .{tup[0]});
        // print("{d}\n", .{tup[1]});
        //convert chars to two-digit number
        // const fst = tup[0] + '0';
        // const snd = tup[1] + '0';
        // const tup2: [2]u8 = .{ fst, snd };
        // two_digit = try std.fmt.parseInt(u8, &tup2, 10);
        sum += tup[0] * 10 + tup[1];
    }

    print("Sum: {d}", .{sum});
}
