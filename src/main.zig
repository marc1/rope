const std = @import("std");

const Rope = @import("rope.zig").Rope;
const Node = @import("rope.zig").Node;


pub fn main() !void {
    var seed: u64 = 123456789;//@bitCast(u64, std.time.milliTimestamp());
    var rand = std.rand.Xoroshiro128.init(seed).random();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alc = &gpa.allocator;

    var str = try Rope.init(alc, rand);
    defer str.deinit();

    _ = try str.append('a');
    var b = try str.append('b');
    _ = try str.prepend_to(b.?, 'c');
    var d = try str.prepend_to(b.?, 'd');
    _ = try str.prepend_to(d.?, 'e');

    str.print();
}
