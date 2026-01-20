+++
title = "Bugs, Types, and Random Bullshit"
draft = true
+++

You probably experienced the recent [Cloudflare outage][cloudflare-incident]. Per the incident report, the problem was caused by a database query generating more results than the 200 lines accepted by the code using the output. There are several ways this problem could be addressed, but I'm more interested in the nature of the problem itself: an implicitly stated contract between the query and its user, or as I prefer to call it, random bullshit. (This is my Australian upbringing coming out.) I've recently been thinking a lot about random bullshit, and ways to mitigate it, as it was also behind some bugs I recently worked on. Unlike Cloudflare, my problems could all have been prevented with some simple use of the type system, but before we get into that let's talk about systems and try to pin down what I mean by random bullshit.


## Systems and Understanding

It's impossible to fully understand any reasonably sized code base. Instead we rely on various signs and signifiers to help us build understanding. Code style, naming conventions, directory layout, types, and comments are all examples of ways a code base can communicate meaning to the reader without them having to get into the details of code. If we see a method parameter named `userId` with type `UUID` we can reasonably infer it's the user's identifier, represented as a UUID. This is *principled knowledge*, and we rely on it all the time when reading code.

If we instead of a parameter named `userId` we have a parameter named `uuid`, and instead of type `UUID` it has type `String`,  we have no way of knowing it represents the current user's identifier without tracing the value back to its origin. (Yes, this is a real example.) This is *random bullshit*. Random bullshit is the opposite of principled knowledge. If principled knowledge is something that is explicitly communicated to us or can reasonably infer, random bullshit is something we only know if we know.

Despite the name, random bullshit can be very important. Domain specific knowledge is largely random bullshit, and yet is incredibly valuable. Think about, say, tax law. What can and can't be claimed as a business expense is quite arbitrary, but it's critical knowledge for a small business accountant.

Other kinds of random bullshit, however, are not a source of value. 
When we, as developer, find unnecessary random bullshit we should either try to remove it or formalize it so it is explicitly represented.


## Systems

I strongly believe that systems prevent errors. 
All of us have limited cognitive resources, and striving to pay more attention or be more careful simply doesn't work at scale.
Computers, however, are great at the kind of mindless rote work of running the same checks on every new software release.
We have software systems that do this: continuous integration.
The role of humans in the cycle of quality is converting what I call random bullshit into a form that these systems can check.


## Random Bullshit

My loose mental taxonomy of knowledge is divided into random bullshit and principles. Principled knowledge is anything that can be derived from other knowledge. This could be as loose as "follows existing convention", or as formal as a chain proofs starting from fundamental axioms. Random bullshit is everything else: stuff you have no way of knowing until you know it.



Take the Cloudflare limit of 200 lines for example. It is random bullshit; it's an arbitrary choice and there is no way anyone would know this without intimate knowledge of the system. There are two choices: change the code so it can handle an arbitrary number of lines in the query result, or change the system so something shouts loudly when the limit is exceeded.


## Types and Tests

How should constraints be explicitly represented? 
In software we have basically two choices: 

1. Static checks, which test properties of code without running it. Types are the most accessible form of static check, but there are other approaches under the umbrella of formal methods.

2. Dynamic checks, usually called tests, that run code and make assertions about its behaviour. There are various kinds of tests: unit tests, integration tests, and so on.

I prefer types where they are feasible.
Types prevent entire classes of errors,
rather than only the specific instances a test looks for,
and they are often cheaper to write and maintain than tests.
However, types have limits.
We'll get back to this later.
Let's now turn to the bugs I created, and the random bullshit that was the cause of them.


## My Enduring Shame

I'm going to talk about three bugs, which occurred in two different projects.

The first bug was fairly simple, but frustrating to find for reasons I won't get into. I was writing code for what was essentially a login system. Users entered their email address, and we checked for an existing one. The check was failing intermittently, due to a case sensitive comparison. This was an extension to an existing system, that already had an `Email` type. I assumed, in [parse, don't validate][parse] style, that this type would have normalised case upon construction. It didn't, and it was a simple fix to implement correct behaviour once I discovered the source of the problem.

The second bug occurred in a system using a home-grown query DSL. I wrote what I thought was a query with two where clauses, but the second clause overwrote the first. This led to many more records being selected than desired, and the following update made a mess. Luckily the system wasn't live for long and it was possible to restore the database from a backup.

The question is, why did this error occur, and what can be done to prevent it?

The basic issue of why the error occurred is a mismatch between my expectations of how the query DSL worked and how it did work. Concretely, if I wrote something like

```scala
select(aTable).where(condition1).where(condition2)
```

I would expect both `condition1` and `condition2` to apply. This is not how the homegrown system worked: the second `where` overwrote the first one. This meant that my query only used the second condition and selected many more records than it should have.

All the existing tests, and a period of manual testing, didn't find this error. This isn't particularly surprising, as its a unusual bug to check for.

The third error also involved the home-grown ORM. I called a method to update a particular table. This method had many parameters, one for each column, and all of which were optional. Some of these parameters defaulted to not changing the value of the column, while others defaulted to setting the column's value to null. All the parameters had the same `Option` type.


## Preventing Mistakes with Systems

My philosophy is that *systems* are the only way of reliably preventing problems. We are inherently forgetful and distractable creatures, and no number of exhortations to be more careful will make a long term difference. Systems, however, can reliably work every time. Computerised systems are ideal: they can work the same way every time, and are cheap.

