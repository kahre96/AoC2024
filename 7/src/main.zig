const std = @import("std");
const data = @embedFile("data.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();

    var lines = std.mem.splitScalar(u8, data, '\n');

    var answer: i64 = 0;
    var total: i64 = 0;

    while (lines.next()) |line| {

        if(line.len == 0){
            continue;
        }

        var i : usize = 0;
        while(i < line.len){
            if (line[i] == ':') {
                i += 2;
                break;
            }
            answer = answer * 10 + line[i] - '0';
            i += 1;
        }

        var numbers = std.ArrayList(i64).init(ally);
        var number : i64 = 0;
        while(i < line.len){
            if(std.ascii.isWhitespace(line[i])){
                try numbers.append(number);
                number = 0;
                i += 1;
                continue;
            }
            number = number * 10 + line[i] - '0';
            i += 1;
        }


        std.debug.print("number : {}  ::", .{answer});
        for (numbers.items) |value| {
            std.debug.print("{} ", .{value});
        }
        if (add(numbers.items[0], 1, &numbers, answer) or
            multiply(numbers.items[0], 1, &numbers, answer) or
                concan(numbers.items[0], 1, &numbers, answer)) {
           total += answer;
            std.debug.print("concated works!", .{});
        }


        std.debug.print("\n", .{});
        answer = 0;
    }

    std.debug.print("Totalt: {}", .{total});

}

fn add(currenttotal : i64,index : usize, list : *std.ArrayList(i64), answer : i64) bool{
    const total = currenttotal + list.items[index];

    if(index != list.items.len-1){
        return add(total, index+1, list, answer)  or
            multiply(total, index+1, list, answer) or
            concan(total, index+1, list, answer);
    } else {
        if(total == answer){
            return true;
        } else {
            return false;
        }
    }
}

fn multiply(currenttotal : i64,index : usize, list : *std.ArrayList(i64), answer : i64) bool{
    if (currenttotal > answer) {
        return false;
    }
    const total = currenttotal * list.items[index];

    if(index != list.items.len-1){
        return add(total, index+1, list, answer) or
            multiply(total, index+1, list, answer) or
            concan(total, index+1, list, answer);
    } else {
        if(total == answer){
            return true;
        } else {
            return false;
        }
    }
}

fn concan(currenttotal : i64,index : usize, list : *std.ArrayList(i64), answer : i64) bool{
    if (currenttotal > answer) {
        return false;
    }
    var buff : [64]u8 = undefined;
    const concateda = std.fmt.bufPrint(&buff, "{}", .{currenttotal}) catch unreachable;
    var buff2 : [64]u8 = undefined;
    const concatedb = std.fmt.bufPrint(&buff2, "{}", .{list.items[index]}) catch unreachable;

    const total_size = concateda.len + concatedb.len;
    var concated: [128]u8 = undefined;
    @memcpy(concated[0..concateda.len], concateda);
    @memcpy(concated[concateda.len..(concateda.len+concatedb.len)], concatedb);

    const total = std.fmt.parseInt(i64, concated[0..total_size], 10) catch unreachable;

    if(index != list.items.len-1){
        return add(total, index+1, list, answer)
            or multiply(total, index+1, list, answer)
            or concan(total, index+1, list, answer);
    } else {
        if(total == answer){
            return true;
        } else {
            return false;
        }
    }
}
