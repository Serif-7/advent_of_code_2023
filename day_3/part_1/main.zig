const std = @import("std");
const print = std.debug.print;

// optional pointers

fn isSymbol(c: u8) bool {
    return switch (c) {
        '0'...'9', '.', '\r', '\n' => false,
        else => true,
    };
}

fn test_adjacency(line_index: usize, prev_line: ?[]const u8, curr_line: []const u8, next_line: ?[]const u8) bool {

    //check adjacent positions for symbols

    const not_end_of_line: bool = if (line_index < curr_line.len - 1) true else false;
    const not_beg_of_line: bool = if (line_index > 0) true else false;

    // print("Line index: {d}\n", .{line_index});
    // print("Line Length: {d}\n", .{curr_line.len});

    if (prev_line) |prev| {
        if (not_end_of_line) {
            if (isSymbol(prev[line_index + 1])) {
                return true;
            }
        }
        if (not_beg_of_line) {
            if (isSymbol(prev[line_index - 1])) {
                // print("prev_line[i-1]: {c}\n", .{prev[line_index - 1]});
                return true;
            }
        }
        if (isSymbol(prev[line_index])) {
            return true;
        }
    }
    if (not_beg_of_line) {
        if (isSymbol(curr_line[line_index - 1])) {
            return true;
        }
    }
    if (not_end_of_line) {
        if (isSymbol(curr_line[line_index + 1])) {
            return true;
        }
    }

    if (next_line) |next| {
        if (next.len == 0) return false;
        if (not_end_of_line) {
            if (isSymbol(next[line_index + 1])) {
                return true;
            }
        }
        if (not_beg_of_line) {
            if (isSymbol(next[line_index - 1])) {
                // print("prev_line[i-1]: {c}\n", .{prev[line_index - 1]});
                return true;
            }
        }
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
    var line_num: usize = 1;

    var prev_line: ?[]const u8 = null;

    while (iter.next()) |line| {
        if (iter.peek() == null) {
            break;
        }

        var line_sum: usize = 0;

        print("{s}\n", .{line});

        var i: usize = 0;

        while (i < line.len) : (i += 1) {
            // for (line, 0..) |_, i| {
            // print("index: {d}\n", .{i});
            // print("Char: {c}\n", .{line[i]});
            if (std.ascii.isDigit(line[i])) {
                const start: usize = i;
                var adj: bool = false;
                while (i < line.len and std.ascii.isDigit(line[i])) : (i += 1) {
                    if (test_adjacency(i, prev_line, line, iter.peek())) {
                        adj = true;
                    }
                }
                if (adj) {
                    // print("Number buffer: {s}\n", .{number_buffer});
                    // print("Sum before addition: {d}\n", .{sum});
                    // print("Part number: {s}\n", .{line[start..end]});
                    // print("Part Number: {d}\n", .{try std.fmt.parseInt(usize, line[start..end], 10)});
                    sum += try std.fmt.parseInt(usize, line[start..i], 10);
                    line_sum += try std.fmt.parseInt(usize, line[start..i], 10);
                }
            }
        }
        prev_line = line;
        print("Line Number: {d}\n", .{line_num});
        line_num += 1;
        print("Line Sum: {d}\n", .{line_sum});
        // print("Sum: {d}\n", .{sum});
    }
    print("Sum: {d}\n", .{sum});
}
