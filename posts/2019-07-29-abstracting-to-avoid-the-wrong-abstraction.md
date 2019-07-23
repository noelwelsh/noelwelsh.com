---
title: Abstracting to Avoid the Wrong Abstraction
---

There's an [interesting blog post][the-wrong-abstraction] that argues that code duplication is better than the wrong abstraction. This blog post came to mind when I was recently wrestling with the Java graphics API. However I don't think the blog got it right. In this post I want to argue that---at least in certain cases---the wrong abstraction is not enough abstraction, and _completely abstracting_ (with a generic type) is the right solution. This gives an interesting decision rule---a programming strategy if you will---for when one should use a concrete type, a generic type, or the imtermediate point we call a type class.

<!-- more -->

I was recently adding animated GIF support to [Doodle][doodle]. The output of my first implementation was [pure awful][pure-awful] instead of the [pure awesome][pure-awesome] I was hoping for. I discovered that animated GIFs have an option to specify what happens to the previous frame when a new frame is about to be displayed: it can be kept around so the new frame renders on top of the old frame, or the old frame can be cleared. I thought this might be causing the ugly output (it looked a bit like old frames were kept around). To test this I needed to set some metadata on the image, this is where things became really ugly.

The [`imageio`][imageio] package provides the built-in Java tools for reading and writing images, and are what I was using. The developers of this library knew that images have metadata, but there is a problem here: different image formats support different metadata. For example, in addition to the setting I described above, animated GIFs have other properties such as setting the delay between frames. These properties don't make sense for image formats that cannot display animations (which is most of them). So what type should the method that sets the metadata accept?

The answer in `imageio` is XML (via a bit of indirection through the [IIOMetadata][iiometadata] type). You can kinda see 

, which is a mostly useless type. About the only useful thing you can do with it is convert it into XML

[the-wrong-abstraction]: https://www.sandimetz.com/blog/2016/1/20/the-wrong-abstraction
[doodle]: https://github.com/creativescala/doodle
[pure-awful]: /images/abstracting-to-avoid-the-wrong-abstraction/pulsing-circle.gif 
[pure-awesome]: /images/abstracting-to-avoid-the-wrong-abstraction/pulsing-circle-2.gif 
[imageio]: https://docs.oracle.com/javase/8/docs/api/javax/imageio/package-summary.html
[iiometadata]: https://docs.oracle.com/javase/8/docs/api/javax/imageio/metadata/IIOMetadata.html
