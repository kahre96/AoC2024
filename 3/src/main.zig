const std = @import("std");
const data = @embedFile("data.txt");
pub fn main() !void {
    var i: usize = 0;
    var sum: i32 = 0;
    var do: bool = true;
    while (i < data.len) : (i += 1) {
        var u = i;
        var firstnum: i32 = 0;
        var secondnum: i32 = 0;
        // std.debug.print("i : {}  value: {c}", .{ i, data[i] });

        if (docheck(&i)) {
            do = true;
        }

        if (dontcheck(&i)) {
            do = false;
        }
        // std.debug.print("  i : {}  value: {c}\n", .{ i, data[i] });
        if (data[u] != 'm') {
            continue;
        }
        u += 1;
        if (data[u] != 'u') {
            continue;
        }
        u += 1;
        if (data[u] != 'l') {
            continue;
        }
        u += 1;
        if (data[u] != '(') {
            continue;
        }
        u += 1;

        while (std.ascii.isDigit(data[u])) {
            // std.debug.print("while: {}\n", .{data[u] - '0'});
            firstnum = firstnum * 10 + (data[u] - '0');
            u += 1;
        }

        if (data[u] != ',') {
            continue;
        }
        u += 1;
        while (std.ascii.isDigit(data[u])) {
            secondnum = secondnum * 10 + (data[u] - '0');
            u += 1;
        }

        if (data[u] != ')') {
            continue;
        }

        // std.debug.print("firstnum: {}\n", .{firstnum});
        // std.debug.print("secondnum: {}\n", .{secondnum});
        if (do) {
            sum += firstnum * secondnum;
        }
    }

    std.debug.print("Sum : {}", .{sum});
}

pub fn docheck(i: *usize) bool {
    var j = i.*;

    if (data[j] != 'd') {
        return false;
    }
    j += 1;
    if (data[j] != 'o') {
        return false;
    }
    j += 1;
    if (data[j] != '(') {
        return false;
    }
    j += 1;
    if (data[j] != ')') {
        return false;
    }
    i.* += 3;
    return true;
}

pub fn dontcheck(i: *usize) bool {
    var j = i.*;

    if (data[j] != 'd') {
        return false;
    }
    j += 1;
    if (data[j] != 'o') {
        return false;
    }
    j += 1;
    if (data[j] != 'n') {
        return false;
    }
    j += 1;
    if (data[j] != '\'') {
        return false;
    }
    j += 1;
    if (data[j] != 't') {
        return false;
    }
    j += 1;
    if (data[j] != '(') {
        return false;
    }
    j += 1;
    if (data[j] != ')') {
        return false;
    }
    i.* += 6;
    return true;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
