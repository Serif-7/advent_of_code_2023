const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    // const fba = std.heap.FixedBufferAllocator.init(&mem);
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
    const buf = try file.readToEndAlloc(alloc, try file.getEndPos());
    defer alloc.free(buf);

    // var factors = std.ArrayList(u8).init(alloc);
    // defer factors.deinit();

    // var factors = std.ArrayHashMap([]const u8, u8, std.array_hash_map.StringContext, false);
    // defer factors.deinit();

    var sum_of_powers: usize = 0;
    var cube_cnt: u8 = 0;
    var factors = [3]?u8{
        null, //red
        null, //green
        null, //blue
    };

    const red: *?u8 = &factors[0];
    const green: *?u8 = &factors[1];
    const blue: *?u8 = &factors[2];

    var iter = std.mem.splitScalar(u8, buf, '\n');

    while (iter.next()) |game| {
        if (iter.peek() == null) {
            break;
        }
        print("{s}\n", .{game});

        factors[0] = null;
        factors[1] = null;
        factors[2] = null;

        var s_iter = std.mem.splitScalar(u8, game, ' ');

        next_word: while (s_iter.next()) |word| {
            if (std.ascii.isDigit(word[0]) and !std.mem.endsWith(u8, word, ":")) {
                cube_cnt = try std.fmt.parseInt(u8, word, 10);
                continue :next_word;
            }
            if (std.ascii.isAlphabetic(word[0])) {
                if (word[0] == 'b') {
                    //check if blue is already a factor
                    if (blue.* == null) {
                        blue.* = cube_cnt;
                    } else if (cube_cnt > blue.*.?) {
                        blue.* = cube_cnt;
                    }
                    continue :next_word;
                }
                if (word[0] == 'r') {
                    if (red.* == null) {
                        red.* = cube_cnt;
                    } else if (cube_cnt > red.*.?) {
                        red.* = cube_cnt;
                    }
                    continue :next_word;
                }
                if (word[0] == 'g') {
                    if (green.* == null) {
                        green.* = cube_cnt;
                    } else if (cube_cnt > green.*.?) {
                        green.* = cube_cnt;
                    }
                    continue :next_word;
                }
            }
        }
        var power: usize = 1;
        for (factors) |fac| {
            if (fac != null) {
                print("factor: {?}\n", .{fac});
                power *= fac.?;
            }
        }
        sum_of_powers += power;
    }

    print("Sum of Powers: {d}", .{sum_of_powers});
}
