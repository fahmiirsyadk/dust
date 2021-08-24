open Promise
module Utils = Internal__Dust_Utils
@module("node:fs") external mkdirSync: string => unit = "mkdirSync"
@module("node:fs") external existsSync: string => bool = "existsSync"
@module("node:fs") external readFileSync: (string, 'a) => string = "readFileSync"
@module("js-yaml") external yamlLoad: string => 'a = "load"
@module("globby") external globby: string => array<string> = "globby"
@scope("JSON") @val external parse: string => 'a = "parse"

module Kleur = {
  type t
  @module("kleur") external kleur: t = "default"
  @send external bold: (t, 'a) => t = "bold"
  @send external green: (t, 'a) => t = "green"
  @send external yellow: (t, 'a) => t = "yellow"
  @send external blue: (t, 'a) => t = "blue"
  @send external underline: (t, 'a) => t = "underline"
  @send external red: (t, 'a) => t = "red"
}

module ErrorMessage = {
  open Kleur
  type t = [
    | #error(string)
    | #warning(string)
    | #info(string)
  ]

  let logMessage = msg =>
    switch msg {
    | #error(msg) => kleur->bold()->red(j`--- Oh no, we found error ---\n>> ${msg} <<\n`)
    | #warning(msg) => kleur->bold()->yellow(j`--- Just in case, warning ---\n>> ${msg} <<\n`)
    | #info(msg) => kleur->bold()->blue(j`--- Information for you ---\n>> ${msg} <<\n`)
    }->Js.log
}

type folderConfig = {
  blog: string,
  output: string,
  static: string,
  pages: string,
  base: string,
}

type syntaxOutput = {status: bool, data: string}
type config = {folder: folderConfig}

let configIsExist = ref(true)

let configPath = [Node.Process.cwd(), "dust.config.yml"]->Node.Path.join

let defaultConfig = {
  folder: {
    blog: "blog",
    output: "dist",
    static: "static",
    pages: "pages",
    base: "./",
  },
}

let checkExistFolder = folder => folder->existsSync
let checkConfig = () => {
  try {
    let _ = "dust.config.yml"->readFileSync("utf-8")
  } catch {
  | Js.Exn.Error(_) => configIsExist := false
  }
}

let cleanOutputFolder = folder => {
  checkExistFolder(folder) ? () : mkdirSync(folder)
}

let generateHtml = htmlContent => {
  let _ = Utils.writeFile(
    [Node.Process.cwd(), "test.html"]->Node.Path.join,
    ~options=Utils.writeFileOptions(~encoding=#"utf-8", ()),
    htmlContent,
    (),
  )
}

let getMarkdownSources = dataYaml => {
  dataYaml
  ->Js.toOption
  ->Belt.Option.flatMap(content => content["sources"])
  ->Belt.Option.flatMap(sources => sources)
}

let generatePages = () => {
  let pagesPath = [Node.Process.cwd(), "src", "pages", "**", "*.mjs"]->Node.Path.join->globby

  let markdownPath = () =>
    switch configIsExist.contents {
    | true => {
        let configContent = configPath->readFileSync("utf-8")->yamlLoad
        switch configContent->getMarkdownSources {
        | Some(x) => x
        | None => []
        }
      }
    | false => []
    }

  markdownPath()->Js.log

  let pageFileImport = (path, meta): Promise.t<syntaxOutput> => {
    let file = %raw("
      async function(path, props) {
        let data = await import(path)
        const status = data.main ? true : false
        if (status) {
          return { status, data: data.main(props) }
        } else {
          return { status, data: `` }
        }
      }
    ")
    file(path, meta)
  }

  Promise.resolve(pagesPath)
  ->then(res => {
    res->Js.Array2.map(page => page->pageFileImport(""))->resolve
  })
  ->then(res => {
    res
    ->Promise.all
    ->then(render => {
      let _ = render[0].data->generateHtml
      resolve()
    })
    ->ignore
    resolve()
  })
  ->ignore
}

let getAllMD = ()

let run = () => {
  checkConfig()
  (configIsExist.contents ? "has config" : "no config")->Js.log
  generatePages()
}

run()
