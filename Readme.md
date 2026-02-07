# zigableiter
Lightning fast derivations in zig[^1]

[^1]: We never spoke of compile time

## How does it work
1. Build an ast of your math expression
2. Call `.derive()` to derive the expression
3. Call `.eval()` to evaluate the expression
4. Profit

## How does it work under the hood
We transform the ast into its derivation. E.g. x^n -> nx^(n-1):
Pow(x, n) becomes Mul(n, Pow(x, Sub(n, 1)))
Eval is basic interpreter that walks through the ast and then calculates the final value.
The cool thing is since zig has comptime we can do these transformations at compile time.
What's even cooler, is that in theory the compiler should be able to resolve and inline the whole interpreter loop. 
What's even even cooler, is that we can do further optimisation like sorting the variables in tree to get them closer together for less cache misses.
