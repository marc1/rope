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
    try rope.append('d');
    try rope.append('e');
    try rope.append('f');
    try rope.append('g');
    try rope.append('h');
    try rope.append('i');
    try rope.append('j');
    try rope.append('k');
    try rope.append('l');
    try rope.append('m');
    try rope.append('n');
    try rope.append('o');
    try rope.append('p');
    try rope.append('q');
    try rope.append('r');
    try rope.append('s');
    try rope.append('t');
    try rope.append('u');
    try rope.append('v');
    try rope.append('w');
    try rope.append('x');
    try rope.append('y');
    try rope.append('z');


    try rope.append('1');
    try rope.append('2');
    try rope.append('3');
    try rope.append('4');
    try rope.append('5');
    try rope.append('6');
    try rope.append('7');
    try rope.append('8');
    try rope.append('9');
    try rope.append('0');

    var h: u8 = rope.height;
    while(h > 0) : (h -= 1) {
        var l: u8 = h-1;
        std.debug.print("L{}: ", .{l});
        // print all elements in this level

        var tmp: ?*Node = rope.head;
        while(tmp) |node| : (tmp = node.next[l]) {
            std.debug.print("{c}", .{node.val});
            if(node.next[l] != rope.tail)
                std.debug.print(", ", .{});
        }


        std.debug.print("\n", .{});
    }
}
