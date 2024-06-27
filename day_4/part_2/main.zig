const std = @import("std");
const print = std.debug.print;

fn proc_line(line: []const u8, line_array_len: u8) !usize {
    var card_id: usize = 0;
    var copies: u8 = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var win_numbers = std.ArrayList(u8).init(alloc);
    defer win_numbers.deinit();
    var player_numbers = std.ArrayList(u8).init(alloc);
    defer player_numbers.deinit();

    var tok_iter = std.mem.tokenizeScalar(u8, line, " ");

    var fst_section = true;

    //process line
    while (tok_iter.next()) |token| {
        if (tok_iter.peek() == null) {
            for (player_numbers.items) |p| {
                // print("p: {d}\n", .{p});
                for (win_numbers.items) |w| {
                    if (p == w) {
                        // print("Hit! {d},{d}\n", .{ w, p });

                        //recursive call
                        proc_line(lines.items[card_id + 1])
                        copies += 1;
                    }
                }
            }
            //clear lists
            win_numbers.clearAndFree();
            player_numbers.clearAndFree();
            fst_section = true;
            break;
        }
        // if (std.mem.eql(u8, token, "Card")) {
        //     print("\n", .{});
        // }
        // print("{s} ", .{token});

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

    var lines = std.ArrayList([]const u8).init(alloc);
    var sum: usize = 0;

    //put lines in list
    while (iter.next()) |line| {
        if (iter.peek() == null) {
            break;
        }
        lines.append(line);
    }

    for (lines) |line| {
        sum += proc_line(line, lines.items.len);
    }

    print("Sum: {s}\n", .{sum});
}
