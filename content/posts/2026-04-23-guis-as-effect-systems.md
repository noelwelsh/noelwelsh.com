+++
title = "Capability-Passing User Interfaces"
draft = true
+++

Modern user interface libraries have converged on an underling model that represents interfaces as effects in the [capability-passing style][wysiwyg]. Others have noted that [algebraic effects are a useful mental model for user interfaces][rest-of-us], but as far as I know this has been a post hoc discovery, not a strategy that guided design from the start. When we start with the capability-passing model in mind, we get a cleaner implementation that prevents certain kinds of errors. Furthermore, capability-passing is simple and easy to work with.

In this post starts with a brief discussion of capability-passing, and then turns to investigating what makes user interface frameworks challenging. We'll see the fundamental problem is that an interface consists of two structures, the layout tree and the event graph, and each structure refers to the other. We'll explore how different frameworks deal with this, starting with callbacks, visiting reactive programming, and ending up at three contemporary models: immediate mode GUIs, modern Javascript frameworks exemplified by Solid, and Jetpack Compose. When we dig into the details of the current systems we'll see they can all be viewed as capability-passing. Finally, we'll reverse the process, and ask what happens if we design a framework using capability-passing to start with. We'll see that it gives us a simple design and we can prevent some programming errors by leveraging language support for the capability-passing style.


<!-- more -->

## Context, Effects, and Capabilities

To talk about capability-passing, we need to briefly talk about context, effects, and capabilities. An **effect** (using the definition in the capability-passing literature; [see for example][effekt-publications]) is anything that depends on or modifies the surrounding context in which the program executes. What, then, is the context? **Context** is the set of capabilities that are available to the program at any particular point, together with the state of any resources those capabilities control. The capabilities? This where we get a bit philosophical. **Capabilities** are the ability to undertake actions that we wish to explicitly track or control. This, fundamentally, comes down to a choice on what we think is important. For example, most languages don't consider memory allocation to be a capability. In such languages a program can freely allocate memory and we wouldn't consider this to be an effect. In systems programming languages, however, memory allocation is a core concern and is treated as a capability: something that we restrict access to or wish to explicitly track.

Once we have defined all these, **capability-passing** is simple: it's a programming style where capabilities are values that are passed to the parts of code that need them. For example, if we have capabilities for IO and memory allocation, we might write a function signature

```scala
f: (Io, Memory) => A
```

indicating that this function requires the `Io` and `Memory` capabilities to run.

This gives a very simple form of effect tracking: a function's signature tells us which capabilities it needs and therefore which effects it can perform. The languages that support capability-passing, [Effekt][effekt] and [Scala 3][scala-cap], add a few details for safety and ease of use, but this is not important for us right now.


## The Problems of User Interfaces

User interfaces are difficult to create. This is in part because user interfaces have an enormous amount of detail; there's just a lot of stuff to write for a good user interface. That's not the problem we're considering here. Rather, we're concerned with the architecture. That is, the way in which the user interface author expresses the structure of the user interface, as mediated by the framework they use.

Consider the following user interface. 

{{ iframe(src="/demos/callback-ui.html", height=140) }}

In pseudo-code, we might write

```scala
val i = Input("", placeholder = "Type something...")
val b = Button("Go!").disable()

i.onKey(_ => b.enable())
b.onSubmit{ _ => 
  doSomething(i.value)
  i.clear()
  b.disable()
}

RowContainer(i, b).show()
```

This code is written in a callback-driven style. It will be familiar to many from the browser [DOM][dom], but this model stretches back to Smalltalk and the first GUIs.

The callback-driven approach focuses on the **components** representing what is displayed on the screen. `Input` and `Button` represent the text input and the button, respectively, and the `RowContainer` specifies the text input and button should be displayed in a row. We can see that:

1. Components are values. We can pass them around and combine them to produce new components, as we do when passing `i` and `b` to the `RowContainer`.
2. Components form a tree. We'll call this the **layout tree**.

