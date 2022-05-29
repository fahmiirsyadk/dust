type t

type markdownConfig<'a> = {
  html: bool,
  highlight: (string, 'a) => string,
}
type h<'a> = {codeToHtml: (. string, 'a) => string}
@new @module external markdownIt: markdownConfig<'a> => t = "markdown-it"
@send external render: (t, string) => string = "render"
@module("shiki") external getHighlighter: 'a => Promise.t<h<'b>> = "getHighlighter"
@module external matter: string => 'a = "gray-matter"

let renderMarkdown = raw => {
  getHighlighter({
    "theme": "nord",
  })->Promise.then(h => {
    let md = markdownIt({
      html: true,
      highlight: (code, lang) => h.codeToHtml(. code, {"lang": lang}),
    })
    {"matter": raw->matter, "html": md->render(raw)}->Promise.resolve
  })
}
