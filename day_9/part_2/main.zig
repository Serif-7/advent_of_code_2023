const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var iter = std.mem.splitScalar(u8, buf, '\n');

    // store extrapolated history values here
    var res_values = std.ArrayList(isize).init(alloc);
    defer res_values.clearAndFree();

    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }
        var diff_arrays = std.ArrayList(std.ArrayList(isize)).init(alloc);
        defer {
            for (diff_arrays.items) |*arr| {
                arr.clearAndFree();
            }
            diff_arrays.clearAndFree();
        }

        var diff_array = std.ArrayList(isize).init(alloc);
        var line_iter = std.mem.tokenizeAny(u8, line, " ");
        //parse string
        while (line_iter.next()) |token| {
            const a = try std.fmt.parseInt(isize, token, 10);
            try diff_array.append(a);
        }
        try diff_arrays.append(diff_array);

        while (!all_zero(diff_arrays.getLast())) {
            try diff_arrays.append(try get_diffs(diff_arrays.getLast(), alloc));
        }

        try res_values.append(extrapolate_backward(diff_arrays));
        for (diff_arrays.items) |arr| {
            for (arr.items) |e| {
                print("{d} ", .{e});
            }
            print("\n", .{});
        }

        // print("{s}\n", .{line});
    }

    var final_result: isize = 0;
    for (res_values.items) |e| {
        print("{d}\n", .{e});
        final_result += e;
    }
    print("Result: {d}\n", .{final_result});
}

fn all_zero(arr: std.ArrayList(isize)) bool {
    for (arr.items) |e| {
        if (e != 0) {
            return false;
        }
    }
    return true;
}

//returns an array of diffs between the elements of the argument array
fn get_diffs(arr: std.ArrayList(isize), alloc: std.mem.Allocator) !std.ArrayList(isize) {
    var res = std.ArrayList(isize).init(alloc);
    for (0..arr.items.len - 1) |i| {
        const a = arr.items[i];
        const b = arr.items[i + 1];
        // const diff = @abs(a - b);
        const diff: isize = b - a;
        try res.append(@intCast(diff));
    }

    return res;
}

fn extrapolate_forward(diff_arrays: std.ArrayList(std.ArrayList(isize))) isize {
    // var lasts = std.ArrayList(isize).init(alloc);
    // defer lasts.clearAndFree();

    var res: isize = 0;
    for (diff_arrays.items) |arr| {
        var a: isize = undefined;
        if (arr.items.len == 0) {
            a = 0;
        } else {
            a = arr.getLast();
        }
        res += a;
    }

    return res;
}

fn extrapolate_backward(diff_arrays: std.ArrayList(std.ArrayList(isize))) isize {
    var res: isize = 0;

    var i: usize = diff_arrays.items.len - 1;
    while (true) : (i -= 1) {
        const arr = diff_arrays.items[i];
        var a: isize = undefined;
        if (arr.items.len == 0) {
            a = 0;
        } else {
            a = arr.items[0];
        }
        res = a - res;
        if (i == 0) break;
    }
    // for (diff_arrays.items[1..]) |arr| {
    //     var a: isize = undefined;
    //     if (arr.items.len == 0) {
    //         a = 0;
    //     } else {
    //         a = arr.items[0];
    //     }
    //     res -= a;
    // }
    return res;
}

test "negative list" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const init_arr = [_]isize{
        4,
        -1,
        -6,
        -11,
        -16,
        -21,
        -26,
        -31,
        -36,
        -41,
        -46,
        -51,
        -56,
        -61,
        -66,
        -71,
        -76,
        -81,
        -86,
        -91,
        -96,
    };
    var arr = std.ArrayList(isize).init(alloc);
    try arr.appendSlice(&init_arr);

    var diff_arrays = std.ArrayList(std.ArrayList(isize)).init(alloc);
    defer {
        for (diff_arrays.items) |*diff_arr| {
            diff_arr.clearAndFree();
        }
        diff_arrays.clearAndFree();
    }
    try diff_arrays.append(arr);

    while (!all_zero(diff_arrays.getLast())) {
        try diff_arrays.append(try get_diffs(diff_arrays.getLast(), alloc));
    }

    for (diff_arrays.items) |a| {
        for (a.items) |e| {
            print("{d} ", .{e});
        }
        print("\n", .{});
    }
}

test "extrapolate_backwards()" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const init_arr = [_]isize{
        4,
        -1,
        -6,
        -11,
        -16,
        -21,
        -26,
        -31,
        -36,
        -41,
        -46,
        -51,
        -56,
        -61,
        -66,
        -71,
        -76,
        -81,
        -86,
        -91,
        -96,
    };
    var arr = std.ArrayList(isize).init(alloc);
    try arr.appendSlice(&init_arr);

    var diff_arrays = std.ArrayList(std.ArrayList(isize)).init(alloc);
    defer {
        for (diff_arrays.items) |*diff_arr| {
            diff_arr.clearAndFree();
        }
        diff_arrays.clearAndFree();
    }
    try diff_arrays.append(arr);

    while (!all_zero(diff_arrays.getLast())) {
        try diff_arrays.append(try get_diffs(diff_arrays.getLast(), alloc));
    }

    for (diff_arrays.items) |a| {
        for (a.items) |e| {
            print("{d} ", .{e});
        }
        print("\n", .{});
    }
}
