const std = @import("std");
const data = @embedFile("testdata.txt");

pub fn main() !void {
    // var base_alloc = std.heap.GeneralPurposeAllocator(.{}){};
    // defer base_alloc.deinit();
    // const ally = base_alloc.allocator();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var map = std.AutoHashMap(i32, []i32).init(arena.allocator());
    defer map.deinit();

    var lines = std.mem.splitScalar(u8, data, '\n');
    var numinfront: i32 = undefined;
    var numbehind: i32 = undefined;

    while (lines.next()) |line| {
        if (!std.ascii.isDigit(line[0])) {
            std.debug.print("this should run!", .{});
            break;
        }
        numinfront = (line[0] - '0') * 10 + line[1] - '0';
        numbehind = (line[3] - '0') * 10 + line[4] - '0';
        std.debug.print("numonfrint: {} \n", .{numinfront});
        map.put(numbehind, numinfront);
    }
}