*diagram here*

It's natural to focus on what we see on the screen, but this ignores another structure that is equally important: the flow of events. In the example above the input field `i` refers to the button `b`, to enable it, and the button `b` refers backs to the input field `i`, to clear it. This means the event handling structure is a cyclic graph, which is a more complex structure than the layout tree. We'll call this the **event graph**.

*diagram here*

It is difficult to express cyclic structures in code. The callback-driven solution is to write user interfaces in a two stage process. First we create all the components. Now that we can reference any component of interest we add callbacks to define the event handling structure. Layout is straightforward to read in this model, but event handling is fragmented across a mess of callbacks and becomes difficult to reason about.

In summary, user interfaces require we define two structures[^other]: layout and event handling. Layout is a tree, but event handling is a cyclic graph. To further complicate things, the layout tree and event graph have references to each other. How different architectures handle this is the core of what we'll examine when we look at contemporary frameworks.


## Reactive Programming

Reactive programming, exemplified by [ReactiveX][reactivex], [RxJS][rxjs], and [Flapjax][flapjax], solves the problem of the event graph by making events first-class values. We'll call them observables, and they represent a sequence of values over time.
In a typical implementation might rewrite the example as shown below.
In this example code I'm assuming that component properties, such as the enabled state of the button, can be set directly from observables.


```scala
val text = Observable("")
val enabled = text.map(t => t.isNonEmpty)

val i = Input(text).onKey(_ => text.set(i.value))
val b = Button("Go!")
          .enabled(enabled)
          .onSubmit(_ => text.set(""))

RowContainer(i, b).show()
```

Now that events—the observables—have names they can be referred to directly. 
This indirection via names allows us to break the cycles in the event graph[^indirection].

Having written many user interfaces in this style I've found there are still a few problems. A basic one is the annoynace of dealing with two distinct structures, involving a lot of packing and unpacking of components and observables to pass them around. More serious is that observables just tend to be difficult to work with. Typical implementations have complex APIs that require careful reasoning about semantics, and when things go wrong debugging can be very hard. Still, they are an improvement over what came before.


## Interfaces as Capabilties

Let's now move on to the final category of architectures. We are going to look at three different systems—[egui][egui], [Solid][solid-js], and [Jetpack Compose][jetpack-compose]—to see how they handle the layout tree and event graph problem. We'll see a lot of similarities, and a few differences. When we dig into the similarities we'll find capability-passing as a unifying model.


### Immediate-Mode GUIs

Our first case study will be so-called immediate-mode GUIs. 
Below is a small example using the [egui] framework,
taken from the project's home page.

```rust
ui.heading("My egui Application");
ui.horizontal(|ui| {
    ui.label("Your name: ");
    ui.text_edit_singleline(&mut name);
});
ui.add(egui::Slider::new(&mut age, 0..=120).text("age"));
if ui.button("Increment").clicked() {
    age += 1;
}
ui.label(format!("Hello '{name}', age {age}"));
ui.image(egui::include_image!("ferris.png"));
```

Each component, such as `heading` or `button`, is an effect.
Sometimes these effects act on the top-level `ui`.
In other cases they are nested, such as the call to `ui.horizontal` that creates a new `ui` data structure which lays out its children horizontally.
We can infer the shape of the layout tree is the shape of the calls to `ui`. 

Immediate-mode GUIs redraw the user interface on every frame,
which gives them a unique approach to event handling.
Events are handled as the interface is rendered,
which we can see above in the call to `clicked`.
Note that event handling requires storing state between frames.
For example, a mouse click is differentiated from a mouse drag by the starting and ending locations of the click events.

