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
@scope("JSON") @val
external parseJson: string => 'a = "parse"

let renderMarkdown = raw => {
  let matter = raw->matter
  let theme = parseJson(
    Node.Fs.readFileAsUtf8Sync(
      Node.Path.join2(
        Internal__Dust_Config.rootPath,
        Internal__Dust_Config.config.syntaxThemeUrl,
      )->Node.Path.normalize,
    ),
  )

  getHighlighter({
    "theme": theme,
  })->Promise.then(h => {
    let md = markdownIt({
      html: true,
      highlight: (code, lang) => h.codeToHtml(. code, {"lang": lang}),
    })
    {"matter": matter, "html": md->render(matter["content"])}->Promise.resolve
  })
}
