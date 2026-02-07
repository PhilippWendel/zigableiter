const std = @import("std");
const zigableiter = @import("zigableiter");

const Ast = zigableiter.Ast(f32);

pub fn main() !void {
    std.debug.print("Simple zigableiter demo\n", .{});

    const function = Ast{ .add = &.{ .l = Ast{ .variable = 1.0 }, .r = Ast{ .variable = 4.0 } } };
    std.debug.print("Num: {d}\n", .{comptime function.eval().?});

    const base = 2;
    std.debug.print("Derive {d}^n for n = 0 to 10\n", .{base});
    inline for (0..10) |i| {
        const exp = @as(f32, @floatFromInt(i));
        const pow = Ast{ .pow = &.{ .l = .{ .constant = base }, .r = .{ .constant = exp } } };
        const pow_d = comptime pow.derive().?;
        std.debug.print("{d}: {d}^{d}={d}; Auto Derived: {d}; Hand Derived: {d}\n", .{ i, pow.pow.l.constant, pow.pow.r.constant, pow.eval().?, pow_d.eval().?, exp * std.math.pow(f32, base, exp - 1) });
        pow_d.print();
    }
    // std.debug.print("Derive {d}^n for n = -10 to 0\n", .{base});
    // inline for (0..10) |i| {
    //     const pow = Ast{ .pow = &.{ .l = .{ .constant = base }, .r = .{ .constant = (-1) * @as(f32, @floatFromInt(i)) } } };
    //     const pow_d = comptime pow.derive().?;
    //     std.debug.print("{d}: {d}^{d}= {d}\n", .{ i, pow.pow.l.constant, pow.pow.r.constant, pow_d.eval().? });
    // }
}
