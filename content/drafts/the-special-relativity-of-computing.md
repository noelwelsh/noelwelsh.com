# The Special Relativity of Computing

In my first year of undergraduate I was required to take a general survey course in Physics. A few things still stand out after all these years:

- [Frank van Kann's][Frank van Kann] looking death in the eye as he demonstrated physics principles (pendulums! magnets! capacitors!) in the most dangerous manner ... **TODO**
- our loose interpretation of the scientific method as we attempted to make our experimental data fit the theory;
- special relativity, which *blew* **my** **MIND**.

One of the most fun things about special relativity is [Lorentz Contraction] which basically says, as I recall, you can trade length for time. As velocity increases, length decreases---the "contraction" in Lorentz contraction---and yet time increases (so-called [time dilation]). If you want more time simply go faster, and give up a bit of length. And if you want more length, slow down and give up some time. (This is a very hand waving description, and no one should take this as a physics lession. If you want to know more, go read a book or maybe you can get Frank van Kann to explain it to you!)

I have noticed a similar space versus time trade off in computing. I call this the special relativity of computing. Let's see some examples.

The most obvious example is a cache, such as [Pelikan][pelikan]. In a cache we store items---taking up space in memory---to avoid recomputing them when they are needed---saving time.

We can explore this directly in code. Here's the recursive fibonacci function, written in Javascript. For our purposes, we only care that this is a very inefficient way to calculate what we're after.

```javascript
let fib = (n) => {
  if (n > 1) {
    return fib(n - 1) + fib(n - 2);
  } else {
    return n;
  }
}
```

```javascript
function time(f) {
  let start = new Date().getTime();

  f();

  let end = new Date().getTime();
  return (end - start);
}
```

```
> time(() => fib(40));
1213
```

```javascript
function memoize(f) {
  let cache = {};
  return (x) => {
    let cached = cache[x];
    if (cached == undefined) {
      let result = f(x)
      cache[x] = result;
      return result;
    } else {
      return cached;
    }
  }
}
```

```javascript
let memoFib = memoize((n) => {
  if (n > 1) {
    return memoFib(n - 1) + memoFib(n - 2);
  } else {
    return n;
  }
})
```

```
> time(() => memoFib(40));
0
```

Another example is the compiler optimization of [inlining].
None other than Andy Wingo has said [inlining is the mother of all optimizations][wingo].


Not a general law. `5 + 2` is bigger and slower than `7`.

[Frank van Kann]: https://research-repository.uwa.edu.au/en/persons/frank-van-kann
[Lorentz Contraction]: https://en.wikipedia.org/wiki/Length_contraction
[time dilation]: https://en.wikipedia.org/wiki/Time_dilation
[pelikan]: http://www.pelikan.io/
[inlining]: https://en.wikipedia.org/wiki/Inline_expansion
[wingo]: https://wingolog.org/archives/2011/08/02/a-closer-look-at-crankshaft-v8s-optimizing-compiler
