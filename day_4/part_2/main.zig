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

    // var win_numbers = try std.BoundedArray(u8, 100).init(300);
    // var player_numbers = try std.BoundedArray(u8, 100).init(300);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
    var win_numbers = std.ArrayList(u8).init(alloc);
    var player_numbers = std.ArrayList(u8).init(alloc);
    defer win_numbers.clearAndFree();
    defer player_numbers.clearAndFree();

    while (iter.next()) |token| {
        if (std.mem.endsWith(u8, token, ":")) {
            card_id = try std.fmt.parseInt(usize, token[0 .. token.len - 1], 10);
            // print("Card ID: {d}\n", .{card_id});
            continue;
        } else if (std.mem.eql(u8, token, "|")) {
            fst_section = false;
            continue;
        } else if (std.ascii.isDigit(token[0])) {
            // print("Number: {s}\n", .{token});
            if (fst_section) {
                const n = try std.fmt.parseInt(u8, token, 10);
                // print("win number: {d}\n", .{n});
                try win_numbers.append(n);
                // print("Appended: {s}\n", .{token});
                // print("Last item: {d}\n", .{win_numbers.getLast()});
            } else {
                const n = try std.fmt.parseInt(u8, token, 10);
                // print("player number: {d}\n", .{n});
                try player_numbers.append(n);
                // print("Last item: {d}\n", .{player_numbers.getLast()});
                // print("Appended: {s}\n", .{token});
            }
        }
        if (iter.peek() == null) {
            for (win_numbers.items) |w| {
                // print("p: {d}\n", .{p});
                for (player_numbers.items) |p| {
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
    }
    // print("get_win_numbers_and_id():\n", .{});
    // print("Card ID: {d}\n", .{card_id});
    // print("Sum: {d}\n", .{sum});

    return .{
        card_id,
        sum,
    };
}

test "Evaluates line 1 of test_input.txt to 4 matches" {
    const line: []const u8 = "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53";

    const tup = try get_win_numbers_and_id(line);

    try std.testing.expectEqual(4, tup[1]);
}
test "Evaluates line 2 of test_input.txt to 2 matches" {
    const line: []const u8 = "Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19";
    const tup = try get_win_numbers_and_id(line);

    try std.testing.expectEqual(2, tup[1]);
}
test "Evaluates line 3 of test_input.txt to 2 matches" {
    const line: []const u8 = "Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1";
    const tup = try get_win_numbers_and_id(line);

    try std.testing.expectEqual(2, tup[1]);
}

//returns the number of copies a card generates
//a copy of a card shares it's ID with it's original
fn get_number_of_copies(card_id: usize, cards: std.ArrayList([]const u8), index: usize) !usize {
    // var card_id: usize = 0;

    //[0] is card_id, [1] is win_numbers: usize
    const tup = try get_win_numbers_and_id(cards.items[index]);

    if (tup[1] == 0) return 0;

    const number_of_copies = tup[1];
    // const real_card_id = tup[0];

    var sum: usize = number_of_copies;

    for (1..number_of_copies + 1) |i| {
        if (index + i > cards.items.len) {
            break;
        }
        const copies = try get_number_of_copies(card_id, cards, index + i);
        // print("DEBUGGING\n", .{});
        // print("get_number_of_copies()\n", .{});
        // if (real_card_id == card_id) {
        //     print("Original instance.\n", .{});
        //     print("ID: {d}\n", .{card_id});
        // } else {
        //     print("Copy.\n", .{});
        //     print("Real ID: {d}\n", .{real_card_id});
        //     print("Copied ID: {d}\n", .{card_id});
        // }
        // print("Copies: {d}\n", .{copies});
        // print("Sum: {d}\n", .{sum});
        sum += copies;
    }

    return sum;
}

test "Evaluates Card 1 to have 13 copies total" {
    const lines =
        \\ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;

    var iter = std.mem.splitScalar(u8, lines, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
    var line_array = std.ArrayList([]const u8).init(alloc);
    defer line_array.clearAndFree();
    while (iter.next()) |line| {
        try line_array.append(line);
        if (iter.peek() == null) {
            break;
        }
    }

    const copies = try get_number_of_copies(1, line_array, 0);

    try std.testing.expectEqual(13, copies);
}
test "Evaluates Card 2 to have 5 copies total" {
    const lines =
        \\ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;

    var iter = std.mem.splitScalar(u8, lines, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
    var line_array = std.ArrayList([]const u8).init(alloc);
    defer line_array.clearAndFree();
    while (iter.next()) |line| {
        try line_array.append(line);
        if (iter.peek() == null) {
            break;
        }
    }

    const copies = try get_number_of_copies(2, line_array, 1);

    try std.testing.expectEqual(5, copies);
}
test "Evaluates Card 3 to have 3 copies total" {
    const lines =
        \\ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;

    var iter = std.mem.splitScalar(u8, lines, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
    var line_array = std.ArrayList([]const u8).init(alloc);
    defer line_array.clearAndFree();
    while (iter.next()) |line| {
        try line_array.append(line);
        if (iter.peek() == null) {
            break;
        }
    }

    const copies = try get_number_of_copies(3, line_array, 2);

    try std.testing.expectEqual(3, copies);
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
    defer lines.clearAndFree();
    var sum: usize = 0;

    // var card_matches: [100]
    // var card_hash = std.StringHashMap(usize).init(alloc);
    // defer card_hash.deinit();
    // card_hash.put("1", 0);
    // card_hash.put("1", 0);
    // card_hash.put("1", 0);
    // card_hash.put("1", 0);
    // card_hash.put("1", 0);
    // card_hash.put("1", 0);
    //put lines in list
    while (iter.next()) |line| {
        try lines.append(line);
        if (iter.peek() == null) {
            break;
        }
    }

    for (0.., lines.items) |i, line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }
        // const tup = try get_win_numbers_and_id(line);
        // print("ID: {d}, Matches: {d}\n", .{ tup[0], tup[1] });
        const copies = try get_number_of_copies(i + 1, lines, i);
        sum += copies;
        // print("Index: {d}\n", .{i});
        // print("Copies: {d}\n", .{copies});
        // sum += try get_number_of_copies(i + 1, lines, i);
        sum += 1; //add one for each original card
        // print("Sum: {d}\n", .{sum});
    }

    print("Sum: {d}\n", .{sum});
}
