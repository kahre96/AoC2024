const std = @import("std");
const print = @import("std").debug.print;
const data = @embedFile("data.txt");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var first_list = std.ArrayList(i32).init(allocator);
    var second_list = std.ArrayList(i32).init(allocator);

    defer first_list.deinit();
    defer second_list.deinit();

    var isfirst: bool = true;
    var current_number: i32 = 0;

    for (data) |char| {
        // print("char: {}\n", .{char});
        if (std.ascii.isDigit(char)) {
            current_number = current_number * 10 + char - '0';
        } else if (char == ' ' or char == '\n') {
            // print("current_number: {}\n", .{current_number});
            if (isfirst) {
                try first_list.append(current_number);
            } else {
                try second_list.append(current_number);
            }

            current_number = 0;
            isfirst = !isfirst;
        }
    }

    std.mem.sort(i32, first_list.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, second_list.items, {}, std.sort.asc(i32));

    // print("First arryay: {}\n", .{first_list});
    // print("Second arryay: {}\n", .{second_list});

    var sum: i32 = 0;

    for (first_list.items, 0..) |value, i| {
        sum += @max(value, second_list.items[i]) - @min(value, second_list.items[i]);
    }

    var similarity_score: i32 = 0;

    for (first_list.items) |value| {
        var hits: i32 = 0;
        for (second_list.items) |secondvalue| {
            if (value == secondvalue) {
                hits += 1;
            }
        }
        // print("value: {}\n", .{value});
        // print("hits: {}\n", .{hits});
        similarity_score += value * hits;
    }
    print("sum: {}\n", .{sum});
    print("sim score: {}\n", .{similarity_score});
}

test "simple test" {
    var list = std.arraylist(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectequal(@as(i32, 42), list.pop());
}
