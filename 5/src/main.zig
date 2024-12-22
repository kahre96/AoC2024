const std = @import("std");
const data = @embedFile("testdata.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();

    var map = std.AutoHashMap(i32, std.ArrayList(i32)).init(ally);
    defer map.deinit();

    var lines = std.mem.splitScalar(u8, data, '\n');
    var numinfront: i32 = undefined;
    var numbehind: i32 = undefined;

    while (lines.next()) |line| {
        if (!std.ascii.isDigit(line[0])) {
            break;
        }
        numinfront = (line[0] - '0') * 10 + line[1] - '0';
        numbehind = (line[3] - '0') * 10 + line[4] - '0';
        if (!map.contains(numinfront)) {
            var list = std.ArrayList(i32).init(ally);
            errdefer list.deinit();

            try map.put(numinfront, list);
        }
        try appendToList(&map, numinfront, numbehind);
    }

    var it = map.iterator();
    while (it.next()) |entry| {
        std.debug.print("Key: {}\n", .{entry.key_ptr.*});
        std.debug.print("Values: ", .{});
        for (entry.value_ptr.items) |val| {
            std.debug.print("{} ", .{val});
        }
        std.debug.print("\n", .{});
    }
}

fn appendToList(map: *std.AutoHashMap(i32, std.ArrayList(i32)), key: i32, value: i32) !void {
    if (map.getPtr(key)) |list_ptr| {
        try list_ptr.append(value);
    } else {
        return error.KeyNotFound;
    }
}
