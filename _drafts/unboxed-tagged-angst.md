---
layout: post
category: programming
title: Unboxed Tagged Angst
---

Type class based serialization is now standard in Scala JSON libaries such as [Play JSON](http://www.playframework.com/documentation/2.2.x/ScalaJsonCombinators). All our web applications these days are designed as JSON APIs, with the UI being just an API client. With this approach we usually find we want many different serialization formats. For example, logged-in users often see more information that anonymous users. If we're using a document-oriented database such as Mongo, we will want to save information in the database that we don't want other clients to see. Thus we need to control which type class is used for serialization at each point.

One approach to controlling type class visibility is to manually import the correct type class into scope at each point. This is a fantastic way to introduce bugs, as nothing in the type system will fail if we introduce the wrong type class.

As better approach, and the one we've been using, is to tag the data before serialization. I think some code helps at this point.

Let's say we have a basic `User` class

{% highlight scala %}
case class User(name: String, email: String)
{% endhighlight %}

In Play we can construct a serializer like so:

{% highlight scala %}
import play.api.libs.json._

implicit val userWrite: Write[User] = Json.write[User]
{% endhighlight %}

A `Write[User]` is a type class that can write a `User` as JSON. If we want to write a `User` we can call `Json.toJson(user)` and the usual implicit resolution rules will look for a `Write` in scope.

Now suppose we don't want to display email addresses to anonymous users. We can define a new `Write` easily enough.

{% highlight scala %}
implicit val anonymousUserWrite: Write[User] = (
    (_ \ "name").write[String])
)(unlift(User.unapply))
{% endhighlight %}

The question is do we make sure this implicit is used at the correct points, in a way that the compiler will complain to us if we get it wrong?

We've followed Scalaz's lead, using [unboxed tagged types](http://etorreborre.blogspot.co.uk/2011/11/practical-uses-for-unboxed-tagged-types.html).
