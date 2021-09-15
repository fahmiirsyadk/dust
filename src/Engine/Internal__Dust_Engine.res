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

let globalMetadata: array<{.}> = []
let rootPath = Node.Process.cwd()
let configPath = [rootPath, ".dust.yml"]->Node.Path.join
let pagesPath = [rootPath, "src", "pages"]->Node.Path.join
let pagesPathGlob = [pagesPath, "**", "*.mjs"]->Node.Path.join

// Need to change btw
let configIsExist = configPath->existsSync
let outputPath = [rootPath, defaultConfig.folder.output]->Node.Path.join

let cleanOutputFolder = () => {
  Utils.emptyDir(outputPath)
}

let generateHtml = (htmlContent, location) => {
  location->Utils.outputFile(
    htmlContent,
    ~options=Utils.writeFileOptions(~encoding=#"utf-8", ()),
    (),
  )
}

let parseMLCollection = (metadata, root, output, filename, obj): Promise.t<metadataML> => {
  let process = %raw("
    async function(metadata, root, output, filename, obj) {
      
      async function importFresh() {
        const cache = `${metadata.layout}?update=${Date.now()}`
        return (await import(cache))
      }

      const res = await importFresh()
      const status = res.main ? true : false
      const path = Path.join(root, output, metadata.name, Path.basename(filename, `.md`), `index.html`)
      if (status) {
        return { status, filename, path, content: res.main(obj) }
      } else {
        return { status, filename, path, content: `` }
      }
    }
  ")
  process(metadata, root, output, filename, obj)
}

let parseMLPages = (metadata, path, output): Promise.t<metadataML> => {
  let process = %raw("
    async function(metadata, path, output) {
      
      async function importFresh() {
        const cache = `${path}?update=${Date.now()}`
        return (await import(cache))
      }

      const res = await importFresh()      
      const status = res.main ? true : false

      if (status) {
        return { status, path: output, content: res.main(metadata) }
      } else {
        return { status, path: output, content: `` }
      }
    }
  ")
  process(metadata, path, output)
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

let renderCollections = (~isMetaOnly, ()) => {
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

    switch configIsExist {
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
    // Make sure globalMetadata values are empty
    let _ =
      globalMetadata->Js.Array2.removeCountInPlace(~pos=0, ~count=globalMetadata->Js.Array2.length)

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
            parseMLCollection(metadata, rootPath, defaultConfig.folder.output, page, obj)
          })
        })
      })
      ->resolve
    })
    ->then(eachReadFile => eachReadFile->Promise.all)
    ->then(collections => [collections]->Utils.flatten->resolve)
    ->then(collections =>
      switch isMetaOnly {
      | true => [()]->resolve
      | false =>
        collections
        ->Js.Array2.map(collection => {
          collection.content->generateHtml(collection.path)
        })
        ->Promise.all
      }
    )
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

let copyAssetsAndPublic = () => {
  let path = x => [rootPath]->Js.Array2.concat(x)->Node.Path.join

  let assets = () => ["src", "assets"]->path->Utils.recCopy(["dist", "assets"]->path)
  let public = () => ["src", "public"]->path->Utils.copy(["dist"]->path)

  [assets(), public()]->Promise.all
}

let renderPage = (pagePath, metadata) => {
  let pageFilename = pagePath->Node.Path.basename_ext(".mjs")
  let specialPage = switch pageFilename {
  | "index"
  | "404"
  | "500" => true
  | _ => false
  }

  let targetPath =
    pagePath
    ->Js.String2.replace(
      pageFilename,
      !specialPage ? [pageFilename, "index"]->Node.Path.join : pageFilename,
    )
    ->Js.String2.replace(".mjs", ".html")
    ->Js.String2.replace(
      [rootPath, "src", "pages"]->Node.Path.join,
      [rootPath, defaultConfig.folder.output]->Node.Path.join,
    )
  metadata->sortGlobalCollectionMeta->parseMLPages(pagePath, targetPath)
  ->then(res => res.status === true ? res.content->generateHtml(res.path): ()->resolve)
}

let renderPages = (pagesPath, metadata) => {
  pagesPath
  ->then(paths => {
    paths
    ->Js.Array2.map(path => {
      let pageFilename = path->Node.Path.basename_ext(".mjs")
      let specialPage = switch pageFilename {
      | "index"
      | "404"
      | "500" => true
      | _ => false
      }

      let targetPath =
        path
        ->Js.String2.replace(
          pageFilename,
          !specialPage ? [pageFilename, "index"]->Node.Path.join : pageFilename,
        )
        ->Js.String2.replace(".mjs", ".html")
        ->Js.String2.replace(
          [rootPath, "src", "pages"]->Node.Path.join,
          [rootPath, defaultConfig.folder.output]->Node.Path.join,
        )
      metadata->sortGlobalCollectionMeta->parseMLPages(path, targetPath)
    })
    ->Promise.all
  })
  ->then(res => res->Js.Array2.filter(x => x.status === true)->resolve)
  ->then(res => res->Js.Array2.map(x => x.content->generateHtml(x.path))->Promise.all)
}

// first build
let run = () => {
  if configIsExist {
    [
      Utils.ensureDir(outputPath)->then(() => copyAssetsAndPublic()),
      renderCollections(~isMetaOnly=false, ())->then(_ =>
        renderPages(pagesPathGlob->globby, globalMetadata)
      ),
    ]->Promise.all
  } else {
    [
      Utils.ensureDir(outputPath)->then(() => copyAssetsAndPublic()),
      renderPages(pagesPathGlob->globby, globalMetadata),
    ]->Promise.all
  }
}

// update
let update = path => {
  let replacePath = origin => origin->Js.String2.replace("src", "dist")
  let replacePathAndRemove = origin => origin->Js.String2.replace("src", "dist")->Utils.remove
  let replaceFile = (origin, target) => {
    origin->Js.String2.includes(target)
      ? {
          let newPath = origin->replacePath
          newPath->Utils.remove->then(_ => path->Utils.recCopy(newPath))->ignore
        }
      : ()
  }

  // process assets
  path->replaceFile(defaultConfig.folder.assets)
  path->replaceFile("public")
  // process pages
  let filename = path->Node.Path.basename
  let dataPagesTuple = (
    filename->Js.String2.includes(".md"),
    filename->Js.String2.includes(".ml"),
    path->Js.String2.includes(pagesPath),
  )
  switch dataPagesTuple {
  | (true, false, false) =>
    path->replacePathAndRemove->then(_ => renderCollections(~isMetaOnly=false, ()))->ignore
  | (false, true, true) =>
    path
    ->replacePathAndRemove
    ->then(_ => renderCollections(~isMetaOnly=true, ()))
    ->then(_ => renderPage(path->Js.String2.replace(".ml", ".mjs"), globalMetadata))
    ->ignore
  | (false, true, false) =>
    path
    ->replacePathAndRemove
    ->then(_ => renderCollections(~isMetaOnly=false, ()))
    ->then(_ => renderPage(path->Js.String2.replace(".ml", ".mjs"), globalMetadata))
    ->ignore
  | _ => Js.log("watching another ???")
  }
}
