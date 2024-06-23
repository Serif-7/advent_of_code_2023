const std = @import("std");
const print = std.debug.print;

const MAX_BUFFER = 256;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var arr = std.ArrayList(u8).init(alloc);
    defer arr.deinit();

    while (true) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err|
            switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        // for (arr) |elem| {
        //     print("{}", .{elem});
        // }
        print("{s}\n", .{arr.items});
    }
}
