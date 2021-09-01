module Utils = Internal__Dust_Utils
open Promise
@module("node:fs") external mkdirSync: string => unit = "mkdirSync"
@module("node:fs") external existsSync: string => bool = "existsSync"
@module("node:fs") external readFileSync: (string, 'a) => string = "readFileSync"
@module("js-yaml") external yamlLoad: string => 'a = "load"
@module("globby") external globby: string => Promise.t<array<string>> = "globby"
@scope("JSON") @val external parse: string => 'a = "parse"
@scope("Object") @val external obj_entries: 'a => array<'a> = "entries"
@scope("Object") @val external obj_keys: 'a => array<'a> = "keys"
@module("gray-matter") external matter: string => 'a = "default"

type folderConfig = {
  blog: string,
  output: string,
  assets: string,
  pages: string,
  base: string,
}

type config = {folder: folderConfig}

type metadataML = {
  status: bool,
  filename: string,
  content: string,
  path: string,
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
let globalMetadata: array<{}> = []
let rootPath = Node.Process.cwd()
let configPath = [rootPath, ".dust.yml"]->Node.Path.join
let pagesPath = [rootPath, "src", "pages", "**", "*.mjs"]->Node.Path.join->globby
// Need to change btw
let outputPath = [rootPath, defaultConfig.folder.output]->Node.Path.join

let checkConfig = () => {
  try {
    let _ = ".dust.yml"->readFileSync("utf-8")
  } catch {
  | Js.Exn.Error(_) => configIsExist := false
  }
}

let cleanOutputFolder = folder => Utils.delSync(folder)

let generateHtml = (htmlContent, location) => {
  location->Utils.outputFile(
    htmlContent,
    ~options=Utils.writeFileOptions(~encoding=#"utf-8", ()),
    (),
  )
}

let parseML = (metadata, root, output, filename, obj): Promise.t<metadataML> => {
  let process = %raw("
    async function(metadata, root, output, filename, obj) {
      const res = await import(metadata.layout)
      const status = res.main ? true : false
      const path = Path.join(root, output, metadata.name, Path.basename(filename, `.md`) + `.html`)
      if (status) {
        return { status, filename, path, content: res.main(obj) }
      } else {
        return { status, filename, path, content: `` }
      }
    }
  ")
  process(metadata, root, output, filename, obj)
}

let parseMarkdown = data => {
  open Utils.Unified

  unified()
  ->use(remarkParse)
  ->use(remarkGfm)
  ->use(rehype)
  ->use(stringify)
  ->process(data)
  ->then(res => res["value"]->resolve)
}

// let renderPages = () => {

// }



let renderCollections = () => {
  // Check config collections
  let getCollectionConfig = path => {
    path
    ->readFileSync("utf-8")
    ->yamlLoad
    ->Js.toOption
    ->Belt.Option.flatMap(content => content["collections"])
  }

  let processCollectionConfig = () => {
    let readConfig = () => {
      switch configPath->getCollectionConfig {
      | Some(collections) => collections
      | None => []
      }
    }

    switch configIsExist.contents {
    | true => readConfig()
    | false => []
    }
  }

  let processCollectionMetadata = () =>
    configPath
    ->readFileSync("utf-8")
    ->yamlLoad
    ->processCollectionConfig
    ->obj_entries
    ->Js.Array2.map(collection => {
      open Node.Path
      {
        "name": collection[0],
        "layout": [rootPath, "src", "layouts", collection[1]["layout"] ++ ".mjs"]->join->normalize,
        "source": [rootPath, collection[1]["source"]]->join->normalize,
        "pattern": [rootPath, collection[1]["source"], "*.md"]->join->normalize,
      }
    })

  let transformMeta = %raw("
    function(metadata, page, md, matter) {
      const newMatter = {...matter, content: md}
      const url = Path.join(`/`, metadata.name, Path.basename(page, `.md`))
      return {
        ...metadata,
        ...newMatter,
        url,
        page
      }
    }
  ")

  let processCollectionPages = metadata => {
    metadata["pattern"]
    ->globby
    ->then(pages => {
      pages
      ->Js.Array2.map(page => {
        Utils.readFile(page, "utf-8")->then(raw => {
          let matter = raw->matter
          matter["content"]
          ->parseMarkdown
          ->then(mdHtml => {
            let obj = transformMeta(metadata, page, mdHtml, matter)
            let _ = globalMetadata->Js.Array2.push(obj)
            parseML(metadata, rootPath, defaultConfig.folder.output, page, obj)
          })
        })
      })
      ->resolve
    })
    ->then(eachReadFile => eachReadFile->Promise.all)
    ->then(collections => [collections]->Utils.flatten->resolve)
    ->then(collections => collections->Js.Array2.map(collection => {
      	collection.content->generateHtml(collection.path)
    })->Promise.all)
  }

  processCollectionMetadata()
  ->Js.Array2.map(metadata => {
    metadata->processCollectionPages
  })
  ->Promise.all
}

let sortGlobalCollectionMeta = %raw("
  function(metadata) {
    let obj = {};
    metadata.forEach(data => {
      if(obj.hasOwnProperty(data.name)) {
        obj[`${data.name}`] = [{...obj[`${data.name}`]}, data]
      } else {
        obj = { ...obj, [data.name]: data }
      }
    })
    return obj
  }
")

let copyAssets = () => {
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
  renderCollections()
}

// let generatePages = (pagesPath, metadata) => {
//   pagesPath
//   ->then(paths => {
//     paths
//     ->Js.Array2.map(path => {
//       let filename = path->Node.Path.basename_ext(".mjs")
//       let specialPage = switch filename {
//       | "index"
//       | "404"
//       | "500" => true
//       | _ => false
//       }
//       let outputPath =
//         path
//         ->Js.String2.replace(filename, !specialPage ? "index" : filename)
//         ->Js.String2.replace(".mjs", ".html")
//         ->Js.String2.replace(
//           [rootPath, "src", "pages"]->Node.Path.join,
//           [rootPath, defaultConfig.folder.output, specialPage ? "" : filename]->Node.Path.join,
//         )
//       path->ocamlToHtml(outputPath, filename, metadata)
//     })
//     ->Promise.all
//   })
//   ->then(res => res->Js.Array2.map(x => x->generateHtml)->Promise.all)
// }

// let copyAssetsAndPublic = () => {

// }

// let run = () => {
//   outputPath->cleanOutputFolder
//   checkConfig()
//   [copyAssetsAndPublic(), mdToPages()->then(res => pagesPath->generatePages(res))]
//   ->Promise.all
//   ->ignore
// }

// run()
