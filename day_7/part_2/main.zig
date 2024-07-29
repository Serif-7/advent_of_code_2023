const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var iter = std.mem.splitScalar(u8, buf, '\n');

    //track all hands and their ranks
    var hand_map = std.AutoArrayHashMap(Hand, usize).init(alloc);
    defer hand_map.clearAndFree();
    var hand_arr = std.ArrayList(Hand).init(alloc);
    defer hand_arr.clearAndFree();

    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        var s_iter = std.mem.tokenizeScalar(u8, line, ' ');

        const string_hand = s_iter.next().?;
        const bid = s_iter.next().?;
        const hand = try Hand.init(string_hand, try std.fmt.parseInt(usize, bid, 10));

        //sort hand into list
        if (hand_arr.items.len == 0) {
            try hand_arr.append(hand);
        } else {
            for (0..hand_arr.items.len, hand_arr.items) |i, h| {
                if (hand.eq(h) == std.math.Order.eq) {
                    break;
                }
                //greater
                if (hand.eq(h) == std.math.Order.gt) {
                    //if end of line
                    if (i + 1 == hand_arr.items.len) {
                        try hand_arr.append(hand);
                        break;
                    } else if (hand.eq(hand_arr.items[i + 1]) == std.math.Order.lt) {
                        try hand_arr.insert(i + 1, hand);
                        break;
                    }
                }
                //lesser
                if (hand.eq(h) == std.math.Order.lt) {
                    try hand_arr.insert(i, hand);
                    break;
                }
            }
        }

        // print("{s}\n", .{line});
    }
    var sum: usize = 0;

    for (0..hand_arr.items.len, hand_arr.items) |i, h| {
        sum += h.bid * (i + 1);
    }

    print("Final Sum: {d}\n", .{sum});
}

const Card = enum(u8) {
    J,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
    T,
    Q,
    K,
    A,
};

const HandType = enum(u8) {
    high_card,
    one_pair,
    two_pair,
    three_of_a_kind,
    full_house,
    four_of_a_kind,
    five_of_a_kind,
};

const Hand = struct {
    hand: [5]Card,
    bid: usize,
    type: HandType,

    pub fn init(string_hand: []const u8, bid: usize) !Hand {
        std.debug.assert(string_hand.len == 5);

        var hand: [5]Card = undefined;

        // var card_map = std.BoundedArray(, )

        //convert string to array of type: card
        for (string_hand, 0..5) |string_card, i| {
            const c = switch (string_card) {
                'J' => Card.J,
                '2' => Card.two,
                '3' => Card.three,
                '4' => Card.four,
                '5' => Card.five,
                '6' => Card.six,
                '7' => Card.seven,
                '8' => Card.eight,
                '9' => Card.nine,
                'T' => Card.T,
                'Q' => Card.Q,
                'K' => Card.K,
                'A' => Card.A,
                else => unreachable,
            };

            hand[i] = c;
        }

        return Hand{
            .hand = hand,
            .bid = bid,
            .type = try Hand.hand_type(hand),
        };
    }

    pub fn eq(self: Hand, opp: Hand) std.math.Order {
        if (@intFromEnum(self.type) > @intFromEnum(opp.type)) {
            return std.math.Order.gt;
        } else if (@intFromEnum(self.type) < @intFromEnum(opp.type)) {
            return std.math.Order.lt;
        } else {
            return std.mem.order(u8, @as([]const u8, @ptrCast(&self.hand)), @as([]const u8, @ptrCast(&opp.hand)));
            // for (self.hand, opp.hand) |x1, x2| {
            //     const c1 = @intFromEnum(x1);
            //     const c2 = @intFromEnum(x2);
            //     if (c1 > c2) {
            //         return std.math.Order.gt;
            //     } else if (c1 < c2) {
            //         return std.math.Order.lt;
            //     } else if (c1 == c2) {
            //         continue;
            //     }
            // }
            // return std.math.Order.eq;
        }
    }

    pub fn hand_type(hand: [5]Card) !HandType {
        //record types seen
        // var types: []u8 = {};
        // var types_len: u8 = 0;

        // std.debug.assert(hand.len == 5);

        // var card_map = std.BoundedArray(struct{ .card, .count}, 5){};
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const alloc = gpa.allocator();
        var card_map = std.AutoArrayHashMap(Card, usize).init(alloc);
        defer card_map.clearAndFree();
        //find type of hand
        for (hand) |c| {
            if (card_map.get(c)) |v| {
                try card_map.put(c, v + 1);
            } else {
                try card_map.put(c, 1);
            }
        }

        return switch (card_map.count()) {
            5 => HandType.high_card,
            4 => HandType.one_pair,
            3 => for (card_map.values()) |v| {
                switch (v) {
                    2 => break HandType.two_pair,
                    3 => break HandType.three_of_a_kind,
                    else => {},
                }
            } else {
                unreachable;
            },
            2 => for (card_map.values()) |v| {
                switch (v) {
                    1, 4 => break HandType.four_of_a_kind,
                    3, 2 => break HandType.full_house,
                    else => {},
                }
            } else {
                unreachable;
            },
            1 => HandType.five_of_a_kind,
            else => unreachable,
        };

        // h_type = switch (types) {
        //     1 => hand_type.five_of_a_kind,
        //     //either four of a kind or full house
        //     2 => hand_type.four_of_a_kind,
        //     3 => 0,
        //     4 => hand_type.one_pair,
        //     5 => hand_type.high_card,
        // };
    }
};
