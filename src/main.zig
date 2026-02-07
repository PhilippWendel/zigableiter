const std = @import("std");
const zigableiter = @import("zigableiter");

const Ast = zigableiter.Ast(f32);

pub fn main() !void {
    std.debug.print("Simple zigableiter demo\n", .{});

    const function = Ast{ .add = &.{ .l = Ast{ .variable = 1.0 }, .r = Ast{ .variable = 4.0 } } };
    std.debug.print("Num: {d}\n", .{comptime function.eval().?});

    std.debug.print("Derive 1^n for n = 0 to 10\n", .{});
    inline for (0..10) |i| {
        const pow = Ast{ .pow = &.{ .l = .{ .variable = 1 }, .r = .{ .variable = @as(f32, @floatFromInt(i)) } } };
        const pow_d = comptime pow.derive().?;
        std.debug.print("{d}: {d}^{d}= {d}\n", .{ i, pow.pow.l.variable, pow.pow.r.variable, pow_d.eval().? });
    }
    std.debug.print("Derive 1^n for n = -10 to 0\n", .{});
    inline for (0..10) |i| {
        const pow = Ast{ .pow = &.{ .l = .{ .variable = 1 }, .r = .{ .variable = (-1) * @as(f32, @floatFromInt(i)) } } };
        const pow_d = comptime pow.derive().?;
        std.debug.print("{d}: {d}^{d}= {d}\n", .{ i, pow.pow.l.variable, pow.pow.r.variable, pow_d.eval().? });
    }
}
