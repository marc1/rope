const std = @import("std");
const Allocator = std.mem.Allocator;

const max_level: u8 = 20;

const Link = struct {
    to: *Node,
    width: u8,
};

const Node = struct {
    val: u8,

    level: u8,
    next: []?Link,
    prev: []?Link,

    fn init(alc: *Allocator, val: u8) !Node {
        var next = try alc.alloc(?Link, max_level);
        std.mem.set(?Link, next, null);

        var prev = try alc.alloc(?Link, max_level);
        std.mem.set(?Link, prev, null);

        return Node{
            .val = val,
            .level = 0,
            .next = next,
            .prev= prev,
        };
    }

    fn init_ptr(alc: *Allocator, val: u8) Allocator.Error!*Node {
        var n = try alc.create(Node);
        n.* = try Node.init(alc, val);

        return n;
    }

    fn deinit(self: *Node, alc: *Allocator) void {
        alc.free(self.next);
        alc.free(self.prev);
    }
};

pub const Rope = struct {
    alc: *Allocator,
    rand: std.rand.Random,

    head: *Node,
    tail: *Node,

    pub fn init(alc: *Allocator, rand: std.rand.Random) Allocator.Error!Rope {
        var head = try Node.init_ptr(alc, 0);
        var tail = try Node.init_ptr(alc, 0);

        head.next[0] = Link{ .to = tail, .width = 1 };
        tail.prev[0] = Link{ .to = head, .width = 1 };

        return Rope{
            .alc = alc,
            .rand = rand,
            .head = head,
            .tail = tail,
        };
    }

    pub fn deinit(self: *Rope) void {
        var next_opt = self.head.next[0];
        while (next_opt) |next| {
            next_opt = next.to.next[0];
            next.to.deinit(self.alc);
            self.alc.destroy(next.to);
        }

        self.head.deinit(self.alc);
        self.alc.destroy(self.head);
    }

    pub fn print(self: Rope) void {
        // This is how you traverse including the head
        // But you should never need to
        //var next_opt: ?Link = Link{ .to = self.head, .width = 0 };
        
        var next_opt = self.head.next[0];
        while (next_opt) |next| : (next_opt = next.to.next[0]) {
            std.debug.print("{c}", .{next.to.val});
            if (next.to.next[0]) |next_next| {
                if (next_next.to == self.tail)
                    break;

                std.debug.print(" -> ", .{});
            }
        }
        std.debug.print("\n", .{});
    }

    fn random_level(self: Rope) void {
        var flip = self.rand.boolean();

        var level: u8 = 0;
        while (flip and level < max_level) : (flip = self.rand.boolean())
            level += 1;

        return level;
    }

    pub fn prepend_to(self: *Rope, before: *Node, val: u8) !?*Node {
        if (before.prev[0]) |prev| {
            return try self.append_to(prev.to, val);
        }

        return null;
    }

    pub fn prepend(self: *Rope, val: u8) !?*Node {
        return try self.append_to(self.head, val);
    }

    pub fn append_to(self: *Rope, after: *Node, val: u8) !?*Node {
        if (after.next[0]) |next| {
            var n = try Node.init_ptr(self.alc, val);

            n.prev[0] = Link{ .to = after, .width = 1 };
            n.next[0] = Link{ .to = next.to, .width = 1 };

            after.next[0] = Link{ .to = n, .width = 1};

            next.to.prev[0] = Link{ .to = n, .width = 1};

            return n;
        }

        return null;
    }

    pub fn append(self: *Rope, val: u8) !?*Node {
        return try self.prepend_to(self.tail, val);
    }

};
