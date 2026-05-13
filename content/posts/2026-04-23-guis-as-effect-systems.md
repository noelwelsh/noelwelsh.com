+++
title = "Capability-Passing User Interfaces"
draft = true
+++

Modern user interface libraries have converged on an underling model that represents interfaces as effects in the [capability-passing style][wysiwyg]. Others have noted that [algebraic effects are a useful mental model for user interfaces][rest-of-us], but as far as I know this has been a post hoc discovery, not a strategy that guided design from the start. When we start with the capability-passing model in mind, we get a cleaner implementation that prevents certain kinds of errors. Furthermore, capability-passing is simple and easy to work with.

In this post I'm going to start by investigating what makes user interface frameworks challenging. We'll see the fundamental problem is that an interface consists of two structures, the layout tree and the event graph, and each structure refers to the other. We'll explore how different frameworks deal with this, starting with callbacks, visiting reactive programming, and ending up at three contemporary models: immediate mode GUIs, modern Javascript frameworks exemplified by Solid, and Jetpack Compose. When we dig into the details of the current systems we'll see they all use capability-passing to an extent. Finally, we'll reverse the process, and ask what happens if we design a framework using capability-passing to start with. We'll see that it gives us a simple design and we can prevent some programming errors by leveraging language support for the capability-passing style.


<!-- more -->

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

The callback-driven approach focuses on the **components** representing what is displayed on the screen[^tangible]. `Input` and `Button` represent the text input and the button, respectively, and the `RowContainer` specifies the text input and button should be displayed in a row. We can see that:

1. Components are values. We can pass them around and combine them to produce new components, as we do when passing `i` and `b` to the `RowContainer`.
2. Components form a tree. We'll call this the **layout tree**.

*diagram here*

It's natural to focus on what we see on the screen, but this ignores another structure that is equally important: the flow of events. In the example above the input field `i` refers to the button `b`, to enable it, and the button `b` refers backs to the input field `i`, to clear it. This means the event handling structure is a cyclic graph, which is a more complex structure than the layout tree. We'll call this the **event graph**.

*diagram here*

Expressing cyclic structures in code is difficult. The callback-driven solution is to write user interfaces in a two stage process. First we create all the components. Now that we can reference any particular component of interest, we add callbacks to define the event handling structure. Layout is straightforward to read in this model, but event handling is fragmented across a mess of callbacks and becomes difficult to reason about.

In summary, user interfaces require we define two structures[^other]: layout and event handling. Layout is a tree, but event handling is a cyclic graph. To further complicate things, the layout tree and event graph have references to each other. How different architectures handle this is the core of what we'll examine.


## Reactive Programming

Reactive programming, exemplified by [ReactiveX][reactivex], [RxJS][rxjs], and [Flapjax][flapjax], gives event handling first-class status. In a typical implementation we define so-called observables, which represent values that can change over time. 

```scala
val text = Observable("")
val enabled = text.map(t => t.isNonEmpty)

val i = Input(text).onKey(_ => text.set(i.value))
val b = Button("Go!")
          .enabled(enabled)
          .onSubmit(_ => text.set(""))

RowContainer(i, b).show()
```

In this example code I'm assuming that component properties, such as the enabled state of the button, can be set directly from observables.

The key insight is that by adding a layer of indirection to the event handling—communicating through the observables instead of directly from the callbacks—we break the cycles in the graph[^indirection]. 

*More description here*

There are still a few problems. One that is we need to pass around observables *and* components. This is inconvenient.

Bidirectional flow is difficult to understand.

Working with higher-order functions can be hard.


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

The immediate mode approach does not cleanly handle layout that depends on child elements, 
or cycles in event handling.
Consider the form example at the start of this post.
When the button is clicked we clear the input. 
The button is rendered after the input and, therefore, 
at the point in time when we render the input we do not know if the button has been clicked.
egui allows the programmer to [request rerendering][equi-rerender] to deal with such situations.


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
The body of the function, up to the `return` expression, can be considered the setup phase of the component.
Anything here runs once, when `MousePos` is called.
The most important part of the setup phase is the `createSignal` call.
This creates a `Signal`, which we can think of as an observable (the differences are not important here).
The `return` expression, however, runs within a tracking scope.
Any use a signal within a tracking scope, 
such as the calls to `pos().x` and `pos().y`, 
will register a dependency on the signal.
If the value of the signal changes,
the expression within the tracking scope is reevaluated.

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

The calls to `_$insert` register dependencies. 
This 


This is unlike Jetpack Compose, which will reinvoke the entire composable. This means that Solid potentially does less work, but other effects that depend on observables must be wrapped within calls to `createEffect`. 


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

Here `Column`, `Text`, and `OutlinedTextField` are components.
As in immediate-mode GUIs, components are effects.
We can see in the way the `Text` component is rendered.
It only exists in the true branch of the `if` expression.
If components were constructed by composing values we would have to construct a corresponding value for the false branch.
The `Text` and `OutlinedTextField` components are rendered within the context of the surrounding `Column` field,
which means they will appear stacked vertically.
Therefore the `Column` component is establishing some state that at a minimum is tracking the location of rendered components.
The `Column` component renders within the context of whatever calls the `HelloContent` function,
and this surrounding context will determine where the `Column` is rendered.

Event handling is done by observables; `name` is an example.
When an observable changes any part of the UI that depends on that observable is rerendered.
In the example above, changing the value of the `OutlinedTextField` will update the `name` observable, which in turn will cause a change in the value displayed by the `Text` component.
This is done by tracking uses of observables.
However, the granularity of rerendering is the entire function (marked `@Composable`, and called a composable in Jetpack nomenclature) in which the observable is used.
We can think of the `@Composable` annotation as establishing a context holding a reference to a thunk that is registered with any observables used within the thunk, and reinvoked whenever any of those observables change.


[^tangible]: Smalltalk, and later developments such as [Morphic][morphic], had a laudable focus on presenting information graphically. What you see if what you get, but what about what you don't see? The event graph is not directly rendered on the screen, and in their user interface model the event graph is a secondary concern.

[^other]: There are other structures in a user interface. For example, there is usually another tree to handle input events. These structures are often fairly simple and not directly constructed by the application programmer, so we'll ignore them here.

[^indirection]: "All problems in computer science can be solved by another level of indirection." Attributed to David Wheeler and Butler Lampson.

[morphic]: https://en.wikipedia.org/wiki/Morphic_(software)
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
