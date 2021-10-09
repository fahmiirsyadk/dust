type t
@new @module external markdownIt: unit => t = "markdown-it"
@send external render: (t, string) => string = "render"
@module external matter: string => 'a = "gray-matter"

let md = markdownIt()

let mdToHtml = mdfile => md->render(mdfile)
let mdToMatter = mdfile => mdfile->matter