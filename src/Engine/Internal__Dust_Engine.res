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
  assets: string,
  pages: string,
  base: string,
}

type config = {folder: folderConfig}

type metadata = {
  status: bool,
  filename: string,
  origin: string,
  content: string,
  output: string,
}

let defaultConfig = {
  folder: {
    blog: "blog",
    output: "dist",
    assets: "assets",
    pages: "pages",
    base: "./",
  },
}
let configIsExist = ref(true)
let configPath = [Node.Process.cwd(), "dust.config.yml"]->Node.Path.join
let pagesPath = [Node.Process.cwd(), "src", "pages", "**", "*.mjs"]->Node.Path.join->globby
let outputPath = [Node.Process.cwd(), defaultConfig.folder.output]->Node.Path.join
let checkExistFolder = folder => folder->existsSync

let checkConfig = () => {
  try {
    let _ = "dust.config.yml"->readFileSync("utf-8")
  } catch {
  | Js.Exn.Error(_) => configIsExist := false
  }
}

let cleanOutputFolder = folder => Utils.delSync(folder)

let generateHtml = (metadata: metadata) => {
  switch metadata.status {
  | true =>
    Utils.outputFile(
      metadata.output,
      ~options=Utils.writeFileOptions(~encoding=#"utf-8", ()),
      metadata.content,
      (),
    )
  | false => Promise.resolve()
  }
}

let ocamlToHtml = (path, output, filename, meta): Promise.t<metadata> => {
  let file = %raw("
      async function(path, output, filename, props) {
        let data = await import(path)
        const status = data.main ? true : false
        if (status) {
          return { status, filename, origin: path, output, content: data.main(props) }
        } else {
          return { status, filename, origin: path, output, content: `` }
        }
      }
    ")
  file(path, output, filename, meta)
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
          let obj = obj_entries(path)->Utils.flatten
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
      let filename = path->Node.Path.basename_ext(".mjs")
      let outputPath =
        path
        ->Js.String2.replace(".mjs", ".html")
        ->Js.String2.replace(
          [Node.Process.cwd(), "src", "pages"]->Node.Path.join,
          [
            Node.Process.cwd(),
            defaultConfig.folder.output,
            filename === "index" ? "" : filename,
          ]->Node.Path.join,
        )
      path->ocamlToHtml(outputPath, filename, "")
    })
    ->Promise.all
  })
  ->then(res => res->Js.Array2.map(x => x->generateHtml)->Promise.all)
  // ->ignore
}

let getAllMD = ()
let copyAssetsAndPublic = () => {
  let path = path => [Node.Process.cwd()]->Js.Array2.concat(path)->Node.Path.join

  let copyAssets = () =>
    ["src", defaultConfig.folder.assets]
    ->path
    ->Utils.copy(["dist", defaultConfig.folder.assets]->path)

  let copyPublic = () => 
    ["src", "public"]
    ->path
    ->Utils.copy(["dist"]->path)
  // Fs-extra have issue about race codition on copy function
  // solved with ensureDir that will check availability of dist folder
  // related issue: 
  // https://github.com/serverless/serverless/commit/548bd986e4dafcae207ae80c3a8c3f956fbce037
  //
  Utils.ensureDir(["dist"]->path)
  ->then(_ => [copyAssets(), copyPublic()]->Promise.all)
}

let run = () => {
  outputPath->cleanOutputFolder
  checkConfig()
  [copyAssetsAndPublic(), generatePages()]
  ->Promise.all->ignore
}

run()