It's clear we can view this as capability-passing; the `ui` value is exactly the capability to create components and handle events.
The layout tree and event graph simply don't exist in this model, except in the internal state of `ui` where the application programmer doesn't have to deal with them.
The immediate-mode approach does seem very ergonomic, but it has some serious limitations.
For example, it cannot cleanly handle layout that depends on child elements, 
or cycles in event handling.
Consider the form example at the start of this post.
When the button is clicked we clear the input. 
The button is rendered after the input and, therefore, 
at the point in time when we render the input we do not know if it should be cleared or not.
egui allows the programmer to [request rerendering][egui-rerender] to deal with such situations, but this only pushes the problem of correctness onto the application programmer instead of solving it.


### Solid

Our next example is [Solid][solid-js], a Javascript framework for the web.
It's similar to contemporaries like [React][react] and [Vue][vuejs], but a little bit more explicit about the parts we care about.
Here's an example:

```js
function MousePos() {
  const [pos, setPos] = createSignal({x: 0, y: 0});

  function handleMouseMove(event) {
    setPos({
      x: event.clientX,
      y: event.clientY
    });
  }

  return (
    <div onMouseMove={handleMouseMove}>
      The mouse position is {pos().x} x {pos().y}
    </div>
  );
}

render(() => <MousePos />, document.getElementById("app")!);
```

This defines a Solid component call `MousePos`. 
Instantiating the component—calling the `MousePos` function—is a two stage process.
The body of the function, up to the `return` expression, is the setup phase of the component.
Anything here runs once, when `MousePos` is called.
The most important part of the setup phase is the `createSignal` call.
This creates a `Signal`, which we can think of as an observable (the differences are not important here).
The `return` expression, however, runs within the rendering phase.
This creates a tracking scope to records any use of signals,
such as the calls to `pos().x` and `pos().y`, 
and registers a dependency on those signal.
If the value of the signal changes,
the expression registered with the tracking scope is reevaluated.

Solid uses a specialized compiler,
and we can peel back some of the abstraction by looking at the compiler's output:

```js
function MousePos() {
  const [pos, setPos] = createSignal({
    x: 0,
    y: 0
  });
  function handleMouseMove(event) {
    setPos({
      x: event.clientX,
      y: event.clientY
    });
  }
  return (() => {
    var _el$ = _tmpl$(),
      _el$2 = _el$.firstChild,
      _el$4 = _el$2.nextSibling,
      _el$3 = _el$4.nextSibling;
    _el$.$$mousemove = handleMouseMove;
    _$insert(_el$, () => pos().x, _el$4);
    _$insert(_el$, () => pos().y, null);
    return _el$;
  })();
}

render(() => _$createComponent(MousePos, {}), document.getElementById("app"));
_$delegateEvents(["mousemove"]);
```

The call to `render` setups up the objects that will track signal dependencies and handle cleanup. Inside `_$insert` the actual tracking scope is created, and the parameters passed to `_$insert` provide the information necessary to reevaluate on change.

From the above we can tell that the layout tree in Solid is *not* an effect, but a value. 
The browser requires DOM nodes—values—so it doesn't make a lot of sense to introduce a different abstraction. The effect graph, however, is where Solid gets interesting. The basic model is similar to reactive programming, but it has improved ergonomics. The interface to signals is very simple; the main operations are getting and setting a value. With observables the user has to learn many higher-order combinators, like `mergeMap` and `combineLatest`. With signals dependencies are automatically tracked and dependents automatically reevaluated, whereas this must all be done manually when using observables. This all works because signals run in the context of a runtime that handles these tasks for the developer.


### Jetpack Compose

Our final example is [Jetpack Compose][jetpack-compose], the UI framework used in Android and [Compose Multiplatform][compose-mp].
Below is a small example.

```kotlin
@Composable
fun HelloContent() {
    Column(modifier = Modifier.padding(16.dp)) {
        var name by remember { mutableStateOf("") }
        if (name.isNotEmpty()) {
            Text(
                text = "Hello, $name!",
                modifier = Modifier.padding(bottom = 8.dp),
                style = MaterialTheme.typography.bodyMedium
            )
        }
        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            label = { Text("Name") }
        )
    }
}
```

