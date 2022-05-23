module H = Internal__Dust_Syntax.Html.Elements

let main data =
  H.html [] [
    H.body [] [
      H.h1 [] data
    ]
  ]