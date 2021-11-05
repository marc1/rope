const std = @import("std");
const Allocator = std.mem.Allocator;

const max_height = 60;



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
    rng: std.rand.Random,

    pub fn init(alc: *Allocator) !Self {
        var head = try Node.init_ptr(alc, 2); //stx
        var tail = try Node.init_ptr(alc, 3); //etx

        head.next[0] = tail;
        tail.prev[0] = head;

        var rng = std.rand.Xoroshiro128.init(@bitCast(u64, std.time.milliTimestamp()));

        return Self {
            .alc = alc,
            .head = head,
            .tail = tail,
            .height = 1,
            .rng = rng.random(),
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

// bad but good enough
pub fn random_height(self: Self) u8 {
    var promote = self.rng.boolean();

    var height: u8 = 1;
    while ((height < (max_height - 1)) and promote) : (promote = self.rng.boolean()) {
        height += 1;
    }

    return height;
}

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

        // Now, insert to higher levels if needed.
        // 1 <= height <= max_height
        var height = self.random_height();

        if (height != 1) {
            // we need to make new levels
            if(self.height < height) {
                // say self.height = 1 and height=3
                // so level 0 is inited, but levels 1,2 are not.
                // self.height - height = 2, so up to level 2
                var tmph: u8 = height;
                while (tmph > self.height) : (tmph -= 1) {
                    self.head.next[tmph-1] = self.tail;
                    self.tail.prev[tmph-1] = self.head;
                }
                self.height = height;
            }

            var h: u8 = 2;
            // a height of 1 corresponds to next[0]
            while(h <= height) : (h += 1) {
                last = self.tail.prev[h-1].?;
                last.next[h-1] = node;
                self.tail.prev[h-1] = node;
                node.next[h-1] = self.tail;
            }
        }
    }


    pub fn print(self: *Self) void {
        var tmp = self.head.next[0];
        while (tmp) |node| : (tmp = node.next[0]) {
            if(node == self.tail)
                continue;
            std.debug.print("{c}", .{node.val});
        }
    }
};
