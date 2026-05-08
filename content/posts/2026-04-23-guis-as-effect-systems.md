+++
title = "Capability-passing User Interfaces"
draft = true
+++

Recent user interfaces frameworks, across the browser and native platforms, have converged on an underlying model that represents user interfaces as effects. 

In this article discuss what makes user interfaces challenging to code, 
walk through the evolution of code architectures for user interfaces,
and finish by showing how a variety of recent models can be unified by considering user interfaces as effects.

<!-- more -->

## The Problems of User Interfaces

User interfaces are difficult to create. This is in part because user interfaces have an enormous amount of detail; there's just a lot of stuff to write for a good user interface. That's not the problem we're considering here. Rather, we're concerned with the architecture. That is, the way in which the user interface author expresses the structure of the user interface. (*Consider rewriting this description*)

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

This code is written in the callback-driven style that will be familiar to many developers from the browser DOM but which stretches back to Smalltalk and the first GUIs.

This approach focuses on the **components** representing what is displayed on the screen[^tangible]. `Input` and `Button` represent the text input and the button, respectively, and the `RowContainer` specifies the text input and button should be displayed in a row. The important points to take from this are:

1. Components are values. We can pass them around and combine them to produce new components, as we do when passing `i` and `b` to the `RowContainer`.
2. Components form a tree. We'll call this the **layout tree**.

*diagram here*

It's natural to focus on what we see on the screen, but this ignores another structure that is equally important: the flow of events. In the example above the input field `i` refers to the button `b`, to enable it, and the button `b` refers backs to the input field `i`, to clear it. This means the event handling structure is a cyclic graph, which is a more complex structure than the layout tree.

*diagram here*

Expressing cyclic structures in code is difficult. The solution in the callback-driven style is to write user interfaces as a two stage process. First we create all the components. Now that we can reference any particular component of interest, we add callbacks to define the event handling structure. Layout is straightforward to read in this model, but event handling is fragmented across a mess of callbacks and becomes difficult to reason about.

In summary, user interfaces require we define two structures[^other]: layout and event handling. Layout is a tree, but event handling is a cyclic graph. How different architectures handle this is the core of what we'll examine.


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


## Interfaces as Effects

Let's now move on to the final category of architectures. As far as I know, I'm the first person to make this claim. So here I'm going to present examples of code from several existing frameworks, extract the common ideas from them, and make the argument that we can model them all as representing interfaces as direct-style effect systems.


### Immediate-Mode GUIs

Our starting example will be so-called immediate-mode GUIs. 
There is a small example below using the [egui] framework,
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

Let's first focus on the layout tree.
Each component, such as `heading` or `button`, is an effect.
We can see this because there is no overall container representing the GUI.
However, there is internal state.
Each new component renders below the previous one,
so the system must be keeping track of the current screen coordinates.
Therefore we can think of the system having an implicit container, which is held inside the global `ui` value.
Sometimes the container is made explicit, as in the call to `ui.horizontal`.

Events handling in immediate-mode GUIs is quite different to other systems.
There is a single example of event handling above, the call to `clicked` when the button is rendered.
This works because immediate-mode GUIs rerender on every frame,
so as the frame is rendered it can also check for coinciding input events.
Note that event handling requires storing state across frames.
For example, a click event is differentiated from a drag event by the starting and ending locations of the click events,
so this information must be stored until the determination can be made.


### Jetpack Compose

Let's now look at [Jetpack Compose][jetpack-compose], the UI framework used in Android and also in [Compose Multiplatform][compose-mp].
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


### Solid

Our final example will be [Solid][solid-js], a Javascript framework for the web.
It's similar to contemporaries like [React][react] and [Vue][vuejs], but a little bit more explicit about the parts we care about.
Here's an example:

```js
function App() {
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
```

The first thing to notice is that components are *not* effects, but values. This is a requirement of using the [DOM][dom]; you have to construct DOM elements. So the layout tree is explicitly represented by the structure of the DOM.

Event handling uses observables, called signals in Solid, in a way similar to Jetpack Compose. Use of an observable in a DOM element registers a dependency, and that dependency is updated when the observable's value changes. This works because Solid uses a compiler. The above code compiles into

```js
function App() {
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
```

The calls to `_$insert` register dependencies. In this case the dependencies are fine-grained. When an observable updates, only the exact DOM elements that depend on it are changed. This is unlike Jetpack Compose, which will reinvoke the entire composable. This means that Solid potentially does less work, but other effects that depend on observables must be wrapped within calls to `createEffect`. 

[^tangible]: Smalltalk, and later developments such as [Morphic][morphic], had a laudable focus on directly representing ... WYSIWYG but what about what you don't see?

[^other]: There are other structures in a user interface. For example, there is usually another tree to handle input events. These structures are often not directly constructed by the application programmer, so we'll ignore them here.

[^indirection]: "All problems in computer science can be solved by another level of indirection." Attributed to David Wheeler and Butler Lampson.

[morphic]: https://en.wikipedia.org/wiki/Morphic_(software)
[reactivex]: https://reactivex.io/
[flapjax]: https://www.flapjax-lang.org/
[rxjs]: https://rxjs.dev
[egui]: https://github.com/emilk/egui
[jetpack-compose]: https://developer.android.com/compose
[compose-mp]: https://kotlinlang.org/compose-multiplatform/
[solid-js]: https://www.solidjs.com
[react]: https://react.dev/
[vue]: https://vuejs.org/
[dom]: https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model
