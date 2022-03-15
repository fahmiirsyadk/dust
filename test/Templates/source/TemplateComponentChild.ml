module H = Internal__Dust_Syntax.Html.Elements

let head title =
  H.head [] [
    H.title [] [
      title
    ]
  ]

let heading title =
  H.h1 [] [
    title
  ]