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

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    // const fba = std.heap.FixedBufferAllocator.init(&mem);
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
    const buf = try file.readToEndAlloc(alloc, try file.getEndPos());
    defer alloc.free(buf);

    var sum: usize = 0;

    var i: usize = 0;

    while (i < buf.len) : (i += 1) {
        var adj = false;

        if (std.ascii.isDigit(buf[i])) {
            const start = i;
            var end = i;

            while (std.ascii.isDigit(buf[i]) and i < buf.len - 1) : (i += 1) {
                if (isSymbol(buf[i + 1])) {
                    adj = true;
                }
                if (i > 0) {
                    if (isSymbol(buf[i - 1])) {
                        adj = true;
                    }
                }
                if (i >= 140) {
                    if (isSymbol(buf[i - 140] 
                        or isSymbol(buf[i - ]))) {
                        adj = true;
                    }
                }
                end += 1;
            }
        }
    }

    print("Sum: {d}\n", .{sum});
}
