const std = @import("std");
const data = @embedFile("data.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();

    var map = std.AutoHashMap(i32, std.AutoHashMap(i32, i32)).init(ally);
    defer map.deinit();

    var lines = std.mem.splitScalar(u8, data, '\n');
    var numinfront: i32 = undefined;
    var numbehind: i32 = undefined;
    var totalSum : i32 = 0;
    var unsafetotalSum : i32 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        numinfront = (line[0] - '0') * 10 + line[1] - '0';
        numbehind = (line[3] - '0') * 10 + line[4] - '0';
        if (!map.contains(numinfront)) {
            var list = std.AutoHashMap(i32, i32).init(ally);
            errdefer list.deinit();

            try map.put(numinfront, list);
        }
        try appendToList(&map, numinfront, numbehind);
    }

    // var it = map.iterator();
    // while (it.next()) |entry| {
    //     std.debug.print("Key: {}\n", .{entry.key_ptr.*});
    //     std.debug.print("Values: ", .{});
    //     var valit = entry.value_ptr.*.iterator();
    //     while (valit.next()) |value| {
    //         std.debug.print(" {} ", .{value.key_ptr.*});
    //     }
    //     std.debug.print("\n", .{});
    // }

    var pages = std.ArrayList(i32).init(ally);

    while (lines.next()) |line| {
        std.debug.print("line: {s} \n", .{line});
        var unsafe : bool = false;
        var number : i32 = 0;
        for (line) |value| {

            if(std.ascii.isDigit(value)) {
                number = number * 10 + value - '0';
            }
            if (value == ',') {
                try pages.append(number);
                if ( try numbercheck(number, &pages, &map)) {
                    unsafe = true;
                }
                number = 0;
            }
        }
        try pages.append(number);
        if (try numbercheck(number, &pages, &map)) {
            unsafe = true;
        }
        number = 0;
        if (!unsafe){
            const mid = pages.items[pages.items.len/2];
            totalSum += mid;
            //std.debug.print("safe line: {s} \n", .{line});
            //std.debug.print("safe mid: {d} \n", .{mid});
        }
        if(unsafe and pages.items.len != 0) {
            const mid = pages.items[pages.items.len/2];
            unsafetotalSum += mid;
            // std.debug.print("unsafe line: \n{s}\n", .{line});
            // for (pages.items) |page| {
            //     std.debug.print("{d} ", .{page});
            // }
            //
            // std.debug.print("\nunsafe mid: {d} \n", .{mid});
        }
        pages.clearAndFree();
    }
    std.debug.print("sum : {d} \n", .{totalSum});
    std.debug.print("unsafesum : {d} \n", .{unsafetotalSum});
}


fn numbercheck(number : i32, pages: *std.ArrayList(i32), map :  *std.AutoHashMap(i32, std.AutoHashMap(i32, i32))) !bool{
    if (map.get(number)) |numbersinstructions | {
       for (pages.items, 0..) |page, index| {
           if (numbersinstructions.contains(page)) {
               //std.debug.print("page: {} number: {} \n", .{page,number.*});
               pages.items[pages.items.len-1] = page;
               pages.items[index] = number;
               _ = try numbercheck(page, pages, map);
               return true;
           }
       }
    }
    return false;
}

fn appendToList(map: *std.AutoHashMap(i32, std.AutoHashMap(i32, i32)), key: i32, value: i32) !void {
    if (map.getPtr(key)) |valuemap| {
        try valuemap.put(value, 0);
    } else {
        return error.KeyNotFound;
    }
}
