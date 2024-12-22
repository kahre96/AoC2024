const std = @import("std");
const data = @embedFile("data.txt");
const matrixSize: usize = 140;

pub fn main() !void {
    var matrix: [matrixSize][matrixSize]u8 = undefined;

    var i: usize = 0;
    for (data) |value| {
        if (!std.ascii.isAlphabetic(value)) {
            continue;
        }
        const col = i % matrixSize;
        const row = i / matrixSize;
        // std.debug.print("row : {}", .{row});
        // std.debug.print("col : {}", .{col});
        // std.debug.print("value : {c}\n", .{value});
        matrix[row][col] = value;
        i += 1;
    }
    var xmasCounter: i32 = 0;
    var masMasCounter: i32 = 0;
    for (matrix, 0..) |row, row_index| {
        for (row, 0..) |_, column_index| {
            if (matrix[row_index][column_index] == 'X') {
                // std.debug.print("row : {}", .{row_index});
                // std.debug.print("col : {}\n", .{column_index});
                xmasCounter += xmasChecker(matrix, row_index, column_index);
            }
            if (matrix[row_index][column_index] == 'M') {
                masMasCounter += masmasChecker(matrix, row_index, column_index);
            }
        }
        // std.debug.print("Row {d}: {s}\n", .{ row_index, row });
    }
    std.debug.print("Xmases: {}", .{xmasCounter});
    std.debug.print("MasMases: {}", .{masMasCounter});
}

fn masmasChecker(matrix: [matrixSize][matrixSize]u8, row_index: usize, column_index: usize) i32 {
    var xmasCounter: i32 = 0;
    if (column_index < matrixSize - 2 and matrix[row_index][column_index + 2] == 'M') {
        if (row_index < matrixSize - 2) {
            xmasCounter += masmascheckup(matrix, row_index, column_index, 1);
        }
        if (row_index > 1) {
            xmasCounter += masmascheckup(matrix, row_index, column_index, -1);
        }
    }

    if (row_index < matrixSize - 2 and matrix[row_index + 2][column_index] == 'M') {
        if (column_index < matrixSize - 2) {
            xmasCounter += masmascheckdown(matrix, row_index, column_index, 1);
        }
        if (column_index > 1) {
            xmasCounter += masmascheckdown(matrix, row_index, column_index, -1);
        }
    }
    return xmasCounter;
}

fn masmascheckup(matrix: [matrixSize][matrixSize]u8, rowindex: usize, columnindex: usize, direction: i32) i32 {
    const introw: i64 = @bitCast(rowindex);
    const row: usize = @bitCast(introw + direction);

    if (matrix[row][columnindex + 1] != 'A') {
        return 0;
    }
    const targetrow: usize = @bitCast(introw + 2 * direction);
    if (matrix[targetrow][columnindex] == 'S' and matrix[targetrow][columnindex + 2] == 'S') {
        return 1;
    }
    return 0;
}
fn masmascheckdown(matrix: [matrixSize][matrixSize]u8, rowindex: usize, columnindex: usize, direction: i32) i32 {
    const intcolumn: i64 = @bitCast(columnindex);
    const column: usize = @bitCast(intcolumn + direction);

    if (matrix[rowindex + 1][column] != 'A') {
        return 0;
    }
    const targetColumn: usize = @bitCast(intcolumn + 2 * direction);
    if (matrix[rowindex][targetColumn] == 'S' and matrix[rowindex + 2][targetColumn] == 'S') {
        return 1;
    }
    return 0;
}
fn xmasChecker(matrix: [matrixSize][matrixSize]u8, row_index: usize, column_index: usize) i32 {
    var xmasCounter: i32 = 0;

    if (column_index < matrixSize - 3) {
        xmasCounter += xmasCheck(matrix, [3]usize{ row_index, row_index, row_index }, [3]usize{ column_index + 1, column_index + 2, column_index + 3 });
    }
    if (column_index > 2) {
        xmasCounter += xmasCheck(
            matrix,
            [3]usize{ row_index, row_index, row_index },
            [3]usize{ column_index - 1, column_index - 2, column_index - 3 },
        );
    }
    if (row_index < matrixSize - 3) {
        xmasCounter += xmasCheck(matrix, [3]usize{ row_index + 1, row_index + 2, row_index + 3 }, [3]usize{ column_index, column_index, column_index });
    }
    if (row_index > 2) {
        xmasCounter += xmasCheck(matrix, [3]usize{ row_index - 1, row_index - 2, row_index - 3 }, [3]usize{ column_index, column_index, column_index });
    }

    //Diagonal
    if (column_index < matrixSize - 3 and row_index < matrixSize - 3) {
        xmasCounter += xmasCheck(matrix, [3]usize{ row_index + 1, row_index + 2, row_index + 3 }, [3]usize{ column_index + 1, column_index + 2, column_index + 3 });
    }
    if (column_index < matrixSize - 3 and row_index > 2) {
        xmasCounter += xmasCheck(matrix, [3]usize{ row_index - 1, row_index - 2, row_index - 3 }, [3]usize{ column_index + 1, column_index + 2, column_index + 3 });
    }
    if (column_index > 2 and row_index < matrixSize - 3) {
        xmasCounter += xmasCheck(matrix, [3]usize{ row_index + 1, row_index + 2, row_index + 3 }, [3]usize{ column_index - 1, column_index - 2, column_index - 3 });
    }
    if (column_index > 2 and row_index > 2) {
        xmasCounter += xmasCheck(matrix, [3]usize{ row_index - 1, row_index - 2, row_index - 3 }, [3]usize{ column_index - 1, column_index - 2, column_index - 3 });
    }

    return xmasCounter;
}

fn xmasCheck(matrix: [matrixSize][matrixSize]u8, rownumbers: [3]usize, columnnumbers: [3]usize) i32 {
    const letters = [3]u8{ 'M', 'A', 'S' };

    if (matrix[rownumbers[0]][columnnumbers[0]] != letters[0]) {
        return 0;
    }
    if (matrix[rownumbers[1]][columnnumbers[1]] != letters[1]) {
        return 0;
    }
    if (matrix[rownumbers[2]][columnnumbers[2]] != letters[2]) {
        return 0;
    }
    return 1;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
