const std = @import("std");
const Allocator = std.mem.Allocator;

const __rope = @import("rope.zig");
const Rope = __rope.Rope;
const Node = __rope.Node;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alc = &gpa.allocator;

    var rope = try Rope.init(alc);
    defer rope.deinit();

    try rope.append('a');
    try rope.append('b');
    try rope.append('c');

    rope.print();
}
