type metaTemplate = {
  status: bool,
  filename: string,
  content: string,
  path: string,
}

type metaCollection = {
  name: string,
  layout: string,
  source: string,
  pattern: string,
}

open Promise
@module external fsglob: array<string> => Promise.t<array<string>> = "fast-glob"
@scope("Object") @val external obj_entries: 'a => array<('b, 'c)> = "entries"
@val external importJs: string => 'a = "require"
@module("fs-extra") external pathExists: string => Promise.t<bool> = "pathExists"

module Config = Internal__Dust_Config
module Markdown = Internal__Dust_Markdown
module Utils = Internal__Dust_Utils

let globalMetadata: array<{.}> = []
let pagesPath = [Config.getFolderBase(), "pages"]->Node.Path.join->Node.Path.normalize
let pagePattern = [pagesPath, "**", "*.js"]->Node.Path.join->Node.Path.normalize

let cleanOutputFolder = path => {
  switch path {
  | Some(val) => Utils.emptyDir(val)
  | None => Utils.emptyDir(Config.getFolderOutput())
  }
}

let deleteAllCache = %raw("
  function() {
    Object.keys(require.cache).forEach(function(key) {
      delete require.cache[key]
    })
  }
")

let sortGlobalCollectionMeta = %raw("
  function(metadata) {
    let obj = {};

    metadata.forEach(meta => {
      if(obj.hasOwnProperty(meta.name)) {
        obj[meta.name].push(meta)
      } else {
        obj[meta.name] = [meta]
      }
    })

    return obj
  }
")

type templateMetadata<'b> = {content: option<'b>}

let parseTemplate = (originPath, props) => {
  let basename = Node.Path.basename(originPath)->Js.String2.slice(~from=0, ~to_=-3)
  let renderer = (originPath, props) => {
    let data = importJs(originPath)

    let getStatus = Js.Nullable.toOption(data["main"])

    switch getStatus {
    | Some(val) => val(props)
    | None => {
        Utils.ErrorMessage.logMessage(#info(`main function in [${basename}] not exist`))
        None
      }
    }
  }

  let checkFile = path => {
    pathExists(path)
    ->then(res => Ok(res)->resolve)
    ->catch(e => {
      let msg = switch e {
      | JsError(err) =>
        switch Js.Exn.message(err) {
        | Some(msg) => msg
        | None => ""
        }
      | _ => "Unexpected error occurred when checking file"
      }
      Error(msg)->resolve
    })
  }

  checkFile(originPath)
  ->then(res => {
    switch res {
    | Ok(_) =>
      switch renderer(originPath, props) {
      | Some(val) => {content: val}
      | None => {content: None}
      }
    | Error(msg) => {
        Utils.ErrorMessage.logMessage(#error(`Something unknown error happen with message: ${msg}`))
        {content: None}
      }
    }->resolve
  })
  ->catch(e => {
    let msg = switch e {
    | JsError(err) =>
      switch Js.Exn.message(err) {
      | Some(msg) => `Something error happen: ${msg}`
      | None => `Something error happen, must be non-error value`
      }
    | _ => `Something unkown error happen`
    }
    Utils.ErrorMessage.logMessage(#error(msg))
    {content: None}->resolve
  })
}

let parseCollection = collections => {
  open Js.Array2
  let getMetadata: array<metaCollection> = {
    collections
    ->obj_entries
    ->Js.Array2.map(collection => {
      open Node
      open Config
      let (name, data) = collection
      let sourcePath = Path.join2(getFolderBase(), data["source"])
      {
        name: name,
        layout: [getFolderBase(), "layouts", data["layout"] ++ ".js"]->Path.join->Path.normalize,
        source: sourcePath->Path.normalize,
        pattern: sourcePath->Path.join2("*.md")->Path.normalize,
      }
    })
  }

  let transformMeta = %raw("
      function(config, metadata, page, md, matter) {
        const newMatter = {...matter, content: md}
        const url = Path.join(`/`, metadata.name, Path.basename(page, `.md`))
        return {
          config: config,
          ...metadata,
          ...newMatter,
          url,
          page
        }
      }
    ")

  // getMetadata
  let process = metadata => {
    let _ = globalMetadata->removeCountInPlace(~pos=0, ~count=globalMetadata->length)

    [metadata.pattern]
    ->fsglob
    ->then(pages => {
      pages->map(page => Utils.readFile(page, "utf8"))->resolve
    })
    ->then(promisePages => promisePages->all)
    // ->then(contents => {
    //   contents
    //   ->map(content => {
    //     let matter = content->Markdown.mdToMatter
    //     let html = matter["content"]->Markdown.mdToHtml
    //     let config = switch Config.dataConfig {
    //     | Some(val) => val
    //     | None => ""
    //     }
    //     let props = transformMeta(config, metadata, content, html, matter)
    //     let _ = globalMetadata->push(props)
    //     parseTemplate(content, metadata)
    //   })
    //   ->resolve
    // })
  }
  getMetadata->map(metadata => metadata->process)->all->then(res => res->Utils.flatten->resolve)
}

module Transform = {
  let page = (originPath, props) => {
    let basename = path => Node.Path.basename(path)->Js.String2.slice(~from=0, ~to_=-3)
    // List of whitelisted page / special pages
    // instead of going nested folder/index.html
    // we just use the filename as the page name
    // TODO: add more pages ( dynamic from configs)
    let whiteListPage = switch basename(originPath) {
    | "index"
    | "404"
    | "500" => true
    | _ => false
    }

    let outputPath =
      [
        Config.getFolderOutput(),
        whiteListPage
          ? basename(originPath) ++ ".html"
          : basename(originPath)->Node.Path.join2("index.html"),
      ]
      ->Node.Path.join
      ->Node.Path.normalize

    parseTemplate(originPath, props)
    ->then(res => {
      switch res.content {
      | Some(val) =>
        Utils.outputFile(
          outputPath,
          val,
          ~options=Utils.writeFileOptions(~encoding=#"utf-8", ()),
          (),
        )
      | None => resolve()
      }
    })
    ->catch(e => {
      let msg = switch e {
      | JsError(err) =>
        switch Js.Exn.message(err) {
        | Some(msg) => `Something error happen: ${msg}`
        | None => `Something error happen, must be non-error value`
        }
      | _ => `Something unkown error happen`
      }
      Utils.ErrorMessage.logMessage(#error(msg))
      resolve()
    })
  }
}

let copyPublicFiles = () => {
  let publicPath = [Config.getFolderBase(), "public"]->Node.Path.join->Node.Path.normalize
  publicPath->Node.Fs.existsSync
    ? publicPath->Utils.recCopy(
        Config.getFolderOutput(),
        {overwrite: true, dot: true, results: false},
      )
    : resolve()
}

// first build
let build = () => {
  let listProcessPage = paths => paths->Js.Array2.map(path => Transform.page(path, globalMetadata))
  Utils.ensureDir(Config.getFolderOutput())
  ->then(() => [pagePattern]->fsglob)
  ->then(paths => {
    listProcessPage(paths)->Promise.all
  })
}
