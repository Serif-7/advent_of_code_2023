const std = @import("std");
const print = std.debug.print;

// optional pointers

fn isSymbol(c: u8) bool {
    return switch (c) {
        '!'...'-' => true,
        '=' => true,
        '@' => true,
        else => false,
    };
}

fn test_adjacency(line_index: u8, prev_line: ?[]const u8, curr_line: []const u8, next_line: ?[]const u8) bool {

    //check adjacent positions for symbols

    // end of line
    if (line_index < curr_line.len - 1) {
        if (isSymbol(curr_line[line_index + 1])) {
            return true;
        }
        if (prev_line) |prev| {
            if (isSymbol(prev[line_index + 1])) {
                return true;
            }
        }
        if (next_line) |next| {
            if (next.len == 0) {
                return false;
            }
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
                // print("prev_line[i-1]: {c}\n", .{prev[line_index - 1]});
                return true;
            }
        }
        if (next_line) |next| {
            if (next.len == 0) {
                return false;
            }
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
        if (next.len == 0) {
            return false;
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

    var prev_line: ?[]const u8 = null;

    while (iter.next()) |line| {
        if (iter.peek() == null) {
            break;
        }

        print("{s}\n", .{line});

        var i: u8 = 0;

        while (i < line.len) : (i += 1) {
            // print("index: {d}\n", .{i});
            print("Char: {c}\n", .{line[i]});
            if (std.ascii.isDigit(line[i])) {
                const start: u8 = i;
                var end = i;
                var adj: bool = false;
                while (i < line.len - 1 and std.ascii.isDigit(line[i])) : (i += 1) {
                    if (test_adjacency(i, prev_line, line, iter.peek())) {
                        adj = true;
                    }
                    end += 1;
                }
                if (adj) {
                    // print("Number buffer: {s}\n", .{number_buffer});
                    print("Sum before addition: {d}\n", .{sum});
                    print("Part number: {s}\n", .{line[start..end]});
                    // print("Part Number: {d}\n", .{try std.fmt.parseInt(usize, line[start..end], 10)});
                    sum += try std.fmt.parseInt(usize, line[start..end], 10);
                }
            }
        }
        prev_line = line;
    }
    print("Sum: {d}", .{sum});
}
