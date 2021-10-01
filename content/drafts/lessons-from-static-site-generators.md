# Lessons from Static Static Generators (Or, Why Static Site Generators are Terrible)

Static site generators (SSG), such as [Zola][zola], [Hugo][hugo], and [Next.js][next], are not the most glamourous side of programming but they are ubiquitous. Many websites, large and small, are created using them. They're economically important enough that the company developing Next.js, for example,  has raised [hundreds of millions of dollars][vercel-funding]. They're also an interesting case study in programming language design: their success illustrates the importance of often overlooked aspects of programming and their flaws highlight the relevance of existing concerns in programming language theory.

I've been using static site generators for a very long time. I have used Jekyll, Hakyll, Gatsby, Eleventy, Next.js, and Zola to create either personal sites or small commercial sites. One of the first commercial programs I wrote was a static site generator, which helped me create the website of one of first consulting clients. That generators didn't live for very long but I guess it indicates I've been thinking about this problem for a while. I've also been frustrated with the limitations of existing systems starting about ten minutes after I finished that first one way back in 1998.


## Static Site Generators

The core problem solved by static site generators is to create a collection of text files---usually HTML files making up a website---from several source components. A typical example is to combine a blog post with a template that styles the post. The default in almost every current SSG is to write blog posts in [Markdown][commonmark] format with [YAML][yaml] "front-matter". Front-matter is essentially a sequence of key-value pairs that add additional information, such as the title and author, to the post. Here's an example from my blog, where the front matter defines the title of the blog post.

    ---
    title: What Functional Programming Is, What it Isn't, and Why it Matters
    ---
    
    The programming world is moving towards functional programming (FP). More developers are using languages with an explicit bias towards FP, such as Scala and Haskell, while object-oriented (OO) languages and their communities adopt FP features and practices. (A striking example of the latter is the rise of Typescript and React in the Javascript community.) &hellip;
 
A template is usually text interpersed with escapes to a simple programming language. [Liquid][liquid] and [Nunjucks][nunjucks] are two typical examples. Both use `{%` and  `%}` to delimit statements, and `{{` and `}}` for expressions. A very simple template might look like

    <html>
      <head><title>{{ title }}</title></head>
      <body>
        {% include header.html %}
        <h1>{{ title }}</h1>
        {{ content }}
        {% include footer.html %}
      </body>
    </html>
  
Here `{{ title }}` inserts the title defined in the front-matter and `{{ content }}` the content of the blog post. The statements `{% include header.html %}` and `{% include footer.html %}` insert header and footer templates respectively, which are defined in separate files. This example shows two primary concerns of programming languages: abstraction to extract resuable components into templates, and composition to combine templates together in the final result. Eagle-eyed readers will have noticed some confusing semantics here: some text is inserted using expressions and other using statements. This hints at some of the problems we'll see later but for now let's look at what static site generators get right.


## Programming Systems, not Programming Languages.

Although static site generators include programming languages it's better to think of them as [programming systems][incommensurability]. That is, the programming language lives in the context of a larger system that makes the language useful. When we consider programming systems, instead of languages in isolation, different tradeoffs are possible. For example, we might be ok giving up static safety if we have great tools for runtime inspection. In some ways this is the approach taken by Smalltalk, which is very definitely a programing system (though probably the type theory of the time was not sufficient for it to be any other way.)

The are two main components of a typicall SSG: the template system, which we've already briefly described, and a build system. Tasks covered by the build system can include resizing and compressing images, building CSS stylesheets, and minimizing HTML, CSS, and Javascript code, in addition to applying content to templates. This build system is usually controlled with a different language to that used in templates. Programming the build system is often dismissed as "configuration" which dimishes the fact that it is a programming task and the usual concerns of programming apply. 

Providing a programming system is one of the great benefits of a SSG. Building a static site generator is not difficult---it could reasonably be done in a weekend by an experienced programmer---but the value is in having a preassembled system that solves a particular task. Although the individual components could be assembled by hand, having them combined in a single package is what makes SSGs valuable. 


## Notation Matters

One thing static site generators get really right is recognizing the importance of notation. In a conventional programming language the code itself is the main thing, and text needs to be enclosed in quotes. For example, in Scala (and just about every other language) text is delimited with `"`

```scala
val aString = "text goes in quotes"
```

Furthermore text usually needs to worry about escaping and multi-line strings. 

SSGs invert this: text is primary and an escape is needed to enter a program. We've seen the examples above, which use `{{` and `{%` to enter code and `}}` and `%}` to exit back to text. 

Text is usually written in [Markdown][commonmark] format. Markdown is a simple notation that makes common formatting commands, such as heading and lists, easier to write than in HTML.