Here `HelloContent`, `Column`, `Text`, and `OutlinedTextField` are all components,
known as composables in Jetpack's lingo.
Composables are impure functions, as in immediate-mode GUIs, 
and once again we see the layout tree represented by the structure of effectful calls.
Notice that parent composables can change how child composables appear.
We see that with the `Column` composable, which causes its children to appear in a vertical column.
Therefore the `Column` composable is establishing some state that at a minimum is tracking the location of child composables.
The `Column` component renders within the context of whatever calls the `HelloContent` function,
and this surrounding context will determine where the `Column` is rendered.

Event handling is done by signals as in Solid; `name` is an example.
As in Solid, changing a signal rerenders any part of the UI that depends on that signal.
In the example above, changing the value of the `OutlinedTextField` will update the `name` signal, which in turn will cause a change in the value displayed by the `Text` composable.
The mechanism Jetpack uses is quite different to Solid, however.
The Jetpack Compose compiler plugin rewrites composables to take an additional parameter, a [`Composer`][composer].
It also inserts calls to the `Composer`.
Most important for our cases are the calls that delimit regions where signal uses are tracked
and which can be rerun when those signals change.

We can see that Jetpack Compose has elements of the immediate-mode model: user interface elements are effects, and the layout tree matches the structure of calls to some layout context. It also has similarities to Solid: the event graph is constructed by establishing some context that listens for signal use and registers user interface elements to rerender when those signals change.



## User Interfaces as Capability-Passing

Now that we understand capability-passing, we can see the modern interface framework as using capability-passing for the layout tree, event graph, or both. The layout tree is a capability in the immediate mode frameworks and Jetpack Compose. They work by mutating some data structure in the current scope; access to the data structure is the capability. Indeed, it's even explicit in egui (the `ui` value). Similarly, the event graph is a capability in Solid and Jetpack Compose. We saw this with the tracking scope that Solid uses: this is exactly the capability to track a signal use and register the dependency. Similarly with Jetpack Compose, where the tracking scopes are inserted by the compiler. The event graph is actually also a capability in egui: as we saw the system stores event handling state in-between frames. We can think of access to this state as the capability.

What does viewing these systems as capability-passing give us? One thing is a clearer picture of how they work, abstracted away from the details of any one framework. As we've seen, there are two capabilities, layout and events, central to user interfaces.

We can also do usual thing we do with type systems: prevent running a whole bunch of incorrect programs (and some correct ones!) For example, in Solid it's possible to access a signal outside a tracking scope, which usually indicates a bug. We can statically prevent this.


[^other]: There are other structures in a user interface. For example, there is usually another tree to handle input events. These structures are often fairly simple and not directly constructed by the application programmer, so we'll ignore them here.

[^indirection]: "All problems in computer science can be solved by another level of indirection." Attributed to David Wheeler and Butler Lampson.

[reactivex]: https://reactivex.io/
[flapjax]: https://www.flapjax-lang.org/
[rxjs]: https://rxjs.dev
[egui]: https://github.com/emilk/egui
[egui-rerender]: https://docs.rs/egui/latest/egui/index.html#multi-pass-immediate-mode
[jetpack-compose]: https://developer.android.com/compose
[compose-mp]: https://kotlinlang.org/compose-multiplatform/
[solid-js]: https://www.solidjs.com
[react]: https://react.dev/
[vue]: https://vuejs.org/
[dom]: https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model
[rest-of-us]: https://overreacted.io/algebraic-effects-for-the-rest-of-us/
[wysiwyg]: https://link.springer.com/chapter/10.1007/978-3-030-83128-8_3
[composer]: https://developer.android.com/reference/kotlin/androidx/compose/runtime/Composer?hl=en
[effekt]: https://effekt-lang.org/
[scala-cap]: https://www.scala-lang.org/api/current/scala/caps/Capability.html
[effekt-publications]: https://effekt-lang.org/publications
