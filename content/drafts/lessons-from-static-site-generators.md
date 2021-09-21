# Lessons from Static Static Generators (Or, Why Static Site Generators are Terrible)

Static site generators (SSG), such as [Zola][zola], [Hugo][hugo], and [Next.js][next], are not the most glamourous side of programming but they are ubiquitous. Many websites, large and small, are created using them, and they're economically important enough that companies developing some them have raised [hundreds of millions of dollars][vercel-funding]. They're also an interesting case study in programming language design.

I've spent enough time with static site generators, and been frustrated enough by their limitations, that I decided to write this blog post about them. I find them an interesting case study in programming language design: their success illustrates the importance of often overlooked aspects of programming and their flaws highlight the utility of existing concerns in programming language theory.


## Static Site Generators

The core problem solved by static site generators is to create a website---a collection of HTML files---from several source components. A typical example is to combine a blog post with a template that styles the post. In almost every SSG a blog post is usually written in [Markdown][commonmark] format with [YAML][yaml] "front-matter". Front-matter is essentially a sequence of key-value pairs that add additional information, such as the title and author, to the post. Here's an example from my blog, where the front matter defines the title of the blog post.

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
  
Here `{{ title }}` inserts the title defined in the front matter and `{{ content }}` the content of the blog post. The statements `{% include header.html %}` and `{% include footer.html %}` insert headers and footers respectively, that are defined in separate files.


## Programming Systems, not Programming Languages.

A static site generator is essentially a system for programming web sites. The example above shows abstraction in 

Websites face issues common to programming. For example, websites have lots of commonality across pages such as a common header and footer.  Rather than repeating this on every page, the developer could create templates for the header and footer and include these templates in the templates that define other pages in the site. Programmery-types should recognize this as fundamental elements of programming: abstraction to create templates and composition to include templates in other templates.

Static site generators often include a programming language, but it's better to think of static site generators as a [programming system][incommensurability]. The other major component of a typical SSG is a build system, for constructing a web site from content, templates, images, and so on. Programming languages have always been embedded in a larger context which too much programming language research ignores. This is a mistake, because the context imposes constraints and opens up possibilities that are not visible if you take the more limited view. A lot of what I want to consider today is the role of context.


## Notation Matters

One thing static site generators get really right is recognizing the importance of notation. In a conventional programming language that language itself is primary, and text needs to be enclosed in quotes. Furthermore text usually needs to worry about escaping and multi-line strings. SSGs invert this: text is primary and an escape is needed to enter a program. A typical system is [Nunjucks][nunjucks], which  SSGs also allow text to be entered in formats such as [Markdown][commonmark], which makes common formatting options, such as headings and emphasis, easier to write than in HTML.

Notation is not considered very important in most programming language research. However it becomes central when you consider programming as a system, as notation is the user interface by which programming is accessed. The text of the web pages is the majority of the user generated content in an static site generator, so it is correctly made the easiest thing to create. In the live coding system [Tidal Cycles][tidal] musical patterns are entered using the ["mini-notation"][mini-notation]. This notation is optimized for brevity, an important consideration for code that is created live. Programming does not have to be textual, as demonstrated by [Para][para], or it can mix text and other representations, as shown by [Sketch-n-sketch][sketch-n-sketch].


## Programming Matters

If static site generators get notation right, the majority of them get almost everything else about programming wrong. Let's look at some examples draw from a number of static site generators. Every SSG I know of has some concept of templates.

[Jekyll][jekyll] uses [Liquid][liquid] templates. Liquid provides a simple imperative programming language

The concept of a function is straight-forward. Informally, you give some stuff to a function (it's arguments) and you get something back. 

We can consider templates as functions. 
In this section I'll use [Eleventy][11ty] and its default template engine [Nunjucks][nunjucks] as an example, as I'm most familiar with their frustrations.

Eleventy and Nunjucks provide a number of forms of abstraction that almost, but no quite, implement functions. Let's start with what's probably the most commonly used abstraction mechanism, the [layout][11ty-layout].

We can think of a page of content as a data structure. The main content is available under the key `content` and additional data can be made available under other keys by using [front matter][11ty-front-matter].

Nunjucks provides a concept known as [macros][nunjucks-macro], described as "similar to a function in a programming language" which makes me wonder what they think Nunjucks is if not a programming language. A macro appears 

A page of content 
 fs fs
I would find this amusing if I hadn't lost many hours to these broken forms of abstractions.

Eleventy and Nunjucks have a pro

Nunjucks seems like a fairly standard imperative programming language, but it is broken in many ways. Here are some of them:

- It uses dynamic scoping. 


## Staging is Real

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
