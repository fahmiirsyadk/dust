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
external writeFile: (string, string, ~options: writeFileOptions=?, unit) => Js.Promise.t<unit> =
  "writeFile"
