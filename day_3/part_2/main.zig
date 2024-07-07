const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

// using a hashmap as a set

// fn isSymbol(c: u8) bool {
//     return switch (c) {
//         '0'...'9', '.', '\r', '\n' => false,
//         else => true,
//     };
// }

//true if a < b
// fn comp(_: void, a: []const u8, b: []const u8) bool {
//     // assert(std.ascii.isDigit());

//     //have to use 'catch unreachable' here because this function cannot return an error
//     const lhs = std.fmt.parseInt(usize, a, 10) catch unreachable;
//     const rhs = std.fmt.parseInt(usize, b, 10) catch unreachable;

//     return lhs < rhs;
// }

//takes a list of number-strings and returns a new sorted list without duplicates.
//Does not respect order.
// fn dedup_numstring_list(list: std.ArrayList([]const u8)) std.ArrayList([]const u8) {
//     for (list.items) |str| {
//         for (str) |c| {
//             print("character: {c}\n", .{c});
//             assert(std.ascii.isDigit(c));
//         }
//     }
//     var mut_list = list.clone() catch unreachable;
//     // mut_list.clearAndFree();

//     std.sort.insertion([]const u8, mut_list.items, {}, comp);

//     var i: usize = 0;
//     while (i < mut_list.items.len - 1) {
//         if (std.mem.eql(u8, mut_list.items[i], mut_list.items[i + 1])) {
//             _ = mut_list.swapRemove(i);
//         } else {
//             i += 1;
//         }
//     }
//     return mut_list;
// }

//return slice
fn get_number_from_line(line: []const u8, index: usize) []const u8 {

    //check backwards
    var start = index;
    while (true) : (start -= 1) {
        if (!std.ascii.isDigit(line[start])) {
            start += 1;
            break;
        }
        if (start == 0) break;
    }
    //check forwards
    var end = index;
    // while (true) : (end += 1) {
    //     if (!std.ascii.isDigit(line[end])) {
    //         // end -= 1;
    //         break;
    //     }
    //     if (end == line.len - 1) break;
    // }
    while (end < line.len and std.ascii.isDigit(line[end])) end += 1;
    // print("get_number_from_line: slice: {s}\n", .{line[start..end]});

    return line[start..end];
}

pub fn main() !void {
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

    var prev_line: ?[]const u8 = null;

    var numbers = std.ArrayList([]const u8).init(alloc);

    //can use the hashmap as a set by making the values of type void
    // var numbers = std.StringArrayHashMap(void).init(alloc);
    // defer numbers.clearAndFree();
    defer numbers.deinit();

    //debugging
    // const line_limit = 2;

    // var line_num: usize = 0;

    while (iter.next()) |line| {
        if (iter.peek() == null) {
            break;
        }
        //debugging
        // if (line_num == line_limit) break;

        // var line_sum: usize = 0;

        print("{s}\n", .{line});

        var i: usize = 0;

        while (i < line.len) : (i += 1) {
            const end_of_line: bool = i == line.len - 1;
            const beg_of_line: bool = i == 0;
            // for (line, 0..) |_, i| {
            // print("index: {d}\n", .{i});
            // print("Char: {c}\n", .{line[i]});

            if (line[i] == '*') {
                if (prev_line) |prev| {
                    var tl = false;

                    if (!beg_of_line) {
                        if (std.ascii.isDigit(prev[i - 1])) {
                            tl = true;
                            try numbers.append(get_number_from_line(prev, i - 1));
                        }
                    }
                    if (std.ascii.isDigit(prev[i]) and !tl) {
                        try numbers.append(get_number_from_line(prev, i));
                    }
                    if (!end_of_line) {
                        if (!std.ascii.isDigit(prev[i]) and std.ascii.isDigit(prev[i + 1])) {
                            try numbers.append(get_number_from_line(prev, i + 1));
                        }
                    }
                }
                if (iter.peek()) |next| {
                    var bl = false;

                    if (!beg_of_line) {
                        if (std.ascii.isDigit(next[i - 1])) {
                            bl = true;
                            try numbers.append(get_number_from_line(next, i - 1));
                        }
                    }
                    if (std.ascii.isDigit(next[i]) and !bl) {
                        try numbers.append(get_number_from_line(next, i));
                    }
                    if (!end_of_line) {
                        if (!std.ascii.isDigit(next[i]) and std.ascii.isDigit(next[i + 1])) {
                            try numbers.append(get_number_from_line(next, i + 1));
                        }
                    }
                }
                // if (iter.peek()) |next| {
                //     if (!beg_of_line) {
                //         if (std.ascii.isDigit(next[i - 1])) {
                //             try numbers.append(get_number_from_line(next, i - 1));
                //         }
                //     }
                //     if (!end_of_line) {
                //         if (std.ascii.isDigit(next[i + 1])) {
                //             try numbers.append(get_number_from_line(next, i + 1));
                //         }
                //     }
                //     if (std.ascii.isDigit(next[i])) {
                //         try numbers.append(get_number_from_line(next, i));
                //     }
                // }
                if (!end_of_line) {
                    if (std.ascii.isDigit(line[i + 1])) {
                        try numbers.append(get_number_from_line(line, i + 1));
                    }
                }
                if (!beg_of_line) {
                    if (std.ascii.isDigit(line[i - 1])) {
                        try numbers.append(get_number_from_line(line, i - 1));
                    }
                }

                // print("List:\n", .{});
                // for (numbers.keys()) |item| {
                //     print("{s}\n", .{item});
                // }

                if (numbers.items.len == 2) {
                    const a = try std.fmt.parseInt(usize, numbers.items[0], 10);
                    print("A: {d}\n", .{a});
                    const b = try std.fmt.parseInt(usize, numbers.items[1], 10);
                    print("B: {d}\n", .{b});
                    sum += (a * b);
                }
                numbers.clearRetainingCapacity();
            }
        }
        prev_line = line;
        // print("Line Number: {d}\n", .{line_num});
        // line_num += 1;
        // print("Line Sum: {d}\n", .{line_sum});
        // print("Sum: {d}\n", .{sum});
        // line_num += 1;
    }
    print("Sum: {d}\n", .{sum});
}
