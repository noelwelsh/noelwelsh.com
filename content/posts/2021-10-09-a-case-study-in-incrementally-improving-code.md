+++
title = "A Case Study in Incrementally Improving Code"
+++

In this article I'm going to go through the process of improving some code. I'm mentoring a new developer who is applying for their first job. They were asked to complete some tasks on [Codility](https://www.codility.com/) as the first step of the interview process. To get used to the platform they did the first example task, and I advised them on some changes. I'm writing up here the progression from their code to (what I think is) better code. (Since this is the example task, not a task used to assess applicants, I think this is ok to publically post.)

<!-- more -->

## The Problem

First, the Codility problem:


> Write a function:
> 
> ``` scala
> object Solution {
>   def solution(a: Array[Int]): Int
> }
> ```
> 
> that, given an array A of N integers, returns the smallest positive integer (greater than 0) that does not occur in A.
> 
> For example, given A = [1, 3, 6, 4, 1, 2], the function should return 5. Given A = [1, 2, 3], the function should return 4. Given A = [−1, −3], the function should return 1.
> 
> Write an efficient algorithm for the following assumptions:
> 
> - N is an integer within the range [1..100,000];
> - each element of array A is an integer within the range [−1,000,000..1,000,000].


## Setup

I created the interface below so that I could run all the variations through the same test harness. It's not part of the specification from Codility or the student's original code.

``` scala
trait Solution {
  def solution(a: Array[Int]): Int
}
```


## Initial Solution

Here's the student's initial solution:

```scala
object Solution1 extends Solution {

  def solution(a: Array[Int]): Int = {

    def tolis(b: List[Int]): Int = b match {
      case x :: Nil => x + 1
      case x :: hs => if ((hs.head - x) > 1) x + 1 else tolis(hs)

    }
    var b: List[Int] = a.toList.filter(_ > 0).sorted
    //b.sorted
    if (b.isEmpty) 1
    else if (b.head != 1) 1
    else tolis(b)


  }
}
```

## Code Cleanup

There are several issues with the initial solution. Let's start with the easiest ones:

- confusing naming (what does `tolis` mean?)
- `var` is not necessary (it could be a `val`)
- messy formatting

These are fairly small points but they are easy for an interviewer to complain about. A lot of jobs, particularly entry level jobs, receive many applicants and interviewers are often looking for reasons to reject candidates. We don't want to give them an easy reason to reject us!

Here's the code after a quick clean up.

``` scala
object Solution2 extends Solution {

  def solution(a: Array[Int]): Int = {
    def findLowest(numbers: List[Int]): Int = 
      numbers match {
        case x :: Nil => x + 1
        case x :: xs => if ((xs.head - x) > 1) x + 1 else findLowest(xs)
      }

    val clean: List[Int] = a.toList.filter(_ > 0).sorted

    if (clean.isEmpty) 1
    else if (clean.head != 1) 1
    else findLowest(clean)
  }
}
```


## Testing the Solution

Before we move on to deeper issues, I want to create a test suite so we can be sure we don't break anything during refactoring. 
To test this function we could create a few hand-crafted cases, the programmer equivalent of banging together sticks to make fire, or we could generate test cases from a specification. A fairly simple way to generate test cases is:

- create a many negative number as we like
- create a sequence of positive numbers, and remove one of the numbers
- join the two sets of numbers and shuffle

With this construction we know the result should be the number we removed.

Once we've setup the test suite we can proceed. I used [MUnit](https://scalameta.org/munit/) and its ScalaCheck integration to do the above.


## Partial and Total Functions

Let's now move on to deeper issues. I don't like the implementation of `findLowest`. There is some input for which it will crash---namely the empty list. In FP jargon we'd say it is a *partial function*, not a *total function*. The emtpy list case checked before it's called, but it easy for future modifications to break this.  We could use, say, Cats' `NonEmptyList` type to express that this function only works with non-empty lists, but it's not really appropriate to add a dependency in this context. We can, instead, rewrite `findLowest` to be a total function. 

We can make `findLowest` a total function by adding an extra parameter, which is the current guess for the lowest number. With this we can write `findLowest` as a standard structural recursion and the compiler will stop complaining about our incomplete match. Here's the code (written with Scala 3 syntax).

``` scala
object Solution3 extends Solution {
  def solution(a: Array[Int]): Int = {
    def findLowest(result: Int, numbers: List[Int]): Int =
      numbers match {
        case Nil => result
        case x :: xs =>
          if result == x then findLowest(result + 1, xs) else result
      }

    val clean: List[Int] = a.toList.filter(_ > 0).sorted

    findLowest(1, clean)
  }
}
```


## Performance

The requirements state they want an "efficient algorithm". I don't think they really mean that, but optimizing code can be fun and in this case there are some easy wins to be had. I'm going to look at two types of optimization:

- data representation, where we change how we store data to be more efficient; and
- algorithmic optimization, where we change the structure of the code to do less work.

The code mostly uses the `List` datatype, which is a singly linked list. This is a poor choice for performance as it involves a lot of pointer chasing and random memory access is slow on modern computers. `List` is appropriate when want to reason about shared data, and hence use immutable data, but in this code the data is never shared outside the method so that is not a concern.

From the algorithmic perspective we are doing a lot of work:

- there is an [O(n)][big-o] traversal of the input to convert to a `List`;
- the filtering operation is at least O(n) and may be more depending on how the filtered result is constructed;
- sorting is O(n log n); and
- the final traversal to find the lowest missing number is O(n).

My first change is mostly concerned with data representation. By working purely with arrays we use a more cache-friendly data structure, and we can also sort in-place which avoids some allocation. Here's the code.

``` scala
import java.util.Arrays

object Solution4 extends Solution {
  def solution(a: Array[Int]): Int = {
    def findLowest(result: Int, idx: Int, numbers: Array[Int]): Int = {
      if idx == numbers.length then result
      else if result == numbers(idx) then
        findLowest(result + 1, idx + 1, numbers)
      else result
    }

    val clean: Array[Int] = a.filter(_ > 0)

    Arrays.sort(clean)
    findLowest(1, 0, clean)
  }
}
```

The next step is mostly algorithmic optimization. We don't need to sort the array, or even filter it. All we need to do is construct a data structure that tells us what numbers are present. This requires just one O(n) traversal through the input. We only need a single bit to represent presence or absence for each positive integer. The specification tells us the input will not be higher than 1,000,000. Hence we can use a bit-set consuming no more than about 125kB, which should easily fit into the L2 cache and might even squeeze into L1 cache. Once we have constructed the bit set we need a single O(n) traversal to find the lowest missing number. Here's the code. Note I used `java.util.BitSet` instead of `scala.collection.mutable.BitSet` because it was a bit clearer on a quick glance which were the methods I wanted.

``` scala
import java.util.Arrays
import java.util.BitSet

object Solution5 extends Solution {
  def solution(a: Array[Int]): Int = {
    def populateBitSet(
        bitSet: BitSet,
        idx: Int,
        numbers: Array[Int]
    ): BitSet = {
      if idx == numbers.length then bitSet
      else {
        val elt = numbers(idx)
        if elt < 1 then populateBitSet(bitSet, idx + 1, numbers)
        else {
          bitSet.set(elt)
          populateBitSet(bitSet, idx + 1, numbers)
        }
      }
    }

    val bitSet = populateBitSet(BitSet(1000000), 0, a)
    val result = bitSet.nextClearBit(1)
    result
  }
}
```

I setup a quick [JMH][jmh] benchmark to compare implementations. I was only looking for big improvements, so I'm only reporting results below for the first solution, and `Solution4` and `Solution5` above. As you can see the combination of data representation and algorithmic improvements yield a speed up a bit over ten times compared to the original. That's pretty good for some fairly simple changes!


    [info] CodilityBenchmark.benchSolution1  thrpt    3  741.060 ± 32.291  ops/s
    [info] CodilityBenchmark.benchSolution4  thrpt    3  1956.945 ± 62.053  ops/s
    [info] CodilityBenchmark.benchSolution5  thrpt    3  8406.225 ± 751.966  ops/s


## Conclusions

The process of improving the code was reasonably straight forward. The most important improvements, in my opinion, are the ones that were done first. As an interviewer I want to see code that pays attention to clarity, as I think that's one of the most important factors in successfully growing a large code base. The optimizations I performed require some level of knowledge of data structures, computer architecture, and algorithmic complexity. All these things should be covered in a computer science course but those who haven't studied CS can find equivalents online. My optimizations don't require a deep level of knowledge of, for example x86-64 architecture. All these optimizations can be reasoned about with a fairly coarse machine model.

All the code is on [Github][repo] if you want go further, or just see how I setup the tests and benchmarks. I hope it is useful!


[jmh]: https://github.com/openjdk/jmh
[big-o]: https://en.wikipedia.org/wiki/Big_O_notation
[repo]: https://github.com/noelwelsh/codility

