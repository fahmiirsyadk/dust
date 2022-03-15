module H = Internal__Dust_Syntax.Html.Elements

let main () =
  H.html [] [
    H.body [] [
      H.h1 [] [ "TEST" ]
    ]
  ]