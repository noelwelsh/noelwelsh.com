+++
title = "Bugs, Types, and Random Bullshit"
draft = true
+++

You probably experienced the recent [Cloudflare outage][cloudflare-incident] that took down many websites. Per the incident report, contributing to the issue was a constraint shared between a database query and some Rust code that the result of the query would not exceed 200 lines. Unfortunately this constraint was not explicitly represented anywhere in the system. When the query generated results longer than 200 lines there was nothing to flag the constraint had been broken, other than a lot of websites breaking.

This reminds me of some bugs I recently released (which, fortunately, had much smaller impacts). I certainly don't like releasing bugs, but rather than beating myself up I find it much more useful to think about what kind of systems could have prevented the bug. All of us have limited cognitive resources, and striving to pay more attention or be more careful simply doesn't work over an extended duration. However, we can create systems---continuous integration is one example---that are extremely reliable and will almost always find problems if we can represent the constraints of the system in a way they can check. If not, we're left with what I call random bullshit, the bane of software development. Let's talk a bit about this and then return to the bugs I created and how they could be avoided.

## Random Bullshit

I have a loose mental taxonomy of knowledge, between random bullshit and principled. Principled knowledge is anything that can be derived from some principle. This could just be "works the same as other systems", to mathematical theories that give a chain proofs starting from basic axioms. Random bullshit is everything else: stuff you Just Have To Know.

Despite the name, random bullshit is very important. Domain specific knowledge is largely random bullshit, and domain knowledge is incredibly valuable. What isn't valuable is random bullshit where there is no need for it. Let's see some examples.

Javascript is, of course, the finest purveyor of random bullshit in modern programming. For example, equality in Javascript is just completely bizarre. Consider the following snippet:

```javascript
0 == [];
// true
0 == "0";
// true
"0" == [];
// FALSE?!
```

It's random bullshit because it doesn't work the way equality in mathematics, or any sane language, does. If you don't want random bullshit you Just Have To Know to use `===` instead. 

Javascript, of course, has much more random bullshit. Here's another fun example.

```javascript
[] + {};
// "[object Object]"
{} + [];
// 0?!
```

One last example. When sorting a Javascript array, a comparison function is optional. If you don't provide one Javascript just does some random bullshit. Consider, for example

```javascript
["Zachery", 1, {name: "Ziggy"}, "~Tilde~", "$bill"].toSorted()
//  [ "$bill", 1, "Zachery", {name: "Ziggy"}, "~Tilde~" ]
```

Strings starting with symbols can be sorted before or after numbers depending on the symbol. The object appears between two strings. What is going on here?!

It's important to note that random bullshit can still be consistent. All the above behaviour is documented in the Javascript specification, but no sane person would guess these were the semantics on their own. What makes this the bad kind of random bullshit is that there is no need for this behaviour. Javascript could work in a sane way, but Brendain Eich was listening to a lot of the Smiths back in 


Random bullshit makes learning incredibly inefficient, because everything is its own special snowflake, and you can't transfer over what you know about from other domains.


## The Error

I was working on a system using a home-grown query DSL. I wrote what I thought was a query with two where clauses, but the second clause overwrote the first. This led to many more records being selected than I expected, and the following update made a mess. Luckily the system wasn't live for long and it was possible to restore the database from a backup.

The question is, why did this error occur, and what can be done to prevent it?

The basic issue of why the error occurred is a mismatch between my expectations of how the query DSL worked and how it did work. Concretely, if I wrote something like

```scala
select(aTable).where(condition1).where(condition2)
```

I would expect both `condition1` and `condition2` to apply. This is not how the homegrown system worked: the second `where` overwrote the first one. This meant that my query only used the second condition and selected many more records than it should have.

All the existing tests, and a period of manual testing, didn't find this error. This isn't particularly surprising, as its a unusual bug to check for.


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
