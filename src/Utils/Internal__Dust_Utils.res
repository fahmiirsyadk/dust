type writeFileOptions

type encoding = [
  | #"utf-8"
]

@obj
external writeFileOptions: (
  ~mode: int=?,
  ~flag: string=?,
  ~encoding: encoding=?,
  unit,
) => writeFileOptions = ""

@module("fs") @scope("promises")
external writeFile: (string, string, ~options: writeFileOptions=?, unit) => Promise.t<unit> =
  "writeFile"

module Klaw = {
  type t
  @module("klaw") external klaw: 'a => t = "default"
  @send external on: (t, string, 'a => 'b) => t = "on"
}

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

  let logMessage = msg =>
    switch msg {
    | #error(msg) => kleur->bold()->red(j`--- Oh no, we found error ---\n>> ${msg} <<\n`)
    | #warning(msg) => kleur->bold()->yellow(j`--- Just in case, warning ---\n>> ${msg} <<\n`)
    | #info(msg) => kleur->bold()->blue(j`--- Information for you ---\n>> ${msg} <<\n`)
    }->Js.log
}
