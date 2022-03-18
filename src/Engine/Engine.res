open Promise
@module external fsglob: array<string> => Promise.t<array<string>> = "fast-glob"
@scope("Object") @val external obj_entries: 'a => array<'a> = "entries"
@val external importJs: string => 'a = "require"
@module("fs-extra") external pathExists: string => Promise.t<bool> = "pathExists"

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

// global functions
let cleanOutputFolder = () => Utils.emptyDir(Config.getFolderOutput())
let deleteAllCache = %raw("
  function() {
    Object.keys(require.cache).forEach(function(key) {
      delete require.cache[key]
    })
  }
")

type templateData<'a> = {main: option<'a>}

type templateMetadata<'b> = {
  status: bool,
  content: option<'b>,
}

let transformTemplate = (originPath, props) => {
  let basename = Node.Path.basename(originPath)->Js.String2.slice(~from=0, ~to_=-3)
  let renderer = (originPath, props) => {
    let data = importJs(originPath)

    let getStatus = data.main->Belt.Option.flatMap(func => func)

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
    ->then(res => res->resolve)
    ->catch(_ => {
      Utils.ErrorMessage.logMessage(#error(`template [${basename}] not exist`))
      false->resolve
    })
  }

  checkFile(originPath)
  ->then(res => res->resolve)
  ->then(res => {
    switch res {
    | true =>
      switch renderer(originPath, props) {
      | Some(val) => {status: true, content: val}->resolve
      | None => {status: false, content: None}->resolve
      }
    | false => {status: false, content: None}->resolve
    }
  })
  ->catch(err => {
    switch err {
    | JsError(obj) => switch Js.Exn.message(obj) {
      | Some(msg) => Utils.ErrorMessage.logMessage(#error(`Something error happen: ${msg}`))
      | None =>
        Utils.ErrorMessage.logMessage(#error(`Something error happen, must be non-error value`))
      }
    | _ => Utils.ErrorMessage.logMessage(#error(`Something unkown error happen`))
    }
    {status: false, content: None}->resolve
  })
}
