const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("part2input.txt");

    var iter = std.mem.splitScalar(u8, buf, '\n');
    var times = std.BoundedArray(usize, 30){};
    var distances = std.BoundedArray(usize, 30){};
    var races = std.BoundedArray(Race, 20){};

    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }
        var fst_line = false;

        var tok_iter = std.mem.tokenizeScalar(u8, line, ' ');

        while (tok_iter.next()) |token| {
            // print("Token: {s}\n", .{token});
            if (std.mem.eql(u8, token, "Time:")) {
                fst_line = true;
                continue;
            }

            if (std.ascii.isDigit(token[0])) {
                if (fst_line) {
                    times.appendAssumeCapacity(try std.fmt.parseInt(usize, token, 10));
                } else {
                    distances.appendAssumeCapacity(try std.fmt.parseInt(usize, token, 10));
                }
            }
        }

        // print("{s}\n", .{line});
    }

    std.debug.assert(times.slice().len == distances.slice().len);

    for (0..times.slice().len) |i| {
        races.appendAssumeCapacity(Race.init(times.slice()[i], distances.slice()[i]));
    }

    var sum: usize = 1;
    for (races.slice()) |race| {
        sum *= race.number_of_winning_methods();
    }

    print("Final sum: {d}\n", .{sum});
}

const Race = struct {
    time: usize,
    record_distance: usize,

    pub fn init(time: usize, record_distance: usize) Race {
        return Race{
            .time = time,
            .record_distance = record_distance,
        };
    }

    pub fn number_of_winning_methods(self: Race) usize {
        var wins: usize = 0;
        for (1..self.time) |time_held| {
            const speed = time_held;
            const distance = speed * (self.time - time_held);

            if (distance > self.record_distance) {
                wins += 1;
            }
        }
        // print("Wins: {d}\n", .{wins});
        return wins;
    }
};
