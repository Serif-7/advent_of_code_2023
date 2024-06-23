const std = @import("std");
const print = std.debug.print;

// Advent of Code 2023: Puzzle 1
// https://adventofcode.com/2023/day/1

pub fn main() !void {
    const cwd: std.fs.Dir = std.fs.cwd();
    const file = try cwd.openFile("input.txt", .{});

    var buf: [65536]u8 = undefined;

    _ = try file.read(&buf);

    var iter = std.mem.splitScalar(u8, &buf, '\n');
    var string = iter.first();

    //hardcoded
    var digit_pairs: [1000][2]u8 = undefined;
    var i: usize = 0;

    while (iter.peek() != null) : (string = iter.next().?) {
        var first_digit: ?u8 = null;
        var second_digit: ?u8 = null;

        for (string) |char| {
            if (std.ascii.isAlphabetic(char)) {
                continue;
            }

            if (std.ascii.isDigit(char)) {
                if (first_digit == null) {
                    first_digit = char;
                } else {
                    second_digit = char;
                }
            }
        }
        if (second_digit == null) {
            second_digit = first_digit;
        }
        digit_pairs[i][0] = first_digit.?;
        digit_pairs[i][1] = second_digit.?;
        i += 1;
    }

    var sum: usize = 0;

    var two_digit: usize = 0;

    for (digit_pairs) |tup| {
        print("{c} : ", .{tup[0]});
        print("{c}\n", .{tup[1]});
        //convert chars to two-digit number

        two_digit = try std.fmt.parseInt(u8, &tup, 10);
        sum += two_digit;
    }

    print("Sum: {d}", .{sum});
}

//read a single line into a buffer, delimited by a newline
pub fn getline(file: std.fs.File, buf: []u8) !usize {
    var fbs = std.io.fixedBufferStream(buf);
    const reader = file.reader();
    // "" is for strings, '' is for single chars
    try reader.streamUntilDelimiter(fbs.writer(), '\n', fbs.buffer.len);
    const output = fbs.getWritten();
    // buf[output.len] = "\n";
    return output.len;
}
