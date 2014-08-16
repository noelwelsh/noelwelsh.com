---
layout: post
title: AngularJS vs React
category: programming
repost: underscore
---

[AngularJS](https://angularjs.org/) and [React](http://facebook.github.io/react/index.html) are two of the most prominent Javascript UI frameworks today. It is natural to ask which is best. Having some experience with both my opinion is that React is superior, by a landslide.

I'll get into why in a moment, but first some background so you can understand how I came to this conclusion. I'm not very experienced with either framework. I have written some small projects in AngularJS. I've spent about three days porting part of a medium sized AngularJS project to React, which prompted this writeup. It's possible with more experience of both frameworks I would come to a different conclusion, but for reasons I explain at the end I don't think this will be the case.

With that out of the way, on to my comparison.

## Simplicity

My number one reason for preferring React to AngularJS is its simplicity. This is very apparent when learning the frameworks. AngularJS introduces an explosion of new concepts. There is, at least, *controllers*, *directives*, *factories*, *scopes*, *services*, *transclusion*, the directives library, the module system, and more than I've no doubt forgotten about or haven't encountered yet. Add to that the famously bad documentation, and you have a learning curve like a cliff.

In React there are just four important concepts: *components* with *properties* and *state*. and the internal DOM representation. Components are just code, as is DOM construction. There is so little to React that when I started to learn it I could read all the documentation in just one day. The documentation also made sense, a major advantage over AngularJS.

## Composition

## Conclusions

It certainly is possible to climb the learning curve with AngularJS and be productive using it. Is it worth it? My experience suggests it isn't. React can be used to achieve the same things as AngularJS, it's much simpler to use, and it has some nice optimisations that AngularJS doesn't.
