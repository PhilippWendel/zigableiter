const std = @import("std");

pub fn Ast(T: type) type {
    return union(enum) {
        const Self = @This();
        pub fn Args(n: usize) type {
            return [n]*const Self;
        }

        add: Args(2),
        sub: Args(2),
        mul: Args(2),
        div: Args(2),
        pow: Args(2),
        sin: Args(1),
        cos: Args(1),
        val: T, // Variable, e.g. x
        num: T, // Constant, e.g 7.

        pub const @"1" = Self{ .num = 1 };
        pub const @"-1" = Self{ .num = -1 };

        fn apply1(f: fn (T) T, args: Args(1)) ?T {
            const l = args[0].eval() orelse return null;
            return f(l);
        }
        fn apply2(f: fn (T, T) T, args: Args(2)) ?T {
            const l = args[0].eval() orelse return null;
            const r = args[1].eval() orelse return null;
            return f(l, r);
        }

        pub fn derive(ast: Self) Self {
            return switch (ast) {
                .num => .{ .num = 0 },
                .val => Self.@"1",
                .pow => |args| derive_power_rule(args),
                .add => |args| derive_sum_rule(args),
                .sub => |args| derive_difference_rule(args),
                .mul => |args| derive_product_rule(args),
                .div => |args| derive_quotient_rule(args),
                .sin => |x| .{ .cos = x },
                .cos => |x| .{ .mul = .{ &Self.@"-1", &.{ .sin = x } } },
            };
        }

        /// (x^n)' = nx^(n-1)
        fn derive_power_rule(args: Args(2)) Self {
            return .{ .mul = .{
                args[1],
                &.{ .pow = .{
                    args[0],
                    &.{ .sub = .{ args[1], &Self.@"1" } },
                } },
            } };
        }
        fn derive_sum_rule(args: Args(2)) Self {
            return .{ .add = .{ &args[0].derive(), &args[0].derive() } };
        }

        /// (u-v)' = u'-v'
        fn derive_difference_rule(args: Args(2)) Self {
            return .{ .sub = .{ &args[0].derive(), &args[0].derive() } };
        }

        /// (u*v)' = u'*v+u*v'
        fn derive_product_rule(args: Args(2)) Self {
            return .{ .add = .{
                &.{ .mul = .{ &args[0].derive(), args[1] } },
                &.{ .mul = .{ args[0], &args[1].derive() } },
            } };
        }

        fn derive_quotient_rule(args: Args(2)) Self {
            const dividend = Self{ .sub = .{
                &.{ .mul = .{ args[1], &args[0].derive() } },
                &.{ .mul = .{ args[0], &args[1].derive() } },
            } };
            const divisor = Self{ .pow = .{ args[1], &.{ .num = 2 } } };
            return .{ .div = .{ &dividend, &divisor } };
        }
        // f(x) = g(h(x)) -> f'(x) = g'(h(x)) * h'(x)
        // fn derive_chain_rule(args: Args(2)) Self {
        //     return .{};
        // }

        pub fn eval(ast: Self) ?T {
            return switch (ast) {
                .add => |node| apply2(fun.add, node),
                .sub => |node| apply2(fun.sub, node),
                .mul => |node| apply2(fun.mul, node),
                .div => |node| apply2(fun.div, node),
                .pow => |node| apply2(fun.pow, node),
                .sin => |node| apply1(fun.sin, node),
                .cos => |node| apply1(fun.cos, node),
                .val, .num => |value| value,
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
            pub fn sin(a: T) T {
                return std.math.sin(a);
            }
            pub fn cos(a: T) T {
                return std.math.cos(a);
            }
        };
        pub fn print(self: Self) void {
            self.printIndented(0);
        }
        pub fn printIndented(self: Self, indent: usize) void {
            for (0..indent) |_| std.debug.print("  ", .{});
            const indent_new = indent + 1;
            switch (self) {
                .add, .sub, .mul, .div, .pow => |v| {
                    std.debug.print("{s}\n", .{@tagName(self)});
                    for (v) |s| s.printIndented(indent_new);
                },
                .sin, .cos => |v| {
                    std.debug.print("{s}\n", .{@tagName(self)});
                    for (v) |s| s.printIndented(indent_new);
                },
                .val, .num => |num| std.debug.print("{d}\n", .{num}),
            }
        }
    };
}

const TestAst = Ast(f32);

test "Derivation of a constant is 0" {
    const constant = TestAst.@"1";
    try std.testing.expectEqual(constant.derive(), TestAst{ .num = 0 });
}

test "Derivation of variable (e.g. x) is 1" {
    const variable = TestAst{ .val = 2.0 };
    try std.testing.expectEqualDeep(variable.derive(), TestAst.@"1");
}

test "Power rule" {
    const Data = struct { base: f32, exp: f32, derived: f32 };

    const data = [_]Data{
        .{ .base = 2, .exp = 0, .derived = 0 },
        .{ .base = 2, .exp = 1, .derived = 1 },
        .{ .base = 2, .exp = 2, .derived = 4 },
        .{ .base = 2, .exp = 3, .derived = 12 },
        .{ .base = 2, .exp = 4, .derived = 32 },
        .{ .base = 2, .exp = 5, .derived = 80 },
        .{ .base = 2, .exp = 6, .derived = 192 },
        .{ .base = 2, .exp = 7, .derived = 448 },
        .{ .base = 2, .exp = 8, .derived = 1024 },
        .{ .base = 2, .exp = 9, .derived = 2304 },
    };
    inline for (data) |d| {
        const exp = d.exp;
        const pow = TestAst{ .pow = .{ &.{ .val = d.base }, &.{ .val = exp } } };
        const pow_d = comptime pow.derive();
        const res = pow_d.eval().?;
        try std.testing.expectApproxEqAbs(d.derived, res, 0.00000001);
    }
}

test "derive sin to cos" {
    const sin = TestAst{ .sin = .{&TestAst.@"1"} };
    const cos = TestAst{ .cos = .{&TestAst.@"1"} };
    try std.testing.expectApproxEqAbs(sin.derive().eval().?, cos.eval().?, 0.0000001);
}

test "derive cos to -sin" {
    const x = TestAst.Args(1){&TestAst.@"1"};
    const cos = TestAst{ .cos = x };
    const cos_d = comptime cos.derive();
    const minus_sin = TestAst{ .mul = .{ &TestAst.@"-1", &.{ .sin = x } } };
    try std.testing.expectApproxEqAbs(cos_d.eval().?, minus_sin.eval().?, 0.0000001);
}
