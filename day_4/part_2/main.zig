const std = @import("std");
const print = std.debug.print;

// const FixedList = struct {
//     items: undefined,
//     len: usize,
//     T: undefined,

//     pub fn init(size: usize, T: anytype) FixedList {
//         return FixedList{
//             .items = [size]T,
//             .T = @TypeOf(T),
//         };
//     }

//     pub fn append(self: FixedList, elem: @TypeOf(self.T)) void {
//         if (self.len == self.items.len) {
//             //panic
//         }
//         self.items[self.len] = elem;
//     }
// };

// pub fn FixedArrayList(comptime T: type) type {
//     return struct {
//         const Self = @This();
//         items: []T,
//         len: usize = 0,

//         pub fn init(size: usize) void {
//             return Self{
//                 .items = [size]T,
//             };

//         pub fn append(elem: T) void {
//             if (len = items.len) {

//             }
//             items[len] = elem;
//         }
//     }

//     };
// }

// get card ID and number of winning numbers from line
fn get_win_numbers_and_id(line: []const u8) !struct { usize, usize } {
    var sum: usize = 0;
    var card_id: usize = 0;

    var iter = std.mem.tokenizeScalar(u8, line, ' ');

    var fst_section = true;

    var win_numbers = try std.BoundedArray(u8, 30).init(30);
    var player_numbers = try std.BoundedArray(u8, 30).init(30);

    while (iter.next()) |token| {
        if (iter.peek() == null) {
            for (player_numbers.buffer) |p| {
                // print("p: {d}\n", .{p});
                for (win_numbers.buffer) |w| {
                    if (p == w) {
                        // print("Hit! {d},{d}\n", .{ w, p });

                        //recursive call
                        // proc_line(lines.items[card_id + 1])
                        sum += 1;
                    }
                }
            }
            break;
        }
        if (std.mem.endsWith(u8, token, ":")) {
            card_id = try std.fmt.parseInt(usize, token[0 .. token.len - 1], 10);
            continue;
        } else if (std.mem.eql(u8, token, "|")) {
            fst_section = false;
        } else {
            // print("Number: {s}\n", .{token});
            if (fst_section) {
                try win_numbers.append(try std.fmt.parseInt(u8, token, 10));
                // print("Appended: {s}\n", .{token});
                // print("Last item: {d}\n", .{win_numbers.getLast()});
            } else {
                try player_numbers.append(try std.fmt.parseInt(u8, token, 10));
                // print("Last item: {d}\n", .{player_numbers.getLast()});
                // print("Appended: {s}\n", .{token});
            }
        }
    }

    return .{
        card_id,
        sum,
    };
}

//returns the number of copies a card generates

//a copy of a card shares it's ID with it's original
fn get_number_of_copies(card_id: usize, cards: std.ArrayList([]const u8), index: usize) !usize {
    // var card_id: usize = 0;
    var sum: usize = 0;

    //[0] is card_id, [1] is win_numbers: usize
    const tup = try get_win_numbers_and_id(cards.items[index]);

    if (tup[1] == 0) return 0;

    const copies = tup[1];

    for (0..copies) |i| {
        if (index + i > cards.items.len - 1) {
            continue;
        }
        sum += try get_number_of_copies(card_id, cards, index + i);
    }

    return sum;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("test_input.txt", .{});
    defer file.close();
    // const fba = std.heap.FixedBufferAllocator.init(&mem);
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
    const buf = try file.readToEndAlloc(alloc, try file.getEndPos());
    defer alloc.free(buf);

    var iter = std.mem.splitScalar(u8, buf, '\n');

    var lines = std.ArrayList([]const u8).init(alloc);
    var sum: usize = 0;

    //put lines in list
    while (iter.next()) |line| {
        if (iter.peek() == null) {
            break;
        }
        try lines.append(line);
    }

    for (0..lines.items.len) |i| {
        sum += try get_number_of_copies(i + 1, lines, i);
    }

    print("Sum: {s}\n", .{sum});
}
