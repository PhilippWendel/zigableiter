# zigableiter
Lightning fast automatic derivations in zig[^1], because blazingly fast is just to slow.

[^1]: We never spoke of compile times

## How does it work
1. Build an ast of your math expression
2. Call `.derive()` to derive the expression
3. Call `.eval()` to evaluate the expression
4. Profit

## How does it work under the hood
We transform the ast into its derivation. E.g. x^n -> nx^(n-1):
Pow(x, n) becomes Mul(n, Pow(x, Sub(n, 1)))
Eval is a basic interpreter that walks through the ast and then calculates the final value.
The cool thing is since zig has comptime we can do these transformations at compile time.
What's even cooler, is that in theory the compiler should be able to resolve and inline the whole interpreter loop. 
What's even even cooler, is that we can do further optimisations like sorting the variables in the tree to get them closer together for less cache misses.

# TODOs
- [ ] Figure out how to missuse hashmaps as 'functional match expressions'
- [ ] Find a better distinction between val (var) and num (const)
      How can compiler optimise on nums?
- [ ] Do the derivation rules
- [ ] Add debug and analysis tools
- [ ] How should/can i handle si units? This is important for physics.
- [X] Try out with shaders? https://github.com/Snektron/vulkan-zig/tree/master/examples
      Maybe this can be rolled into compute shaders?
	  
	  Does not work with vulkan shaders. I don't know if this is currently or in general.
	  I use the example fragment shader from the vulkan_zig bindings. But since i don't
	  much about vulkan this is a future problem.
- [ ] Figure out how to 'bind' the underlying math functions.
      I want to be able to use at least the zig std math functions and gmp.
- [ ] How to handle errors, e.g. overflows
- [ ] How to use simd types? (@Vector and in the future @Matrice)
- [ ] Write test and benchmarks. How does the code get lowered
- [ ] What optimisations can we do?
  1. Variable sorting for better caching
  2. Google calculator trick for accuracy
  3. ... TBD
