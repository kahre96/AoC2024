const std = @import("std");
const data = @embedFile("data.txt");
pub var steg : i32 = 0;
pub var fastnat: i32 = 0;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();
    
    var guardroom = std.ArrayList(std.ArrayList(u8)).init(ally);
    defer guardroom.deinit();

    var platser = std.AutoHashMap([2]usize, void).init(ally);
    defer platser.deinit();

    var lines = std.mem.splitScalar(u8, data, '\n');

    while (lines.next()) |line| {
        var list = std.ArrayList(u8).init(ally);
        for (line) |char| {
            try list.append(char);
        }
        try guardroom.append(list);
    }

    // for (guardroom.items) |lists| {
    //     for (lists.items) |value| {
    //         std.debug.print(" {c} ", .{value});
    //     }
    //     std.debug.print("\n", .{});
    // }
    var startposition : [2]usize = [_]usize{0,0};
    for (guardroom.items, 0..) |lists, rowi| {
        for (lists.items, 0..) |value, coli| {
            if (value == '^') {
                startposition[0] = rowi;
                startposition[1] = coli;
                try walking(rowi, coli, Direction.Up, &guardroom, &platser);
            }
        }
    }

    for (guardroom.items, 0..) |lists, rowi| {
        for (lists.items, 0..) |value, coli| {
            if(rowi == startposition[0] and coli == startposition[1]){
                continue;
            }
            if(value == '.'){
                guardroom.items[rowi].items[coli] = '#';
                try walking(startposition[0], startposition[1], Direction.Up, &guardroom, &platser);
                steg = 0;
                guardroom.items[rowi].items[coli] = '.';
            }



        }
    }
    std.debug.print("fastnat: {} \n", .{fastnat});
    //std.debug.print("startposition: {d}", .{startposition});
}

fn walking(currentrow : usize, currentcol : usize, direction : Direction, guardroom : *std.ArrayList(std.ArrayList(u8)), platser : *std.AutoHashMap([2]usize, void)) !void {
    const pos: [2]usize = .{ currentrow, currentcol };
    try platser.put(pos, {});
    if(steg > 20000){
        fastnat += 1;
        return;
    }
    steg += 1;
    const introw  : i64 = @bitCast(currentrow);
    const newrow : usize = @bitCast(introw + direction.getCords()[0]);
    const intcol  : i64 = @bitCast(currentcol);
    const newcol : usize = @bitCast(intcol + direction.getCords()[1]);

    if(newrow > guardroom.items.len-1 or newrow < 0 or newcol > guardroom.items[0].items.len-1 or newcol < 0 ){
        //std.debug.print("ute! antal platser: {}\n", .{platser.count()});
    } else if (guardroom.items[newrow].items[newcol] == '#') {
        //std.debug.print("a wall at: {} {}\n", .{newrow, newcol});
        try walking(currentrow, currentcol, rotateClockwise(direction), guardroom, platser);

    } else {
        try walking(newrow, newcol, direction, guardroom, platser);
    }
}

const Direction = enum {
    Up,
    Right,
    Down ,
    Left ,

    pub fn getCords(self : Direction) [2]i32{
        return switch (self) {
            .Up => [2]i32{-1,0},
            .Right => [2]i32{0,1},
            .Down => [2]i32{1,0},
            .Left => [2]i32{0,-1},
        };
    }
};

fn rotateClockwise(direction : Direction) Direction{
    return switch (direction) {
        .Down => .Left,
        .Left => .Up,
        .Up => .Right,
        .Right => .Down,
    };
}






