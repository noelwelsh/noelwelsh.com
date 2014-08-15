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

My number one reason for preferring React to AngularJS is its simplicity. In React there are three concepts: *components* with *properties* and *state*. Components are just code. Writing React is just writing code. And because there is so little to React, when I wanted to learn it I could read all the documentation in just one day.

In contrast AngularJS has an explosion of new concepts. There are, at least, *controllers*, *directives*, *factories*, *scopes*, *services*, the directives library, the module system, the dependency injection system, and quite possibly more I don't even know about yet. Add to that the famously bad documentation.

## Conclusions

It certainly is possible to climb the learning curve with AngularJS and be productive using it. Is it worth it? My experience suggests it isn't. React can be used to achieve the same things as AngularJS, it's much simpler to use, and it has some nice optimisations that AngularJS doesn't.