Notation is not considered very important in most programming language research. However it becomes central when you consider programming as a system, as notation is the user interface by which programming is accessed. The text of the web pages is the majority of the user generated content in an static site generator, so it is correctly made the easiest thing to create. There are other examples. In the live coding system [Tidal Cycles][tidal] musical patterns are entered using the ["mini-notation"][mini-notation]. This notation is optimized for brevity, an important consideration for code that is created in front of an audience. The user interface does not have to be textual, as demonstrated by [Para][para], or it can mix text and other representations, as shown by [Sketch-n-sketch][sketch-n-sketch].


## Programming Matters

If static site generators get notation right, the majority of them get almost everything else about programming wrong. Here I'm going to look at programming fundamentals and see the sorry state of programming in the static site generators.

Functions are a basic mechanism for abstraction. The concept of a function is straight-forward. Informally, a function accepts some stuff (it's parameters) and returns something back when arguments are applied to the parameters. Changing the arguments gives different results, hence abstracting over some common pattern.

We are going to see how [Liquid][liquid] treats functions. Liquid is perhaps the most commonly used templating language as it's the one used by [Jekyll][jekyll], the SSG built in to Github. The functionality reported below was tested using Ruby 2.7.2p137 and Jekyll 4.2.0.

Liquid doesn't have functions as such, but it does have filters, tags, and templates.

A filter is the Liquid feature most like a function. It has unusual syntax, using a pipe operator rather than standard function application. For example, instead of writing `abs(-4)` in Liquid one writes `-4 | abs`. Pipes can be nested, and if a filter takes more than one argument the successive arguments follow the filter with a colon separator. For example `-4 | abs | at_least: 42` evaluates to `42`. We can do normal programming language things, like refer to names for arguments (though filters are not first-class values). The following snippet binds the name `a_number` to `42` and then evaluates to `42`

```
{% assign a_number = 42 %}
{{ -4 | abs | at_least: a_number }}
```

The most significant limitation of filters is that the user cannot define their own. Otherwise they function like, well, functions.

Templates can be either "layouts" or "includes" in Jekyll. They achieve the same goal, which is to place computed values into a largely textual document. I don't know why Jekyll includes both concepts. I'll focus on includes here, as they are more flexible but also more unusual.

Here's an example of a simple include, which we'll assume is stored in a file called `header.html`

```html
<section>
  <h2>This is the header for {{ include.title }}</h2>
</section>
```

This include has a single parameter called `title`, and hence we can consider templates as functions that produce text. Functions, that is, with a fatal flaw: they are dynamically scoped[^scope]. Includes share the scope of the template that includes them, and can directly reference (and even modify!) any variables that are present in the template. Dynamic scoping was shown to a Bad Things in the [the Art of the Interpreter][aoti] back in 1973.

[^scope]: I'm not certain if Liquid has dynamic scope or just one global scope shared by all templates and includes, which is slightly different. It didn't do the experiments to confirm one way or the other because, dear reader, I am utterly sick of Liquid at this point.


Here is how we call an include, passing a value for a parameter.

```
{% include header.html title="Notice" %}
```

This is a tag. There are already some strange things going on here. Notice the `include` is delimited with `{%` and `%}`. The Jekyll documentation says

> in Liquid you output content using two curly braces e.g. `{{ variable }}` and
> perform logic statements by surrounding them in a curly brace percentage sign
> e.g. `{% if statement %}`.

The Liquid documentation is even more direct:

> The curly brace percentage delimiters `{%` and `%}` and the text that they
> surround do not produce any visible output when the template is rendered.

Yet here we have code surrounded by curly brace percentage delimiters which very clearly produces visible output.

There is more strangeness. Notice that the name of the include, `header.html`, is not enclosed in quotation marks. In other words, it's not a string literal. This suggests that we can't compute the name of a template, but in fact we can. The following example shows that we use the `{{  }}` syntax to reference a variable for the name of the template.

```
{% assign template_name = "header.html" %}
{% include {{ template_name  }} title="Notice" %}
```

Again, this makes no sense in light of the (supposed) meaning of the `{{ }}` delimiters given in the documentation.

There is yet another quirk. If a string literal argument includes a `{{` and  `}}` pair, and there is text that matches the syntax for a variable name between the pair, the string literal is rejected. This description is a bit confusing (but so are the rules) so here is a concrete example. The following is rejected

```
{% include header.html password="{{ wat }}" %}
```

with the error message

```
Liquid Exception: Invalid syntax for include tag. File contains invalid characters or sequences: header.html password="" 
```

Notice that the error message doesn't include the actuall offending text---poor error messages are fairly typical. Note that the following is fine.

```
{% include header.html password="{{ wat?! }}" %}
```

Another annoyance of Liquid is that it hasn't *really* learned the lesson of notation. Liquid has an escape to go from text to code, but there is no escape to go from code to text. I have often found I want to write a fairly large block of text as a parameter for an include, and there is no nice way to write this without defining an unnecessary variable using a `capture` tag. It is also not clear when Markdown is parsed. Suffice to say I've had problems where Markdown text I expected to be parsed was displayed without being converted to HTML.

Liquid has many other odd features. For example, it has an array type but no way to write an array literal. It has an object type (a value with properties) as they are used ubiquitously in Jekyll, but they are not described at all in the documentation of Liquid's types and it's not possible to write object literals either. In fact I don't know any way to create an object, whereas arrays at least can be created by splitting a string. There are plenty of other strange features, but this is enough to make my point.

Finally, these oddities are not unique Liquid and Jekyll. [Nunjucks][nunjucks], the default templating language of [Eleventy][11ty], has filters, *and* functions, *and* [macros][nunjucks-macro][^macros].  Eleventy adds their own version of functions---called shortcodes---into the mix. Nunjucks has dynamic scoping, like Liquid, and adds another mechanism for composition called template inheritance which comes with its own limitations. It also has recursive for loops, a feature I have never encountered in any other language.

[^macros]: The documentation describes macros as "similar to a function in a programming language"---which makes me wonder what they think Nunjucks is if not a programming language, and what a macro is if not a function.

My experience using these frameworks is that simple changes, which I expect to take a maybe half an hour, turn into marathon multi-hour sessions. The arbitrary limitations of the abstraction mechanisms mean I often run into unexpected roadblocks. The ad-hoc semantics mean that knowledge from other programming languages, or even other features in the same language, can't be used to infer to the behaviour of unfamiliar features. Finally the poor error messages give little clue as to what is wrong, and there is no debugger or REPL to give clarity.

All of the problems I have described have been solved in the programming literature. I've already mentioned dynamic scoping, which was addressed in 1973. Escaping into and out of a data format is solved in Lisp using quasi-quote and unquote, and in other languages using string interpolation. Semantics is clearly a major concern in programming language theory, and finding minimal expressive abstractions arguably dates back to the lambda calculus, developed before digital computers even existed.


## Staging is Real

Recently there has been a new class of static site generators, that instead of outputting plain text sites output sites that are rendered using Javascript. Examples include [Gatsby] and [Next.js][next]. These tools have some issues---for one, the site may not be viewable without Javascript running. However they solve most of the issues I gave above. I don't think this is because the authors have any greater knowledge of programming languages than the authors of the olders SSGS, but rather because the assumption is you'll write code in Javascript and Javascript, despite it's many flaws, is a reasonably well-designed and modern language in its current incarnation.

One interesting new problem these tools bring is that of staging. When a site is built with code, and the site itself may run code, we need to clear about what runs when. In particular, if I'm doing some computation to render part of the site (for example, accessing a database to get a list of products) when exactly is this computation performed? When I build the site or when the site is viewed in the user's browser. 



## Conclusions

Why have I spent so much time writing up everything I think is wrong with static site generators? One reason is I hope future SSGs can learn from the mistakes of the past.

Maybe some programming language researchers will read this.


[zola]: https://www.getzola.org/
[hugo]: https://gohugo.io/
[jekyll]: https://jekyllrb.com/
[next]: https://nextjs.org/
[liquid]: https://shopify.github.io/liquid/
[vercel-funding]: https://craft.co/vercel/funding-rounds
[incommensurability]: https://www.dreamsongs.com/Files/Incommensurability.pdf
[nunjucks]: https://mozilla.github.io/nunjucks/
[commonmark]: https://commonmark.org/
[yaml]: https://yaml.org/ 
[tidal]: https://tidalcycles.org/
[mini-notation]: https://tidalcycles.org/docs/patternlib/tutorials/mini_notation
[para]: https://dl.airtable.com/.attachments/ad3fb4f941503ca569496b7cd4414aa6/38527f40/para1.pdf
[sketch-n-sketch]: https://arxiv.org/pdf/1907.10699.pdf
[11ty]: https://www.11ty.dev/
[11ty-layout]: https://www.11ty.dev/docs/layouts/
[11ty-front-matter]: https://www.11ty.dev/docs/data-frontmatter/
[nunjucks-macro]: https://mozilla.github.io/nunjucks/templating.html#macro
[aoti]: https://dspace.mit.edu/handle/1721.1/6094
