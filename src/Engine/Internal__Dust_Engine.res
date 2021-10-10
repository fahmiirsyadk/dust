open Promise
@module external clearModule: string => unit = "clear-module"
@module external fsglob: array<string> => Promise.t<array<string>> = "fast-glob"
@scope("Object") @val external obj_entries: 'a => array<'a> = "entries"

type metadataML = {
  status: bool,
  filename: string,
  content: string,
  path: string,
}

module Config = Internal__Dust_Config
module Markdown = Internal__Dust_Markdown
module Utils = Internal__Dust_Utils

let globalMetadata: array<{.}> = []
let pagesPath = [Config.getFolderBase(), "pages"]->Node.Path.join
let pagePattern = [pagesPath, "**", "*.js"]->Node.Path.join

let cleanOutputFolder = () => Utils.emptyDir(Config.getFolderOutput())

let generateHtml = (htmlContent, location) => {
  location->Utils.outputFile(
    htmlContent,
    ~options=Utils.writeFileOptions(~encoding=#"utf-8", ()),
    (),
  )
}

let parseCollection = (meta, output, filename, props): metadataML => {
  let process = %raw("
  function (meta, output, filename, props) {
    const importFresh = require(`import-fresh`)
    let res = importFresh(`${meta.layout}`)
    
    const status = res.main ? true : false
    const filepath = Path.join(output, meta.name, Path.basename(filename, `.md`), `index.html`)
    
    if(status) {
      return { status, filename, path: filepath, content: res.main(props)}
    } else {
      return { status, filename, path: filepath, content: ``}
    }
  }")
  process(meta, output, filename, props)
}

let parsePages = (metadata, path, output): metadataML => {
  let process = %raw("
  function (meta, filepath, output) {
    const importFresh = require(`import-fresh`)
    let res = importFresh(filepath)

    const status = res.main ? true : false
    
    if(status) {
      return { status, path: output, content: res.main(meta) }
    } else {
      return { status, path: output, content: `` }
    }
  }")
  process(metadata, path, output)
}

let renderCollections = () => {
  let collectionMetadata = () =>
    Config.collections()
    ->obj_entries
    ->Js.Array2.map(collection =>
      {
        "name": collection[0],
        "layout": [Config.getFolderBase(), "layouts", collection[1]["layout"] ++ ".js"]
        ->Node.Path.join
        ->Node.Path.normalize,
        "source": [Config.rootPath, collection[1]["source"]]->Node.Path.join->Node.Path.normalize,
        "pattern": [Config.rootPath, collection[1]["source"], "*.md"]
        ->Node.Path.join
        ->Node.Path.normalize,
      }
    )

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

  let proccessCollectionPages = metadata => {
    // Make sure globalMetadata valus are empty first
    let _ =
      globalMetadata->Js.Array2.removeCountInPlace(~pos=0, ~count=globalMetadata->Js.Array2.length)

    [metadata["pattern"]]
    ->fsglob
    ->then(pages => {
      pages
      ->Js.Array2.map(page => {
        Utils.readFile(page, "utf-8")->then(raw => {
          let matter = raw->Markdown.mdToMatter
          let html = matter["content"]->Markdown.mdToHtml
          let props = transformMeta(metadata, page, html, matter)
          let _ = globalMetadata->Js.Array2.push(props)
          parseCollection(metadata, Config.getFolderOutput(), page, props)->resolve
        })
      })
      ->resolve
    })
    ->then(eachFile => eachFile->Promise.all)
    ->then(collections => [collections]->Utils.flatten->resolve)
    ->then(collections =>
      collections
      ->Js.Array2.map(collection => collection.content->generateHtml(collection.path))
      ->Promise.all
    )
  }

  collectionMetadata()
  ->Js.Array2.map(metadata => {
    metadata->proccessCollectionPages
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

let copyPublic = () => {
  let publicPath = [Config.getFolderBase(), "public"]->Node.Path.join
  publicPath->Node.Fs.existsSync
    ? publicPath->Utils.recCopy(
        Config.getFolderOutput(),
        {overwrite: true, dot: true, results: false},
      )
    : resolve()
}

let renderPage = (pagePath, metadata) => {
  let pageFilename = pagePath->Node.Path.basename_ext(".js")
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
    ->Js.String2.replace(".js", ".html")
    ->Js.String2.replace(
      [Config.getFolderBase(), "pages"]->Node.Path.join,
      Config.getFolderOutput(),
    )

  let pages = metadata->sortGlobalCollectionMeta->parsePages(pagePath, targetPath)
  pages.status === true ? pages.content->generateHtml(pages.path) : ()->resolve
}

// first build
let run = () => {
  [pagePattern]
  ->fsglob
  ->then(paths => {
    let listRenderPages = () => paths->Js.Array2.map(path => renderPage(path, globalMetadata))

    if Config.isConfigExist {
      Utils.ensureDir(Config.getFolderOutput())->then(() => copyPublic())->ignore
      renderCollections()->then(_ => listRenderPages()->Promise.all)
    } else {
      Utils.ensureDir(Config.getFolderOutput())->then(() => copyPublic())->ignore
      listRenderPages()->Promise.all
    }
  })
}

// update
let update = path => {
  let replacePath = origin => origin->Js.String2.replace("src", "dist")
  let replacePathAndRemove = origin => origin->Js.String2.replace("src", "dist")->Utils.remove
  let replaceFile = (origin, target) => {
    origin->Js.String2.includes(target)
      ? {
          let newPath = origin->replacePath
          newPath->Utils.remove->then(_ => path->Utils.copy(newPath))->ignore
        }
      : ()
  }

  // process assets
  path->replaceFile("public")
  // process pages
  let filename = path->Node.Path.basename
  let dataPagesTuple = (
    filename->Js.String2.includes(".md"),
    filename->Js.String2.includes(".ml"),
    path->Js.String2.includes(pagesPath),
  )
  switch dataPagesTuple {
  | (true, false, false) => path->replacePathAndRemove->then(_ => renderCollections())->ignore
  | (false, true, false) => path->replacePathAndRemove->then(_ => renderCollections())->ignore
  | (false, true, true) =>
    path
    ->replacePathAndRemove
    ->then(_ => renderPage(path->Js.String2.replace(".ml", ".js"), globalMetadata))
    ->ignore
  | _ => Js.log("watching another ???")
  }
}
