module H = Dust.Html.Elements
module A = Dust.Html.Attributes

let main () =
  H.html [] [
    H.head [] [
      H.title [] (H.text "Hello, World!")
    ]
  ; H.body [] [
      Box.box
    ; H.h1 [] (H.text "Hello, World!")
    ]
  ]