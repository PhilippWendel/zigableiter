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
        val: T,

        fn apply(f: fn (T, T) T, node: LR) ?T {
            const l = node.l.eval() orelse return null;
            const r = node.r.eval() orelse return null;
            return f(l, r);
        }

        pub fn eval(ast: Self) ?T {
            return switch (ast) {
                .add => |node| apply(fun.add, node.*),
                .sub => |node| apply(fun.sub, node.*),
                .mul => |node| apply(fun.mul, node.*),
                .div => |node| apply(fun.div, node.*),
                .pow => |node| apply(fun.pow, node.*),
                .val => |val| val,
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
