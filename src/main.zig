const std = @import("std");

const Rope = @import("rope.zig").Rope;
const Node = @import("rope.zig").Node;


pub fn main() !void {
    var seed: u64 = 1234;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alc = &gpa.allocator;

    var str = try Rope.init(alc, seed);
    defer str.deinit();
    _ = str;
}
