@module("fs") external existsSync: string => bool = "existsSync"
@module("js-yaml") external yamlLoad: string => 'a = "load"

type folderConfig = {
  output: string,
  base: string,
  openBrowser: bool
}

let rootPath = Node.Process.cwd()
let configPath = [rootPath, ".dust.yml"]->Node.Path.join

let defaultFolderConfig = {
  output: [rootPath, "dist"]->Node.Path.join,
  base: [rootPath, "src"]->Node.Path.join,
  openBrowser: true
}

let isConfigExist = configPath->existsSync

let dataConfig = {
  if configPath->existsSync {
    configPath->Node.Fs.readFileSync(#utf8)->yamlLoad->Js.toOption
  } else {
    Js.Nullable.null->Js.toOption
  }
}

let dustConfig = () => {
  switch dataConfig->Belt.Option.flatMap(content => content["dust"]) {
  | Some(config) => config
  | None => Js.Nullable.null
  }->Js.toOption
}

let getFolderBase = () => {
  switch dustConfig()->Belt.Option.flatMap(data => data["base"]) {
  | Some(val) => val
  | None => defaultFolderConfig.base
  }
}

let getFolderOutput = () => {
  switch dustConfig()->Belt.Option.flatMap(data => data["output"]) {
  | Some(val) => val
  | None => defaultFolderConfig.output
  }
}

let getOpenBrowser = () => {
  switch dustConfig()->Belt.Option.flatMap(data => data["openBrowser"]) {
  | Some(val) => val
  | None => defaultFolderConfig.openBrowser
  }
}

let config = {
  base: [rootPath, getFolderBase()]->Node.Path.join,
  output: [rootPath, getFolderOutput()]->Node.Path.join,
  openBrowser: getOpenBrowser()
}

let collections = () => {
  switch dataConfig->Belt.Option.flatMap(content => content["collections"]) {
  | Some(collections) => collections
  | None => []
  }
}