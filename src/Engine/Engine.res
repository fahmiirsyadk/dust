open Promise
@module external fsglob: array<string> => Promise.t<array<string>> = "fast-glob"
@scope("Object") @val external obj_entries: 'a => array<'a> = "entries"

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


let cleanOutputFolder = () => Utils.emptyDir(Config.getFolderOutput())