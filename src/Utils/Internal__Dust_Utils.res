type writeFileOptions

type encoding = [
  | #"utf-8"
]

type recursiveCopyOptions = {
  overwrite: bool,
  dot: bool,
  results: bool
}

@obj
external writeFileOptions: (
  ~mode: int=?,
  ~flag: string=?,
  ~encoding: encoding=?,
  unit,
) => writeFileOptions = ""
@module("fs-extra")
external outputFile: (string, string, ~options: writeFileOptions=?, unit) => Promise.t<unit> =
  "outputFile"
@module("fs-extra") external copy: (string, string) => Promise.t<unit> = "copy"
@module("fs-extra") external ensureDir: string => Promise.t<unit> = "ensureDir"
@module("fs") @scope("promises")
external readFile: (string, string) => Js.Promise.t<string> = "readFile"
@module("fs-extra") external emptyDirSync: string => unit = "emptyDirSync"
@module("fs-extra") external emptyDir: string => Promise.t<unit> = "emptyDir"
@module("fs-extra") external remove: string => Promise.t<unit> = "remove"
@module external recCopy: (string, string, recursiveCopyOptions) => Promise.t<unit> = "recursive-copy"
let flatten = (arr: array<array<'a>>): array<'a> => arr->Array.to_list->Array.concat

module Klaw = {
  type t
  @module("klaw") external klaw: 'a => t = "default"
  @send external on: (t, string, 'a => 'b) => t = "on"
}

module Kleur = {
  type t
  @module external kleur: t = "kleur"
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
    | #error(msg) => kleur->bold()->red(j`--- Oh no, we found error ---\n ${msg}\n-----------------------------\n`)
    | #warning(msg) => kleur->bold()->yellow(j`--- Just in case, warning ---\n ${msg}\n-----------------------------\n`)
    | #info(msg) => kleur->bold()->blue(j`--- Information for you ---\n ${msg}\n-----------------------------\n`)
    }->Js.log
}

module Chokidar = {
  type t

  type awaitWriteFinishOptions = {
    stabilityThreshold: int,
    pollInterval: int,
  }

  type watchConfig = {
    ignored: string,
    ignoreInitial: bool,
    awaitWriteFinish: awaitWriteFinishOptions,
    depth: int,
  }

  @module external watcher: t = "chokidar"
  @send external watch: (t, string, watchConfig) => t = "watch"
  @send external on: (t, string, 'a => unit) => t = "on"
}

module LiveServer = {
  type t
  type serverConfig = {
    root: string,
    logLevel: int,
    @as("open") opens: bool,
  }
  @module external server: t = "live-server"
  @send external start: (t, serverConfig) => unit = "start"
}
