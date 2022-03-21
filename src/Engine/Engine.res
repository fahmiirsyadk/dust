open Promise
@module external fsglob: array<string> => Promise.t<array<string>> = "fast-glob"
@scope("Object") @val external obj_entries: 'a => array<'a> = "entries"
@val external importJs: string => 'a = "require"
@module("fs-extra") external pathExists: string => Promise.t<bool> = "pathExists"

exception MyError(string)

type metaTemplate = {
  status: bool,
  filename: string,
  content: string,
  path: string,
}

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
    | Ok(_) => {
      switch renderer(originPath, props) {
      | Some(val) => {content: val}
      | None => {content: None}
      }
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

    Js.log(outputPath)

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
    ->catch(err => {
      Js.log("Somethings error")
      err->reject
    })
  }
}