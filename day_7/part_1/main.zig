const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("test_input.txt");

    var iter = std.mem.splitScalar(u8, buf, '\n');

    var gpa = std.heap.GeneralPurposeAllocator({}){};
    defer gpa.deinit();
    const alloc = gpa.allocator();
    //track all hands and their ranks
    var hand_map = std.AutoArrayHashMap(Hand, usize).init(alloc);
    defer hand_map.clearAndFree();

    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        // print("{s}\n", .{line});
    }
}

const card = enum(u8) {
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
    T,
    J,
    Q,
    K,
    A,
};

const hand_type = enum(u8) {
    high_card,
    one_pair,
    two_pair,
    three_of_a_kind,
    full_house,
    four_of_a_kind,
    five_of_a_kind,
};

const Hand = struct {
    hand: []card,
    bid: usize,
    type: hand_type,

    // find a hand's type
    pub fn init(string_hand: []const u8, bid: usize) void {
        std.debug.assert(string_hand.len == 5);

        var h_type: hand_type = undefined;

        var hand: [5]card = undefined;

        //convert string to array of type: card
        for (string_hand, 0..5) |string_card, i| {
            const c = switch (string_card) {
                '2' => card.two,
                '3' => card.three,
                '4' => card.four,
                '5' => card.five,
                '6' => card.six,
                '7' => card.seven,
                '8' => card.eight,
                '9' => card.nine,
                'T' => card.T,
                'J' => card.J,
                'Q' => card.Q,
                'K' => card.K,
                'A' => card.A,
            };

            hand[i] = c;
        }

        //record types seen
        var types: []u8 = {};
        var types_len: u8 = 0;
        //find type of hand
        for (hand) |c| {

            var already_seen = false;
            for (0.. types_len, types) |i, t| {
                if (c != t and i == types_len) {
                    types
                }
                if (c == t) {
                    types[i] += 1;
                    types_len += 1;
                }
            }
            
        }
        h_type = switch (types) {
            1 => hand_type.five_of_a_kind,
            //either four of a kind or full house
            2 => hand_type.four_of_a_kind,
            3 => 0,
            4 => hand_type.one_pair,
            5 => hand_type.high_card,
        };

    }

    pub fn stronger_than(self: Hand, hand: Hand) bool {
        if (self.type > hand.type) {
            return true;
        } else if (self.type < hand.type) {
            return false;
        } else {
            for (self.hand, hand) |c1, c2| {}
        }
    }
};
