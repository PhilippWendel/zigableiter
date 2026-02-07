const std = @import("std");
const zigableiter = @import("zigableiter");

const Ast = zigableiter.Ast(f32);

pub fn main() !void {
    std.debug.print("Simple zigableiter demo\n", .{});

    const lr = Ast.LR{ .l = Ast{ .val = 1.0 }, .r = Ast{ .val = 4.0 } };
    std.debug.print("Num: {d}\n", .{comptime (Ast{ .add = &lr }).eval().?});
}
