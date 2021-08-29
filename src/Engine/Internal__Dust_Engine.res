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

type metadataPage = {
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
let rootPath = Node.Process.cwd()
let configPath = [rootPath, ".dust.yml"]->Node.Path.join
let pagesPath = [rootPath, "src", "pages", "**", "*.mjs"]->Node.Path.join->globby
let outputPath = [rootPath, defaultConfig.folder.output]->Node.Path.join

let checkConfig = () => {
  try {
    let _ = "dust.config.yml"->readFileSync("utf-8")
  } catch {
  | Js.Exn.Error(_) => configIsExist := false
  }
}

let cleanOutputFolder = folder => Utils.delSync(folder)

let generateHtml = metadata => {
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

let ocamlToHtml = (path, output, filename, meta): Promise.t<metadataPage> => {
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

let generatePages = (pagesPath, metadata) => {
  pagesPath
  ->then(paths => {
    paths
    ->Js.Array2.map(path => {
      let filename = path->Node.Path.basename_ext(".mjs")
      let specialPage = switch filename {
      | "index"
      | "404"
      | "500" => true
      | _ => false
      }
      let outputPath =
        path
        ->Js.String2.replace(filename, !specialPage ? "index" : filename)
        ->Js.String2.replace(".mjs", ".html")
        ->Js.String2.replace(
          [rootPath, "src", "pages"]->Node.Path.join,
          [rootPath, defaultConfig.folder.output, specialPage ? "" : filename]->Node.Path.join,
        )
      path->ocamlToHtml(outputPath, filename, metadata)
    })
    ->Promise.all
  })
  ->then(res => res->Js.Array2.map(x => x->generateHtml)->Promise.all)
}

let mdToHtml = data => {
  open Utils.Unified

  unified()
  ->use(remarkParse)
  ->use(remarkGfm)
  ->use(rehype)
  ->use(stringify)
  ->process(data)
  ->then(res => res["value"]->resolve)
}

let mdToPages = () => {
  // Check config sources
  let getConfigSources = dataYaml => {
    dataYaml
    ->Js.toOption
    ->Belt.Option.flatMap(content => content["sources"])
    ->Belt.Option.flatMap(sources => sources)
  }

  // set data sources if exist will return data within array, or else return empty array
  let transformConfigSource = () =>
    switch configIsExist.contents {
    | true =>
      switch configPath->readFileSync("utf-8")->yamlLoad->getConfigSources {
      | Some(x) =>
        x->Js.Array2.map(path => {
          let obj = obj_entries(path)->Utils.flatten
          let pathResolve = path => [rootPath]->Js.Array2.concat(path)->Node.Path.join
          // create temporary metadata to simplify the process
          {
            "source": obj[0],
            "path": [obj[1]]->pathResolve,
            "pattern": [obj[1], "*.md"]->pathResolve,
          }
        })
      | None => []
      }
    | false => []
    }

  let configSources = () =>
    transformConfigSource()->Js.Array2.map(data => {
      data["pattern"]
      ->globby
      ->then(res =>
        {
          "source": data["source"],
          "path": data["path"],
          "files": res,
        }->resolve
      )
    })

  let jsObjFile = %raw("
    function(source, filename, content, raw, internal) {
      return {
        filename,
        ...internal,
        data: {
          name: `${source}/${filename}`,
          content,
          raw,
        }
      }
    }
  ")

  configSources()
  ->Promise.all
  ->then(res =>
    res
    ->Js.Array2.mapi((data, dataIndex) => {
      data["files"]->Js.Array2.mapi((file, _) => {
        let filename = file->Node.Path.basename_ext(".md")
        file
        ->Utils.readFile("utf-8")
        ->then(raw => {
          raw
          ->mdToHtml
          ->then(content =>
            jsObjFile(data["source"], filename, content, raw, res[dataIndex])->resolve
          )
        })
      })
    })
    ->Utils.flatten
    ->Promise.all
  )
  ->then(metas => {
    metas
    ->Js.Array2.map(meta => {
      let filename = meta["data"]["name"]
      let path = [rootPath, defaultConfig.folder.output, filename, "index.html"]->Node.Path.join
      path->Utils.outputFile(
        ~options=Utils.writeFileOptions(~encoding=#"utf-8", ()),
        meta["data"]["content"],
        (),
      )
    })
    ->Promise.all
    ->then(_ => metas->resolve)
  })
}

let copyAssetsAndPublic = () => {
  let path = x => [rootPath]->Js.Array2.concat(x)->Node.Path.join

  let copyAssets = () =>
    ["src", defaultConfig.folder.assets]
    ->path
    ->Utils.copy(["dist", defaultConfig.folder.assets]->path)

  let copyPublic = () => ["src", "public"]->path->Utils.copy(["dist"]->path)
  // Fs-extra have issue about race codition on copy function
  // solved with ensureDir that will check availability of dist folder
  // related issue:
  // https://github.com/serverless/serverless/commit/548bd986e4dafcae207ae80c3a8c3f956fbce037
  //
  Utils.ensureDir(["dist"]->path)->then(_ => [copyAssets(), copyPublic()]->Promise.all)
}

let run = () => {
  outputPath->cleanOutputFolder
  checkConfig()
  [copyAssetsAndPublic(), mdToPages()->then(res => pagesPath->generatePages(res))]
  ->Promise.all
  ->ignore
}

run()
