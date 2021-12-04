module Extra = {
  module H = Internal__Dust_Syntax.Html.Elements
  module A = Internal__Dust_Syntax.Html.Attributes

  let meta_twitter = (~title="", ~description="", ~card="", ()) => {
    [
      H.meta(list{A.name("twitter:title"), A.content(title)}, list{}),
      H.meta(list{A.name("twitter:description"), A.content(description)}, list{}),
      H.meta(list{A.name("twitter:card"), A.content(card)}, list{}),
    ]->Belt.Array.reduce("", (x, y) => x ++ y)
  }

  let inject = (file) => {
    let text = Node.Fs.readFileAsUtf8Sync( Node.Path.join2(Internal__Dust_Config.config.base, file))
    text
  }
}
