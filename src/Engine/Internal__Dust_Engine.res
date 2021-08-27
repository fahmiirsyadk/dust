module Utils = Internal__Dust_Utils
open Promise
@module("node:fs") external mkdirSync: string => unit = "mkdirSync"
@module("node:fs") external existsSync: string => bool = "existsSync"
@module("node:fs") external readFileSync: (string, 'a) => string = "readFileSync"
@module("js-yaml") external yamlLoad: string => 'a = "load"
@module("globby") external globby: string => Promise.t<array<string>> = "globby"
@scope("JSON") @val external parse: string => 'a = "parse"
@scope("Object") @val external obj_entries: 'a => array<'a> = "entries"

type folderConfig = {
  blog: string,
  output: string,
  static: string,
  pages: string,
  base: string,
}

type config = {folder: folderConfig}

type metadata = {
  status: bool,
  origin: string,
  content: string,
  output: string,
}

let configIsExist = ref(true)
let configPath = [Node.Process.cwd(), "dust.config.yml"]->Node.Path.join
let pagesPath = [Node.Process.cwd(), "src", "pages", "**", "*.mjs"]->Node.Path.join->globby
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

let generateHtml = (metadata: metadata) => {
  switch metadata.status {
  | true =>
    Utils.writeFile(
      metadata.output,
      ~options=Utils.writeFileOptions(~encoding=#"utf-8", ()),
      metadata.content,
      (),
    )
  | false => Promise.resolve()
  }
}

let ocamlToHtml = (path, output, meta): Promise.t<metadata> => {
  let file = %raw("
      async function(path, output, props) {
        let data = await import(path)
        const status = data.main ? true : false
        if (status) {
          return { status, origin: path, output, content: data.main(props) }
        } else {
          return { status, origin: path, output, content: `` }
        }
      }
    ")
  file(path, output, meta)
}

let generatePages = () => {
  // Check config sources
  let getConfigSources = dataYaml => {
    dataYaml
    ->Js.toOption
    ->Belt.Option.flatMap(content => content["sources"])
    ->Belt.Option.flatMap(sources => sources)
  }

  // set data sources if exist will return data within array, or else return empty array
  let configSourcesData = () =>
    switch configIsExist.contents {
    | true =>
      switch configPath->readFileSync("utf-8")->yamlLoad->getConfigSources {
      | Some(x) =>
        x->Js.Array2.map(path => {
          open Array
          let flatten = (arr: array<array<'a>>): array<'a> => arr->to_list->concat
          let obj = obj_entries(path)->flatten
          {
            "source": obj[0],
            "path": obj[1],
          }
        })
      | None => []
      }
    | false => []
    }
  configSourcesData()->Js.log
  pagesPath
  ->then(paths => {
    paths
    ->Js.Array2.map(path => {
      let outputPath =
        path
        ->Js.String2.replace(".mjs", ".html")
        ->Js.String2.replace(
          [Node.Process.cwd(), "src", "pages"]->Node.Path.join,
          [Node.Process.cwd(), defaultConfig.folder.output]->Node.Path.join,
        )
      path->ocamlToHtml(outputPath, "")
    })
    ->Promise.all
  })
  ->then(res => res->Js.Array2.map(x => x->generateHtml)->Promise.all)
  ->ignore
}

let getAllMD = ()

let run = () => {
  checkConfig()
  generatePages()
}

run()
