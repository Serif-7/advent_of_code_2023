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

    var iter = std.mem.tokenizeAny(u8, buf, " \n");
    var sum: usize = 0;

    //winning numbers
    var win_numbers = std.ArrayList(u8).init(alloc);
    defer win_numbers.deinit();

    //player numbers
    var player_numbers = std.ArrayList(u8).init(alloc);
    defer player_numbers.deinit();

    var fst_section: bool = true;

    while (iter.next()) |token| {
        if (iter.peek() == null) {
            break;
        }
        // if (std.mem.eql(u8, token, "Card")) {
        //     print("\n", .{});
        // }
        // print("{s} ", .{token});

        if (std.mem.eql(u8, token, "Card")) {
            var points: usize = 0;
            for (player_numbers.items) |p| {
                print("p: {d}\n", .{p});
                for (win_numbers.items) |w| {
                    print("w: {d}\n", .{w});
                    // print("w: {d}, p: {d}\n", .{ w, p });
                    if (p == w) {
                        print("Hit! {d},{d}\n", .{ w, p });
                        if (points == 0) {
                            points = 1;
                        } else {
                            points *= 2;
                        }
                    }
                }
            }
            print("Points: {d}\n", .{points});
            sum += points;
            //clear lists
            win_numbers.clearAndFree();
            player_numbers.clearAndFree();
            fst_section = true;
            continue;
        } else if (std.mem.endsWith(u8, token, ":")) {
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
    print("Sum: {d}\n", .{sum});
}
