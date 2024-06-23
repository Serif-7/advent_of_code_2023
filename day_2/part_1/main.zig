const std = @import("std");
const print = std.debug.print;

//read file into buf
// pub fn readFileInCurrentDir(len: usize, buf: *const [len]u8, file_name: []const u8) !void {
//     const cwd: std.fs.Dir = std.fs.cwd();

//     const file = try cwd.openFile(file_name, .{});
//     defer file.close();
//     _ = try file.read(&buf);

//     return;
// }

// *** 12 red cubes, 13 green, 14 blue ***

const MAX_RED = 12;
const MAX_GREEN = 13;
const MAX_BLUE = 14;

pub fn main() !void {
    // var mem: [65536]u8 = undefined;
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    // const fba = std.heap.FixedBufferAllocator.init(&mem);
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
    const buf = try file.readToEndAlloc(alloc, try file.getEndPos());
    defer alloc.free(buf);

    var iter = std.mem.splitScalar(u8, buf, '\n');

    var sum: usize = 0;
    var game_id: usize = 0;
    // var green_count: usize = 0;
    // var red_count: usize = 0;
    // var blue_count: usize = 0;

    // the color follows the number so we set it here first
    // before assigning the value to a color count above
    var count: usize = 0;

    next_game: while (iter.next()) |string| {
        if (iter.peek() == null) {
            break;
        }
        //formatting output
        print("\n", .{});

        var game_is_possible: bool = true;

        print("{s}\n", .{string});

        var s_iter = std.mem.splitScalar(u8, string, ' ');

        next_word: while (s_iter.next()) |word| {
            // if (s_iter.peek() == null) {
            //     break;
            // }
            // if (std.mem.eql(u8, word, "Game")) {
            //     //reset
            //     game_id = 0;
            //     game_is_possible = true;
            //     continue :next_word;
            // }
            //get game ID
            if (std.mem.endsWith(u8, word, ":")) {
                game_id = try std.fmt.parseInt(u8, word[0 .. word.len - 1], 10);
                game_is_possible = true;
                // print("Game ID: {d}\n", .{game_id});
                continue :next_word;
                // if (word.len == 2) {
                //     game_id = try std.fmt.parseInt(u8, word[0..word.len-1], 10);
                // } else if (word.len == 3) {
                //     game_id = try std.fmt.parseInt(u8, word[0..2], 10);
                // } else if (word.len == 4) {
                //     game_id = try std.fmt.parseInt(u8, word[0..3], 10);
                // }
            }
            if (std.ascii.isDigit(word[0]) and !std.mem.endsWith(u8, word, ":")) {
                count = try std.fmt.parseInt(u8, word, 10);
                continue :next_word;
                // print("Count number: {s}\n", .{word});
            }
            if (std.ascii.isAlphabetic(word[0])) {
                if (word[0] == 'b') {
                    // if (std.mem.startsWith(u8, word, "blue")) {
                    if (count > MAX_BLUE) {
                        print("BLUE CUBES OVER LIMIT.\n", .{});
                        game_is_possible = false;
                        continue :next_game;
                    }
                }
                if (word[0] == 'r') {
                    // if (std.mem.startsWith(u8, word, "red")) {
                    if (count > MAX_RED) {
                        print("RED CUBES OVER LIMIT.\n", .{});
                        game_is_possible = false;
                        continue :next_game;
                    }
                }
                if (word[0] == 'g') {
                    // if (std.mem.startsWith(u8, word, "green")) {
                    if (count > MAX_GREEN) {
                        print("GREEN CUBES OVER LIMIT.\n", .{});
                        game_is_possible = false;
                        continue :next_game;
                    }
                }
            }

            // if (std.mem.endsWith(u8, word, ";") or s_iter.peek() == null) {
            //     //check if game was possible according to rules
            //     if (red_count > MAX_RED) {
            //         print("RED CUBES OVER LIMIT.\n", .{});
            //         game_is_possible = false;
            //         continue;
            //     } else if (green_count > MAX_GREEN) {
            //         print("GREEN CUBES OVER LIMIT.\n", .{});
            //         game_is_possible = false;
            //         continue;
            //     } else if (blue_count > MAX_BLUE) {
            //         print("BLUE CUBES OVER LIMIT.\n", .{});
            //         game_is_possible = false;
            //         continue;
            //     }
            // }
        }
        if (game_is_possible) {
            print("Game is possible. ", .{});
            sum += game_id;
            print("Sum is now: {d}\n", .{sum});
        }
    }
    print("Sum of all possible game IDs: {d}\n", .{sum});
}
