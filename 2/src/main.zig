const std = @import("std");
const print = @import("std").debug.print;
const data = @embedFile("testdata.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    var numberlist = std.ArrayList(i32).init(allocator);

    var safecounter: i32 = 0;

    var currentNumber: i32 = 0;

    for (data) |char| {
        if (std.ascii.isDigit(char)) {
            // print("Current charisdigit: {}\n", .{(char - '0')});
            currentNumber = currentNumber * 10 + (char - '0');
        }

        if (char == ' ' or char == '\n') {
            // print("Current num: {}\n", .{currentNumber});
            try numberlist.append(currentNumber);
            currentNumber = 0;
        }

        if (char == '\n') {
            const lists = try createListsWithRemovedValues(allocator, numberlist);
            std.debug.print("testing", .{});
            var tempsafe: i32 = 0;
            for (lists, 0..) |list, i| {
                std.debug.print("List {}: ", .{i});
                for (list.items) |value| {
                    std.debug.print("{} ", .{value});
                }
                std.debug.print("\n", .{});
            }
            for (lists) |list| {
                tempsafe += evallist(list);
            }
            if (tempsafe > 0) {
                safecounter += 1;
            }
            numberlist.clearAndFree();
        }
    }

    print("Safecount: {}", .{safecounter});
}

pub fn evallist(numberlist: std.ArrayList(i32)) i32 {
    for (numberlist.items) |value| {
        std.debug.print(" {} ", .{value});
    }
    if (numberlist.items.len < 2) {
        return 1;
    }

    if (numberlist.items[0] == numberlist.items[1]) {
        return 0;
    }

    if (numberlist.items[0] > numberlist.items[1]) {
        // std.debug.print("desc\n", .{});
        for (numberlist.items[1..], 1..) |value, i| {
            if (value > numberlist.items[i - 1]) {
                std.debug.print("value to big {}\n", .{value});
                return 0;
            }

            if (numberlist.items[i - 1] - value > 3) {
                std.debug.print("dif to big {}\n", .{value});
                return 0;
            }

            if (numberlist.items[i - 1] - value < 1) {
                std.debug.print("dif to small {}\n", .{value});
                return 0;
            }
        }
    }

    if (numberlist.items[0] < numberlist.items[1]) {
        // std.debug.print("asc\n", .{});
        for (numberlist.items[1..], 1..) |value, i| {
            if (value < numberlist.items[i - 1]) {
                std.debug.print("value to small {}\n", .{value});
                return 0;
            }

            if (value - numberlist.items[i - 1] > 3) {
                std.debug.print("diff to big {}\n", .{value});
                return 0;
            }

            if (value - numberlist.items[i - 1] < 1) {
                std.debug.print("diff to small {}\n", .{value});
                return 0;
            }
        }
    }
    std.debug.print("\n", .{});
    return 1;
}

pub fn createListsWithRemovedValues(
    allocator: std.mem.Allocator,
    numberlist: std.ArrayList(i32),
) ![]std.ArrayList(i32) {
    for (numberlist.items) |value| {
        std.debug.print(" {} ", .{value});
    }

    var result = try allocator.alloc(std.ArrayList(i32), numberlist.items.len);
    defer allocator.free(result);

    for (numberlist.items, 0..) |_, index| {
        var new_list = std.ArrayList(i32).init(allocator);

        for (numberlist.items, 0..) |value, i| {
            if (i != index) {
                try new_list.append(value);
            }
        }
        for (new_list.items) |value| {
            std.debug.print("new list value: {} \n", .{value});
        }
        result[index] = new_list;
        new_list.clearAndFree();
    }
    std.debug.print("list done: \n", .{});
    return result;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
