const std = @import("std");
const data = @embedFile("data.txt");

pub fn main() !void {

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();
    
    
    var matris = std.ArrayList(std.ArrayList(u8)).init(ally);
    defer matris.deinit();

    var lines = std.mem.splitScalar(u8, data, '\n');

    while (lines.next()) |line| {
        var list = std.ArrayList(u8).init(ally);
        for (line) |char| {
            try list.append(char);
        }
        try matris.append(list);
    }

    var antenner = std.AutoHashMap(u8, std.ArrayList([2]usize)).init(ally);
    defer antenner.deinit();

    for (matris.items, 0..) |lists, rowi| {
        for (lists.items, 0..) |value, coli| {
            if(value != '.') {
                const cords  = [2]usize{rowi,coli};

                const cordlist = try antenner.getOrPut(value);

                if(cordlist.found_existing) {
                    try cordlist.value_ptr.*.append(cords);
                } else {
                    var newcordlist = std.ArrayList([2]usize).init(ally);
                    try newcordlist.append(cords);
                    try antenner.put(value, newcordlist);
                }


            }
        }
    }
    // var antenit = antenner.iterator();
    // while (antenit.next()) |anten| {
    //     std.debug.print("{c} : ", .{anten.key_ptr.*});
    //     for (anten.value_ptr.items) |value| {
    //         std.debug.print("[{} {}]", .{value[0], value[1]});
    //     }
    //     std.debug.print("\n", .{});
    // }

    var cordset = std.AutoHashMap([2]usize, void).init(ally);
    defer cordset.deinit();

    var antenit2 = antenner.iterator();
    while (antenit2.next()) |anten| {

        for (anten.value_ptr.items, 0..) |currentcord, cordsi| {
            for(anten.value_ptr.items, 0..) |othercords, cordsj| {
                if(cordsi == cordsj){
                    continue;
                }

                const intcurrow : i64 = @bitCast(currentcord[0]);
                const intcurcol : i64= @bitCast(currentcord[1]);
                const intotherrow : i64= @bitCast(othercords[0]);
                const intothercol : i64= @bitCast(othercords[1]);

                const distancerow : i64 = intotherrow - intcurrow;
                const distancecol : i64 = intothercol - intcurcol;


                var antirow = intotherrow;
                var anticol = intothercol;

                while (true) {
                    antirow = antirow - distancerow;
                    anticol = anticol - distancecol;
                    if (anticol > matris.items.len-1 or
                        antirow > matris.items.len-1 or
                        antirow < 0 or anticol < 0 ) {
                        break;
                    }
                    try cordset.put([2]usize{@bitCast(antirow),@bitCast(anticol)}, {});
                }



            }
        }
    }

    std.debug.print("Antinodes: {}\n", .{cordset.count()});
    // var cordsit = cordset.iterator();
    // std.debug.print("\n", .{});
    // while (cordsit.next()) |entry| {
    //     std.debug.print("[{} {}] ", .{entry.key_ptr.*[0], entry.key_ptr.*[1]});
    // }

    for (matris.items, 0..) |lists, rowi| {
        for (lists.items, 0..) |value, coli| {
            if (cordset.contains([2]usize{rowi,coli})) {
                std.debug.print("# ", .{});
            } else {
                std.debug.print("{c} ", .{value});
            }
        }
        std.debug.print("\n", .{});
    }
}


