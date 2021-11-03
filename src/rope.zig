const std = @import("std");
const Allocator = std.mem.Allocator;

const max_height = 10;

pub const Node = struct {
    const Self = @This();

    val: u8,
    next: []?*Node,
    prev: []?*Node,

    pub fn init(alc: *Allocator, val: u8) !Self {
        var next = try alc.alloc(?*Node, max_height);
        var prev = try alc.alloc(?*Node, max_height);
        std.mem.set(?*Node, next, null);
        std.mem.set(?*Node, prev, null);

        return Self {
            .val = val,
            .next = next,
            .prev= prev,
        };
    }

    pub fn init_ptr(alc: *Allocator, val: u8) !*Self {
        var node = try alc.create(Self);
        node.* = try Self.init(alc, val);
        return node;
    }

    pub fn deinit(self: *Self, alc: *Allocator) void {
        alc.free(self.next);
        alc.free(self.prev);
    }
};

pub const Rope = struct {
    const Self = @This();

    alc: *Allocator,
    head: *Node,
    tail: *Node,
    height: u8,

    pub fn init(alc: *Allocator) !Self {
        var head = try Node.init_ptr(alc, 2); //stx
        var tail = try Node.init_ptr(alc, 3); //etx

        head.next[0] = tail;
        tail.prev[0] = head;

        return Self {
            .alc = alc,
            .head = head,
            .tail = tail,
            .height = 1,
        };
    }

    pub fn deinit(self: Self) void {
        var tmp = @as(?*Node, self.head);
        while (tmp) |node| {
            var next = node.next[0];
            node.deinit(self.alc);
            self.alc.destroy(node);
            tmp = next;
        }
    }

    // append
    pub fn append(self: *Self, val: u8) !void {
        var node = try Node.init_ptr(self.alc, val);

        // ptr to last non-tail elem
        // we know the `next` of this is just the tail,
        // so no need to store. will be important for
        // insertion in middle of seq.
        var last = self.tail.prev[0].?; //safe unwrap

        last.next[0] = node;
        self.tail.prev[0] = node;
        node.next[0] = self.tail;
    }

    pub fn print(self: *Self) void {
        var tmp = &self.head.next[0];
        while (tmp.*) |node| : (tmp = &node.next[0]) {
            if(node == self.tail)
                continue;
            std.debug.print("{c}", .{node.val});
        }
    }
};
