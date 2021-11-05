const std = @import("std");
const Allocator = std.mem.Allocator;

const max_level: u8 = 9;

// Path between two nodes
const Link = struct {
    width: usize,
    node: *Node,
};

const Node = struct {
    const Self = @This();

    val: u8,

    level: u8, // Number of active levels in `next` and `prev`
    next: []?Link,
    prev: []?Link,

    fn init(alc: *Allocator, val: u8) !Self {
        var res: Self = undefined;

        res.val = val;

        res.level = 0;

        res.next = try alc.alloc(?Link, max_level);
        std.mem.set(?Link, res.next, null);
        res.prev = try alc.alloc(?Link, max_level);
        std.mem.set(?Link, res.prev, null);

        return res;
    }

    fn deinit(self: Self, alc: *Allocator) void {
        alc.free(self.next);
        alc.free(self.prev);
    }

    fn init_ptr(alc: *Allocator, val: u8) !*Self {
        var node = try alc.create(Self);
        node.* = try Self.init(alc, val);

        return node;
    }
};

pub const Rope = struct {
    const Self = @This();

    alc: *Allocator,
    rng: std.rand.Random,

    head: *Node,
    tail: *Node,

    level: u8, // Level of the tallest node

    pub fn init(alc: *Allocator, seed: u64) !Self {
        var res: Self = undefined;

        res.alc = alc;
        res.rng = std.rand.Xoroshiro128.init(seed).random();

        res.head = try Node.init_ptr(alc, 0);
        res.tail = try Node.init_ptr(alc, 0);

        return res;
    }

    pub fn deinit(self: *Self) void {
        var tmp = self.head.next[0];
        while (tmp) |link| {
            var next = link.node.next[0];
            link.node.deinit(self.alc);
            self.alc.destroy(link.node);
            tmp = next;
        }

        self.head.deinit(self.alc);
        self.alc.destroy(self.head);

        self.tail.deinit(self.alc);
        self.alc.destroy(self.tail);
    }
};
