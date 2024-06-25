const std = @import("std");
const print = std.debug.print;

fn isSymbol(char: u8) bool {
    return switch (char) {
        '!'...'-' => true,
        '=' => true,
        else => false,
    };
}

fn test_adjacency(line_index: u8, prev_line: ?[]const u8, curr_line: []const u8, next_line: ?[]const u8) bool {

    //check adjacent positions for symbols

    // end of line
    if (line_index < curr_line.len) {
        if (isSymbol(curr_line[line_index + 1])) {
            return true;
        }
        if (prev_line) |prev| {
            if (isSymbol(prev[line_index + 1])) {
                return true;
            }
        }
        if (next_line) |next| {
            if (isSymbol(next[line_index + 1])) {
                return true;
            }
        }
    }
    //beginning of line
    if (line_index > 0) {
        if (isSymbol(curr_line[line_index - 1])) {
            return true;
        }
        if (prev_line) |prev| {
            if (isSymbol(prev[line_index - 1])) {
                return true;
            }
        }
        if (next_line) |next| {
            if (isSymbol(next[line_index - 1])) {
                return true;
            }
        }
    }
    if (prev_line) |prev| {
        if (isSymbol(prev[line_index])) {
            return true;
        }
    }
    if (next_line) |next| {
        if (isSymbol(next[line_index])) {
            return true;
        }
    }
    return false;
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

    while (iter.next()) |line| {
        if (iter.peek() == null) {
            break;
        }

        var i: u8 = 0;

        print("{s}", .{line});

        while (i < line.len) : (i += 1) {
            if (std.ascii.isDigit(line[i])) {
                if (test_adjacency(i, null, line, iter.peek())) {
                    const start: u8 = i;
                    var end = i;
                    // var number_buffer = [1]u8{'_'} ** 5;
                    while (std.ascii.isDigit(line[i])) : (i += 1) {
                        // number_buffer[j] = line[i];
                        end += 1;
                    }
                    // print("Number buffer: {s}\n", .{number_buffer});
                    print("Sum before addition: {d}\n", .{sum});
                    print("Part number: {s}\n", .{line[start..end]});
                    // print("Part Number: {d}\n", .{try std.fmt.parseInt(usize, line[start..end], 10)});
                    sum += try std.fmt.parseInt(usize, line[start..end], 10);
                }
            }
        }
        print("Sum: {d}\n", .{sum});
    }
    print("Sum: {d}\n", .{sum});
}
