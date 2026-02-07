const std = @import("std");

pub fn Ast(T: type) type {
    return union(enum) {
        const Self = @This();
        pub const LR = struct { l: Self, r: Self };
        add: *const LR,
        sub: *const LR,
        mul: *const LR,
        div: *const LR,
        pow: *const LR,
        sin: *const Self,
        cos: *const Self,
        variable: T,
        constant: T,

        fn apply(f: fn (T, T) T, node: LR) ?T {
            const l = node.l.eval() orelse return null;
            const r = node.r.eval() orelse return null;
            return f(l, r);
        }

        pub fn derive(ast: Self) ?Self {
            return switch (ast) {
                .constant => null,
                .variable => .{ .constant = 1 },
                .pow => |lr| .{
                    .mul = &.{
                        .l = lr.r,
                        .r = .{
                            .pow = &.{
                                .l = lr.l,
                                .r = .{
                                    .sub = &.{
                                        .l = lr.r,
                                        .r = .{ .constant = 1 },
                                    },
                                },
                            },
                        },
                    },
                },
                .sin => |x| .{ .cos = x },
                .cos => |x| .{ .mul = &.{ .l = .{ .constant = (-1) }, .r = .{ .sin = x } } },
                else => ast,
            };
        }
        pub fn eval(ast: Self) ?T {
            return switch (ast) {
                .add => |node| apply(fun.add, node.*),
                .sub => |node| apply(fun.sub, node.*),
                .mul => |node| apply(fun.mul, node.*),
                .div => |node| apply(fun.div, node.*),
                .pow => |node| apply(fun.pow, node.*),
                .sin => |x| std.math.sin(x.eval() orelse return null),
                .cos => |x| std.math.cos(x.eval() orelse return null),
                .constant => |constant| constant,
                .variable => |value| value,
            };
        }

        const fun = struct {
            pub fn add(a: T, b: T) T {
                return a + b;
            }
            pub fn sub(a: T, b: T) T {
                return a - b;
            }
            pub fn mul(a: T, b: T) T {
                return a * b;
            }
            pub fn div(a: T, b: T) T {
                return a / b;
            }
            pub fn pow(a: T, b: T) T {
                return std.math.pow(T, a, b);
            }
        };
    };
}

const TestAst = Ast(f32);

test "Derivation of a constant is 0" {
    const constant = TestAst{ .constant = 1.0 };
    try std.testing.expectEqual(constant.derive(), null);
}

test "Derivation of variable (e.g. x) is 1" {
    const variable = TestAst{ .variable = 1.0 };
    try std.testing.expectEqualDeep(variable.derive().?, TestAst{ .constant = 1.0 });
}

test "Power rule" {
    const pow = TestAst{ .pow = &.{ .l = .{ .variable = 1 }, .r = .{ .variable = 2 } } };
    const pow_d = comptime pow.derive().?;
    try std.testing.expectApproxEqAbs(pow_d.eval().?, 2.0, 0.00000001);
}

test "derive sin to cos" {
    const sin = TestAst{ .sin = &.{ .constant = 1 } };
    const cos = TestAst{ .cos = &.{ .constant = 1 } };
    try std.testing.expectApproxEqAbs(sin.derive().?.eval().?, cos.eval().?, 0.0000001);
}

test "derive cos to -sin" {
    const cos = TestAst{ .cos = &.{ .constant = 1 } };
    const cos_d = comptime cos.derive().?;
    const minus_sin = TestAst{ .mul = &.{
        .l = .{ .constant = -1 },
        .r = .{ .sin = &.{ .constant = 1 } },
    } };
    try std.testing.expectApproxEqAbs(cos_d.eval().?, minus_sin.eval().?, 0.0000001);
}
