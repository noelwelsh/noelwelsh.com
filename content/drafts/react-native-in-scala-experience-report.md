# React Native in Scala, an Experience Report

I've recently spent a bit of time playing with [Slinky][slinky], a [Scala.js][scalajs] library for [React][react], and [React Native][react-native]. My goals were to assess its viability for both commercial mobile app development and for fun case studies at [ScalaBridge London][scalabridgelondon]. In this blog post I describe:

- React Native and [Expo][expo];
- Slinky; and
- the developer experience using Slinky to create React Native apps.

To save you scrolling to the end here are my conclusions: Slinky is very nice and works well for normal React development. The [ScalablyTyped][scalablytyped] plugin makes it reasonably straightforward to wrap JavaScript libraries (with TypeScript type definitions) in Scala APIs. React Native is a bit rougher. Slinky provides wrappers for the most common React Native components. However there is a good chunk of the API that is not wrapped. I couldn't get ScalablyTyped working with Expo's build process, so my options for accessing these parts of the React Native API were dropping Expo or wrapping APIs by hand. Neither was a great option for my use. Slinky and Scala is a good choice for funtime development with React Native, but not a great choice for commercial development unless you don't require Expo.


## React Native and Expo

If you're reading this there is a good chance you're not a mobile app developer, so let me start with a quick overview of React Native and Expo.

React Native is a toolkit for building mobile applications targetting iOS and Android that presents a model that is similar to using using React in the web browser. Specifically, it uses the React programming model but UIs are built from React Native specific components instead of DOM notes and layout is performed using a variant of CSS. The React Native components, however, bind to platform native components which gives better performance and access to platform specific features.

Expo is a development environment and library that builds on React Native. It's main value, from my point of view, comes from the ease of prototyping. A normal React Native app requires installing the platform (iOS or Android) development kit. This makes setup a bit cumbersome. With Expo you can install a mobile app that will hot load the app you're developing from your machine. This makes the development experience much more pleasant, but more important is that it is more accessible. Without Expo developing a React Native app for iOS requires owning a Mac. Many ScalaBridge students only have old Windows laptops, and if they couldn't run their app on their phone; well, that would take away a lot of the fun.


## Slinky

Slinky brings React into Scala.js. It has a programming model that is almost identical to React in Javascript, so existing React tutorials can be translated with ease. The modern "hook" API is 


## Getting Started with Slinky

Very easy. `sbt new` etc. Expo gives hot reload. Very easy.


## Wrapping Libraries

Animation library

React Native documentation could do with some improvement.

Getting ScalablyTyped to work was beyond me.

Wrapping the library wasn't super hard but was going to take more time than I could justify. (Did get some of it working.) As an aside the structure of the animated library was moderately opaque. It's odd that I think it was developed with types (I think React Native uses Flow) but the library didn't seem to have the kind of structure I'd expect from TDD.

## Conclusions


[expo]: https://expo.io/
[slinky]: https://slinky.dev/
[scala-js]: http://www.scala-js.org/
[react]: https://reactjs.org/
[react-native]: https://reactnative.dev/
[corecursive]: https://corecursive.com/044-shadaj-laddad-react-and-scala-js/
[scalabridgelondon]: http://scalabridgelondon.org/
[scalablytyped]: https://scalablytyped.org/docs/readme.html
