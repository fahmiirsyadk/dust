@module("node:fs") external mkdirSync: string => unit = "mkdirSync"
@module("node:fs") external existsSync: string => bool = "existsSync"
@module("node:fs") external readFileSync: (string, 'a) => string = "readFileSync"
@module("js-yaml") external yamlLoad: string => 'a = "load"
@scope("JSON") @val external parse: string => 'a = "parse"

module Kleur = {
  type t
   @module("kleur") external kleur: t = "default"
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

  let logMessage = msg => switch msg {
  | #error(msg) => kleur->bold()->red(j`--- Oh no, we found error ---\n>> ${msg} <<\n`)
  | #warning(msg) => kleur->bold()->yellow(j`--- Just in case, warning ---\n>> ${msg} <<\n`)
  | #info(msg) => kleur->bold()->blue(j`--- Information for you ---\n>> ${msg} <<\n`)
  }->Js.log
}

type folderConfig = {
  blog: string,
  output: string,
  static: string,
  pages: string,
  base: string,
}

type config = {folder: folderConfig}

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
let getConfig = () => {
  // let fm = Belt.Option.flatMap

  let configFile = "dust.config.yml"->readFileSync("utf-8")->yamlLoad
  // let data =
  //   configFile["dust"]
  //   ->Js.Nullable.toOption
  //   ->fm(dust => dust["markdown"])
  //   ->fm(markdown => markdown["log"])

  Js.log2(configFile["sources"], configFile)
}

let cleanOutputFolder = folder => {
  checkExistFolder(folder) ? () : mkdirSync(folder)
}

let getAllPages = ()
let getAllMD = ()

let run = () => {
  getConfig()
  // cleanOutputFolder(Node.Path.join([defaultConfig.folder.base, defaultConfig.folder.output]))
  // let dataTemp = ref("")
  // try {
  //   dataTemp.contents = readFileSync("no.dat", "utf-8")
  // } catch {
  // | Js.Exn.Error(obj) =>
  //   switch obj->Js.Exn.message {
  //   | Some(err) => ErrorMessage.logMessage(#error(err))
  //   | None => "Error not recognized"->Js.log
  //   }
  // }
}

run()
