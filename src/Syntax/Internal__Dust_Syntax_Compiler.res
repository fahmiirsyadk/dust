type t =
  | Single
  | Paired

type typeAttr =
  | AttrString(string, string)
  | AttrBool(string, bool)
  | AttrInt(string, int)

let render = (tagType, tag, attrs, children) => {
  let el = switch children {
  | list{} => ""
  | list{head, ...rest} => List.fold_left((a, b) => a ++ b, head, rest)
  }

  let at = switch attrs {
  | list{} => ""
  | list{head, ...rest} => List.fold_left((a, b) => j`$a$b`, head, rest)
  }

  let validateHTMLTag = (template, tag) =>
    switch tag === "html" {
    | true => j`<!DOCTYPE html>$template`
    | false => template
    }

  switch tagType {
  | Single => j`<$tag$at>`->validateHTMLTag(tag)
  | Paired => j`<$tag$at>$el</$tag>`->validateHTMLTag(tag)
  }
}

// transform function into proper html attribute syntax
let attrFormat = (typeAttr) => {
  let transform = (prop, attr) => j` $attr="$prop"`
  switch typeAttr {
  | AttrString(attr, prop) => transform(attr, prop)
  | AttrInt(attr, prop) => prop->Js.Int.toString->transform(attr)
  // Shorthand for attribute that have boolean value
  //
  // instead <input disabled="true"></input>, it can be just <input disabled></input>
  // otherwise, when the value is false, the value of the attribute still remains
  // CMIIW
  | AttrBool(attr, prop) => prop ? j` $attr` : transform(attr, "false")
  }
}