Automated tests (and continuous integration) are one form of system. They have certainly improved software quality, but they do come with a cost.
I didn't write a test for the query as it was a straightforward modification to an existing query. I would guess the orthodox view, influenced by test-driven development philosophy, is to test everything. I don't hold to this view. Tests have a cost, in terms of the time they take to write, to run, and the maintenance they require. This query was a trivial modification of an existing query, and I didn't feel a test was needed.

Type systems are another form of system. They run every time we compile our code, and the type system itself is maintained by the language authors. 
Types also rule out every bug, while tests only cover individual cases.
We have to maintain the types.

Now, I strongly believe the query DSL was doing the wrong thing. I've worked with many query DSLs in Scala, and they have never has these semantics. I think the design is counter-intuitive, both from the point-of-view of someone who has used other query DSLs and of someone who is familiar with SQL. However, there are situations, such as complex configuration, where it makes sense to only allow certain values to be set once. We can express this in the type system, and if the query DSL had been implemented in this way my buggy code would have failed to compile.

There are a few different ways we can implement this. As a case study let's use a very simple query DSL. We'll start with the following data structure, where I have just used `String` as a stand-in for the elaborate expression language we'd need in a real system.

```scala
final case class Query(from: String, where: String, select: String)
```

This allows us to specify a query in terms of the tables to get data from (`from`), filters on those tables (`where`), and transformations on the filtered data (`select`).

This is close enough to the system I was working with, with a method `where` implemented as

```scala
final case class Query(from: String, where: String, select: String) {
  def where(clause: String): Query =
    this.copy(where = clause)
}
```

Now the simplest way to enforce write-once constraints is to require queries to be written in a specific order. Let's say we want the programmer to write queries in the order: from, then where, then select. We can implement this as follows.

```scala
final case class From(from: String) {
  def where(clause: String): Where =
    Where(from, clause)
}

final case class Where(from: String, where: String) {
  def select(clause: String): Select =
    Select(from, where, clause)
}

final case class Select(from: String, where: String, select: String) {
  def run: IO[QueryResult] = ???
}
```

In effect we have a very simple finite state machine. Each state of that finite state machine corresponds to a type, and methods allow transitions between states.

This works well enough for a simple finite state machine, like the linear one above. However if our finite state machine is more complex then it becomes very tedious to implement. A better approach is to use phantom types. There is quite a bit of machinery involved. Let's walk through it.

The first thing we need is a type to represent whether a field is present of absent. We'll call this type `IsSet`. Notice that `Yes` and `No` are subtypes of `IsSet`

```scala
sealed trait IsSet
sealed trait Yes extends IsSet
sealed trait No extends IsSet
```

Now we extend `Query` with type parameters, one for each field we want to track. These type parameters tells us if a particular field is set or not. These type parameters are known as phantom types as there are no values in the `case class` that have these types. I've also changed the field themselves to `Options`, so the values also track if the field is set, but this is not necessary.

```scala
final case class Query[From <: IsSet, Where <: IsSet, Select <: IsSet](from: Option[String], where: Option[String], select: Option[String])
```

The final part is add methods that 1) can only be called when the phantom types are in the correct state and 2) return a value with updated phantom types. The types `From =:= No`, and so on, are infix notation for a type `=:=[From, No]` and mean `From` is equal to `No`. Given instances of these types are generated by the compiler when the types are equal. Having a `using` clause on the methods means we can only call them when the compiler will generate a given instance, which in turn means we can only call the methods when the phantom types are in the correct state. We return a value with an updated state to correctly track setting the field.

```scala
final case class Query[From <: IsSet, Where <: IsSet, Select <: IsSet](from: Option[String], where: Option[String], select: Option[String]) {
  def from(table: String)(using From =:= No): Query[Yes, Where, Select] =
    this.copy(from = Some(table))

  def where(clause: String)(using Where =:= No): Query[From, Yes, Select] =
    this.copy(where = Some(clause))

  def select(clause: String)(using Select =:= No): Query[From, Where, Yes] =
    this.copy(select = Some(clause))
}
object Query {
  val empty: Query[No, No, No] = Query(None, None, None)
}
```

[cloudflare-incident]: https://blog.cloudflare.com/18-november-2025-outage/
[toSorted]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/toSorted
[parse]: https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/




Random bullshit is one of the most pernicious sources of problems, and that was behind three bugs I've worked on recently. (Fortunately, I didn't take down the Internet.)

. This reminds me of several bugs I've worked on recently; not in that I brought down the Internet, but in that they arose because of implicit constraints. 

My loose mental taxonomy of knowledge is divided into random bullshit and principles. Principled knowledge is anything that can be derived from other knowledge. This could be as loose as "follows existing convention", or as formal as a chain proofs starting from fundamental axioms. Random bullshit is everything else: stuff you have no way of knowing until you know it.

We can view this as a shared, implicit, constraint between the query and the code using the result. There was nothing that explicitly validated this constraint. There was no `limit` on the query result, and no checks in the code parsing the result. So when it was broken the result was a lot of unusable websites, rather than, say, a type error, test failure, or error message.

The Cloudflare incident reminds me of some bugs I recently released; not in that I took down a sizable portion of the Internet, but rather there were implicit constraints that I wasn't aware of. It's natural to feel bad about releasing bugs, and I've done this, but it's far more productive to think about why these bugs were caused and how they could be prevented. That's what this post is about.
