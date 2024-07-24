const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("input.txt");

    var iter = std.mem.splitScalar(u8, buf, '\n');

    var gpa = std.heap.GeneralPurposeAllocator({}){};
    const alloc = gpa.allocator();
    //track all hands and their ranks
    var hand_map = std.AutoArrayHashMap(Hand, usize).init(alloc);

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
    pub fn init(hand: []const u8, bid: usize) Hand {

        var arr = std.BoundedArray(card, 5){};

        //convert string to array of type: card
        for (hand) |string_card| {
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

            arr.appendAssumeCapacity(c);
        }

        for (0..arr.slice().len) |i| {

            for ()
        }
    }

    pub fn stronger_than(self: Hand, hand: Hand) bool {
        if (self.type > hand.type) {
            return true;
        } else if (self.type < hand.type) {
            return false;
        } else {
            for (self.hand, hand) |c1, c2| {
                
            }
        }
    }
};
